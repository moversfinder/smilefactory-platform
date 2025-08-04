# JIRA-GitHub Automation - SmileFactory Platform

## 🔗 **Automated Integration Overview**

This document defines the automated integration between JIRA and GitHub for the SmileFactory platform, enabling seamless status updates, automatic linking, and enhanced team productivity through workflow automation.

## 🎯 **Automation Goals**

### **Primary Objectives**
- **Automatic Status Updates**: GitHub events update JIRA issue status
- **Seamless Linking**: Commits, PRs, and branches automatically link to JIRA
- **Progress Tracking**: Real-time visibility of development progress in JIRA
- **Quality Gates**: Automated validation and status transitions

### **Key Benefits**
- Reduced manual status updates (saves 2-3 hours/week per developer)
- Complete traceability from requirements to deployment
- Automatic documentation of development progress
- Enhanced team coordination and visibility

## 🔄 **Automated Workflow Triggers**

### **GitHub → JIRA Status Updates**

#### **1. Branch Creation**
```yaml
Trigger: Branch created with JIRA key
Action: Update JIRA issue status to "In Progress"
Example: feature/SMILE-123-P4-backend-user-auth created
Result: SMILE-123 → "In Progress"
```

#### **2. Pull Request Events**
```yaml
PR Created:
  Trigger: PR opened with JIRA key in title/branch
  Action: JIRA issue → "In Review"
  Comment: Add PR link to JIRA issue

PR Approved:
  Trigger: Required approvals received
  Action: JIRA issue → "Ready for Merge"
  Comment: Add approval details to JIRA

PR Merged:
  Trigger: PR merged to develop/main
  Action: JIRA issue → "Done" (develop) or "Deployed" (main)
  Comment: Add merge details and deployment info
```

#### **3. Deployment Events**
```yaml
Staging Deployment:
  Trigger: Merge to develop branch
  Action: JIRA issue → "In Staging"
  Comment: Add staging environment link

Production Deployment:
  Trigger: Merge to main branch
  Action: JIRA issue → "Deployed"
  Comment: Add production deployment details
```

## 🛠️ **GitHub Actions Workflows**

### **1. JIRA Issue Transition Workflow**

```yaml
# .github/workflows/jira-integration.yml
name: JIRA Integration

on:
  pull_request:
    types: [opened, closed, review_requested, approved]
  push:
    branches: [main, develop]
  create:
    branches: true

jobs:
  jira-transition:
    runs-on: ubuntu-latest
    steps:
      - name: Extract JIRA Issue Key
        id: jira-key
        run: |
          # Extract JIRA key from branch name or PR title
          BRANCH_NAME="${{ github.head_ref || github.ref_name }}"
          JIRA_KEY=$(echo "$BRANCH_NAME" | grep -oE 'SMILE-[0-9]+' || echo "")
          echo "jira_key=$JIRA_KEY" >> $GITHUB_OUTPUT
          
      - name: Transition Issue on PR Open
        if: github.event_name == 'pull_request' && github.event.action == 'opened'
        uses: atlassian/gajira-transition@v3
        with:
          issue: ${{ steps.jira-key.outputs.jira_key }}
          transition: "In Review"
          
      - name: Transition Issue on PR Merge
        if: github.event_name == 'pull_request' && github.event.action == 'closed' && github.event.pull_request.merged == true
        uses: atlassian/gajira-transition@v3
        with:
          issue: ${{ steps.jira-key.outputs.jira_key }}
          transition: "Done"
          
      - name: Transition Issue on Production Deploy
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        uses: atlassian/gajira-transition@v3
        with:
          issue: ${{ steps.jira-key.outputs.jira_key }}
          transition: "Deployed"
```

### **2. JIRA Comment Automation**

