# 6. Dashboard APIs

## 📊 **Dashboard API Overview**

This document specifies comprehensive dashboard APIs that provide personalized user information, activity summaries, and quick access to platform features based on user profile type and engagement level.

## 🎯 **Core Dashboard APIs**

### **GET /api/v1/dashboard/overview**
**Get comprehensive dashboard overview**

```typescript
interface DashboardOverviewResponse {
  success: boolean;
  dashboard: {
    user: {
      id: string;
      firstName: string;
      lastName: string;
      email: string;
      profilePhotoUrl?: string;
      profileType: string;
      profileStatus: 'ACTIVE' | 'INACTIVE' | 'PENDING';
      profileCompletion: number;
      hasAnyProfile: boolean;
    };
    unreadCounts: {
      messages: number;
      activities: number;
      connectionRequests: number;
      notifications: number;
    };
    stats: {
      totalPosts: number;
      totalConnections: number;
      totalLikes: number;
      profileViews: number;
    };
    recentActivity: {
      lastLogin: string;
      lastPost?: string;
      lastConnection?: string;
    };
  };
}
```

**Response Example**:
```json
{
  "success": true,
  "dashboard": {
    "user": {
      "id": "e42a885b-b9e7-45d1-8ec5-9644736b3b9d",
      "firstName": "Effy",
      "lastName": "Setumeni",
      "email": "effysetumeni@outlook.com",
      "profileType": "mentor",
      "profileStatus": "ACTIVE",
      "profileCompletion": 66,
      "hasAnyProfile": true
    },
    "unreadCounts": {
      "messages": 0,
      "activities": 0,
      "connectionRequests": 0,
      "notifications": 0
    },
    "stats": {
      "totalPosts": 0,
      "totalConnections": 2,
      "totalLikes": 0,
      "profileViews": 15
    },
    "recentActivity": {
      "lastLogin": "2025-01-03T10:30:00Z",
      "lastConnection": "2024-07-11T06:22:00Z"
    }
  }
}
```

### **GET /api/v1/dashboard/stats**
**Get detailed user statistics**

```typescript
interface DashboardStatsResponse {
  success: boolean;
  stats: {
    profile: {
      views: number;
      connections: number;
      completionPercentage: number;
      lastUpdated: string;
    };
    content: {
      postsCreated: number;
      likesReceived: number;
      commentsReceived: number;
      sharesReceived: number;
      bookmarksReceived: number;
    };
    engagement: {
      likesGiven: number;
      commentsGiven: number;
      sharesGiven: number;
      bookmarksGiven: number;
      messagesExchanged: number;
    };
    network: {
      connectionsSent: number;
      connectionsReceived: number;
      connectionsAccepted: number;
      networkGrowthRate: number;
    };
    activity: {
      loginStreak: number;
      totalLogins: number;
      averageSessionDuration: number;
      lastActiveDate: string;
    };
  };
}
```

### **GET /api/v1/dashboard/activities**
**Get recent user activities**

```typescript
interface DashboardActivitiesRequest {
  page?: number;
  limit?: number;
  activityTypes?: string[];
  dateRange?: {
    start: string;
    end: string;
  };
}

interface DashboardActivitiesResponse {
  success: boolean;
  activities: Activity[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

interface Activity {
  id: string;
  type: 'connection_accepted' | 'post_created' | 'profile_updated' | 'event_registered' | 'message_sent';
  title: string;
  description: string;
  icon: string;
  timestamp: string;
  metadata?: Record<string, any>;
  relatedUser?: {
    id: string;
    name: string;
    profileType: string;
    avatar?: string;
  };
}
```

### **GET /api/v1/dashboard/recommendations**
**Get personalized recommendations**

```typescript
interface DashboardRecommendationsResponse {
  success: boolean;
  recommendations: {
    connections: UserRecommendation[];
    content: ContentRecommendation[];
    events: EventRecommendation[];
    opportunities: OpportunityRecommendation[];
  };
}

interface UserRecommendation {
  id: string;
  user: {
    id: string;
    name: string;
    profileType: string;
    title?: string;
    avatar?: string;
    location?: string;
  };
  reason: string;
  matchScore: number;
  mutualConnections: number;
}

interface ContentRecommendation {
  id: string;
  type: 'post' | 'article' | 'event' | 'opportunity';
  title: string;
  description: string;
  author: {
    name: string;
    profileType: string;
  };
  reason: string;
  relevanceScore: number;
  engagement: {
    likes: number;
    comments: number;
  };
}
```

### **GET /api/v1/dashboard/quick-actions**
**Get profile-specific quick actions**

```typescript
interface QuickActionsResponse {
  success: boolean;
  actions: QuickAction[];
}

interface QuickAction {
  id: string;
  title: string;
  description: string;
  icon: string;
  action: string;
  url?: string;
  priority: 'high' | 'medium' | 'low';
  category: string;
  profileSpecific: boolean;
}
```

