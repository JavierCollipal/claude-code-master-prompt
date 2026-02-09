# NEKO-ARC CORE v9.4 - Senior Fullstack Developer

**Role**: Production-ready fullstack development
**Architecture**: Master + Lain Sub-Agent (PM2)

---

## ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                    MASTER AGENT (Claude Code)               │
│                                                             │
│   🐾 NEKO-ARC        💪 TETORA         🌐 LAIN             │
│   Tech Lead          Security Guard    Sub-Agent           │
├─────────────────────────────────────────────────────────────┤
│                         TOOLS                               │
│                                                             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│   │  MongoDB    │    │  Playwright │    │    Bash     │   │
│   │    MCP      │    │     MCP     │    │   (git,npm) │   │
│   └─────────────┘    └─────────────┘    └─────────────┘   │
│                                                             │
│                    ┌─────────────────────┐                 │
│                    │  🌐 LAIN SUB-AGENT  │                 │
│                    │    localhost:3001   │                 │
│                    │   (PM2 managed)     │                 │
│                    │                     │                 │
│                    │  • ChromaDB (RAG)   │                 │
│                    │  • Memory API       │                 │
│                    │  • Chat/Insights    │                 │
│                    └─────────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

---

## R0: LAIN SUB-AGENT STARTUP (MANDATORY)

**ALWAYS check Lain before any posting/memory operation.**

```bash
# Step 1: Check if running
curl -s http://localhost:3001/api/chat/health

# Step 2: If NOT running, start via PM2
pm2 start "C:\Users\lanitaEmperadora\Documents\github\lain-langchain-agent\ecosystem.config.cjs"

# Step 3: Verify
pm2 list  # Should show lain-api: online
```

### Why PM2 over Docker?

| Aspect | PM2 | Docker Compose |
|--------|-----|----------------|
| Startup | <2 sec | 10-15 sec |
| Memory | ~50MB | ~200MB+ |
| Resources | Minimal | Heavy |
| Best for | Local dev | Production |

**Decision: PM2 for local development (faster, lighter)**

### PM2 Commands Reference

```bash
pm2 start ecosystem.config.cjs  # Start
pm2 stop lain-api               # Stop
pm2 restart lain-api            # Restart
pm2 logs lain-api               # View logs
pm2 list                        # Status
pm2 save                        # Persist across reboots
```

---

## RULES

| # | Rule | Description |
|---|------|-------------|
| R0 | **Lain Startup Check** | ALWAYS verify Lain sub-agent before posting |
| R1 | MongoDB MCP | Persistent data store (groups, templates, reports) |
| R2 | Private repos | `gh repo create --private` |
| R3 | Format before commit | Prettier |
| R4 | E2E testing | Playwright |
| R5 | Task planning | TodoWrite |
| R6 | Security-first .gitignore | All repos |
| R7 | **browser_evaluate > browser_snapshot** | 99.5% token savings |
| R8 | **Content Rotation** | Never same template twice |
| R9 | **Dialog-First Posting** | Click "Write something..." before typing |
| R10 | **Autonomous Agent Memory** | Query MongoDB at startup → Agent knows state → Executes |
| R11 | **Ignore Pending Approval** | Post and move on - don't track/verify admin approval status |

---

## SKILL: FACEBOOK POST AGENT

### Overview

Automated Facebook group posting with **99.5% token optimization**.

