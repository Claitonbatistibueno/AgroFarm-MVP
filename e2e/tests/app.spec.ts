import { test, expect, type Page } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

const USER = process.env.E2E_USER ?? 'demo';
const PASS = process.env.E2E_PASS ?? 'AgroFarm2026!';

async function login(page: Page) {
  await page.goto('/login.php');
  await page.locator('input[name="username"]').fill(USER);
  await page.locator('input[name="password"]').fill(PASS);
  await page.locator('button[type="submit"]').click();
  await expect(page).toHaveURL(/dashboard\.php/);
}

// PHP errors must never reach the page
async function expectNoPhpErrors(page: Page) {
  const html = await page.content();
  expect(html).not.toMatch(/Fatal error|Parse error|<b>(Warning|Notice|Deprecated)<\/b>|SQLSTATE/);
}

test('landing page loads and links to the login', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Farm/i);
  await page.locator('a[href="login.php"]').first().click();
  await expect(page).toHaveURL(/login\.php/);
});

test('wrong password shows an error and stays on the login page', async ({ page }) => {
  await page.goto('/login.php');
  await page.locator('input[name="username"]').fill(USER);
  await page.locator('input[name="password"]').fill('wrong-password');
  await page.locator('button[type="submit"]').click();
  await expect(page.getByText('Invalid username or password')).toBeVisible();
});

test('a farmer can log in and see the dashboard KPIs', async ({ page }) => {
  await login(page);
  await expect(page.getByText(/Active Animals|Animals/i).first()).toBeVisible();
  await expectNoPhpErrors(page);
});

test('the herd list and its search work', async ({ page }) => {
  await login(page);
  await page.goto('/animal.php?search=angus');
  await expectNoPhpErrors(page);
  await expect(page.locator('table tbody tr').first()).toBeVisible();
});

test('every report opens without errors', async ({ page }) => {
  await login(page);
  for (const path of ['reports.php', 'reports_animals.php', 'reports_weight.php', 'reports_health.php',
                      'reports_feeding.php', 'reports_financial.php', 'financial_dashboard.php']) {
    const res = await page.goto('/' + path);
    expect(res?.status(), path).toBe(200);
    await expectNoPhpErrors(page);
  }
});

test('logout ends the session', async ({ page }) => {
  await login(page);
  await page.goto('/dashboard.php?logout=1');
  await page.goto('/dashboard.php');
  await expect(page).toHaveURL(/login\.php/);
});

// Accessibility gate: no critical axe violations on the public pages.
for (const path of ['/', '/login.php']) {
  test(`accessibility: no critical violations on ${path}`, async ({ page }) => {
    await page.goto(path);
    const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
    const critical = results.violations.filter((v) => v.impact === 'critical');
    expect(critical.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
  });
}
