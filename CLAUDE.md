# Fullstack Expert: React/Next.js · Python · Node.js/NestJS — typed, linted, production-ready.

## CORE RULES
- Private repos: `gh repo create --private`
- Format before commit: Black / Prettier / ESLint
- Security `.gitignore` on every repo
- NestJS: CLI only, never hand-write boilerplate
- Playwright: `browser_run_code` only, never `browser_snapshot`

## PYTHON
- Functional-first, PEP 8, 88-char lines, 4-space indent
- Type hints mandatory on all functions (`str | None`, Python 3.10+)
- Prefer comprehensions over `map`/`filter` + lambda
- Immutability: `tuple`, `frozenset`, `dataclass(frozen=True)`
- Specific exceptions, early returns, no bare `except:`
- Data containers: `dataclass` or `NamedTuple`, never plain `class`

Tools: `black .` · `ruff check .` · `mypy src/` · `pytest`
Config: line-length=88, `ruff select=["E","F","I"]`, `mypy strict=true`

## NODE.JS / NESTJS
ESM, strict TypeScript, ESLint + Prettier enforced on commit.

```bash
npx @nestjs/cli new project --package-manager npm --skip-git --strict
nest g module name --no-spec
nest g service name --no-spec --flat
nest g resource name --no-spec
```

MCP tool pattern:
```typescript
@Tool({ name: 'x', description: '...', parameters: z.object({ p: z.string() }) })
async myTool({ p }: { p: string }) {
  return { content: [{ type: 'text', text: JSON.stringify(result) }] };
}
```

## PLAYWRIGHT
Selectors: `getByRole('button',{name:'Write something...'})` · `getByRole('textbox')` · `getByRole('button',{name:'Post',exact:true})`

Batch: loop urls → `goto(domcontentloaded)` → click Write → `fill(textbox)` → click Post(exact) → `waitForTimeout(2000+rand*3000)`

## REACT / NEXT.JS
TypeScript strict, ESLint + Prettier, App Router (Next.js 14+).

### Conventions
- Components: named exports only, no default exports except `page.tsx` / `layout.tsx`
- File structure: feature-based (`/features/auth/`, `/features/dashboard/`)
- State: local → Zustand → React Query (server state). Never Redux unless pre-existing.
- Data fetching: React Query (`useQuery`/`useMutation`) on client; `fetch` with `cache` options on server components
- Forms: React Hook Form + Zod schema validation (reuse schema for API types)
- Styling: Tailwind CSS utility-first; no inline styles; no CSS modules unless required
- Images: always `next/image`, never `<img>`
- Links: always `next/link`, never `<a>` for internal routes
- Env: server vars in `process.env.VAR`, client vars prefixed `NEXT_PUBLIC_`

### Performance rules
- Server Components by default; add `"use client"` only when needed (interactivity, browser APIs)
- Dynamic imports (`next/dynamic`) for heavy components
- Route groups `(group)/` to co-locate without affecting URL
- Suspense boundaries around async data fetches

### Testing
- Unit: Jest + React Testing Library (`@testing-library/react`)
- E2E: Playwright (`browser_run_code` only)
- Test files co-located: `Component.test.tsx` next to `Component.tsx`
- Queries: `getByRole` > `getByText` > `getByTestId` (never use index-based queries)

### Scaffolding
```bash
npx create-next-app@latest project --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
```

### Code review checklist
- No `any` types — use `unknown` + type guards
- No prop drilling >2 levels — extract context or lift to Zustand
- Async errors handled (loading/error states visible to user)
- No hardcoded strings — i18n-ready keys or constants file
- Accessible: semantic HTML, ARIA roles where needed, keyboard navigable

## .gitignore
`.env` `.env.*` `*.pem` `*.key` `credentials.json` `node_modules/` `dist/` `.next/` `build/` `__pycache__/` `.venv/`
