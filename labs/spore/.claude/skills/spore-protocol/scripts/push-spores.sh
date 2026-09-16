#!/bin/bash
# push-spores.sh - Publish spores from outbox to colony repository
# Usage: ./push-spores.sh [--dry-run]

set -e

SPORE_DIR="${SPORE_DIR:-.claude/spore}"
CONFIG_FILE="$SPORE_DIR/config.md"
OUTBOX_DIR="$SPORE_DIR/outbox"
LOG_FILE="$SPORE_DIR/publish.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
    DRY_RUN=true
    log_warn "DRY RUN MODE - No changes will be made"
fi

# Get colony repo from config
get_colony_repo() {
    grep "^repo:" "$CONFIG_FILE" | sed 's/repo: *//'
}

# Get colony ID from config  
get_colony_id() {
    grep "^colony_id:" "$CONFIG_FILE" | sed 's/colony_id: *//'
}

# Count spores in outbox
count_outbox() {
    find "$OUTBOX_DIR" -name "*.md" 2>/dev/null | wc -l
}

# List spores in outbox
list_outbox() {
    find "$OUTBOX_DIR" -name "*.md" -printf "%P\n" 2>/dev/null
}

# Verify spore has required fields
verify_spore() {
    local spore="$1"
    local errors=""
    
    # Check for required frontmatter fields
    if ! grep -q "^type:" "$spore"; then
        errors="$errors\n  - Missing 'type' field"
    fi
    if ! grep -q "^origin:" "$spore"; then
        errors="$errors\n  - Missing 'origin' field"
    fi
    if ! grep -q "^signature:" "$spore"; then
        errors="$errors\n  - Missing 'signature' field"
    fi
    
    if [ -n "$errors" ]; then
        echo -e "$errors"
        return 1
    fi
    return 0
}

# Main push function
push_spores() {
    local colony_repo=$(get_colony_repo)
    local colony_id=$(get_colony_id)
    local count=$(count_outbox)
    
    if [ "$count" -eq 0 ]; then
        log_info "No spores in outbox to publish"
        exit 0
    fi
    
    log_info "Publishing $count spore(s) from $colony_id"
    log_info "Repository: $colony_repo"
    echo ""
    
    # Clone colony repo to temp directory
    local temp_dir="/tmp/spore-push-$$"
    trap "rm -rf $temp_dir" EXIT
    
    log_step "Cloning colony repository..."
    if [ "$DRY_RUN" = false ]; then
        git clone --quiet "$colony_repo" "$temp_dir"
    else
        log_info "  Would clone: $colony_repo"
        mkdir -p "$temp_dir"
    fi
    
    # Verify and copy each spore
    log_step "Verifying and staging spores..."
    local staged=0
    local failed=0
    
    for spore in $(list_outbox); do
        local spore_path="$OUTBOX_DIR/$spore"
        local spore_type=$(dirname "$spore")
        local spore_name=$(basename "$spore")
        
        echo -n "  $spore: "
        
        # Verify spore
        local errors=$(verify_spore "$spore_path")
        if [ -n "$errors" ]; then
            echo -e "${RED}FAILED${NC}"
            echo -e "$errors"
            ((failed++))
            continue
        fi
        
        # Create type directory if needed
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$temp_dir/$spore_type"
            cp "$spore_path" "$temp_dir/$spore_type/"
        fi
        
        echo -e "${GREEN}OK${NC}"
        ((staged++))
    done
    
    echo ""
    log_info "Staged: $staged, Failed: $failed"
    
    if [ "$staged" -eq 0 ]; then
        log_error "No valid spores to publish"
        exit 1
    fi
    
    # Commit and push
    if [ "$DRY_RUN" = false ]; then
        log_step "Committing changes..."
        cd "$temp_dir"
        git add .
        
        # Generate commit message
        local commit_msg="Add $staged spore(s) from $colony_id

Spores added:"
        for spore in $(list_outbox); do
            commit_msg="$commit_msg
- $spore"
        done
        
        git commit -m "$commit_msg"
        
        log_step "Pushing to remote..."
        git push
        
        # Clean outbox
        log_step "Cleaning outbox..."
        for spore in $(list_outbox); do
            rm "$OUTBOX_DIR/$spore"
        done
        
        # Log publication
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[$timestamp] Published $staged spores" >> "$LOG_FILE"
        for spore in $(list_outbox); do
            echo "  - $spore" >> "$LOG_FILE"
        done
        
        echo ""
        log_info "Successfully published $staged spore(s)!"
        log_info "Peers can now pull your knowledge with /spore pull"
    else
        echo ""
        log_info "DRY RUN complete"
        log_info "Would have published $staged spore(s)"
        log_info "Run without --dry-run to actually publish"
    fi
}

# Pre-flight checks
preflight() {
    # Check config exists
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "Config file not found: $CONFIG_FILE"
        log_info "Run /spore init to set up your colony"
        exit 1
    fi
    
    # Check repo is configured
    local repo=$(get_colony_repo)
    if [ -z "$repo" ] || [ "$repo" == "git@github.com:me/my-colony-spores.git" ]; then
        log_error "Colony repository not configured"
        log_info "Edit $CONFIG_FILE and set your repo URL"
        exit 1
    fi
    
    # Check git is available
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed"
        exit 1
    fi
    
    # Check outbox exists
    if [ ! -d "$OUTBOX_DIR" ]; then
        log_error "Outbox directory not found: $OUTBOX_DIR"
        exit 1
    fi
}

# Entry point
preflight
push_spores
