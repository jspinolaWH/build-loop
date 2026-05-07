---
description: Scans BE and FE codebases to extract architecture, packages, naming conventions, and patterns. Writes context files used by all build agents. Run once per session by the build-loop orchestrator.
allowed-tools: [Read, Write, Glob, Grep, Bash]
---

# BL Context Scan

You are an autonomous codebase scanner. You scan the BE and FE codebases, extract all conventions and patterns, and write context files to disk. Every subsequent build agent reads these files. You do not ask questions. You do not skip anything.

## Setup

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

Create output folder:
```bash
mkdir -p $PROJECT_ROOT/build-loop/context
```

---

## Step 1 — Detect Codebase Roots

Search `$PROJECT_ROOT` for BE and FE roots using these heuristics in order (stop at first match per layer):

**Backend:**
1. Look for `src/main/java` → Spring Boot (Java/Kotlin)
2. Look for `requirements.txt` or `pyproject.toml` alongside `*.py` files → Python
3. Look for `package.json` with `"main"` or `"start"` script pointing to a server file → Node.js backend

**Frontend:**
1. Look for `package.json` containing `"next"` in dependencies → Next.js
2. Look for `src/` with `index.html` and `package.json` containing `"react"` or `"vite"` → React/Vite
3. Look for `package.json` containing `"vue"` → Vue

Store detected roots as `BE_ROOT` and `FE_ROOT`. If a root is not found, note "not detected" in the context file and do your best.

---

## Step 2 — Scan Backend

For the detected BE_ROOT, extract:

### 2a. Framework & Language
- What framework is used (Spring Boot, FastAPI, Express, etc.)
- Language and version if detectable from pom.xml, pyproject.toml, or package.json

### 2b. Package / Dependency List
- Read the dependency file (pom.xml, requirements.txt, pyproject.toml, package.json)
- Extract ALL dependencies with versions
- Note which ones are for: HTTP, database, auth, testing, utilities

### 2c. Project Structure
- Map the folder structure (top 3 levels)
- Identify the pattern: controller → service → repository, or routes → handlers → models, etc.
- Note the package/module naming convention

### 2d. Naming Conventions
- Class/file naming (PascalCase, snake_case, camelCase)
- Method naming style
- DTO / model naming patterns (e.g. `XxxDto`, `XxxRequest`, `XxxResponse`)
- Repository/service naming patterns (e.g. `XxxService`, `XxxRepository`)

### 2e. API Patterns
- Base path prefix (e.g. `/api/v1/`)
- Authentication method (JWT header, session cookie, API key)
- Response envelope shape (e.g. `{ data: ..., meta: ... }` or raw objects)
- Error response shape
- Pagination pattern if present

### 2f. Database
- ORM or query builder used
- Migration tool if present
- Entity/model base class if any

### 2g. Testing Conventions
- Test framework used
- Test file location pattern (e.g. `src/test/java/...`, `tests/`, `__tests__/`)
- Naming pattern for test classes/files

---

## Step 3 — Scan Frontend

For the detected FE_ROOT, extract:

### 3a. Framework & Build Tool
- Framework (Next.js, React+Vite, Vue, etc.)
- Build tool and version
- TypeScript or JavaScript

### 3b. Package / Dependency List
- Read package.json
- Extract ALL dependencies and devDependencies
- Categorise: UI component library, state management, routing, HTTP client, forms, testing, utilities

### 3c. Folder Structure
- Map top 3 levels
- Identify: where pages/routes live, where components live, where API calls live, where types live, where hooks live

### 3d. Routing Pattern
- File-based or config-based routing
- Route naming convention
- How protected routes are handled

### 3e. Component Conventions
- File naming (PascalCase.tsx, kebab-case.tsx, etc.)
- Default export or named export
- Props type naming (e.g. `XxxProps`)
- Where component styles live (CSS modules, Tailwind, styled-components, etc.)

### 3f. State Management
- What is used (Zustand, Redux, React Query, Context, etc.)
- Where stores / context providers live
- Pattern for async data fetching

