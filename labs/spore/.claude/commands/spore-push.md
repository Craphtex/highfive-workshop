---
name: spore-push
description: Publish packaged spores from outbox to the network
---

# /spore push

Publish your outbox spores to the colony's git repository, making
them available to peers on their next pull.

## Usage

```
/spore push                     Push all outbox spores
/spore push <spore-id>          Push a specific spore
/spore push --dry-run           Show what would be pushed without pushing
```

## Full push

```
/spore push

SPORE PUSH
──────────

Checking outbox...

2 spores ready to publish:

  1. graveyard/timeline-gamma-auth-001.md
     Type: graveyard | Confidence: 0.76
     Pattern: aggressive + low-defensive fails security audit
     
  2. genome/improved-api-handler.md
     Type: genome | Confidence: 0.80
     Pattern: defensive API handler with retry logic

Pre-push checks:
  ✓ Security scan: No secrets or local paths found
  ✓ Format validation: All spores comply with protocol
  ✓ Signatures: All valid

Push these 2 spores to network? [Y/n] > y

git add .claude/spore/outbox/
git commit -m "spore: publish 2 spores (1 graveyard, 1 genome)"
git push origin main

Published! 2 spores now available to peers.

Ledger entry created:
  Decision: NETWORK_KNOWLEDGE_PUBLISHED
  Spores: timeline-gamma-auth-001, improved-api-handler
  Timestamp: 2025-02-02T15:30:00Z

Chain entries appended (if chain enabled):
  #1248 PUBLISH timeline-gamma-auth-001
  #1249 PUBLISH improved-api-handler
```

## Dry run

```
/spore push --dry-run

DRY RUN (nothing will be pushed)

Would publish 2 spores:
  1. graveyard/timeline-gamma-auth-001.md -> peers can pull
  2. genome/improved-api-handler.md -> peers can pull

No issues detected.
```

## Selective push

```
/spore push timeline-gamma-auth-001

Pushing 1 spore:
  graveyard/timeline-gamma-auth-001.md

Pre-push checks:
  ✓ Security scan: Clean
  ✓ Format: Valid
  ✓ Signature: Valid

Published! 1 spore now available.

Remaining in outbox: 1 spore
  Run /spore push to publish the rest.
```

## What push does

1. Scans `.claude/spore/outbox/` for packaged spores
2. Runs security check on each (no secrets, no local paths)
3. Validates format compliance
4. Verifies signatures
5. Commits to colony's spore repository
6. Pushes to remote
7. Logs to Ledger if log_to_ledger is enabled

## Push guards

Push will refuse if:
- Spore contains local file paths or secrets
- Spore format is invalid
- Signature doesn't match content
- Colony repository is not configured

```
/spore push

ERROR: Security check failed for genome/local-handler.md
  Found local path: /Users/me/projects/api/src/handler.js
  
Fix: Remove local paths before pushing.
  Run /spore announce to re-package with path stripping.
```

## Empty outbox

```
/spore push

Outbox is empty. Nothing to push.

To package learnings for sharing:
  /spore announce <path-to-learning>
```
