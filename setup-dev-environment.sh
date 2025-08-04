#!/bin/bash

# SmileFactory Platform - Development Environment Setup
# This script helps team members set up their development environment

echo "🚀 Setting up SmileFactory Platform Development Environment"
echo "=========================================================="

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -d "docs" ]; then
    echo "❌ Please run this script from the root of the smilefactory-platform repository"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Git
if command_exists git; then
    echo "✅ Git is installed"
    git --version
else
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Check Node.js for frontend development
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js is installed: $NODE_VERSION"
    
    # Check if version is 18 or higher
    NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR_VERSION" -ge 18 ]; then
        echo "✅ Node.js version is compatible (18+)"
    else
        echo "⚠️  Node.js version should be 18 or higher. Current: $NODE_VERSION"
    fi
else
    echo "⚠️  Node.js is not installed. Frontend developers need Node.js 18+"
fi

# Check npm
if command_exists npm; then
    echo "✅ npm is installed: $(npm --version)"
else
    echo "⚠️  npm is not installed"
fi

# Check Java for backend development
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo "✅ Java is installed: $JAVA_VERSION"
else
    echo "⚠️  Java is not installed. Backend developers need Java 17+"
fi

# Check Maven for backend development
if command_exists mvn; then
    echo "✅ Maven is installed: $(mvn --version | head -n 1)"
else
    echo "⚠️  Maven is not installed. Backend developers need Maven"
fi

echo ""
echo "📁 Setting up project structure..."

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore file..."
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production builds
/frontend/build/
/frontend/dist/
/backend/target/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Database
*.db
*.sqlite

# Temporary folders
tmp/
temp/
EOF
    echo "✅ .gitignore created"
else
    echo "✅ .gitignore already exists"
fi

# Set up Git hooks directory
if [ ! -d ".githooks" ]; then
    mkdir .githooks
    echo "📁 Created .githooks directory"
fi

# Create a simple pre-commit hook
cat > .githooks/pre-commit << 'EOF'
#!/bin/bash
# Simple pre-commit hook to check for common issues

echo "🔍 Running pre-commit checks..."

# Check for merge conflict markers
if grep -r "<<<<<<< HEAD" --exclude-dir=node_modules --exclude-dir=target .; then
    echo "❌ Merge conflict markers found. Please resolve conflicts before committing."
    exit 1
fi

# Check for TODO/FIXME comments in staged files
if git diff --cached --name-only | xargs grep -l "TODO\|FIXME" 2>/dev/null; then
    echo "⚠️  Found TODO/FIXME comments in staged files. Consider addressing them."
fi

echo "✅ Pre-commit checks passed"
EOF

chmod +x .githooks/pre-commit

# Configure git to use our hooks
git config core.hooksPath .githooks
echo "✅ Git hooks configured"

echo ""
echo "🌳 Setting up branch structure..."

# Make sure we're on the right branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Check if develop branch exists
if git show-ref --verify --quiet refs/heads/develop; then
    echo "✅ develop branch exists"
else
    echo "📝 Creating develop branch..."
    git checkout -b develop
    git push -u origin develop
    echo "✅ develop branch created and pushed"
fi

# Switch to develop if not already there
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "🔄 Switching to develop branch..."
    git checkout develop
    git pull origin develop
fi

echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "📋 Next steps for team members:"
echo "1. 📖 Read TEAM_ONBOARDING.md for detailed setup instructions"
echo "2. 🔄 Read TEAM_WORKFLOW_QUICK_REFERENCE.md for daily workflow"
echo "3. 🤝 Read CONTRIBUTING.md for development standards"
echo "4. 🔗 Read JIRA_GITHUB_INTEGRATION.md for project management"
echo "5. 🌳 Create your first feature branch:"
echo "   Frontend: git checkout -b feature/SMILE-XXX-P5-frontend-description"
echo "   Backend:  git checkout -b feature/SMILE-XXX-P4-backend-description"
echo "6. 🎯 Check JIRA for your assigned tickets"
echo "7. 💻 Start coding and follow the workflow!"
echo ""
echo "📚 Key Documentation:"
echo "   • Frontend: docs/5_frontend_implementation/"
echo "   • Backend:  docs/4_backend_implementation/"
echo "   • APIs:     docs/2_technical_architecture/8_complete_api_documentation.md"
echo ""
echo "🤝 Happy coding! Let's build Zimbabwe's innovation future together! 🇿🇼"