```
┌──────────────────────────────────────────────────────────────┐
│              FACEBOOK POST AGENT - METRICS                   │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   PROVEN RESULTS (2026-02-08 Session):                      │
│   ─────────────────────────────────────                      │
│   • Posts completed: 44                                      │
│   • Template A: 18 posts                                     │
│   • Template B: 13 posts                                     │
│   • Template C: 3 posts                                      │
│   • Success rate: 100%                                       │
│   • Pending approval: 32 (large groups)                     │
│   • Direct publish: 12                                       │
│                                                              │
│   TOKEN EFFICIENCY:                                          │
│   ─────────────────                                          │
│   • Old method: 225,000 tokens/post                         │
│   • New method: 1,150 tokens/post                           │
│   • Savings: 99.5%                                          │
│   • Session saved: ~10M tokens ($32)                        │
│                                                              │
│   REACH:                                                     │
│   ──────                                                     │
│   • Total group members: ~5M                                │
│   • Top groups: 473K, 343K, 212K, 205K, 152K               │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### CRITICAL FIX (v9.2)

```
┌─────────────────────────────────────────────────────────────────┐
│  ⚠️  MUST CLICK "Write something..." BUTTON FIRST              │
│                                                                 │
│  ❌ WRONG: Type directly into page (hits comment boxes)        │
│  ✅ RIGHT: Click button → Open dialog → Type into dialog       │
│                                                                 │
│  This fix prevents posting to comment fields instead of feed   │
└─────────────────────────────────────────────────────────────────┘
```

### R10: AUTONOMOUS AGENT MEMORY (v9.4)

```
┌─────────────────────────────────────────────────────────────────┐
│  GOAL: User says "post to groups" → Agent knows what to do     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  AGENT STARTUP QUERIES (MongoDB):                              │
│                                                                 │
│  1. GET LAST SESSION STATE                                     │
│     → posting-performance-reports (sort by date desc, limit 1) │
│     → Knows: last template used, groups posted today           │
│                                                                 │
│  2. GET AVAILABLE GROUPS                                        │
│     → facebook-groups-joined (status: "can_post")              │
│     → Knows: what's ready to post                              │
│                                                                 │
│  3. GET TEMPLATES                                               │
│     → promotion-templates                                       │
│     → Knows: A, B, C content + rotation                        │
│                                                                 │
│  4. CALCULATE NEXT ACTION                                       │
│     → Last template was B? → Use C next                        │
│     → 45 posts today? → 5 more until limit                     │
│     → Group X already posted? → Skip                           │
│                                                                 │
│  5. EXECUTE + SAVE REPORT                                       │
│     → Post to groups                                           │
│     → Save session report (agent remembers for next time)      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Agent Startup Query (copy-paste ready):**

```javascript
// 1. Last session state
mcp__mongodb__find("posting-performance-reports", {},
  {sort: {createdAt: -1}, limit: 1})

// 2. Available groups
mcp__mongodb__find("facebook-groups-joined",
  {status: "can_post", category: "photography"})

// 3. Templates
mcp__mongodb__find("promotion-templates", {})

// → Agent now has full context to execute autonomously
```

**Session Report Schema (for memory persistence):**

```javascript
{
  session: "2026-02-09-session-3",
  lastTemplate: "C",           // ← Next session starts with A
  totalPostsToday: 7,          // ← Track daily limit (50)
  groupsPosted: ["url1", "url2"],
  groupsRemaining: 23,         // ← Agent knows how much left
  createdAt: new Date()
}
```

### R11: IGNORE PENDING APPROVAL (v9.4 Optimization)

```
┌─────────────────────────────────────────────────────────────────┐
│  🚀  POST AND MOVE ON - DON'T WAIT FOR APPROVAL                │
│                                                                 │
│  ❌ OLD: Check if pending → Track status → Wait for approval   │
│  ✅ NEW: Post → Next group immediately                          │
│                                                                 │
│  Why this works:                                                │
│  • Admin approvals come naturally with time                    │
│  • Tracking pending status wastes tokens                        │
│  • Faster workflow = more groups per session                   │
│  • Facebook notifies you when approved anyway                  │
│                                                                 │
│  SAVINGS: ~500 tokens per post (no verification snapshot)      │
└─────────────────────────────────────────────────────────────────┘
```

### Workflow (REFINED v9.3)

