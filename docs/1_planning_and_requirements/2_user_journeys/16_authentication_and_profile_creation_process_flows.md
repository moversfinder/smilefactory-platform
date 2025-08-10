# 16. Authentication and Profile Creation Process Flows

## 📋 **Journey Overview**

- **Phase**: Onboarding (Phase 1 - Core Foundation)
- **User Types**: All potential users (anonymous to fully profiled)
- **Prerequisites**: Landing page interaction or direct referral
- **Success Criteria**: User has authenticated account and complete profile ready for platform engagement
- **Duration**: 5-15 minutes for complete authentication and profile creation
- **Architecture Goal**: Enable scalable implementation with multiple profiles per user

## 🎯 **Process Flow Objectives**

### **Business Goals**
- **Shortest User Journey**: Minimize friction in initial sign-up process
- **Scalable Architecture**: Support multiple profiles per user via personal_details UUID
- **Stage-by-Stage Completion**: Allow users to complete profile creation over time
- **Data Integrity**: Ensure each step triggers appropriate database operations
- **Auto-Save Functionality**: Prevent data loss during profile creation

### **Technical Goals**
- **Modular Database Design**: Separate authentication from profile data
- **API Efficiency**: Each completed step triggers separate database calls
- **State Management**: Track completion status at each stage
- **Scalability**: Architecture supports future expansion and multiple profile types

## 🔐 **Authentication Process Flow**

### **Phase 1: Initial Sign-Up (Shortest Journey)**

#### **Step 1: Authentication Method Selection**
**User Experience**:
- Landing on sign-up page with clear, simple options
- Three authentication pathways presented equally:
  - **Email & Password**: Traditional registration
  - **Social Authentication**: Google, Facebook, LinkedIn one-click
  - **Phone Authentication**: SMS-based verification

**Technical Implementation**:
```
User Selection → Authentication Provider → Account Creation
```

#### **Step 2: Account Creation**
**For Email & Password**:
- Minimal form: Email, Password, Confirm Password
- Real-time validation and security indicators
- Terms of service agreement

**For Social Authentication**:
- OAuth flow with selected provider
- Permission request for basic profile information
- Automatic email verification if provided by social provider

**For Phone Authentication**:
- Phone number entry with country code selection
- SMS verification code sent immediately
- Backup email collection for account recovery

#### **Step 3: Authentication Account Created**
**Database Operations**:
```sql
-- Create authentication record in personal_details table
INSERT INTO personal_details (
    id,                    -- UUID (primary key)
    email,                 -- From authentication
    password_hash,         -- If email/password method
    phone_number,          -- If phone authentication
    social_provider,       -- If social authentication
    social_provider_id,    -- Provider-specific ID
    email_verified,        -- True for social, pending for email
    account_status,        -- 'ACTIVE'
    profile_completion,    -- 0% initially
    created_at,
    updated_at
) VALUES (...)
```

**User State After Authentication**:
- ✅ Can sign in to platform
- ✅ Has unique personal_details UUID
- ❌ No profile created yet
- ❌ Limited platform access

#### **Step 4: Dashboard Access with Profile Creation Prompt**
**User Experience**:
- Successful authentication redirects to dashboard
- Dashboard shows "Create Profile" prominent button/card
- Limited functionality available until profile creation
- Clear explanation of benefits of completing profile

**Dashboard Elements**:
- Welcome message with user's name (if available)
- Profile completion progress (0%)
- "Create Profile" call-to-action
- Basic platform navigation (limited features)
- Help and support options

## 👤 **Profile Creation Process Flow**

### **Phase 2: Profile Creation (3-Step Process)**

#### **Step 1: Profile Type Selection**
**User Experience**:
- Clear presentation of 8 profile types with descriptions
- Visual cards showing benefits and use cases for each type
- "Learn More" options for detailed explanations
- Ability to change selection before proceeding

**Profile Type Options**:
1. **Innovator** 🚀 - "I have innovative ideas and need support"
2. **Business Investor** 💰 - "I invest in startups and projects"
3. **Mentor** 🎓 - "I guide and support emerging innovators"
4. **Professional** 💼 - "I offer services to the innovation community"
5. **Industry Expert** 🔬 - "I have deep industry knowledge"
6. **Academic Student** 📚 - "I'm seeking learning opportunities"
7. **Academic Institution** 🏫 - "I represent an educational institution"
8. **Organisation** 🏢 - "I represent a company or organization"

