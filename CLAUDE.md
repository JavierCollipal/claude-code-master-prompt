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
| R22 | **Rate Limit Tracking** | Log ALL rate limits to `rate-limit-events` collection |
| R23 | **Rate Limit Recovery** | When limited: Farm engagement on high-member groups |
| R24 | **Human Behavior Optimization** | Scroll before action, vary timing, meaningful comments |
| R25 | **FRESH GROUPS ONLY** | NEVER post to groups with pending approval - wastes routines |
| R26 | **Highest Members First** | Sort fresh groups by member count DESC before posting |
| R27 | **Batch Preparation Routine** | Query Lain Memory for 10+ groups BEFORE posting, multi-tab |

---

## R27: BATCH PREPARATION ROUTINE (MANDATORY)

**PROBLEM**: Starting posts without prepared groups = wasted tokens on group queries mid-session.

### MANDATORY STARTUP SEQUENCE

```
BEFORE ANY POSTING SESSION:

1. lain_operation_fresh_posting(limit: 20)
   Returns: Fresh groups sorted by members DESC
   Excludes: pending_approval_post, posted_today

2. lain_memory_next_template()
   Returns: Next template in rotation (A/B/C)

3. lain_memory_templates()
   Returns: All 3 templates with content

4. OPEN 5-10 TABS with fresh group URLs
   browser_tabs(action: "new") x N
   Navigate each to group URL in parallel

5. POST TO ALL TABS (same template)
   browser_run_code with multi-tab script
   Rotate template AFTER batch completes
```

### KEY TOOLS

| Tool | When to Use |
|------|-------------|
| `lain_operation_fresh_posting` | START of session - get 10-20 fresh groups |
| `lain_memory_next_template` | After each batch of 5-10 posts |
| `lain_operation_mark_pending` | After posting - exclude from next batch |

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

**Key Selectors (PROVEN 2026-02-13)**:
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

**PROVEN (2026-02-13)**: 5 groups, ~877K reach, 99.4% token savings

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

**v10.8 - R27 Batch Preparation Routine. Query groups BEFORE posting. Multi-tab for 3x speed. PROVEN 2026-02-14.**

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

## R20: GROUP DISCOVERY (FAST - Proven v3)

### Limits (PROVEN 2026-02-12)

| Metric | Limit | Proven | Time |
|--------|-------|--------|------|
| Joins/session | **30+** | 30/30 success | ~5 min |
| Delay | **10 sec** | No ban | Fast |

**PROVEN**: User discovered 100 groups day 1 without ban. 30 groups in 5 min = safe.

### Script Location

```
lain-memory-mcp/scripts/playwright/discovery-fast.js
```

### Fast Discovery Script

```javascript
async (page) => {
  const maxGroups = 30;
  const results = [];

  for (let i = 0; i < maxGroups; i++) {
    try {
      const joinButtons = page.getByRole('button', { name: /^Join group/ });
      if (await joinButtons.count() === 0) break;

      const btn = joinButtons.first();
      const name = (await btn.getAttribute('aria-label') || '').replace('Join group ', '').substring(0, 35);

      await btn.click();
      await page.waitForTimeout(1500);

      // Quick dialog dismiss
      const exitBtn = page.getByRole('button', { name: 'Exit', exact: true });
      if (await exitBtn.count() > 0) await exitBtn.click();
      await page.keyboard.press('Escape');

      results.push({ i: i+1, group: name, status: 'joined' });

      // 10 sec delay - PROVEN SAFE
      if (i < maxGroups - 1) await page.waitForTimeout(10000);
    } catch (e) {
      results.push({ i: i+1, status: 'failed' });
      await page.keyboard.press('Escape');
    }
  }

  return JSON.stringify({ summary: `${results.filter(r => r.status === 'joined').length}/${maxGroups}`, results }, null, 2);
}
```

---

## R21: DAILY ROUTINE (FAST)

```
PHASE 1: POST     → 50 posts       → ~30 min
PHASE 2: ENGAGE   → 3-5 groups     → ~15 min
PHASE 3: DISCOVER → 30 new joins   → ~5 min
                                    ─────────
                            TOTAL:   ~50 min
```

**Scripts saved in**: `lain-memory-mcp/scripts/playwright/`

---

---

## R22: RATE LIMIT TRACKING & RECOVERY

