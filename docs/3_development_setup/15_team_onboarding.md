# SmileFactory Platform - Team Onboarding Guide

## 🚀 **Welcome to the SmileFactory Team!**

This guide will get you up and running quickly on the SmileFactory platform development.

## 📋 **Quick Start Checklist**

### **✅ Prerequisites**
- [ ] Git installed and configured
- [ ] GitHub account with repository access
- [ ] Node.js 18+ (for frontend)
- [ ] Java 17+ (for backend)
- [ ] Docker (optional, for local development)

### **✅ Repository Setup**
```bash
# 1. Clone the repository
git clone https://github.com/moversfinder/smilefactory-platform.git
cd smilefactory-platform

# 2. Switch to develop branch (default for development)
git checkout develop
git pull origin develop

# 3. Explore the structure
ls -la
```

## 🎯 **For Frontend Developers**

### **Your Workspace**
- **Main folder**: `frontend/`
- **Documentation**: `docs/5_frontend_implementation/`
- **UI Specs**: `docs/5_frontend_implementation/7_user_experience_design/`

### **Your First Task**
```bash
# 1. Create your first feature branch
git checkout -b feature/SMILE-[NUMBER]-P5-frontend-[description]

# Example:
git checkout -b feature/SMILE-45-P5-frontend-user-dashboard

# 2. Work in the frontend folder
cd frontend/
# Set up React app, install dependencies, start coding

# 3. When ready, create PR
git add .
git commit -m "SMILE-45 Implement user dashboard UI"
git push origin feature/SMILE-45-P5-frontend-user-dashboard
```

### **Key Documentation**
- **User Journeys**: `docs/1_planning_and_requirements/2_user_journeys/`
- **Platform Features**: `docs/1_planning_and_requirements/3_platform_features_specification.md`
- **UI Implementation**: `docs/5_frontend_implementation/2_user_interface_implementation.md`
- **API Endpoints**: `docs/2_technical_architecture/8_complete_api_documentation.md`

## 🔧 **For Backend Developers**

### **Your Workspace**
- **Main folder**: `backend/`
- **Documentation**: `docs/4_backend_implementation/`
- **API Specs**: `docs/2_technical_architecture/8_complete_api_documentation.md`

### **Your First Task**
```bash
# 1. Create your first feature branch
git checkout -b feature/SMILE-[NUMBER]-P4-backend-[description]

# Example:
git checkout -b feature/SMILE-67-P4-backend-user-api

# 2. Work in the backend folder
cd backend/
# Set up Spring Boot, implement APIs, write tests

# 3. When ready, create PR
git add .
git commit -m "SMILE-67 Implement user management API"
git push origin feature/SMILE-67-P4-backend-user-api
```

### **Key Documentation**
- **System Architecture**: `docs/2_technical_architecture/1_system_architecture_design.md`
- **Database Schema**: `docs/2_technical_architecture/2_database_schema_and_design.md`
- **API Specifications**: `docs/2_technical_architecture/8_complete_api_documentation.md`
- **Business Logic**: `docs/4_backend_implementation/4_business_logic_implementation.md`

## 🌳 **Branching Strategy (Simple)**

### **Branch Naming Convention**
```
feature/SMILE-[JIRA-NUMBER]-P[PHASE]-[COMPONENT]-[description]

Examples:
✅ feature/SMILE-45-P5-frontend-user-dashboard
✅ feature/SMILE-67-P4-backend-user-api
✅ feature/SMILE-89-P6-ai-recommendations
```

### **Daily Workflow**
```bash
# 1. Start from develop
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/SMILE-XXX-P[4|5]-[backend|frontend]-description

# 3. Work and commit regularly
git add .
git commit -m "SMILE-XXX Brief description of changes"

# 4. Push and create PR when ready
git push origin your-branch-name
# Create PR via GitHub web interface
```

## 🔄 **Code Review Process**

### **Creating Pull Requests**
1. **Title Format**: `SMILE-XXX [P4-Backend|P5-Frontend] Brief description`
2. **Description**: Explain what you built and why
3. **Link to JIRA**: Include JIRA ticket number
4. **Request Review**: Tag team members for review

### **Review Guidelines**
- **Be constructive** and helpful in feedback
- **Test the changes** if possible
- **Check documentation** is updated
- **Approve when satisfied** with the quality

## 🧪 **Testing & Quality**

### **Before Creating PR**
- [ ] Code follows project standards
- [ ] Tests are written and passing
- [ ] Documentation is updated
- [ ] No console errors or warnings
- [ ] JIRA ticket requirements are met

### **CI/CD Pipeline**
- **Automatic testing** runs on every PR
- **Must pass** before merging
- **Green checkmark** = good to merge
- **Red X** = needs fixing

## 📞 **Getting Help**

### **Documentation First**
- Check `docs/` folder for specifications
- Look at existing code for patterns
- Review JIRA tickets for requirements

### **Team Communication**
- **Questions**: Ask in team chat or create GitHub issue
- **Blockers**: Communicate early, don't wait
- **Ideas**: Share suggestions for improvements

### **Common Issues**
- **Merge conflicts**: Ask for help resolving
- **CI failures**: Check the logs and fix issues
- **JIRA access**: Contact project manager

## 🎯 **Success Metrics**

### **Good Developer Practices**
- **Regular commits** with clear messages
- **Small, focused PRs** (easier to review)
- **Good test coverage** for your code
- **Updated documentation** when needed
- **Responsive to feedback** during reviews

### **Team Collaboration**
- **Help teammates** when they need it
- **Share knowledge** and best practices
- **Communicate blockers** early
- **Participate in code reviews**

## 🚀 **Ready to Start!**

### **Your First Week Goals**
1. **Day 1**: Set up local environment and explore codebase
2. **Day 2-3**: Read relevant documentation and understand requirements
3. **Day 4-5**: Complete your first small feature/task
4. **Week 1**: Create your first successful PR and get it merged

### **Resources**
- **Repository**: https://github.com/moversfinder/smilefactory-platform
- **Documentation**: `docs/` folder in repository
- **JIRA**: [Your JIRA project URL]
- **Team Chat**: [Your team communication channel]

**Welcome to the team! Let's build something amazing together!** 🎉
