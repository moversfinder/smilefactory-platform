# Team Workflow Quick Reference

## 🚀 **Daily Workflow for Developers**

### **🌅 Starting Your Day**
```bash
# 1. Check JIRA for assigned tickets
# 2. Pull latest changes
git checkout develop
git pull origin develop

# 3. Create feature branch
git checkout -b feature/SMILE-XXX-P[4|5]-[component]-[description]

# 4. Start work and update JIRA
git commit --allow-empty -m "SMILE-XXX: Start [feature description] #in-progress"
git push origin feature/SMILE-XXX-P[4|5]-[component]-[description]
```

### **💻 During Development**
```bash
# Regular commits with JIRA reference
git add .
git commit -m "SMILE-XXX: [What you did]"

# Log time in JIRA (optional)
git commit -m "SMILE-XXX: [What you did] #time 2h"

# Push regularly
git push origin your-branch-name
```

### **🔄 Creating Pull Request**
1. **Push final changes**
2. **Go to GitHub** → Create Pull Request
3. **Use PR template** (auto-filled)
4. **Title format**: `SMILE-XXX [P4-Backend|P5-Frontend] Brief description`
5. **Request review** from team member
6. **Link JIRA ticket** in description

### **✅ Finishing Work**
```bash
# After PR is merged, JIRA ticket auto-transitions to Done
# Clean up local branch
git checkout develop
git pull origin develop
git branch -d feature/SMILE-XXX-P[4|5]-[component]-[description]
```

## 🎯 **Frontend Developer Workflow**

### **Your Focus Areas**
- **React Components**: UI components and layouts
- **TypeScript**: Type-safe development
- **State Management**: Redux for global state
- **API Integration**: Connecting to backend APIs
- **Testing**: Component and integration tests

### **Branch Naming for Frontend**
```bash
feature/SMILE-XXX-P5-frontend-[description]

Examples:
✅ feature/SMILE-45-P5-frontend-user-dashboard
✅ feature/SMILE-67-P5-frontend-profile-components
✅ feature/SMILE-89-P5-frontend-community-feed
```

### **Key Documentation**
- **Frontend Specs**: `docs/5_frontend_implementation/`
- **UI Guidelines**: `docs/5_frontend_implementation/8_frontend_specifications/UI_DESIGN_GUIDELINES.md`
- **Component Architecture**: `docs/5_frontend_implementation/8_frontend_specifications/component-architecture.md`
- **API Documentation**: `docs/2_technical_architecture/8_complete_api_documentation.md`

## 🔧 **Backend Developer Workflow**

### **Your Focus Areas**
- **Java Spring Boot**: REST API development
- **Database**: PostgreSQL schema and queries
- **Authentication**: JWT and security implementation
- **Business Logic**: Core platform functionality
- **Testing**: Unit and integration tests

### **Branch Naming for Backend**
```bash
feature/SMILE-XXX-P4-backend-[description]

Examples:
✅ feature/SMILE-123-P4-backend-auth-api
✅ feature/SMILE-456-P4-backend-user-management
✅ feature/SMILE-789-P4-backend-community-endpoints
```

### **Key Documentation**
- **Backend Specs**: `docs/4_backend_implementation/`
- **API Documentation**: `docs/2_technical_architecture/8_complete_api_documentation.md`
- **Database Schema**: `docs/2_technical_architecture/2_database_schema_and_design.md`
- **Security Design**: `docs/2_technical_architecture/4_security_and_authentication_design.md`

## 📋 **JIRA Ticket Workflow**

### **Ticket States**
- **📋 To Do** → Ready for development
- **🔄 In Progress** → Currently being worked on
- **👀 In Review** → Pull request created, under review
- **🧪 Testing** → In QA testing
- **✅ Done** → Completed and merged

### **Updating Tickets**
```bash
# Start work
git commit -m "SMILE-XXX: Start implementation #in-progress"

# Log time (optional)
git commit -m "SMILE-XXX: Complete feature #time 4h"

# Move to review (when PR created)
git commit -m "SMILE-XXX: Ready for review #in-review"

# Complete work (after merge)
git commit -m "SMILE-XXX: Implementation complete #done"
```

## 🔍 **Code Review Guidelines**