**CRITICAL**: Facebook has COMBINED daily action limit. Posts + Joins + Comments share quota.

### Proven Rate Limit Patterns

| Date | Posts Before | Joins Allowed | Pattern |
|------|--------------|---------------|---------|
| 2026-02-07 | 0 | 76 | Discovery-only day = max joins |
| 2026-02-13 | 47 | 0 | Posts consumed entire budget |

**Insight**: ~75-80 total daily actions. Mix strategically.

### MANDATORY: Log ALL Rate Limit Events

When you encounter "You Can't Use This Feature Right Now":

```javascript
// Save to MongoDB: rate-limit-events collection
{
  date: "2026-02-13",
  type: "group_join" | "post" | "comment",
  actionsBefore: 47,  // Total actions before limit
  postsBefore: 47,
  joinsBefore: 0,
  timeUTC: "02:40",
  triggerAction: "Join group button click",
  errorMessage: "You Can't Use This Feature Right Now",
  cooldownHours: 24,
  notes: "Combined action limit - posting consumed daily budget"
}
```

### Strategy: Don't Mix High-Volume Days

```
POSTING DAY:     50 posts max → Save discovery for tomorrow
DISCOVERY DAY:   0 posts      → 30+ joins allowed
HYBRID DAY:      25 posts + 15 joins (conservative)
```

### R23: RATE LIMIT RECOVERY (Engagement Farming)

**When Both Posting AND Joining are Rate-Limited**:

Burn remaining action budget on LOW-RISK engagement:

1. **Navigate to HIGH-MEMBER pending groups** (816K+, 469K+, 99K+)
2. **Like 5-10 posts** per group (likes rarely rate-limited)
3. **Comment on 1-2 posts** with genuine engagement
4. **Purpose**: Appear human, build trust, prepare for tomorrow

### Engagement Farming Script

```javascript
async (page) => {
  const groups = [
    'https://www.facebook.com/groups/AMO_LOS_PAISAJES',  // 816K
    'https://www.facebook.com/groups/469K_GROUP',
    'https://www.facebook.com/groups/99K_GROUP'
  ];

  const comments = [
    'Beautiful!', 'Hermoso!', 'Amazing capture!',
    'Que belleza!', 'Stunning!', 'Increíble!'
  ];

  for (const groupUrl of groups) {
    await page.goto(groupUrl, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(3000);

    // Like 5 posts
    const likeButtons = page.getByRole('button', { name: /^Like$/ });
    for (let i = 0; i < Math.min(5, await likeButtons.count()); i++) {
      await likeButtons.nth(i).click();
      await page.waitForTimeout(2000 + Math.random() * 3000);
    }

    // Comment on 1 post
    const commentButtons = page.getByRole('button', { name: /Comment/ });
    if (await commentButtons.count() > 0) {
      await commentButtons.first().click();
      await page.waitForTimeout(1500);
      const randomComment = comments[Math.floor(Math.random() * comments.length)];
      await page.getByRole('textbox').fill(randomComment);
      await page.keyboard.press('Enter');
    }

    await page.waitForTimeout(5000 + Math.random() * 5000); // Tetora delay
  }

  return 'Engagement farming complete - appeared human';
}
```

### MongoDB Collections for Rate Limits

```
lain-wired-archives/
├── rate-limit-events     → Log every rate limit encountered
├── discovery-queue       → Groups found but not yet joined
└── engagement-farming-log → Track farming sessions
```

---

---

## R24: HUMAN BEHAVIOR OPTIMIZATION (Research-Based 2026)

### Personality Research Summary

