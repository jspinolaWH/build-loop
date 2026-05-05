# build-loop

Autonomous build system for the WasteHero platform. Give it a list of requirements. Walk away. Come back to working code.

---

## What it does

build-loop reads a `prd.json` file of product requirements and builds them end-to-end with zero human input:

1. **Scans the codebase** — extracts architecture, conventions, and existing components so no agent ever invents a pattern that already exists
2. **Analyses requirement dependencies** — maps which requirements need to be built before others and finds any partial implementations already in the codebase
3. **Loops through each requirement** — designs an implementation plan, builds BE and FE, then verifies against the acceptance criteria; if gaps remain, it loops back to fix them (up to a configurable max)
4. **Writes a morning summary** — `loop-summary.md` tells you what passed, what needs review, and exactly where to test each feature manually

See `build-loop-flow.html` for a full visual diagram of the flow.

---

## Who's involved

| Person | Role |
|---|---|
| **Product / Engineer** | Shapes requirements with `/spec-shaping`, writes `prd.json`, runs `/build-loop` |
| **Oliver** (designer) | Maintains the brand skill and UX patterns — feeds into every UI build automatically |

---

## Quick start

### 1. Shape requirements

Run `/spec-shaping` in Claude Code to turn a Linear ticket or rough idea into a structured spec with acceptance criteria, squad routing, and UX intent.

### 2. Write prd.json

Create `build-loop/prd.json` in your project root. See `prd.example.json` for the full schema:

```json
[
  {
    "id": "REQ-001",
    "summary": "One-line description of the requirement",
    "squad": "nexus",
    "priority": 0,
    "acceptance_criteria": [
      "Specific, testable criterion",
      "Another criterion"
    ],
    "skills": ["nexus", "ux-patterns", "testing"],
    "passes": false,
    "needs_review": false,
    "iteration_count": 0,
    "notes": ""
  }
]
```
**PROMPT TO USE ON CLAUDE WEB**
```
Pull all issues from this Jira release and format them as a prd.json file.

Release URL: [PASTE YOUR JIRA RELEASE URL HERE]

---

FIELD MAPPING:

- `id`: Jira issue key (e.g. "PD-427")
- `summary`: Jira issue summary, one line, no numbering prefix (e.g. strip "3.4.5 " from the front)
- `squad`: derive from component/label, map to one of: nexus, forge, compass, ledger, beacon, bridge, access
- `priority`: assign based on dependency order — requirements that other requirements build on get lower numbers. Use 0 for foundational data models/APIs, 1 for core business logic, 2 for UI features, 3 for reporting/edge cases. No two related requirements should share the same priority.
- `acceptance_criteria`: see cleaning rules below
- `skills`: always ["{squad}", "ux-patterns"] using the squad value you derived
- `passes`: false
- `needs_review`: false
- `iteration_count`: 0
- `notes`: ""

---

ACCEPTANCE CRITERIA CLEANING RULES — apply all of these before writing:

1. STRIP all markdown formatting: remove **bold**, ### headers, and any other markdown syntax. Keep only plain text.
2. SKIP any entry that is just a section header — i.e. a line ending with ":" and containing no actual requirement (e.g. "Customer-specific bundling rules:" → skip it).
3. SKIP any entry that is a single dash "—" or "–" or "-" or empty/whitespace only.
4. SKIP any entry that is a fragment of 1-3 words with no verb (e.g. "A customer", "Date", "Municipality" alone on a line → skip unless it is clearly a field name in a list of required fields for a data record).
5. CONVERT incomplete sentences into full testable statements. Example: "Missing billing address" → "The system prevents invoice finalisation if the billing address is missing and displays an error to the user."
6. MERGE broken sentences: if a line ends with a colon and the next line is its continuation, join them into one criterion.
7. If after cleaning, a requirement has ZERO valid acceptance criteria, set `needs_review: true` and `notes: "No testable acceptance criteria found in Jira — needs manual review"` instead of leaving it with an empty array.

---

Output only a valid JSON array, nothing else, sorted by priority ascending.

```
**Priority:** lower number = built first (before graph analysis re-sorts by dependency).

**Skills:** which skill files to load during design. Domain skills (`nexus`, `ledger`, etc.) are auto-resolved. `ux-patterns` loads Oliver's interaction patterns. `testing` loads test conventions.

### 3. Run the loop

Drop the BE and FE repos inside your project root, then:

```
/build-loop
```

Or with a custom iteration limit per requirement (default: 4):

```
/build-loop 6
```

The loop is fully resumable — if interrupted, re-run `/build-loop` and it picks up from `build-loop/state.json`.

---

## Oliver's designer loop

Oliver runs a parallel track that feeds directly into every UI build. He does not need to be present when the loop runs — his work is baked in automatically.

**Oliver's files:**

