# 8. Notification System APIs

## 🔔 **Notification System Overview**

This document specifies comprehensive notification system APIs supporting real-time notifications, preferences management, and multi-channel delivery (in-app, email, push) for the ZbInnovation platform.

## 📱 **Notification Types**

### **Social Notifications**
- **Connection Requests** - New connection requests received
- **Connection Accepted** - Connection requests accepted
- **Messages** - New direct messages received
- **Mentions** - User mentioned in posts or comments

### **Content Notifications**
- **Post Likes** - Someone liked user's post
- **Post Comments** - Someone commented on user's post
- **Post Shares** - Someone shared user's post
- **Content Saved** - Someone saved user's content

### **Activity Notifications**
- **Event Registrations** - Someone registered for user's event
- **Group Joins** - Someone joined user's group
- **Profile Views** - Someone viewed user's profile
- **Marketplace Inquiries** - Someone inquired about user's listing

### **System Notifications**
- **Platform Updates** - New features, maintenance notices
- **Security Alerts** - Login attempts, password changes
- **Account Updates** - Profile completion reminders
- **AI Recommendations** - Personalized suggestions

## 🔔 **Core Notification APIs**

### **GET /api/v1/notifications**
**Get user notifications**

```typescript
interface NotificationsRequest {
  page?: number;
  limit?: number;
  type?: 'all' | 'social' | 'content' | 'activity' | 'system';
  unreadOnly?: boolean;
  category?: string;
  dateRange?: {
    start: string;
    end: string;
  };
}

interface NotificationsResponse {
  success: boolean;
  notifications: Notification[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  summary: {
    total: number;
    unread: number;
    byType: Record<string, number>;
  };
}

interface Notification {
  id: string;
  type: string;
  category: 'social' | 'content' | 'activity' | 'system';
  title: string;
  message: string;
  icon?: string;
  imageUrl?: string;
  actor?: {
    id: string;
    name: string;
    avatar?: string;
    profileType: string;
  };
  target?: {
    id: string;
    type: string;
    title?: string;
    url?: string;
  };
  actionUrl?: string;
  actionText?: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  channels: ('in_app' | 'email' | 'push')[];
  isRead: boolean;
  readAt?: string;
  createdAt: string;
  expiresAt?: string;
  metadata?: Record<string, any>;
}
```

**Response Example**:
```json
{
  "success": true,
  "notifications": [
    {
      "id": "notif-uuid-123",
      "type": "connection_request",
      "category": "social",
      "title": "New Connection Request",
      "message": "John Doe wants to connect with you",
      "icon": "people",
      "actor": {
        "id": "user-uuid-456",
        "name": "John Doe",
        "avatar": "https://storage.example.com/avatars/john.jpg",
        "profileType": "innovator"
      },
      "actionUrl": "/connections/requests",
      "actionText": "View Request",
      "priority": "medium",
      "channels": ["in_app", "email"],
      "isRead": false,
      "createdAt": "2024-01-20T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  },
  "summary": {
    "total": 45,
    "unread": 12,
    "byType": {
      "social": 15,
      "content": 20,
      "activity": 8,
      "system": 2
    }
  }
}
```

### **PUT /api/v1/notifications/{notificationId}/read**
**Mark notification as read**

```typescript
interface MarkNotificationReadResponse {
  success: boolean;
  notification: {
    id: string;
    isRead: boolean;
    readAt: string;
  };
  unreadCount: number;
}
```

### **PUT /api/v1/notifications/mark-all-read**
**Mark all notifications as read**

```typescript
interface MarkAllNotificationsReadRequest {
  type?: 'all' | 'social' | 'content' | 'activity' | 'system';
  olderThan?: string;
}

interface MarkAllNotificationsReadResponse {
  success: boolean;
  markedCount: number;
  readAt: string;
  remainingUnread: number;
}
```

### **DELETE /api/v1/notifications/{notificationId}**
**Delete notification**

```typescript
interface DeleteNotificationResponse {
  success: boolean;
  message: string;
  deletedAt: string;
}
```

### **POST /api/v1/notifications/bulk-action**
**Perform bulk actions on notifications**

```typescript
interface BulkNotificationActionRequest {
  notificationIds: string[];
  action: 'read' | 'unread' | 'delete';
}

interface BulkNotificationActionResponse {
  success: boolean;
  processedCount: number;
  failedCount: number;
  errors?: string[];
}
```

## ⚙️ **Notification Preferences APIs**

### **GET /api/v1/notifications/preferences**
**Get notification preferences**

