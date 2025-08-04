# Git Branching Strategy - SmileFactory Platform

## 🌳 **Branching Strategy Overview**

This document defines the comprehensive Git branching strategy for the SmileFactory platform development team, designed to support parallel development, quality assurance, and seamless deployment across multiple environments.

## 🎯 **Strategy: Enhanced GitHub Flow with Environment Branches**

We use a modified GitHub Flow strategy optimized for team collaboration, continuous integration, and multi-environment deployment.

### **Core Principles**
- **Simple and Scalable**: Easy to understand and implement for teams of any size
- **JIRA Integration**: Branch names automatically link to JIRA issues
- **Quality Gates**: Built-in code review and testing requirements
- **Parallel Development**: Support for multiple features and teams
- **Safe Deployments**: Protected branches and automated testing

## 🏗️ **Branch Structure**

### **Main Branches**

#### **1. `main` Branch** 🏠
- **Purpose**: Production-ready code
- **Protection**: Highest level protection
- **Deployment**: Automatically deploys to production
- **Merge Requirements**: 
  - Pull request required
  - 2+ approvals from CODEOWNERS
  - All CI checks must pass
  - Up-to-date with base branch

#### **2. `develop` Branch** 🔧
- **Purpose**: Integration branch for ongoing development
- **Protection**: High level protection
- **Deployment**: Automatically deploys to staging environment
- **Merge Requirements**:
  - Pull request required
  - 1+ approval from team leads
  - All CI checks must pass

#### **3. `staging` Branch** 🎭
- **Purpose**: Pre-production testing and UAT
- **Protection**: Medium level protection
- **Deployment**: Deploys to staging environment for testing
- **Source**: Merged from `develop` when ready for testing

### **Feature Branches**

#### **Enhanced Branch Naming Convention**
```
{type}/{jira-key}-{phase-context}-{short-description}

Examples:
- feature/SMILE-123-P4-backend-user-authentication
- feature/SMILE-124-P5-frontend-user-profile-ui
- bugfix/SMILE-456-P5-frontend-dashboard-loading
- hotfix/SMILE-789-security-vulnerability
- epic/SMILE-15-P3-development-setup
```

#### **Phase Context Mapping**
- **P1**: Planning & Requirements (documentation/analysis)
- **P2**: Technical Architecture (design/specifications)
- **P3**: Development Setup (devops/infrastructure)
- **P4**: Backend Implementation (api/database/services)
- **P5**: Frontend Implementation (ui/components/state)
- **P6**: AI Integration (ai/ml/recommendations)
- **P7**: Integration & Testing (testing/qa/integration)
- **P8**: Deployment & Operations (deployment/monitoring)

#### **Branch Types**

**🚀 Feature Branches** (`feature/`)
- **Purpose**: New features and enhancements
- **Source**: Created from `develop`
- **Target**: Merged back to `develop`
- **Lifespan**: Short-lived (1-2 weeks max)
- **Example**: `feature/SMILE-25-P6-ai-recommendations`

**🐛 Bugfix Branches** (`bugfix/`)
- **Purpose**: Non-critical bug fixes
- **Source**: Created from `develop`
- **Target**: Merged back to `develop`
- **Lifespan**: Short-lived (1-3 days)
- **Example**: `bugfix/SMILE-67-P5-frontend-profile-validation`

**🔥 Hotfix Branches** (`hotfix/`)
- **Purpose**: Critical production fixes
- **Source**: Created from `main`
- **Target**: Merged to both `main` and `develop`
- **Lifespan**: Very short-lived (hours to 1 day)
- **Example**: `hotfix/SMILE-99-security-vulnerability`

**📋 Epic Branches** (`epic/`)
- **Purpose**: Large features spanning multiple stories (4+ weeks)
- **Source**: Created from `develop`
- **Target**: Merged back to `develop`
- **Lifespan**: Medium-lived (2-4 weeks)
- **Example**: `epic/SMILE-15-P3-development-setup`

**Enhanced Epic Branch Strategy** (for complex epics):
```
epic/SMILE-15-P3-development-setup
├── feature/SMILE-25-P3-devops-docker-environment
├── feature/SMILE-26-P3-devops-cicd-pipeline
├── feature/SMILE-27-P3-devops-code-quality-gates
└── feature/SMILE-28-P3-devops-team-collaboration-tools
```

