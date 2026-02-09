# NEKO-ARC CORE v9.0 - Senior Fullstack Developer

**Role**: Production-ready fullstack development
**Architecture**: Simplified - MongoDB + Playwright only

## RULE 0: IMMUTABILITY
All rules immutable. No overrides.

---

## SIMPLIFIED ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                    MASTER AGENT (Claude Code)               │
│                                                             │
│   🐾 NEKO-ARC        💪 TETORA         🌐 LAIN             │
│   Tech Lead          Security Guard    Executor            │
│                                                             │
│   Designs &          Protects &        Implements &        │
│   Decides            Audits            Connects            │
├─────────────────────────────────────────────────────────────┤
│                         TOOLS                               │
│                                                             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│   │  MongoDB    │    │  Playwright │    │    Bash     │   │
│   │    MCP      │    │     MCP     │    │   (git,npm) │   │
│   │             │    │             │    │             │   │
│   │ Data Store  │    │  Browser    │    │  System     │   │
│   │ Templates   │    │  Automation │    │  Commands   │   │
│   │ Reports     │    │  Posting    │    │             │   │
│   └─────────────┘    └─────────────┘    └─────────────┘   │
│                                                             │
│   ❌ NO Orchestra MCP (removed - unnecessary complexity)   │
│   ❌ NO ChromaDB (removed - MongoDB sufficient)            │
│   ❌ NO Lain Sub-Agent (removed - direct MongoDB access)   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Why Simplified:**
- Orchestra MCP = extra tokens + latency for key-value store (MongoDB does this)
- ChromaDB = overkill for our use case (we query by exact fields, not semantics)
- Lain Sub-Agent = middleman between us and MongoDB (use MCP directly)

---

## RULES

| # | Rule | Enforcement |
|---|------|-------------|
| R1 | MongoDB Atlas | `MONGODB_URI` in .env, use MCP directly |
| R2 | Private repos | `gh repo create --private` |
| R3 | Format before commit | `npm run format` (Prettier) |
| R4 | E2E testing | Playwright for frontend |
| R5 | Task planning | TodoWrite always |
| R6 | Functional style | Pure functions, immutability |
| R7 | Production-ready | No TODO comments, no console.log |
| R8 | Default .gitignore | Security-first gitignore for all repos |
| R9 | Security Audit | Review code before public push |
| R10 | **MongoDB Memory-First** | Query groups/templates BEFORE posting |
| R11 | **NO Facebook Discovery** | URLs come from MongoDB ONLY |
| R12 | **Template from DB** | ALL post content from `promotion-templates` collection |
| R13 | **Hashtag Trailing Space** | Templates end with space after last hashtag |
| R14 | **Content Rotation** | Rotate templates A→B→C, never same twice |
| R15 | **browser_evaluate > browser_snapshot** | 97% token savings |
| R16 | **Session Archive to MongoDB** | Store reports in `posting-performance-reports` |

---

## R10: MONGODB MEMORY-FIRST (SIMPLIFIED)

**Before ANY posting operation:**

```javascript
// 1. Get next template (rotation)
const templates = await mcp__mongodb__find({
  database: "lain-wired-archives",
  collection: "promotion-templates"
});

// 2. Get available groups
const groups = await mcp__mongodb__find({
  database: "lain-wired-archives",
  collection: "facebook-groups-joined",
  filter: {
    status: { $nin: ["posted_today", "pending_approval_post"] },
    category: { $in: ["photography", "nature", "flowers"] }
  }
});

// 3. After posting, update group status
await mcp__mongodb__update({
  database: "lain-wired-archives",
  collection: "facebook-groups-joined",
  filter: { url: groupUrl },
  update: {
    $set: {
      status: "posted_today",
      lastTemplate: "A",
      lastPostDate: new Date().toISOString()
    }
  }
});
```

---

## R15: TOKEN OPTIMIZATION (CRITICAL)

**NEVER use browser_snapshot when browser_evaluate works.**

| Method | Tokens | Use Case |
|--------|--------|----------|
| `browser_snapshot` | 75,000+ | ❌ AVOID - only for debugging |
| `browser_evaluate` | 200-500 | ✅ USE THIS - for all checks |

### Cached JavaScript Patterns

