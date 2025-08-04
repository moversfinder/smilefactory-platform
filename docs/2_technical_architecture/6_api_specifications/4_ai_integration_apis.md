# 4. AI Integration APIs

## 🤖 **AI Integration API Overview**

This document outlines the comprehensive AI integration APIs for the ZbInnovation platform, including chat functionality, context building, matchmaking, content suggestions, and conversation management using DeepSeek API integration.

## 🔄 **AI Chat APIs**

### **POST /api/v1/ai/chat**
**Stream AI conversation with context awareness**

```typescript
interface AIChatRequest {
  message: string;
  conversationId?: string;
  currentPage?: string;
  pageContext?: Record<string, any>;
  includeContext?: boolean;
  responseStyle?: 'concise' | 'detailed' | 'balanced';
}

interface AIChatResponse {
  conversationId: string;
  response: string;
  suggestions?: string[];
  quickReplies?: QuickReply[];
  contextUsed: string[];
  tokensUsed: number;
  responseTime: number;
}

interface QuickReply {
  id: string;
  text: string;
  action?: string;
  icon?: string;
}
```

**Request Example:**
```json
{
  "message": "Help me find funding opportunities for my AI startup",
  "currentPage": "dashboard",
  "pageContext": {
    "profileCompletion": 75,
    "profileType": "innovator",
    "industry": "technology"
  },
  "includeContext": true,
  "responseStyle": "balanced"
}
```

**Response Example (Streaming):**
```
data: {"type": "start", "conversationId": "conv_123"}

data: {"type": "content", "content": "Based on your AI startup profile, I can help you discover relevant funding opportunities. "}

data: {"type": "content", "content": "Here are some tailored suggestions:\n\n1. **Tech Innovation Fund** - Specifically for AI startups in Zimbabwe"}

data: {"type": "suggestions", "suggestions": ["Find investors in AI", "Connect with other AI founders", "Review my pitch deck"]}

data: {"type": "quick_replies", "quickReplies": [{"id": "find_investors", "text": "Find AI Investors", "icon": "💰"}, {"id": "connect_founders", "text": "Connect with Founders", "icon": "🤝"}]}

data: {"type": "end", "tokensUsed": 245, "responseTime": 1250}
```

### **POST /api/v1/ai/context**
**Build and retrieve user context for AI interactions**

```typescript
interface AIContextRequest {
  userId: string;
  contextTypes: ('profile' | 'activity' | 'connections' | 'preferences' | 'content')[];
  timeRange?: {
    start: string;
    end: string;
  };
  includeEmbeddings?: boolean;
}

interface AIContextResponse {
  userId: string;
  context: {
    profile?: UserProfileContext;
    activity?: UserActivityContext;
    connections?: ConnectionContext;
    preferences?: UserPreferences;
    content?: ContentContext;
  };
  contextSummary: string;
  relevanceScore: number;
  generatedAt: string;
}
```

**Request Example:**
```json
{
  "userId": "user_123",
  "contextTypes": ["profile", "activity", "connections"],
  "timeRange": {
    "start": "2024-01-01T00:00:00Z",
    "end": "2024-01-31T23:59:59Z"
  },
  "includeEmbeddings": false
}
```

## 🎯 **AI Matchmaking APIs**

### **POST /api/v1/ai/matchmaking**
**AI-powered user and opportunity matching**

```typescript
interface AIMatchmakingRequest {
  userId: string;
  matchType: 'investors' | 'mentors' | 'cofounders' | 'opportunities' | 'events';
  criteria?: {
    industry?: string[];
    stage?: string[];
    location?: string[];
    investmentRange?: {
      min: number;
      max: number;
    };
    expertiseAreas?: string[];
  };
  limit?: number;
  includeReasons?: boolean;
}

interface AIMatchmakingResponse {
  matches: AIMatch[];
  totalMatches: number;
  matchingCriteria: string[];
  generatedAt: string;
}

interface AIMatch {
  id: string;
  type: 'user' | 'opportunity' | 'event';
  matchScore: number;
  matchReasons: string[];
  entity: UserProfile | Opportunity | Event;
  suggestedActions: SuggestedAction[];
}

interface SuggestedAction {
  action: 'connect' | 'message' | 'apply' | 'attend' | 'follow';
  text: string;
  priority: 'high' | 'medium' | 'low';
}
```

**Request Example:**
```json
{
  "userId": "user_123",
  "matchType": "investors",
  "criteria": {
    "industry": ["technology", "fintech"],
    "stage": ["seed", "series-a"],
    "investmentRange": {
      "min": 50000,
      "max": 500000
    }
  },
  "limit": 10,
  "includeReasons": true
}
```

### **POST /api/v1/ai/content-suggestions**
**Generate AI-powered content suggestions**

```typescript
interface AIContentSuggestionsRequest {
  userId: string;
  contentType: 'post' | 'article' | 'comment' | 'message';
  context?: {
    topic?: string;
    audience?: string;
    purpose?: string;
    currentContent?: string;
  };
  count?: number;
}

interface AIContentSuggestionsResponse {
  suggestions: ContentSuggestion[];
  generatedAt: string;
}

interface ContentSuggestion {
  id: string;
  title?: string;
  content: string;
  tags: string[];
  estimatedEngagement: 'high' | 'medium' | 'low';
  reasoning: string;
}
```

## 🧠 **AI Profile Assistance APIs**

### **POST /api/v1/ai/profile-assistance**
**Get AI guidance for profile optimization**

