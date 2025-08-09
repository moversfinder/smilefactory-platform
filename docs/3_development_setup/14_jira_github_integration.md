# JIRA-GitHub Integration & Automation

## 🎯 **Overview**
This comprehensive guide covers the setup, configuration, and automated workflows for JIRA-GitHub integration on the SmileFactory platform, enabling seamless tracking between development work and project management with automated status updates.

## 🔗 **Integration Setup**

### **1. JIRA Configuration**
**Required JIRA Apps**:
- GitHub for Jira (by Atlassian)
- Smart Commits for Jira

**JIRA Project Configuration**:
- **Project Key**: `SMILE`
- **Issue Types**: Epic, Story, Task, Bug, Spike
- **Workflows**: Aligned with development phases
- **Custom Fields**: GitHub PR links, Component (Frontend/Backend)

### **2. GitHub Repository Settings**
**Required Settings**:
- JIRA integration enabled in repository settings
- Smart commit format configured
- Branch protection rules with JIRA ticket requirements

## 📋 **Ticket Naming Conventions**

### **Epic Naming**: `[Phase] - [Epic Name]`
```
Examples:
✅ P3 - Development Setup & Team Collaboration
✅ P4 - Backend Implementation  
✅ P5 - Frontend Implementation
✅ P6 - Integration & Testing
```

### **Story Naming**: `[Phase]-[Epic Code]-[Feature Area]-[Number]`
```
Examples:
✅ P4-BACKEND-AUTH-001: JWT authentication system
✅ P5-FRONTEND-DASH-002: User dashboard implementation
✅ P4-BACKEND-API-003: Community hub API endpoints
✅ P5-FRONTEND-COMP-004: Profile management components
```

### **Task Naming**: `[Story Code]-[Category]-[Number]`
```
Examples:
✅ P4-BACKEND-AUTH-001-BE-001: JWT token generation service
✅ P5-FRONTEND-DASH-002-FE-001: Dashboard layout component
✅ P4-BACKEND-API-003-TEST-001: API endpoint unit tests
```

## 🌳 **Branch Naming Strategy**

### **Branch Format**: `feature/SMILE-XXX-P[4|5]-[component]-[description]`
```
Examples:
✅ feature/SMILE-45-P5-frontend-user-dashboard
✅ feature/SMILE-67-P4-backend-auth-api
✅ feature/SMILE-89-P5-frontend-profile-components
✅ feature/SMILE-123-P4-backend-community-endpoints
```

### **Branch Types**:
- **`feature/`** - New feature development
- **`bugfix/`** - Bug fixes
- **`hotfix/`** - Emergency production fixes
- **`spike/`** - Research and investigation

## 💬 **Smart Commit Format**

### **Commit Message Structure**:
```
SMILE-XXX: Brief description of changes

Optional longer description explaining what was done and why.

- Specific change 1
- Specific change 2
- Specific change 3
```

### **Smart Commit Commands**:
```bash
# Transition ticket to In Progress
git commit -m "SMILE-123: Start implementing user authentication #in-progress"

# Log work time
git commit -m "SMILE-123: Complete JWT token validation #time 4h"

# Transition to Done
git commit -m "SMILE-123: Finish authentication implementation #done"

# Add comment
git commit -m "SMILE-123: Fix validation logic #comment Updated validation to handle edge cases"
```

## 🔄 **Development Workflow Integration**

### **1. Starting Work**
```bash
# 1. Create branch from JIRA ticket
git checkout develop
git pull origin develop
git checkout -b feature/SMILE-123-P4-backend-auth-api

# 2. Transition JIRA ticket
# Commit with smart command to move ticket to "In Progress"
git commit --allow-empty -m "SMILE-123: Start authentication API development #in-progress"
git push origin feature/SMILE-123-P4-backend-auth-api
```

### **2. During Development**
```bash
# Regular commits with JIRA ticket reference
git commit -m "SMILE-123: Add JWT token generation service"
git commit -m "SMILE-123: Implement token validation middleware"
git commit -m "SMILE-123: Add authentication unit tests #time 2h"
```

### **3. Creating Pull Request**
**PR Title Format**: `SMILE-XXX [P4-Backend|P5-Frontend] Brief description`
```
Examples:
✅ SMILE-123 [P4-Backend] Implement JWT authentication system
✅ SMILE-456 [P5-Frontend] Add user dashboard components
✅ SMILE-789 [P4-Backend] Create community API endpoints
```

