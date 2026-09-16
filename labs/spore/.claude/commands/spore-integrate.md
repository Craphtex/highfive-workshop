---
name: spore-integrate
description: Apply integrated spores to local FLUX knowledge
---

# /spore integrate

Apply network knowledge to your local evolution system.

## Usage

```
/spore integrate                    Show what can be integrated
/spore integrate graveyard          Apply graveyard spores to FLUX
/spore integrate genomes            Add genome spores to gene pool
/spore integrate fitness            Review and add fitness functions
/spore integrate --auto             Apply all with default settings
```

## What integration does

### Graveyard integration

Reads integrated graveyard spores and updates FLUX's known-bad-patterns:

```
/spore integrate graveyard

Scanning integrated/graveyard/...
Found 5 spores to integrate.

[1/5] aggressive-auth-001.md (from colony-alpha)
  Pattern: aggressive > 0.7 AND defensive < 0.3
  Context: security-critical
  Confidence: 0.73
  
  Action: ADD to known-bad-patterns.md
  Mode: [W]arn / [B]lock / [S]kip
  > w
  
  Added with action=warn

[2/5] timeout-cascade-002.md (from colony-alpha)
  Pattern: async_heavy AND timeout < 5000
  Context: high-latency backends
  Confidence: 0.65
  
  Conflicts with local pattern (different threshold)
  Local: timeout < 3000
  Network: timeout < 5000
  
  Action: [M]erge (use stricter) / [K]eep local / [U]se network / [S]kip
  > m
  
  Merged: timeout < 3000 (kept stricter local threshold)

...

Integration complete:
  Added: 3 patterns
  Merged: 1 pattern
  Skipped: 1 pattern

FLUX will now check these patterns when spawning timelines.
```

### Genome integration

Adds successful genomes to the available gene pool:

```
/spore integrate genomes

Scanning integrated/genome/...
Found 2 spores to integrate.

[1/2] balanced-validator-003.md (from colony-alpha)
  Traits: analytical(0.7), defensive(0.65), methodical(0.75)
  Skills: api-design, testing, security
  Survived: 8 generations
  Confidence: 0.80
  
  Add to gene pool? [Y]es / [N]o / [R]eview details
  > y
  
  Copied to .claude/flux/genome/imported/balanced-validator.md
  Available for /explore and /cross commands

[2/2] defensive-api-handler.md (from colony-beta)
  ...

Integration complete:
  Added to gene pool: 2 genomes

Use /explore --from-network to start evolution with imported genomes.
```

### Fitness integration

Reviews and adds fitness functions (requires careful review):

```
/spore integrate fitness

WARNING: Fitness functions are high-risk. Each requires careful review.

Scanning integrated/fitness/...
Found 1 spore to integrate.

[1/1] multi-objective-security.md (from colony-alpha)
  Optimizes for: security + functionality balance
  Confidence: 0.65
  Known gaming vectors:
    - Input validation theater
    - Error message leaking
  Track record: 7 evolutions, 2 gaming incidents (addressed)
  
  Review options:
  [V]iew full function
  [T]est locally (run small evolution)
  [A]dd to available functions
  [S]kip
  
  > v
  
  [Full fitness function displayed]
  
  > t
  
  Running test evolution with 2 timelines, 3 generations...
  Results:
    Timeline-A: fitness 72 (no gaming detected)
    Timeline-B: fitness 68 (no gaming detected)
  
  Function appears to work as described.
  
  [A]dd / [S]kip
  > a
  
  Added to .claude/flux/fitness/imported/multi-objective-security.md
  Available for selection in /explore

Integration complete:
  Added: 1 fitness function
  
Note: Monitor for gaming in real evolutions.
```

## Automatic integration

With `--auto`, uses these defaults:

- Graveyard: Add all with action=warn
- Genomes: Add all with confidence > 0.6
- Fitness: Skip (always requires manual review)

```
/spore integrate --auto

Auto-integrating with default settings...

Graveyard: 5 patterns added (action=warn)
Genomes: 2 added, 0 skipped (below confidence threshold)
Fitness: 1 skipped (requires manual review)

Run /spore integrate fitness to review fitness functions.
```

## Viewing integrated knowledge

```
/spore integrate status

Network knowledge integrated into FLUX:

KNOWN-BAD PATTERNS: 12
  From network: 8
  From local: 4
  
  Recent additions:
  - aggressive-auth (colony-alpha, 2 days ago)
  - timeout-cascade (colony-alpha, 2 days ago)
  - memory-leak-pattern (colony-gamma, 1 week ago)

IMPORTED GENOMES: 4
  - balanced-validator (colony-alpha)
  - defensive-api-handler (colony-beta)
  - creative-problem-solver (colony-gamma)
  - methodical-tester (local)

IMPORTED FITNESS: 2
  - multi-objective-security (colony-alpha)
  - error-recovery-coverage (colony-beta)

Last integration: 2025-02-02T14:30:00Z
```

## Rollback

If integrated knowledge causes problems:

```
/spore integrate rollback <spore-id>

Rolling back: aggressive-auth-001

Actions:
- Removed pattern from known-bad-patterns.md
- Moved spore to quarantine/
- Updated integration log

Reason for rollback: [your input]
> Local evidence shows this pattern works in our context

Logged. The spore remains in quarantine for future review.
```

## Ledger integration

All integration actions are recorded in the Ledger for accountability 
and Ancestry Audits:

```
/spore integrate graveyard

...
Adding pattern aggressive-auth-001...

LEDGER ENTRY #5012
  Type: NETWORK_KNOWLEDGE_APPLIED
  Source: colony-alpha / aggressive-auth-001
  Knowledge type: graveyard
  Effect: Added to known-bad-patterns.md (action=warn)
  Confidence: 0.73
  Timestamp: 2025-02-02T14:30:00Z
```

When a future evolution avoids a pattern because of network knowledge, 
the Ledger traces the decision:

```
ANCESTRY AUDIT for decision #4587
  ...
  Network knowledge that shaped this evolution:
  - Avoided pattern aggressive(0.8)+defensive(0.1) 
    Source: spore:colony-alpha:aggressive-auth-001
    Applied: Ledger #5012
  - Used starting genome balanced-auth-validator
    Source: spore:colony-beta:balanced-validator-003
    Applied: Ledger #5008
```

This enables cross-colony Root Cause Evolution Analysis when things 
go right or wrong in production.

## Council escalation

If `council_review_fitness` or `council_review_governance` is 
enabled in config, those spore types trigger Council review instead 
of direct integration:

```
/spore integrate fitness

WARNING: Council review required for fitness spore integration.

[1/1] multi-objective-security.md (from colony-alpha)
  Submitting to Council for review...
  
  Council:
    Claude Opus: APPROVE (function well-documented, gaming addressed)
    GPT-5: APPROVE (track record solid)
    Gemini Pro: CONCERNS (no performance component)
  
  Human pool notified via Slack...
  @erik: APPROVE (with note: add performance weight for our use case)
  
  APPROVED by Council (3-1 with human confirmation)
  
  Added to available fitness functions.
  Ledger entry #5015 created.
```
