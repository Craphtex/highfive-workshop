---
name: spore-rollback
description: Revert a spore integration and undo its effects on local knowledge
---

# /spore rollback

Undo a spore integration. Removes the spore's effects from FLUX
knowledge, restores previous state, and logs the rollback to the
Ledger for traceability.

## Usage

```
/spore rollback <spore-id>            Rollback a specific integration
/spore rollback --last                Rollback the most recent integration
/spore rollback --from <colony-id>    Rollback all spores from a peer
/spore rollback --dry-run <spore-id>  Show what would change without doing it
```

## Standard rollback

```
/spore rollback aggressive-api-handler

ROLLBACK: aggressive-api-handler
─────────────────────────────────

Spore details:
  Type: graveyard
  Origin: colony-beta
  Integrated: 2025-01-20T09:15:00Z (13 days ago)
  Confidence at integration: 0.68

What this spore changed when integrated:
  1. Added pattern to .claude/flux/known-bad-patterns.md:
     "aggressive > 0.8 AND methodical < 0.2 fails on API design"
  2. Updated colony-beta reliability score (+0.01)
  3. Logged to Ledger: NETWORK_KNOWLEDGE_APPLIED

Reverting these changes:

  [1/3] Removing pattern from known-bad-patterns.md
        Pattern: aggressive > 0.8 AND methodical < 0.2
        Context: api-design
        REMOVED

  [2/3] Adjusting colony-beta reliability
        0.88 -> 0.87 (reversed integration credit)
        UPDATED

  [3/3] Creating Ledger entry
        Decision: NETWORK_KNOWLEDGE_ROLLED_BACK
        Reason: Manual rollback by operator
        Original integration: 2025-01-20T09:15:00Z
        LOGGED

Moving spore to: .claude/spore/rejected/graveyard/aggressive-api-handler.md
Reason recorded: Rolled back by operator

ROLLBACK COMPLETE

Note: Any evolutions that were influenced by this pattern between
integration and now are not automatically re-run. Check if recent
evolutions need revisiting.
```

## Dry run

```
/spore rollback --dry-run aggressive-api-handler

DRY RUN (no changes will be made)

Would revert:
  1. Remove pattern from known-bad-patterns.md
     "aggressive > 0.8 AND methodical < 0.2" in context "api-design"
  2. Adjust colony-beta reliability: 0.88 -> 0.87
  3. Move spore to rejected/
  4. Log rollback to Ledger

Evolutions potentially affected:
  - api-handler-evolution-003 (ran 5 days ago, avoided this pattern)
    This evolution may have produced different results without the pattern.
```

## Rollback last integration

```
/spore rollback --last

Most recent integration:
  Spore: balanced-validator-v3 (genome)
  From: colony-alpha
  Integrated: 2 hours ago

This genome was added to .claude/flux/genome/imported/

Rollback? [Y/n] > y

  [1/2] Removing genome from imported pool
        REMOVED

  [2/2] Logging to Ledger
        LOGGED

ROLLBACK COMPLETE
```

## Rollback all from peer

Use when a peer turns out to be unreliable:

```
/spore rollback --from colony-gamma

WARNING: This will rollback ALL integrated spores from colony-gamma.

Spores from colony-gamma currently integrated: 8
  - 5 graveyard spores (patterns in known-bad-patterns.md)
  - 2 genome spores (in imported gene pool)
  - 1 fitness spore (in imported fitness functions)

This will:
  - Remove 5 patterns from known-bad-patterns.md
  - Remove 2 genomes from gene pool
  - Remove 1 fitness function
  - Set colony-gamma reliability to 0.00
  - Move all 8 spores to rejected/
  - Log 8 rollback entries to Ledger

Proceed? [Y/n] > y

Rolling back 8 spores...
  [1/8] chaotic-test-pattern: ROLLED BACK
  [2/8] unstable-handler-002: ROLLED BACK
  [3/8] frontend-crash-001: ROLLED BACK
  [4/8] inconsistent-api-003: ROLLED BACK
  [5/8] experimental-renderer: ROLLED BACK
  [6/8] reactive-component-v2: ROLLED BACK
  [7/8] aggressive-prototype: ROLLED BACK
  [8/8] speed-first-fitness: ROLLED BACK

colony-gamma reliability set to 0.00
Consider removing peer: /spore peers remove colony-gamma

ROLLBACK COMPLETE
8 spores rolled back, Ledger updated.
```

## What rollback tracks

Every rollback creates a Ledger entry:

```yaml
decision: NETWORK_KNOWLEDGE_ROLLED_BACK
spore_id: aggressive-api-handler
origin: colony-beta
type: graveyard
integrated_at: 2025-01-20T09:15:00Z
rolled_back_at: 2025-02-02T15:45:00Z
reason: Manual rollback by operator
effects_reversed:
  - removed pattern from known-bad-patterns.md
  - adjusted peer reliability
potentially_affected_evolutions:
  - api-handler-evolution-003
```

This ensures Ancestry Audits can trace rollbacks. If a future
evolution fails and the audit finds it would have benefited from
a rolled-back pattern, the Ledger shows why the pattern was removed.

## Rollback limits

Rollback can reverse:
- Pattern additions to known-bad-patterns.md
- Genome additions to imported gene pool
- Fitness function additions
- Peer reliability adjustments

Rollback cannot reverse:
- Evolutions already completed under the influence of the spore
- Governance changes (these require Council review to revert)
- Confidence updates to other spores based on this one
- Knowledge that was forwarded to other peers before rollback

For governance rollbacks, use the METAMORPHOSIS Council process
instead of /spore rollback.