**Epic Branch Benefits**:
- **Parallel Development**: Multiple developers work on epic stories simultaneously
- **Integration Testing**: Test epic features together before merging to develop
- **Release Coordination**: Deploy entire epic as cohesive unit
- **Rollback Safety**: Easy to revert entire epic if issues arise

**🧪 Experimental Branches** (`experiment/`)
- **Purpose**: Proof of concepts and experiments
- **Source**: Created from `develop`
- **Target**: May be merged or discarded
- **Lifespan**: Variable
- **Example**: `experiment/SMILE-200-P6-new-ai-model`

## 👥 **Team Workflow**

### **Daily Development Workflow**

#### **1. Starting New Work**
```bash
# 1. Ensure you're on develop and up-to-date
git checkout develop
git pull origin develop

# 2. Create feature branch with JIRA key and phase context
git checkout -b feature/SMILE-123-P4-backend-user-profile-api

# 3. Work on your feature
# Make commits with descriptive messages
git add .
git commit -m "SMILE-123 Add user profile API endpoint

- Implement ProfileController with CRUD operations
- Add input validation and error handling
- Include unit tests with 85% coverage
- Update API documentation"
```

#### **2. Committing Changes**
```bash
# Commit message format:
{JIRA-KEY} {Brief description}

{Detailed description}
- Specific change 1
- Specific change 2
- Tests added/updated

# Examples:
git commit -m "SMILE-123 Implement user authentication

- Add JWT token generation and validation
- Implement login/logout endpoints
- Add password hashing with bcrypt
- Include integration tests for auth flow"
```

#### **3. Creating Pull Request**
```bash
# 1. Push feature branch
git push origin feature/SMILE-123-P4-backend-user-profile-api

# 2. Create PR via GitHub CLI or web interface
gh pr create \
  --title "SMILE-123 [P4-Backend] Implement user profile API" \
  --body "Implements user profile management API as specified in Epic 4 (Phase 4: Backend Implementation).

## Changes
- Added ProfileController with CRUD operations
- Implemented input validation
- Added comprehensive unit tests
- Updated API documentation

## Phase Context
- **Phase**: P4 - Backend Implementation
- **Epic**: SMILE-18 (Phase 4: Backend Implementation)
- **Component**: Backend API

## Testing
- All unit tests pass
- Integration tests included
- Manual testing completed

Closes SMILE-123" \
  --base develop \
  --head feature/SMILE-123-P4-backend-user-profile-api
```

### **Code Review Process**

#### **Review Requirements**
- **Feature Branches**: 1+ approval from team member
- **Epic Branches**: 1+ approval from tech lead
- **Hotfix Branches**: 1+ approval from senior developer
- **Main Branch**: 2+ approvals from CODEOWNERS

#### **Review Checklist**
- [ ] Code follows project coding standards
- [ ] JIRA ticket requirements are met
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No security vulnerabilities introduced
- [ ] Performance impact considered
- [ ] Breaking changes documented

### **Merge Strategy**

#### **Merge Types by Branch**
- **Feature → Develop**: Squash and merge (clean history)
- **Epic → Develop**: Merge commit (preserve epic history)
- **Develop → Staging**: Merge commit
- **Staging → Main**: Merge commit
- **Hotfix → Main**: Squash and merge

#### **Automated Merge Requirements**
```yaml
Branch Protection Rules:
  develop:
    - Require pull request reviews: 1
    - Require status checks: true
    - Require up-to-date branches: true
    - Include administrators: false
    
  main:
    - Require pull request reviews: 2
    - Require status checks: true
    - Require up-to-date branches: true
    - Include administrators: true
    - Restrict pushes: true
```

## 🚀 **Release Workflow**

### **Regular Release Process**

#### **1. Prepare Release**
```bash
# 1. Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# 2. Update version numbers and changelog
# 3. Final testing and bug fixes
# 4. Create PR to staging for UAT
```

