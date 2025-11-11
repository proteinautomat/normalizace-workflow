# Normalizace Workflow - Automatic Development Pipeline

Automatic development workflow system that handles code review, integration, testing, and deployment with zero manual configuration.

**Status:** ✅ Production Ready

## Features

✨ **Automatic Code Review** - GitHub Actions automatically reviews code changes
✨ **Automatic Integration** - Feedback is automatically merged back
✨ **Automatic Testing** - Tests run before deployment
✨ **Automatic Deployment** - Changes automatically deployed to production
✨ **Zero Manual Steps** - After you code, everything is automatic

## How It Works

### 1. **Code Your Feature**
Work normally in your editor. No special workflow needed.

```bash
# Edit files, make changes
# Update documentation
# Commit locally
```

### 2. **Automatic Code Review**
Push to a review branch - GitHub Actions automatically runs.

```bash
kodovani-auto auto-review

# What happens:
# 1. Creates review branch: review/dev-*
# 2. GitHub Actions triggers
# 3. Generates review instructions with GitHub diff link
# 4. Shows exactly what needs to be reviewed
```

### 3. **Review the Code**
Click the GitHub link and review changes with provided checklist.

```
GitHub Diff URL: https://github.com/YOUR/REPO/compare/master...review/your-branch

✅ Review Checklist:
- [ ] Code follows project conventions
- [ ] No obvious bugs or issues
- [ ] Error handling is proper
- [ ] Security checks passed
- [ ] Documentation updated
- [ ] Tests adequate
```

### 4. **Deploy**
Tests run and code is automatically deployed.

```bash
kodovani-auto test-deploy

# What happens:
# 1. Runs all tests
# 2. Merges to master/main
# 3. GitHub Actions deploys
# 4. Server updated automatically
```

## ⚠️ IMPORTANT: Each Project Needs Its Own GitHub Repository

**CRITICAL REQUIREMENT:** This workflow system requires that **EVERY project has its own separate GitHub repository**.

### Why Separate Repos?

```
❌ WRONG - Multi-project in single repo:
one-repo/
├── project-1/
├── project-2/
└── project-3/
# ❌ GitHub Actions can't trigger properly per project!
# ❌ Workflow gets confused about which branch/project
# ❌ Deployments conflict
```

```
✅ CORRECT - Separate repos:
GitHub Repo: normalizace-workflow (this project)
GitHub Repo: projekt-1 (separate!)
GitHub Repo: projekt-2 (separate!)
GitHub Repo: projekt-3 (separate!)
# ✅ Each has independent .github/workflows/
# ✅ Automatic triggering works perfectly
# ✅ Separate deployment pipelines
```

### Key Points

- ✅ Each project MUST have its own GitHub repository
- ✅ Each repo gets its own `.github/workflows/auto-codex-review.yml`
- ✅ GitHub Actions triggers independently per repo
- ✅ `review/*` branch pattern works only in that repo's context
- ✅ Each project has isolated deployment

### Setup Pattern

For each of your projects:

```bash
# 1. Create repo on GitHub (separate!)
gh repo create my-project-1

# 2. Clone it
git clone https://github.com/YOUR_ORG/my-project-1
cd my-project-1

# 3. Add workflow (from normalizace-workflow)
cp .../normalizace-workflow/.github/workflows/auto-codex-review.yml \
   .github/workflows/

# 4. Configure for this project
cp .../normalizace-workflow/.workflow.yaml .

# 5. Push it
git add .github/workflows/ .workflow.yaml
git commit -m "ci: Add automatic workflow"
git push origin master

# Now JUST THIS PROJECT has automatic workflow!
```

---

## Installation

### For Existing Projects

1. **Copy workflow file to your repo:**

```bash
mkdir -p .github/workflows
cp .github/workflows/auto-codex-review.yml YOUR_REPO/.github/workflows/
```

2. **Add aliases to your shell** (`.bashrc` or `.zshrc`):

```bash
alias kodovani-auto='bash /path/to/kodovani-workflow-auto.sh'
alias kodovani='bash /path/to/kodovani-workflow.sh'
```

3. **Push to GitHub:**

```bash
git add .github/workflows/auto-codex-review.yml
git commit -m "ci: Add automatic code review workflow"
git push origin master
```

Now whenever you push to a `review/*` branch, GitHub Actions will automatically trigger!

### For This Project

```bash
# Clone
git clone https://github.com/YOUR_ORG/normalizace-workflow
cd normalizace-workflow

# Use the workflow scripts
bash kodovani-workflow.sh --help
bash kodovani-workflow-auto.sh --help
```

## Quick Start

### Step 1: Initialize Your Project

```bash
cd your-project
kodovani init
```

### Step 2: Start Development

```bash
# Method 1: Step by step
kodovani-auto auto-review    # Review stage
kodovani-auto test-deploy    # Deploy stage

# Method 2: Full cycle
kodovani-auto full           # All stages in one command

# Method 3: Watch mode
kodovani-auto watch         # Auto-deploy on every commit
```

## File Structure

```
.
├── .github/workflows/
│   └── auto-codex-review.yml          # GitHub Actions workflow
├── .workflow-logs/                     # Workflow execution logs
├── kodovani-workflow.sh                # Manual workflow orchestrator
├── kodovani-workflow-auto.sh          # Automatic workflow orchestrator
├── .workflow.yaml                      # Per-project configuration
└── README.md
```

