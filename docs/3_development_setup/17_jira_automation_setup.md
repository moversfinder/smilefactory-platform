# JIRA Automation Setup Guide

## 🎯 **Overview**

This guide explains how to set up automatic JIRA ticket creation and management when Pull Requests are created in GitHub. The automation will:

- **Automatically create JIRA tickets** when PRs are opened (if ticket doesn't exist)
- **Update JIRA ticket status** based on PR events (opened, merged, closed)
- **Add comments to JIRA** with PR links and status updates
- **Track code review progress** in JIRA

## 🔧 **Prerequisites**

### **1. JIRA Setup Requirements**
- JIRA project with key `SMILE` (or update workflow files to match your project key)
- JIRA user account with permissions to create and update tickets
- JIRA API token for authentication

### **2. GitHub Repository Access**
- Admin access to the GitHub repository
- Ability to configure repository secrets

## 📋 **Step-by-Step Setup**

### **Step 1: Create JIRA API Token**

1. **Log into JIRA** with your account
2. **Go to Account Settings** → Profile → Personal Access Tokens
3. **Create new token** with these permissions:
   - Read and write issues
   - Add comments to issues
   - Transition issues
4. **Copy the token** (you'll need it for GitHub secrets)

### **Step 2: Configure GitHub Repository Secrets**

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these **Repository Secrets**:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `JIRA_BASE_URL` | Your JIRA instance URL | `https://yourcompany.atlassian.net` |
| `JIRA_EMAIL` | Email of JIRA user account | `your-email@company.com` |
| `JIRA_API_TOKEN` | JIRA API token from Step 1 | `ATATT3xFfGF0T...` |

### **Step 3: Verify JIRA Project Configuration**

Ensure your JIRA project has:

**Issue Types:**
- Story (for frontend/backend features)
- Task (for general work)
- Bug (for bug fixes)

**Workflow Transitions:**
- Transition ID `31` for "In Review" status
- Transition ID `41` for "Done" status

*Note: If your JIRA uses different transition IDs, update the workflow file accordingly.*

### **Step 4: Test the Automation**

1. **Create a test branch** following naming convention:
   ```bash
   git checkout -b feature/SMILE-999-P5-frontend-test-automation
   ```

2. **Create a Pull Request** with title:
   ```
   SMILE-999: Test JIRA automation integration
   ```

3. **Check JIRA** to verify:
   - New ticket `SMILE-999` was created (if it didn't exist)
   - Ticket status changed to "In Review"
   - Comment added with PR link

## 🔄 **How the Automation Works**

### **PR Opened Event**
```
GitHub PR Created → Extract JIRA key from title → Check if ticket exists
                 ↓
If ticket doesn't exist → Create new JIRA ticket with PR details
                 ↓
Update ticket status to "In Review" → Add comment with PR link
```

### **PR Review Events**
```
PR Approved → Add approval comment to JIRA ticket
PR Changes Requested → Add changes requested comment to JIRA ticket
```

### **PR Merged/Closed Events**
```
PR Merged → Transition JIRA ticket to "Done" → Add merge success comment
PR Closed (not merged) → Add closure comment to JIRA ticket
```

## 📝 **JIRA Ticket Auto-Creation Details**

When a PR is created with a JIRA key that doesn't exist, the automation creates:

**Ticket Fields:**
- **Project**: SMILE
- **Summary**: PR title
- **Description**: Auto-generated with PR link and author
- **Issue Type**: Story (for frontend/backend) or Task (for general)
- **Status**: Automatically transitioned to "In Review"

**Example Auto-Created Ticket:**
```
Summary: SMILE-123: Implement user authentication system
Description: 
  Auto-created from GitHub Pull Request: https://github.com/repo/pull/45
  Created by: developer-username
  Branch: feature/SMILE-123-P4-backend-auth-system
```

## 🎯 **Developer Workflow Integration**

### **For Frontend Developers**
```bash
# 1. Create branch with JIRA key
git checkout -b feature/SMILE-456-P5-frontend-user-dashboard

# 2. Create PR with proper title
Title: "SMILE-456: Implement user dashboard components"

# 3. Automation handles:
#    - Creates JIRA ticket if needed
#    - Updates status to "In Review"
#    - Links PR to JIRA ticket
```

### **For Backend Developers**
```bash
# 1. Create branch with JIRA key
git checkout -b feature/SMILE-789-P4-backend-api-endpoints

# 2. Create PR with proper title
Title: "SMILE-789: Add community API endpoints"

# 3. Automation handles:
#    - Creates JIRA ticket if needed
#    - Updates status to "In Review"
#    - Links PR to JIRA ticket
```

## 🔍 **Troubleshooting**

### **Common Issues**

**1. "JIRA ticket creation failed"**
- Check JIRA_API_TOKEN is valid and not expired
- Verify JIRA_EMAIL has permissions to create tickets
- Ensure JIRA project key "SMILE" exists

**2. "Transition failed"**
- Check if transition IDs (31, 41) match your JIRA workflow
- Verify user has permission to transition tickets
- Update workflow file with correct transition IDs if needed

**3. "No JIRA key found in PR title"**
- Ensure PR title starts with "SMILE-XXX:" format
- Check branch name follows convention: `feature/SMILE-XXX-component-description`

### **Debugging Steps**

1. **Check GitHub Actions logs** in the repository's Actions tab
2. **Verify secrets are set** in repository settings
3. **Test JIRA API manually** using curl with your credentials
4. **Check JIRA permissions** for the user account

## 📊 **Benefits of This Automation**

### **For Project Managers**
- **Complete Traceability**: Every PR automatically linked to JIRA
- **Real-time Status Updates**: JIRA reflects actual development progress
- **Reduced Manual Work**: No need to manually create/update tickets

### **For Developers**
- **Seamless Workflow**: Focus on coding, automation handles tracking
- **Consistent Documentation**: All work automatically documented
- **Clear Progress Visibility**: Team can see what's in review/done

### **For Code Reviews**
- **Automatic JIRA Updates**: Review status reflected in project management
- **Centralized Information**: All PR and review info in one place
- **Historical Tracking**: Complete audit trail of changes

## 🚀 **Next Steps**

After setup is complete:

1. **Train your team** on the new automated workflow
2. **Update your team documentation** to reflect the automation
3. **Monitor the automation** for the first few PRs to ensure it works correctly
4. **Customize transition IDs** if your JIRA workflow differs
5. **Consider adding more automation** like automatic assignee setting

---

**This automation saves approximately 15-20 minutes per PR in manual JIRA management while ensuring complete traceability between development work and project tracking.** 🎉
