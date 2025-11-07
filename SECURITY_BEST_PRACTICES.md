# 🔒 Security Best Practices - Never Expose Secrets Again!

**Created**: November 7, 2025
**Purpose**: Prevent credential exposure in public repositories

---

## 🚨 The Golden Rules of Secret Management

### Rule #1: NEVER Hardcode Secrets
**Even if credentials are fake or inactive, NEVER commit them to repositories!**

❌ **WRONG**:
```javascript
const MONGODB_URI = "mongodb+srv://user:password@cluster.mongodb.net/db";
```

✅ **CORRECT**:
```javascript
const MONGODB_URI = process.env.MONGODB_URI;
```

### Rule #2: Always Use Environment Variables
```bash
# .env file (NEVER commit this!)
MONGODB_URI=mongodb+srv://actual:credentials@cluster.mongodb.net/db

# .env.example file (SAFE to commit)
MONGODB_URI=mongodb+srv://[USERNAME]:[PASSWORD]@[CLUSTER].mongodb.net/[DATABASE]
```

---

## 🛡️ Prevention Tools Setup

### 1. Install Gitleaks (Recommended)
```bash
# macOS
brew install gitleaks

# Linux
wget https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_linux_amd64
chmod +x gitleaks_linux_amd64
sudo mv gitleaks_linux_amd64 /usr/local/bin/gitleaks

# Verify installation
gitleaks version
```

### 2. Create Pre-commit Hook
```bash
# Create hooks directory
mkdir -p ~/.git-hooks

# Create pre-commit hook file
cat > ~/.git-hooks/pre-commit << 'EOF'
#!/bin/bash

echo "🔍 Scanning for secrets before commit..."

# Run Gitleaks on staged files
gitleaks git --pre-commit --redact --staged --verbose

if [ $? -ne 0 ]; then
    echo "❌ COMMIT BLOCKED: Potential secrets detected!"
    echo "📝 Fix the issues above before committing."
    exit 1
fi

echo "✅ No secrets detected. Proceeding with commit."
EOF

# Make it executable
chmod +x ~/.git-hooks/pre-commit

# Configure Git to use global hooks
git config --global core.hooksPath ~/.git-hooks
```

### 3. Alternative: TruffleHog Setup
```bash
# Install TruffleHog
brew install trufflehog  # macOS
# or
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin

# Add to pre-commit hook
cat > ~/.git-hooks/pre-commit << 'EOF'
#!/bin/bash

echo "🔍 TruffleHog scanning for secrets..."

trufflehog git file://. --since-commit HEAD --only-verified --fail

if [ $? -ne 0 ]; then
    echo "❌ COMMIT BLOCKED: Secrets detected!"
    exit 1
fi

echo "✅ No secrets detected."
EOF

chmod +x ~/.git-hooks/pre-commit
```

---

## 📁 Essential .gitignore Entries

**Always include these in your .gitignore**:
```gitignore
# Environment files
.env
.env.*
!.env.example
!.env.sample

# Credentials
credentials.json
secrets.json
*.pem
*.key
*.crt
*.p12

# Config files with potential secrets
config/secrets.yml
config/database.yml
config/credentials.yml

# IDE and system files
.vscode/settings.json
.idea/
.DS_Store
```

---

## 🏗️ Repository Structure Best Practice

```
project/
├── .env.example          # ✅ Template with placeholders (commit this)
├── .env                  # ❌ Actual credentials (NEVER commit)
├── .gitignore            # ✅ Must exclude .env files
├── .gitleaks.toml        # ✅ Gitleaks configuration
└── README.md             # ✅ Document env var requirements
```

---

## 📋 Documentation Best Practices

### In README.md or Documentation Files

❌ **NEVER write**:
```markdown
Connect using: mongodb+srv://admin:secretpass123@cluster.mongodb.net/mydb
```

✅ **ALWAYS write**:
```markdown
## Configuration

1. Copy `.env.example` to `.env`
2. Update the following variables:
   - `MONGODB_URI`: Your MongoDB connection string
   - `API_KEY`: Your API key from [service]

Example format:
`MONGODB_URI=mongodb+srv://[USERNAME]:[PASSWORD]@[CLUSTER].mongodb.net/[DATABASE]`
```

---

## 🔄 If Secrets Are Exposed

### Immediate Actions (Within 1 Hour):
1. **Rotate the exposed credentials immediately** in the service dashboard
2. **Remove from repository** (as we just did)
3. **Push the fix** to all branches
4. **Check access logs** for unauthorized usage
5. **Update all applications** using the old credentials

### GitHub History Cleanup (If Needed):
```bash
# WARNING: This rewrites history!
# Use BFG Repo-Cleaner to remove secrets from entire history
brew install bfg  # or download from https://rtyley.github.io/bfg-repo-cleaner/

# Clean the repository
bfg --replace-text passwords.txt repo.git

# Force push (coordinate with team!)
git push --force
```

---

## 🎯 Pre-Push Checklist

Before EVERY push to a public repository:

- [ ] Run `gitleaks detect` to scan entire repository
- [ ] Verify `.env` is in `.gitignore`
- [ ] Check no hardcoded credentials in code
- [ ] Ensure only `.env.example` with placeholders is committed
- [ ] Review all configuration files for secrets
- [ ] Confirm pre-commit hooks are installed

---

## 🔍 Manual Scanning Commands

```bash
# Scan current repository
gitleaks detect --source . -v

# Scan specific file
gitleaks detect --source ./config.js

# Scan git history
gitleaks detect --source . --log-opts="--all"

# Scan before push (manual)
gitleaks git --pre-commit --staged
```

---

## 📊 Statistics to Remember

- GitHub reported **39 million leaked secrets in 2024** (67% increase)
- Once pushed, secrets are **permanently compromised** (even if deleted)
- Average time to exploit exposed AWS keys: **Under 1 minute**
- Cost of average data breach: **$4.45 million** (IBM, 2024)

---

## 🏆 Best Practices Summary

1. **Use environment variables** - Never hardcode
2. **Install pre-commit hooks** - Automate prevention
3. **Use .env.example files** - Document without exposing
4. **Enable GitHub secret scanning** - Extra protection layer
5. **Rotate credentials regularly** - 30-90 days
6. **Use secret management tools** - HashiCorp Vault, AWS Secrets Manager
7. **Educate your team** - Security is everyone's responsibility

---

## 🔗 Resources

- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [TruffleHog Documentation](https://github.com/trufflesecurity/trufflehog)
- [GitGuardian Best Practices](https://blog.gitguardian.com/secrets-api-management/)

---

**Remember**: It's better to be paranoid about secrets than to have them exposed! 🔒

*Generated to prevent future credential exposures*