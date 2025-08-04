# 7. Social Features APIs

## 🤝 **Social Features API Overview**

This document specifies comprehensive social networking and interaction APIs supporting connection management, direct messaging, and social engagement features for the ZbInnovation platform.

## 👥 **Connection Management APIs**

### **POST /api/v1/connections/request**
**Send connection request**

```typescript
interface ConnectionRequestBody {
  targetUserId: string;
  connectionType: 'professional' | 'mentor' | 'collaboration' | 'friendship';
  message?: string;
}

interface ConnectionRequestResponse {
  success: boolean;
  connection: {
    id: string;
    userId: string;
    connectedUserId: string;
    connectionType: string;
    connectionStatus: 'pending' | 'accepted' | 'declined';
    connectionStrength: number;
    message?: string;
    createdAt: string;
  };
}
```

**Request Example**:
```json
{
  "targetUserId": "user-uuid-456",
  "connectionType": "professional",
  "message": "I'd like to connect with you to discuss innovation opportunities."
}
```

### **GET /api/v1/connections**
**Get user connections**

```typescript
interface ConnectionsRequest {
  status?: 'pending' | 'accepted' | 'declined' | 'all';
  type?: 'professional' | 'mentor' | 'collaboration' | 'friendship';
  page?: number;
  limit?: number;
  search?: string;
}

interface ConnectionsResponse {
  success: boolean;
  connections: Connection[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  summary: {
    total: number;
    pending: number;
    accepted: number;
    byType: Record<string, number>;
  };
}

interface Connection {
  id: string;
  user: {
    id: string;
    firstName: string;
    lastName: string;
    profileType: string;
    title?: string;
    avatar?: string;
    location?: string;
  };
  connectionType: string;
  connectionStatus: string;
  connectionStrength: number;
  mutualConnections: number;
  lastInteraction?: string;
  connectedAt: string;
}
```

### **PUT /api/v1/connections/{connectionId}**
**Update connection status**

```typescript
interface UpdateConnectionRequest {
  status: 'accepted' | 'declined';
  message?: string;
}

interface UpdateConnectionResponse {
  success: boolean;
  connection: Connection;
  notification?: {
    sent: boolean;
    type: string;
  };
}
```

### **DELETE /api/v1/connections/{connectionId}**
**Remove connection**

```typescript
interface RemoveConnectionResponse {
  success: boolean;
  message: string;
  removedAt: string;
}
```

### **GET /api/v1/connections/requests**
**Get connection requests**

```typescript
interface ConnectionRequestsRequest {
  type: 'sent' | 'received' | 'all';
  page?: number;
  limit?: number;
}

interface ConnectionRequestsResponse {
  success: boolean;
  requests: ConnectionRequest[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  summary: {
    sent: number;
    received: number;
    pending: number;
  };
}

interface ConnectionRequest {
  id: string;
  requester: {
    id: string;
    name: string;
    profileType: string;
    avatar?: string;
    title?: string;
  };
  target: {
    id: string;
    name: string;
    profileType: string;
  };
  connectionType: string;
  message?: string;
  status: 'pending' | 'accepted' | 'declined';
  createdAt: string;
}
```

## 💬 **Messaging APIs**

### **POST /api/v1/messages**
**Send direct message**

```typescript
interface SendMessageRequest {
  recipientId: string;
  content: string;
  messageType?: 'text' | 'image' | 'file' | 'link';
  attachments?: string[];
  replyToId?: string;
}

interface SendMessageResponse {
  success: boolean;
  message: {
    id: string;
    senderId: string;
    recipientId: string;
    content: string;
    messageType: string;
    attachments: string[];
    replyToId?: string;
    readAt?: string;
    createdAt: string;
  };
}
```

### **GET /api/v1/messages/conversations**
**Get user conversations**

```typescript
interface ConversationsRequest {
  page?: number;
  limit?: number;
  unreadOnly?: boolean;
  search?: string;
}

interface ConversationsResponse {
  success: boolean;
  conversations: Conversation[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  unreadCount: number;
}

interface Conversation {
  id: string;
  participant: {
    id: string;
    name: string;
    avatar?: string;
    profileType: string;
    isOnline: boolean;
    lastSeen?: string;
  };
  lastMessage: {
    id: string;
    content: string;
    senderId: string;
    createdAt: string;
    isRead: boolean;
  };
  unreadCount: number;
  updatedAt: string;
}
```

### **GET /api/v1/messages/conversations/{conversationId}**
**Get conversation messages**

