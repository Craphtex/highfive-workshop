---
name: spore-status
description: Show overview of colony's network status and knowledge
---

# /spore status

Get a complete overview of your colony's SPORE network status.

## Usage

```
/spore status                   Full status overview
/spore status --brief           One-line summary
/spore status --peers           Focus on peer health
/spore status --knowledge       Focus on integrated knowledge
/spore status --pending         Focus on items needing attention
```

## Full status

```
/spore status

╔══════════════════════════════════════════════════════════════╗
║                    SPORE COLONY STATUS                       ║
║                    my-colony @ 2025-02-02                    ║
╚══════════════════════════════════════════════════════════════╝

COLONY IDENTITY
───────────────
  Colony ID: my-colony
  Repository: git@github.com:me/my-colony-spores.git
  Domains: api-design, testing, databases
  Active since: 2025-01-15 (18 days)

NETWORK HEALTH
───────────────
  Peers: 4 connected
    ✓ colony-alpha (0.87) - synced 2h ago - contrib 0.34
    ✓ colony-beta (0.91) - synced 5h ago - contrib 0.52
    ✓ colony-gamma (0.65) - synced 1d ago [LOW RELIABILITY] [PARASITIC]
    ✓ colony-delta (0.78) - synced 3h ago - contrib 0.21
  
  Average reliability: 0.80
  Network diversity: HEALTHY (max pattern: 34%)
  Corroboration: 78% of patterns have 2+ independent sources

PROVENANCE CHAIN
───────────────
  Status: ENABLED
  Entries: 1,247 (last verified: 2h ago)
  Integrity: VERIFIED
  Independence checks available: yes

KNOWLEDGE BASE
───────────────
  Total integrated: 127 spores
    Graveyard: 72 (patterns to avoid)
    Genomes: 41 (successful patterns)
    Fitness: 12 (evaluation functions)
    Governance: 2 (institutional patterns)

  By domain:
    api-design: 48 spores ████████████████░░░░ 38%
    testing: 31 spores    ██████████░░░░░░░░░░ 24%
    databases: 28 spores  █████████░░░░░░░░░░░ 22%
    authentication: 20    ██████░░░░░░░░░░░░░░ 16%

PENDING ACTIONS
───────────────
  Inbox: 3 spores awaiting validation
  Quarantine: 4 spores awaiting review (1 expired)
  Outbox: 2 spores ready to push

  Run /spore validate to process inbox
  Run /spore quarantine to review quarantine
  Run git push to publish outbox

CONTRIBUTIONS
───────────────
  Spores contributed: 23
  Spores received: 127
  Contribution ratio: 0.18 (consider sharing more)
  
  Your most-adopted spores:
    1. defensive-api-pattern (integrated by 3 peers)
    2. timeout-handling-fix (integrated by 2 peers)

FLUX INTEGRATION
───────────────
  Known-bad patterns: 68 (from network)
  Imported genomes: 12 (available in gene pool)
  Imported fitness: 4 (available for evolution)
  
  Last FLUX evolution: 2 days ago
  Network knowledge used: Yes (avoided 3 bad patterns)

FRESHNESS
───────────────
  Fresh (validated within 90 days): 112 spores
  Stale (overdue for revalidation): 11 spores
  Deprecated (confidence reduced): 4 spores
  
  Oldest unvalidated: jwt-timeout-cascade (147 days)
  Run /spore revalidate --stale to refresh

CONSERVATION
───────────────
  Protected local patterns: 2
    - aggressive-prototype (speed over safety for throwaway code)
    - custom-error-format (local convention, network prefers standard)
  Override requires: human approval

ALERTS
───────────────
  ⚠ colony-gamma reliability below threshold (0.65 < 0.70)
  ⚠ colony-gamma zero contribution after grace period [PARASITIC]
  ⚠ 1 quarantine item expired, needs review
  ⚠ 11 stale spores need revalidation
  ℹ 3 new spores in inbox since last validation
  ℹ 22% of patterns from single source only (no corroboration)
```

## Brief status

```
/spore status --brief

SPORE: 4 peers | 127 integrated | 3 inbox | 4 quarantine | healthy
```

## Peer focus

