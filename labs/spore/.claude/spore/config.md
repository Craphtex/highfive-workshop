---
# Colony identity
colony_id: my-colony
repo: git@github.com:me/my-colony-spores.git

# What domains this colony focuses on
domains:
  - api-design
  - testing
  - databases

# Automation settings (all disabled by default)
auto_pull: false      # Auto-fetch from peers periodically
auto_validate: false  # Auto-process inbox without confirmation
auto_announce: false  # Auto-share learnings that meet criteria

# Thresholds
diversity_threshold: 0.70        # Alert when pattern > this %
min_peer_reliability: 0.50       # Warn about peers below this
quarantine_review_days: 7        # Auto-review deadline
min_observations_to_share: 3     # Minimum evidence before announcing

# Privacy - what this colony shares
privacy:
  share_graveyard: true    # Dead timeline learnings
  share_genomes: true      # Successful gene combinations
  share_fitness: true      # Fitness functions
  share_governance: false  # Institutional patterns (usually private)

# Network settings
max_peers: 20                    # Limit peer connections
sync_cooldown_hours: 1           # Minimum time between syncs per peer

# Notification settings (prevents update fatigue, mirrors METAMORPHOSIS 
# confidence-weighted silence where routine decisions are batched)
notifications:
  graveyard: digest              # realtime | digest | silent
  genomes: realtime              # New genomes are worth attention
  fitness: realtime              # Fitness functions need careful review
  governance: realtime           # Always notify for governance
  digest_interval_hours: 24      # How often to batch digest notifications

# FLUX integration settings
integration:
  # Automatically apply network knowledge to FLUX
  auto_apply_graveyard: true     # Add bad patterns to known-bad list
  auto_apply_genomes: false      # Require review before adding to gene pool
  auto_apply_fitness: false      # Always require manual review
  
  # Automatically package local learnings for sharing
  auto_package_graveyard: true   # Package graveyard entries when ready
  auto_package_winners: false    # Require confirmation for winners
  
  # Thresholds for auto-packaging
  min_generations_to_share: 5    # Genomes must survive this many
  min_fitness_to_share: 60       # Minimum fitness score for winners
  
  # Safety settings
  block_low_confidence: true     # Block patterns with confidence > 0.8
  warn_medium_confidence: true   # Warn for confidence 0.5-0.8
  allow_low_confidence: false    # Allow confidence < 0.5 (risky)
  
  # Ledger integration
  log_to_ledger: true            # Record network knowledge in Ledger
  
  # Council escalation
  council_review_fitness: true   # Require Council for fitness spore integration
  council_review_governance: true # Require Council for governance spore integration
  council_review_genomes: false  # Genomes can be reviewed by user alone

# Conservation areas (preserves local knowledge from network override,
# mirrors METAMORPHOSIS concept where some timelines deliberately reject
# viral infection to maintain biodiversity)
conservation:
  enabled: true
  protected_patterns: []         # List of local pattern IDs that network cannot override
  override_requires: human       # human | council | none

# Freshness (addresses knowledge decay: what worked a month ago may not
# work today)
freshness:
  max_age_days: 180              # Spores older than this get flagged for re-validation
  revalidation_interval_days: 90 # How often to re-test integrated spores
  auto_deprecate: false          # Automatically reduce confidence of stale spores
  deprecation_rate: 0.05         # Confidence reduction per missed revalidation

# Reciprocity (detects parasitic peers without punishing new colonies)
reciprocity:
  track_contributions: true      # Monitor contribution ratios per peer
  grace_period_days: 30          # New peers get this long before ratio matters
  min_contribution_ratio: 0.1    # Below this after grace period = warning
  warn_only: true                # True = warn operator. False = auto-restrict sharing

# Provenance chain (shared append-only log for verifiable temporal ordering)
chain:
  enabled: false                 # Disabled by default (small networks don't need it)
  repo: null                     # Git URL for shared chain repo
  auto_sync: true                # Sync chain during push/pull operations
  privacy:
    batch_pulls: false           # Log one PULL per sync instead of per spore
    delay_hours: 0               # Delay chain entry logging (0 = immediate)
  verify_interval_hours: 24      # How often to auto-verify chain integrity
---

# Colony configuration

## About this colony

Describe what this colony focuses on, what kinds of problems it solves,
and what makes its learnings potentially valuable to others.

This colony works primarily on [describe domain]. We have particular
expertise in [specific areas]. Our evolution style tends toward
[aggressive/balanced/conservative].

## Sharing philosophy

What we freely share:
- Graveyard entries (our failures help others avoid the same mistakes)
- Winning genomes (successful patterns should spread)
- Fitness functions (good evaluation criteria are hard to create)

What we keep private:
- Governance patterns (these are too context-dependent)
- Anything with fewer than 3 observations (not enough evidence)

## Peer selection criteria

We prefer peers who:
- Work in overlapping domains
- Have reliability above 0.6
- Contribute as well as consume

We avoid peers who:
- Only consume, never share
- Have reliability below 0.5
- Flood with low-quality spores

## Local conventions

Any special rules for this colony:
- [Example: We require 5 observations before sharing, not 3]
- [Example: Fitness functions need extra review before announcing]
- [Example: We never auto-integrate genome spores]