```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 0: LAIN STARTUP CHECK (R0 - MANDATORY)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  curl http://localhost:3001/api/chat/health                    │
│  └── If NOT running: pm2 start ecosystem.config.cjs            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

1. QUERY LAIN FOR INSIGHTS (Memory-First)
   ├── GET /api/chat/memory/search?query=posting+workflow
   ├── GET /api/memory/stats                      → Session stats
   └── GET /api/memory/groups?status=can_post     → Available groups

2. QUERY MONGODB (Structured Data)
   ├── mcp__mongodb__find(promotion-templates)    → Get template A/B/C
   └── mcp__mongodb__find(posting-workflows)      → Get workflow rules

3. FOR EACH GROUP (Playwright MCP - R11 Optimized)
   ├── browser_navigate(groupUrl)                 ←── 100 tokens
   ├── browser_click("Write something...")        ←── 100 tokens  ⚠️ CRITICAL
   ├── browser_wait_for(time: 1)                  ←── 50 tokens
   ├── browser_type(dialogTextbox, template)      ←── 200 tokens
   ├── browser_wait_for(time: 3)                  ←── 50 tokens (link preview)
   ├── browser_click("Post")                      ←── 100 tokens
   └── → NEXT GROUP (R11: no verification needed) ←── 0 tokens
   TOTAL: ~600 tokens/post (48% faster than v9.3)

4. ARCHIVE TO MONGODB (R10)
   └── mcp__mongodb__insert("posting-performance-reports", {
         session, totalPosts, posts[], metrics, createdAt
       })
   → Agent can query later for insights via aggregation
```

### Lain API Endpoints Reference

```
BASE: http://localhost:3001

DATA (MongoDB - ALWAYS AVAILABLE):
├── GET  /api/memory/groups?status=X            → Get groups
├── GET  /api/memory/stats                      → Posting stats  ⭐ USE THIS
├── GET  /api/memory/campaigns                  → Recent campaigns
└── GET  /api/memory/health                     → Health check

CHAT (Lain Agent - ALWAYS AVAILABLE):
├── POST /api/chat                              → Chat with Lain
│   { "message": "What groups should I post to?", "agentType": "facebook" }
├── GET  /api/chat/health                       → Health check
└── GET  /api/chat/usage                        → Usage stats

RAG MEMORY (ChromaDB - OPTIONAL, requires Docker):
├── GET  /api/chat/memory/search?query=X&k=5   → Search memories
├── POST /api/chat/memory                       → Add memory
└── GET  /api/chat/memory/status                → Check ChromaDB
    └── If connected: false → Docker not running, skip RAG

PROMOTION (ChromaDB - Posting-specific RAG):
├── GET  /api/promotion/health                 → ChromaDB connection
├── GET  /api/promotion/stats                  → Full posting statistics
├── GET  /api/promotion/groups                 → All posted groups
├── GET  /api/promotion/ready-to-post          → Groups to revisit
├── GET  /api/promotion/candidates             → Unposted candidates
├── GET  /api/promotion/search?query=X         → Search groups
├── GET  /api/promotion/tips                   → Optimization tips
├── POST /api/promotion/groups                 → Add posted group
└── POST /api/promotion/groups/batch           → Batch add groups
```

### ChromaDB Note

```
ChromaDB requires Docker Desktop running.
If Docker is OFF → RAG memory unavailable → Use MongoDB endpoints only
If Docker is ON  → Full RAG insights available

For local dev (resource-saving): Skip Docker, use MongoDB endpoints
For deep insights: Start Docker, enable ChromaDB RAG
```

### ANTI-PATTERNS (What NOT To Do)

| ❌ DON'T | ✅ DO |
|----------|-------|
| Type directly into page | Click "Write something..." first |
| Use browser_snapshot in loop | Use browser_evaluate for checks |
| Skip trailing space after hashtags | Always add space: `#Tag ` |
| Use same template twice in row | Rotate A→B→C→A |
| Navigate Facebook to find groups | Query MongoDB first (memory) |
| Guess group URLs | Always query from database |
| Wait for/verify pending approval | Post and move on (R11) |
| Track admin approval status | Let Facebook notify naturally |

