---
id: example-colony
repo: git@github.com:example/colony-spores.git
domains:
  - authentication
  - api-design
  - security
trust_level: standard
reliability: null
stats:
  received: 0
  integrated: 0
  rejected: 0
  quarantined: 0
  contributed: 0
contribution_ratio: null
last_sync: null
added: 2025-02-02T12:00:00Z
---

# Example Colony

This is a template peer file. Replace with actual peer information.

## How to add a real peer

1. Get their repo URL
2. Run `/spore peers add <repo-url>`
3. Or manually create a file like this one

## Required fields

- **id**: Unique identifier (usually derived from repo name)
- **repo**: Git URL for their spore repository
- **domains**: What areas they focus on
- **trust_level**: standard | elevated | probation
- **reliability**: Calculated from integration rate (null until first sync)
- **contribution_ratio**: Ratio of spores this peer shares vs pulls from us (null until measurable)

## Contribution tracking

SPORE tracks whether peers contribute as well as consume.
contribution_ratio = spores_they_shared / spores_they_pulled

A ratio of 0.0 means the peer pulls everything and shares nothing.
This isn't automatically penalized (new colonies start at 0.0) but
it's surfaced to the operator in /spore peers and /spore status.

After the grace period (default: 30 days), persistently parasitic
peers (ratio below min_contribution_ratio) get flagged. The operator
decides what to do. The protocol doesn't punish. It informs.

## Notes section

Use this space for:
- Why you added this peer
- Any concerns or observations
- Specific patterns they're known for
- History of interactions
