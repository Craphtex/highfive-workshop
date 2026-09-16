#!/bin/bash
# init-colony.sh - Initialize SPORE colony structure
# Usage: ./init-colony.sh <colony-id> [repo-url]

set -e

COLONY_ID="${1:-my-colony}"
REPO_URL="${2:-git@github.com:me/my-colony-spores.git}"
SPORE_DIR=".claude/spore"
FLUX_DIR=".claude/flux"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if already initialized
if [ -f "$SPORE_DIR/config.md" ]; then
    log_warn "SPORE already initialized in this project"
    echo "Run with --force to reinitialize"
    exit 1
fi

log_info "Initializing SPORE colony: $COLONY_ID"

# Create directory structure
log_info "Creating directory structure..."

mkdir -p "$SPORE_DIR/peers"
mkdir -p "$SPORE_DIR/inbox/graveyard"
mkdir -p "$SPORE_DIR/inbox/genome"
mkdir -p "$SPORE_DIR/inbox/fitness"
mkdir -p "$SPORE_DIR/inbox/governance"
mkdir -p "$SPORE_DIR/outbox/graveyard"
mkdir -p "$SPORE_DIR/outbox/genome"
mkdir -p "$SPORE_DIR/outbox/fitness"
mkdir -p "$SPORE_DIR/outbox/governance"
mkdir -p "$SPORE_DIR/integrated/graveyard"
mkdir -p "$SPORE_DIR/integrated/genome"
mkdir -p "$SPORE_DIR/integrated/fitness"
mkdir -p "$SPORE_DIR/integrated/governance"
mkdir -p "$SPORE_DIR/rejected"
mkdir -p "$SPORE_DIR/quarantine"

mkdir -p "$FLUX_DIR"

# Create config file
log_info "Creating config.md..."

cat > "$SPORE_DIR/config.md" << EOF
---
colony_id: $COLONY_ID
repo: $REPO_URL

domains:
  - api-design
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

integration:
  auto_apply_graveyard: true
  auto_apply_genomes: false
  auto_apply_fitness: false
  auto_package_graveyard: true
  auto_package_winners: false
  min_generations_to_share: 5
  min_fitness_to_share: 60
---

# Colony: $COLONY_ID

Initialized on $(date -u +"%Y-%m-%d").

## About this colony

[Add description of your colony here]

## Notes

[Add any notes about your setup]
EOF

# Create index file
log_info "Creating index.md..."

cat > "$SPORE_DIR/index.md" << EOF
---
last_updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
total_spores: 0
by_type:
  graveyard: 0
  genome: 0
  fitness: 0
  governance: 0
by_domain: {}
---

# Spore index

This index is maintained by the librarian agent.
It will be populated as spores are integrated.

## By domain

No spores integrated yet.

## Cross-references

No cross-references yet.

## Search keywords

No keywords indexed yet.
EOF

# Create known-bad-patterns file
log_info "Creating known-bad-patterns.md..."

cat > "$FLUX_DIR/known-bad-patterns.md" << EOF
# Known bad patterns

This file is automatically updated by SPORE integration when graveyard 
spores are applied. FLUX checks this before spawning new timelines.

## Active patterns

\`\`\`yaml
patterns: []
\`\`\`

No patterns yet. Run /spore pull and /spore integrate to populate.
EOF

# Create .gitkeep files for empty directories
touch "$SPORE_DIR/inbox/.gitkeep"
touch "$SPORE_DIR/outbox/.gitkeep"
touch "$SPORE_DIR/integrated/.gitkeep"
touch "$SPORE_DIR/rejected/.gitkeep"
touch "$SPORE_DIR/quarantine/.gitkeep"

# Create validation log
touch "$SPORE_DIR/validation.log"

log_info "Colony initialized!"
echo ""
echo "Created:"
echo "  $SPORE_DIR/config.md"
echo "  $SPORE_DIR/index.md"
echo "  $SPORE_DIR/peers/"
echo "  $SPORE_DIR/inbox/"
echo "  $SPORE_DIR/outbox/"
echo "  $SPORE_DIR/integrated/"
echo "  $SPORE_DIR/rejected/"
echo "  $SPORE_DIR/quarantine/"
echo "  $FLUX_DIR/known-bad-patterns.md"
echo ""
echo "Next steps:"
echo "  1. Edit $SPORE_DIR/config.md with your details"
echo "  2. Set your actual repository URL"
echo "  3. Run /spore peers add <repo-url> to add peers"
echo "  4. Run /spore pull to fetch network knowledge"
