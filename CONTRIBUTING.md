# Contributing to SmileFactory Platform

## 🚀 Quick Start for Team Members

### Prerequisites
- Git configured with your GitHub account
- Node.js 18+ (for frontend development)
- Java 17+ (for backend development)
- Your preferred IDE (VS Code recommended)

### Getting Started
```bash
# 1. Clone the repository
git clone https://github.com/moversfinder/smilefactory-platform.git
cd smilefactory-platform

# 2. Switch to develop branch
git checkout develop
git pull origin develop

# 3. Create your feature branch
git checkout -b feature/SMILE-XXX-P[4|5]-[backend|frontend]-description
```

## 🌳 Branching Strategy

### Branch Types
- **`main`** - Production-ready code
- **`develop`** - Integration branch for development
- **`feature/`** - Feature development branches
- **`hotfix/`** - Emergency fixes for production

### Branch Naming Convention
```
feature/SMILE-[JIRA-NUMBER]-P[PHASE]-[COMPONENT]-[description]

Examples:
✅ feature/SMILE-45-P5-frontend-user-dashboard
✅ feature/SMILE-67-P4-backend-user-api
✅ feature/SMILE-89-P6-integration-auth-flow
```

### Phase Numbers
- **P4** - Backend development
- **P5** - Frontend development
- **P6** - Integration & testing

## 👥 Team Workflow

### Daily Workflow
1. **Start from develop**
   ```bash
   git checkout develop
   git pull origin develop
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/SMILE-XXX-P[4|5]-[component]-description
   ```

3. **Work and commit regularly**
   ```bash
   git add .
   git commit -m "SMILE-XXX: Brief description of changes"
   ```

4. **Push and create PR**
   ```bash
   git push origin your-branch-name
   # Create PR via GitHub web interface
   ```

### Commit Message Format
```
SMILE-XXX: Brief description of what you did

Examples:
✅ SMILE-45: Add user profile component
✅ SMILE-67: Implement user authentication API
✅ SMILE-89: Fix dashboard loading issue
```

## 🔍 Code Review Process

### Creating Pull Requests
1. **Title Format**: `SMILE-XXX [P4-Backend|P5-Frontend] Brief description`
2. **Fill out PR template** completely
3. **Link JIRA ticket** in description
4. **Request review** from team members
5. **Ensure CI checks pass** (when we add them later)

### Review Guidelines
- **Be constructive** and helpful in feedback
- **Test the changes** locally if possible
- **Check for code quality** and best practices
- **Verify documentation** is updated
- **Approve when satisfied** with quality

### Merging Requirements
- ✅ At least 1 approval from team member
- ✅ All conversations resolved
- ✅ No merge conflicts
- ✅ Branch is up to date with target

## 🎯 Development Standards

### Frontend (React/TypeScript)
- Use TypeScript for all new code
- Follow React best practices and hooks
- Use consistent naming conventions
- Write unit tests for components
- Ensure responsive design

### Backend (Java Spring Boot)
- Follow Java coding conventions
- Use proper REST API design
- Implement proper error handling
- Write unit and integration tests
- Document API endpoints

### General
- Write clear, self-documenting code
- Add comments for complex logic
- Keep functions small and focused
- Follow DRY (Don't Repeat Yourself) principle
- Update documentation when needed

## 🐛 Bug Reports and Issues

### Reporting Bugs
1. Check if issue already exists in JIRA
2. Create detailed bug report with:
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots/videos if applicable
   - Environment details

### Feature Requests
1. Discuss with team lead first
2. Create JIRA ticket with requirements
3. Get approval before starting development

## 📞 Getting Help

### Communication Channels
- **Questions**: Ask in team chat or GitHub discussions
- **Blockers**: Communicate early, don't wait
- **Code Issues**: Create GitHub issue or ask for pair programming
- **JIRA Access**: Contact project manager

### Resources
- **Documentation**: Check `docs/` folder first
- **API Specs**: `docs/2_technical_architecture/8_complete_api_documentation.md`
- **Team Onboarding**: `TEAM_ONBOARDING.md`
- **Project Overview**: `README.md`

## 🎉 Welcome to the Team!

Remember: We're building Zimbabwe's innovation future together! 🇿🇼

**Questions?** Don't hesitate to ask - we're here to help! 🤝