```typescript
interface ConversationMessagesRequest {
  page?: number;
  limit?: number;
  before?: string;
  after?: string;
}

interface ConversationMessagesResponse {
  success: boolean;
  messages: Message[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    hasMore: boolean;
  };
  conversation: {
    id: string;
    participant: {
      id: string;
      name: string;
      avatar?: string;
    };
  };
}

interface Message {
  id: string;
  senderId: string;
  recipientId: string;
  content: string;
  messageType: string;
  attachments: Attachment[];
  replyTo?: {
    id: string;
    content: string;
    senderName: string;
  };
  readAt?: string;
  editedAt?: string;
  createdAt: string;
}

interface Attachment {
  id: string;
  type: 'image' | 'file' | 'link';
  url: string;
  filename: string;
  size: number;
  mimeType: string;
}
```

### **PUT /api/v1/messages/{messageId}/read**
**Mark message as read**

```typescript
interface MarkMessageReadResponse {
  success: boolean;
  message: {
    id: string;
    readAt: string;
  };
  conversationUnreadCount: number;
}
```

### **PUT /api/v1/messages/conversations/{conversationId}/read**
**Mark all messages in conversation as read**

```typescript
interface MarkConversationReadResponse {
  success: boolean;
  conversationId: string;
  messagesMarkedRead: number;
  readAt: string;
}
```

## 🔔 **Social Notifications APIs**

### **GET /api/v1/notifications/social**
**Get social notifications**

```typescript
interface SocialNotificationsRequest {
  types?: ('connection_request' | 'connection_accepted' | 'message' | 'mention' | 'follow')[];
  unreadOnly?: boolean;
  page?: number;
  limit?: number;
}

interface SocialNotificationsResponse {
  success: boolean;
  notifications: SocialNotification[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  unreadCount: number;
}

interface SocialNotification {
  id: string;
  type: 'connection_request' | 'connection_accepted' | 'message' | 'mention' | 'follow';
  title: string;
  message: string;
  actor: {
    id: string;
    name: string;
    avatar?: string;
    profileType: string;
  };
  target?: {
    id: string;
    type: string;
    title?: string;
  };
  actionUrl?: string;
  isRead: boolean;
  createdAt: string;
}
```

## 👤 **User Discovery APIs**

### **GET /api/v1/users/discover**
**Discover users for connections**

```typescript
interface UserDiscoveryRequest {
  profileTypes?: string[];
  location?: string;
  interests?: string[];
  connectionType?: string;
  excludeConnected?: boolean;
  page?: number;
  limit?: number;
}

interface UserDiscoveryResponse {
  success: boolean;
  users: DiscoverableUser[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  filters: {
    profileTypes: string[];
    locations: string[];
    interests: string[];
  };
}

interface DiscoverableUser {
  id: string;
  firstName: string;
  lastName: string;
  profileType: string;
  title?: string;
  bio?: string;
  avatar?: string;
  location?: string;
  interests: string[];
  mutualConnections: number;
  connectionStatus?: 'none' | 'pending' | 'connected';
  matchScore: number;
  lastActive: string;
}
```

### **GET /api/v1/users/{userId}/mutual-connections**
**Get mutual connections with a user**

```typescript
interface MutualConnectionsResponse {
  success: boolean;
  mutualConnections: {
    id: string;
    name: string;
    avatar?: string;
    profileType: string;
    connectionType: string;
  }[];
  count: number;
}
```

## 📊 **Social Analytics APIs**

### **GET /api/v1/social/analytics**
**Get social engagement analytics**

```typescript
interface SocialAnalyticsRequest {
  timeRange: '7d' | '30d' | '90d' | '1y';
  metrics?: ('connections' | 'messages' | 'profile_views' | 'engagement')[];
}

interface SocialAnalyticsResponse {
  success: boolean;
  analytics: {
    overview: {
      totalConnections: number;
      newConnections: number;
      messagesSent: number;
      messagesReceived: number;
      profileViews: number;
    };
    trends: {
      connectionGrowth: DataPoint[];
      messageActivity: DataPoint[];
      profileViews: DataPoint[];
      engagement: DataPoint[];
    };
    insights: {
      topConnectionTypes: { type: string; count: number }[];
      mostActiveConnections: { userId: string; name: string; interactions: number }[];
      networkGrowthRate: number;
      engagementRate: number;
    };
  };
}

interface DataPoint {
  date: string;
  value: number;
}
```

---

## 📚 **Reference Documents**

**User Management**: See `/2_technical_architecture/api_specifications/2_profile_management_apis.md`
**Notifications**: See `/2_technical_architecture/api_specifications/8_notification_system_apis.md`
**Content Management**: See `/2_technical_architecture/api_specifications/3_content_management_apis.md`
**Authentication**: See `/2_technical_architecture/api_specifications/1_authentication_apis.md`

*These social features APIs provide comprehensive functionality for connection management, messaging, user discovery, and social engagement analytics on the ZbInnovation platform.*