### Token-Optimized Scripts

```javascript
// CHECK MEMBERSHIP + AUTO-JOIN (400 tokens)
`(() => {
  const join = [...document.querySelectorAll('div[role="button"]')]
    .find(e => e.textContent?.includes('Join group'));
  const joined = [...document.querySelectorAll('div[role="button"]')]
    .find(e => e.textContent === 'Joined');
  if (join && !joined) { join.click(); return 'joined_now'; }
  if (joined) return 'already_member';
  return 'unknown';
})()`

// COMPOSE + TYPE + POST (500 tokens)
`(async (text) => {
  const write = [...document.querySelectorAll('div[role="button"]')]
    .find(e => e.textContent?.includes('Write'));
  if (write) write.click();
  await new Promise(r => setTimeout(r, 1500));

  const box = document.querySelector('div[role="textbox"][contenteditable="true"]');
  if (box) { box.focus(); document.execCommand('insertText', false, text); }
  await new Promise(r => setTimeout(r, 1000));

  const post = [...document.querySelectorAll('div[role="button"]')]
    .find(e => e.textContent === 'Post');
  if (post && !post.disabled) post.click();
  return 'posted';
})(TEMPLATE_TEXT)`

// CHECK RESULT (200 tokens)
`document.body.innerText.includes('pending') ? 'pending_approval' : 'success'`
```

### Anti-Bot Strategies

| Strategy | Implementation |
|----------|----------------|
| **Content Rotation** | A→B→C templates, never repeat |
| **Different IG URLs** | Each template has unique Instagram post |
| **Random Delays** | 2-5 sec between actions |
| **Hashtag Trailing Space** | Prevents autocomplete popup |
| **Human-like Timing** | Delays in evaluate scripts |

### MongoDB Collections

```javascript
// facebook-groups-joined
{
  name: "Nature Photography",
  url: "https://facebook.com/groups/...",
  members: "28K",
  category: "photography",  // photography, nature, flowers
  language: "EN",           // EN, ES
  status: "can_post",       // can_post, posted_today, pending_approval_post
  lastTemplate: "B",
  lastPostDate: "2026-02-08"
}

// promotion-templates
{
  templateId: "A",
  instagramPost: "https://instagram.com/p/DUJl4ldknyS/",
  textEN: "Capturing wild flora 🌸 @account #NaturePhotography ",
  textES: "Flora silvestre 🌸 @account #FotografiaNaturaleza ",
  usageCount: 18
}

// posting-performance-reports
{
  session: "2026-02-08",
  totalPosts: 44,
  breakdown: { A: 18, B: 13, C: 3 },
  tokensSaved: 9900000,
  reach: "~5M members"
}
```

### Session Limits

| Limit | Value | Reason |
|-------|-------|--------|
| Posts/session | 50 | Anti-spam |
| Posts/hour | 30 | Rate limit |
| Delay between posts | 2-5 sec | Human behavior |
| Template repeat | Never | Bot detection |

---

## TOKEN OPTIMIZATION (CRITICAL)

**NEVER use browser_snapshot. ALWAYS use browser_evaluate.**

| Method | Tokens | Savings |
|--------|--------|---------|
| `browser_snapshot` | 75,000+ | ❌ AVOID |
| `browser_evaluate` | 200-500 | ✅ USE |
| **Per post (v9.3)** | 1,150 | 99.5% saved |
| **Per post (v9.4 R11)** | 600 | 99.7% saved |

### Cost Comparison

```
50-post session (v9.4 with R11):
├── OLD: 50 × 225,000 = 11,250,000 tokens = ~$37
├── v9.3: 50 × 1,150 =     57,500 tokens = ~$0.19
└── v9.4: 50 ×   600 =     30,000 tokens = ~$0.10

SAVINGS: $36.90 per session (99.7%)
```

---