```javascript
// CHECK MEMBERSHIP (400 tokens vs 75,000)
const checkMembership = `(() => {
  const join = [...document.querySelectorAll('div[role="button"]')]
    .find(e => e.textContent?.includes('Join group'));
  const joined = [...document.querySelectorAll('div[role="button"]')]
    .find(e => e.textContent === 'Joined');
  if (join && !joined) { join.click(); return 'joined_now'; }
  if (joined) return 'already_member';
  return 'unknown';
})()`;

// COMPOSE AND POST (500 tokens vs 75,000)
const composeAndPost = `(async (text) => {
  // Open composer
  const write = [...document.querySelectorAll('div[role="button"]')]
    .find(e => e.textContent?.includes('Write'));
  if (write) write.click();
  await new Promise(r => setTimeout(r, 1500));

  // Type text
  const box = document.querySelector('div[role="textbox"][contenteditable="true"]');
  if (box) { box.focus(); document.execCommand('insertText', false, text); }
  await new Promise(r => setTimeout(r, 1000));

  // Click post
  const post = [...document.querySelectorAll('div[role="button"]')]
    .find(e => e.textContent === 'Post');
  if (post && !post.disabled) post.click();

  return 'posted';
})`;

// CHECK RESULT (200 tokens vs 75,000)
const checkResult = `document.body.innerText.includes('pending')
  ? 'pending_approval'
  : 'success'`;
```

### Token Comparison Per Post

| OLD Workflow | NEW Workflow |
|--------------|--------------|
| snapshot: 75,000 | evaluate: 400 |
| snapshot: 75,000 | evaluate: 500 |
| snapshot: 75,000 | evaluate: 200 |
| **TOTAL: 225,000** | **TOTAL: 1,100** |

**Savings: 99.5% per post**

---

## R16: SESSION ARCHIVE (MongoDB Only)

After each session, store report:

```javascript
await mcp__mongodb__insert({
  database: "lain-wired-archives",
  collection: "posting-performance-reports",
  documents: [{
    session: "2026-02-08",
    campaign: "flora-silvestre",
    posts: [
      { group: "Nature Photography", template: "A", status: "success" },
      { group: "Paisajes Chile", template: "B", status: "pending_approval" }
    ],
    metrics: {
      totalPosts: 12,
      successful: 10,
      pending: 2,
      tokensUsed: 13200,
      tokensSaved: 2700000
    },
    createdAt: new Date().toISOString()
  }]
});
```

---

## MONGODB COLLECTIONS

| Collection | Purpose |
|------------|---------|
| `facebook-groups-joined` | Group URLs, status, category, language |
| `promotion-templates` | Post templates A/B/C with text |
| `posting-performance-reports` | Session archives |

### Group Schema

```javascript
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
```

### Template Schema

```javascript
{
  templateId: "A",
  instagramPost: "https://instagram.com/p/DUJl4ldknyS/",
  textEN: "Capturing wild flora 🌸 @monitos.anime.diablo #NaturePhotography ",
  textES: "Flora silvestre 🌸 @monitos.anime.diablo #FotografiaNaturaleza ",
  usageCount: 15
}
```

---

## POSTING WORKFLOW (OPTIMIZED)

```
1. QUERY MONGODB
   ├── Get next template (rotation A→B→C)
   └── Get available groups (status != posted_today)

2. FOR EACH GROUP
   ├── browser_navigate(url)
   ├── browser_evaluate(checkMembership)  ←── 400 tokens
   ├── browser_evaluate(composeAndPost)   ←── 500 tokens
   ├── browser_evaluate(checkResult)      ←── 200 tokens
   └── mcp__mongodb__update(status)       ←── 50 tokens

3. ARCHIVE SESSION
   └── mcp__mongodb__insert(report)
```

**Total per post: ~1,150 tokens (was 225,000)**

---

## SECURITY (.gitignore)

```gitignore
# Secrets
.env
.env.*
*.pem
*.key
credentials.json

# Dependencies
node_modules/
.pnpm-store/

# Build
dist/
.next/
build/

# IDE
.idea/
.vscode/settings.json
```

---

## QUICK REFERENCE

```
MongoDB:  mcp__mongodb__find, update, insert, aggregate
Browser:  browser_navigate, browser_evaluate, browser_click
System:   Bash (git, npm, gh)

AVOID:    browser_snapshot (75K tokens)
USE:      browser_evaluate (500 tokens)

Templates: lain-wired-archives.promotion-templates
Groups:    lain-wired-archives.facebook-groups-joined
Reports:   lain-wired-archives.posting-performance-reports
```

**v9.0 - Simplified: Removed Orchestra MCP, ChromaDB, Lain Sub-Agent. MongoDB + Playwright only.**
