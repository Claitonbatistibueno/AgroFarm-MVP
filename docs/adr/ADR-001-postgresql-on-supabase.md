# ADR-001: Move the database from MariaDB to PostgreSQL on Supabase

## Status

Accepted (Date: 2026-11-03).

## Context

AgroFarm was built on XAMPP with MariaDB. To put it online I need a database that is reachable from the internet, backed up, and free. Running MariaDB myself on the server means doing backups and updates by hand, and a managed MySQL on AWS (RDS) is only free for a limited time.

The pages use the `mysqli` API in 286 places across 18 files, and a few queries use MySQL-only functions (`DATEDIFF`, `MONTH()`, `INTERVAL n MINUTE`, `CURDATE()`).

## Options considered

| Option | Verdict |
|---|---|
| MariaDB in a container on the same server | Rejected: backups and data safety on me; data lost if the server is replaced |
| Amazon RDS for MySQL | Rejected: not always free, and it costs as soon as the free period ends |
| **PostgreSQL on Supabase (free plan)** | **Accepted**: managed, daily backups, SQL editor, 500 MB is plenty for the demo herd |

**How to change the code**

| Option | Verdict |
|---|---|
| Rewrite every page to PDO by hand | Rejected for now: 286 call sites, high risk of breaking a page |
| **A small adapter (`lib/db.php`) with the same `mysqli`-style methods, running on PDO** | **Accepted**: the pages keep working; only the SQL dialect had to change |

## Decision

- Schema and data converted with pgloader; the result is `database/supabase.sql`, loaded once in the Supabase SQL editor.
- `lib/db.php` (`FarmDb`, `FarmStmt`, `FarmResult`) implements the part of `mysqli` the pages use (`prepare`, `bind_param`, `get_result`, `fetch_assoc`, `num_rows`, `insert_id`, `foreach`) on top of PDO.
- MySQL-only SQL replaced by standard SQL: `date_trunc('month', …)`, `CURRENT_DATE - birth_date`, `make_interval(mins => …)`, `ILIKE` for case-insensitive search.
- Text comparisons fixed for case sensitivity (`'active'`, `'sold'`): MySQL ignored case, PostgreSQL does not.
- Supabase also exposes tables through its REST API. AgroFarm does not use it, so RLS is enabled on every table with no policies and the `anon` / `authenticated` roles have no grants.
- The app connects through the **Session pooler** (IPv4) with `sslmode=require`.

## Consequences

**Good**
- Managed database with backups, no server to maintain, $0.
- Every page was compared against the MariaDB version (same numbers) and is covered by the integration and E2E tests on a real PostgreSQL in CI.

**Not so good**
- Free projects pause after 7 days without use: a scheduled workflow runs one query every 3 days.
- The adapter is a bridge, not the final shape. New code should use `$pdo` directly.
- Local development now needs PostgreSQL (Docker Compose) or the Supabase connection, not XAMPP's MySQL.

## Key terms (my notes)

- **Adapter**: uma classe que "traduz" uma interface para outra, para o código antigo continuar funcionando sem reescrever tudo.
- **RLS (Row Level Security)**: regra no próprio banco que decide quais linhas cada papel pode ver; sem policy, ninguém de fora vê nada.
- **Connection pooler**: um intermediário que reaproveita conexões com o banco; no Supabase ele também permite conectar por IPv4.