**Technical Implementation**:
```
Profile Type Selection → Validation → Store Selection → Proceed to Personal Details
```

#### **Step 2: Personal Information Entry**
**User Experience**:
- Form fields relevant to personal details
- Auto-population from authentication data where available
- Clear field labels with helpful examples
- Real-time validation with constructive feedback

**Data Collection**:
```typescript
interface PersonalInformation {
  firstName: string;
  lastName: string;
  dateOfBirth?: Date;
  gender?: 'male' | 'female' | 'other' | 'prefer_not_to_say';
  location: {
    country: string;
    city: string;
    region?: string;
  };
  bio?: string;
  profilePhoto?: File;
  contactPreferences: {
    email: boolean;
    sms: boolean;
    platform: boolean;
  };
}
```

**Database Operations**:
```sql
-- Update personal_details record with personal information
UPDATE personal_details SET
    first_name = ?,
    last_name = ?,
    date_of_birth = ?,
    gender = ?,
    country = ?,
    city = ?,
    region = ?,
    bio = ?,
    profile_photo_url = ?,
    contact_preferences = ?,
    profile_completion = 33,  -- 1/3 complete
    updated_at = NOW()
WHERE id = ?;
```

**Auto-Save Implementation**:
- Form data saved every 30 seconds
- Save on field blur events
- Visual indicator of save status
- Recovery mechanism for interrupted sessions

#### **Step 3: Profile Details Entry**
**User Experience**:
- Dynamic form based on selected profile type
- Progressive disclosure of relevant sections
- Optional vs required field indicators
- Ability to save and continue later

**Profile-Specific Data Collection**:
Each profile type has specialized fields:

**Innovator Profile**:
```typescript
interface InnovatorProfile {
  innovationFocus: string;
  currentStage: 'idea' | 'prototype' | 'mvp' | 'scaling';
  industryFocus: string[];
  fundingStatus: 'pre_seed' | 'seed' | 'series_a' | 'funded';
  teamSize: number;
  lookingFor: ('funding' | 'mentorship' | 'team_members' | 'partnerships')[];
}
```

**Business Investor Profile**:
```typescript
interface BusinessInvestorProfile {
  investmentFocus: string[];
  ticketSize: {
    minimum: number;
    maximum: number;
  };
  investmentStage: ('pre_seed' | 'seed' | 'series_a' | 'series_b')[];
  geographicFocus: string[];
  portfolioSize: number;
}
```

**Database Operations**:
```sql
-- Create profile-specific record
INSERT INTO [profile_type]_profiles (
    personal_details_id,  -- Foreign key to personal_details.id
    profile_specific_data,
    completion_status,
    created_at,
    updated_at
) VALUES (?, ?, 'COMPLETE', NOW(), NOW());

-- Update personal_details completion
UPDATE personal_details SET
    profile_type = ?,
    profile_completion = 100,
    profile_state = 'COMPLETE',
    updated_at = NOW()
WHERE id = ?;
```

### **Phase 3: Profile Completion and Activation**

#### **Profile Review and Finalization**
**User Experience**:
- Preview of complete profile as others will see it
- Edit options for any section
- Privacy and visibility settings
- Final confirmation before publishing

**System Operations**:
- Profile validation and completeness check
- Search index updates for discoverability
- Recommendation engine initialization
- Welcome email with platform guidance

## 🏗️ **Architecture Rationale**

### **Multiple Profiles Support**
**Design Philosophy**:
- One `personal_details` record per person (UUID as primary key)
- Multiple profile type records can link to same `personal_details_id`
- Enables users to have multiple professional identities
- Maintains data integrity and reduces duplication

**Example Scenario**:
```
Dr. Sarah Johnson (personal_details UUID: abc-123)
├── Academic Researcher Profile (research focus)
├── Mentor Profile (mentoring students)
└── Industry Expert Profile (consulting work)
```

### **Database Architecture Benefits**:
1. **Data Normalization**: Personal information stored once
2. **Scalability**: Easy to add new profile types
3. **Flexibility**: Users can switch or add profile types
4. **Analytics**: Track user behavior across profile types
5. **Privacy**: Granular control over profile visibility

