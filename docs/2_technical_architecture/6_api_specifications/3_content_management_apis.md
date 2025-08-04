# 3. Content Management APIs

## 📝 **Content Management Overview**

The Content Management APIs handle all content creation, editing, publishing, and engagement features across the ZbInnovation platform. These APIs support multiple content types, rich media, and comprehensive social interaction features.

## 🏗️ **Content Architecture**

### **Content Type System**
```typescript
enum ContentType {
  GENERAL_POST = 'general_post',
  BLOG_ARTICLE = 'blog_article', 
  ANNOUNCEMENT = 'announcement',
  OPPORTUNITY = 'opportunity',
  SUCCESS_STORY = 'success_story',
  QUESTION = 'question',
  POLL = 'poll',
  EVENT_POST = 'event_post'
}

interface BaseContent {
  contentId: string;
  authorId: string;
  contentType: ContentType;
  title?: string;
  content: string;
  visibility: 'PUBLIC' | 'CONNECTIONS_ONLY' | 'PRIVATE';
  status: 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';
  tags: string[];
  category?: string;
}
```

### **Content Engagement System**
```typescript
interface ContentEngagement {
  likes: number;
  comments: number;
  shares: number;
  views: number;
  saves: number;
  engagementRate: number;
}
```

## 📋 **Core Content Management Endpoints**

### **1. Create New Content**
```http
POST /api/v1/content/posts
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "contentType": "general_post",
  "title": "Exciting Innovation Update",
  "content": "Just reached a major milestone in our AI development...",
  "visibility": "PUBLIC",
  "tags": ["innovation", "AI", "milestone"],
  "category": "Technology",
  "featuredImage": "https://cdn.zbinnovation.com/images/post123.jpg",
  "mediaUrls": [
    "https://cdn.zbinnovation.com/videos/demo.mp4"
  ],
  "scheduledPublishAt": "2024-01-25T10:00:00Z"
}
```

**Response (201 Created)**:
```json
{
  "success": true,
  "message": "Content created successfully",
  "data": {
    "contentId": "uuid-string",
    "authorId": "uuid-author",
    "contentType": "general_post",
    "title": "Exciting Innovation Update",
    "content": "Just reached a major milestone in our AI development...",
    "visibility": "PUBLIC",
    "status": "PUBLISHED",
    "tags": ["innovation", "AI", "milestone"],
    "category": "Technology",
    "featuredImage": "https://cdn.zbinnovation.com/images/post123.jpg",
    "mediaUrls": ["https://cdn.zbinnovation.com/videos/demo.mp4"],
    "engagement": {
      "likes": 0,
      "comments": 0,
      "shares": 0,
      "views": 0,
      "saves": 0
    },
    "createdAt": "2024-01-20T15:30:00Z",
    "publishedAt": "2024-01-20T15:30:00Z"
  }
}
```

### **2. Get User's Content**
```http
GET /api/v1/content/posts
Authorization: Bearer {access-token}
Query Parameters:
- status: Filter by status (draft, published, archived)
- contentType: Filter by content type
- page: Page number
- limit: Results per page
- sortBy: Sort criteria (createdAt, publishedAt, engagement)
- sortOrder: asc or desc
```

**Example Request**:
```http
GET /api/v1/content/posts?status=published&page=1&limit=10&sortBy=publishedAt&sortOrder=desc
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "contentId": "uuid-1",
        "contentType": "general_post",
        "title": "Exciting Innovation Update",
        "content": "Just reached a major milestone...",
        "visibility": "PUBLIC",
        "status": "PUBLISHED",
        "tags": ["innovation", "AI"],
        "category": "Technology",
        "featuredImage": "https://cdn.zbinnovation.com/images/post1.jpg",
        "engagement": {
          "likes": 25,
          "comments": 8,
          "shares": 3,
          "views": 150,
          "saves": 12
        },
        "createdAt": "2024-01-20T15:30:00Z",
        "publishedAt": "2024-01-20T15:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "totalPages": 3
    }
  }
}
```

