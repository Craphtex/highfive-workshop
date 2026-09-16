---
name: spore-coverage
description: Show domain coverage and gaps in network knowledge
---

# /spore coverage

Analyze what domains the network covers well and where gaps exist.
Helps identify which peers to seek and where your colony can contribute.

## Usage

```
/spore coverage                 Full coverage report
/spore coverage <domain>        Detail for a specific domain
/spore coverage --gaps          Show only gaps and sparse areas
/spore coverage --sources       Show coverage by source colony
```

## Full report

```
/spore coverage

NETWORK KNOWLEDGE COVERAGE
───────────────────────────

WELL COVERED (10+ spores, multiple sources):
  ✓ api-design       48 spores  5 sources  ████████████████████
  ✓ authentication   31 spores  4 sources  █████████████░░░░░░░
  ✓ testing          28 spores  3 sources  ████████████░░░░░░░░

MODERATE (5-10 spores):
  ~ databases        9 spores   2 sources  ████░░░░░░░░░░░░░░░░
  ~ security         7 spores   3 sources  ███░░░░░░░░░░░░░░░░░
  ~ error-handling   6 spores   2 sources  ██░░░░░░░░░░░░░░░░░░

SPARSE (<5 spores):
  ! frontend         3 spores   1 source   █░░░░░░░░░░░░░░░░░░░
  ! devops           2 spores   1 source   █░░░░░░░░░░░░░░░░░░░
  ! performance      1 spore    1 source   ░░░░░░░░░░░░░░░░░░░░

NO COVERAGE:
  - machine-learning
  - mobile
  - infrastructure

SPORE TYPE BREAKDOWN:
  Graveyard:  72 (57%) - good failure coverage
  Genomes:    41 (32%) - decent success patterns
  Fitness:    12 (9%)  - limited evaluation functions
  Governance:  2 (2%)  - minimal (expected)

RECOMMENDATIONS:
  - Seek peers specializing in: frontend, devops, performance
  - Your colony could contribute more to: databases (you have
    local expertise but few shared spores)
  - Consider sharing fitness functions (network has few)
```

## Domain detail

```
/spore coverage authentication

DOMAIN: authentication
──────────────────────

SPORES (31 total):

  Graveyard (18):
    - aggressive-auth-001 [0.76] colony-alpha
    - jwt-short-expiry [0.68] colony-beta
    - no-refresh-token [0.71] colony-alpha
    - session-leak-003 [0.82] local
    ... and 14 more

  Genomes (9):
    - balanced-auth-validator [0.80] colony-alpha
    - secure-session-handler [0.75] colony-beta
    - jwt-refresh-variant [0.70] colony-alpha
    ... and 6 more

  Fitness (3):
    - multi-objective-security [0.65] colony-alpha
    - auth-speed-balance [0.55] colony-gamma
    - session-robustness [0.60] local

  Governance (1):
    - auth-review-process [0.50] colony-beta

KNOWLEDGE GAPS within authentication:
  - OAuth / social login (no spores)
  - Biometric authentication (no spores)
  - Multi-factor authentication (2 graveyard only, no genomes)

FRESHNESS:
  Fresh: 24 spores
  Stale: 5 spores (oldest: 142 days)
  Run /spore revalidate authentication to refresh

SOURCES:
  colony-alpha: 14 spores (45%)
  colony-beta: 8 spores (26%)
  local: 6 spores (19%)
  colony-gamma: 3 spores (10%)
```

## Gaps only

```
/spore coverage --gaps

KNOWLEDGE GAPS
──────────────

DOMAINS WITH NO COVERAGE:
  machine-learning, mobile, infrastructure

DOMAINS WITH SPARSE COVERAGE:
  frontend (3 spores, 1 source only)
  devops (2 spores, 1 source only)
  performance (1 spore, 1 source only)

TYPE GAPS:
  Fitness functions: Only 12 total across all domains
    - No fitness functions for: databases, frontend, devops
  Governance: Only 2 total (expected to be low)

SINGLE-SOURCE RISK:
  These domains depend on one colony only:
  - frontend: colony-gamma only
  - devops: colony-delta only
  - performance: colony-delta only

  If these peers go offline, coverage drops to zero.

RECOMMENDED ACTIONS:
  1. Seek 1-2 peers with frontend/devops expertise
  2. Share your local fitness functions (network needs more)
  3. Contribute local graveyard entries for sparse domains
```

## By source

```
/spore coverage --sources

COVERAGE BY SOURCE
──────────────────

colony-alpha (47 spores, reliability: 0.87)
  Strongest: authentication (14), api-design (18)
  Weakest: no testing or database spores
  Unique: Only source for OAuth patterns

colony-beta (38 spores, reliability: 0.91)
  Strongest: testing (15), databases (12)
  Weakest: no security spores
  Unique: Only source for database migration patterns

colony-gamma (12 spores, reliability: 0.65)
  Strongest: frontend (3), api-design (5)
  Weakest: low volume across all domains
  Note: Low reliability, consider probation

colony-delta (7 spores, reliability: 0.78)
  Strongest: devops (2), performance (1)
  Weakest: limited coverage overall
  Unique: Only source for infrastructure patterns

local (23 spores)
  Strongest: api-design (10), authentication (6)
  Contributed but not shared: 8 learnings in outbox
```
