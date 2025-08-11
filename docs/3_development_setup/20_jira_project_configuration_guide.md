# 20. JIRA Project Configuration Guide

## 🎯 **Overview**

This comprehensive guide covers the complete JIRA project setup for the SmileFactory platform, including project configuration, custom fields, workflows, automation rules, and integration with the authentication and profile creation process flows.

## 📋 **JIRA Project Setup**

### **Project Configuration**
```yaml
Project Details:
  Key: SMILE
  Name: SmileFactory Platform
  Type: Software Development
  Template: Scrum
  Lead: Project Manager
  Default Assignee: Project Lead
```

### **Project Components**
```yaml
Components:
  - name: Frontend
    description: React/TypeScript UI components and pages
    lead: Frontend Team Lead
    
  - name: Backend
    description: Spring Boot APIs and business logic
    lead: Backend Team Lead
    
  - name: Database
    description: PostgreSQL schema and data management
    lead: Backend Team Lead
    
  - name: DevOps
    description: CI/CD, deployment, and infrastructure
    lead: DevOps Engineer
    
  - name: Documentation
    description: Technical and user documentation
    lead: Technical Writer
```

### **Issue Types Configuration**

#### **Standard Issue Types**
```yaml
Epic:
  description: Large feature or process flow implementation
  icon: 📋
  color: Purple
  workflow: Epic Workflow
  
Story:
  description: User-facing feature or functionality
  icon: 📖
  color: Green
  workflow: Story Workflow
  
Task:
  description: Technical work or non-user-facing changes
  icon: ✅
  color: Blue
  workflow: Task Workflow
  
Bug:
  description: Defect or issue to be fixed
  icon: 🐛
  color: Red
  workflow: Bug Workflow
  
Spike:
  description: Research or investigation work
  icon: 🔍
  color: Orange
  workflow: Task Workflow
```

#### **Process Flow Specific Issue Types**
```yaml
Authentication Story:
  description: Authentication process flow implementation
  icon: 🔐
  color: Dark Blue
  workflow: Process Flow Workflow
  
Profile Creation Story:
  description: Profile creation process flow implementation
  icon: 👤
  color: Teal
  workflow: Process Flow Workflow
```

## 🔧 **Custom Fields Configuration**

### **Process Flow Fields**
```yaml
Process Flow Type:
  type: Select List (single choice)
  options:
    - Authentication
    - Profile Creation
    - General
  description: Type of process flow this issue belongs to
  
Epic Link:
  type: Epic Link
  description: Links stories to their parent epic
  
Story Points:
  type: Number
  description: Effort estimation for stories
  
Component:
  type: Select List (single choice)
  options:
    - Frontend
    - Backend
    - Database
    - DevOps
    - Documentation
  description: Technical component this issue affects
```

### **GitHub Integration Fields**
```yaml
GitHub PR Link:
  type: URL
  description: Link to associated GitHub Pull Request
  
GitHub Branch:
  type: Text Field (single line)
  description: Git branch name for this issue
  
Deployment Status:
  type: Select List (single choice)
  options:
    - Not Deployed
    - Staging
    - Production
  description: Current deployment status
```

### **Team Management Fields**
```yaml
Team Assignment:
  type: Select List (single choice)
  options:
    - Frontend Team
    - Backend Team
    - Full Stack
    - DevOps Team
  description: Team responsible for this issue
  
Reviewer:
  type: User Picker (single user)
  description: Code reviewer for this issue
  
Pair Programming:
  type: User Picker (multiple users)
  description: Team members working together on this issue
```

## 🔄 **Workflow Configuration**

### **Process Flow Workflow**
```yaml
Statuses:
  - name: To Do
    category: To Do
    description: Ready for development
    
  - name: In Progress
    category: In Progress
    description: Currently being worked on
    
  - name: Code Review
    category: In Progress
    description: Pull request created, under review
    
  - name: Testing
    category: In Progress
    description: In QA testing phase
    
  - name: Ready for Merge
    category: In Progress
    description: Approved and ready to merge
    
  - name: Done
    category: Done
    description: Completed and merged
    
  - name: Deployed
    category: Done
    description: Deployed to production

Transitions:
  - name: Start Progress
    from: To Do
    to: In Progress
    id: 11
    
  - name: Submit for Review
    from: In Progress
    to: Code Review
    id: 21
    
  - name: Move to Testing
    from: Code Review
    to: Testing
    id: 31
    
  - name: Ready for Merge
    from: Testing
    to: Ready for Merge
    id: 41
    
  - name: Complete
    from: Ready for Merge
    to: Done
    id: 51
    
  - name: Deploy
    from: Done
    to: Deployed
    id: 61
```

### **Epic Workflow**
```yaml
Statuses:
  - name: Planning
    category: To Do
    description: Epic being planned and broken down
    
  - name: In Progress
    category: In Progress
    description: Stories are being worked on
    
  - name: Review
    category: In Progress
    description: Epic implementation under review
    
  - name: Complete
    category: Done
    description: All epic stories completed

Transitions:
  - name: Start Epic
    from: Planning
    to: In Progress
    id: 71
    
  - name: Epic Review
    from: In Progress
    to: Review
    id: 81
    
  - name: Complete Epic
    from: Review
    to: Complete
    id: 91
```

## 🤖 **JIRA Automation Rules**

### **GitHub Integration Automation**