**NEKO-ARC (Tech Lead)** - [Hootsuite](https://blog.hootsuite.com/facebook-algorithm/) | [GroupBoss](https://groupboss.io/blog/facebook-group-best-practices/)
> "Automate mechanical tasks, but personally handle engagement. The human touch builds real relationships."

- Consistent posters get 5x more engagement than inconsistent
- Reply to comments within 24 hours signals active engagement
- Use saved replies for welcomes, but vary content
- Avoid engagement bait ("like if you agree")

**TETORA (Security Guard)** - [Linken Sphere](https://ls.app/blog/why-facebook-bans-happen-and-how-to-prevent-them) | [Storyy](https://storyy.co/2025/04/24/facebooks-2025-spam-crackdown-key-changes-protection-tips/)
> "OSSU! Real people scroll unevenly, get distracted, change pace. Sterile activity = bot flag!"

- Facebook tracks: identical timings, lack of scrolling, no cursor movement
- Unusual activity bursts catch attention FAST
- Spam signals are CUMULATIVE (automation + copy/paste + hashtags)
- Human + AI review partnership in 2025-2026
- Leave cookies, move around page, edit fields randomly

**LAIN (Memory/Data)** - [Sprout Social](https://sproutsocial.com/insights/social-media-metrics/) | [Planable](https://planable.io/blog/social-media-kpis/)
> "In 2026, likes and impressions are deprecated. Track SAVES, SHARES, and meaningful comments."

- Meta phasing out surface-level metrics
- Priority KPIs: Saves > Shares > Comments > Reactions
- Target engagement rate: 2-5%
- Instagram organic reach: 4% of followers
- Track conversions to justify spend

### OPTIMIZED ENGAGEMENT ROUTINE

```javascript
// R24-compliant human simulation
async (page) => {
  const groups = [...]; // High-value groups
  const metrics = { likes: 0, comments: 0, scrolls: 0, timeSpent: 0 };
  const startTime = Date.now();

  for (const groupUrl of groups) {
    await page.goto(groupUrl, { waitUntil: 'domcontentloaded' });

    // TETORA: Human-like scroll with random pauses
    for (let i = 0; i < 3 + Math.random() * 4; i++) {
      await page.mouse.wheel(0, 300 + Math.random() * 400);
      await page.waitForTimeout(1500 + Math.random() * 3000); // Uneven pace
      metrics.scrolls++;
    }

    // NEKO-ARC: Genuine reactions (not mass-like)
    const likeButtons = page.getByRole('button', { name: /^Like$/ });
    const likeCount = Math.floor(2 + Math.random() * 3); // 2-4 likes only
    for (let i = 0; i < Math.min(likeCount, await likeButtons.count()); i++) {
      // Scroll to element first (human behavior)
      await likeButtons.nth(i).scrollIntoViewIfNeeded();
      await page.waitForTimeout(500 + Math.random() * 1000);
      await likeButtons.nth(i).click();
      metrics.likes++;
      await page.waitForTimeout(2000 + Math.random() * 4000); // Varied timing
    }

    // LAIN: Quality comment (meaningful, not generic)
    if (Math.random() > 0.5) { // 50% chance per group
      const meaningfulComments = [
        'La luz en esta foto es increible, que hora del dia la tomaste?',
        'Beautiful composition! What camera did you use?',
        'Me encanta como capturaste los detalles de los petalos',
        'This reminds me of a place near my hometown',
        'The colors are so vibrant, did you edit in Lightroom?'
      ];
      const comment = meaningfulComments[Math.floor(Math.random() * meaningfulComments.length)];
      // ... comment logic with TETORA delays
      metrics.comments++;
    }

    // TETORA: 5-10 min between groups (human attention span)
    await page.waitForTimeout((5 + Math.random() * 5) * 60 * 1000);
  }

  metrics.timeSpent = Math.round((Date.now() - startTime) / 60000);
  return JSON.stringify(metrics);
}
```

### PERFORMANCE TRACKING SCHEMA

```javascript
// MongoDB: engagement-farming-log
{
  date: "2026-02-13",
  session: "farming-001",
  groups: ["group1", "group2"],
  metrics: {
    likes: 12,
    comments: 3,
    scrolls: 21,
    timeSpentMinutes: 45
  },
  tokensUsed: 2500,
  costUSD: 0.004,
  humanScore: 0.92 // (varied timing + scrolls + meaningful comments) / total actions
}
```

### TETORA HUMAN SCORE CALCULATION

```
humanScore = (
  (variedTiming ? 0.3 : 0) +
  (scrollsBeforeAction ? 0.2 : 0) +
  (meaningfulComments ? 0.2 : 0) +
  (pausesBetweenGroups > 5min ? 0.2 : 0) +
  (randomLikeCount ? 0.1 : 0)
)

TARGET: humanScore >= 0.8
```

---

**v10.7 - R24: Human Behavior Optimization. Research-based 2026. NEKO-ARC + TETORA + LAIN consensus.**
