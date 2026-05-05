---
description: Fully autonomous build loop for WasteHero platform. Reads prd.json, scans codebase, maps requirement graph, then designs/builds/verifies each requirement until done. Zero human input. Fully resumable.
argument-hint: [max-iterations-per-requirement]
allowed-tools: [Read, Write, Bash, Agent, ScheduleWakeup]
---

# Build Loop — Orchestrator

You are the autonomous build loop orchestrator. You run overnight. You **never ask questions**. You **never wait for input**. You drive every requirement from prd.json to completion and log everything. When you are done, the developer reads loop-summary.md.

**CRITICAL — How sub-skills work:**
Every phase (context scan, graph analysis, design, build, gap-check) must be run using the **Agent tool**, NOT the Skill tool. The Agent tool spawns a sub-agent that completes the work and returns the result to you. You then continue the loop immediately. Never use the Skill tool for sub-skills — it hands off the turn and stops the loop.

---

## Setup

### 1. Detect project root

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

### 2. Locate prd.json

Check `$PROJECT_ROOT/build-loop/prd.json` first. If not found, check `$PROJECT_ROOT/prd.json`. Use whichever exists. If neither exists:
```
ERROR: prd.json not found. Create build-loop/prd.json first. See prd.example.json for schema.
```
Stop.

Store the path as `PRD_PATH`.

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
- If it does not exist: create it:

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

Invoke via **Agent tool**:
```
description: "BL context scan"
prompt: "Invoke the /bl-context-scan skill using the Skill tool. Project root: [PROJECT_ROOT]. Complete all steps in the skill fully. Your final output line must be exactly: CONTEXT_SCAN_RESULT: DONE"
```

Read the last line of the agent response starting with `CONTEXT_SCAN_RESULT:`.
- `CONTEXT_SCAN_RESULT: DONE` → update state: `context_scan_done: true`, proceed
- `CONTEXT_SCAN_RESULT: ERROR` → log error, attempt once more, then stop with message asking user to check codebase paths

---

## Phase B — Requirement Graph Analysis (skip if state.graph_analysis_done = true)

Update state.json: `"current_phase": "graph-analysis"`

Invoke via **Agent tool**:
```
description: "BL graph analysis"
prompt: "Invoke the /bl-graph-analysis skill using the Skill tool. Project root: [PROJECT_ROOT]. prd.json is at [PRD_PATH]. Complete all steps fully and produce req-graph.json. Your final output line must be exactly: GRAPH_RESULT: DONE"
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

Read the requirement from prd.json. Check for Meyer's Seven Sins:

1. **Silence** — does it have at least one acceptance criterion? If none → flag
2. **Ambiguity** — do criteria use unmeasurable terms ("user-friendly", "seamless") with no measurable definition? → flag
3. **Wishful thinking** — are all criteria untestable? ("works well", "looks good") → flag

If pre-flight fails:
- Set `needs_review: true`, `notes: "Pre-flight failed [timestamp]: [reason]"` in prd.json
- Log: `[timestamp] PREFLIGHT_FAIL [req-id] [reason]`
- Move to next requirement

If pre-flight passes, proceed.

### Iteration loop

Update state.json with current requirement and reset iteration to 0 (or resume from state.iteration).

**Step 1 — Design** (run on first iteration only; subsequent iterations use gap report)

Update state: `current_phase: "design"`

Invoke via **Agent tool**:
```
description: "BL design [REQ_ID]"
prompt: "Invoke the /bl-design skill using the Skill tool with argument [REQ_ID]. Project root: [PROJECT_ROOT]. prd.json at: [PRD_PATH]. Complete all steps fully and write the plan file. Your final output line must be exactly: DESIGN_RESULT: DONE"
```

Read last line starting with `DESIGN_RESULT:`.
- `DESIGN_RESULT: DONE` → log DESIGN_DONE, proceed to Step 2
- `DESIGN_RESULT: ERROR` → log, count as iteration, retry if iterations remain, else flag

**Step 2 — Build**

Update state: `current_phase: "build"`, `iteration: [n]`

Invoke via **Agent tool**:
```
description: "BL build [REQ_ID] iter [n]"
prompt: "Invoke the /bl-build skill using the Skill tool with argument [REQ_ID]. Project root: [PROJECT_ROOT]. prd.json at: [PRD_PATH]. Iteration: [n]. If iteration > 0, the gap report is at build-loop/gaps/[REQ_ID].md — pass this context to the skill. Implement fully, run the build, fix errors. Your final output line must be exactly one of: BUILD_RESULT: DONE or BUILD_RESULT: BUILD_FAILED"
```

Read last line starting with `BUILD_RESULT:`.
- `BUILD_RESULT: DONE` → log BUILD_DONE, proceed to Step 3
- `BUILD_RESULT: BUILD_FAILED` → log WARNING, proceed to Step 3 (gap check will catch it)
- `BUILD_RESULT: ERROR` → log ERROR, flag requirement, move to next

**Step 3 — Verify**

Update state: `current_phase: "verify"`

Invoke via **Agent tool**:
```
description: "BL gap-check [REQ_ID] iter [n]"
prompt: "Invoke the /bl-gap-check skill using the Skill tool with argument [REQ_ID]. Project root: [PROJECT_ROOT]. prd.json at: [PRD_PATH]. Scan all acceptance criteria, write the gap report, update prd.json. Your final output line must be exactly one of: GAP_CHECK_RESULT: PASSES or GAP_CHECK_RESULT: GAPS_FOUND"
```

Read last line starting with `GAP_CHECK_RESULT:`.
- `GAP_CHECK_RESULT: PASSES` → mark `passes: true` in prd.json, log PASS, call `ScheduleWakeup(delaySeconds=60, reason="continuing to next requirement", prompt="/build-loop [ORIGINAL_ARGUMENTS]")` as a heartbeat, then immediately continue to next requirement without waiting for the wakeup
- `GAP_CHECK_RESULT: GAPS_FOUND` → check iteration count:
  - If iterations < MAX_ITERATIONS: increment iteration in state.json, loop back to Step 2 (skip design)
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
