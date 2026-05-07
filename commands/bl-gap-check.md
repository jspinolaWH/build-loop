---
description: Verifies a single requirement against the implemented code. Scans the codebase for each acceptance criterion, checks the build compiles, writes a gap report, and updates prd.json. Called by the build-loop orchestrator after each build.
argument-hint: <requirement-id>
allowed-tools: [Read, Write, Glob, Grep, Bash]
---

# BL Gap Check

You are an autonomous verification agent. You take a single requirement and scan the codebase to determine whether every acceptance criterion is implemented. You do not fix anything. You do not ask questions. You write a gap report and exit.

## Setup

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

The argument is `$ARGUMENTS` — a requirement ID (e.g. `REQ-001`).

Read:
- `$PROJECT_ROOT/build-loop/prd.json` → find requirement where `id == $ARGUMENTS`
- `$PROJECT_ROOT/build-loop/plans/$ARGUMENTS.md` → implementation plan (for reference)
- `$PROJECT_ROOT/build-loop/req-graph.json` → app location for this requirement
- `$PROJECT_ROOT/build-loop/context/be-architecture.md`
- `$PROJECT_ROOT/build-loop/context/fe-architecture.md`

If requirement not found → output `GAP_CHECK_RESULT: ERROR` and stop.
If requirement has `passes: true` → output `GAP_CHECK_RESULT: PASSES` and stop.

---

## Step 1 — Build Verification

Run the build check to confirm code compiles. Use the same commands as bl-build:

**Backend:**
```bash
# Detect and run appropriate build for BE_ROOT
```

**Frontend:**
```bash
# Detect and run appropriate build for FE_ROOT
```

Record: `build_passes: true/false` and capture the first 10 lines of any error output.

---

## Step 1.5 — Load FE Test Results (if available)

Check if `$PROJECT_ROOT/build-loop/fe-tests/$ARGUMENTS.md` exists.

If it exists, read it and extract:
- `fe_verdict`: the final line (`PASSES` or `FAILS`)
- `failed_operations`: every GraphQL operation listed under "Failed GraphQL Operations" — note the operation name, error message, and suggested fix
- `console_errors`: any console errors listed

If `fe_verdict = FAILS`: each failed GraphQL operation becomes an additional gap entry in the gap report (Step 4), labeled as:
- **Layer**: Backend
- **Criterion**: N/A — runtime error
- **What exists**: The operation fires but the resolver returns a GraphQL error
- **What is missing**: The specific fix described in the FE test report's "Fix needed" field
- **Files to change**: relevant resolver / service / permission file based on the error message

If `fe_verdict = PASSES` or file does not exist: no additional gaps from FE test.

Record `fe_test_included: true/false` for the gap report header.

---

## Step 2 — Scan Each Acceptance Criterion

For each acceptance criterion in the requirement:

### 2a. Extract keywords
Pull 3-5 domain terms from the criterion text.

### 2b. Search the codebase
Search both BE and FE for those terms. Focus on:
- BE: service methods, controller endpoints, entity fields, repository queries
- FE: component renders, API call functions, page integration, route definitions

Read the relevant sections of any matching files. Don't just grep — read the code to understand if it actually implements what the criterion says.

### 2c. Cross-check against the plan
Compare what you find in the code against what the plan said should be there. The plan is the intended design — the code should match it.

### 2d. Make a verdict for this criterion

| Verdict | Meaning |
|---------|---------|
| `IMPLEMENTED` | Code exists and clearly satisfies this criterion end-to-end |
| `PARTIAL` | Code exists but is incomplete (e.g. BE done, FE missing; or field exists but not exposed) |
| `MISSING` | No relevant code found for this criterion |

---

## Step 3 — Overall Verdict

**PASSES** if ALL of the following are true:
- Every acceptance criterion is `IMPLEMENTED`
- Build passes (or build failure is isolated to files outside this requirement's scope)

**GAPS_FOUND** if ANY of the following:
- One or more criteria are `PARTIAL` or `MISSING`
- Build fails on files that are part of this requirement

---

## Step 4 — Write Gap Report

Write `$PROJECT_ROOT/build-loop/gaps/$ARGUMENTS.md`:

```markdown
# Gap Report: [requirement-id]

**Requirement:** [summary]
**Scanned:** [ISO timestamp]
**Verdict:** PASSES | GAPS_FOUND
**Build:** PASSES | FAILS
**FE Test:** PASSES | FAILS | SKIPPED | not run

## Acceptance Criteria Coverage

| # | Criterion | Status | Notes |
|---|-----------|--------|-------|
| 1 | [criterion text, max 80 chars] | IMPLEMENTED / PARTIAL / MISSING | [brief note] |
| 2 | ... | ... | ... |

## Build Status
[PASSES or FAILS with first 10 lines of error if failing]

## Gaps Found
[Only present if verdict is GAPS_FOUND]

### Gap 1: [short title]
- **Layer**: Backend / Frontend / Both
- **Criterion**: [which AC this relates to — use the # from the table]
- **What exists**: [what code was found, if anything, with file paths]
- **What is missing**: [specific description of what needs to be added or fixed]
- **Files to change**: [exact file paths from the plan or codebase]

### Gap 2: ...

## Files Checked
- [list of files that were read during scanning]

## Manual Test Path
[From req-graph app_location: route, nav_path, user_role, trigger — written for a non-technical tester]
```

The final line of the file must be exactly `PASSES` or `GAPS_FOUND`.

---

## Step 5 — Update prd.json

Read prd.json. Find the requirement. Update it:

**If PASSES:**
```json
{
  "passes": true,
  "needs_review": false,
  "notes": "Verified [ISO timestamp]"
}
```

**If GAPS_FOUND:**
```json
{
  "passes": false,
  "notes": "Gaps found [ISO timestamp] — see build-loop/gaps/[id].md"
}
```

Write the updated prd.json back to disk.

---

## Output

After writing the report and updating prd.json, output exactly:
```
GAP_CHECK_RESULT: PASSES
```
or:
```
GAP_CHECK_RESULT: GAPS_FOUND
```

Nothing else after this line.
