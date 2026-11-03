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

* **Backend:** PHP 8.1+ (mysqli + PDO, prepared statements everywhere)
* **Database:** MariaDB / MySQL
* **Frontend:** HTML, Bootstrap, Chart.js, jsPDF
* **AI Clinical Assistant:** Claude API (`vet_ai.php`) — reads the animal's record, vitals, symptoms and an optional photo, adds PubMed evidence, returns a structured differential
* **Herd analytics (offline):** Python + scikit-learn (`tools/previsao_ia.py`)

## 🔐 Security (MVP hardening)

* Passwords stored with `password_hash` (bcrypt). Old plain-text passwords are upgraded automatically on the next successful login.
* Login brute-force lock (5 failures / 15 min per IP).
* CSRF token on every form, delete link and `fetch()` call (injected automatically by `config.php`).
* All SQL uses prepared statements; all output is HTML-escaped.
* Uploads: extension + MIME whitelist, random file names, PHP execution disabled in `uploads/`.
* Secrets live only in `.env` (never committed). `.htaccess` blocks `.env`, SQL dumps, `tools/`, `database/` and `.git`.

## 🚀 Run locally (XAMPP)

1. Copy the project to `C:\xampp\htdocs\farmproject`.
2. In phpMyAdmin create a database `farmproject` and import **`database/farmproject.sql`** (demo data, no personal data).
   *Already have the old database?* Import only **`database/migrations_001_mvp.sql`** instead.
3. Copy `.env.example` to `.env` and fill in the values (for XAMPP the defaults `root` / empty password work).
4. Add your Claude API key to `.env` → `ANTHROPIC_API_KEY=sk-ant-...` (create one at https://console.anthropic.com).
5. Open `http://localhost/farmproject/` → **Log in**.
   Demo login: **`demo` / `AgroFarm2026!`** — change it in *Users* after the first login.

> Login is now **username + password** (the 6-digit login code is no longer used to sign in).

## 🌍 Deploy online (any PHP + MySQL host)

Works on shared hosting (e.g. cPanel hosts) or a small VPS — no Python needed on the server.

1. Requirements: PHP 8.1+ with `mysqli`, `pdo_mysql`, `curl`, `fileinfo`; MariaDB/MySQL; Apache with `AllowOverride All` (or replicate `.htaccess` rules in nginx).
2. Upload the files (FTP or `git clone`). Do **not** upload `.env` from your PC — create a new one on the server from `.env.example`.
3. Create the database + user in the host panel and import `database/farmproject.sql`.
4. In `.env` set `APP_ENV=production`, the DB credentials from the host, and `ANTHROPIC_API_KEY`.
5. Enable HTTPS (Let's Encrypt in the host panel). Session cookies become `Secure` automatically.
6. Log in as `demo`, create your real user, then delete or change the demo user.

## 🧠 Optional: herd analytics script

```bash
pip install -r tools/requirements.txt
python tools/previsao_ia.py          # writes tools/ai_analysis.json (ADG, finish date, risk score)
```
It reads the same `.env` as the PHP app.

---
*Developed by Claitonbatistibueno*