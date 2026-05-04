---
description: Fully autonomous build loop for WasteHero platform. Reads build-loop/prd.json, scans codebase, maps requirement graph, then designs/builds/verifies each requirement until done. Zero human input. Fully resumable.
argument-hint: [max-iterations-per-requirement]
allowed-tools: [Read, Write, Bash]
---

# Build Loop — Orchestrator

You are the autonomous build loop orchestrator. You run overnight. You never ask questions. You never wait for input. You drive every requirement from prd.json to completion and log everything. When you are done, the developer reads loop-summary.md.

## Setup

### 1. Detect project root

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

### 2. Verify build-loop folder exists

Check that `$PROJECT_ROOT/build-loop/prd.json` exists. If not:
```
ERROR: build-loop/prd.json not found in $PROJECT_ROOT
Create build-loop/prd.json first. See prd.example.json for schema.
```
Stop.

### 3. Create required folders

```bash
mkdir -p $PROJECT_ROOT/build-loop/gaps
mkdir -p $PROJECT_ROOT/build-loop/plans
mkdir -p $PROJECT_ROOT/build-loop/context
mkdir -p $PROJECT_ROOT/build-loop/skills
```

### 4. Read configuration

The argument is `$ARGUMENTS`.
- If a number is provided, use it as `MAX_ITERATIONS` per requirement (default: 4)

### 5. Load or initialise state

Check if `$PROJECT_ROOT/build-loop/state.json` exists.
- If it exists: read it and resume from where the loop left off
- If it does not exist: create it with initial state:

```json
{
  "started_at": "[ISO timestamp]",
  "last_updated": "[ISO timestamp]",
  "context_scan_done": false,
  "graph_analysis_done": false,
  "current_requirement": null,
  "current_phase": null,
  "iteration": 0
}
```

### 6. Read prd.json

Load all requirements. Count total, passing, remaining.

Output the opening banner:
```
╔══════════════════════════════════════════╗
║         BUILD LOOP STARTING              ║
╠══════════════════════════════════════════╣
║ Project:    $PROJECT_ROOT                ║
║ Total:      [n] requirements             ║
║ Passing:    [n]                          ║
║ Remaining:  [n]                          ║
║ Max iters:  [n] per requirement          ║
╚══════════════════════════════════════════╝
```

---

## Phase A — Context Scan (skip if state.context_scan_done = true)

Update state.json: `"current_phase": "context-scan"`

Run:
```bash
claude -p "/bl-context-scan" --cwd $PROJECT_ROOT
```

Read the last line of stdout starting with `CONTEXT_SCAN_RESULT:`.
- `CONTEXT_SCAN_RESULT: DONE` → update state: `context_scan_done: true`, proceed
- `CONTEXT_SCAN_RESULT: ERROR` → log error, stop with message asking user to check codebase paths

---

## Phase B — Requirement Graph Analysis (skip if state.graph_analysis_done = true)

Update state.json: `"current_phase": "graph-analysis"`

Run:
```bash
claude -p "/bl-graph-analysis" --cwd $PROJECT_ROOT
```

Read the last line starting with `GRAPH_RESULT:`.
- `GRAPH_RESULT: DONE` → update state: `graph_analysis_done: true`, proceed
- `GRAPH_RESULT: ERROR` → log error, stop

Read `$PROJECT_ROOT/build-loop/req-graph.json`. Use `sorted_order` array as the queue for Phase C.

---

## Phase C — Requirement Loop

Work through requirements in `sorted_order` from req-graph.json. Skip any with `passes: true` in prd.json.

If `state.current_requirement` is set (resuming), start from that requirement.

For each requirement:

### Pre-flight check

Read the requirement from prd.json. Perform a quick internal check for Meyer's Seven Sins:

1. **Silence** — does it have at least one acceptance criterion? If none → flag immediately
2. **Ambiguity** — do acceptance criteria use vague unmeasurable terms like "user-friendly", "fast", "seamless" with no measurable definition? If yes → flag
3. **Wishful thinking** — are criteria untestable? (e.g. "works well", "looks good") If all criteria are untestable → flag