**Response Example for Mentor Profile**:
```json
{
  "success": true,
  "actions": [
    {
      "id": "find-mentees",
      "title": "Find Mentees",
      "description": "Discover innovators seeking mentorship",
      "icon": "people",
      "action": "navigate",
      "url": "/mentorship/opportunities",
      "priority": "high",
      "category": "mentorship",
      "profileSpecific": true
    },
    {
      "id": "schedule-session",
      "title": "Schedule Session",
      "description": "Arrange mentoring meetings",
      "icon": "event",
      "action": "modal",
      "priority": "medium",
      "category": "mentorship",
      "profileSpecific": true
    }
  ]
}
```

## 📱 **Profile-Specific Dashboard APIs**

### **GET /api/v1/dashboard/profile-widgets**
**Get profile type-specific dashboard widgets**

```typescript
interface ProfileWidgetsRequest {
  profileType: string;
  userId: string;
}

interface ProfileWidgetsResponse {
  success: boolean;
  widgets: DashboardWidget[];
}

interface DashboardWidget {
  id: string;
  type: string;
  title: string;
  description: string;
  data: Record<string, any>;
  config: {
    size: 'small' | 'medium' | 'large';
    position: number;
    refreshInterval?: number;
  };
  actions: WidgetAction[];
}

interface WidgetAction {
  id: string;
  label: string;
  icon: string;
  action: string;
  url?: string;
}
```

### **GET /api/v1/dashboard/completion-status**
**Get profile completion status and next steps**

```typescript
interface CompletionStatusResponse {
  success: boolean;
  completion: {
    percentage: number;
    currentStep: number;
    totalSteps: number;
    steps: CompletionStep[];
    nextActions: NextAction[];
  };
}

interface CompletionStep {
  step: number;
  title: string;
  description: string;
  status: 'completed' | 'current' | 'pending';
  icon: string;
  fields?: string[];
}

interface NextAction {
  action: string;
  title: string;
  description: string;
  url: string;
  priority: 'high' | 'medium' | 'low';
  estimatedTime: string;
}
```

## 📊 **Analytics Dashboard APIs**

### **GET /api/v1/dashboard/analytics**
**Get dashboard analytics and insights**

```typescript
interface DashboardAnalyticsRequest {
  timeRange: '7d' | '30d' | '90d' | '1y';
  metrics: string[];
}

interface DashboardAnalyticsResponse {
  success: boolean;
  analytics: {
    overview: {
      totalViews: number;
      totalEngagement: number;
      growthRate: number;
      activeConnections: number;
    };
    trends: {
      profileViews: DataPoint[];
      connectionGrowth: DataPoint[];
      contentEngagement: DataPoint[];
      activityLevel: DataPoint[];
    };
    insights: Insight[];
  };
}

interface DataPoint {
  date: string;
  value: number;
}

interface Insight {
  type: 'growth' | 'engagement' | 'network' | 'content';
  title: string;
  description: string;
  impact: 'positive' | 'negative' | 'neutral';
  actionable: boolean;
  suggestions?: string[];
}
```

## 🔧 **Dashboard Configuration APIs**

### **GET /api/v1/dashboard/preferences**
**Get user dashboard preferences**

```typescript
interface DashboardPreferencesResponse {
  success: boolean;
  preferences: {
    layout: 'default' | 'compact' | 'expanded';
    theme: 'light' | 'dark' | 'auto';
    widgets: {
      enabled: string[];
      order: string[];
      sizes: Record<string, 'small' | 'medium' | 'large'>;
    };
    notifications: {
      showInDashboard: boolean;
      autoRefresh: boolean;
      refreshInterval: number;
    };
    privacy: {
      showActivity: boolean;
      showStats: boolean;
      showRecommendations: boolean;
    };
  };
}
```

### **PUT /api/v1/dashboard/preferences**
**Update dashboard preferences**

```typescript
interface UpdateDashboardPreferencesRequest {
  preferences: Partial<{
    layout: 'default' | 'compact' | 'expanded';
    theme: 'light' | 'dark' | 'auto';
    widgets: {
      enabled: string[];
      order: string[];
      sizes: Record<string, 'small' | 'medium' | 'large'>;
    };
    notifications: {
      showInDashboard: boolean;
      autoRefresh: boolean;
      refreshInterval: number;
    };
    privacy: {
      showActivity: boolean;
      showStats: boolean;
      showRecommendations: boolean;
    };
  }>;
}
```

---

## 📚 **Reference Documents**

**Dashboard Implementation**: See `/3_user_experience_design/4_dashboard_functionality_specification.md`
**Profile Management**: See `/2_technical_architecture/api_specifications/2_profile_management_apis.md`
**User State Management**: See `/2_technical_architecture/api_specifications/7_user_state_management_apis.md`
**Authentication**: See `/2_technical_architecture/api_specifications/1_authentication_apis.md`

*These dashboard APIs provide comprehensive functionality for personalized user dashboards with profile-specific features, analytics, and customization options for the ZbInnovation platform.*