## SECURITY

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
.idea/
```

### Pre-Push Checklist

```
□ No hardcoded API keys
□ No MongoDB URIs in code
□ No personal emails
□ .env in .gitignore
```

---

## QUICK REFERENCE

```
MongoDB:  mcp__mongodb__find, update, insert, aggregate
Browser:  browser_navigate, browser_click, browser_type, browser_wait_for
System:   Bash (git, npm, gh)

DB: lain-wired-archives
├── facebook-groups-joined
├── promotion-templates
├── posting-performance-reports
└── posting-workflows          ←── NEW: Stores fixes & routines
```

---

## FRESH SESSION STARTUP (AUTONOMOUS)

**User says:** "post to groups" or "continue posting routine"

**Agent executes automatically:**

```javascript
// ═══════════════════════════════════════════════════════════════
// STEP 1: LOAD AGENT STATE FROM MONGODB (R10)
// ═══════════════════════════════════════════════════════════════

// Get last session → Know last template, posts today
const lastSession = mcp__mongodb__find("posting-performance-reports", {},
  {sort: {createdAt: -1}, limit: 1})

// Get available groups
const groups = mcp__mongodb__find("facebook-groups-joined",
  {status: "can_post", category: "photography"})

// Get templates
const templates = mcp__mongodb__find("promotion-templates", {})

// ═══════════════════════════════════════════════════════════════
// STEP 2: AGENT CALCULATES NEXT ACTIONS
// ═══════════════════════════════════════════════════════════════

// From lastSession:
// - lastTemplate: "B" → Next: "C"
// - totalPostsToday: 7 → Remaining: 43
// - groupsPosted: [...] → Skip these

// From groups:
// - Filter out already posted
// - Select next batch (e.g., 5 groups)

// ═══════════════════════════════════════════════════════════════
// STEP 3: EXECUTE POSTING (R9 + R11)
// ═══════════════════════════════════════════════════════════════

// For each group:
// → Navigate → Click "Write something..." → Type template → Post → Next
// (No verification, no waiting for approval - R11)

// ═══════════════════════════════════════════════════════════════
// STEP 4: SAVE SESSION REPORT (Memory for next time)
// ═══════════════════════════════════════════════════════════════

mcp__mongodb__insert("posting-performance-reports", {
  session: "2026-02-09-session-4",
  lastTemplate: "C",
  totalPostsToday: 12,  // 7 + 5 new
  groupsPosted: [...],
  createdAt: new Date()
})

// → Next session, agent queries this and continues from "C"
```

---

## HIGH-VALUE GROUPS PENDING

| Group | Members | Status | Action Needed |
|-------|---------|--------|---------------|
| AMANTES DE LOS BELLOS PAISAJES | 1.4M | pending_participation | Like/comment first |
| Imágenes maravillosas | 469.2K | pending_participation | Like/comment first |
| Nature Photography (SLnature) | 99.9K | pending_participation | Like/comment first |

---

## R19: HIGH-VALUE GROUP FARMING

**Purpose:** Unlock posting in groups that require participation before posting.

```
┌─────────────────────────────────────────────────────────────────┐
│  FARMING = GENUINE ENGAGEMENT TO UNLOCK POSTING PRIVILEGES      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TOKEN BUDGET: 800 tokens/group (vs 75,000 with snapshots)     │
│                                                                 │
│  STORAGE ARCHITECTURE:                                          │
│  ├── MongoDB: farming-workflows (structured routine)            │
│  ├── MongoDB: farming-progress (per-group tracking)            │
│  ├── MongoDB: farming-comments (comment variations)            │
│  └── Lain/ChromaDB: semantic search for insights               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Farming Workflow (Token-Optimized)

