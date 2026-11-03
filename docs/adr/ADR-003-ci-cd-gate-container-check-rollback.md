# ADR-003: CI/CD with a gate, a container check and rollback by image tag

## Status

Accepted (Date: 2026-11-03). Same structure as my Astro project (ADR-005, ADR-009, ADR-010, ADR-011 there).

## Context

AgroFarm had no tests and no pipeline: changes went straight to the files on XAMPP. To put it online I need the same safety I built for the Astro blog: nothing reaches users unless it passed every check, and a bad release can be undone in minutes.

## Decision

**CI (`ci.yml`)** runs on every pull request and is *called* by the deploy workflow (`workflow_call`), so the exact commit is tested again before it is published.

1. Secret scan (gitleaks) on the full history.
2. PHP: lint, PHPStan (level 0 for the legacy pages, level 5 for `lib/`, `vet_ai.php`, `health.php`), PHPUnit, `composer audit`.
3. Python: ruff on the analytics scripts.
4. Integration: PostgreSQL service loaded with `database/supabase.sql` (the same file used on Supabase), then `tests/integration/smoke.sh`: health probes, login, CSRF blocks, every page without PHP or SQL errors, a create/delete round-trip.
5. The herd analytics script runs against that database.
6. Playwright E2E on desktop and mobile, with an axe scan (no critical accessibility violations on the public pages).
7. CDK tests, including the zero-cost guardrails (ADR-002).

**Container Check (`container-ci.yml`)** builds the production image on every PR, runs it with PostgreSQL through Docker Compose, waits for the `HEALTHCHECK`, runs the same smoke test (now through Apache, so the `.htaccess` rules are tested too) and checks that the health logs are JSON.

**Deploy (`deploy.yml`)**: gate (CI) → image to GHCR tagged with the commit SHA, `latest` and, for tags, `vX.Y.Z` → (when enabled) CDK deploy → rollout through SSM → live smoke test that also checks the live version is the one just deployed.

**Rollback**: *Run workflow* with an existing `image_tag` skips the build and redeploys that image.

**Dependabot** opens weekly PRs for Composer, npm (E2E and CDK), pip, Docker and GitHub Actions; they go through the same gate.

## Consequences

**Good**
- Two independent controls: branch protection on `main` and the gate inside the deploy pipeline.
- The database script is tested on every PR, so what I paste into Supabase is known to work.
- The pipeline checks results (the live site answers with the right version), not only actions.

**Not so good**
- CI takes a few minutes (browser install, two viewports).
- PHPStan level 0 on the legacy pages only catches the serious errors; the level goes up as pages are refactored.

## Key terms (my notes)

- **Gate**: ponto de controle; o deploy só roda se o CI passou.
- **`workflow_call`**: workflow reutilizável, chamado por outro como uma função.
- **Smoke test**: teste rápido do básico logo depois de subir.
- **Image tag**: o "nome da versão" da imagem Docker; voltar para uma tag antiga é o rollback.