### 3g. API Call Pattern
- HTTP client used (axios, fetch, react-query, etc.)
- Where API functions live (e.g. `src/api/`, `src/services/`)
- Auth token injection pattern (interceptor, wrapper, etc.)
- Base URL configuration

### 3h. Existing UI Components
- List any shared/common component library files found in `components/ui/`, `components/common/`, or equivalent
- Note which ones exist: Button, Modal, Table, Form, Input, Select, Toast, etc.
- Note the import paths for these

### 3i. Testing Conventions
- Test framework (Jest, Vitest, Cypress, Playwright, etc.)
- Test file location pattern
- Testing utilities used (Testing Library, etc.)

---

## Step 4 — Write Context Files

Write `$PROJECT_ROOT/build-loop/context/be-architecture.md`:

```markdown
# Backend Architecture Context
**Generated:** [ISO timestamp]
**Root:** [BE_ROOT]
**Framework:** [framework + language]

## Dependencies
[full list with versions and category tags]

## Project Structure
[folder map]

## Naming Conventions
[conventions extracted]

## API Patterns
[base path, auth, response shape, error shape, pagination]

## Database
[ORM, migration tool, entity base]

## Testing
[framework, file locations, naming]
```

Write `$PROJECT_ROOT/build-loop/context/fe-architecture.md`:

```markdown
# Frontend Architecture Context
**Generated:** [ISO timestamp]
**Root:** [FE_ROOT]
**Framework:** [framework + build tool]

## Dependencies
[full list categorised]

## Folder Structure
[folder map]

## Routing
[pattern, naming, protected routes]

## Component Conventions
[naming, exports, props, styles]

## State Management
[tool, pattern, locations]

## API Call Pattern
[client, location, auth injection, base URL]

## Existing UI Components
[list with import paths]

## Testing
[framework, locations, utilities]
```

---

## Step 5 — Detect dev server configuration

This information is used by `bl-fe-test` to start and health-check servers.

### 5a. Frontend dev server

- Read `package.json` `scripts` — find `"dev"` or `"start:app"` command
- Check for a `vite.config.*` or `next.config.*` for the server port
  - Vite: look for `server.port` in config; fall back to env var `PORT`; default 3000
  - Next.js: default 3000
- Health check URL: `http://localhost:[FE_PORT]/` — expect 200 or 304

### 5b. Backend dev server

- **Django**: command is `python manage.py runserver [BE_PORT]`
  - Check `settings/local.py` or `.env` for the port; default 8000
  - Health check: `POST http://localhost:[BE_PORT]/graph-api/ {"query":"{ __typename }"}` — expect 200
- **FastAPI/Uvicorn/Daphne**: check for `daphne`, `uvicorn`, or `hypercorn` in start scripts; detect port from the script
- **Node**: `npm start` or `node server.js`; default 3001

### 5c. GraphQL path

- Look for the base GraphQL endpoint path in the BE URL config or Django urls.py
- Common pattern for this project: `/graph-api/`
- Record as `GQL_PATH`

### 5d. Append to fe-architecture.md

Append a new section at the bottom of `$PROJECT_ROOT/build-loop/context/fe-architecture.md`:

```markdown
## Dev Server

- **Start command:** yarn dev
- **Port:** [FE_PORT]
- **Health check URL:** http://localhost:[FE_PORT]/
```

### 5e. Append to be-architecture.md

Append a new section at the bottom of `$PROJECT_ROOT/build-loop/context/be-architecture.md`:

```markdown
## Dev Server

- **Start command:** python manage.py runserver [BE_PORT]
- **Port:** [BE_PORT]
- **GraphQL path:** [GQL_PATH]
- **Health check:** POST http://localhost:[BE_PORT][GQL_PATH] {"query":"{ __typename }"}
```

---

## Output

After writing both files, output exactly:
```
CONTEXT_SCAN_RESULT: DONE
```

If a codebase root could not be detected for either BE or FE, still write the file with what was found, note the detection failure inside the file, and still output `DONE`. Never stop the loop because a root was not found.

If a file cannot be read due to permissions or size, note it as "unreadable" and continue.
