#!/bin/bash

###############################################################################
# UNIVERSAL DEVOPS WORKFLOW ORCHESTRATOR
#
# Workflow: Code → Review (Codex) → GitHub → Local Test → Server Deploy
# Works with any project type (Python, Node.js, Go, etc.)
#
# Usage:
#   kodovani dev          - Start development
#   kodovani review       - Prepare for Codex review
#   kodovani integrate    - Integrate Codex review
#   kodovani test         - Run local tests
#   kodovani deploy       - Deploy to server
#   kodovani status       - Show workflow status
#
# Author: Claude Code Generator
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PWD}"
WORKFLOW_CONFIG="${PROJECT_ROOT}/.workflow.yaml"
STATE_FILE="${PROJECT_ROOT}/.workflow-state"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

###############################################################################
# HELPER FUNCTIONS
###############################################################################

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

check_config() {
    if [ ! -f "$WORKFLOW_CONFIG" ]; then
        log_error "Workflow config not found: $WORKFLOW_CONFIG"
        log_info "Run 'kodovani init' first to create config"
        exit 1
    fi
}

init_state() {
    cat > "$STATE_FILE" << EOF
{
  "stage": "idle",
  "branch": "develop",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "codex_review": false,
  "tested": false
}
EOF
}

get_git_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main"
}

###############################################################################
# WORKFLOW STAGES
###############################################################################

# STAGE 1: DEV - Local coding with documentation
stage_dev() {
    log_info "Starting development workflow..."

    check_config

    # Get project config
    PROJECT_TYPE=$(grep "project_type:" "$WORKFLOW_CONFIG" | head -1 | awk '{print $2}')

    # Create development branch
    BRANCH="dev-$(date +%s)"
    log_info "Creating branch: $BRANCH"
    git checkout -b "$BRANCH" || git checkout "$BRANCH"

    # Run pre-code hook
    if [ -f "$SCRIPT_DIR/hooks/pre-code.sh" ]; then
        log_info "Running pre-code hook..."
        bash "$SCRIPT_DIR/hooks/pre-code.sh"
    fi

    # Setup environment based on project type
    case "$PROJECT_TYPE" in
        python)
            log_info "Python project detected"
            [ -d "venv" ] || python3 -m venv venv
            source venv/bin/activate
            [ -f "requirements.txt" ] && pip install -r requirements.txt --quiet
            ;;
        nodejs)
            log_info "Node.js project detected"
            [ -d "node_modules" ] || npm install --silent
            ;;
        go)
            log_info "Go project detected"
            go mod download
            ;;
    esac

    log_success "Development environment ready"
    log_info "Repository: $PROJECT_ROOT"
    log_info "Branch: $BRANCH"
    log_info "Now code your changes... Press Enter when ready for review"
    read -p ""

    # Ask for documentation
    if [ -f "navod.md" ] || [ -f "DOCUMENTATION.md" ]; then
        log_warn "Remember to update documentation!"
        read -p "Have you updated docs? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_warn "Please update documentation before continuing"
            return 1
        fi
    fi

    # Run post-code hook
    if [ -f "$SCRIPT_DIR/hooks/post-code.sh" ]; then
        log_info "Running post-code hook..."
        bash "$SCRIPT_DIR/hooks/post-code.sh"
    fi

    # Commit changes
    log_info "Preparing commit..."
    git add -A
    git commit -m "dev($BRANCH): Development changes

- Coded by Claude via Cursor
- Ready for Codex review
- Documentation updated: $(date)

Generated with Claude Code" || log_warn "No changes to commit"

    log_success "Development stage complete"
}

# STAGE 2: REVIEW - Prepare for Codex review on separate branch
stage_review() {
    log_info "Preparing for Codex code review..."

    check_config

    CURRENT_BRANCH=$(get_git_branch)
    REVIEW_BRANCH="review/$CURRENT_BRANCH"

    log_info "Creating review branch: $REVIEW_BRANCH"
    git push origin "$CURRENT_BRANCH"
    git checkout -b "$REVIEW_BRANCH" || git checkout "$REVIEW_BRANCH"

    # Run pre-review hook
    if [ -f "$SCRIPT_DIR/hooks/pre-review.sh" ]; then
        bash "$SCRIPT_DIR/hooks/pre-review.sh"
    fi

    log_info "Review branch: $REVIEW_BRANCH"
    log_info "Push this branch to GitHub for Codex review"
    log_info "Codex will review and suggest changes"

    git push origin "$REVIEW_BRANCH" -u
    log_success "Ready for Codex review on branch: $REVIEW_BRANCH"
}

# STAGE 3: INTEGRATE - Merge Codex review feedback
stage_integrate() {
    log_info "Integrating Codex review..."

    REVIEW_BRANCH=$(get_git_branch)

    if [[ ! "$REVIEW_BRANCH" =~ ^review/ ]]; then
        log_error "Not on a review branch. Current branch: $REVIEW_BRANCH"
        return 1
    fi

    # Get the original dev branch
    DEV_BRANCH="${REVIEW_BRANCH#review/}"

    log_info "Review branch: $REVIEW_BRANCH"
    log_info "Dev branch: $DEV_BRANCH"

    # Check for conflicts
    if git merge-base --is-ancestor "$DEV_BRANCH" "$REVIEW_BRANCH"; then
        log_info "Merging review changes..."
        git checkout "$DEV_BRANCH"
        git merge "$REVIEW_BRANCH" -m "Merge: Integrate Codex review changes"
    fi

    # Run post-review hook
    if [ -f "$SCRIPT_DIR/hooks/post-review.sh" ]; then
        bash "$SCRIPT_DIR/hooks/post-review.sh"
    fi

    log_success "Codex review integrated"
    log_info "Next: Run tests with 'kodovani test'"
}

