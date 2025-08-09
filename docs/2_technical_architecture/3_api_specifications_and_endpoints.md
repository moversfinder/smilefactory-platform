# 3. API Specifications and Endpoints

## 🔌 **API Architecture Overview**

The ZbInnovation platform provides a comprehensive REST API with 138 endpoints supporting all platform functionality. The API follows RESTful principles with JWT authentication, real-time WebSocket integration, and OpenAPI 3.0 documentation.

## 🏗️ **API Design Principles**

### **RESTful Architecture**
- **HTTP Methods**: Standard GET, POST, PUT, DELETE operations
- **Status Codes**: Consistent HTTP status code usage
- **Resource Naming**: Clear, hierarchical resource naming
- **Versioning**: API versioning through URL path (`/api/v1/`)

### **Authentication and Security**
- **JWT Tokens**: Stateless authentication with refresh tokens
- **Role-Based Access**: User type-specific permissions
- **Rate Limiting**: API usage throttling and protection
- **Input Validation**: Comprehensive request validation

### **Response Format**
**Standard Response Structure**:
- **Success**: Boolean indicating operation success
- **Data**: Response payload containing requested information
- **Message**: Human-readable status message
- **Timestamp**: ISO 8601 formatted timestamp
- **Pagination**: Page information for paginated responses

## 📋 **API Endpoint Categories**

### **1. Authentication APIs (8 endpoints)**
**Base Path**: `/api/v1/auth`

#### **User Registration and Login**
```
POST   /api/v1/auth/register           - User registration
POST   /api/v1/auth/login              - User authentication
POST   /api/v1/auth/logout             - User logout
POST   /api/v1/auth/refresh            - Token refresh
```

#### **Email Verification and Recovery**
```
POST   /api/v1/auth/verify-email       - Email verification
POST   /api/v1/auth/resend-verification - Resend verification email
POST   /api/v1/auth/forgot-password    - Password reset request
POST   /api/v1/auth/reset-password     - Password reset confirmation
```

### **2. Profile Management APIs (15 endpoints)**
**Base Path**: `/api/v1/profiles`

#### **Profile CRUD Operations**
```
GET    /api/v1/profiles/me             - Get current user profile
PUT    /api/v1/profiles/me             - Update current user profile
DELETE /api/v1/profiles/me             - Delete current user profile
GET    /api/v1/profiles/{userId}       - Get user profile by ID
```

#### **Profile Type-Specific Operations**
```
POST   /api/v1/profiles/innovator      - Create innovator profile
PUT    /api/v1/profiles/innovator      - Update innovator profile
POST   /api/v1/profiles/investor       - Create investor profile
PUT    /api/v1/profiles/investor       - Update investor profile
POST   /api/v1/profiles/mentor         - Create mentor profile
PUT    /api/v1/profiles/mentor         - Update mentor profile
POST   /api/v1/profiles/professional   - Create professional profile
PUT    /api/v1/profiles/professional   - Update professional profile
POST   /api/v1/profiles/expert         - Create expert profile
PUT    /api/v1/profiles/expert         - Update expert profile
POST   /api/v1/profiles/student        - Create student profile
PUT    /api/v1/profiles/student        - Update student profile
POST   /api/v1/profiles/institution    - Create institution profile
PUT    /api/v1/profiles/institution    - Update institution profile
POST   /api/v1/profiles/organisation   - Create organisation profile
PUT    /api/v1/profiles/organisation   - Update organisation profile
```

#### **Profile Analytics and Visibility**
```
GET    /api/v1/profiles/analytics      - Profile performance analytics
PUT    /api/v1/profiles/visibility     - Update profile visibility settings
GET    /api/v1/profiles/completion     - Profile completion status
```

### **3. Dashboard APIs (12 endpoints)**
**Base Path**: `/api/v1/dashboard`

#### **Dashboard Content and Personalization**
```
GET    /api/v1/dashboard/overview      - Dashboard overview data
GET    /api/v1/dashboard/feed          - Personalized content feed
GET    /api/v1/dashboard/recommendations - AI-powered recommendations
GET    /api/v1/dashboard/analytics     - User activity analytics
```

#### **Quick Actions and Widgets**
```
GET    /api/v1/dashboard/quick-actions - Profile-specific quick actions
GET    /api/v1/dashboard/widgets       - Dashboard widget configuration
PUT    /api/v1/dashboard/widgets       - Update widget preferences
GET    /api/v1/dashboard/notifications - Recent notifications summary
```

#### **Profile State Management**
```
GET    /api/v1/dashboard/state         - Current user state (new/incomplete/complete)
GET    /api/v1/dashboard/onboarding    - Onboarding progress and next steps
PUT    /api/v1/dashboard/preferences   - Update dashboard preferences
POST   /api/v1/dashboard/tour-complete - Mark platform tour as completed
```

### **4. Virtual Community APIs (29 endpoints)**
**Base Path**: `/api/v1/community`

#### **Feed Tab APIs (6 endpoints)**
```
GET    /api/v1/community/feed          - Get community feed
POST   /api/v1/community/feed/post     - Create new post
GET    /api/v1/community/feed/trending - Get trending content
GET    /api/v1/community/feed/following - Get content from followed users
PUT    /api/v1/community/feed/filter   - Update feed filter preferences
GET    /api/v1/community/feed/search   - Search feed content
```

#### **Profiles Tab APIs (5 endpoints)**
```
GET    /api/v1/community/profiles      - Get user directory
GET    /api/v1/community/profiles/search - Search user profiles
GET    /api/v1/community/profiles/filter - Filter profiles by criteria
GET    /api/v1/community/profiles/suggestions - Get profile suggestions
GET    /api/v1/community/profiles/featured - Get featured profiles
```

