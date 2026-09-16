---
name: spore-init
description: Initialize a new SPORE colony
---

# /spore init

Set up your project as a SPORE colony and connect to the network.

## Usage

```
/spore init                     Interactive setup
/spore init --quick             Use defaults, configure later
/spore init --from <colony>     Clone settings from existing colony
```

## Interactive setup

```
/spore init

╔══════════════════════════════════════════════════════════════╗
║                    SPORE COLONY SETUP                        ║
╚══════════════════════════════════════════════════════════════╝

Welcome! Let's set up your colony for the SPORE network.

STEP 1: Colony identity
───────────────────────

Colony ID (unique name, lowercase, no spaces):
> my-colony

What domains does your colony focus on?
(comma-separated, e.g., api-design, testing, databases)
> api-design, authentication, testing

STEP 2: Repository setup
────────────────────────

SPORE uses a git repository to share knowledge.
You need a separate repo for spores (not your code repo).

Do you have a spore repository? [Y/n]
> n

Let's create one. Recommended structure:
  Repository name: my-colony-spores
  Visibility: Public (for open knowledge sharing) or Private (team only)

After creating the repo, enter the SSH URL:
> git@github.com:myuser/my-colony-spores.git

Testing connection... ✓ Connected

STEP 3: Privacy settings
────────────────────────

What knowledge will you share with the network?

Share graveyard entries (failed patterns)? [Y/n] > y
Share winning genomes (successful patterns)? [Y/n] > y  
Share fitness functions (evaluation methods)? [Y/n] > y
Share governance patterns (institutional rules)? [y/N] > n

STEP 4: Automation preferences
──────────────────────────────

How much automation do you want?

Auto-pull from peers periodically? [y/N] > n
Auto-validate incoming spores? [y/N] > n
Auto-announce shareable learnings? [y/N] > n

(You can change these later in config.md)

STEP 5: First peer (optional)
─────────────────────────────

Add a peer to start receiving knowledge?

Enter peer repo URL (or press Enter to skip):
> git@github.com:other/their-colony-spores.git

Testing connection... ✓ Connected
Peer added: their-colony (detected from repo name)

╔══════════════════════════════════════════════════════════════╗
║                    SETUP COMPLETE!                           ║
╚══════════════════════════════════════════════════════════════╝

Created:
  ✓ .claude/spore/config.md
  ✓ .claude/spore/index.md
  ✓ .claude/spore/peers/their-colony.md
  ✓ .claude/spore/inbox/
  ✓ .claude/spore/outbox/
  ✓ .claude/spore/integrated/
  ✓ .claude/spore/rejected/
  ✓ .claude/spore/quarantine/
  ✓ .claude/flux/known-bad-patterns.md

Next steps:
  1. Run /spore pull to fetch knowledge from your peer
  2. Run /spore validate to process incoming spores
  3. Run /spore integrate to apply knowledge to FLUX
  4. Start evolving with /explore "your problem"

Your colony is ready! Welcome to the network. 🍄
```

## Quick setup

```
/spore init --quick

Quick setup mode - using defaults...

Colony ID: detected from project name -> "my-project"
Repository: not configured (set later)
Privacy: sharing all except governance
Automation: all disabled
Peers: none

Created basic structure.

⚠ You still need to:
  1. Create a spore repository
  2. Edit .claude/spore/config.md with your repo URL
  3. Add at least one peer

Run /spore status to see what's missing.
```

## Clone from existing colony

If you have another SPORE colony, clone its configuration:

```
/spore init --from /path/to/other/project

Cloning configuration from: /path/to/other/project

Found existing colony: other-colony
  Domains: api-design, databases
  Peers: 3
  Privacy: standard

Clone options:
  [C] Clone config only (new identity, same settings)
  [F] Full clone (same identity, same settings) 
  [S] Selective (choose what to clone)

> c

Creating new colony with cloned settings...

New colony ID:
> my-new-colony

Created with settings from other-colony.
Peers copied but will need re-authentication.

Run /spore peers to verify peer connections.
```

## What init creates

### Directory structure

```
.claude/
├── spore/
│   ├── config.md           # Your colony configuration
│   ├── index.md            # Knowledge index (empty initially)
│   ├── peers/              # Peer colony definitions
│   ├── inbox/              # Incoming spores
│   ├── outbox/             # Outgoing spores
│   ├── integrated/         # Applied knowledge
│   ├── rejected/           # Failed validation
│   └── quarantine/         # Needs review
│
└── flux/
    └── known-bad-patterns.md   # Patterns to avoid (empty initially)
```

### Config file

Generated `config.md`:

```yaml
---
colony_id: my-colony
repo: git@github.com:myuser/my-colony-spores.git

domains:
  - api-design
  - authentication
  - testing

auto_pull: false
auto_validate: false
auto_announce: false

diversity_threshold: 0.70
min_peer_reliability: 0.50
quarantine_review_days: 7
min_observations_to_share: 3

privacy:
  share_graveyard: true
  share_genomes: true
  share_fitness: true
  share_governance: false

max_peers: 20
sync_cooldown_hours: 1

notifications:
  graveyard: digest
  genomes: realtime
  fitness: realtime
  governance: realtime
  digest_interval_hours: 24

integration:
  auto_apply_graveyard: true
  auto_apply_genomes: false
  auto_apply_fitness: false
  auto_package_graveyard: true
  auto_package_winners: false
  min_generations_to_share: 5
  min_fitness_to_share: 60
  block_low_confidence: true
  warn_medium_confidence: true
  allow_low_confidence: false
  log_to_ledger: true
  council_review_fitness: true
  council_review_governance: true
  council_review_genomes: false

conservation:
  enabled: true
  protected_patterns: []
  override_requires: human

freshness:
  max_age_days: 180
  revalidation_interval_days: 90
  auto_deprecate: false
  deprecation_rate: 0.05

reciprocity:
  track_contributions: true
  grace_period_days: 30
  min_contribution_ratio: 0.1
  warn_only: true

chain:
  enabled: false
  repo: null
  auto_sync: true
  privacy:
    batch_pulls: false
    delay_hours: 0
  verify_interval_hours: 24
---

# Colony: my-colony

Initialized on 2025-02-02.

## About this colony

[Add description of your colony here]

## Notes

[Add any notes about your setup]
```

## Repository initialization

If your spore repository is empty, init will offer to set it up:

```
Repository is empty. Initialize with standard structure? [Y/n]
> y

Creating repository structure...
  mkdir graveyard/
  mkdir genome/
  mkdir fitness/
  mkdir governance/
  Creating README.md...
  
Committing initial structure...
Pushing to remote...

Repository initialized! ✓
```

## Troubleshooting

**"Permission denied" on repository**
- Check SSH keys are configured
- Verify you have write access to the repo
- Try: `ssh -T git@github.com` to test connection

**"Colony ID already exists"**
- Choose a different colony ID
- Or use `--force` to overwrite existing config

**"Cannot detect project name"**
- Specify colony ID manually
- Check you're in a valid project directory

## Re-initialization

If you need to reconfigure:

```
/spore init

Existing SPORE configuration detected.

Options:
  [R] Reconfigure (keep data, update settings)
  [F] Full reset (delete all SPORE data)
  [C] Cancel

> r

Reconfiguration mode...
[Runs through setup, preserving existing data]
```
