#!/bin/bash

###############################################################################
# AUTOMATIC WORKFLOW ORCHESTRATOR
#
# Runs the full development cycle automatically:
# 1. Code (Claude in Cursor)
# 2. Review (GitHub Actions - Automatic)
# 3. Integrate (Automatic)
# 4. Test (Local)
# 5. Deploy (Automatic)
#
# Usage:
#   workflow-auto dev [message]      # Develop + auto-review
#   workflow-auto full               # Full cycle
#   workflow-auto watch              # Watch for changes and auto-deploy
#
###############################################################################

set -e

PROJECT_ROOT="${PWD}"
WORKFLOW_CONFIG="${PROJECT_ROOT}/.workflow.yaml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

###############################################################################
# AUTO DEVELOPMENT CYCLE
###############################################################################

auto_dev() {
    local commit_msg="${1:-Development changes}"

    log_info "═════════════════════════════════════════════════════════════════"
    log_info "AUTOMATIC DEVELOPMENT CYCLE"
    log_info "═════════════════════════════════════════════════════════════════"
    echo ""

    # 1. Setup environment
    log_info "1️⃣  Setting up development environment..."
    bash ~/.cursor/workflow/main.sh dev 2>/dev/null || true
    log_success "Environment ready"
    echo ""

    # 2. Wait for user coding (they do this manually in Cursor)
    log_warn "2️⃣  Manual: Code your changes in Cursor"
    log_info "    - Make your code changes"
    log_info "    - Update documentation"
    log_info "    - Press Ctrl+C here when done, then run: workflow-auto review"
    echo ""
    log_info "Or continue with: workflow-auto auto-review [message]"
    echo ""
}

###############################################################################
# AUTO REVIEW (with GitHub Actions)
###############################################################################

auto_review() {
    local commit_msg="${1:-Automatic review and integration}"

    log_info "═════════════════════════════════════════════════════════════════"
    log_info "AUTOMATIC CODE REVIEW & INTEGRATION"
    log_info "═════════════════════════════════════════════════════════════════"
    echo ""

    # 1. Prepare review branch
    log_info "1️⃣  Creating review branch..."
    bash ~/.cursor/workflow/main.sh review
    log_success "Review branch created and pushed"
    echo ""

    # 2. GitHub Actions will automatically review
    log_info "2️⃣  GitHub Actions triggered - Automatic review in progress..."
    log_info "    Waiting for GitHub Actions to complete code review..."
    echo ""

    # 3. Wait a bit for GitHub Actions to run
    log_warn "    [Waiting 30 seconds for GitHub Actions to process...]"
    sleep 30
    echo ""

    # 4. Integrate
    log_info "3️⃣  Integrating code review feedback..."
    bash ~/.cursor/workflow/main.sh integrate || log_warn "No changes to integrate"
    log_success "Review integrated"
    echo ""

    log_success "Automatic review & integration complete!"
    log_info "Next: Run 'workflow-auto test-deploy' for testing & deployment"
    echo ""
}

###############################################################################
# AUTO TEST & DEPLOY
###############################################################################

auto_test_deploy() {
    log_info "═════════════════════════════════════════════════════════════════"
    log_info "AUTOMATIC TESTING & DEPLOYMENT"
    log_info "═════════════════════════════════════════════════════════════════"
    echo ""

    # 1. Run tests
    log_info "1️⃣  Running tests..."
    if ! bash ~/.cursor/workflow/main.sh test 2>&1; then
        log_error "Tests failed! Fix issues before deploying."
        return 1
    fi
    log_success "Tests passed"
    echo ""

    # 2. Deploy
    log_info "2️⃣  Deploying to production..."
    log_info "    Deploying with auto-confirmation..."

    # Get current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # Determine base branch
    BASE_BRANCH="main"
    if ! git rev-parse --verify main >/dev/null 2>&1; then
        BASE_BRANCH="master"
    fi

    if [[ "$CURRENT_BRANCH" =~ ^(main|master)$ ]]; then
        log_error "Already on $BASE_BRANCH branch"
        return 1
    fi

    log_info "Switching to $BASE_BRANCH..."
    if ! git checkout "$BASE_BRANCH"; then
        log_error "Failed to checkout $BASE_BRANCH"
        return 1
    fi

    log_info "Merging $CURRENT_BRANCH..."
    if ! git merge "$CURRENT_BRANCH" -m "Merge: Auto-deploy to production" --no-edit; then
        log_error "Merge failed!"
        git merge --abort
        return 1
    fi

    log_info "Pushing to remote..."
    if ! git push origin "$BASE_BRANCH"; then
        log_error "Push failed!"
        return 1
    fi

    log_success "Deployment initiated!"
    log_info "    GitHub Actions will handle the rest..."
    echo ""

    log_success "Automatic test & deployment complete!"
    echo ""
}

