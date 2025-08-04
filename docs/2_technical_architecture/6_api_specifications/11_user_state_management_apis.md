# 11. User State Management APIs

## 👤 **User State Management Overview**

This document specifies APIs for managing different user states based on the platform's sophisticated user state system. The platform supports three main user states: NEW_USER (no profile), INCOMPLETE_PROFILE (partial profile), and COMPLETE_PROFILE (full profile).

## 🎯 **User State Definitions**

### **User State Types**
1. **NEW_USER** - User has signed up but has no profile
2. **INCOMPLETE_PROFILE** - User has a profile but it's incomplete (< 100% completion)
3. **COMPLETE_PROFILE** - User has a complete profile (100% completion)

### **Profile Completion Calculation**
Based on the 3-step completion process:
1. **Profile Category** (33%) - Profile type selected
2. **Personal Details** (33%) - First name and last name provided
3. **Profile Details** (34%) - All required fields for profile type completed

## 🔍 **User State APIs**

### **GET /api/v1/user/state**
**Get current user state**

```typescript
interface UserStateResponse {
  success: boolean;
  userState: {
    state: 'NEW_USER' | 'INCOMPLETE_PROFILE' | 'COMPLETE_PROFILE';
    isAuthenticated: boolean;
    hasAnyProfile: boolean;
    profileCompletion: number;
    isProfileComplete: boolean;
    isNewUser: boolean;
    hasIncompleteProfile: boolean;
    onboardingCompleted: boolean;
    firstTimeUser: boolean;
    lastActive: string;
    platformFamiliarityScore: number;
  };
  profile?: {
    id: string;
    profileType: string;
    profileStatus: 'ACTIVE' | 'INACTIVE' | 'PENDING';
    completionSteps: {
      personalDetails: boolean;
      profileCategory: boolean;
      profileDetails: boolean;
    };
  };
  nextSteps: NextStep[];
  recommendations: StateRecommendation[];
}

interface NextStep {
  step: string;
  title: string;
  description: string;
  url: string;
  priority: 'high' | 'medium' | 'low';
  estimatedTime: string;
  completed: boolean;
}

interface StateRecommendation {
  type: 'profile_completion' | 'feature_discovery' | 'networking' | 'content_creation';
  title: string;
  description: string;
  actionText: string;
  actionUrl: string;
  relevanceScore: number;
}
```

**Response Example for Incomplete Profile**:
```json
{
  "success": true,
  "userState": {
    "state": "INCOMPLETE_PROFILE",
    "isAuthenticated": true,
    "hasAnyProfile": true,
    "profileCompletion": 66,
    "isProfileComplete": false,
    "isNewUser": false,
    "hasIncompleteProfile": true,
    "onboardingCompleted": false,
    "firstTimeUser": false,
    "lastActive": "2024-01-20T15:30:00Z",
    "platformFamiliarityScore": 3
  },
  "profile": {
    "id": "profile-uuid-123",
    "profileType": "mentor",
    "profileStatus": "ACTIVE",
    "completionSteps": {
      "personalDetails": true,
      "profileCategory": true,
      "profileDetails": false
    }
  },
  "nextSteps": [
    {
      "step": "complete_profile_details",
      "title": "Complete Profile Details",
      "description": "Add specialized information for your mentor profile",
      "url": "/dashboard/profile/edit",
      "priority": "high",
      "estimatedTime": "5 minutes",
      "completed": false
    }
  ],
  "recommendations": [
    {
      "type": "profile_completion",
      "title": "Complete Your Profile",
      "description": "Unlock all platform features by completing your profile",
      "actionText": "Complete Now",
      "actionUrl": "/dashboard/profile/edit",
      "relevanceScore": 0.95
    }
  ]
}
```

### **PUT /api/v1/user/state**
**Update user state**

```typescript
interface UpdateUserStateRequest {
  onboardingCompleted?: boolean;
  firstTimeUser?: boolean;
  platformFamiliarityScore?: number;
  lastActiveSection?: string;
  preferences?: {
    skipOnboarding?: boolean;
    hideRecommendations?: boolean;
    preferredDashboardLayout?: string;
  };
}

interface UpdateUserStateResponse {
  success: boolean;
  userState: UserStateResponse['userState'];
  message: string;
}
```

