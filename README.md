# AgroFarm

Herd management for small and medium beef farms: animals, weighing, feeding, health records, costs and sales, with reports per animal and an AI assistant that helps read clinical signs.

Most farm software is built for large dairy operations. Family beef farms end up managing by averages, so a calf that is not gaining weight, or one that costs more than it will sell for, goes unnoticed. AgroFarm tracks each animal individually. More background in [why/problem_statement.md](why/problem_statement.md).

Live version: http://ec2-63-184-32-11.eu-central-1.compute.amazonaws.com

## What it does

- Animals and lots, with origin, breed and history
- Weighing (manual or CSV import) with daily gain per animal
- Feeding per animal or per lot
- Health records linked to a medicine catalogue with stock and cost
- Sales, expenses and profit per animal
- Reports with charts and PDF/Excel export
- AI clinical assistant: temperature, symptoms and an optional photo go to the Claude API together with the animal's records, and it returns possible causes and safe next steps (`vet_ai.php`)
- Herd analytics script in Python that flags weight loss and estimates finishing dates (`tools/previsao_ia.py`)

## Stack

PHP 8.2, PostgreSQL on Supabase, Bootstrap and Chart.js on the front end, Python for the analytics script. Docker for packaging, GitHub Actions for CI/CD, AWS (EC2 managed with CDK) for hosting.

## Running it locally

With Docker:

```bash
docker compose up --build
```

Then open http://localhost:8080. Compose starts a local PostgreSQL and loads `database/supabase.sql`, which creates a demo user called `demo` (the password is in `docker-compose.yml`).

Without Docker you need PHP 8.2 with `pdo_pgsql` and a PostgreSQL database. Copy `.env.example` to `.env` and fill in the connection details.

## Database

Production runs on Supabase (free plan). To set up a new project, open the SQL Editor and run `database/supabase.sql`. If the editor stops halfway on the big file, run the files in `database/supabase-parts/` in order instead.

Connect through the **Session pooler** (it works over IPv4) with `DB_SSLMODE=require`. The script turns on row level security for every table, so the Supabase REST API cannot read the data; the app connects to Postgres directly.

After the first login, create your own user and change or delete `demo`.

## CI/CD

- `ci.yml` runs on every pull request: secret scan, PHP lint, PHPStan, PHPUnit, an integration test against a real PostgreSQL, browser tests with Playwright (desktop and mobile, with an accessibility check) and tests for the AWS infrastructure.
- `container-ci.yml` builds the Docker image and checks it starts and serves every page.
- `deploy.yml` runs on every merge to `main`: CI again, then the image is pushed to GitHub Container Registry and deployed to EC2. If the new version does not pass its health check, the server goes back to the previous one. Running the workflow by hand with an older `image_tag` is a manual rollback.
- `keep-supabase-awake.yml` runs a small query every three days, because Supabase pauses free projects after a week without use.

Dependabot opens weekly pull requests for dependencies.

## Hosting cost

The AWS account is on the Free Plan, so nothing is charged; usage comes out of the plan credits. The setup is one `t4g.micro` in Frankfurt (same region as the database), with no load balancer, NAT gateway or managed database. That is about US$11 a month in credits. The infrastructure tests fail if anything more expensive is added, and a budget alert emails when spending passes US$7.50 or US$15.

To deploy to your own account, add these repository secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS`, `BUDGET_EMAIL`, and optionally `ANTHROPIC_API_KEY`. Then create the variable `AWS_DEPLOY=true`.

## Decisions

The main technical choices and their trade-offs are written up in [docs/adr](docs/adr):

- [Why PostgreSQL on Supabase](docs/adr/ADR-001-postgresql-on-supabase.md)
- [Zero-cost hosting: EC2 now, Lambda later](docs/adr/ADR-002-zero-cost-hosting-ec2-now-lambda-later.md)
- [How the pipeline is built](docs/adr/ADR-003-ci-cd-gate-container-check-rollback.md)

---

Claiton Batisti Bueno, Immersive Software Engineering, University of Limerick