## Workflow Configuration

### `.workflow.yaml` (per project)

```yaml
project: "my-app"
type: "python"  # or nodejs, go

make:
  dev: "make dev"
  test: "make test"
  lint: "make lint"
  deploy: "make deploy"

health_check: "http://localhost:5000/health"
```

## GitHub Actions Workflow

The `auto-codex-review.yml` workflow:

1. **Triggers** on any push to `review/*` branches
2. **Generates** code review instructions with:
   - GitHub diff URL (clickable)
   - Review checklist
   - Security checks
   - Documentation verification
3. **Creates** REVIEW.md file with findings
4. **Shows** exactly what needs to be reviewed

**Key features:**
- Handles both `main` and `master` branches
- Safe git operations with proper error handling
- Continues even if PR context is missing (push events)
- Generates simple, clear instructions

## Commands

### Manual Workflow

```bash
kodovani init              # Initialize workflow
kodovani dev              # Start development
kodovani review           # Create review branch
kodovani integrate        # Merge review feedback
kodovani test             # Run tests
kodovani deploy           # Deploy to production
kodovani status           # Check current status
```

### Automatic Workflow (Recommended)

```bash
kodovani-auto dev              # Development setup
kodovani-auto auto-review      # Automatic: Review + Integrate
kodovani-auto test-deploy      # Automatic: Test + Deploy
kodovani-auto full             # Automatic: Full cycle
kodovani-auto watch            # Watch mode - auto-deploy on changes
```

## Real-World Example

### Day 1 - Feature Development

```bash
# 9:00 AM - Open editor
cd my-project

# 9:00 - 12:00 - Code feature
# Edit app/main.py
# Update README.md
# Test locally

# 12:00 - Push to review
kodovani-auto auto-review

# GitHub Actions runs automatically:
# - Generates review instructions
# - Shows GitHub diff link
# - Creates checklist
# (Takes ~30 seconds)

# 12:30 - Deploy
kodovani-auto test-deploy

# What happens:
# 1. Tests run locally
# 2. Code merged to master
# 3. GitHub Actions auto-deploys
# 4. Server updated (takes ~2-3 min)

# 1:00 PM - Feature is LIVE! 🎉
```

## How Review Works

When you run `kodovani-auto auto-review`:

```
1. Code is pushed to review/dev-* branch
   ↓
2. GitHub Actions triggered (automatic)
   ↓
3. Workflow generates review instructions
   - Shows complete diff on GitHub
   - Provides checklist
   - Lists security checks
   ↓
4. Review is committed to branch
   ↓
5. Local script integrates feedback
   ↓
6. Ready for testing!
```

**The key:** Simple GitHub link shows everything needed for review. No need to look at multiple places.

## Safety & Reliability

### Error Handling

✅ All git operations checked for errors
✅ Tests must pass before deploy
✅ Merge conflicts detected and handled
✅ Health checks verified before considering success

### Git Safety

✅ Full git history preserved
✅ Can rollback anytime: `git revert HEAD`
✅ All changes tracked in commits
✅ Branch protection on main/master

### Logging

✅ Session logs in `.workflow-logs/`
✅ All commands logged with timestamps
✅ Error messages clear and actionable

## Troubleshooting

### GitHub Actions Not Triggering

Check:
1. Workflow file is in `.github/workflows/`
2. Branch name matches `review/*` pattern
3. GitHub Actions is enabled in repo settings

### Review Instructions Not Showing

Check:
1. Branch has commits (not empty)
2. GitHub Actions completed successfully
3. Check workflow logs on GitHub

### Tests Failing Before Deploy

Solution:
1. Fix failing tests locally
2. Run `kodovani-auto test-deploy` again
3. Deploy only runs after tests pass

## Architecture

### Components

- **Main Orchestrator** (`kodovani-workflow.sh`): Manual workflow control
- **Auto Orchestrator** (`.kodovani-auto.sh`): Automatic execution
- **GitHub Actions** (`auto-codex-review.yml`): Remote code review automation
- **Config** (`.workflow.yaml`): Per-project settings

### Flow

```
Code → Push to review/* → GitHub Actions triggers → Review Instructions Generated
                                                       ↓
                                        Manual Review (with GitHub link)
                                                       ↓
Merge to master → Tests Run → Health Check → Deploy Complete
```

## Advanced Usage

### Custom Test Commands

Edit `.workflow.yaml`:
```yaml
make:
  test: "pytest tests/ -v --cov"
  deploy: "./scripts/deploy.sh production"
```

### Multiple Projects

Each project needs:
```bash
.github/workflows/auto-codex-review.yml
.workflow.yaml
```

The system auto-detects project type and configures accordingly.

### Continuous Deployment

```bash
kodovani-auto watch

# Monitors git for changes
# Auto-runs full cycle on each commit
# Ctrl+C to stop
```

## Contributing

This workflow system is designed to be:
- Simple and understandable
- Reliable and production-ready
- Adaptable to different project types
- Easy to customize

## License

MIT

---

## Quick Links

- **GitHub**: [normalizace-workflow](https://github.com/proteinautomat/normalizace-workflow)
- **Documentation**: See README.md (this file)
- **Example**: See `.github/workflows/auto-codex-review.yml`

---

**Status:** ✅ Production Ready | **Version:** 1.0.0 | **Last Updated:** 2025-11-11

Start using automatic workflows today. Code → Review → Deploy. Automatic. 🚀