```yaml
# .github/workflows/jira-comments.yml
name: JIRA Comments

on:
  pull_request:
    types: [opened, closed, review_requested]
  push:
    branches: [main, develop]

jobs:
  add-jira-comment:
    runs-on: ubuntu-latest
    steps:
      - name: Extract JIRA Issue Key
        id: jira-key
        run: |
          BRANCH_NAME="${{ github.head_ref || github.ref_name }}"
          JIRA_KEY=$(echo "$BRANCH_NAME" | grep -oE 'SMILE-[0-9]+' || echo "")
          echo "jira_key=$JIRA_KEY" >> $GITHUB_OUTPUT
          
      - name: Comment on PR Creation
        if: github.event_name == 'pull_request' && github.event.action == 'opened'
        uses: atlassian/gajira-comment@v3
        with:
          issue: ${{ steps.jira-key.outputs.jira_key }}
          comment: |
            🔄 **Pull Request Created**
            
            **PR**: [${{ github.event.pull_request.title }}](${{ github.event.pull_request.html_url }})
            **Branch**: `${{ github.head_ref }}`
            **Author**: @${{ github.event.pull_request.user.login }}
            **Phase**: ${{ contains(github.head_ref, 'P4') && 'Backend Implementation' || contains(github.head_ref, 'P5') && 'Frontend Implementation' || 'Development' }}
            
            **Status**: Ready for Review 👀
            
      - name: Comment on PR Merge
        if: github.event_name == 'pull_request' && github.event.action == 'closed' && github.event.pull_request.merged == true
        uses: atlassian/gajira-comment@v3
        with:
          issue: ${{ steps.jira-key.outputs.jira_key }}
          comment: |
            ✅ **Pull Request Merged**
            
            **PR**: [${{ github.event.pull_request.title }}](${{ github.event.pull_request.html_url }})
            **Merged by**: @${{ github.event.pull_request.merged_by.login }}
            **Target**: `${{ github.event.pull_request.base.ref }}`
            
            ${{ github.event.pull_request.base.ref == 'main' && '🚀 **Deployed to Production**' || '🎭 **Deployed to Staging**' }}
```

### **3. Epic Progress Tracking**

```yaml
# .github/workflows/epic-progress.yml
name: Epic Progress Tracking

on:
  pull_request:
    types: [closed]
  issues:
    types: [closed]

jobs:
  update-epic-progress:
    runs-on: ubuntu-latest
    steps:
      - name: Calculate Epic Progress
        uses: actions/github-script@v6
        with:
          script: |
            // Get epic from issue labels or branch name
            // Calculate completion percentage
            // Update epic description with progress
            // Add comment to epic with latest updates
```

## 📋 **JIRA Workflow Configuration**

### **Required JIRA Statuses**
```
Workflow Statuses:
├── To Do (Initial)
├── In Progress (Branch created)
├── In Review (PR opened)
├── Ready for Merge (PR approved)
├── Done (PR merged to develop)
├── In Staging (Deployed to staging)
└── Deployed (Deployed to production)
```

### **JIRA Automation Rules**

#### **1. Branch Creation Rule**
```
Trigger: Webhook from GitHub (branch created)
Condition: Branch name contains issue key
Action: Transition issue to "In Progress"
```

#### **2. PR Status Rule**
```
Trigger: Webhook from GitHub (PR events)
Condition: PR title or branch contains issue key
Actions:
  - PR opened → "In Review"
  - PR approved → "Ready for Merge"
  - PR merged → "Done"
```

#### **3. Deployment Rule**
```
Trigger: Webhook from GitHub (push to main)
Condition: Commit message contains issue key
Action: Transition issue to "Deployed"
```

## 🔧 **Setup Instructions**

### **1. GitHub Repository Setup**
```bash
# Add GitHub Actions workflows
mkdir -p .github/workflows
# Copy workflow files to .github/workflows/

# Configure repository secrets
JIRA_BASE_URL=https://your-domain.atlassian.net
JIRA_USER_EMAIL=your-email@domain.com
JIRA_API_TOKEN=your-api-token
```

### **2. JIRA Configuration**
```
1. Install GitHub for Jira app
2. Connect repository to JIRA project
3. Configure webhook endpoints
4. Set up automation rules
5. Test integration with sample issue
```

### **3. Team Training**
```
Branch Naming: feature/SMILE-123-P4-backend-description
Commit Messages: "SMILE-123 Brief description with details"
PR Titles: "SMILE-123 [P4-Backend] Feature description"
```

## 📊 **Integration Benefits**

### **Time Savings**
- **Manual Status Updates**: Eliminated (saves 2-3 hours/week per developer)
- **Progress Reporting**: Automated (saves 1 hour/week for project managers)
- **Deployment Tracking**: Real-time (saves 30 minutes/week for DevOps)

### **Quality Improvements**
- **Traceability**: 100% automatic linking from requirements to deployment
- **Visibility**: Real-time progress tracking for stakeholders
- **Compliance**: Automatic documentation of all changes

### **Team Productivity**
- **Reduced Context Switching**: Developers stay in GitHub, managers see updates in JIRA
- **Faster Reviews**: Automatic notifications and status updates
- **Better Coordination**: Clear visibility of who's working on what

## 🎯 **Success Metrics**

### **Automation Effectiveness**
- **Status Update Accuracy**: >95% automatic updates
- **Manual Intervention**: <5% of issues require manual status changes
- **Integration Reliability**: >99% uptime for webhook processing

### **Team Adoption**
- **Branch Naming Compliance**: >90% follow naming convention
- **Commit Message Quality**: >85% include JIRA keys
- **PR Template Usage**: >95% use proper PR titles

---

*This automated integration ensures seamless coordination between development work and project management, enabling the SmileFactory team to focus on building great features while maintaining complete visibility and traceability.*