## 🔄 **Auto-Save and State Management**

### **Auto-Save Implementation**
**Triggers**:
- Every 30 seconds during active editing
- On field blur events
- Before navigation away from page
- On browser close/refresh events

**State Tracking**:
```typescript
interface ProfileCreationState {
  currentStep: 1 | 2 | 3;
  profileTypeSelected: boolean;
  personalInfoComplete: boolean;
  profileDetailsComplete: boolean;
  lastSaved: Date;
  autoSaveEnabled: boolean;
}
```

### **Recovery Mechanisms**:
- Session restoration on return
- Draft state preservation
- Progress indicators
- Clear continuation paths

## 🎯 **JIRA Workflow Integration**

### **Epic and Story Structure for Process Flows**

#### **Authentication Process Epic**
**Epic**: `P4-BACKEND-AUTH-FLOW - Authentication Process Implementation`
**Stories**:
- `P4-BACKEND-AUTH-001`: Email/Password authentication endpoint
- `P4-BACKEND-AUTH-002`: Social authentication integration (Google, Facebook, LinkedIn)
- `P4-BACKEND-AUTH-003`: Phone/SMS authentication system
- `P4-BACKEND-AUTH-004`: Authentication account creation and personal_details table operations
- `P5-FRONTEND-AUTH-001`: Authentication method selection UI
- `P5-FRONTEND-AUTH-002`: Sign-up form components with validation
- `P5-FRONTEND-AUTH-003`: Social authentication integration UI
- `P5-FRONTEND-AUTH-004`: Dashboard with profile creation prompt

#### **Profile Creation Process Epic**
**Epic**: `P4-BACKEND-PROFILE-FLOW - Profile Creation Process Implementation`
**Stories**:
- `P4-BACKEND-PROFILE-001`: Profile type selection and validation
- `P4-BACKEND-PROFILE-002`: Personal information collection and storage
- `P4-BACKEND-PROFILE-003`: Profile-specific data collection for all 8 types
- `P4-BACKEND-PROFILE-004`: Auto-save functionality and state management
- `P5-FRONTEND-PROFILE-001`: Profile type selection interface
- `P5-FRONTEND-PROFILE-002`: Personal information form with auto-save
- `P5-FRONTEND-PROFILE-003`: Dynamic profile-specific forms
- `P5-FRONTEND-PROFILE-004`: Profile review and completion interface

### **Automated JIRA Ticket Creation**
**PR-to-JIRA Automation Rules**:
```yaml
# GitHub Action for automatic JIRA ticket creation
name: Auto-create JIRA tickets for Process Flow PRs
on:
  pull_request:
    opened:
      - 'feature/SMILE-*-auth-*'
      - 'feature/SMILE-*-profile-*'

jobs:
  create-jira-ticket:
    if: contains(github.event.pull_request.title, 'auth-flow') || contains(github.event.pull_request.title, 'profile-flow')
    steps:
      - name: Create JIRA Ticket
        uses: atlassian/gajira-create@v2
        with:
          project: SMILE
          issuetype: Task
          summary: "Review: ${{ github.event.pull_request.title }}"
          description: |
            **Pull Request**: ${{ github.event.pull_request.html_url }}
            **Process Flow**: Authentication and Profile Creation
            **Component**: ${{ contains(github.event.pull_request.title, 'frontend') && 'Frontend' || 'Backend' }}

            **Review Checklist**:
            - [ ] Code follows process flow specifications
            - [ ] Database operations align with architecture
            - [ ] Auto-save functionality implemented correctly
            - [ ] Error handling and validation complete
            - [ ] Tests cover all process flow scenarios
```

## 🛠️ **Implementation Guidelines for Development Teams**

### **Backend Development Guidelines**

#### **Database Implementation Priority**
1. **Personal Details Table**: Ensure UUID primary key and proper indexing
2. **Profile Type Tables**: Create separate tables for each of 8 profile types
3. **Foreign Key Relationships**: Link profile tables to personal_details via UUID
4. **Auto-Save Support**: Implement draft state columns and timestamp tracking