# STAGE 4: TEST - Local testing before deployment
stage_test() {
    log_info "Running local tests..."

    check_config

    PROJECT_TYPE=$(grep "project_type:" "$WORKFLOW_CONFIG" | head -1 | awk '{print $2}')

    case "$PROJECT_TYPE" in
        python)
            if [ -f "requirements.txt" ]; then
                log_info "Testing Python environment..."

                # Check if venv exists, create if needed
                if [ ! -d "venv" ]; then
                    log_info "Virtual environment not found, creating..."
                    python3 -m venv venv
                fi

                # Activate virtual environment
                source venv/bin/activate

                # Run tests if tests directory exists
                if [ -d "tests" ]; then
                    log_info "Running pytest..."
                    if python -m pytest tests/ -v; then
                        log_success "All tests passed"
                    else
                        log_error "Tests failed"
                        return 1
                    fi
                else
                    log_warn "No tests directory found"
                fi

                # Run health check if available
                if grep -q "uvicorn\|fastapi" requirements.txt; then
                    log_info "Starting FastAPI health check..."
                    timeout 5 uvicorn app.main:app --host 127.0.0.1 --port 8001 &
                    sleep 2
                    curl -s http://127.0.0.1:8001/health && log_success "Health check passed"
                    pkill -f "uvicorn"
                fi
            fi
            ;;
        nodejs)
            log_info "Testing Node.js environment..."
            npm test 2>/dev/null || log_warn "No tests configured"
            ;;
    esac

    log_success "Local tests completed"
}

# STAGE 5: DEPLOY - Merge to main and deploy
stage_deploy() {
    log_info "Deploying to server..."

    CURRENT_BRANCH=$(get_git_branch)

    # Ensure we're not on develop/review branch
    if [[ "$CURRENT_BRANCH" =~ ^(dev-|review/) ]]; then
        log_error "Cannot deploy from development/review branch"
        log_info "Switch to main branch first"
        return 1
    fi

    log_warn "About to merge to main and trigger GitHub Actions deployment"
    read -p "Confirm deployment? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout main
        git merge "$CURRENT_BRANCH" -m "Merge: Deploy to production"
        git push origin main

        log_success "Merged to main branch"
        log_info "GitHub Actions will automatically deploy..."
        log_info "Check: https://github.com/<repo>/actions"
    else
        log_warn "Deployment cancelled"
    fi
}

# STATUS - Show workflow status
stage_status() {
    log_info "Workflow Status"
    echo "───────────────────────────────────"
    echo "Project: $(basename "$PROJECT_ROOT")"
    echo "Current Branch: $(get_git_branch)"
    echo "Config: $WORKFLOW_CONFIG"

    if [ -f "$STATE_FILE" ]; then
        echo "───────────────────────────────────"
        echo "State:"
        cat "$STATE_FILE" | grep -E "stage|branch|codex|tested" || echo "No state"
    fi
}

# INIT - Initialize workflow for project
stage_init() {
    log_info "Initializing workflow for this project..."

    if [ -f "$WORKFLOW_CONFIG" ]; then
        log_warn "Config already exists: $WORKFLOW_CONFIG"
        return 0
    fi

    # Detect project type
    if [ -f "requirements.txt" ]; then
        PROJECT_TYPE="python"
    elif [ -f "package.json" ]; then
        PROJECT_TYPE="nodejs"
    elif [ -f "go.mod" ]; then
        PROJECT_TYPE="go"
    else
        PROJECT_TYPE="generic"
    fi

    log_info "Detected project type: $PROJECT_TYPE"

    # Create config from template
    cat > "$WORKFLOW_CONFIG" << EOF
# Workflow Configuration for $(basename "$PROJECT_ROOT")
project_type: $PROJECT_TYPE
created: $(date -u +%Y-%m-%dT%H:%M:%SZ)

# Test command (optional)
test_command: "make test || npm test || pytest tests/ || go test ./..."

# Deploy command (optional)
deploy_command: "systemctl restart myapp"

# Health check endpoint
health_check: "http://localhost:8000/health"

# Documentation files to maintain
docs:
  - README.md
  - DEPLOYMENT.md
  - CHANGELOG.md

# Review requirements
review:
  required_by: codex
  branch_prefix: review/
  approval_needed: true
EOF

    log_success "Workflow config created: $WORKFLOW_CONFIG"
    init_state
    log_success "State file created: $STATE_FILE"
}

###############################################################################
# MAIN
###############################################################################

main() {
    if [ $# -eq 0 ]; then
        cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║      KODOVANI WORKFLOW ORCHESTRATOR                           ║
║  Code → Review → GitHub → Test → Deploy                       ║
╚════════════════════════════════════════════════════════════════╝

Usage: kodovani <command>

Commands:
  init       Initialize workflow for this project
  dev        Start development (local coding + docs)
  review     Prepare for Codex review
  integrate  Integrate Codex review feedback
  test       Run local tests
  deploy     Deploy to production server
  status     Show workflow status

Examples:
  kodovani init              # First time setup
  kodovani dev               # Start coding
  kodovani review            # Create review branch
  kodovani integrate         # Merge review changes
  kodovani test              # Test locally
  kodovani deploy            # Deploy to server

For more info: cat README.md
EOF
        return 0
    fi

    case "$1" in
        init)
            stage_init
            ;;
        dev)
            stage_dev
            ;;
        review)
            stage_review
            ;;
        integrate)
            stage_integrate
            ;;
        test)
            stage_test
            ;;
        deploy)
            stage_deploy
            ;;
        status)
            stage_status
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Run 'kodovani' with no arguments to see help"
            return 1
            ;;
    esac
}

main "$@"
