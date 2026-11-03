# 🚜 Farm-Project

<details>
  <summary><b>💡 Why was this project built? (The Market Problem)</b></summary>
  <br>
  The Irish agricultural sector has over 135,000 active farms, but many small and medium beef producers struggle with tight margins due to volatile feed and energy costs. Most existing management software is built for massive, industrial dairy operations—leaving family farms to manage their herds based on rough national averages rather than individual data.
  <br><br>
  <b>Farm-Project</b> was built to fix this "black box." It brings individual financial traceability, fattening optimization, and predictive Veterinary AI to the everyday farmer, designed to work even in offline rural environments.
  <br><br>
  👉 <a href="./why/problem_statement.md">Click here to read the full Market Gap Analysis & Problem Statement</a>
</details>

<br>

Welcome to **Farm-Project**, this is my project submission for the Immersive Software Engineering course at the University of Limerick.

## 🌟 Main Features

* **Authentication & Access:** Secure login (`login.php`, hashed passwords, CSRF, brute-force lock) from the public landing page (`index.html`).
* **Central Dashboard:** System overview (`dashboard.php`).
* **Financial Hub:** Financial management and overview (`financial_dashboard.php`).
* **Comprehensive Reports (`reports.php`):**
    * **Animal Reports:** Detailed herd reports and history (`reports_animals.php`).
    * **Feeding Reports:** Animal nutrition history and management (`reports_feeding.php`).
    * **Health Reports:** Health data tracking (`reports_health.php`).
    * **Financial Reports:** Detailed financial tracking and summaries (`reports_financial.php`).
* **Artificial Intelligence (AI) Integration:**
    * AI Clinical Assistant with photo analysis (`ai_vision.php` → `vet_ai.php`, Claude API).
    * Herd prediction & anomaly detection (`tools/previsao_ia.py`).

## 🛠️ Technologies Used

* **Backend:** PHP 8.2 (PDO, prepared statements everywhere)
* **Database:** PostgreSQL on **Supabase** (free plan)
* **Frontend:** HTML, Bootstrap, Chart.js, jsPDF
* **AI Clinical Assistant:** Claude API (`vet_ai.php`) — reads the animal's record, vitals, symptoms and an optional photo, adds PubMed evidence, returns a structured differential
* **Herd analytics (offline):** Python + scikit-learn (`tools/previsao_ia.py`)
* **Delivery:** Docker, GitHub Actions, GitHub Container Registry, AWS (EC2 + SSM via CDK)

## 🔐 Security

* Passwords stored with `password_hash` (bcrypt); plain-text legacy passwords are upgraded on the next login.
* Login brute-force lock (5 failures / 15 min per IP).
* CSRF token on every form, delete link and `fetch()` call (injected automatically by `config.php`).
* Prepared statements and HTML escaping on every page.
* Uploads: extension + MIME whitelist, random names, no PHP execution in `uploads/`.
* Secrets only in `.env` / GitHub secrets / AWS SSM Parameter Store — never in the code.
* Supabase REST API locked: RLS on every table, no grants for the `anon` / `authenticated` roles.
* CI scans every commit for leaked secrets (gitleaks) and vulnerable dependencies.

## 🗄️ Database (Supabase)

1. Create a free project at [supabase.com](https://supabase.com) (region **West EU (Ireland)**).
2. **SQL Editor → New query**, paste [`database/supabase.sql`](database/supabase.sql) and **Run**. It creates the tables, the demo data and the security rules.
   If the editor stops part-way on the big file, run the same script split into small files instead: [`database/supabase-parts/`](database/supabase-parts/) `part1` → `part8`, one query each, in order (part 1 cleans any half-created tables, so it is safe to start again).
3. **Connect → Session pooler** gives the values for `.env`: host, port `5432`, database `postgres`, user `postgres.<project-ref>`, your database password, `DB_SSLMODE=require`.

Demo login: **`demo` / `AgroFarm2026!`** — change it in *Users* after the first login.

## 🚀 Run locally

**With Docker (recommended):** `docker compose up --build` → http://localhost:8080 (a local PostgreSQL is loaded with the same script).

**With XAMPP:** enable `extension=pdo_pgsql` in `php.ini`, copy `.env.example` to `.env` with your Supabase values, open `http://localhost/agrofarm-mvp/`.

## 🔄 CI/CD pipeline

| Workflow | When | What it does |
|---|---|---|
| `ci.yml` — Continuous Integration | every PR, and called by Deploy | gitleaks secret scan → PHP lint → PHPStan → PHPUnit → `composer audit` → Python lint → loads `supabase.sql` into PostgreSQL → integration smoke test → herd analytics run → Playwright E2E (desktop + mobile) with axe → CDK tests (zero-cost guardrails) |
| `container-ci.yml` — Container Check | every PR | builds the production image, runs it with PostgreSQL, waits for `HEALTHCHECK`, smoke test incl. `.htaccess` rules, checks JSON logs |
| `deploy.yml` — Deploy | push to `main`, tags `v*`, manual | CI gate → image to GHCR (`sha`, `latest`, `vX.Y.Z`) → *(if enabled)* CDK deploy → rollout via SSM with automatic rollback → live smoke test |
| `deploy.yml` → *Run workflow* with `image_tag` | manual | **rollback**: redeploys an existing image, no rebuild |
| `keep-supabase-awake.yml` | every 3 days | one query so the free Supabase project is not paused |

Branching: GitHub Flow (`feat/…`, `fix/…`, `ci/…` → PR → `main`), Conventional Commits.

## ☁️ AWS at zero cost

The AWS part is **off** until you enable it, so nothing is created or billed by accident.

* One **t3.micro** (Free Plan eligible), public subnet, **no** NAT gateway, load balancer, RDS or Elastic IP — CI tests fail if any of these appear.
* The database stays on Supabase (free), the image on GHCR (free).
* A **budget alert** e-mails you at 50 % / 100 % of `BUDGET_USD` (gross usage before credits).
* Admin through **SSM** (no SSH port, no keys). Secrets in **SSM Parameter Store** (standard tier, free).

To enable: add the repository **secrets** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS`, `ANTHROPIC_API_KEY`, `BUDGET_EMAIL`, then the repository **variable** `AWS_DEPLOY=true`. The next push to `main` creates the server and deploys.

> Plan after the 6-month Free Plan: move the PHP app to AWS Lambda (always-free tier) with Bref — see [ADR-002](docs/adr/ADR-002-zero-cost-hosting-ec2-now-lambda-later.md).

## 🧠 Optional: herd analytics script

```bash
pip install -r tools/requirements.txt
python tools/previsao_ia.py          # writes tools/ai_analysis.json (ADG, finish date, risk score)
```
It reads the same `.env` as the PHP app.

---
*Developed by Claitonbatistibueno*