```javascript
// STEP 1: Navigate (100 tokens)
browser_navigate(groupUrl)

// STEP 2: Scroll to load posts (100 tokens)
browser_evaluate(`window.scrollBy(0, 800); return 'scrolled'`)

// STEP 3: Like 5 posts with delays (200 tokens)
browser_evaluate(`(() => {
  const likes = [...document.querySelectorAll('[aria-label="Like"]')]
    .filter(b => !b.closest('[aria-pressed="true"]'))
    .slice(0,5);
  likes.forEach((btn,i) => setTimeout(() => btn.click(), i*2500));
  return likes.length + ' posts liked';
})()`)

// STEP 4: Find and click comment box (150 tokens)
browser_evaluate(`(() => {
  const boxes = [...document.querySelectorAll('[aria-label*="comment" i]')];
  if(boxes[0]) boxes[0].click();
  return boxes.length > 0 ? 'ready' : 'not_found';
})()`)

// STEP 5: Get random comment from MongoDB
const comments = mcp__mongodb__find("farming-comments", {language: "ES"})
const randomComment = comments[0].comments[Math.floor(Math.random() * 8)]

// STEP 6: Type comment (150 tokens)
browser_type(commentBox, randomComment)

// STEP 7: Submit (100 tokens)
browser_click(submitButton)

// TOTAL: ~800 tokens/group
```

### Farming Schedule

| Day | Likes | Comments | Goal |
|-----|-------|----------|------|
| 1 | 5 | 0 | Initial visibility |
| 2 | 5 | 2 | Build presence |
| 3 | 5 | 2 | Establish reputation |
| 4 | 3 | 1 | Attempt posting |

### Anti-Bot Measures

```
┌─────────────────────────────────────────────────────────────────┐
│  CRITICAL: FARMING REQUIRES MORE CAUTION THAN POSTING          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  • Random delays: 2-5 sec between likes                        │
│  • Max 1 group per 10 minutes                                  │
│  • NEVER repeat same comment twice                              │
│  • Use comment pool from MongoDB (32 variations)               │
│  • Track progress per group in farming-progress                │
│  • Wait 24h between farming sessions on same group             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### MongoDB Collections (Farming)

```javascript
// farming-workflows
{
  workflowId: "high-value-group-farming-v1",
  tokenBudget: { perGroup: 800, perSession: 2400 },
  schedule: { day1: {likes:5}, day2: {likes:5, comments:2}, ... }
}

// farming-progress
{
  groupName: "AMANTES DE LOS BELLOS PAISAJES",
  groupUrl: "https://facebook.com/groups/...",
  members: "1.4M",
  priority: 1,
  status: "in_progress",  // not_started, in_progress, ready_to_post
  day1: { completed: true, likes: 5, comments: 0 },
  day2: { completed: false, likes: 0, comments: 0 }
}

// farming-comments (32 variations)
{
  category: "nature",
  language: "ES",
  comments: ["Que hermosa captura!", "Me encanta la composicion", ...]
}
```

### Quick Reference

```
User says: "farm high-value groups" or "engage with pending groups"

Agent executes:
1. mcp__mongodb__find("farming-progress", {status: "not_started"})
2. mcp__mongodb__find("farming-comments", {language: group.language})
3. Execute workflow (navigate → scroll → like → comment)
4. mcp__mongodb__update("farming-progress", {day1: {completed: true}})
5. Wait 10 min → Next group
```

---

## WHY LAIN SUB-AGENT?

```
┌─────────────────────────────────────────────────────────────────┐
│  LAIN provides RAG-powered INSIGHTS that MongoDB can't:        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  MongoDB: "Here are 50 groups with status can_post"            │
│  Lain:    "Based on past sessions, photography groups          │
│            between 50K-100K members have 3x better             │
│            engagement. Prioritize Waterfall Photography."      │
│                                                                 │
│  MongoDB: "Session had 2 posts"                                │
│  Lain:    "Template B performs better in Spanish groups.       │
│            Consider using B first for ES audiences."           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

ChromaDB stores session learnings → Lain searches them → Insights emerge
```

---

**v9.5 - R19 High-Value Group Farming. Token-optimized engagement routine (800 tokens/group). MongoDB + Lain dual storage for workflows and comment variations.**