## 📊 **Profile Completion APIs**

### **GET /api/v1/user/completion**
**Get detailed profile completion status**

```typescript
interface ProfileCompletionResponse {
  success: boolean;
  completion: {
    overall: {
      percentage: number;
      completedSteps: number;
      totalSteps: number;
      status: 'incomplete' | 'complete';
    };
    steps: CompletionStep[];
    missingFields: MissingField[];
    recommendations: CompletionRecommendation[];
    estimatedTimeToComplete: string;
  };
}

interface CompletionStep {
  step: number;
  name: string;
  title: string;
  description: string;
  status: 'completed' | 'current' | 'pending';
  percentage: number;
  fields: {
    fieldName: string;
    label: string;
    required: boolean;
    completed: boolean;
    value?: any;
  }[];
  estimatedTime: string;
}

interface MissingField {
  fieldName: string;
  label: string;
  section: string;
  importance: 'critical' | 'high' | 'medium' | 'low';
  description: string;
  helpText?: string;
  examples?: string[];
}

interface CompletionRecommendation {
  field: string;
  suggestion: string;
  reason: string;
  impact: string;
  priority: number;
}
```

### **POST /api/v1/user/completion/validate**
**Validate profile completion**

```typescript
interface ValidateCompletionRequest {
  profileData: Record<string, any>;
  profileType: string;
}

interface ValidateCompletionResponse {
  success: boolean;
  validation: {
    isComplete: boolean;
    percentage: number;
    errors: ValidationError[];
    warnings: ValidationWarning[];
    suggestions: ValidationSuggestion[];
  };
}

interface ValidationError {
  field: string;
  message: string;
  code: string;
  severity: 'error' | 'warning';
}

interface ValidationWarning {
  field: string;
  message: string;
  suggestion: string;
}

interface ValidationSuggestion {
  field: string;
  suggestion: string;
  reason: string;
  impact: string;
}
```

## 🎯 **Onboarding APIs**

### **GET /api/v1/user/onboarding**
**Get onboarding status and steps**

```typescript
interface OnboardingResponse {
  success: boolean;
  onboarding: {
    isCompleted: boolean;
    currentStep: number;
    totalSteps: number;
    steps: OnboardingStep[];
    canSkip: boolean;
    estimatedTimeRemaining: string;
  };
}

interface OnboardingStep {
  step: number;
  name: string;
  title: string;
  description: string;
  status: 'completed' | 'current' | 'pending' | 'skipped';
  url?: string;
  component?: string;
  data?: Record<string, any>;
  estimatedTime: string;
  isOptional: boolean;
}
```

### **PUT /api/v1/user/onboarding/{stepId}**
**Update onboarding step**

```typescript
interface UpdateOnboardingStepRequest {
  status: 'completed' | 'skipped';
  data?: Record<string, any>;
}

interface UpdateOnboardingStepResponse {
  success: boolean;
  step: OnboardingStep;
  nextStep?: OnboardingStep;
  onboardingCompleted: boolean;
}
```

### **POST /api/v1/user/onboarding/skip**
**Skip onboarding**

```typescript
interface SkipOnboardingResponse {
  success: boolean;
  message: string;
  redirectUrl: string;
}
```

## 🔄 **User Journey APIs**

### **GET /api/v1/user/journey**
**Get user journey analytics**

```typescript
interface UserJourneyResponse {
  success: boolean;
  journey: {
    registrationDate: string;
    daysSinceRegistration: number;
    currentPhase: 'onboarding' | 'exploration' | 'engagement' | 'advocacy';
    milestones: Milestone[];
    activities: JourneyActivity[];
    progressMetrics: {
      profileCompletion: number;
      platformEngagement: number;
      networkGrowth: number;
      contentCreation: number;
    };
    nextMilestones: NextMilestone[];
  };
}

interface Milestone {
  id: string;
  name: string;
  description: string;
  achievedAt?: string;
  category: 'profile' | 'social' | 'content' | 'engagement';
  points: number;
  badge?: string;
}

interface JourneyActivity {
  date: string;
  activity: string;
  description: string;
  category: string;
  impact: 'low' | 'medium' | 'high';
}

interface NextMilestone {
  id: string;
  name: string;
  description: string;
  requirements: string[];
  estimatedTime: string;
  reward: string;
  progress: number;
}
```

