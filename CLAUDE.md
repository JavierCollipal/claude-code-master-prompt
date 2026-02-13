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

## SESSION LIMITS (TETORA-001)

| Limit | Value |
|-------|-------|
| Posts/session | 50 |
| Posts/hour | 30 |
| Joins/session | **20** |
| Joins/day | **20** |
| Delay between posts | 2-5 sec |
| Delay between joins | 3-5 min (random) |

---

## R22: RATE LIMIT TRACKING & RECOVERY

**CRITICAL**: Facebook has COMBINED daily action limit. Posts + Joins + Comments share quota.

### Proven Rate Limit Patterns

| Date | Posts Before | Joins Allowed | Pattern |
|------|--------------|---------------|---------|
| 2026-02-07 | 0 | 76 | Discovery-only day = max joins |
| 2026-02-13 | 47 | 0 | Posts consumed entire budget |

**Insight**: ~75-80 total daily actions. Mix strategically.

### Strategy: Don't Mix High-Volume Days

```
POSTING DAY:     50 posts max → Save discovery for tomorrow
DISCOVERY DAY:   0 posts      → 30+ joins allowed
HYBRID DAY:      25 posts + 15 joins (conservative)
```

---

## R24: HUMAN BEHAVIOR OPTIMIZATION (Research-Based 2026)

### Personality Research Summary

**NEKO-ARC (Tech Lead)** - [Hootsuite](https://blog.hootsuite.com/facebook-algorithm/) | [GroupBoss](https://groupboss.io/blog/facebook-group-best-practices/)
> "Automate mechanical tasks, but personally handle engagement. The human touch builds real relationships."

- Consistent posters get 5x more engagement than inconsistent
- Reply to comments within 24 hours signals active engagement
- Avoid engagement bait ("like if you agree")

**TETORA (Security Guard)** - [Linken Sphere](https://ls.app/blog/why-facebook-bans-happen-and-how-to-prevent-them) | [Storyy](https://storyy.co/2025/04/24/facebooks-2025-spam-crackdown-key-changes-protection-tips/)
> "OSSU! Real people scroll unevenly, get distracted, change pace. Sterile activity = bot flag!"

- Facebook tracks: identical timings, lack of scrolling, no cursor movement
- Unusual activity bursts catch attention FAST
- Spam signals are CUMULATIVE (automation + copy/paste + hashtags)
- Human + AI review partnership in 2025-2026

**LAIN (Memory/Data)** - [Sprout Social](https://sproutsocial.com/insights/social-media-metrics/) | [Planable](https://planable.io/blog/social-media-kpis/)
> "In 2026, likes and impressions are deprecated. Track SAVES, SHARES, and meaningful comments."

- Meta phasing out surface-level metrics
- Priority KPIs: Saves > Shares > Comments > Reactions
- Target engagement rate: 2-5%

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
  humanScore: 0.92
}
```

---

## DATABASES

### MongoDB: lain-wired-archives

```
├── facebook-groups-joined     → Groups data
├── promotion-templates        → A/B/C templates
├── posting-performance-reports → Session history
├── rate-limit-events          → Rate limit tracking
├── discovery-queue            → Groups pending join
└── engagement-farming-log     → Farming sessions
```

---

**v10.7 - R24: Human Behavior Optimization. Research-based 2026. NEKO-ARC + TETORA + LAIN consensus.**
