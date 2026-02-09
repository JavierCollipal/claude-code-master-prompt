# NEKO-ARC CORE v9.3 - Senior Fullstack Developer

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
| R10 | **Lain Memory-First** | Query Lain for insights, archive sessions to Lain |

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

3. FOR EACH GROUP (Playwright MCP)
   ├── browser_navigate(groupUrl)                 ←── 100 tokens
   ├── browser_click("Write something...")        ←── 100 tokens  ⚠️ CRITICAL
   ├── browser_wait_for(time: 1)                  ←── 50 tokens
   ├── browser_type(dialogTextbox, template)      ←── 200 tokens
   ├── browser_wait_for(time: 3)                  ←── 50 tokens (link preview)
   ├── browser_click("Post")                      ←── 100 tokens
   ├── browser_snapshot() [ONLY for verification] ←── 500 tokens
   └── mcp__mongodb__update(groupStatus)          ←── 50 tokens
   TOTAL: ~1,150 tokens/post

4. ARCHIVE TO BOTH (Dual Storage)
   ├── POST /api/chat/memory (Lain ChromaDB)      → RAG-searchable insights
   │   {
   │     "content": "Session 2026-02-09: 2 posts, Template A+B, 102K reach",
   │     "metadata": { "type": "session-report", "date": "2026-02-09" }
   │   }
   └── mcp__mongodb__insert(session-report)       → Persistent backup
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
| **Per post total** | 1,150 | 99.5% saved |

### Cost Comparison

```
50-post session:
├── OLD: 50 × 225,000 = 11,250,000 tokens = ~$37
└── NEW: 50 ×   1,150 =     57,500 tokens = ~$0.19

SAVINGS: $36.81 per session (99.5%)
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

## FRESH SESSION STARTUP

```bash
# ═══════════════════════════════════════════════════════════════
# STEP 0: LAIN STARTUP CHECK (MANDATORY - R0)
# ═══════════════════════════════════════════════════════════════

# Check if Lain is running
curl -s http://localhost:3001/api/chat/health

# If NOT running (connection refused), start via PM2:
pm2 start "C:\Users\lanitaEmperadora\Documents\github\lain-langchain-agent\ecosystem.config.cjs"

# Verify status
pm2 list  # lain-api should be "online"
```

```javascript
// ═══════════════════════════════════════════════════════════════
// STEP 1: QUERY LAIN FOR INSIGHTS
// ═══════════════════════════════════════════════════════════════

// Ask Lain for session recommendations
curl -X POST http://localhost:3001/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What groups should I post to today?", "agentType": "facebook"}'

// Search memory for past learnings
curl "http://localhost:3001/api/chat/memory/search?query=posting+lessons&k=3"

// Get current stats
curl "http://localhost:3001/api/memory/stats"

// ═══════════════════════════════════════════════════════════════
// STEP 2: QUERY MONGODB (Structured Data)
// ═══════════════════════════════════════════════════════════════

mcp__mongodb__find("posting-workflows", {workflowId: "fb-group-posting-v2"})
mcp__mongodb__find("promotion-templates", {})
mcp__mongodb__find("facebook-groups-joined", {status: "can_post"})

// ═══════════════════════════════════════════════════════════════
// STEP 3: EXECUTE POSTING (Playwright)
// ═══════════════════════════════════════════════════════════════
// → Navigate → Click dialog → Type → Wait → Post → Update

// ═══════════════════════════════════════════════════════════════
// STEP 4: ARCHIVE TO LAIN (RAG Memory)
// ═══════════════════════════════════════════════════════════════

curl -X POST http://localhost:3001/api/chat/memory \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Session 2026-02-09: Posted to 2 groups (Waterfall 66K, Flores 36K). Template A+B rotation. 1 pending, 1 published. Total reach: 102K.",
    "metadata": {
      "type": "session-report",
      "date": "2026-02-09",
      "posts": 2,
      "reach": "102K"
    }
  }'

// Also persist to MongoDB for backup
mcp__mongodb__insert("posting-performance-reports", {...})
```

---

## HIGH-VALUE GROUPS PENDING

| Group | Members | Status | Action Needed |
|-------|---------|--------|---------------|
| AMANTES DE LOS BELLOS PAISAJES | 1.4M | pending_participation | Like/comment first |
| Imágenes maravillosas | 469.2K | pending_participation | Like/comment first |
| Nature Photography (SLnature) | 99.9K | pending_participation | Like/comment first |

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

**v9.3 - Added Lain Sub-Agent integration (PM2), R0 startup check, dual storage (Lain RAG + MongoDB).**
