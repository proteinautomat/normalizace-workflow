# Installation Guide - Normalizace Workflow

How to set up automatic workflow system for your projects.

## For New Projects

### 1. Create GitHub Repository

```bash
# Create on GitHub
# Clone locally
git clone https://github.com/YOUR_ORG/your-project
cd your-project
```

### 2. Add Workflow Files

```bash
# Copy GitHub Actions workflow
mkdir -p .github/workflows
cp /root/normalizace-workflow/.github/workflows/auto-codex-review.yml \
   .github/workflows/

# Copy configuration template
cp /root/normalizace-workflow/.workflow.yaml \
   .
```

### 3. Customize Configuration

Edit `.workflow.yaml` for your project:

```yaml
project: "my-app"
type: "python"  # or nodejs, go

make:
  dev: "pip install -e ."
  test: "pytest tests/"
  deploy: "bash scripts/deploy.sh"

health_check: "http://localhost:5000/health"
```

### 4. Commit and Push

```bash
git add .github/workflows/auto-codex-review.yml .workflow.yaml
git commit -m "ci: Add automatic workflow system"
git push origin master
```

Done! Workflow is now active.

## For Existing Projects

### 1. Copy Workflow File

```bash
cd your-existing-project
mkdir -p .github/workflows
cp /root/normalizace-workflow/.github/workflows/auto-codex-review.yml \
   .github/workflows/auto-codex-review.yml
```

### 2. Add Configuration

Copy and customize configuration:

```bash
cp /root/normalizace-workflow/.workflow.yaml .workflow.yaml
# Edit .workflow.yaml with your project settings
nano .workflow.yaml
```

### 3. Test It

```bash
# Make a small test change
echo "# Test" >> README.md

# Push to test branch
git checkout -b review/test
git add README.md
git commit -m "test: Testing workflow"
git push origin review/test

# Check GitHub Actions
# Go to: https://github.com/YOUR_ORG/YOUR_REPO/actions
```

### 4. Final Commit

```bash
git checkout master
git merge review/test
git push origin master
```

## Shell Integration (Optional)

Add aliases to your shell for easy access:

### For Bash/Zsh

Add to `~/.bashrc` or `~/.zshrc`:

```bash
alias kodovani-auto='bash /root/normalizace-workflow/kodovani-workflow-auto.sh'
alias kodovani='bash /root/normalizace-workflow/kodovani-workflow.sh'
```

Then reload:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

### For Fish Shell

Add to `~/.config/fish/config.fish`:

```fish
alias kodovani-auto 'bash /root/normalizace-workflow/kodovani-workflow-auto.sh'
alias kodovani 'bash /root/normalizace-workflow/kodovani-workflow.sh'
```

## Cursor IDE Integration

If using Cursor IDE, add to `.cursor/settings.json`:

```json
{
  "terminal.integrated.shellArgs.linux": ["-c", "cd ${workspaceFolder} && bash"]
}
```

This ensures proper working directory when using workflow commands.

## System Requirements

- **Git** 2.25+
- **GitHub Account** with repo access
- **Bash** 4.0+
- **Make** (optional, for running build commands)

## Verification

### Check Installation

```bash
# Test workflow aliases
kodovani --help
kodovani-auto --help

# Check GitHub Actions
# Visit: https://github.com/YOUR_ORG/YOUR_REPO/actions
# Should see "Automatic Code Review by Claude (Codex Role)"
```

### Test First Run

```bash
# 1. Make a small change
echo "test" >> README.md

# 2. Create review branch
git checkout -b review/test-setup
git add README.md
git commit -m "test: Setup testing"
git push origin review/test-setup

# 3. Watch GitHub Actions run
# Visit Actions tab on GitHub
# Should see workflow start within 30 seconds

# 4. Check generated review
# Go back to master
git checkout master
git pull origin master
```

## Troubleshooting

### GitHub Actions Not Showing

**Problem:** "Automatic Code Review" workflow not in Actions tab

**Solution:**
1. Check `.github/workflows/auto-codex-review.yml` exists in repo
2. Ensure file is committed and pushed to GitHub
3. Refresh GitHub page (F5)
4. Check repo Settings → Actions → Enable

### Workflow Not Triggering

**Problem:** Push to `review/*` branch but workflow doesn't run

**Solution:**
1. Check branch name matches `review/*` pattern
2. Confirm file is pushed to remote: `git branch -r`
3. Check workflow YAML syntax: `gh workflow view auto-codex-review.yml`
4. Look at run logs on GitHub for errors

### Permission Denied Errors

**Problem:** "Permission denied" when running scripts

**Solution:**
```bash
chmod +x /root/normalizace-workflow/kodovani-workflow*.sh
```

### Tests Failing

**Problem:** Tests fail when running kodovani-auto test-deploy

**Solution:**
1. Fix tests locally first
2. Verify test command in `.workflow.yaml` is correct
3. Run same command locally: `make test` (or configured command)
4. Push again after fixing

## Support

### Common Issues

- **Workflow doesn't trigger**: Check branch name starts with `review/`
- **Tests timeout**: Increase timeout in `.workflow.yaml`
- **Deploy fails**: Check health_check endpoint is correct
- **Review.md not generated**: Ensure GitHub Actions has write permissions

### Getting Help

1. Check workflow logs on GitHub Actions tab
2. Review `.workflow.yaml` configuration
3. Test workflow locally with `kodovani --help`
4. Check file permissions: `ls -la .github/workflows/`

## Next Steps

After installation:

1. **Customize** `.workflow.yaml` for your project
2. **Test** with a small feature branch
3. **Review** the generated instructions
4. **Deploy** with confidence

See [README.md](README.md) for usage examples.

---

**Installation Complete!** 🎉

Your project now has automatic code review and deployment. Start using it:

```bash
kodovani-auto auto-review    # Automatic review
kodovani-auto test-deploy    # Test and deploy
```
