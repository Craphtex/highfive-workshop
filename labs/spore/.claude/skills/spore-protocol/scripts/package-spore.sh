#!/bin/bash
# package-spore.sh - Package a local learning into a spore
# Usage: ./package-spore.sh <learning-path> [--dry-run]

set -e

SPORE_DIR="${SPORE_DIR:-.claude/spore}"
CONFIG_FILE="$SPORE_DIR/config.md"
OUTBOX_DIR="$SPORE_DIR/outbox"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Get colony ID from config
get_colony_id() {
    grep "^colony_id:" "$CONFIG_FILE" | sed 's/colony_id: *//'
}

# Detect spore type from path
detect_type() {
    local path="$1"
    if [[ "$path" == *"graveyard"* ]]; then
        echo "graveyard"
    elif [[ "$path" == *"winners"* ]]; then
        echo "genome"
    elif [[ "$path" == *"fitness"* ]]; then
        echo "fitness"
    elif [[ "$path" == *"governance"* ]]; then
        echo "governance"
    else
        echo "unknown"
    fi
}

# Calculate SHA256 signature of content (excluding frontmatter)
calculate_signature() {
    local file="$1"
    # Extract content after frontmatter and hash it
    sed '1,/^---$/d' "$file" | sed '1,/^---$/d' | sha256sum | cut -d' ' -f1
}

# Security scan for sensitive data
security_scan() {
    local file="$1"
    local issues=""
    
    # Check for common secrets patterns
    if grep -qiE "(api[_-]?key|password|secret|token|credential)" "$file"; then
        issues="$issues\n  - Possible credentials detected"
    fi
    
    # Check for absolute paths
    if grep -qE "^/|~/|/home/|/Users/" "$file"; then
        issues="$issues\n  - Absolute paths detected"
    fi
    
    # Check for IP addresses
    if grep -qE "\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b" "$file"; then
        issues="$issues\n  - IP addresses detected"
    fi
    
    # Check for email addresses
    if grep -qE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" "$file"; then
        issues="$issues\n  - Email addresses detected"
    fi
    
    if [ -n "$issues" ]; then
        echo -e "$issues"
        return 1
    fi
    return 0
}

# Main packaging function
package_spore() {
    local input_file="$1"
    local dry_run="$2"
    
    if [ ! -f "$input_file" ]; then
        log_error "File not found: $input_file"
        exit 1
    fi
    
    local type=$(detect_type "$input_file")
    if [ "$type" == "unknown" ]; then
        log_error "Cannot detect spore type from path"
        log_info "Expected path to contain: graveyard, winners, fitness, or governance"
        exit 1
    fi
    
    log_info "Packaging $type spore..."
    log_info "Source: $input_file"
    
    # Security scan
    log_info "Running security scan..."
    local security_issues=$(security_scan "$input_file")
    if [ -n "$security_issues" ]; then
        log_error "Security issues found:$security_issues"
        log_error "Please remove sensitive data before packaging"
        exit 1
    fi
    log_info "  Security scan: PASS"
    
    # Get metadata
    local colony_id=$(get_colony_id)
    local created=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local signature=$(calculate_signature "$input_file")
    local spore_name=$(basename "$input_file")
    
    # Create output directory
    mkdir -p "$OUTBOX_DIR/$type"
    local output_file="$OUTBOX_DIR/$type/$spore_name"
    
    # Build spore with proper frontmatter
    cat > "$output_file.tmp" << EOF
---
type: $type
origin: $colony_id
created: $created
confidence: 0.5
context:
  domain: TBD
  constraints: TBD
  environment: TBD
signature: $signature
forwarded_by: []
---

EOF
    
    # Append original content (skip original frontmatter if present)
    if head -1 "$input_file" | grep -q "^---$"; then
        # Has frontmatter, skip it
        sed '1,/^---$/d' "$input_file" | sed '1,/^---$/d' >> "$output_file.tmp"
    else
        # No frontmatter, append all
        cat "$input_file" >> "$output_file.tmp"
    fi
    
    if [ "$dry_run" == "--dry-run" ]; then
        log_info ""
        log_info "DRY RUN - Preview:"
        echo "================================"
        head -30 "$output_file.tmp"
        echo "..."
        echo "================================"
        rm "$output_file.tmp"
        log_info ""
        log_info "Run without --dry-run to package for real"
    else
        mv "$output_file.tmp" "$output_file"
        log_info ""
        log_info "Spore packaged: $output_file"
        log_info ""
        log_info "Next steps:"
        log_info "  1. Review and edit context fields in the spore"
        log_info "  2. Run: git add $output_file"
        log_info "  3. Run: git commit -m 'Add spore: $spore_name'"
        log_info "  4. Run: git push"
    fi
}

# Entry point
if [ -z "$1" ]; then
    echo "Usage: $0 <learning-path> [--dry-run]"
    echo ""
    echo "Examples:"
    echo "  $0 .claude/flux/graveyard/timeline-001.md"
    echo "  $0 .claude/flux/winners/balanced-api.md --dry-run"
    exit 1
fi

package_spore "$1" "$2"
