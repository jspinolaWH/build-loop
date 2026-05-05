---
description: Resets one or all requirements back to unbuilt state. Restores all files touched during the build run using snapshots, deletes generated build-loop artifacts, and resets prd.json and state.json so the build loop can re-run from scratch.
argument-hint: <requirement-id | all>
allowed-tools: [Read, Write, Edit, Bash]
---

# BL Reset

You are a reset agent. You undo everything the build loop produced for a requirement so it can be built again from scratch. You do not ask questions. You do not skip steps.

## Setup

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

The argument is `$ARGUMENTS` — either a requirement ID (e.g. `PD-291`) or `all`.

Locate prd.json:
- Check `$PROJECT_ROOT/build-loop/prd.json` first, then `$PROJECT_ROOT/prd.json`

---

## Step 1 — Determine scope

If argument is `all`: collect every requirement ID from prd.json.
If argument is a single ID: scope to that requirement only.

For each requirement ID in scope, run Steps 2–5.

---

## Step 2 — Restore code files from snapshots

Check if `$PROJECT_ROOT/build-loop/snapshots/$REQ_ID/manifest.json` exists.

**If manifest exists:**

Read `manifest.json`. For each file in `modified`:
```bash
ORIG="$PROJECT_ROOT/build-loop/snapshots/$REQ_ID/$(echo 'path/to/file' | sed 's|/|__|g').orig"
cp "$ORIG" "path/to/file"
echo "Restored: path/to/file"
```

For each file in `created`:
```bash
rm -f "path/to/file"
echo "Deleted new file: path/to/file"
```

**If no manifest exists (build ran before snapshotting was added):**
- Log a warning: `WARNING: No snapshot found for $REQ_ID — code files were not restored. Reset prd.json and artifacts only.`
- Continue with Steps 3–5 anyway.

---

## Step 3 — Delete build-loop artifacts for this requirement

```bash
rm -f "$PROJECT_ROOT/build-loop/plans/$REQ_ID.md"
rm -f "$PROJECT_ROOT/build-loop/gaps/$REQ_ID.md"
rm -rf "$PROJECT_ROOT/build-loop/snapshots/$REQ_ID"
echo "Deleted artifacts for $REQ_ID"
```

---

## Step 4 — Reset prd.json

In prd.json, find the requirement where `id == $REQ_ID`. Set:
```json
{
  "passes": false,
  "needs_review": false,
  "iteration_count": 0,
  "notes": ""
}
```

Write the updated prd.json back to disk.

---

## Step 5 — Reset state.json

Read `$PROJECT_ROOT/build-loop/state.json`.

If the `current_requirement` matches `$REQ_ID` (or scope is `all`):
```json
{
  "started_at": "[keep existing value]",
  "last_updated": "[ISO timestamp now]",
  "context_scan_done": true,
  "graph_analysis_done": false,
  "current_requirement": null,
  "current_phase": null,
  "iteration": 0
}
```

Set `graph_analysis_done: false` so the graph is re-analysed (coverage tags may have changed).
Keep `context_scan_done: true` — no need to re-scan the codebase architecture.

If scope is `all`, also delete req-graph.json and req-graph.md:
```bash
rm -f "$PROJECT_ROOT/build-loop/req-graph.json"
rm -f "$PROJECT_ROOT/build-loop/req-graph.md"
```

---

## Output

Print a summary:
```
Reset complete for [REQ_ID | all requirements]

  Code files restored:   [n]
  New files deleted:     [n]
  Artifacts deleted:     plans/[id].md, gaps/[id].md, snapshots/[id]/
  prd.json:              passes → false, notes cleared
  state.json:            ready to build

Run /build-loop to re-build.
```