If pre-flight fails:
- Set `needs_review: true`, `notes: "Pre-flight failed [timestamp]: [reason]"` in prd.json
- Log: `[timestamp] PREFLIGHT_FAIL [req-id] [reason]`
- Move to next requirement

If pre-flight passes, proceed.

### Iteration loop

Update state.json with current requirement and reset iteration to 0 (or resume from state.iteration).

**Step 1 — Design**

Update state: `current_phase: "design"`

Run:
```bash
claude -p "/bl-design $REQUIREMENT_ID" --cwd $PROJECT_ROOT
```

Read last line starting with `DESIGN_RESULT:`.
- `DESIGN_RESULT: DONE` → proceed to Step 2
- `DESIGN_RESULT: ERROR` → log, count as iteration, if iterations remain retry design, else flag

**Step 2 — Build**

Update state: `current_phase: "build"`, `iteration: [n]`

Run:
```bash
claude -p "/bl-build $REQUIREMENT_ID" --cwd $PROJECT_ROOT
```

Read last line starting with `BUILD_RESULT:`.
- `BUILD_RESULT: DONE` → proceed to Step 3
- `BUILD_RESULT: BUILD_FAILED` → log warning, proceed to Step 3 anyway (gap check will catch it)
- `BUILD_RESULT: ERROR` → log, flag requirement, move on

**Step 3 — Verify**

Update state: `current_phase: "verify"`

Run:
```bash
claude -p "/bl-gap-check $REQUIREMENT_ID" --cwd $PROJECT_ROOT
```

Read last line starting with `GAP_CHECK_RESULT:`.
- `GAP_CHECK_RESULT: PASSES` → mark `passes: true` in prd.json, log PASS, move to next requirement
- `GAP_CHECK_RESULT: GAPS_FOUND` → check iteration count:
  - If iterations < MAX_ITERATIONS: increment iteration in state.json, loop back to Step 2 (skip design, use gap report)
  - If iterations >= MAX_ITERATIONS: set `needs_review: true`, `notes: "Max iterations [timestamp]"`, log MAX_ITERATIONS, move to next

### Logging

Every action appends to `$PROJECT_ROOT/build-loop/loop.log`:
```
[ISO timestamp] [LEVEL] [req-id] [message]
```
Levels: `START`, `PASS`, `PREFLIGHT_FAIL`, `DESIGN_DONE`, `BUILD_DONE`, `FIX_APPLIED`, `MAX_ITERATIONS`, `SKIPPED`, `WARNING`, `ERROR`

---

## After all requirements

Read prd.json and count final state.

Write `$PROJECT_ROOT/build-loop/loop-summary.md`:

```markdown
# Build Loop Summary

**Completed:** [ISO timestamp]
**Project:** [PROJECT_ROOT]
**Duration:** [start to end]

## Results

| Status | Count |
|--------|-------|
| ✅ Passing | [n] |
| ⚠️ Needs review | [n] |
| ❌ Still failing | [n] |

## ✅ Built & Verified

[For each passing requirement:]
### [req-id] — [summary]
- **What was built:** [brief description]
- **Where to test manually:** [route/page] → [what to click] → [what to expect]
- **Iterations needed:** [n]

## ⚠️ Needs Manual Review

[For each flagged requirement:]
### [req-id] — [summary]
- **Reason:** [preflight fail reason / max iterations / error]
- **Last gap report:** build-loop/gaps/[req-id].md
- **Iterations attempted:** [n]
```

Output final banner:
```
╔══════════════════════════════════════════╗
║         BUILD LOOP COMPLETE              ║
╠══════════════════════════════════════════╣
║ ✅ Passing:       [n]                    ║
║ ⚠️  Needs review: [n]                    ║
║ ❌ Still failing: [n]                    ║
╚══════════════════════════════════════════╝

See build-loop/loop-summary.md for full report.
```

Update state.json: `"current_phase": "complete"`.