### **3. Get Specific Content**
```http
GET /api/v1/content/posts/{contentId}
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "contentId": "uuid-string",
    "author": {
      "userId": "uuid-author",
      "firstName": "John",
      "lastName": "Doe",
      "profileType": "innovator",
      "profilePhoto": "https://cdn.zbinnovation.com/photos/author.jpg",
      "isVerified": true
    },
    "contentType": "general_post",
    "title": "Exciting Innovation Update",
    "content": "Just reached a major milestone in our AI development...",
    "visibility": "PUBLIC",
    "status": "PUBLISHED",
    "tags": ["innovation", "AI", "milestone"],
    "category": "Technology",
    "featuredImage": "https://cdn.zbinnovation.com/images/post123.jpg",
    "mediaUrls": ["https://cdn.zbinnovation.com/videos/demo.mp4"],
    "engagement": {
      "likes": 25,
      "comments": 8,
      "shares": 3,
      "views": 150,
      "saves": 12,
      "userEngagement": {
        "hasLiked": false,
        "hasShared": false,
        "hasSaved": true
      }
    },
    "createdAt": "2024-01-20T15:30:00Z",
    "publishedAt": "2024-01-20T15:30:00Z",
    "updatedAt": "2024-01-20T15:30:00Z"
  }
}
```

### **4. Update Content**
```http
PUT /api/v1/content/posts/{contentId}
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "title": "Updated Innovation Milestone",
  "content": "Updated content with more details...",
  "tags": ["innovation", "AI", "milestone", "update"],
  "category": "Technology"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Content updated successfully",
  "data": {
    "contentId": "uuid-string",
    "updatedFields": ["title", "content", "tags"],
    "updatedAt": "2024-01-21T10:15:00Z"
  }
}
```

### **5. Delete Content**
```http
DELETE /api/v1/content/posts/{contentId}
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Content deleted successfully",
  "data": {
    "contentId": "uuid-string",
    "deletedAt": "2024-01-21T11:00:00Z"
  }
}
```

## 👍 **Content Engagement Endpoints**

### **6. Like/Unlike Content**
```http
POST /api/v1/content/posts/{contentId}/like
DELETE /api/v1/content/posts/{contentId}/like
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Content liked successfully",
  "data": {
    "contentId": "uuid-string",
    "liked": true,
    "totalLikes": 26,
    "likedAt": "2024-01-21T12:00:00Z"
  }
}
```

### **7. Add Comment to Content**
```http
POST /api/v1/content/posts/{contentId}/comments
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "content": "Great achievement! Looking forward to seeing more updates.",
  "parentCommentId": null
}
```

**Response (201 Created)**:
```json
{
  "success": true,
  "message": "Comment added successfully",
  "data": {
    "commentId": "uuid-comment",
    "contentId": "uuid-string",
    "authorId": "uuid-commenter",
    "content": "Great achievement! Looking forward to seeing more updates.",
    "parentCommentId": null,
    "likes": 0,
    "replies": 0,
    "createdAt": "2024-01-21T12:30:00Z"
  }
}
```

### **8. Get Content Comments**
```http
GET /api/v1/content/posts/{contentId}/comments
Authorization: Bearer {access-token}
Query Parameters:
- page: Page number
- limit: Results per page
- sortBy: Sort criteria (createdAt, likes)
- sortOrder: asc or desc
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "comments": [
      {
        "commentId": "uuid-comment-1",
        "author": {
          "userId": "uuid-commenter",
          "firstName": "Jane",
          "lastName": "Smith",
          "profilePhoto": "https://cdn.zbinnovation.com/photos/commenter.jpg"
        },
        "content": "Great achievement! Looking forward to seeing more updates.",
        "parentCommentId": null,
        "likes": 3,
        "replies": 1,
        "userHasLiked": false,
        "createdAt": "2024-01-21T12:30:00Z",
        "childComments": [
          {
            "commentId": "uuid-reply-1",
            "author": {
              "userId": "uuid-author",
              "firstName": "John",
              "lastName": "Doe"
            },
            "content": "Thank you for the support!",
            "likes": 1,
            "createdAt": "2024-01-21T13:00:00Z"
          }
        ]
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 8,
      "totalPages": 1
    }
  }
}
```

### **9. Share Content**
```http
POST /api/v1/content/posts/{contentId}/share
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "shareType": "INTERNAL",
  "message": "Check out this amazing innovation!",
  "targetAudience": "PUBLIC"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Content shared successfully",
  "data": {
    "shareId": "uuid-share",
    "contentId": "uuid-string",
    "shareType": "INTERNAL",
    "totalShares": 4,
    "sharedAt": "2024-01-21T14:00:00Z"
  }
}
```

### **10. Save/Bookmark Content**
```http
POST /api/v1/content/posts/{contentId}/save
DELETE /api/v1/content/posts/{contentId}/save
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Content saved successfully",
  "data": {
    "contentId": "uuid-string",
    "saved": true,
    "totalSaves": 13,
    "savedAt": "2024-01-21T14:30:00Z"
  }
}
```

