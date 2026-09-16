---
name: spore-announce
description: Package and publish a local learning to the network
---

# /spore announce

Share a local learning with your peer network.

## Usage

```
/spore announce <learning-path>              Package and publish
/spore announce --dry-run <learning-path>    Preview without publishing
/spore announce --list                       Show publishable learnings
```

## Process

1. Validate the learning is ready for sharing
2. Invoke packager agent to create spore
3. Security check (no secrets, paths, PII)
4. Place in outbox/
5. Git commit and push to colony repo
6. Report success

## What can be announced

- Graveyard entries: `.claude/flux/graveyard/*.md`
- Winning genomes: `.claude/flux/winners/*.md`
- Fitness functions: `.claude/flux/fitness/*.md`
- Governance patterns: `.claude/metamorphosis/governance/*.md` (if enabled)

## Output

```
/spore announce .claude/flux/graveyard/timeline-gamma-autopsy.md

Checking learning...
  Type: graveyard
  Validated locally: YES (died gen-004)
  Observations: 3 (minimum 5 recommended, proceeding anyway)

Packaging spore...
  Stripping local paths... OK
  Adding context... OK
  Computing signature... OK
  
Security check...
  No credentials found: OK
  No local paths found: OK
  No PII detected: OK

Preview:
---
type: graveyard
origin: my-colony
created: 2025-02-02T15:30:00Z
confidence: 0.60
context:
  domain: api-design
  constraints: production-ready
  environment: Node.js, Express
signature: b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3
---

# Aggressive API handler failed under load

## Summary
Timeline attempted high-aggression API design...
[truncated]

Publish this spore? [Y/n] y

Publishing...
  Copied to outbox/graveyard/aggressive-api-001.md
  Git add... OK
  Git commit... OK
  Git push... OK

Spore announced! 
Available to peers on next /spore pull.
```

## Dry run

Preview what would be shared without publishing:

```
/spore announce --dry-run .claude/flux/graveyard/timeline-gamma-autopsy.md

DRY RUN - Nothing will be published

[Shows full spore preview]

To publish for real, run without --dry-run
```

## Listing publishable learnings

```
/spore announce --list

Publishable learnings:

GRAVEYARD (4 ready, 2 need more observations)
  Ready:
    timeline-alpha-autopsy.md (confidence: 0.78)
    timeline-beta-autopsy.md (confidence: 0.65)
    timeline-gamma-autopsy.md (confidence: 0.60)
    timeout-cascade.md (confidence: 0.82)
  Need more observations:
    connection-pool-issue.md (2/5 observations)
    memory-leak-pattern.md (1/5 observations)

GENOMES (2 ready)
  Ready:
    balanced-validator.md (survived 8 generations)
    defensive-api-handler.md (survived 6 generations)

FITNESS (0 ready)
  None meet sharing criteria

GOVERNANCE (1 ready, sharing disabled)
  rotating-critic.md (stable 30 days)
  Note: Enable share_governance in config to publish
```

## Pre-publish checks

Before announcing, the system verifies:

1. **Local validation passed** - The learning has been through local process
2. **Minimum evidence** - At least 3 observations (5 recommended)
3. **Not already shared** - No duplicate in outbox or previously pushed
4. **Privacy settings allow** - Check config for share permissions
5. **Security scan** - No secrets, credentials, or sensitive paths

## Errors

```
/spore announce .claude/flux/graveyard/incomplete.md

Error: Learning not ready for sharing
Reason: Only 1 observation (minimum 3, recommended 5)

Wait for more evidence or force with --force flag (not recommended)
```

```
/spore announce .claude/flux/fitness/internal-eval.md

Error: Privacy settings block this share
Your config has share_fitness: false

To enable, edit .claude/spore/config.md
```
