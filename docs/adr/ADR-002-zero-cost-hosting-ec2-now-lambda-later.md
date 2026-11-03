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
| **EC2 t3.micro running the Docker image, database on Supabase** | **Accepted now**: one small server, covered by the Free Plan, same container as CI |
| Lambda + Bref (PHP on Lambda), database on Supabase | **Planned**: always free, but sessions and uploads must leave the local disk first |
| Lightsail | Rejected: fixed monthly price after any free period |

## Decision

- **Now:** CDK stack with one t3.micro, a public subnet, no NAT gateway, no load balancer, no RDS, no Elastic IP. The image comes from GitHub Container Registry (free) instead of ECR.
- Deploys use **SSM Run Command** (no SSH port, no keys). The script on the server swaps the container, checks `/health.php?probe=ready`, and **rolls back to the previous container** if the new one is not healthy in 60 s.
- Secrets live in **SSM Parameter Store** (standard tier, free), written by the pipeline from GitHub secrets.
- A **budget alert** e-mails me at 50 % and 100 % of the monthly limit, measuring gross usage before credits, so I can see how fast credits go.
- CDK tests fail the build if a NAT gateway, load balancer, RDS instance or Elastic IP is ever added: the cost rules are code, not a promise.
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
