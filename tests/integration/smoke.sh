#!/usr/bin/env bash
# =========================================================
# Integration smoke test: runs the real app against a real PostgreSQL.
#   BASE_URL   app URL               (default http://127.0.0.1:8080)
#   USERNAME / PASSWORD  demo login  (default demo / AgroFarm2026!)
# Fails (exit 1) on any HTTP error, PHP warning/notice/deprecation or SQL error.
# =========================================================
set -uo pipefail
BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
USERNAME="${USERNAME:-demo}"
PASSWORD="${PASSWORD:-AgroFarm2026!}"
JAR="$(mktemp)"; trap 'rm -f "$JAR"' EXIT
FAILS=0
ERR_PATTERN='Fatal error|Parse error|<b>(Warning|Notice|Deprecated)</b>|Uncaught|SQLSTATE|Something went wrong'

pass() { echo "PASS  $*"; }
fail() { echo "FAIL  $*"; FAILS=$((FAILS + 1)); }

csrf_from() { grep -o 'name="csrf-token" content="[^"]*"' | head -1 | sed 's/.*content="//;s/"//'; }

# --- 1. Health probes
for probe in live ready; do
  body=$(curl -fsS "$BASE_URL/health.php?probe=$probe") && echo "$body" | grep -q '"status":"ok"' \
    && pass "health $probe" || fail "health $probe: ${body:-no answer}"
done

# --- 2. Public pages
curl -fsS "$BASE_URL/" | grep -qi "<title>" && pass "landing page" || fail "landing page"
code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/dashboard.php")
[ "$code" = "302" ] && pass "dashboard redirects anonymous users" || fail "dashboard without login returned $code"

# --- 3. Login (bad password, then good password)
TOKEN=$(curl -s -c "$JAR" -b "$JAR" "$BASE_URL/login.php" | grep -o 'name="csrf_token" value="[^"]*"' | head -1 | sed 's/.*value="//;s/"//')
curl -s -c "$JAR" -b "$JAR" --data-urlencode "username=$USERNAME" --data-urlencode "password=wrong-password" \
  -d "csrf_token=$TOKEN" "$BASE_URL/login.php" | grep -q "Invalid username or password" \
  && pass "wrong password rejected" || fail "wrong password not rejected"
code=$(curl -s -o /dev/null -w '%{http_code}' -c "$JAR" -b "$JAR" -d "username=$USERNAME&password=x" "$BASE_URL/login.php")
[ "$code" = "403" ] && pass "login without CSRF token blocked" || fail "login without CSRF token returned $code"
loc=$(curl -s -o /dev/null -w '%{redirect_url}' -c "$JAR" -b "$JAR" --data-urlencode "username=$USERNAME" \
  --data-urlencode "password=$PASSWORD" -d "csrf_token=$TOKEN" "$BASE_URL/login.php")
[[ "$loc" == *dashboard.php ]] && pass "login" || { fail "login (redirect: $loc)"; echo "$FAILS failure(s)"; exit 1; }

# --- 4. Every page renders without PHP or SQL errors
PAGES="dashboard.php animal.php breeds.php clients.php feeding.php weighing.php weighing.php?show_all=1
medical_catalog.php suppliers_list.php users.php settings.php financial_dashboard.php reports.php
reports_animals.php reports_feeding.php reports_health.php reports_weight.php reports_financial.php ai_vision.php"
for page in $PAGES; do
  out=$(curl -s -b "$JAR" -w '\n%{http_code}' "$BASE_URL/$page"); code=$(tail -1 <<<"$out")
  errs=$(grep -cE "$ERR_PATTERN" <<<"$out")
  if [ "$code" = "200" ] && [ "$errs" = "0" ]; then pass "$page"
  else fail "$page (HTTP $code): $(grep -oE "($ERR_PATTERN).{0,160}" <<<"$out" | sed 's/<[^>]*>//g' | head -1)"; fi
done

# --- 5. A write round-trip (create + delete a client) with CSRF
TOKEN=$(curl -s -b "$JAR" "$BASE_URL/clients.php" | csrf_from)
code=$(curl -s -o /dev/null -w '%{http_code}' -b "$JAR" -d "action=save_client&name=x" "$BASE_URL/clients.php")
[ "$code" = "403" ] && pass "POST without CSRF token blocked" || fail "POST without CSRF token returned $code"
NAME="CI Client $RANDOM"
curl -s -b "$JAR" -L -o /dev/null -F csrf_token="$TOKEN" -F action=save_client -F client_id= -F company_id=5 \
  -F "name=$NAME" -F phone=1 -F email=ci@example.com -F address=CI "$BASE_URL/clients.php"
page=$(curl -s -b "$JAR" "$BASE_URL/clients.php")
grep -q "$NAME" <<<"$page" && pass "client created" || fail "client not created"
ID=$(grep -oE "edit\(\{[^)]*$NAME" <<<"$(sed 's/&quot;/"/g' <<<"$page")" | grep -oE '"client_id":[0-9]+' | head -1 | cut -d: -f2)
if [ -n "$ID" ]; then
  curl -s -b "$JAR" -o /dev/null "$BASE_URL/clients.php?delete=$ID&csrf_token=$TOKEN"
  curl -s -b "$JAR" "$BASE_URL/clients.php" | grep -q "$NAME" && fail "client not deleted" || pass "client deleted"
else fail "could not find the new client id"; fi

# --- 6. Files that must never be served
for path in .env database/supabase.sql lib/helpers.php vet_ai.php tools/previsao_ia.py; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/$path")
  case "${CHECK_HTACCESS:-0}:$code" in
    1:403|1:404) pass "blocked /$path ($code)";;
    1:*) fail "/$path is reachable ($code)";;
    0:*) : ;;  # php -S ignores .htaccess; checked in the container job
  esac
done

echo "-----"
[ "$FAILS" -eq 0 ] && echo "All smoke tests passed" || { echo "$FAILS failure(s)"; exit 1; }
