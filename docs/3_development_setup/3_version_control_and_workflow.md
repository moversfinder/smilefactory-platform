# 3. Version Control and Workflow

## 🔄 **GitHub-Based Version Control Strategy**

The SmileFactory platform uses GitHub with an Enhanced GitHub Flow branching strategy designed for team collaboration, continuous integration, and reliable releases. This document outlines the complete GitHub-based version control workflow and best practices optimized for React + Java Spring Boot development.

**📋 For Complete Branching Strategy**: See `9_git_branching_strategy.md` for the comprehensive team branching strategy including branch protection rules, merge workflows, and team guidelines.

## 🌳 **Branching Strategy**

### **GitHub Flow for React + Java Spring Boot**
**Branch Structure**:
- **main**: Production-ready code, always deployable
- **feature/frontend/**: Frontend-specific features and UI components
- **feature/backend/**: Backend API and business logic features
- **feature/fullstack/**: Features requiring both frontend and backend changes
- **feature/infrastructure/**: DevOps, deployment, and infrastructure changes
- **hotfix/**: Critical production fixes requiring immediate deployment
- **experimental/**: Research and experimental features for evaluation

**GitHub Flow Principles**:
- **Single main branch**: `main` is always deployable
- **Feature branches**: Short-lived branches for specific features
- **Pull Requests**: All changes go through PR review process
- **Continuous Deployment**: Automatic deployment from main branch
- **GitHub Integration**: Leverages GitHub's native features

### **Component-Specific Branching Strategy**

#### **Frontend Branches (React)**
**Naming Convention**: `feature/frontend/JIRA-{number}-{description}`
**Purpose**: React component development, UI/UX changes, frontend logic
**Base Branch**: `develop`
**Merge Requirements**:
- Frontend tests pass
- UI/UX review completed
- Accessibility compliance verified
- Performance benchmarks met

#### **Backend Branches (Java Spring Boot)**
**Naming Convention**: `feature/backend/JIRA-{number}-{description}`
**Purpose**: API development, business logic, database changes
**Base Branch**: `develop`
**Merge Requirements**:
- Unit tests pass (>80% coverage)
- Integration tests pass
- API documentation updated
- Security scan completed

#### **Full-Stack Branches**
**Naming Convention**: `feature/fullstack/JIRA-{number}-{description}`
**Purpose**: Features requiring both frontend and backend changes
**Base Branch**: `develop`
**Merge Requirements**:
- Both frontend and backend tests pass
- End-to-end tests pass
- API contract tests pass
- Performance impact assessed

#### **Infrastructure Branches**
**Naming Convention**: `feature/infrastructure/JIRA-{number}-{description}`
**Purpose**: DevOps, CI/CD, deployment, configuration changes
**Base Branch**: `develop`
**Merge Requirements**:
- Infrastructure tests pass
- Security compliance verified
- Deployment scripts tested
- Rollback procedures documented

### **GitHub Flow Branch Strategy**

#### **Main Branch**
**`main`** (Production Branch):
- Contains production-ready code
- Protected branch with strict merge requirements
- Automatic deployment to production environment
- Tagged with version numbers for releases
- All feature branches created from and merged back to main

#### **Feature Branches**
**`feature/*`** (Feature Branches):
- Naming: `feature/{component}/JIRA-{ticket-number}-{brief-description}`
- Created from: `main`
- Merged back to: `main` via Pull Request
- Lifetime: Until feature is complete and merged
- Components: `frontend`, `backend`, `fullstack`, `infrastructure`

**`hotfix/*`** (Hotfix Branches):
- Naming: `hotfix/JIRA-{ticket-number}-{brief-description}`
- Created from: `main`
- Merged to: `main` via Pull Request
- Purpose: Critical production fixes
- Immediate deployment after merge

**`experimental/*`** (Experimental Branches):
- Naming: `experimental/JIRA-{ticket-number}-{brief-description}`
- Created from: `main`
- Used for proof-of-concepts and research
- May be discarded or converted to feature branches

## 📝 **Commit Standards**

### **Commit Message Format**
**Standard Structure**:
- **Header**: `type(scope): brief description`
- **Body**: Detailed explanation of changes and reasoning
- **Footer**: JIRA ticket reference and co-author information

**Required Elements**:
- **Type**: feat, fix, docs, style, refactor, test, chore
- **Scope**: Component or module affected (optional)
- **Description**: Brief summary of changes
- **JIRA Reference**: Link to project management ticket
- **Co-authorship**: Credit for pair programming or collaboration

### **Commit Types**
```typescript
interface CommitType {
  feat: 'New feature implementation';
  fix: 'Bug fix';
  docs: 'Documentation changes';
  style: 'Code style changes (formatting, etc.)';
  refactor: 'Code refactoring without functionality changes';
  test: 'Adding or updating tests';
  chore: 'Maintenance tasks, dependency updates';
  perf: 'Performance improvements';
  ci: 'CI/CD pipeline changes';
  build: 'Build system changes';
  revert: 'Reverting previous changes';
}
```

### **Commit Message Examples**
```bash
# Feature implementation
feat(auth): implement JWT-based authentication system

Add comprehensive JWT authentication with refresh tokens,
including login, logout, and token refresh endpoints.
Includes rate limiting and security measures.

JIRA: PROJ-123

# Bug fix
fix(dashboard): resolve profile completion calculation error

Fix calculation logic that was showing incorrect completion
percentages for users with partial profile data.

JIRA: PROJ-456

# Documentation update
docs(api): update authentication endpoint documentation

Add detailed examples and error response codes for all
authentication endpoints in the API documentation.

JIRA: PROJ-789
```

## 🔀 **Workflow Processes**

### **GitHub Flow Development Workflow with Official JIRA Integration**
```bash
# 1. Create feature branch from main with JIRA key
git checkout main
git pull origin main
git checkout -b PROJ-123-user-profile-creation

# Alternative: Component-specific naming
git checkout -b feature/frontend/PROJ-123-user-profile-creation

# 2. Develop feature with JIRA key in commit messages
git add .
git commit -m "PROJ-123 Add user profile creation form with validation"
git commit -m "PROJ-123 Add form validation and error handling"
git commit -m "PROJ-123 Add unit tests for profile creation"

# 3. Keep feature branch updated with main
git checkout main
git pull origin main
git checkout PROJ-123-user-profile-creation
git rebase main

# 4. Push feature branch
git push origin PROJ-123-user-profile-creation

# 5. Create Pull Request with JIRA key in title (REQUIRED for linking)
gh pr create --title "PROJ-123 Add user profile creation form" \
  --body "Implements user profile creation with validation and error handling" \
  --assignee @me \
  --label "frontend,enhancement"

# 6. Merge to main after approval and CI checks pass
# JIRA will automatically show development information
```

## 🔗 **Official JIRA-GitHub Integration**

### **Automatic Development Linking**
**Based on Atlassian Documentation**: All linking happens automatically when JIRA keys are included properly.

**What Gets Linked Automatically**:
- **Branches**: Include JIRA key in branch name → appears in JIRA development panel
- **Commits**: Include JIRA key in commit message → appears in JIRA development panel
- **Pull Requests**: Include JIRA key in PR title → appears in JIRA development panel
- **Builds**: GitHub Actions builds automatically link if commits contain JIRA keys
- **Deployments**: Deployment information links if commits contain JIRA keys

**JIRA Development Panel Shows**:
```yaml
development_information:
  branches: "Number of linked branches with details"
  commits: "Number of linked commits with messages"
  pull_requests: "Number of linked PRs with status"
  builds: "Build status from GitHub Actions"
  deployments: "Deployment information and status"
```

**Key Requirements for Automatic Linking**:
1. **JIRA Key Format**: Must be uppercase (e.g., "PROJ-123", not "proj-123")
2. **Branch Names**: Include JIRA key anywhere in branch name
3. **Commit Messages**: Include JIRA key anywhere in commit message
4. **PR Titles**: Include JIRA key in pull request title
5. **Repository Connection**: Admin must connect GitHub to JIRA

**Viewing Development Information**:
- **In JIRA**: Navigate to issue → Development panel shows linked activity
- **On Board**: Development icons appear on issue cards
- **In GitHub**: JIRA links appear in connected PRs and commits

### **Release Workflow**
```bash
# 1. Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# 2. Update version numbers and changelog
npm version 1.2.0
git add .
git commit -m "chore(release): bump version to 1.2.0"

# 3. Final testing and bug fixes
git commit -m "fix(release): resolve minor UI issues"

# 4. Merge to main and develop
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"

git checkout develop
git merge --no-ff release/v1.2.0

# 5. Delete release branch
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

### **Hotfix Workflow**
```bash
# 1. Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/JIRA-456-security-patch

# 2. Implement critical fix
git add .
git commit -m "fix(security): patch authentication vulnerability"

# 3. Merge to main and develop
git checkout main
git merge --no-ff hotfix/JIRA-456-security-patch
git tag -a v1.2.1 -m "Hotfix version 1.2.1"

git checkout develop
git merge --no-ff hotfix/JIRA-456-security-patch

# 4. Deploy immediately to production
```

## 🛡️ **GitHub Branch Protection Rules**

### **Main Branch Protection Configuration**
```yaml
# GitHub branch protection settings
main:
  required_status_checks:
    strict: true
    contexts:
      - "Frontend Tests"
      - "Backend Tests"
      - "Integration Tests"
      - "Security Scan"
      - "Code Quality Check"
  enforce_admins: true
  required_pull_request_reviews:
    required_approving_review_count: 2
    dismiss_stale_reviews: true
    require_code_owner_reviews: true
    require_last_push_approval: true
  restrictions:
    users: []
    teams: ["senior-developers", "tech-leads"]
  allow_force_pushes: false
  allow_deletions: false
  required_linear_history: true
```

### **CODEOWNERS Configuration**
```bash
# .github/CODEOWNERS
# Global owners
* @tech-lead @senior-developer

# Frontend specific
/frontend/ @frontend-team @ui-ux-team
*.vue @frontend-team
*.ts @frontend-team @backend-team
*.css @frontend-team @ui-ux-team

# Backend specific
/backend/ @backend-team @tech-lead
*.java @backend-team
*.sql @backend-team @dba-team

# Infrastructure
/.github/ @devops-team @tech-lead
/docker/ @devops-team
/k8s/ @devops-team
```

### **Develop Branch Protection**
```yaml
develop:
  required_status_checks:
    strict: true
    contexts:
      - "ci/backend-tests"
      - "ci/frontend-tests"
      - "ci/lint-check"
  required_pull_request_reviews:
    required_approving_review_count: 1
    dismiss_stale_reviews: true
```

## 🔍 **Code Review Process**

### **Pull Request Template**
```markdown
## Description
Brief description of changes made in this PR.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Performance impact assessed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Code is commented where necessary
- [ ] Documentation updated
- [ ] No new warnings introduced

## JIRA Ticket
PROJ-123

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Additional Notes
Any additional information for reviewers.
```

### **Code Review Guidelines**
**Review Criteria**:
- **Functionality**: Code works as intended and meets requirements
- **Code Quality**: Clean, readable, and maintainable code
- **Testing**: Adequate test coverage and quality
- **Performance**: No obvious performance issues
- **Security**: No security vulnerabilities
- **Documentation**: Proper documentation and comments

**Review Process**:
1. **Automated Checks**: All CI/CD checks must pass
2. **Peer Review**: At least one team member review required
3. **Senior Review**: Senior developer review for complex changes
4. **Approval**: All reviewers must approve before merge
5. **Merge**: Squash and merge to maintain clean history

## 🚀 **React + Java Spring Boot Specific Workflows**

### **Monorepo Structure Management**
```
zbinnovation-platform/
├── frontend/                 # React application
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── backend/                  # Java Spring Boot
│   ├── src/main/java/
│   ├── pom.xml
│   └── Dockerfile
├── shared/                   # Shared configurations
│   ├── api-contracts/
│   └── docker-compose.yml
└── infrastructure/           # DevOps configurations
    ├── bitbucket-pipelines.yml
    └── kubernetes/
```

### **Coordinated Development Workflow**

#### **API-First Development Process**
1. **API Contract Definition** (OpenAPI/Swagger)
   ```bash
   # Create API contract branch
   git checkout -b feature/api-contract/JIRA-123-user-profile
   # Define API contract in shared/api-contracts/
   # Generate client stubs for frontend
   # Generate server stubs for backend
   ```

2. **Parallel Development**
   ```bash
   # Frontend developer
   git checkout -b feature/frontend/JIRA-123-user-profile-ui
   # Backend developer
   git checkout -b feature/backend/JIRA-123-user-profile-api
   ```

3. **Integration Testing**
   ```bash
   # Create integration branch
   git checkout -b integration/JIRA-123-user-profile
   git merge feature/frontend/JIRA-123-user-profile-ui
   git merge feature/backend/JIRA-123-user-profile-api
   # Run end-to-end tests
   ```

#### **Database Migration Coordination**
**Migration Branch Strategy**:
```bash
# Database changes require special handling
git checkout -b feature/database/JIRA-123-user-profile-schema
# Create migration scripts
# Test migration on development environment
# Coordinate with backend API changes
```

**Migration Workflow**:
1. Create migration scripts in backend repository
2. Test migration on development database
3. Update backend models and repositories
4. Update API documentation
5. Coordinate frontend changes if needed

### **Component Testing Strategy**

#### **Frontend Testing Workflow**
```bash
# Feature branch testing
npm run test:unit          # Jest unit tests
npm run test:integration   # React Testing Library
npm run test:e2e          # Cypress end-to-end tests
npm run test:accessibility # Accessibility tests
npm run test:performance  # Lighthouse performance tests
```

#### **Backend Testing Workflow**
```bash
# Feature branch testing
mvn test                  # Unit tests
mvn verify               # Integration tests
mvn test -Dtest=ApiTest  # API contract tests
mvn spotbugs:check       # Security analysis
mvn jacoco:report        # Coverage report
```

#### **Cross-Component Testing**
```bash
# Full-stack integration testing
docker-compose up -d     # Start all services
npm run test:api-integration  # API integration tests
npm run test:e2e-full    # Full application E2E tests
docker-compose down      # Clean up
```

## 🤖 **Advanced Bitbucket Pipelines**

### **Multi-Component Pipeline Strategy**
```yaml
# bitbucket-pipelines.yml
image: atlassian/default-image:3

definitions:
  services:
    postgres:
      image: postgres:13
      variables:
        POSTGRES_DB: zbinnovation_test
        POSTGRES_USER: test
        POSTGRES_PASSWORD: test

pipelines:
  default:
    - parallel:
        - step:
            name: Frontend Build & Test
            image: node:18
            caches:
              - node
            script:
              - cd frontend
              - npm ci
              - npm run lint
              - npm run test:coverage
              - npm run build
            artifacts:
              - frontend/dist/**

        - step:
            name: Backend Build & Test
            image: maven:3.8.6-openjdk-17
            caches:
              - maven
            services:
              - postgres
            script:
              - cd backend
              - mvn clean compile
              - mvn test
              - mvn verify
              - mvn package
            artifacts:
              - backend/target/*.jar

    - step:
        name: Integration Tests
        script:
          - docker-compose -f docker-compose.test.yml up -d
          - npm run test:integration
          - docker-compose -f docker-compose.test.yml down
```
    branches: [ main, develop ]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Run backend tests
        run: ./mvnw test
      - name: Generate test report
        uses: dorny/test-reporter@v1
        if: success() || failure()
        with:
          name: Backend Tests
          path: target/surefire-reports/*.xml
          reporter: java-junit

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Run frontend tests
        run: npm run test:coverage
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
```

### **Pre-commit Hooks**
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-merge-conflict

  - repo: https://github.com/psf/black
    rev: 22.10.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/eslint/eslint
    rev: v8.28.0
    hooks:
      - id: eslint
        files: \.(js|ts|tsx)$
        types: [file]
```

## 📊 **Git Workflow Metrics**

### **Development Metrics**
- **Lead Time**: Time from feature start to production deployment
- **Cycle Time**: Time from first commit to merge
- **Deployment Frequency**: How often code is deployed to production
- **Change Failure Rate**: Percentage of deployments causing failures
- **Mean Time to Recovery**: Time to recover from failures

### **Code Quality Metrics**
- **Code Review Coverage**: Percentage of code changes reviewed
- **Review Turnaround Time**: Time from PR creation to approval
- **Defect Escape Rate**: Bugs found in production vs. development
- **Technical Debt**: Accumulated technical debt over time

## 🔧 **Git Configuration**

### **Global Git Configuration**
```bash
# User configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"

# Editor and merge tool
git config --global core.editor "code --wait"
git config --global merge.tool "vscode"

# Line ending configuration
git config --global core.autocrlf input  # Linux/Mac
git config --global core.autocrlf true   # Windows

# Push configuration
git config --global push.default simple
git config --global pull.rebase true

# Alias configuration
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
```

### **Repository-specific Configuration**
```bash
# .gitconfig (repository level)
[core]
    hooksPath = .githooks
    
[branch "main"]
    remote = origin
    merge = refs/heads/main
    
[branch "develop"]
    remote = origin
    merge = refs/heads/develop
```

## 📚 **Git Best Practices**

### **Commit Best Practices**
- **Atomic Commits**: Each commit should represent a single logical change
- **Descriptive Messages**: Clear, concise commit messages
- **Regular Commits**: Commit frequently to avoid large changesets
- **Clean History**: Use interactive rebase to clean up commit history

### **Branch Management**
- **Short-lived Branches**: Keep feature branches small and short-lived
- **Regular Updates**: Keep branches updated with latest develop changes
- **Clean Merges**: Use squash and merge for feature branches
- **Delete Merged Branches**: Clean up merged branches promptly

### **Collaboration Guidelines**
- **Communication**: Discuss significant changes with team
- **Documentation**: Update documentation with code changes
- **Testing**: Ensure all tests pass before pushing
- **Code Review**: Participate actively in code reviews

---

## 📚 **Reference Documents**

**Coding Standards**: See `/3_development_setup/2_coding_standards_and_guidelines.md`
**CI/CD Pipeline**: See `/3_development_setup/4_ci_cd_pipeline_configuration.md`
**Team Collaboration**: See `/3_development_setup/5_team_collaboration_tools.md`
**JIRA Integration**: See `/development-standards/JIRA_PROJECT_STRUCTURE.md`

*This version control workflow ensures efficient, reliable, and collaborative development for the ZbInnovation platform.*