```typescript
interface AIProfileAssistanceRequest {
  userId: string;
  assistanceType: 'completion' | 'optimization' | 'visibility' | 'networking';
  currentSection?: string;
}

interface AIProfileAssistanceResponse {
  recommendations: ProfileRecommendation[];
  completionScore: number;
  priorityActions: PriorityAction[];
  estimatedImpact: {
    visibility: number;
    networking: number;
    opportunities: number;
  };
}

interface ProfileRecommendation {
  section: string;
  recommendation: string;
  importance: 'critical' | 'high' | 'medium' | 'low';
  estimatedTimeToComplete: string;
  examples?: string[];
}

interface PriorityAction {
  action: string;
  description: string;
  impact: number;
  effort: number;
  quickWin: boolean;
}
```

## 📚 **AI Conversation Management APIs**

### **GET /api/v1/ai/conversations**
**Retrieve user's AI conversation history**

```typescript
interface AIConversationsRequest {
  userId: string;
  page?: number;
  limit?: number;
  dateRange?: {
    start: string;
    end: string;
  };
  includeMessages?: boolean;
}

interface AIConversationsResponse {
  conversations: AIConversation[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

interface AIConversation {
  id: string;
  startedAt: string;
  endedAt?: string;
  status: 'active' | 'completed' | 'error';
  messageCount: number;
  totalTokens: number;
  summary?: string;
  messages?: AIMessage[];
}
```

### **GET /api/v1/ai/conversations/{conversationId}/messages**
**Get messages from a specific conversation**

```typescript
interface AIMessagesResponse {
  conversationId: string;
  messages: AIMessage[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
}

interface AIMessage {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: string;
  tokensUsed?: number;
  responseTime?: number;
  metadata?: Record<string, any>;
}
```

### **POST /api/v1/ai/conversations/{conversationId}/feedback**
**Provide feedback on AI responses**

```typescript
interface AIFeedbackRequest {
  messageId: string;
  rating: 1 | 2 | 3 | 4 | 5;
  feedback?: string;
  categories?: ('helpful' | 'accurate' | 'relevant' | 'clear' | 'actionable')[];
}

interface AIFeedbackResponse {
  success: boolean;
  message: string;
  feedbackId: string;
}
```

## 📊 **AI Analytics APIs**

### **GET /api/v1/ai/insights**
**Get AI-powered user insights and analytics**

```typescript
interface AIInsightsRequest {
  userId: string;
  insightTypes: ('engagement' | 'networking' | 'opportunities' | 'growth')[];
  timeRange?: {
    start: string;
    end: string;
  };
}

interface AIInsightsResponse {
  insights: AIInsight[];
  summary: string;
  recommendations: string[];
  generatedAt: string;
}

interface AIInsight {
  type: string;
  title: string;
  description: string;
  value: number | string;
  trend: 'up' | 'down' | 'stable';
  significance: 'high' | 'medium' | 'low';
  actionable: boolean;
  suggestedActions?: string[];
}
```

## 🔧 **AI Configuration APIs**

### **GET /api/v1/ai/preferences**
**Get user's AI preferences**

```typescript
interface AIPreferencesResponse {
  userId: string;
  preferences: {
    aiEnabled: boolean;
    responseStyle: 'concise' | 'detailed' | 'balanced';
    contextAwarenessLevel: 'minimal' | 'moderate' | 'full';
    quickRepliesEnabled: boolean;
    profileAssistanceEnabled: boolean;
    notificationPreferences: {
      aiSuggestions: boolean;
      conversationSummaries: boolean;
      weeklyInsights: boolean;
    };
  };
}
```

### **PUT /api/v1/ai/preferences**
**Update user's AI preferences**

```typescript
interface UpdateAIPreferencesRequest {
  preferences: Partial<{
    aiEnabled: boolean;
    responseStyle: 'concise' | 'detailed' | 'balanced';
    contextAwarenessLevel: 'minimal' | 'moderate' | 'full';
    quickRepliesEnabled: boolean;
    profileAssistanceEnabled: boolean;
    notificationPreferences: {
      aiSuggestions: boolean;
      conversationSummaries: boolean;
      weeklyInsights: boolean;
    };
  }>;
}
```

## 🚨 **Error Handling**

### **AI Service Error Responses**
```typescript
interface AIErrorResponse {
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
    retryable: boolean;
    retryAfter?: number;
  };
  requestId: string;
  timestamp: string;
}
```

**Common Error Codes:**
- `AI_SERVICE_UNAVAILABLE` - DeepSeek API is temporarily unavailable
- `CONTEXT_BUILD_FAILED` - Failed to build user context
- `RATE_LIMIT_EXCEEDED` - Too many AI requests
- `INVALID_CONVERSATION` - Conversation not found or expired
- `INSUFFICIENT_CONTEXT` - Not enough context for meaningful response
- `TOKEN_LIMIT_EXCEEDED` - Request exceeds token limits

---

## 📚 **Reference Documents**

**AI Implementation**: See `/4_backend_implementation/6_ai_integration_implementation.md`
**Database Schema**: See `/2_technical_architecture/2_database_schema_and_design.md`
**Frontend Integration**: See `/5_frontend_implementation/4_state_management_implementation.md`
**Authentication**: See `/2_technical_architecture/api_specifications/1_authentication_apis.md`

*These AI integration APIs provide comprehensive AI-powered assistance with context awareness, streaming responses, and intelligent recommendations for the ZbInnovation platform.*
