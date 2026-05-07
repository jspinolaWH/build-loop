---
description: Runs Playwright headless integration tests for a single requirement. Logs in, navigates to the requirement's route, intercepts all GraphQL responses, and fails if any contain errors. Writes a test report. Called by the build-loop orchestrator after bl-seed.
argument-hint: <requirement-id>
allowed-tools: [Read, Write, Bash, Glob, Grep]
---

# BL FE Test

You are an autonomous frontend integration test agent. You write and run a Playwright test for one requirement. The test logs in as the configured test user, navigates to the requirement's route, intercepts every GraphQL call to `/graph-api/`, and asserts that none contain `errors` in the response body. This is the GraphQL equivalent of "no 4xx/5xx" — because GraphQL always returns HTTP 200, the error signal lives in the response JSON. You do not ask questions.

## Setup

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

Read:
- `$PROJECT_ROOT/build-loop/config.json` — test credentials and port config
- `$PROJECT_ROOT/build-loop/prd.json` — requirement
- `$PROJECT_ROOT/build-loop/plans/$ARGUMENTS.md` — manual test path
- `$PROJECT_ROOT/build-loop/req-graph.json` — app_location for this requirement
- `$PROJECT_ROOT/build-loop/context/fe-architecture.md`
- `$PROJECT_ROOT/build-loop/context/be-architecture.md`

**If `build-loop/config.json` does not exist:**
Output:
```
FE_TEST_RESULT: ERROR config_missing — copy build-loop/config.json.example to build-loop/config.json and fill in credentials
```
Stop.

Parse config.json:
- `TEST_USERNAME` = `test_user.username`
- `TEST_PASSWORD` = `test_user.password`
- `FE_PORT` = `fe_port` (default 3000)
- `BE_PORT` = `be_port` (default 8000)
- `GQL_PATH` = `be_graphql_path` (default `/graph-api/`)

REQ_ID = `$ARGUMENTS`
REQ_ID_LOWER = lowercase + hyphens version

Read req-graph.json for this requirement's `app_location`.
If `backend_only: true` → output `FE_TEST_RESULT: SKIPPED backend_only` and stop.

ROUTE = `app_location.route`
If ROUTE is null or "NEW — see plan" → output `FE_TEST_RESULT: SKIPPED no_route` and stop.

---

## Step 1 — Verify servers are reachable

### Check FE

```bash
FE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:$FE_PORT/ 2>/dev/null)
echo "FE status: $FE_STATUS"
```

### Check BE (GraphQL endpoint)

```bash
BE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 -X POST http://localhost:$BE_PORT$GQL_PATH \
  -H 'Content-Type: application/json' \
  -d '{"query":"{ __typename }"}' 2>/dev/null)
echo "BE status: $BE_STATUS"
```

### If servers not running — attempt to start them

**FE not reachable:**
```bash
mkdir -p $PROJECT_ROOT/build-loop/logs
FE_ROOT=$(cat $PROJECT_ROOT/build-loop/context/fe-architecture.md | grep '^[*][*]Root:' | sed 's/\*\*Root:\*\* //' | tr -d ' ')
FE_ROOT="${FE_ROOT:-$PROJECT_ROOT/wastehero_frontend-development}"

cd "$FE_ROOT" && yarn dev > "$PROJECT_ROOT/build-loop/logs/fe-server.log" 2>&1 &
FE_PID=$!
echo $FE_PID > "$PROJECT_ROOT/build-loop/logs/fe-server.pid"

# Wait up to 60 s for FE to be ready
for i in $(seq 1 30); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://localhost:$FE_PORT/ 2>/dev/null)
  [ "$STATUS" = "200" ] || [ "$STATUS" = "304" ] && { echo "FE ready"; break; }
  sleep 2
done
```

**BE not reachable:**
```bash
BE_ROOT=$(cat $PROJECT_ROOT/build-loop/context/be-architecture.md | grep '^[*][*]Root:' | sed 's/\*\*Root:\*\* //' | tr -d ' ')
BE_ROOT="${BE_ROOT:-$PROJECT_ROOT/wastehero_backend_v1-master}"

cd "$BE_ROOT" && python manage.py runserver $BE_PORT > "$PROJECT_ROOT/build-loop/logs/be-server.log" 2>&1 &
BE_PID=$!
echo $BE_PID > "$PROJECT_ROOT/build-loop/logs/be-server.pid"

# Wait up to 90 s for BE to respond
for i in $(seq 1 45); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 -X POST http://localhost:$BE_PORT$GQL_PATH \
    -H 'Content-Type: application/json' -d '{"query":"{ __typename }"}' 2>/dev/null)
  [ "$STATUS" = "200" ] && { echo "BE ready"; break; }
  sleep 2
done
```

**If either server is still not reachable after waiting:**
Write a note in the report and output:
```
FE_TEST_RESULT: ERROR servers_not_ready — check build-loop/logs/fe-server.log and be-server.log
```
Stop.

---

## Step 2 — Ensure Playwright is installed

