---
name: spore-validate
description: Test incoming spores and decide their fate
---

# /spore validate

Process spores in your inbox through validation.

## Usage

```
/spore validate                    Validate all inbox spores
/spore validate <spore-path>       Validate specific spore
/spore validate --interactive      Confirm each decision
```

## Process

For each spore in inbox:

1. Load spore content
2. Run validation checks via validator agent
3. Determine verdict: INTEGRATE, REJECT, or QUARANTINE
4. Move spore to appropriate directory
5. Update peer reliability stats
6. Log the decision

## Validation checks

The validator agent runs these in order:

1. **Integrity** - Does signature match content?
2. **Format** - Does it follow the spore schema?
3. **Conflict** - Does it contradict local evidence?
4. **Context** - Is the domain relevant to us?
5. **Diversity** - Would this increase pattern concentration?
6. **Source** - What's the peer's reliability?

## Output

```
/spore validate

Processing 4 spores in inbox...

[1/4] graveyard/aggressive-auth-001.md
  From: colony-alpha (reliability: 0.87)
  Checks:
    Integrity: PASS
    Format: PASS
    Conflict: PASS
    Context: PASS (domain: authentication)
    Diversity: PASS (pattern at 23%)
    Source: PASS
  VERDICT: INTEGRATE
  -> integrated/graveyard/aggressive-auth-001.md

[2/4] graveyard/timeout-cascade-002.md
  From: colony-alpha (reliability: 0.87)
  Checks:
    Integrity: PASS
    Format: PASS
    Conflict: WARN - partial overlap with local finding
    Context: PASS
    Diversity: PASS
    Source: PASS
  VERDICT: INTEGRATE (conflict noted but not strong)
  -> integrated/graveyard/timeout-cascade-002.md

[3/4] genome/balanced-validator-003.md
  From: colony-alpha (reliability: 0.87)
  Checks:
    Integrity: PASS
    Format: PASS
    Conflict: PASS
    Context: PASS
    Diversity: FAIL - pattern at 72%
  VERDICT: QUARANTINE (diversity risk)
  -> quarantine/genome/balanced-validator-003.md
  Review in 7 days or manually with /spore quarantine

[4/4] fitness/multi-objective-security.md
  From: colony-beta (reliability: 0.92)
  Checks:
    Integrity: FAIL - signature mismatch
  VERDICT: REJECT (corrupted or tampered)
  -> rejected/fitness/multi-objective-security.md

Summary:
  Integrated: 2
  Quarantined: 1
  Rejected: 1

Peer reliability updates:
  colony-alpha: 0.87 -> 0.87 (no change)
  colony-beta: 0.92 -> 0.91 (slight decrease)
```

## Interactive mode

Confirm each decision before acting:

```
/spore validate --interactive

[1/4] graveyard/aggressive-auth-001.md
  Recommended: INTEGRATE
  
  Accept? [Y]es / [N]o / [Q]uarantine / [S]kip
  > y
  
  -> integrated/graveyard/aggressive-auth-001.md
```

## Handling conflicts

When a spore conflicts with local evidence:

```
[2/4] graveyard/timeout-cascade-002.md
  CONFLICT DETECTED:
  
  Spore claims: "Connection pooling causes timeout cascades"
  Local evidence: "Connection pooling works fine (3 successful uses)"
  
  Options:
  [I] Integrate anyway (weak local evidence)
  [Q] Quarantine for review
  [R] Reject (trust local evidence)
  [D] Details (show full comparison)
  
  > d
  
  SPORE CLAIM:
  "Connection pooling with >50 connections causes cascading 
  timeouts under load. Observed in 4 separate timelines."
  
  LOCAL EVIDENCE:
  "Used connection pooling with 20 connections successfully 
  in 3 evolutions. No timeout issues observed."
  
  ANALYSIS:
  Spore describes >50 connections. Local tests used 20.
  Conditions may be different. Consider integrating with note.
  
  > i
  
  -> integrated/graveyard/timeout-cascade-002.md
  Note added: "Local experience differs at lower connection counts"
```

## Reviewing quarantine

Quarantined spores need manual review:

```
/spore quarantine

Quarantined spores (3):

[1] genome/balanced-validator-003.md
    Reason: Diversity risk (pattern at 72%)
    From: colony-alpha
    Added: 2 days ago
    Review deadline: 5 days

[2] fitness/aggressive-speed.md
    Reason: Peer on probation
    From: colony-gamma
    Added: 5 days ago
    Review deadline: 2 days

[3] governance/rotating-critic.md
    Reason: Governance spores need explicit approval
    From: colony-beta
    Added: 1 day ago
    No deadline (governance)

Select spore to review: 1

[Detailed view of spore]

Actions:
[I] Integrate now
[R] Reject
[E] Extend quarantine (7 more days)
[K] Keep in quarantine
```