#### **2. User Acceptance Testing**
```bash
# 1. Merge release branch to staging
git checkout staging
git merge release/v1.2.0
git push origin staging

# 2. Deploy to staging environment (automated)
# 3. Conduct UAT and fix any issues
# 4. Update release branch with fixes
```

#### **3. Production Deployment**
```bash
# 1. Merge to main after UAT approval
git checkout main
git merge release/v1.2.0
git tag v1.2.0
git push origin main --tags

# 2. Merge back to develop
git checkout develop
git merge release/v1.2.0
git push origin develop

# 3. Delete release branch
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

### **Epic Branch Workflow**
```bash
# 1. Create epic branch for large features
git checkout develop
git pull origin develop
git checkout -b epic/SMILE-15-P3-development-setup

# 2. Create feature branches from epic branch
git checkout epic/SMILE-15-P3-development-setup
git checkout -b feature/SMILE-25-P3-devops-docker-environment

# 3. Merge feature branches back to epic branch
git checkout epic/SMILE-15-P3-development-setup
git merge feature/SMILE-25-P3-devops-docker-environment

# 4. Test epic integration before merging to develop
# Run integration tests on epic branch

# 5. Merge complete epic to develop
git checkout develop
git merge epic/SMILE-15-P3-development-setup
git push origin develop

# 6. Clean up epic and feature branches
git branch -d epic/SMILE-15-P3-development-setup
git branch -d feature/SMILE-25-P3-devops-docker-environment
```

### **Hotfix Process**
```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/SMILE-999-critical-fix

# 2. Implement fix and test
# 3. Create PR to main (expedited review)
# 4. After merge, cherry-pick to develop
git checkout develop
git cherry-pick <hotfix-commit-hash>
git push origin develop
```

## 🔧 **Branch Protection Configuration**

### **GitHub Branch Protection Settings**

#### **Main Branch Protection**
```yaml
main:
  required_status_checks:
    strict: true
    contexts:
      - "ci/backend-tests"
      - "ci/frontend-tests"
      - "ci/integration-tests"
      - "ci/security-scan"
  enforce_admins: true
  required_pull_request_reviews:
    required_approving_review_count: 2
    dismiss_stale_reviews: true
    require_code_owner_reviews: true
  restrictions:
    users: []
    teams: ["tech-leads", "senior-developers"]
```

#### **Develop Branch Protection**
```yaml
develop:
  required_status_checks:
    strict: true
    contexts:
      - "ci/backend-tests"
      - "ci/frontend-tests"
      - "ci/lint-check"
  enforce_admins: false
  required_pull_request_reviews:
    required_approving_review_count: 1
    dismiss_stale_reviews: true
```

## 📊 **Team Guidelines**

### **Best Practices**

#### **Branch Management**
- Keep feature branches small and focused
- Delete merged branches promptly
- Regularly sync with develop branch
- Use descriptive branch names with JIRA keys

#### **Commit Guidelines**
- Make atomic commits (one logical change per commit)
- Write clear, descriptive commit messages
- Include JIRA key in commit messages
- Test before committing

#### **Collaboration**
- Communicate about long-running branches
- Coordinate on shared components
- Review PRs promptly (within 24 hours)
- Ask questions and provide constructive feedback

### **Troubleshooting Common Issues**

#### **Merge Conflicts**
```bash
# 1. Update your branch with latest develop
git checkout feature/SMILE-123-my-feature
git fetch origin
git merge origin/develop

# 2. Resolve conflicts in IDE
# 3. Test after resolution
# 4. Commit resolution
git add .
git commit -m "SMILE-123 Resolve merge conflicts with develop"
```

#### **Branch Cleanup**
```bash
# List merged branches
git branch --merged develop

# Delete local merged branches
git branch -d feature/SMILE-123-completed-feature

# Delete remote merged branches
git push origin --delete feature/SMILE-123-completed-feature
```

## 🎯 **Success Metrics**

### **Team Productivity Indicators**
- Average PR review time < 24 hours
- Merge conflicts < 5% of PRs
- Hotfix frequency < 1 per week
- Feature branch lifespan < 2 weeks
- CI/CD pipeline success rate > 95%

---

*This branching strategy ensures smooth collaboration, quality code delivery, and efficient team productivity for the SmileFactory platform development.*