```bash
FE_ROOT=$(cat $PROJECT_ROOT/build-loop/context/fe-architecture.md | grep '^[*][*]Root:' | sed 's/\*\*Root:\*\* //' | tr -d ' ')
FE_ROOT="${FE_ROOT:-$PROJECT_ROOT/wastehero_frontend-development}"

# Install @playwright/test as devDep if not present
if ! grep -q '"@playwright/test"' "$FE_ROOT/package.json" 2>/dev/null; then
  cd "$FE_ROOT" && yarn add --dev @playwright/test 2>&1 | tail -5
fi

# Install browsers (chromium only — fastest)
cd "$FE_ROOT" && npx playwright install chromium --with-deps 2>&1 | tail -10
```

Create the test output folder:
```bash
mkdir -p "$PROJECT_ROOT/build-loop/fe-tests"
mkdir -p "$PROJECT_ROOT/build-loop/screenshots"
```

---

## Step 3 — Derive Playwright actions from the Manual Test Path

Read the `## Manual Test Path` section from `$PROJECT_ROOT/build-loop/plans/$ARGUMENTS.md`.

Translate each step into a Playwright action using this mapping:

| Manual step | Playwright code |
|-------------|----------------|
| navigate to `/route` | `await page.goto(BASE_URL + '/route')` |
| click button "Text" | `await page.getByRole('button', { name: 'Text' }).click()` |
| click link "Text" | `await page.getByRole('link', { name: 'Text' }).click()` |
| fill [field label] with [value] | `await page.getByLabel('[field label]').fill('[value]')` |
| select [value] from [dropdown] | `await page.getByRole('combobox', { name: '[dropdown label]' }).selectOption('[value]')` |
| submit / press Enter | `await page.keyboard.press('Enter')` |
| expect to see [text] | `await expect(page.getByText('[text]')).toBeVisible()` |
| wait for load | `await page.waitForLoadState('networkidle', { timeout: 15000 })` |

Collect these as an array of strings called `PLAYWRIGHT_ACTIONS`.

---

## Step 4 — Write the Playwright test file

```bash
mkdir -p "$FE_ROOT/build-loop-tests"
```

Write `$FE_ROOT/build-loop-tests/<req_id_lower>.spec.ts`:

```typescript
import { test, expect } from '@playwright/test'
import * as fs from 'fs'
import * as path from 'path'

const BASE_URL = 'http://localhost:<FE_PORT>'
const GQL_ENDPOINT = '/graph-api/'
const REPORT_PATH = '<PROJECT_ROOT>/build-loop/fe-tests/<REQ_ID>-results.json'
const SCREENSHOTS_DIR = '<PROJECT_ROOT>/build-loop/screenshots'

interface GqlCall {
  operationName: string
  url: string
  status: number
  hasErrors: boolean
  errors: Array<{ message: string; locations?: unknown; path?: unknown }>
  requestBody?: string
}

const gqlCalls: GqlCall[] = []
const consoleErrors: string[] = []

test.describe('<REQ_ID>: <requirement summary>', () => {

  test('login, navigate, and verify no GraphQL errors', async ({ page }) => {

    // ── Capture console errors ──────────────────────────────────────────
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        consoleErrors.push(`[console.error] ${msg.text()}`)
      }
    })

    // ── Intercept GraphQL responses ─────────────────────────────────────
    page.on('response', async (response) => {
      if (!response.url().includes(GQL_ENDPOINT)) return

      let operationName = 'unknown'
      try {
        const req = response.request()
        const postData = req.postData()
        if (postData) {
          const parsed = JSON.parse(postData)
          operationName = parsed.operationName || 'unknown'
        }
      } catch {}

      let body: { data?: unknown; errors?: Array<{ message: string }> } = {}
      try {
        body = await response.json()
      } catch {
        return // non-JSON response, skip
      }

      const call: GqlCall = {
        operationName,
        url: response.url(),
        status: response.status(),
        hasErrors: !!(body.errors && body.errors.length > 0),
        errors: body.errors ?? [],
      }
      gqlCalls.push(call)
    })

    // ── Step 1: Log in ──────────────────────────────────────────────────
    await page.goto(`${BASE_URL}/login`)
    await page.waitForLoadState('networkidle', { timeout: 15000 })

    // Fill credentials
    await page.locator('input[type="email"], input[name="email"], input[name="username"], input#email').first().fill('<TEST_USERNAME>')
    await page.locator('input[type="password"], input[name="password"], input#password').first().fill('<TEST_PASSWORD>')

    // Click submit
    await page.locator('button[type="submit"], button:has-text("Sign in"), button:has-text("Login")').first().click()

    // Wait for successful login (off the /login route)
    await page.waitForFunction(
      () => !window.location.pathname.includes('/login'),
      { timeout: 15000 }
    ).catch(async () => {
      // If still on login page, check for error message
      const errorText = await page.locator('.ant-message-error, .ant-form-item-explain-error, [role="alert"]').textContent().catch(() => '')
      throw new Error(`Login failed. Page error: ${errorText}`)
    })

    await page.screenshot({ path: `${SCREENSHOTS_DIR}/<req_id_lower>-after-login.png` })

    // ── Step 2: Navigate to the requirement's route ─────────────────────
    await page.goto(`${BASE_URL}<ROUTE>`)
    await page.waitForLoadState('networkidle', { timeout: 15000 })
    await page.screenshot({ path: `${SCREENSHOTS_DIR}/<req_id_lower>-page-load.png` })

    // ── Step 3: Perform manual test path actions ────────────────────────
    <PLAYWRIGHT_ACTIONS>

    // Wait for any in-flight GraphQL calls to settle
    await page.waitForLoadState('networkidle', { timeout: 10000 }).catch(() => {})
    await page.screenshot({ path: `${SCREENSHOTS_DIR}/<req_id_lower>-final.png` })

    // ── Assertions ──────────────────────────────────────────────────────
    const failedCalls = gqlCalls.filter((c) => c.hasErrors)

    // Write results JSON for the report generator
    fs.mkdirSync(path.dirname(REPORT_PATH), { recursive: true })
    fs.writeFileSync(REPORT_PATH, JSON.stringify({ gqlCalls, failedCalls, consoleErrors }, null, 2))

    // Fail if any GraphQL operation returned errors
    expect(
      failedCalls,
      `GraphQL operations returned errors:\n${failedCalls
        .map((c) => `  [${c.operationName}] ${c.errors.map((e) => e.message).join('; ')}`)
        .join('\n')}`
    ).toHaveLength(0)

    // Warn (but don't fail) on console errors
    if (consoleErrors.length > 0) {
      console.warn(`Console errors detected:\n${consoleErrors.join('\n')}`)
    }
  })
})
```