#### **Rule 1: Auto-transition on PR Events**
```yaml
Name: GitHub PR Status Sync
Trigger: Issue updated via REST API
Conditions:
  - Comment contains "Pull Request ready for review"
Actions:
  - Transition issue to "Code Review"
  - Add label "in-review"
```

#### **Rule 2: Auto-complete on PR Merge**
```yaml
Name: GitHub PR Merge Completion
Trigger: Issue updated via REST API
Conditions:
  - Comment contains "Pull Request merged successfully"
Actions:
  - Transition issue to "Done"
  - Add label "merged"
  - Update "Deployment Status" to "Staging"
```

### **Process Flow Automation**

#### **Rule 3: Epic Progress Tracking**
```yaml
Name: Epic Progress Updates
Trigger: Issue transitioned
Conditions:
  - Issue has Epic Link
  - Issue transitioned to "Done"
Actions:
  - Add comment to Epic with progress update
  - Calculate completion percentage
  - Notify Epic assignee if Epic is 100% complete
```

#### **Rule 4: Auto-assign by Component**
```yaml
Name: Component-based Assignment
Trigger: Issue created
Conditions:
  - Component is set
Actions:
  - If Component = "Frontend" → Assign to Frontend Team Lead
  - If Component = "Backend" → Assign to Backend Team Lead
  - If Component = "DevOps" → Assign to DevOps Engineer
```

### **Team Collaboration Automation**

#### **Rule 5: Code Review Assignment**
```yaml
Name: Auto-assign Code Reviewer
Trigger: Issue transitioned to "Code Review"
Actions:
  - If Component = "Frontend" → Set Reviewer to Frontend Senior Dev
  - If Component = "Backend" → Set Reviewer to Backend Senior Dev
  - Send notification to reviewer
```

#### **Rule 6: Sprint Planning Automation**
```yaml
Name: Sprint Auto-planning
Trigger: Sprint started
Actions:
  - Move all "Ready for Sprint" issues to "To Do"
  - Assign issues to team members based on component
  - Create sprint goal based on epic progress
```

## 📊 **JIRA Dashboards Configuration**

### **Project Overview Dashboard**
```yaml
Gadgets:
  - Sprint Burndown Chart
  - Epic Progress Report
  - Component Velocity Chart
  - Issue Statistics
  - Recent Activity Stream
  
Filters:
  - Current Sprint Issues
  - Process Flow Progress
  - Team Workload Distribution
```

### **Process Flow Dashboard**
```yaml
Gadgets:
  - Authentication Flow Progress
  - Profile Creation Flow Progress
  - Cross-Epic Dependencies
  - Quality Metrics (Bugs vs Stories)
  - Deployment Pipeline Status
  
Filters:
  - Authentication Process Issues
  - Profile Creation Process Issues
  - Cross-team Dependencies
```

### **Team Performance Dashboard**
```yaml
Gadgets:
  - Team Velocity Chart
  - Code Review Metrics
  - Bug Resolution Time
  - Story Point Accuracy
  - Individual Workload
  
Filters:
  - Frontend Team Performance
  - Backend Team Performance
  - Cross-team Collaboration
```

## 🔗 **Integration Setup**

### **GitHub Integration**
```yaml
Required Apps:
  - GitHub for Jira (by Atlassian)
  - Smart Commits for Jira
  
Configuration:
  - Repository: moversfinder/smilefactory-platform
  - Branch mapping: develop → Staging, main → Production
  - Smart commit format: SMILE-XXX: description #transition
```

### **Slack Integration**
```yaml
Notifications:
  - Epic completion → #project-updates
  - Critical bugs → #dev-alerts
  - Sprint planning → #team-standup
  - Deployment status → #deployment-updates
```

## 📈 **Metrics and KPIs**

### **Process Flow Metrics**
```yaml
Authentication Flow:
  - Stories completed vs planned
  - Average story completion time
  - Bug rate per story
  - Code review cycle time
  
Profile Creation Flow:
  - Epic progress percentage
  - Cross-team dependency resolution time
  - Quality metrics (test coverage, bugs)
  - User acceptance criteria completion
```

### **Team Performance Metrics**
```yaml
Velocity Tracking:
  - Story points completed per sprint
  - Velocity trend over time
  - Capacity vs commitment accuracy
  
Quality Metrics:
  - Bug escape rate
  - Code review feedback cycles
  - Time to resolution
  - Customer satisfaction scores
```

## 🚀 **Implementation Checklist**

### **Initial Setup**
- [ ] Create JIRA project with SMILE key
- [ ] Configure issue types and workflows
- [ ] Set up custom fields
- [ ] Install GitHub integration app
- [ ] Configure automation rules

### **Team Onboarding**
- [ ] Add team members to project
- [ ] Assign component leads
- [ ] Set up team-specific dashboards
- [ ] Train team on workflow processes
- [ ] Establish sprint planning procedures

### **Process Flow Integration**
- [ ] Create authentication flow epic (SMILE-AUTH-FLOW)
- [ ] Create profile creation flow epic (SMILE-PROFILE-FLOW)
- [ ] Set up epic-story relationships
- [ ] Configure process flow automation
- [ ] Test GitHub integration with sample PRs

---

*This JIRA configuration provides comprehensive project management capabilities specifically designed for the SmileFactory platform development workflow with full GitHub integration and process flow tracking.*
