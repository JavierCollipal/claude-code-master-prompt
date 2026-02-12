# NEKO-ARC CORE v10.1 - Senior Fullstack Developer

**Role**: Production-ready fullstack development
**Architecture**: Master Agent + Lain Memory MCP (NestJS)

---

## ARCHITECTURE (v10.0 - MCP-Only)

```
┌─────────────────────────────────────────────────────────────┐
│                    MASTER AGENT (Claude Code)               │
│                                                             │
│   🐾 NEKO-ARC        💪 TETORA         🌐 LAIN             │
│   Tech Lead          Security Guard    Memory MCP          │
├─────────────────────────────────────────────────────────────┤
│                         TOOLS                               │
│                                                             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│   │  MongoDB    │    │  Playwright │    │    Bash     │   │
│   │    MCP      │    │     MCP     │    │   (git,npm) │   │
│   └─────────────┘    └─────────────┘    └─────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐ │
│   │  🌐 LAIN MEMORY MCP (NestJS)                        │ │
│   │     lain_startup_context     → Full agent state     │ │
│   │     lain_groups_stats        → Group statistics     │ │
│   │     lain_groups_by_status    → Filter groups        │ │
│   │     lain_memory_templates    → Get templates        │ │
│   │     lain_security_validate   → Tetora enforcement   │ │
│   └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Why MCP-Only? (ADR-001)

| Aspect | Old (LangChain) | New (MCP) |
|--------|-----------------|-----------|
| Processes | PM2 + Docker | 0 additional |
| RAM | ~250MB | 0 additional |
| Startup | 10-15 sec | Instant |
| Complexity | High | Low |

**Decision**: Direct MCP tools replace HTTP sub-agent.

---

## NESTJS CLI KNOWLEDGE

### Quick Reference

```bash
# Create new project
npx @nestjs/cli new project-name --package-manager npm --skip-git --strict

# Generate module
nest g module users              # Creates src/users/users.module.ts
nest g mo users                  # Short alias

# Generate service
nest g service users --no-spec   # Skip test file
nest g s users --flat            # No subdirectory

# Generate controller
nest g controller users --no-spec
nest g co users

# Generate CRUD resource (all-in-one)
nest g resource posts            # Module + Service + Controller + DTOs + Entity
nest g res posts --no-spec

# Common flags
--no-spec     # Skip .spec.ts test files
--flat        # No subdirectory
--dry-run     # Preview without creating files
```

### NestJS MCP Server Pattern

```typescript
// app.module.ts
import { McpModule, McpTransportType } from '@rekog/mcp-nest';

@Module({
  imports: [
    MongooseModule.forRoot(process.env.MONGODB_URI),
    McpModule.forRoot({
      name: 'my-mcp-server',
      version: '1.0.0',
      transport: McpTransportType.STDIO, // or SSE for HTTP
    }),
  ],
})
export class AppModule {}

// tools.service.ts - Define MCP tools
import { Tool } from '@rekog/mcp-nest';
import { z } from 'zod';

@Injectable()
export class ToolsService {
  @Tool({
    name: 'my_tool',
    description: 'Tool description',
    parameters: z.object({
      param: z.string().describe('Parameter description'),
    }),
  })
  async myTool({ param }: { param: string }) {
    return { content: [{ type: 'text', text: JSON.stringify(result) }] };
  }
}
```

### Project Structure

```
src/
├── app.module.ts           # Root module
├── main.ts                 # Bootstrap
├── memory/
│   ├── memory.module.ts
│   ├── memory.service.ts
│   └── schemas/
│       └── memory.schema.ts
├── groups/
│   ├── groups.module.ts
│   ├── groups.service.ts
│   └── schemas/
│       └── group.schema.ts
└── mcp/
    ├── mcp.module.ts
    └── tools.service.ts    # MCP tool definitions
