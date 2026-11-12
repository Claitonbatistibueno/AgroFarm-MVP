# ADR-002: Zero-cost hosting — EC2 on the Free Plan now, Lambda later

## Status

Accepted (Date: 2026-11-03).

## Context

The goal is to have AgroFarm online without paying anything. My AWS account is on the **Free Plan**: up to $200 in credits for 6 months, and the account cannot be charged while on that plan. After that, only the "always free" services stay free (for example AWS Lambda).

My Astro project runs its container on ECS Fargate behind a load balancer. That pattern is good, but the load balancer alone costs more per month than the whole credit budget would allow for a long time.

## Options considered

| Option | Verdict |
|---|---|
| ECS Fargate + ALB + RDS (same as Astro) | Rejected: ~$40–60/month; burns the credits in a few months |
| **EC2 t4g.micro (ARM) running the Docker image, database on Supabase** | **Accepted now**: the cheapest instance type a Free Plan account can launch, same container as CI |
| Lambda + Bref (PHP on Lambda), database on Supabase | **Planned**: always free, but sessions and uploads must leave the local disk first |
| Lightsail | Rejected: fixed monthly price after any free period |

## Decision

- **Now:** CDK stack with one **t4g.micro** (ARM) in **eu-central-1**, the same region as the Supabase project (a page runs several queries; another region would add ~25 ms to each). 8 GB disk, a public subnet, no NAT gateway, no load balancer, no RDS. One Elastic IP keeps the site address fixed (see update below). The image comes from GitHub Container Registry (free) instead of ECR and is built for amd64 and arm64.
- Free Plan accounts can only launch `t3.micro`, `t3.small`, `t4g.micro`, `t4g.small`, `c7i-flex.large`, `m7i-flex.large`; the stack refuses anything else. Estimated gross usage ≈ US$ 11/month (t4g.micro ≈ 7, public IPv4 ≈ 3.65, 8 GB gp3 ≈ 0.8), paid from the credits.
- Deploys use **SSM Run Command** (no SSH port, no keys). The script on the server swaps the container, checks `/health.php?probe=ready`, and **rolls back to the previous container** if the new one is not healthy in 60 s.
- Secrets live in **SSM Parameter Store** (standard tier, free), written by the pipeline from GitHub secrets.
- A **budget alert** e-mails me at 50 % and 100 % of the monthly limit, measuring gross usage before credits, so I can see how fast credits go.
- CDK tests fail the build if a NAT gateway, load balancer or RDS instance is ever added: the cost rules are code, not a promise.
- The AWS deploy is **off** until the repository variable `AWS_DEPLOY` is `true`.
- **Before month 6:** move to Lambda with Bref (sessions in PostgreSQL, uploads in Supabase Storage), then delete the EC2 stack with `cdk destroy`.

## Consequences

**Good**
- $0 while on the Free Plan, with an alert if anything unexpected appears.
- Same image in CI, in the container check and in production.
- Rollback in two ways: automatic (health check fails) and manual (run the workflow with an older image tag).

**Not so good**
- One server: a deploy has a few seconds of downtime while the container is swapped.
- HTTP only for now (no domain, no certificate). HTTPS comes with a domain or with the Lambda function URL.
- Public IPv4 addresses are billed by AWS (paid from the credits); one more reason for the Lambda plan.

## Key terms (my notes)

- **SSM Run Command**: executa comandos no servidor pela API da AWS, sem abrir porta SSH.
- **Parameter Store**: cofre de configurações/segredos da AWS; o nível standard é gratuito.
- **Guardrail**: uma proteção automática; aqui, testes que impedem recursos pagos de entrar na infraestrutura.
- **Bref**: projeto open source que roda PHP dentro do AWS Lambda.

## Update (2026-11-12): fixed address

A deploy replaced the server because AWS had published a new Amazon Linux image, and the site got a new public address. Two changes stop that:

- **Elastic IP** attached to the instance. Attached to a running instance it costs the same as the public IPv4 address it replaces (≈ US$ 3.65/month, from the credits), and it moves to the new instance if the server is ever replaced.
- **AMI pinned** by the deploy workflow: it passes the AMI of the running server to CDK, so a new Amazon Linux release no longer replaces the server. Running the Deploy workflow by hand with `upgrade_os` moves to the latest image on purpose (the address stays the same).

