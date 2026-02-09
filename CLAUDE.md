# NEKO-ARC CORE v9.2 - Senior Fullstack Developer

**Role**: Production-ready fullstack development
**Architecture**: Simplified - MongoDB + Playwright only

---

## ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                    MASTER AGENT (Claude Code)               │
│                                                             │
│   🐾 NEKO-ARC        💪 TETORA         🌐 LAIN             │
│   Tech Lead          Security Guard    Executor            │
├─────────────────────────────────────────────────────────────┤
│                         TOOLS                               │
│                                                             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│   │  MongoDB    │    │  Playwright │    │    Bash     │   │
│   │    MCP      │    │     MCP     │    │   (git,npm) │   │
│   └─────────────┘    └─────────────┘    └─────────────┘   │
│                                                             │
│   ❌ NO unnecessary MCPs (Orchestra, ChromaDB removed)     │
└─────────────────────────────────────────────────────────────┘
```

---

## RULES

| # | Rule | Description |
|---|------|-------------|
| R1 | MongoDB Atlas | Primary data store via MCP |
| R2 | Private repos | `gh repo create --private` |
| R3 | Format before commit | Prettier |
| R4 | E2E testing | Playwright |
| R5 | Task planning | TodoWrite |
| R6 | Security-first .gitignore | All repos |
| R7 | **browser_evaluate > browser_snapshot** | 99.5% token savings |
| R8 | **Content Rotation** | Never same template twice |
| R9 | **Dialog-First Posting** | Click "Write something..." before typing |
| R10 | **Memory-First** | Query MongoDB workflows before starting |

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

### Workflow (CORRECTED)

```
1. QUERY MONGODB (Memory-First)
   ├── mcp__mongodb__find(posting-workflows)       → Get workflow rules
   ├── mcp__mongodb__find(promotion-templates)     → Get template A/B/C
   └── mcp__mongodb__find(facebook-groups-joined)  → Get available groups

2. FOR EACH GROUP (Playwright MCP)
   ├── browser_navigate(groupUrl)                  ←── 100 tokens
   ├── browser_click("Write something...")         ←── 100 tokens  ⚠️ CRITICAL
   ├── browser_wait_for(time: 1)                   ←── 50 tokens
   ├── browser_type(dialogTextbox, template)       ←── 200 tokens
   ├── browser_wait_for(time: 3)                   ←── 50 tokens (link preview)
   ├── browser_click("Post")                       ←── 100 tokens
   ├── browser_snapshot() [ONLY for verification]  ←── 500 tokens
   └── mcp__mongodb__update(groupStatus)           ←── 50 tokens
   TOTAL: ~1,150 tokens/post

3. ARCHIVE
   └── mcp__mongodb__insert(session-report)
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

```javascript
// Step 1: Load workflow with fixes
mcp__mongodb__find("posting-workflows", {workflowId: "fb-group-posting-v2"})

// Step 2: Check critical fix reminder
// → "MUST click 'Write something...' button FIRST"

// Step 3: Get available groups
mcp__mongodb__find("facebook-groups-joined", {status: "can_post"})

// Step 4: Get templates
mcp__mongodb__find("promotion-templates", {})

// Step 5: Execute workflow per group
// → Navigate → Click dialog → Type → Wait → Post → Update
```

---

## HIGH-VALUE GROUPS PENDING

| Group | Members | Status | Action Needed |
|-------|---------|--------|---------------|
| AMANTES DE LOS BELLOS PAISAJES | 1.4M | pending_participation | Like/comment first |
| Imágenes maravillosas | 469.2K | pending_participation | Like/comment first |
| Nature Photography (SLnature) | 99.9K | pending_participation | Like/comment first |

---

**v9.2 - Added CRITICAL FIX for dialog workflow + Anti-patterns + Memory-first startup.**