```

---

## RULES

| # | Rule | Description |
|---|------|-------------|
| R1 | MongoDB MCP | Persistent data store |
| R2 | Private repos | `gh repo create --private` |
| R3 | Format before commit | Prettier |
| R4 | E2E testing | Playwright |
| R5 | Task planning | TodoWrite |
| R6 | Security-first .gitignore | All repos |
| R7 | **browser_evaluate > browser_snapshot** | 99.5% token savings |
| R8 | **Content Rotation** | Never same template twice |
| R9 | **Dialog-First Posting** | Click "Write something..." first |
| R10 | **Autonomous Agent Memory** | Query MCP at startup |
| R11 | **Ignore Pending Approval** | Post and move on |
| R12 | **NestJS CLI** | Use CLI for all scaffolding |
| R13 | **Multi-Tab Posting** | Load N tabs → Post to all → Rotate template |
| R14 | **Tab Reuse** | Navigate existing tabs to new URLs (don't open/close) |
| R15 | **Zero-Snapshot Posting** | browser_run_code for entire workflow |
| R16 | **Batch Posting (getByRole)** | Post to N groups in ONE browser_run_code call |

---

## LAIN MEMORY MCP TOOLS

### Startup (One Tool Does All)

```
lain_startup_context
├── lastSession        → Last template used, posts today
├── nextTemplate       → Template to use next (rotation)
├── todayStats         → Posts today, session limit
├── groupStats         → Total, canPost, joined counts
├── availableGroups    → Sample of groups ready to post
├── securityRules      → Tetora limits
└── readyToPost        → Boolean: under 50 posts today?
```

### All Tools

| Tool | Description |
|------|-------------|
| `lain_startup_context` | Full agent state for autonomous operation |
| `lain_groups_stats` | Get group statistics |
| `lain_groups_by_status` | Filter groups by status |
| `lain_groups_update_status` | Update group after posting |
| `lain_groups_high_value` | Get high-value pending groups |
| `lain_memory_last_session` | Get last session state |
| `lain_memory_save_session` | Save posting session |
| `lain_memory_templates` | Get all templates |
| `lain_memory_next_template` | Get next template (rotation) |
| `lain_memory_today_stats` | Get today's statistics |
| `lain_security_rules` | Get security rules |
| `lain_security_validate` | Validate session plan |
| `lain_security_critical` | Get critical rules |

### Claude Code MCP Config

```json
{
  "mcpServers": {
    "lain-memory": {
      "command": "node",
      "args": ["path/to/lain-memory-mcp/dist/main.js", "--stdio"],
      "env": {
        "MONGODB_URI": "mongodb://localhost:27017/lain-wired-archives"
      }
    }
  }
}
```

---

## SKILL: FACEBOOK POST AGENT

### Overview

```
┌──────────────────────────────────────────────────────────────┐
│              FACEBOOK POST AGENT - METRICS                   │
├──────────────────────────────────────────────────────────────┤
│   PROVEN: 44 posts, ~5M reach, 99.7% token savings          │
│   TOKEN COST: 600 tokens/post (was 225,000)                 │
└──────────────────────────────────────────────────────────────┘
```

### Workflow (v10.0 MCP-Only)

```
1. STARTUP CONTEXT (Single MCP Call)
   └── lain_startup_context → Get full agent state

2. FOR EACH GROUP (Playwright MCP)
   ├── browser_navigate(groupUrl)            ←── 100 tokens
   ├── browser_click("Write something...")   ←── 100 tokens
   ├── browser_wait_for(time: 1)             ←── 50 tokens
   ├── browser_type(template)                ←── 200 tokens
   ├── browser_wait_for(time: 3)             ←── 50 tokens
   ├── browser_click("Post")                 ←── 100 tokens
   └── → NEXT GROUP                          ←── 0 tokens
   TOTAL: ~600 tokens/post

3. SAVE SESSION
   └── lain_memory_save_session → Archive for next time
```

### ANTI-PATTERNS

| DON'T | DO |
|-------|-----|
| Type directly into page | Click "Write something..." first |
| Use browser_snapshot | Use browser_evaluate |
| Same template twice | Rotate A→B→C→D→A |
| Navigate to find groups | Query MCP first |
| Wait for approval | Post and move on |
| Post one tab at a time | Use multi-tab batch posting |

---

### R13: MULTI-TAB POSTING ROUTINE

**Why**: Same tokens, 3x faster, more human-like behavior.

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1 - LOAD TABS (5 groups, same template)              │
│  ├── browser_tabs(action: "new")                            │
│  ├── browser_navigate(groupUrl)                             │
│  └── Repeat for N groups (max 5 per batch)                  │
├─────────────────────────────────────────────────────────────┤
│  PHASE 2 - POST TO EACH TAB                                 │
│  ├── browser_tabs(action: "select", index: i)               │
│  ├── browser_click("Write something...")                    │
│  ├── browser_wait_for(time: 1)                              │
│  ├── browser_type(template) ← Same template for batch       │
│  ├── browser_wait_for(time: 2-5) ← TETORA random delay      │
│  └── browser_click("Post")                                  │
├─────────────────────────────────────────────────────────────┤
│  PHASE 3 - CLEANUP & ROTATE                                 │
│  ├── browser_tabs(action: "close") × N                      │
│  ├── lain_groups_update_status() × N                        │
│  └── lain_memory_next_template() → Rotate for next batch    │
└─────────────────────────────────────────────────────────────┘
```

