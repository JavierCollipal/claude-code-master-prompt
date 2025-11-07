#!/bin/bash

# 🔒 Security Setup Script for Claude Code Master Prompt
# This script sets up gitleaks and pre-commit hooks to prevent secret exposure

set -e

echo "🔒 Setting up security tools to prevent credential exposure..."
echo "============================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Install Gitleaks
echo -e "\n${YELLOW}Step 1: Installing Gitleaks...${NC}"

if command_exists gitleaks; then
    echo -e "${GREEN}✅ Gitleaks is already installed${NC}"
    gitleaks version
else
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command_exists brew; then
            echo "Installing Gitleaks via Homebrew..."
            brew install gitleaks
        else
            echo -e "${RED}Homebrew not found. Please install: https://brew.sh${NC}"
            exit 1
        fi
    else
        # Linux
        echo "Installing Gitleaks for Linux..."
        GITLEAKS_VERSION=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        wget "https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION#v}_linux_x64.tar.gz"
        tar -xzf "gitleaks_${GITLEAKS_VERSION#v}_linux_x64.tar.gz"
        sudo mv gitleaks /usr/local/bin/
        rm "gitleaks_${GITLEAKS_VERSION#v}_linux_x64.tar.gz" LICENSE README.md
        echo -e "${GREEN}✅ Gitleaks installed successfully${NC}"
    fi
fi

# 2. Create global git hooks directory
echo -e "\n${YELLOW}Step 2: Setting up Git hooks...${NC}"

HOOKS_DIR="$HOME/.git-hooks"
mkdir -p "$HOOKS_DIR"

# 3. Create pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash

# Pre-commit hook to scan for secrets using gitleaks

echo "🔍 Scanning for secrets before commit..."

# Check if gitleaks is installed
if ! command -v gitleaks &> /dev/null; then
    echo "⚠️  Gitleaks is not installed. Please run setup-security.sh"
    echo "   Continuing without secret scanning (NOT RECOMMENDED)"
    exit 0
fi

# Run gitleaks on staged files
gitleaks git --pre-commit --redact --staged --verbose

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ COMMIT BLOCKED: Potential secrets detected!"
    echo ""
    echo "📝 How to fix:"
    echo "   1. Remove the secret from your code"
    echo "   2. Use environment variables instead (.env file)"
    echo "   3. Add placeholder text like [USERNAME]:[PASSWORD]"
    echo ""
    echo "🔄 To bypass (ONLY if false positive):"
    echo "   git commit --no-verify"
    echo ""
    exit 1
fi

echo "✅ No secrets detected. Proceeding with commit."
EOF

chmod +x "$HOOKS_DIR/pre-commit"
echo -e "${GREEN}✅ Pre-commit hook created${NC}"

# 4. Configure Git to use global hooks
echo -e "\n${YELLOW}Step 3: Configuring Git to use hooks globally...${NC}"
git config --global core.hooksPath "$HOOKS_DIR"
echo -e "${GREEN}✅ Git configured to use global hooks${NC}"

# 5. Create .gitleaks.toml configuration
echo -e "\n${YELLOW}Step 4: Creating Gitleaks configuration...${NC}"

cat > .gitleaks.toml << 'EOF'
title = "Gitleaks Configuration for Claude Code Master Prompt"

# Additional patterns to detect
[[rules]]
description = "MongoDB Connection String"
regex = '''mongodb(\+srv)?://[^:]+:[^@]+@[^/]+/[^\s"']+'''
tags = ["database", "mongodb"]

[[rules]]
description = "Generic API Key"
regex = '''(?i)(api[_-]?key|apikey)['"]?\s*[:=]\s*['"][a-z0-9]{32,}['"]'''
tags = ["api", "key"]

# Allowlist - patterns to ignore (false positives)
[allowlist]
paths = [
    '''.env.example''',
    '''.env.sample''',
    '''SECURITY_BEST_PRACTICES.md''',
    '''README.md'''
]

# Allow example/placeholder credentials
regexes = [
    '''mongodb\+srv://\[USERNAME\]:\[PASSWORD\]@\[CLUSTER\]''',
    '''YOUR_[A-Z_]+_HERE''',
    '''\[YOUR_[A-Z_]+\]'''
]
EOF

echo -e "${GREEN}✅ Gitleaks configuration created${NC}"

# 6. Run initial scan
echo -e "\n${YELLOW}Step 5: Running initial security scan...${NC}"
echo "This may take a moment..."

gitleaks detect --source . -v --redact

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ No secrets detected in repository${NC}"
else
    echo -e "${YELLOW}⚠️  Potential secrets detected. Please review above.${NC}"
fi

# 7. Final summary
echo ""
echo "============================================"
echo -e "${GREEN}🎉 Security setup complete!${NC}"
echo ""
echo "📋 What's been configured:"
echo "   ✅ Gitleaks installed and configured"
echo "   ✅ Pre-commit hook installed globally"
echo "   ✅ Git configured to use hooks"
echo "   ✅ Custom gitleaks rules added"
echo ""
echo "🔒 Your repository is now protected against accidental secret exposure!"
echo ""
echo "📝 Next steps:"
echo "   1. Copy .env.example to .env and add your real credentials"
echo "   2. Verify .env is in .gitignore"
echo "   3. Test the hook: Try to commit a fake secret"
echo ""
echo "💡 Tips:"
echo "   - The hook will run automatically before every commit"
echo "   - To bypass (only if false positive): git commit --no-verify"
echo "   - Run 'gitleaks detect' anytime to scan manually"
echo ""
echo "Stay secure! 🔒"