```typescript
interface NotificationPreferencesResponse {
  success: boolean;
  preferences: {
    global: {
      enabled: boolean;
      quietHours: {
        enabled: boolean;
        start: string; // "22:00"
        end: string;   // "08:00"
        timezone: string;
      };
      frequency: 'immediate' | 'hourly' | 'daily' | 'weekly';
    };
    channels: {
      inApp: {
        enabled: boolean;
        types: string[];
      };
      email: {
        enabled: boolean;
        types: string[];
        frequency: 'immediate' | 'daily_digest' | 'weekly_digest';
      };
      push: {
        enabled: boolean;
        types: string[];
        deviceTokens: string[];
      };
    };
    categories: {
      social: {
        enabled: boolean;
        priority: 'low' | 'medium' | 'high';
        channels: string[];
      };
      content: {
        enabled: boolean;
        priority: 'low' | 'medium' | 'high';
        channels: string[];
      };
      activity: {
        enabled: boolean;
        priority: 'low' | 'medium' | 'high';
        channels: string[];
      };
      system: {
        enabled: boolean;
        priority: 'low' | 'medium' | 'high';
        channels: string[];
      };
    };
    specific: {
      connectionRequests: boolean;
      messages: boolean;
      postLikes: boolean;
      postComments: boolean;
      eventReminders: boolean;
      profileViews: boolean;
      aiRecommendations: boolean;
      securityAlerts: boolean;
    };
  };
}
```

### **PUT /api/v1/notifications/preferences**
**Update notification preferences**

```typescript
interface UpdateNotificationPreferencesRequest {
  preferences: Partial<{
    global: {
      enabled: boolean;
      quietHours: {
        enabled: boolean;
        start: string;
        end: string;
        timezone: string;
      };
      frequency: 'immediate' | 'hourly' | 'daily' | 'weekly';
    };
    channels: {
      inApp: {
        enabled: boolean;
        types: string[];
      };
      email: {
        enabled: boolean;
        types: string[];
        frequency: 'immediate' | 'daily_digest' | 'weekly_digest';
      };
      push: {
        enabled: boolean;
        types: string[];
      };
    };
    categories: Record<string, {
      enabled: boolean;
      priority: 'low' | 'medium' | 'high';
      channels: string[];
    }>;
    specific: Record<string, boolean>;
  }>;
}

interface UpdateNotificationPreferencesResponse {
  success: boolean;
  preferences: NotificationPreferences;
  message: string;
}
```

## 📊 **Notification Analytics APIs**

### **GET /api/v1/notifications/analytics**
**Get notification analytics**

```typescript
interface NotificationAnalyticsRequest {
  timeRange: '7d' | '30d' | '90d' | '1y';
  groupBy?: 'day' | 'week' | 'month';
}

interface NotificationAnalyticsResponse {
  success: boolean;
  analytics: {
    overview: {
      totalSent: number;
      totalRead: number;
      readRate: number;
      averageReadTime: number;
    };
    byType: {
      type: string;
      sent: number;
      read: number;
      readRate: number;
    }[];
    byChannel: {
      channel: string;
      sent: number;
      delivered: number;
      opened: number;
      deliveryRate: number;
      openRate: number;
    }[];
    trends: {
      sent: DataPoint[];
      read: DataPoint[];
      readRate: DataPoint[];
    };
    engagement: {
      mostEngagingTypes: string[];
      leastEngagingTypes: string[];
      peakHours: number[];
      optimalFrequency: string;
    };
  };
}

interface DataPoint {
  date: string;
  value: number;
}
```

## 🔄 **Real-time Notification APIs**

### **WebSocket: /ws/notifications**
**Real-time notification stream**

```typescript
interface NotificationWebSocketMessage {
  type: 'notification' | 'read_update' | 'count_update' | 'preference_update';
  data: {
    notification?: Notification;
    notificationId?: string;
    unreadCount?: number;
    preferences?: NotificationPreferences;
  };
  timestamp: string;
}

// Client subscription message
interface NotificationSubscription {
  action: 'subscribe' | 'unsubscribe';
  types?: string[];
  categories?: string[];
}
```

### **POST /api/v1/notifications/push/register**
**Register push notification device**

```typescript
interface RegisterPushDeviceRequest {
  deviceToken: string;
  platform: 'ios' | 'android' | 'web';
  deviceInfo?: {
    model?: string;
    osVersion?: string;
    appVersion?: string;
  };
}

interface RegisterPushDeviceResponse {
  success: boolean;
  deviceId: string;
  registered: boolean;
  message: string;
}
```

### **DELETE /api/v1/notifications/push/unregister**
**Unregister push notification device**

```typescript
interface UnregisterPushDeviceRequest {
  deviceToken: string;
}

interface UnregisterPushDeviceResponse {
  success: boolean;
  unregistered: boolean;
  message: string;
}
```

---

## 📚 **Reference Documents**

**Social Features**: See `/2_technical_architecture/api_specifications/7_social_features_apis.md`
**User Management**: See `/2_technical_architecture/api_specifications/2_profile_management_apis.md`
**Content Management**: See `/2_technical_architecture/api_specifications/3_content_management_apis.md`
**Real-time Features**: See `/4_backend_implementation/5_real_time_features_implementation.md`

*These notification system APIs provide comprehensive functionality for multi-channel notifications, user preferences, real-time delivery, and analytics for the ZbInnovation platform.*
