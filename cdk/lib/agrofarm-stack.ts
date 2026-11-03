import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as budgets from 'aws-cdk-lib/aws-budgets';
import { Construct } from 'constructs';

export interface AgroFarmStackProps extends cdk.StackProps {
  /** E-mail that receives the cost alerts. Without it no budget is created. */
  readonly budgetEmail?: string;
  /** Monthly limit in USD of gross usage (before credits) for the alert. */
  readonly budgetUsd?: number;
  /** EC2 size. t3.micro is Free Plan eligible. */
  readonly instanceType?: string;
}

/**
 * Zero-cost hosting for AgroFarm (AWS Free Plan):
 *  - one t3.micro instance running the Docker image from GitHub Container Registry
 *  - a VPC with a single public subnet and NO NAT gateway (NAT is paid)
 *  - no load balancer, no RDS (the database is Supabase, free plan)
 *  - deploys and rollbacks through SSM Run Command (no SSH port, no keys)
 *  - secrets read at start-up from SSM Parameter Store (standard tier is free)
 *  - a budget alert so any unexpected spending is visible early
 */
export class AgroFarmStack extends cdk.Stack {
  public readonly instance: ec2.Instance;

  constructor(scope: Construct, id: string, props: AgroFarmStackProps = {}) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, 'Vpc', {
      maxAzs: 1,
      natGateways: 0,
      subnetConfiguration: [{ name: 'public', subnetType: ec2.SubnetType.PUBLIC, cidrMask: 24 }],
    });

    const sg = new ec2.SecurityGroup(this, 'WebSg', {
      vpc,
      description: 'AgroFarm web: HTTP only. No SSH: administration goes through SSM.',
      allowAllOutbound: true,
    });
    sg.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.tcp(80), 'HTTP from the internet');

    const role = new iam.Role(this, 'InstanceRole', {
      assumedBy: new iam.ServicePrincipal('ec2.amazonaws.com'),
      managedPolicies: [iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonSSMManagedInstanceCore')],
    });
    role.addToPolicy(new iam.PolicyStatement({
      actions: ['ssm:GetParameter', 'ssm:GetParameters', 'ssm:GetParametersByPath'],
      resources: [cdk.Arn.format({ service: 'ssm', resource: 'parameter', resourceName: 'agrofarm/*' }, this)],
    }));
    role.addToPolicy(new iam.PolicyStatement({
      actions: ['kms:Decrypt'],
      resources: ['*'],
      conditions: { StringEquals: { 'kms:ViaService': `ssm.${this.region}.amazonaws.com` } },
    }));

    const userData = ec2.UserData.forLinux();
    userData.addCommands(
      'set -eux',
      'dnf install -y docker',
      'systemctl enable --now docker',
      'mkdir -p /opt/agrofarm',
      `cat > /opt/agrofarm/deploy.sh <<'SCRIPT'\n${deployScript(this.region)}\nSCRIPT`,
      'chmod 700 /opt/agrofarm/deploy.sh',
    );

    this.instance = new ec2.Instance(this, 'Web', {
      vpc,
      vpcSubnets: { subnetType: ec2.SubnetType.PUBLIC },
      instanceType: new ec2.InstanceType(props.instanceType ?? 't3.micro'),
      machineImage: ec2.MachineImage.latestAmazonLinux2023(),
      securityGroup: sg,
      role,
      userData,
      requireImdsv2: true,
      associatePublicIpAddress: true,
      blockDevices: [{
        deviceName: '/dev/xvda',
        volume: ec2.BlockDeviceVolume.ebs(16, { volumeType: ec2.EbsDeviceVolumeType.GP3, encrypted: true }),
      }],
    });
    cdk.Tags.of(this).add('project', 'agrofarm');

    if (props.budgetEmail) {
      const limit = props.budgetUsd ?? 10;
      new budgets.CfnBudget(this, 'CostAlert', {
        budget: {
          budgetName: 'agrofarm-monthly',
          budgetType: 'COST',
          timeUnit: 'MONTHLY',
          budgetLimit: { amount: limit, unit: 'USD' },
          // Gross usage, before credits: shows how fast the Free Plan credits are used
          costTypes: { includeCredit: false, includeRefund: false },
        },
        notificationsWithSubscribers: [
          notify('ACTUAL', 50, props.budgetEmail),
          notify('ACTUAL', 100, props.budgetEmail),
          notify('FORECASTED', 100, props.budgetEmail),
        ],
      });
    }

    new cdk.CfnOutput(this, 'InstanceId', { value: this.instance.instanceId });
    new cdk.CfnOutput(this, 'SiteURL', { value: `http://${this.instance.instancePublicDnsName}` });
  }
}

function notify(type: 'ACTUAL' | 'FORECASTED', percent: number, email: string) {
  return {
    notification: { notificationType: type, comparisonOperator: 'GREATER_THAN', threshold: percent, thresholdType: 'PERCENTAGE' },
    subscribers: [{ subscriptionType: 'EMAIL', address: email }],
  };
}

/**
 * /opt/agrofarm/deploy.sh IMAGE [GHCR_USER GHCR_TOKEN]
 * Pulls the image, swaps the container and checks /health.php?probe=ready.
 * If the new version is not healthy in 60 s, the previous container is
 * started again (automatic rollback) and the script fails.
 */
function deployScript(region: string): string {
  return `#!/bin/bash
set -euo pipefail
IMAGE="$1"; GH_USER="\${2:-}"; GH_TOKEN="\${3:-}"
REGION="${region}"
ENV_FILE=/opt/agrofarm/app.env

param() { aws ssm get-parameter --region "$REGION" --with-decryption --name "/agrofarm/$1" --query Parameter.Value --output text 2>/dev/null || true; }
umask 077
{
  for k in DB_HOST DB_PORT DB_NAME DB_USER DB_PASS DB_SSLMODE ANTHROPIC_API_KEY ANTHROPIC_MODEL; do
    v="$(param "$k")"; [ -n "$v" ] && [ "$v" != "None" ] && echo "$k=$v"
  done
  echo "APP_ENV=production"
} > "$ENV_FILE"

if [ -n "$GH_TOKEN" ]; then echo "$GH_TOKEN" | docker login ghcr.io -u "$GH_USER" --password-stdin; fi
docker pull "$IMAGE"
if [ -n "$GH_TOKEN" ]; then docker logout ghcr.io || true; fi

PREVIOUS=""
if docker inspect agrofarm >/dev/null 2>&1; then
  PREVIOUS="$(docker inspect --format '{{.Config.Image}}' agrofarm)"
  docker rm -f agrofarm-previous >/dev/null 2>&1 || true
  docker stop agrofarm && docker rename agrofarm agrofarm-previous
fi

docker run -d --name agrofarm --restart unless-stopped -p 80:80 \\
  --env-file "$ENV_FILE" -v agrofarm-uploads:/var/www/html/uploads \\
  --log-driver json-file --log-opt max-size=10m --log-opt max-file=3 "$IMAGE"

for i in $(seq 1 30); do
  if curl -fsS "http://localhost/health.php?probe=ready" >/dev/null; then
    echo "Healthy: $IMAGE"
    docker rm -f agrofarm-previous >/dev/null 2>&1 || true
    docker image prune -af --filter "until=72h" >/dev/null 2>&1 || true
    exit 0
  fi
  sleep 2
done

echo "New version is not healthy, rolling back to: \${PREVIOUS:-none}"
docker logs --tail 50 agrofarm || true
docker rm -f agrofarm
if [ -n "$PREVIOUS" ]; then docker rename agrofarm-previous agrofarm && docker start agrofarm; fi
exit 1`;
}