### **POST /api/v1/user/journey/milestone**
**Track milestone achievement**

```typescript
interface TrackMilestoneRequest {
  milestoneId: string;
  context?: Record<string, any>;
}

interface TrackMilestoneResponse {
  success: boolean;
  milestone: Milestone;
  reward?: {
    type: 'badge' | 'points' | 'feature_unlock';
    value: string | number;
    description: string;
  };
  nextMilestones: NextMilestone[];
}
```

## 📈 **User Engagement APIs**

### **GET /api/v1/user/engagement**
**Get user engagement metrics**

```typescript
interface UserEngagementResponse {
  success: boolean;
  engagement: {
    score: number;
    level: 'low' | 'medium' | 'high' | 'very_high';
    factors: {
      loginFrequency: number;
      profileCompleteness: number;
      socialActivity: number;
      contentCreation: number;
      platformExploration: number;
    };
    trends: {
      daily: EngagementDataPoint[];
      weekly: EngagementDataPoint[];
      monthly: EngagementDataPoint[];
    };
    recommendations: EngagementRecommendation[];
  };
}

interface EngagementDataPoint {
  date: string;
  score: number;
  activities: number;
}

interface EngagementRecommendation {
  type: 'feature_usage' | 'social_activity' | 'content_creation' | 'profile_optimization';
  title: string;
  description: string;
  actionText: string;
  actionUrl: string;
  impact: 'low' | 'medium' | 'high';
  effort: 'low' | 'medium' | 'high';
}
```

### **POST /api/v1/user/engagement/activity**
**Track user activity**

```typescript
interface TrackActivityRequest {
  activity: string;
  category: 'navigation' | 'interaction' | 'creation' | 'social' | 'consumption';
  context?: Record<string, any>;
  duration?: number;
}

interface TrackActivityResponse {
  success: boolean;
  activity: {
    id: string;
    activity: string;
    category: string;
    timestamp: string;
    engagementImpact: number;
  };
  updatedEngagementScore: number;
}
```

## 🎨 **User Preferences APIs**

### **GET /api/v1/user/preferences**
**Get user preferences**

```typescript
interface UserPreferencesResponse {
  success: boolean;
  preferences: {
    dashboard: {
      layout: 'default' | 'compact' | 'expanded';
      theme: 'light' | 'dark' | 'auto';
      showRecommendations: boolean;
      showOnboardingTips: boolean;
    };
    notifications: {
      email: boolean;
      push: boolean;
      inApp: boolean;
      frequency: 'immediate' | 'daily' | 'weekly';
    };
    privacy: {
      profileVisibility: 'public' | 'connections' | 'private';
      showActivity: boolean;
      showConnections: boolean;
      allowMessages: 'everyone' | 'connections' | 'none';
    };
    content: {
      language: string;
      timezone: string;
      contentTypes: string[];
      interests: string[];
    };
  };
}
```

### **PUT /api/v1/user/preferences**
**Update user preferences**

```typescript
interface UpdateUserPreferencesRequest {
  preferences: Partial<UserPreferencesResponse['preferences']>;
}

interface UpdateUserPreferencesResponse {
  success: boolean;
  preferences: UserPreferencesResponse['preferences'];
  message: string;
}
```

---

## 📚 **Reference Documents**

**Profile Management**: See `/2_technical_architecture/api_specifications/2_profile_management_apis.md`
**Dashboard APIs**: See `/2_technical_architecture/api_specifications/6_dashboard_apis.md`
**Authentication**: See `/2_technical_architecture/api_specifications/1_authentication_apis.md`
**User Experience Design**: See `/3_user_experience_design/4_dashboard_functionality_specification.md`

*These user state management APIs provide comprehensive functionality for tracking user progression, managing onboarding, monitoring engagement, and personalizing the user experience on the ZbInnovation platform.*
