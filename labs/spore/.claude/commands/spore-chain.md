---
name: spore-chain
description: View and verify the provenance chain
---

# /spore chain

Inspect the shared provenance chain that records all network
interactions: publishes, pulls, integrations, and rejections.

## Usage

```
/spore chain                     Show chain status summary
/spore chain verify              Verify full chain integrity
/spore chain inspect <spore-id>  Show all chain entries for a spore
/spore chain independence <spore-id>  Check independence of confirmations
/spore chain log [--last N]      Show recent chain entries
```

## Chain status

Show overall chain health:

```
/spore chain

PROVENANCE CHAIN
═══════════════════════════════════

  Chain repo: git@github.com:network/spore-chain.git
  Local cache: .claude/spore/chain/
  Last synced: 12 minutes ago

  Total entries: 1,247
  By type:
    PUBLISH:   412
    PULL:      519
    INTEGRATE: 284
    REJECT:    32

  Participating colonies: 8
  Chain integrity: VERIFIED (last check: 2h ago)
  Oldest entry: 2025-01-15T09:00:00Z
  Latest entry: 2025-02-02T14:22:00Z

  HEALTH:
    ✓ No gaps detected
    ✓ All signatures valid
    ✓ Hash chain unbroken
    ⚠ colony-gamma has 0 PUBLISH entries (possible parasite)
```

## Verify chain integrity

Recompute all hashes and verify signatures:

```
/spore chain verify

Verifying provenance chain...

  Checking hash chain: 1247/1247 entries ✓
  Verifying signatures: 1247/1247 valid ✓
  Checking for gaps: none detected ✓
  Checking for forks: none detected ✓

  RESULT: Chain integrity VERIFIED
  Time: 3.2 seconds
```

If tampering is detected:

```
  RESULT: INTEGRITY FAILURE

  Entry #847 (hash: a1b2c3...)
    Claimed previous: f9e8d7...
    Actual previous:  3c4d5e...
    Colony: colony-delta
    Timestamp: 2025-02-01T10:00:00Z

  Chain is broken from entry #847 onward.
  Entries #847-#1247 cannot be trusted.

  Recommended action:
    1. Alert network peers
    2. Investigate colony-delta
    3. Rebuild chain from last verified entry (#846)
```

## Inspect a spore's provenance

See the full lifecycle of a specific spore on the chain:

```
/spore chain inspect aggressive-auth-001

CHAIN HISTORY: aggressive-auth-001
hash: a1b2c3d4e5f6...

  2025-01-20 10:00  PUBLISH  by colony-alpha
  2025-01-20 14:30  PULL     by colony-beta
  2025-01-20 15:15  PULL     by colony-delta
  2025-01-21 09:00  INTEGRATE by colony-beta
  2025-01-21 11:00  INTEGRATE by colony-delta
  2025-01-22 10:00  PULL     by colony-gamma
  2025-01-22 16:00  REJECT   by colony-gamma (conflict with local evidence)

  Spread: 3 colonies pulled, 2 integrated, 1 rejected
  Time to first integration: 23 hours
```

## Check independence of confirmations

The key use case. When multiple peers confirm the same pattern,
are the confirmations genuinely independent?

```
/spore chain independence aggressive-auth-001

INDEPENDENCE ANALYSIS: aggressive-auth-001
pattern: "aggressive > 0.7 AND defensive < 0.3 fails security"

  ORIGINAL:
    colony-alpha PUBLISHED on 2025-01-20 10:00

  CONFIRMATION 1: colony-beta
    Published similar finding on 2025-01-22 09:00
    BUT: pulled colony-alpha's spore on 2025-01-20 14:30
    VERDICT: NOT INDEPENDENT (pulled original 2 days before confirming)
    Corroboration bonus: +0.00

  CONFIRMATION 2: colony-delta
    Published similar finding on 2025-01-19 16:00
    colony-delta's finding predates colony-alpha's by 18 hours
    No record of colony-delta pulling from colony-alpha before publishing
    VERDICT: INDEPENDENT (published before original existed)
    Corroboration bonus: +0.03

  CONFIRMATION 3: colony-epsilon
    Published similar finding on 2025-01-25 12:00
    No PULL record for colony-alpha's spore or colony-delta's spore
    Could be independent or out-of-band influence (unverifiable)
    VERDICT: POSSIBLY INDEPENDENT (no chain evidence either way)
    Corroboration bonus: +0.01

  SUMMARY:
    3 confirmations claimed
    1 genuinely independent (chain-verified)
    1 not independent (influenced by original)
    1 uncertain (no chain data)
    Adjusted corroboration bonus: +0.04 (vs naive +0.10)
```

## Show recent entries

```
/spore chain log --last 5

RECENT CHAIN ENTRIES:

  #1247  2025-02-02 14:22  INTEGRATE  colony-beta    spore: timeout-fix-003
  #1246  2025-02-02 14:15  PULL       colony-beta    spore: timeout-fix-003
  #1245  2025-02-02 13:00  PUBLISH    colony-alpha   spore: timeout-fix-003
  #1244  2025-02-02 12:30  REJECT     colony-delta   spore: jwt-refresh-007
  #1243  2025-02-02 11:00  INTEGRATE  colony-alpha   spore: cache-pattern-012
```

## How chain entries are created

Chain entries are created automatically by other commands:

**/spore push** creates PUBLISH entries for each spore pushed.
**/spore pull** creates PULL entries for each spore fetched.
**/spore validate** (when verdict is INTEGRATE or REJECT) creates
the corresponding entry.

The colony signs each entry with its identity key (generated
during /spore init). Entries are appended to the local chain
cache and synced to the shared chain repo periodically.

## Chain sync

The chain repo is separate from colony spore repos. All
participating colonies push their entries to the same chain repo.

Sync happens:
- Automatically during /spore pull and /spore push
- Manually via /spore chain verify (pulls latest then verifies)

## Privacy considerations

The chain reveals which colonies consume which knowledge. A colony
that pulls 40 security-related spores in a week reveals that it's
working on security problems.

Mitigation options:
- Batch PULL entries (log one entry per sync, not per spore)
- Delay PULL logging (add entries hours after the actual pull)
- Opt out of chain entirely (lose independence verification)

These are configured in config.md under chain.privacy.

## When chain is disabled

If a colony opts out (chain.enabled: false), corroboration still
works but cannot verify independence. The validator falls back to
naive corroboration: count confirmations without temporal checks.
This is the pre-chain behavior. It still catches blatant junk but
can't detect echo chambers.

## Implementation notes

Read `.claude/skills/spore-protocol/formats/chain-entry.md` for
the entry format specification.

The chain is a git repo with one file per entry, named by
entry number and hash:
```
chain/
  0001-genesis.yaml
  0002-a1b2c3d4.yaml
  0003-e5f6g7h8.yaml
  ...
```

Each file contains one entry in the format specified above.
The hash chain links entries cryptographically. Git provides
additional integrity via its own hash tree, but the chain's
internal hashing is the primary verification mechanism.
