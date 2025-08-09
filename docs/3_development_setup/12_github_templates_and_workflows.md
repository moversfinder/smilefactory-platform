# 12. GitHub Templates and Workflows

## 🔗 **GitHub Integration Overview**

The SmileFactory platform uses GitHub templates and automated workflows to ensure consistent development practices and maintain code quality. All GitHub-specific configurations are located in the `/.github/` folder.

## 📋 **Pull Request Templates**

### **Main PR Template** (`/.github/PULL_REQUEST_TEMPLATE.md`)
**Comprehensive PR checklist covering**:
- **JIRA Integration**: Automatic linking to project tickets
- **Change Classification**: Bug fix, feature, breaking change, documentation
- **Testing Requirements**: Steps to validate changes
- **API Compliance**: OpenAPI updates and backward compatibility
- **Frontend Standards**: Component structure, TypeScript, accessibility
- **Backend Standards**: DTOs, validation, transactions, migrations
- **Review Checklist**: Complete validation before merge

### **Specialized PR Templates** (`/.github/PULL_REQUEST_TEMPLATE/`)
**Type-specific templates for**:
- **Feature PRs** (`feat.md`): New functionality development
- **Bug Fix PRs** (`fix.md`): Issue resolution and patches
- **Documentation PRs** (`docs.md`): Documentation updates

## 🐛 **Issue Templates**

### **Issue Types** (`/.github/ISSUE_TEMPLATE/`)
**Standardized issue creation for**:
- **Bug Reports** (`bug_report.md`): Detailed bug reporting with reproduction steps
- **Feature Requests** (`feature_request.md`): New feature proposals with business justification
- **User Stories** (`story.md`): User-centered feature descriptions
- **Tasks** (`task.md`): Development and maintenance tasks

### **Template Benefits**
- **Consistent Information**: All issues contain required details
- **Faster Triage**: Standardized format speeds up issue processing
- **Better Communication**: Clear structure improves team understanding
- **JIRA Integration**: Automatic linking to project management system

## ⚙️ **Automated Workflows**

### **PR Validation Workflow** (`/.github/workflows/pr-validation.yml`)
**Automated checks for every pull request**:

#### **Title Validation**
- **Format Requirement**: `SF-123: type(scope): description`
- **JIRA Key Validation**: Must start with SMILE- or SF- followed by number
- **Automatic Enforcement**: PRs fail if title format is incorrect

#### **Branch Naming Validation**
- **Convention**: `feature/SF-123-short-description`
- **Supported Types**: feature, fix, docs, chore, refactor
- **Automatic Validation**: Ensures consistent branch naming

#### **JIRA Link Validation**
- **Required Link**: PR body must contain JIRA ticket URL
- **Format Check**: Validates proper JIRA link format
- **Integration Assurance**: Ensures traceability to project management

### **Workflow Benefits**
- **Quality Gates**: Prevents non-compliant PRs from being merged
- **Automation**: Reduces manual review overhead
- **Consistency**: Enforces team standards automatically
- **Integration**: Seamless JIRA-GitHub connection

## 🔄 **Development Workflow Integration**

### **Standard Development Flow**
1. **Create JIRA Ticket**: Define work item in project management system
2. **Create Branch**: Use naming convention `feature/SF-123-description`
3. **Develop Feature**: Follow coding standards and architectural principles
4. **Create PR**: Use appropriate template with required information
5. **Automated Validation**: GitHub workflows validate PR compliance
6. **Code Review**: Team reviews using comprehensive checklist
7. **Merge**: Approved PRs are merged with automatic JIRA updates

### **Template Usage Guidelines**

#### **For Developers**
- **Choose Correct Template**: Select template matching change type
- **Complete All Sections**: Fill out all required template sections
- **Link JIRA Tickets**: Always include JIRA ticket links
- **Follow Checklists**: Use provided checklists for quality assurance

#### **For Reviewers**
- **Use PR Checklist**: Follow template checklist for thorough review
- **Verify JIRA Links**: Ensure proper project management integration
- **Check Standards Compliance**: Validate architectural and coding standards
- **Provide Constructive Feedback**: Use template structure for clear communication

## 📊 **Quality Assurance Integration**

### **Automated Quality Checks**
- **PR Title Format**: Ensures consistent naming and JIRA integration
- **Branch Naming**: Validates development workflow compliance
- **Documentation Links**: Verifies proper project management connection
- **Template Completion**: Encourages comprehensive PR descriptions

### **Manual Quality Checks**
- **Code Review Standards**: Template-guided review process
- **Architectural Compliance**: Checklist ensures modular design principles
- **Testing Requirements**: Validates comprehensive testing approach
- **Documentation Updates**: Ensures documentation stays current

## 🛠️ **Customization and Maintenance**

### **Template Updates**
- **Regular Review**: Templates updated based on team feedback
- **Standards Evolution**: Templates evolve with coding standards
- **Tool Integration**: Templates updated for new development tools
- **Process Improvement**: Continuous refinement based on usage patterns

### **Workflow Maintenance**
- **GitHub Actions Updates**: Keep workflows current with GitHub features
- **Validation Rules**: Update validation rules as standards evolve
- **Integration Points**: Maintain JIRA and other tool integrations
- **Performance Optimization**: Optimize workflow execution time

## 📚 **Related Documentation**

### **Development Process**
- **Coding Standards**: `/docs/3_development_setup/2_coding_standards_and_guidelines.md`
- **Code Review Process**: `/docs/3_development_setup/11_comprehensive_code_review_process.md`
- **Git Workflow**: `/docs/3_development_setup/3_version_control_and_workflow.md`

### **Project Management**
- **JIRA Integration**: `/docs/JIRA_GITHUB_INTEGRATION.md`
- **Team Workflow**: `/docs/TEAM_WORKFLOW_QUICK_REFERENCE.md`
- **Contribution Guidelines**: `/docs/CONTRIBUTING.md`

## 🎯 **Best Practices**

### **For Team Members**
1. **Use Templates**: Always use appropriate PR and issue templates
2. **Complete Information**: Fill out all required template sections
3. **Follow Naming**: Use consistent branch and PR title naming
4. **Link Tickets**: Always connect work to JIRA tickets
5. **Review Checklists**: Use template checklists for quality assurance

### **For Project Maintainers**
1. **Monitor Compliance**: Regularly check template usage and compliance
2. **Update Templates**: Keep templates current with evolving standards
3. **Train Team**: Ensure team understands template usage
4. **Gather Feedback**: Continuously improve templates based on usage
5. **Maintain Workflows**: Keep automated workflows functioning properly

---

## 🚀 **Quick Reference**

### **Creating a PR**
1. Use branch naming: `feature/SF-123-description`
2. Select appropriate PR template
3. Fill out all template sections
4. Include JIRA ticket link
5. Complete relevant checklists

### **Creating an Issue**
1. Select appropriate issue template
2. Provide detailed description
3. Include reproduction steps (for bugs)
4. Link to related JIRA tickets
5. Add appropriate labels

**The GitHub templates and workflows ensure consistent, high-quality development practices while maintaining seamless integration with project management systems.** 🔗
