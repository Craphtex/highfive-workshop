---
name: spore-quarantine
description: Review and manage quarantined spores
---

# /spore quarantine

Manage spores that need manual review before integration or rejection.

## Usage

```
/spore quarantine                    List all quarantined spores
/spore quarantine <spore-id>         Review specific spore
/spore quarantine --expired          Show spores past review deadline
/spore quarantine clear              Process all expired quarantine items
```

## Why spores get quarantined

Spores land in quarantine when:
- **Diversity risk**: Pattern already dominant in network (>70%)
- **Conflict detected**: Contradicts local evidence but not conclusively
- **Unknown origin**: Peer not in your peer list
- **Low confidence**: Source peer has low reliability score
- **Governance type**: All governance spores require explicit approval
- **Suspicious pattern**: Validator flagged something unusual

## Listing quarantine

```
/spore quarantine

QUARANTINED SPORES (4)

[1] genome/balanced-validator-003.md
    Reason: Diversity risk (pattern at 72%)
    From: colony-alpha (reliability: 0.87)
    Added: 2 days ago
    Deadline: 5 days remaining
    
[2] fitness/aggressive-speed.md
    Reason: Source on probation
    From: colony-gamma (reliability: 0.52)
    Added: 5 days ago
    Deadline: 2 days remaining
    
[3] governance/rotating-critic.md
    Reason: Governance requires explicit approval
    From: colony-beta (reliability: 0.91)
    Added: 1 day ago
    Deadline: None (governance)

[4] graveyard/unusual-failure.md
    Reason: Conflicts with local evidence
    From: colony-alpha (reliability: 0.87)
    Added: 6 days ago
    Deadline: 1 day remaining

Select [1-4] to review, or 'q' to quit:
```

## Reviewing a spore

```
/spore quarantine 1

QUARANTINE REVIEW: genome/balanced-validator-003.md
══════════════════════════════════════════════════════

FROM: colony-alpha
RELIABILITY: 0.87
QUARANTINE REASON: Diversity risk (pattern at 72%)

SPORE CONTENT:
─────────────────────────────────────────────────────
type: genome
origin: colony-alpha
confidence: 0.80
context:
  domain: api-design
  environment: Node.js, Express

# Balanced API validator

Traits: analytical(0.7), defensive(0.65), methodical(0.75)
Skills: api-design, testing

Heritage: "Defense in depth. Validate early, fail gracefully."

Survived: 8 generations
─────────────────────────────────────────────────────

DIVERSITY ANALYSIS:
  This pattern type: "defensive-methodical"
  Currently in network: 72% of integrated genomes
  If integrated: Would increase to 74%
  Threshold: 70%
  
  Similar patterns already integrated:
  - defensive-api-handler (colony-beta)
  - methodical-validator (local)
  - cautious-processor (colony-alpha)

RECOMMENDATION:
  Consider whether this adds unique value beyond existing patterns.
  The heritage prompt differs slightly from others.

ACTIONS:
  [I] Integrate anyway (accept diversity risk)
  [R] Reject (too similar to existing)
  [E] Extend quarantine (7 more days)
  [D] Defer to network (wait for diversity to decrease)
  [C] Compare with similar patterns
  [Q] Back to list

> c

COMPARISON: balanced-validator-003 vs existing patterns
─────────────────────────────────────────────────────

                    | balanced-validator-003 | defensive-api-handler | methodical-validator
─────────────────────────────────────────────────────
analytical          | 0.70                   | 0.65                  | 0.60
defensive           | 0.65                   | 0.75                  | 0.55
methodical          | 0.75                   | 0.60                  | 0.85
creative            | 0.35                   | 0.20                  | 0.25
generations         | 8                      | 6                     | 7

UNIQUE ASPECTS of balanced-validator-003:
  + Higher analytical trait
  + More balanced defensive/methodical ratio
  + Different heritage prompt focus

> i

Integrating with diversity warning noted.
Moved to: integrated/genome/balanced-validator-003.md
Logged: Diversity threshold exceeded, integrated per user decision.
```

## Handling conflicts

```
/spore quarantine 4

QUARANTINE REVIEW: graveyard/unusual-failure.md
══════════════════════════════════════════════════════

QUARANTINE REASON: Conflicts with local evidence

SPORE CLAIMS:
  Pattern: "connection pooling with >20 connections causes issues"
  Context: High-traffic API
  Confidence: 0.71
  Observations: 7

LOCAL EVIDENCE:
  Pattern: "connection pooling with 30 connections works fine"
  Context: Medium-traffic API
  Observations: 3 successful evolutions

CONFLICT ANALYSIS:
  Spore says: >20 connections = problem
  Local experience: 30 connections = no problem
  
  Possible explanations:
  1. Different traffic levels (spore: high, local: medium)
  2. Different database backends
  3. Different connection timeout settings
  4. Local sample size too small (3 vs 7)

ACTIONS:
  [I] Integrate (trust network over local)
  [R] Reject (trust local over network)
  [M] Merge (create nuanced pattern)
  [T] Test locally (run experiment)
  [E] Extend quarantine

> m

Creating merged pattern...

MERGED PATTERN:
  "Connection pooling behavior depends on traffic level.
   High traffic (>1000 req/s): Keep pool <20 connections
   Medium traffic (<1000 req/s): Up to 50 connections safe
   Source: network + local evidence"

Save merged pattern? [Y/n] > y

Created: integrated/graveyard/connection-pool-nuanced.md
Original spore archived in: quarantine/resolved/
```

## Expired quarantine

```
/spore quarantine --expired

EXPIRED QUARANTINE ITEMS (2)

These spores have passed their review deadline:

[1] fitness/aggressive-speed.md
    Expired: 2 days ago
    Reason: Source on probation
    Auto-action: REJECT (low-reliability source, no review)

[2] graveyard/unusual-failure.md
    Expired: 1 day ago  
    Reason: Conflict with local evidence
    Auto-action: DEFER (keep in quarantine, extend deadline)

Process expired items with defaults? [Y/n] > y

Processing...
  aggressive-speed.md -> rejected/
  unusual-failure.md -> deadline extended 7 days

Done. 1 rejected, 1 extended.
```

## Quarantine policies

Configure defaults in config.md:

```yaml
quarantine:
  review_days: 7                    # Default deadline
  expired_action_low_reliability: reject
  expired_action_conflict: extend
  expired_action_diversity: extend
  expired_action_governance: keep   # Never auto-process
  
  # Auto-release conditions
  auto_release_if_diversity_drops: true
  diversity_release_threshold: 0.60  # Release if pattern drops below this
```

## Bulk operations

```
/spore quarantine clear

Processing all actionable quarantine items...

AUTO-RELEASING (diversity dropped below threshold):
  - balanced-validator-003.md (was 72%, now 65%)
  -> integrated/

AUTO-REJECTING (expired + low reliability):
  - aggressive-speed.md
  -> rejected/

EXTENDING (expired but valuable source):
  - unusual-failure.md (+7 days)

SKIPPING (governance, requires manual):
  - rotating-critic.md

Summary:
  Released: 1
  Rejected: 1
  Extended: 1
  Skipped: 1
```