```
/spore status --peers

PEER STATUS
═══════════

colony-alpha
  Reliability: 0.87 ████████▋░ 
  Last sync: 2 hours ago
  Spores received: 47 (41 integrated, 4 rejected, 2 quarantined)
  Domains: authentication, api-design, security
  Status: HEALTHY
  
colony-beta
  Reliability: 0.91 █████████░
  Last sync: 5 hours ago
  Spores received: 38 (35 integrated, 2 rejected, 1 quarantined)
  Domains: testing, databases, performance
  Status: HEALTHY

colony-gamma
  Reliability: 0.65 ██████▌░░░
  Last sync: 1 day ago
  Spores received: 25 (16 integrated, 6 rejected, 3 quarantined)
  Domains: frontend, ui-design
  Status: PROBATION (reliability below 0.70)
  Note: Consider removing if reliability doesn't improve

colony-delta
  Reliability: 0.78 ███████▊░░
  Last sync: 3 hours ago
  Spores received: 17 (14 integrated, 2 rejected, 1 quarantined)
  Domains: devops, infrastructure
  Status: HEALTHY

RECOMMENDATIONS:
  - colony-gamma needs attention (low reliability)
  - Consider seeking peers for: machine-learning, mobile (gaps in coverage)
```

## Knowledge focus

```
/spore status --knowledge

INTEGRATED KNOWLEDGE
════════════════════

BY TYPE:
  Graveyard (72 spores)
    Most common failure: aggressive + low-defensive (12 instances)
    Domains covered: api-design, auth, databases, testing
    Unique patterns: 45
    
  Genomes (41 spores)
    Most successful: balanced-defensive patterns
    Average survival: 6.3 generations
    Domains covered: api-design, testing, auth
    
  Fitness (12 spores)
    Multi-objective: 8
    Single-objective: 4
    Gaming incidents reported: 3 (all addressed)
    
  Governance (2 spores)
    critic-rotation (from colony-beta)
    senate-veto-rules (from colony-alpha)

BY SOURCE:
  colony-alpha: 47 spores (37%)
  colony-beta: 38 spores (30%)
  local: 23 spores (18%)
  colony-gamma: 12 spores (9%)
  colony-delta: 7 spores (6%)

DIVERSITY CHECK:
  Pattern concentration:
    "defensive-methodical": 34% ✓ (below 70% threshold)
    "analytical-testing": 22% ✓
    "cautious-security": 18% ✓
  
  Source concentration:
    colony-alpha: 37% ✓ (below 50% threshold)
  
  Status: HEALTHY DIVERSITY

GAPS IDENTIFIED:
  - Few spores about: performance optimization
  - No spores about: mobile development, ML pipelines
  - Consider: seeking specialized peers
```

## Pending items focus

```
/spore status --pending

ITEMS NEEDING ATTENTION
═══════════════════════

INBOX (3 spores) - Run /spore validate
─────────────────────────────────────
  graveyard/race-condition-001.md (colony-alpha, 2h ago)
  genome/fast-validator.md (colony-beta, 5h ago)
  fitness/speed-focused.md (colony-delta, 3h ago)

QUARANTINE (4 spores) - Run /spore quarantine
─────────────────────────────────────────────
  ⚠ fitness/aggressive-speed.md - EXPIRED 2 days ago
  genome/balanced-validator-003.md - 5 days remaining
  governance/rotating-critic.md - no deadline (governance)
  graveyard/unusual-failure.md - 1 day remaining

OUTBOX (2 spores) - Run git push
────────────────────────────────
  graveyard/timeline-gamma-auth.md (packaged today)
  genome/improved-api-handler.md (packaged yesterday)

RECOMMENDATIONS:
  1. Process expired quarantine item first
  2. Validate inbox before it grows
  3. Push outbox to share your learnings
  
Estimated time: 10 minutes
```

## Status in scripts

For automation, use machine-readable output:

```bash
/spore status --json

{
  "colony_id": "my-colony",
  "peers": {
    "count": 4,
    "healthy": 3,
    "probation": 1
  },
  "knowledge": {
    "total": 127,
    "graveyard": 72,
    "genome": 41,
    "fitness": 12,
    "governance": 2
  },
  "pending": {
    "inbox": 3,
    "quarantine": 4,
    "quarantine_expired": 1,
    "outbox": 2
  },
  "health": {
    "diversity": "healthy",
    "peer_reliability_avg": 0.80,
    "contribution_ratio": 0.18,
    "corroboration_rate": 0.78,
    "single_source_patterns": 0.22,
    "parasitic_peers": ["colony-gamma"]
  },
  "chain": {
    "enabled": true,
    "entries": 1247,
    "integrity": "verified",
    "last_verified": "2025-02-02T12:00:00Z"
  },
  "freshness": {
    "fresh": 112,
    "stale": 11,
    "deprecated": 4,
    "oldest_unvalidated_days": 147
  },
  "conservation": {
    "protected_patterns": 2,
    "override_requires": "human"
  },
  "alerts": [
    "colony-gamma reliability below threshold",
    "colony-gamma zero contribution after grace period",
    "1 quarantine item expired",
    "11 stale spores need revalidation"
  ]
}
```