**PR Description Template**:
```markdown
## 🎯 JIRA Ticket
- **Story**: SMILE-XXX
- **Link**: [SMILE-XXX](https://your-jira.atlassian.net/browse/SMILE-XXX)

## 📋 Changes Made
- Change 1
- Change 2
- Change 3

## ✅ Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## 📸 Screenshots (if applicable)
[Add screenshots for UI changes]
```

### **4. Code Review and Merge**
```bash
# After PR approval and merge, JIRA ticket automatically transitions
# Smart commit in merge commit:
git commit -m "SMILE-123: Merge authentication implementation #done #time 8h"
```

## 📊 **Progress Tracking**

### **JIRA Dashboard Widgets**
- **Sprint Progress**: Track story completion
- **Burndown Chart**: Monitor sprint velocity
- **Component Progress**: Frontend vs Backend progress
- **Bug Tracking**: Open bugs by priority
- **Code Review Status**: PRs pending review

### **GitHub Integration Views**
- **Development Panel**: Shows linked PRs and branches
- **Deployment Status**: CI/CD pipeline status
- **Code Review**: PR status and reviewers

## 🎯 **Team Collaboration Best Practices**

### **Daily Standup Integration**
- Update JIRA tickets before standup
- Reference GitHub PRs in status updates
- Use JIRA board for visual progress tracking

### **Sprint Planning**
- Create GitHub milestones for sprints
- Link JIRA epics to GitHub milestones
- Use story points for estimation

### **Code Review Process**
- Require JIRA ticket link in PR description
- Use GitHub review assignments
- Update JIRA with review feedback

## 🔧 **Automation Rules**

### **JIRA Automation**
- Auto-transition tickets when PR is created
- Auto-assign reviewers based on component
- Auto-update story points when tasks complete

### **GitHub Actions Integration**
- Auto-comment on JIRA when CI passes/fails
- Auto-transition tickets when PR is merged
- Auto-create release notes from JIRA tickets

## 📈 **Metrics and Reporting**

### **Key Metrics to Track**
- **Velocity**: Story points completed per sprint
- **Lead Time**: JIRA ticket creation to deployment
- **Code Review Time**: PR creation to merge
- **Bug Rate**: Bugs per feature delivered

### **Weekly Reports**
- Sprint progress dashboard
- Code review metrics
- Bug resolution time
- Team velocity trends

---

## 🚀 **Getting Started Checklist**

### **For Team Members**
- [ ] Access to JIRA project (SMILE)
- [ ] GitHub repository access
- [ ] JIRA-GitHub integration configured
- [ ] Branch naming convention understood
- [ ] Smart commit format learned
- [ ] PR template bookmarked

### **For Project Manager**
- [ ] JIRA project configured with proper workflows
- [ ] GitHub integration enabled
- [ ] Team permissions set up
- [ ] Automation rules configured
- [ ] Dashboard widgets created
- [ ] Reporting schedule established

## 🔄 **Automated Workflow Integration**

### **Automation Goals**
- **Automatic Status Updates**: GitHub events update JIRA issue status
- **Seamless Linking**: Commits, PRs, and branches automatically link to JIRA
- **Progress Tracking**: Real-time visibility of development progress in JIRA
- **Quality Gates**: Automated validation and status transitions

### **Key Benefits**
- Reduced manual status updates (saves 2-3 hours/week per developer)
- Complete traceability from requirements to deployment
- Automatic documentation of development progress
- Enhanced team coordination and visibility

### **GitHub → JIRA Status Updates**

#### **Branch Creation**
- **Trigger**: Branch created with JIRA key
- **Action**: Update JIRA issue status to "In Progress"
- **Example**: `feature/SMILE-123-user-auth` created → SMILE-123 → "In Progress"

#### **Pull Request Events**
- **PR Created**: JIRA issue → "In Review" + PR link added to JIRA
- **PR Approved**: JIRA issue → "Ready for Merge" + approval details
- **PR Merged**: JIRA issue → "Done" (develop) or "Deployed" (main)

#### **Deployment Events**
- **Staging Deployment**: Merge to develop → JIRA issue → "In Staging"
- **Production Deployment**: Merge to main → JIRA issue → "Deployed"

### **Automated Quality Gates**
- **Branch Naming Validation**: Ensures JIRA key is present
- **PR Title Validation**: Validates JIRA ticket reference
- **Status Synchronization**: Keeps JIRA and GitHub in sync
- **Deployment Tracking**: Automatic deployment status updates

**This comprehensive integration ensures seamless collaboration between development work and project management, providing full traceability from requirements to deployment with automated workflow management.** 🎉
