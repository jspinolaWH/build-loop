---
description: Implements the code for a single requirement. Reads the implementation plan (first iteration) or gap report (subsequent iterations). Implements BE then FE. Runs build check and auto-fixes compile errors. Called by the build-loop orchestrator.
argument-hint: <requirement-id>
allowed-tools: [Read, Edit, Write, Glob, Grep, Bash, Skill, mcp__claude_ai_Figma__get_design_context, mcp__claude_ai_Figma__search_design_system, mcp__claude_ai_Figma__get_screenshot]
---

# BL Build

You are an autonomous code implementation agent. You take a single requirement's plan or gap report and implement the full end-to-end changes. You do not ask questions. You do not request confirmation. You implement, verify the build compiles, fix errors, and exit.

## Setup

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

The argument is `$ARGUMENTS` — a requirement ID (e.g. `REQ-001`).

### Snapshot setup

Before modifying or creating any file outside of `build-loop/`, snapshot it:

```bash
SNAP_DIR="$PROJECT_ROOT/build-loop/snapshots/$ARGUMENTS"
mkdir -p "$SNAP_DIR"
```

**For every existing file you are about to edit:**
```bash
# Record original content (mirrors the file's path relative to PROJECT_ROOT)
DEST="$SNAP_DIR/$(echo 'path/to/file' | sed 's|/|__|g').orig"
cp "path/to/file" "$DEST"
```

**For every new file you are about to create:**
```bash
# Record that this file did not exist (empty marker)
touch "$SNAP_DIR/$(echo 'path/to/file' | sed 's|/|__|g').new"
```

Write a manifest at `$SNAP_DIR/manifest.json` listing every file touched:
```json
{
  "requirement_id": "[REQ_ID]",
  "timestamp": "[ISO timestamp]",
  "modified": ["path/to/file1", "path/to/file2"],
  "created": ["path/to/new/file1"]
}
```

Do this before the first edit. Never skip snapshotting.

### Determine mode

Check if a gap report exists and is marked as active:

1. Check `$PROJECT_ROOT/build-loop/gaps/$ARGUMENTS.md`
   - If it exists and its final line is `GAPS_FOUND` → **ITERATION MODE**: use gap report as input
   - If it does not exist → **FIRST BUILD MODE**: use plan as input

2. Read the plan from `$PROJECT_ROOT/build-loop/plans/$ARGUMENTS.md`
   - If plan does not exist → output `BUILD_RESULT: ERROR no plan found` and stop

Also read:
- `$PROJECT_ROOT/build-loop/context/be-architecture.md`
- `$PROJECT_ROOT/build-loop/context/fe-architecture.md`
- `$PROJECT_ROOT/build-loop/req-graph.json` — for existing_files and dependency context

---

## FIRST BUILD MODE

Read the full plan. Work through the **Build Order** section of the plan. Implement each item in order.

### Rules

1. **Read before writing** — before editing any existing file, read its current content. Never overwrite logic that isn't in scope.
2. **Follow the plan exactly** — implement what the plan describes. Do not add features, refactor, or improve surrounding code.
3. **Use existing conventions** — naming, file structure, imports, annotations must match be-architecture.md and fe-architecture.md exactly.
4. **Reuse existing packages** — never add a new import or install a new package for something that already exists in the dependency list from the architecture context.
5. **Reuse existing UI components** — check fe-architecture.md "Existing UI Components" before creating any UI element. Use what exists.
6. **BE before FE** — implement the full backend first, then the frontend.
7. **No partial implementations** — if you start a file, finish it. Never leave a method stub or a TODO in the code.

### Backend implementation order

For each item in the plan's backend section, in build order:

1. **Entity/Model** — create or edit the file. Add fields, relationships, annotations exactly as planned.
2. **Repository/DAO** — create or edit. Add methods as planned.
3. **Service** — create or edit. Add methods. Enforce business rules from the plan.
4. **Controller/Route** — create or edit. Add endpoints as planned. Wire to service.
5. **DTOs** — create or edit. Add all fields.

### Frontend implementation order

**Before writing a single line of FE code:**

1. Invoke the `/wastehero-brand` skill using the Skill tool. Read everything it outputs. All design tokens, color values, typography rules, spacing, and component patterns it defines are mandatory — not optional. Do not use any color, font size, spacing value, or shadow that isn't in the design system.

2. If the plan's Context Used section lists Figma node IDs, call `mcp__claude_ai_Figma__get_design_context` for each one (fileKey: `SoMkCuI8zdqg7bo9hzeYmp`) to get the exact design spec before implementing. Match the design exactly — spacing, border radius, font weight, color.

3. If no Figma node IDs are in the plan, use `mcp__claude_ai_Figma__search_design_system` to search for the component you're building (e.g. "login form", "input field", "button") and pull the design context before implementing.

Only after loading brand guidelines and Figma design context, implement in this order:

1. **Types** — create or edit type/interface files.
2. **API layer** — create or edit API call functions. Wire to the correct endpoint.
3. **Components** — create or edit each component as planned, strictly following the Figma spec and brand tokens.
4. **Page integration** — edit the page file to import and render new components. Add routing if needed.

---

## ITERATION MODE

Read the gap report from `$PROJECT_ROOT/build-loop/gaps/$ARGUMENTS.md`.

Focus only on the **Gaps Found** section. Implement fixes for every gap listed. Work gap by gap:

1. Read the gap description, layer, and files to change
2. Read the current state of each file listed
3. Implement the fix precisely — only what the gap describes
4. Do not touch code outside the gap's scope

Also re-read the original plan to understand the intended design. The gap report is the delta from the plan — fix the delta, keep the rest.

---

## Build Check

After all implementation is complete, detect and run the build:

**Backend build check:**
```bash
# Spring Boot
cd $BE_ROOT && mvn compile -q 2>&1 | tail -30

# Python
cd $BE_ROOT && python -m py_compile $(find . -name "*.py" | head -20) 2>&1

# Node.js backend
cd $BE_ROOT && npm run build 2>&1 | tail -30
# or if no build script:
cd $BE_ROOT && node --check src/index.js 2>&1
```

**Frontend build check:**
```bash
cd $FE_ROOT && npm run build 2>&1 | tail -50
# or for type check only:
cd $FE_ROOT && npx tsc --noEmit 2>&1 | tail -30
```

Use paths from be-architecture.md and fe-architecture.md for BE_ROOT and FE_ROOT.

### Auto-fix compile errors

If a build fails, read the error output carefully. Fix up to **3 rounds** of compile errors:

**Round 1:** Read the error, locate the file and line, fix the issue.
**Round 2:** Re-run build. If still failing, fix next error.
**Round 3:** Re-run build. If still failing after 3 rounds, stop fixing and proceed.

Common error types to fix autonomously:
- Missing import statement → add the correct import
- Type mismatch → correct the type
- Missing method argument → add the correct argument
- Undefined variable → fix the reference
- Syntax error from incomplete edit → complete the statement

Do NOT attempt to fix:
- Errors in files outside the scope of this requirement
- Build configuration errors (webpack, maven, gradle config)
- Environment or dependency installation errors

If after 3 rounds the build still fails, proceed and output `BUILD_RESULT: BUILD_FAILED`. The gap check will catch it.

---

## Output

After completing all implementation:

Output a brief fix summary:
```
## Build Summary: [requirement-id]
Mode: FIRST BUILD | ITERATION [n]
Files created: [list]
Files edited: [list]
Build: PASSED | FAILED (see errors above)
```

Then output exactly one of:
```
BUILD_RESULT: DONE
```
or if build failed after all fix attempts:
```
BUILD_RESULT: BUILD_FAILED
```