#### **Blog Tab APIs (6 endpoints)**
```
GET    /api/v1/community/blog          - Get blog articles
POST   /api/v1/community/blog/article  - Create new article
GET    /api/v1/community/blog/categories - Get article categories
GET    /api/v1/community/blog/trending - Get trending articles
GET    /api/v1/community/blog/search   - Search blog content
GET    /api/v1/community/blog/{id}     - Get specific article
```

#### **Events Tab APIs (6 endpoints)**
```
GET    /api/v1/community/events        - Get upcoming events
POST   /api/v1/community/events        - Create new event
GET    /api/v1/community/events/{id}   - Get specific event
PUT    /api/v1/community/events/{id}   - Update event
POST   /api/v1/community/events/{id}/register - Register for event
DELETE /api/v1/community/events/{id}/register - Cancel event registration
```

#### **Groups Tab APIs (3 endpoints)**
```
GET    /api/v1/community/groups        - Get available groups
POST   /api/v1/community/groups        - Create new group
GET    /api/v1/community/groups/{id}   - Get specific group details
```

#### **Marketplace Tab APIs (3 endpoints)**
```
GET    /api/v1/community/marketplace   - Get marketplace listings
POST   /api/v1/community/marketplace   - Create new listing
GET    /api/v1/community/marketplace/{id} - Get specific listing
```

### **5. Content Management APIs (12 endpoints)**
**Base Path**: `/api/v1/content`

#### **Content CRUD Operations**
```
GET    /api/v1/content/posts           - Get user's posts
POST   /api/v1/content/posts           - Create new post
GET    /api/v1/content/posts/{id}      - Get specific post
PUT    /api/v1/content/posts/{id}      - Update post
DELETE /api/v1/content/posts/{id}      - Delete post
```

#### **Content Engagement**
```
POST   /api/v1/content/posts/{id}/like - Like/unlike post
POST   /api/v1/content/posts/{id}/comment - Add comment to post
POST   /api/v1/content/posts/{id}/share - Share post
POST   /api/v1/content/posts/{id}/save - Save/bookmark post
```

#### **Content Analytics**
```
GET    /api/v1/content/analytics       - Content performance analytics
GET    /api/v1/content/drafts          - Get draft content
PUT    /api/v1/content/drafts/{id}     - Update draft content
```

### **6. Social Features APIs (12 endpoints)**
**Base Path**: `/api/v1/social`

#### **Connection Management**
```
GET    /api/v1/social/connections      - Get user connections
POST   /api/v1/social/connections/request - Send connection request
PUT    /api/v1/social/connections/{id}/accept - Accept connection request
PUT    /api/v1/social/connections/{id}/decline - Decline connection request
DELETE /api/v1/social/connections/{id} - Remove connection
```

#### **Messaging System**
```
GET    /api/v1/social/messages         - Get message conversations
POST   /api/v1/social/messages         - Send new message
GET    /api/v1/social/messages/{conversationId} - Get conversation messages
PUT    /api/v1/social/messages/{id}/read - Mark message as read
```

#### **Social Interactions**
```
GET    /api/v1/social/followers        - Get followers list
POST   /api/v1/social/follow/{userId}  - Follow user
DELETE /api/v1/social/follow/{userId} - Unfollow user
GET    /api/v1/social/activity         - Get social activity feed
```

### **7. AI Integration APIs (7 endpoints)**
**Base Path**: `/api/v1/ai`

#### **AI Assistant and Recommendations**
```
POST   /api/v1/ai/chat                 - AI chat conversation
GET    /api/v1/ai/recommendations      - Get AI recommendations
POST   /api/v1/ai/match                - AI-powered matching
GET    /api/v1/ai/suggestions          - Get AI suggestions
```

#### **AI Learning and Optimization**
```
POST   /api/v1/ai/feedback             - Provide AI feedback
GET    /api/v1/ai/insights             - Get AI-generated insights
PUT    /api/v1/ai/preferences          - Update AI preferences
```

### **8. Search and Filtering APIs (12 endpoints)**
**Base Path**: `/api/v1/search`

#### **Global Search**
```
GET    /api/v1/search/global           - Global platform search
GET    /api/v1/search/users            - Search users
GET    /api/v1/search/content          - Search content
GET    /api/v1/search/events           - Search events
```

#### **Advanced Filtering**
```
POST   /api/v1/search/filter           - Apply advanced filters
GET    /api/v1/search/suggestions      - Get search suggestions
GET    /api/v1/search/trending         - Get trending searches
PUT    /api/v1/search/preferences      - Update search preferences
```

#### **Search Analytics**
```
GET    /api/v1/search/history          - Get search history
POST   /api/v1/search/save             - Save search query
DELETE /api/v1/search/history/{id}     - Delete search history item
GET    /api/v1/search/analytics        - Search performance analytics
```

## 🔄 **Real-Time Features**

### **WebSocket Integration**
**Base Path**: `/ws`

#### **Real-Time Endpoints**
```
/ws/notifications                       - Real-time notifications
/ws/messages                           - Real-time messaging
/ws/activity                           - Live activity updates
/ws/presence                           - User presence status
```

### **WebSocket Event Types**
- **notification**: New notifications
- **message**: Direct messages
- **activity**: Platform activity updates
- **presence**: User online/offline status
- **typing**: Typing indicators
- **connection**: Connection requests and updates

---

## 📚 **Reference Documents**

**Complete API Documentation**: See `/COMPLETE_API_DOCUMENTATION.md` for detailed endpoint specifications
**Authentication Details**: See `/api-specifications/authentication-apis.md`
**Database Integration**: See `/2_technical_architecture/2_database_schema_and_design.md`
**Frontend Integration**: See `/5_frontend_implementation/` for API consumption patterns

*This API specification provides the complete technical foundation for all platform functionality and integrations.*