Replace the `<PLAYWRIGHT_ACTIONS>` placeholder with the actions derived in Step 3, each on its own line, prefixed with `    ` (4 spaces).

Replace all `<PLACEHOLDER>` values with actual values resolved from the config and plan.

---

## Step 5 — Run the test

```bash
cd "$FE_ROOT" && npx playwright test "build-loop-tests/<req_id_lower>.spec.ts" \
  --reporter=list \
  --timeout=60000 \
  2>&1 | tee "$PROJECT_ROOT/build-loop/fe-tests/<req_id_lower>-run.log"

TEST_EXIT=$?
echo "Playwright exit code: $TEST_EXIT"
```

---

## Step 6 — Parse results and write report

Read `$PROJECT_ROOT/build-loop/fe-tests/<REQ_ID>-results.json` (written by the test's afterAll).

Also read the last 30 lines of `<req_id_lower>-run.log` for the summary.

Write `$PROJECT_ROOT/build-loop/fe-tests/$ARGUMENTS.md`:

```markdown
# FE Test Report: [REQ_ID]

**Requirement:** [summary]
**Tested at:** [ISO timestamp]
**Route:** [ROUTE]
**Overall result:** PASSES | FAILS

## GraphQL Call Summary

| Operation | Errors? | Error messages |
|-----------|---------|----------------|
| tokenAuth | ✅ No | — |
| [OperationName] | ❌ Yes | [error message] |

**Total GraphQL calls intercepted:** [n]
**Calls with errors:** [n]

## Failed GraphQL Operations

[For each failed call:]

### [operationName]
- **Error:** [error.message]
- **Path:** [error.path if present]
- **Fix needed:** [what this error suggests — e.g. "resolver returned null for non-nullable field X", "permission denied", "object not found"]

## Console Errors
[list or "None"]

## Screenshots
- After login: build-loop/screenshots/[req_id]-after-login.png
- Page load: build-loop/screenshots/[req_id]-page-load.png
- Final state: build-loop/screenshots/[req_id]-final.png

## Playwright run log
```
[last 30 lines of run log]
```
```

The final line of the file must be exactly `PASSES` or `FAILS`.

- `PASSES` if: `TEST_EXIT == 0` and `failedCalls.length == 0`
- `FAILS` otherwise

---

## Step 7 — Clean up servers started by this skill

Only kill servers that this skill started (check PID files):

```bash
if [ -f "$PROJECT_ROOT/build-loop/logs/fe-server.pid" ]; then
  kill "$(cat $PROJECT_ROOT/build-loop/logs/fe-server.pid)" 2>/dev/null || true
  rm "$PROJECT_ROOT/build-loop/logs/fe-server.pid"
fi
if [ -f "$PROJECT_ROOT/build-loop/logs/be-server.pid" ]; then
  kill "$(cat $PROJECT_ROOT/build-loop/logs/be-server.pid)" 2>/dev/null || true
  rm "$PROJECT_ROOT/build-loop/logs/be-server.pid"
fi
```

Do NOT kill servers that were already running before this skill started.

---

## Output

After writing the report, output exactly one of:
```
FE_TEST_RESULT: PASSES
```
```
FE_TEST_RESULT: FAILS
```
```
FE_TEST_RESULT: SKIPPED [reason]
```
```
FE_TEST_RESULT: ERROR [reason]
```