| File | What it contains |
|---|---|
| `.claude/skills/wastehero-brand/wastehero-design-system.md` | All design tokens synced from Figma — colors, typography, spacing, radius, shadows |
| `.claude/skills/wastehero-brand/SKILL.md` | Rules for applying the tokens: dark mode patterns, component templates, icon usage, copy voice |
| `build-loop/skills/ux-patterns.md` | Interaction patterns: nav, tables, forms, modals, loading states, empty states |

**How enforcement works:**

A Claude Code hook (`brand-check.sh`) fires before every `.jsx` or `.css` file edit during the build phase. If the brand skill hasn't been loaded yet, the hook blocks and loads it first. The build agent cannot write any UI code without reading Oliver's design system.

**Oliver's workflow:**
1. Update the Figma design system (file key `SoMkCuI8zdqg7bo9hzeYmp`)
2. Sync the new tokens into `wastehero-design-system.md`
3. Update `SKILL.md` if new patterns or component rules were added
4. Update `ux-patterns.md` with any new interaction patterns

The next build run picks it up. No code changes needed.

---

## File structure

```
build-loop/                    ← this repo
├── commands/                  ← Claude Code slash commands (the engine)
│   ├── build-loop.md          ← orchestrator — reads prd.json, drives the loop
│   ├── bl-context-scan.md     ← scans BE + FE codebase, writes architecture context
│   ├── bl-graph-analysis.md   ← maps requirement dependencies, sorts build order
│   ├── bl-design.md           ← writes implementation plan for one requirement
│   ├── bl-build.md            ← implements the code from a plan or gap report
│   └── bl-gap-check.md        ← verifies code against acceptance criteria
│
├── skills/                    ← skill files loaded during design phase
│   ├── ux-patterns.md         ← Oliver's interaction patterns (fill this in)
│   └── testing.md             ← test structure and coverage rules
│
├── .claude/                   ← Claude Code project configuration
│   ├── settings.json          ← hooks config (wires brand-check.sh)
│   ├── hooks/
│   │   └── brand-check.sh     ← enforces brand skill before every UI edit
│   └── skills/wastehero-brand/
│       ├── SKILL.md           ← brand rules for Claude (Oliver-maintained)
│       └── wastehero-design-system.md  ← design tokens from Figma (Oliver-maintained)
│
├── prd.example.json           ← example PRD schema
├── build-loop-flow.html       ← visual diagram of the full flow
│
├── wastehero_backend_v1-master/   ← Django/Python BE (placed here for the loop)
└── wastehero_frontend-development/ ← React/TS FE (placed here for the loop)
```

**Files written by the loop at runtime** (inside your project's `build-loop/` folder):

```
build-loop/
├── prd.json          ← updated as requirements pass/fail
├── state.json        ← current phase + iteration (enables resume)
├── req-graph.json    ← dependency order + coverage tags (from graph analysis)
├── loop.log          ← timestamped log of every action
├── loop-summary.md   ← final report (your morning briefing)
├── context/
│   ├── be-architecture.md   ← extracted BE conventions
│   └── fe-architecture.md   ← extracted FE conventions
├── plans/
│   └── REQ-001.md    ← implementation plan per requirement
└── gaps/
    └── REQ-001.md    ← gap report per requirement (updated each iteration)
```

---

## Skills system

Skills are markdown files that get loaded into the build agent's context before it designs or builds. They encode knowledge that isn't derivable from the codebase itself — business rules, design patterns, test conventions.

| Skill | Location | Maintained by | When loaded |
|---|---|---|---|
| Domain skills | `~/.claude/commands/references/domains/` | Product / Engineers | Auto-loaded from `squad` field in prd.json |
| Architecture | `build-loop/context/` | Auto-generated by bl-context-scan | Every requirement |
| WasteHero Brand | `.claude/skills/wastehero-brand/` | Oliver | Every `.jsx`/`.css` edit (hook-enforced) |
| UX Patterns | `build-loop/skills/ux-patterns.md` | Oliver | When `ux-patterns` is in requirement's `skills[]` |
| Testing | `build-loop/skills/testing.md` | Engineers | When `testing` is in requirement's `skills[]` |

---

## Configuration

The hook is configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/brand-check.sh"
          }
        ]
      }
    ]
  }
}
```

The hook is silent for non-UI files. It only activates on `.jsx` and `.css` edits, and only fires once per session (subsequent edits in the same session skip it after the skill is loaded).

---

## Loop outputs

After the loop completes, `build-loop/loop-summary.md` contains:

- **✅ Built & verified** — what was built, what changed, and exactly where to manually test it (route → action → expected result)
- **⚠️ Needs review** — requirements that hit max iterations or failed pre-flight, with the last gap report and reason
- **Counts** — total passing, flagged, still failing