### **For Authors**
- [ ] Self-review your code before requesting review
- [ ] Ensure all tests pass
- [ ] Update documentation if needed
- [ ] Link JIRA ticket in PR description
- [ ] Add screenshots for UI changes

### **For Reviewers**
- [ ] Check code quality and standards
- [ ] Verify functionality works as expected
- [ ] Test the changes locally if possible
- [ ] Provide constructive feedback
- [ ] Approve when satisfied

### **Review Checklist**
- **Functionality**: Does it work as intended?
- **Code Quality**: Is it clean and maintainable?
- **Testing**: Are there adequate tests?
- **Documentation**: Is documentation updated?
- **Security**: Are there any security concerns?

## 🚨 **Common Issues and Solutions**

### **Merge Conflicts**
```bash
# Update your branch with latest develop
git checkout develop
git pull origin develop
git checkout your-branch
git merge develop

# Resolve conflicts in your IDE
# Then commit the merge
git add .
git commit -m "SMILE-XXX: Resolve merge conflicts"
git push origin your-branch
```

### **JIRA Ticket Not Linking**
- Ensure commit message starts with `SMILE-XXX:`
- Check JIRA ticket number is correct
- Verify GitHub-JIRA integration is working

### **PR Checks Failing**
- Check the error messages in GitHub Actions
- Fix any linting or test failures
- Push fixes to the same branch

## 📞 **Getting Help**

### **Technical Questions**
- **Frontend**: Ask frontend team lead or check frontend docs
- **Backend**: Ask backend team lead or check backend docs
- **General**: Create GitHub discussion or ask in team chat

### **Process Questions**
- **JIRA**: Check JIRA documentation or ask project manager
- **Git/GitHub**: Check this guide or ask team lead
- **Workflow**: Reference team onboarding guide

### **Escalation Path**
1. **Team Member** → Ask colleague
2. **Team Lead** → Technical guidance
3. **Project Manager** → Process and priority questions
4. **Scrum Master** → Workflow and impediment resolution

## 🎉 **Success Tips**

### **Daily Habits**
- ✅ Check JIRA tickets first thing in the morning
- ✅ Commit code regularly with clear messages
- ✅ Update JIRA tickets as you progress
- ✅ Communicate blockers early
- ✅ Review others' code promptly

### **Weekly Goals**
- ✅ Complete assigned JIRA tickets
- ✅ Participate in code reviews
- ✅ Update documentation when needed
- ✅ Share knowledge with team
- ✅ Attend team meetings and standups

---

## 🎯 **Process Flow Integration**

### **Authentication Flow (SMILE-12)**
When working on authentication-related features:
```bash
# Branch naming for authentication work
feature/SMILE-XXX-P[4|5]-auth-[description]

Examples:
✅ feature/SMILE-14-P4-auth-email-password
✅ feature/SMILE-15-P4-auth-social-integration
✅ feature/SMILE-16-P5-auth-method-selection
```

### **Profile Creation Flow (SMILE-13)**
When working on profile creation features:
```bash
# Branch naming for profile creation work
feature/SMILE-XXX-P[4|5]-profile-[description]

Examples:
✅ feature/SMILE-17-P4-profile-type-selection
✅ feature/SMILE-18-P4-profile-auto-save
✅ feature/SMILE-19-P5-profile-type-interface
```

### **Epic Progress Tracking**
- **Authentication Epic**: SMILE-12 (Current: 20% complete)
- **Profile Creation Epic**: SMILE-13 (Current: 0% complete)
- Epic progress updates automatically when stories are completed

## 📚 **Quick Links**

- **JIRA Project**: https://smilefactory.atlassian.net/jira/software/projects/SMILE
- **GitHub Repository**: https://github.com/moversfinder/smilefactory-platform
- **Documentation**: `docs/` folder
- **JIRA Setup Guide**: `docs/3_development_setup/23_jira_setup_complete_guide.md`
- **Process Flow Docs**: `docs/1_project_overview/15_authentication_process_flow.md`
- **Team Onboarding**: `TEAM_ONBOARDING.md`
- **Contributing Guide**: `CONTRIBUTING.md`

**Remember: We're building Zimbabwe's innovation future together! 🇿🇼**