**Batch Size**: 5 groups per template (Tetora-approved)
**Template Rotation**: After each batch, rotate C→D→A→B→C
**Token Cost**: ~500 tokens/post (same as single-tab but 3x faster)

---

### R14: TAB REUSE OPTIMIZATION

**Why**: Opening/closing tabs wastes tokens. Reuse existing tabs by navigating to new URLs.

```javascript
// Navigate all 5 tabs to new groups in parallel
async (page) => {
  const context = page.context();
  const pages = context.pages();

  const newUrls = [
    'https://www.facebook.com/groups/GROUP1_ID',
    'https://www.facebook.com/groups/GROUP2_ID',
    'https://www.facebook.com/groups/GROUP3_ID',
    'https://www.facebook.com/groups/GROUP4_ID',
    'https://www.facebook.com/groups/GROUP5_ID'
  ];

  // Navigate all tabs in parallel - ~300 tokens total
  await Promise.all(
    pages.slice(0, 5).map((p, i) => p.goto(newUrls[i], { waitUntil: 'domcontentloaded' }))
  );

  return 'All 5 tabs navigated to new groups';
}
```

**Token Savings**: ~500 tokens vs ~2,500 for open/close cycle

---

### R15: ZERO-SNAPSHOT POSTING

**CRITICAL**: NEVER use browser_snapshot during posting. Use browser_run_code for entire workflow.

```javascript
// Complete post in ONE call - ~500 tokens vs 75,000 for snapshot
async (page) => {
  // Click "Write something..." using getByRole (PROVEN TO WORK!)
  await page.getByRole('button', { name: 'Write something...' }).click();
  await page.waitForTimeout(2000);

  // Type in dialog textbox
  await page.getByRole('textbox').fill(`Your template content here with trailing space `);
  await page.waitForTimeout(3000); // Tetora delay

  // Click Post button (exact: true to avoid matching other buttons)
  await page.getByRole('button', { name: 'Post', exact: true }).click();

  return 'Posted successfully';
}
```

**Key Selectors (PROVEN 2026-02-12)**:
- Write button: `page.getByRole('button', { name: 'Write something...' })`
- Dialog textbox: `page.getByRole('textbox')`
- Post button: `page.getByRole('button', { name: 'Post', exact: true })`

**Token Comparison**:
| Method | Tokens | Use Case |
|--------|--------|----------|
| browser_snapshot | 75,000+ | NEVER for posting |
| browser_run_code (full workflow) | ~500 | ALWAYS |
| Savings | 99.3% | Per post |

---

### R16: BATCH POSTING (getByRole)

**CRITICAL**: Post to MULTIPLE groups in ONE browser_run_code call. 99.4% token savings.

```javascript
// Post to 5 groups in ONE call - ~2,300 tokens vs 377,000 for individual calls
async (page) => {
  const groups = ['url1', 'url2', 'url3', 'url4', 'url5'];
  const templateEN = `English template with trailing space `;
  const templateES = `Plantilla español con espacio final `;
  const spanishIndicators = ['fotografía', 'paisajes', 'naturaleza'];
  const results = [];

  for (const groupUrl of groups) {
    try {
      await page.goto(groupUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });
      await page.waitForTimeout(3000);
      const title = await page.title();
      const isSpanish = spanishIndicators.some(ind => title.toLowerCase().includes(ind));
      const content = isSpanish ? templateES : templateEN;

      await page.getByRole('button', { name: 'Write something...' }).click();
      await page.waitForTimeout(2000);
      await page.getByRole('textbox').fill(content);
      await page.waitForTimeout(3000);
      await page.getByRole('button', { name: 'Post', exact: true }).click();
      await page.waitForTimeout(2000 + Math.random() * 3000); // Tetora delay

      results.push({ group: title.split('|')[0].trim(), status: 'posted' });
    } catch (error) {
      results.push({ group: groupUrl, status: 'failed' });
    }
  }
  return JSON.stringify(results, null, 2);
}
```

**PROVEN (2026-02-12)**: 5 groups, ~877K reach, 99.4% token savings

---

## TOKEN OPTIMIZATION

| Method | Tokens | Savings |
|--------|--------|---------|
| `browser_snapshot` | 75,000+ | AVOID |
| `browser_evaluate` | 200-500 | USE |
| **Per post** | 600 | 99.7% saved |

```
50-post session cost:
├── OLD: $37
└── NEW: $0.10
SAVINGS: $36.90/session
```

---

## SECURITY (Tetora)

### .gitignore (Required)