#### **API Endpoint Implementation**
```typescript
// Authentication Flow Endpoints
POST /api/v1/auth/register/email          // Email/password registration
POST /api/v1/auth/register/social         // Social authentication
POST /api/v1/auth/register/phone          // Phone/SMS authentication
GET  /api/v1/auth/verify-email/:token     // Email verification
POST /api/v1/auth/login                   // User login

// Profile Creation Flow Endpoints
GET  /api/v1/profiles/types               // Get available profile types
POST /api/v1/profiles/select-type         // Select profile type
PUT  /api/v1/profiles/personal-info       // Update personal information
PUT  /api/v1/profiles/profile-details     // Update profile-specific details
POST /api/v1/profiles/auto-save           // Auto-save draft state
GET  /api/v1/profiles/completion-status   // Get completion progress
```

#### **Auto-Save Implementation**
```typescript
// Auto-save service implementation
class ProfileAutoSaveService {
  async saveDraft(userId: string, stepData: any, step: number): Promise<void> {
    await this.db.query(`
      INSERT INTO profile_drafts (user_id, step, data, saved_at)
      VALUES (?, ?, ?, NOW())
      ON DUPLICATE KEY UPDATE data = ?, saved_at = NOW()
    `, [userId, step, JSON.stringify(stepData), JSON.stringify(stepData)]);
  }

  async getDraft(userId: string, step: number): Promise<any> {
    const result = await this.db.query(`
      SELECT data FROM profile_drafts
      WHERE user_id = ? AND step = ?
    `, [userId, step]);
    return result[0] ? JSON.parse(result[0].data) : null;
  }
}
```

### **Frontend Development Guidelines**

#### **Component Architecture**
```typescript
// Authentication Flow Components
AuthenticationMethodSelector    // Step 1: Choose auth method
EmailPasswordForm              // Email/password registration
SocialAuthButtons             // Social authentication options
PhoneAuthForm                 // Phone/SMS authentication
DashboardWithProfilePrompt    // Post-auth dashboard

// Profile Creation Flow Components
ProfileTypeSelector           // Step 1: Profile type selection
PersonalInformationForm      // Step 2: Personal details
ProfileDetailsForm           // Step 3: Profile-specific details
ProfileReviewAndComplete     // Final review and completion
```

#### **State Management Implementation**
```typescript
// Profile creation state management
interface ProfileCreationState {
  currentStep: 1 | 2 | 3;
  selectedProfileType: ProfileType | null;
  personalInfo: PersonalInformation | null;
  profileDetails: any | null;
  autoSaveStatus: 'saving' | 'saved' | 'error';
  completionPercentage: number;
}

// Auto-save hook
const useAutoSave = (data: any, step: number) => {
  const [saveStatus, setSaveStatus] = useState<'saving' | 'saved' | 'error'>('saved');

  useEffect(() => {
    const timer = setTimeout(async () => {
      setSaveStatus('saving');
      try {
        await profileAPI.autoSave(data, step);
        setSaveStatus('saved');
      } catch (error) {
        setSaveStatus('error');
      }
    }, 30000); // Auto-save every 30 seconds

    return () => clearTimeout(timer);
  }, [data, step]);

  return saveStatus;
};
```

### **Testing Requirements**

#### **Backend Testing**
- **Unit Tests**: Each API endpoint with various input scenarios
- **Integration Tests**: Complete authentication and profile creation flows
- **Database Tests**: Verify proper foreign key relationships and data integrity
- **Performance Tests**: Auto-save functionality under load

#### **Frontend Testing**
- **Component Tests**: Each form component with validation scenarios
- **Flow Tests**: Complete user journey from authentication to profile completion
- **Auto-Save Tests**: Verify auto-save triggers and recovery mechanisms
- **Accessibility Tests**: Keyboard navigation and screen reader compatibility

---

## 📚 **Reference Documents**

**Technical Implementation**: See `/2_technical_architecture/6_api_specifications/1_authentication_apis.md`
**Database Schema**: See `/2_technical_architecture/2_database_schema_and_design.md`
**Profile Management**: See `/2_technical_architecture/6_api_specifications/2_profile_management_apis.md`
**JIRA Integration**: See `/3_development_setup/14_jira_github_integration.md`
**Development Setup**: See `/3_development_setup/1_development_environment_setup.md`
**Testing Guidelines**: See `/6_integration_and_testing/1_system_integration.md`

*This comprehensive process flow design enables scalable implementation while maintaining the shortest possible user journey for initial authentication and supports the team's collaborative development workflow.*