## 📊 **Content Analytics and Management**

### **11. Get Content Analytics**
```http
GET /api/v1/content/analytics
Authorization: Bearer {access-token}
Query Parameters:
- timeRange: Time period (7d, 30d, 90d, 1y)
- contentType: Filter by content type
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "overview": {
      "totalPosts": 25,
      "totalViews": 3500,
      "totalEngagement": 450,
      "averageEngagementRate": 12.8
    },
    "performance": {
      "topPerformingPost": {
        "contentId": "uuid-top",
        "title": "Innovation Breakthrough",
        "views": 500,
        "engagementRate": 25.6
      },
      "engagementTrends": [
        {
          "date": "2024-01-15",
          "views": 120,
          "likes": 15,
          "comments": 8,
          "shares": 3
        }
      ]
    },
    "audience": {
      "topLocations": ["Harare", "Bulawayo", "Mutare"],
      "topProfileTypes": ["innovator", "professional", "mentor"],
      "engagementByTime": {
        "peak_hours": ["09:00", "13:00", "18:00"]
      }
    }
  }
}
```

### **12. Get Draft Content**
```http
GET /api/v1/content/drafts
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "drafts": [
      {
        "contentId": "uuid-draft",
        "title": "Work in Progress Post",
        "content": "This is a draft post...",
        "contentType": "general_post",
        "lastSavedAt": "2024-01-21T10:00:00Z",
        "autoSaved": true
      }
    ],
    "total": 3
  }
}
```

## 🔍 **Content Discovery and Search**

### **13. Search Content**
```http
GET /api/v1/content/search
Authorization: Bearer {access-token}
Query Parameters:
- q: Search query
- contentType: Filter by content type
- category: Filter by category
- tags: Filter by tags
- authorType: Filter by author profile type
- timeRange: Filter by time period
- sortBy: Sort criteria (relevance, date, engagement)
```

**Example Request**:
```http
GET /api/v1/content/search?q=innovation&category=Technology&tags=AI&sortBy=engagement
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "contentId": "uuid-result",
        "title": "AI Innovation Breakthrough",
        "excerpt": "Revolutionary AI technology that will change...",
        "author": {
          "firstName": "John",
          "lastName": "Doe",
          "profileType": "innovator"
        },
        "contentType": "blog_article",
        "category": "Technology",
        "tags": ["AI", "innovation", "technology"],
        "engagement": {
          "likes": 45,
          "comments": 12,
          "views": 300
        },
        "publishedAt": "2024-01-20T10:00:00Z",
        "relevanceScore": 0.95
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 15,
      "totalPages": 1
    },
    "suggestions": {
      "relatedTags": ["machine-learning", "startup", "tech"],
      "relatedCategories": ["Business", "Research"]
    }
  }
}
```

## 📝 **Content Moderation and Quality**

### **Content Validation Rules**
```typescript
interface ContentValidation {
  title: { maxLength: 200, required: false };
  content: { maxLength: 10000, required: true, minLength: 10 };
  tags: { maxCount: 10, maxLength: 30 };
  category: { enum: VALID_CATEGORIES };
  mediaUrls: { maxCount: 5, validFormats: ['jpg', 'png', 'mp4', 'pdf'] };
}
```

### **Content Moderation Features**
- **Automated Content Filtering**: AI-powered inappropriate content detection
- **Community Reporting**: User-driven content reporting system
- **Spam Detection**: Automated spam and duplicate content detection
- **Quality Scoring**: Content quality assessment based on engagement and feedback

### **14. Report Content**
```http
POST /api/v1/content/posts/{contentId}/report
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "reason": "INAPPROPRIATE_CONTENT",
  "description": "Contains offensive language",
  "category": "HARASSMENT"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Content reported successfully",
  "data": {
    "reportId": "uuid-report",
    "status": "UNDER_REVIEW",
    "reportedAt": "2024-01-21T16:00:00Z"
  }
}
```

---

## 📚 **Reference Documents**

**Profile Management**: See `/2_technical_architecture/api_specifications/2_profile_management_apis.md`
**Social Features**: See `/2_technical_architecture/api_specifications/4_social_features_apis.md`
**File Upload**: See `/2_technical_architecture/api_specifications/10_file_media_apis.md`
**Frontend Implementation**: See `/5_frontend_implementation/2_user_interface_implementation.md`

*These content management APIs provide comprehensive content creation, engagement, and discovery features for the ZbInnovation platform.*