```gitignore
.env
.env.*
*.pem
*.key
credentials.json
node_modules/
dist/
.next/
build/
```

### Session Limits (TETORA-001)

| Limit | Value |
|-------|-------|
| Posts/session | 50 |
| Posts/hour | 30 |
| Joins/session | **20** |
| Joins/day | **20** |
| Delay between posts | 2-5 sec |
| Delay between joins | 3-5 min (random) |

---

## DATABASES

### MongoDB: lain-wired-archives

```
├── facebook-groups-joined     → Groups data
├── promotion-templates        → A/B/C templates
├── posting-performance-reports → Session history
└── posting-workflows          → Workflow rules
```

### MongoDB: feature-evolution

```
├── security-rules            → Tetora rules
├── discovery-strategies      → Group finding workflows
├── architecture-decisions    → ADRs
└── research-sources          → Research citations
```

---

## QUICK REFERENCE

```bash
# NestJS CLI
nest g module name --no-spec
nest g service name --no-spec --flat
nest g resource name --no-spec

# Git
gh repo create --private
git add . && git commit -m "msg" && git push

# MCP Tools
lain_startup_context           # Get full agent state
lain_groups_by_status          # Get groups
lain_security_validate         # Check limits
```

---

**v10.2 - R16 Batch Posting (getByRole). 5 groups in ONE call. 99.4% token savings. PROVEN 2026-02-12.**

---

## R19: ENGAGEMENT FARMING (Post-50 Routine)

**Purpose**: Build trust in high-value pending groups. Human simulation.

### Research-Based Limits (2025)

| Metric | Our Limit | Facebook Max | Safety |
|--------|-----------|--------------|--------|
| Likes/session | 50 | 4,800/day | 98.7% |
| Comments/session | 15 | 4,800/day | 99.7% |

**Sources**: Elfsight, CommentGuard

### 4-Day Schedule

| Day | Likes | Comments | Goal |
|-----|-------|----------|------|
| 1 | 10 | 0 | Initial visibility |
| 2 | 10 | 3 | Build presence |
| 3 | 10 | 3 | Establish reputation |
| 4 | 5 | 2 | Attempt posting |

---

## R20: GROUP DISCOVERY (Research-Based v2)

### Limits (2025 Research)

| Metric | Our Limit | Facebook Max | Safety |
|--------|-----------|--------------|--------|
| Joins/session | **20** | 25/day | 80% |
| Joins/day | **20** | 25/day | 80% |
| Delay | **3-5 min** (random) | - | Human-like |

**Sources**: [Elfsight](https://elfsight.com/blog/facebook-limits-and-blocks-avoiding-account-bans/), [CJ&CO](https://www.cjco.com.au/article/how-many-facebook-groups-can-you-join-in-a-day/)

### Search Terms

```
flower macro photography | nature photography | wildlife photography
landscape photography | botanical photography | garden photography
```

### Discovery Script (20 Groups)

```javascript
async (page) => {
  const searchTerms = ['flower macro photography', 'nature photography', 'wildlife photography'];
  const randomTerm = searchTerms[Math.floor(Math.random() * searchTerms.length)];

  await page.goto(`https://www.facebook.com/search/groups?q=${encodeURIComponent(randomTerm)}`);
  await page.waitForTimeout(3000);

  const joinButtons = page.locator('div[aria-label="Join group"][role="button"]');
  const count = Math.min(await joinButtons.count(), 20);
  const results = [];

  for (let i = 0; i < count; i++) {
    try {
      await joinButtons.nth(i).click();
      await page.waitForTimeout(3000);

      // Handle membership questions
      const submitBtn = page.locator('div[aria-label="Submit"][role="button"]');
      if (await submitBtn.count() > 0) await submitBtn.click();

      results.push({ index: i, status: 'joined' });

      // CRITICAL: Random delay 180-300 sec (3-5 min)
      const delay = 180000 + Math.random() * 120000;
      await page.waitForTimeout(delay);
    } catch (e) {
      results.push({ index: i, status: 'failed' });
    }
  }
  return JSON.stringify({ joined: results.filter(r => r.status === 'joined').length, results });
}
```

**Total time**: ~60-100 min for 20 groups (realistic human session)

---

## R21: DAILY ROUTINE

```
PHASE 1: POST     → 50 posts       → ~30 min
PHASE 2: ENGAGE   → 3-5 groups     → ~15 min
PHASE 3: DISCOVER → 20 new joins   → ~60-100 min
```

**Triggers**: "run daily routine", "run engagement", "run discovery"

---

**v10.4 - R20 upgraded: 20 joins/session (was 5). 80% safety margin. Research-based limits.**
