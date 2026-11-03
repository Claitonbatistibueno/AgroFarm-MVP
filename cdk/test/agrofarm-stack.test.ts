import * as cdk from 'aws-cdk-lib';
import { Match, Template } from 'aws-cdk-lib/assertions';
import { AgroFarmStack } from '../lib/agrofarm-stack';

// These tests are the cost guardrails: anything that would put a monthly bill
// on the account (NAT gateway, load balancer, RDS, a bigger instance) fails CI.

let template: Template;

beforeAll(() => {
  const app = new cdk.App();
  const stack = new AgroFarmStack(app, 'TestAgroFarm', {
    env: { account: '123456789012', region: 'eu-west-1' },
    budgetEmail: 'alerts@example.com',
    budgetUsd: 10,
  });
  template = Template.fromStack(stack);
});

test('runs on a single Free Plan sized instance (t3.micro)', () => {
  template.resourceCountIs('AWS::EC2::Instance', 1);
  template.hasResourceProperties('AWS::EC2::Instance', { InstanceType: 't3.micro' });
});

test('no paid networking or managed services: NAT, load balancer, RDS, Elastic IP', () => {
  template.resourceCountIs('AWS::EC2::NatGateway', 0);
  template.resourceCountIs('AWS::ElasticLoadBalancingV2::LoadBalancer', 0);
  template.resourceCountIs('AWS::RDS::DBInstance', 0);
  template.resourceCountIs('AWS::EC2::EIP', 0);
});

test('disk stays inside the Free Plan and is encrypted', () => {
  template.hasResourceProperties('AWS::EC2::Instance', {
    BlockDeviceMappings: [
      Match.objectLike({ Ebs: Match.objectLike({ VolumeSize: 16, VolumeType: 'gp3', Encrypted: true }) }),
    ],
  });
});

test('only HTTP is open to the internet (no SSH)', () => {
  const groups = template.findResources('AWS::EC2::SecurityGroup');
  const ingress = Object.values(groups).flatMap(
    (g) => (g.Properties.SecurityGroupIngress ?? []) as Array<Record<string, unknown>>,
  );
  expect(ingress).toHaveLength(1);
  expect(ingress[0]).toMatchObject({ FromPort: 80, ToPort: 80, IpProtocol: 'tcp' });
});

test('instance metadata requires IMDSv2', () => {
  template.hasResourceProperties('AWS::EC2::LaunchTemplate', {
    LaunchTemplateData: Match.objectLike({ MetadataOptions: Match.objectLike({ HttpTokens: 'required' }) }),
  });
});

test('the instance can only read its own parameters (/agrofarm/*)', () => {
  const policies = template.findResources('AWS::IAM::Policy');
  const statements = Object.values(policies).flatMap(
    (p) => p.Properties.PolicyDocument.Statement as Array<Record<string, unknown>>,
  );
  const ssm = statements.find((s) => JSON.stringify(s.Action).includes('ssm:GetParameter'));
  expect(ssm).toBeDefined();
  expect(JSON.stringify(ssm!.Resource)).toContain('parameter/agrofarm/*');
});

test('administration goes through SSM (managed policy attached)', () => {
  template.hasResourceProperties('AWS::IAM::Role', {
    ManagedPolicyArns: Match.arrayWith([
      Match.objectLike({ 'Fn::Join': Match.arrayWith([Match.arrayWith([Match.stringLikeRegexp('AmazonSSMManagedInstanceCore')])]) }),
    ]),
  });
});

test('a monthly budget alerts on gross usage', () => {
  template.hasResourceProperties('AWS::Budgets::Budget', {
    Budget: Match.objectLike({
      BudgetLimit: { Amount: 10, Unit: 'USD' },
      CostTypes: Match.objectLike({ IncludeCredit: false }),
    }),
  });
});

test('the deploy script health-checks and rolls back automatically', () => {
  const instance = Object.values(template.findResources('AWS::EC2::Instance'))[0];
  const userData = JSON.stringify(instance.Properties.UserData);
  expect(userData).toContain('health.php?probe=ready');
  expect(userData).toContain('rolling back');
});

test('outputs the site URL for the smoke test', () => {
  template.hasOutput('SiteURL', {});
  template.hasOutput('InstanceId', {});
});