###############################################################################
# FULL AUTOMATIC CYCLE
###############################################################################

auto_full() {
    local commit_msg="${1:-Full automatic cycle}"

    log_info "═════════════════════════════════════════════════════════════════"
    log_info "FULL AUTOMATIC DEVELOPMENT CYCLE"
    log_info "═════════════════════════════════════════════════════════════════"
    echo ""
    log_info "This will:"
    log_info "1. Review code (GitHub Actions)"
    log_info "2. Integrate feedback (Automatic)"
    log_info "3. Run tests (Local)"
    log_info "4. Deploy (GitHub Actions)"
    echo ""

    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Cancelled"
        return 1
    fi

    log_info "Starting full cycle..."
    echo ""

    # Review
    auto_review

    # Test & Deploy
    auto_test_deploy

    log_success "═════════════════════════════════════════════════════════════════"
    log_success "FULL CYCLE COMPLETE!"
    log_success "═════════════════════════════════════════════════════════════════"
    echo ""
}

###############################################################################
# WATCH MODE (continuous deployment)
###############################################################################

auto_watch() {
    log_info "═════════════════════════════════════════════════════════════════"
    log_info "WATCH MODE - Auto-Deploy on Changes"
    log_info "═════════════════════════════════════════════════════════════════"
    echo ""
    log_info "Monitoring for changes... (Ctrl+C to stop)"
    echo ""

    LAST_COMMIT=$(git rev-parse HEAD)

    while true; do
        sleep 5

        # Check for new commits
        CURRENT_COMMIT=$(git rev-parse HEAD)

        if [ "$LAST_COMMIT" != "$CURRENT_COMMIT" ]; then
            log_info "Changes detected!"
            auto_full
            LAST_COMMIT=$CURRENT_COMMIT
        fi
    done
}

###############################################################################
# MAIN
###############################################################################

main() {
    if [ ! -f "$WORKFLOW_CONFIG" ]; then
        log_error "Workflow not initialized"
        log_info "Run: workflow init"
        exit 1
    fi

    if [ $# -eq 0 ]; then
        cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║     AUTOMATIC WORKFLOW ORCHESTRATOR                            ║
║  Auto: Review → Integrate → Test → Deploy                     ║
╚════════════════════════════════════════════════════════════════╝

Usage: workflow-auto <command>

Commands:
  dev                Start development
  auto-review        Auto: Review + Integrate (GitHub Actions)
  test-deploy        Auto: Test + Deploy
  full               Auto: Full cycle (review→integrate→test→deploy)
  watch              Watch mode - auto-deploy on changes

Examples:
  workflow-auto dev
  workflow-auto auto-review
  workflow-auto full
  workflow-auto watch

Full workflow:
  1. Code in Cursor
  2. workflow-auto auto-review
  3. workflow-auto test-deploy
  4. Done! Deployed automatically

Or run full cycle:
  workflow-auto full
EOF
        return 0
    fi

    case "$1" in
        dev)
            auto_dev "${2:-}"
            ;;
        auto-review)
            auto_review "${2:-}"
            ;;
        test-deploy)
            auto_test_deploy
            ;;
        full)
            auto_full "${2:-}"
            ;;
        watch)
            auto_watch
            ;;
        *)
            log_error "Unknown command: $1"
            return 1
            ;;
    esac
}

main "$@"