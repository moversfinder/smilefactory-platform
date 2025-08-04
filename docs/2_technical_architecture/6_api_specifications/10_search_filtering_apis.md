# 10. Search & Filtering APIs

## 🔍 **Search & Filtering Overview**

This document specifies comprehensive search and content discovery APIs that help users find content, people, and opportunities across the ZbInnovation platform quickly and efficiently.

## 🌐 **Global Search APIs**

### **GET /api/v1/search/global**
**Global platform search**

```typescript
interface GlobalSearchRequest {
  q: string; // Search query
  types?: ('posts' | 'profiles' | 'events' | 'groups' | 'listings' | 'documents')[];
  filters?: {
    location?: string;
    profileType?: string;
    dateRange?: {
      start: string;
      end: string;
    };
    tags?: string[];
    category?: string;
  };
  page?: number;
  limit?: number;
  sortBy?: 'relevance' | 'date' | 'popularity' | 'alphabetical';
  sortOrder?: 'asc' | 'desc';
}

interface GlobalSearchResponse {
  success: boolean;
  query: string;
  results: {
    posts: SearchResult[];
    profiles: SearchResult[];
    events: SearchResult[];
    groups: SearchResult[];
    listings: SearchResult[];
    documents: SearchResult[];
  };
  totalResults: number;
  searchTime: number;
  suggestions: string[];
  filters: {
    locations: string[];
    profileTypes: string[];
    categories: string[];
    tags: string[];
  };
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

interface SearchResult {
  id: string;
  type: 'post' | 'profile' | 'event' | 'group' | 'listing' | 'document';
  title: string;
  description: string;
  url: string;
  imageUrl?: string;
  relevanceScore: number;
  highlights: string[];
  metadata: {
    author?: {
      id: string;
      name: string;
      profileType: string;
      avatar?: string;
    };
    createdAt?: string;
    location?: string;
    category?: string;
    tags?: string[];
    engagement?: {
      likes: number;
      comments: number;
      views: number;
    };
  };
}
```

**Request Example**:
```
GET /api/v1/search/global?q=blockchain%20innovation&types=posts,profiles&limit=20&sortBy=relevance
```

**Response Example**:
```json
{
  "success": true,
  "query": "blockchain innovation",
  "results": {
    "posts": [
      {
        "id": "post-uuid-123",
        "type": "post",
        "title": "Blockchain Innovation in Zimbabwe",
        "description": "Exploring the potential of blockchain technology...",
        "url": "/posts/post-uuid-123",
        "relevanceScore": 0.95,
        "highlights": [
          "Blockchain <mark>innovation</mark> is transforming..."
        ],
        "metadata": {
          "author": {
            "id": "user-uuid-456",
            "name": "John Doe",
            "profileType": "innovator",
            "avatar": "https://storage.example.com/avatars/john.jpg"
          },
          "createdAt": "2024-01-20T09:15:00Z",
          "tags": ["blockchain", "innovation", "technology"],
          "engagement": {
            "likes": 25,
            "comments": 8,
            "views": 150
          }
        }
      }
    ],
    "profiles": [
      {
        "id": "user-uuid-789",
        "type": "profile",
        "title": "Sarah Johnson - Blockchain Expert",
        "description": "Blockchain expert with 10 years experience...",
        "url": "/profiles/user-uuid-789",
        "relevanceScore": 0.89,
        "highlights": [
          "Expert in <mark>blockchain</mark> and <mark>innovation</mark>"
        ],
        "metadata": {
          "profileType": "industry_expert",
          "location": "Harare, Zimbabwe",
          "tags": ["blockchain", "fintech", "innovation"]
        }
      }
    ]
  },
  "totalResults": 47,
  "searchTime": 0.15,
  "suggestions": ["blockchain technology", "innovation hub", "fintech innovation"],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 47,
    "totalPages": 3
  }
}
```

### **GET /api/v1/search/suggestions**
**Get search suggestions**

```typescript
interface SearchSuggestionsRequest {
  q: string;
  types?: string[];
  limit?: number;
}

interface SearchSuggestionsResponse {
  success: boolean;
  query: string;
  suggestions: {
    queries: string[];
    entities: {
      type: string;
      name: string;
      id: string;
      avatar?: string;
    }[];
    tags: string[];
    categories: string[];
  };
}
```

## 👥 **User Search APIs**

### **GET /api/v1/search/users**
**Search users and profiles**

```typescript
interface UserSearchRequest {
  q?: string;
  profileTypes?: string[];
  location?: string;
  skills?: string[];
  interests?: string[];
  connectionStatus?: 'none' | 'connected' | 'pending';
  isOnline?: boolean;
  hasProfilePhoto?: boolean;
  page?: number;
  limit?: number;
  sortBy?: 'relevance' | 'name' | 'lastActive' | 'profileCompletion';
}

interface UserSearchResponse {
  success: boolean;
  users: UserSearchResult[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  filters: {
    profileTypes: { type: string; count: number }[];
    locations: { location: string; count: number }[];
    skills: { skill: string; count: number }[];
  };
}

interface UserSearchResult {
  id: string;
  firstName: string;
  lastName: string;
  displayName: string;
  profileType: string;
  title?: string;
  bio?: string;
  avatar?: string;
  location?: string;
  skills: string[];
  interests: string[];
  connectionStatus: 'none' | 'connected' | 'pending';
  mutualConnections: number;
  profileCompletion: number;
  isOnline: boolean;
  lastActive: string;
  relevanceScore: number;
  highlights: string[];
}
```

## 📝 **Content Search APIs**

### **GET /api/v1/search/content**
**Search posts and content**

```typescript
interface ContentSearchRequest {
  q?: string;
  contentTypes?: ('post' | 'article' | 'announcement' | 'opportunity')[];
  authors?: string[];
  tags?: string[];
  categories?: string[];
  dateRange?: {
    start: string;
    end: string;
  };
  hasMedia?: boolean;
  minEngagement?: number;
  page?: number;
  limit?: number;
  sortBy?: 'relevance' | 'date' | 'popularity' | 'engagement';
}

interface ContentSearchResponse {
  success: boolean;
  content: ContentSearchResult[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  aggregations: {
    byType: { type: string; count: number }[];
    byAuthor: { authorId: string; authorName: string; count: number }[];
    byTag: { tag: string; count: number }[];
    byDate: { date: string; count: number }[];
  };
}

interface ContentSearchResult {
  id: string;
  type: string;
  title: string;
  content: string;
  excerpt: string;
  author: {
    id: string;
    name: string;
    profileType: string;
    avatar?: string;
  };
  tags: string[];
  category?: string;
  mediaCount: number;
  engagement: {
    likes: number;
    comments: number;
    shares: number;
    views: number;
  };
  createdAt: string;
  updatedAt: string;
  relevanceScore: number;
  highlights: string[];
}
```

## 📅 **Event Search APIs**

### **GET /api/v1/search/events**
**Search events**

```typescript
interface EventSearchRequest {
  q?: string;
  eventTypes?: string[];
  location?: string;
  dateRange?: {
    start: string;
    end: string;
  };
  priceRange?: {
    min: number;
    max: number;
  };
  tags?: string[];
  organizers?: string[];
  registrationStatus?: 'open' | 'closed' | 'waitlist';
  page?: number;
  limit?: number;
  sortBy?: 'relevance' | 'date' | 'popularity' | 'price';
}

interface EventSearchResponse {
  success: boolean;
  events: EventSearchResult[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  filters: {
    eventTypes: { type: string; count: number }[];
    locations: { location: string; count: number }[];
    priceRanges: { range: string; count: number }[];
    organizers: { organizerId: string; organizerName: string; count: number }[];
  };
}

interface EventSearchResult {
  id: string;
  title: string;
  description: string;
  eventType: string;
  startDateTime: string;
  endDateTime: string;
  location?: string;
  virtualMeetingUrl?: string;
  organizer: {
    id: string;
    name: string;
    profileType: string;
    avatar?: string;
  };
  price: number;
  currency: string;
  maxAttendees?: number;
  currentAttendees: number;
  registrationStatus: string;
  tags: string[];
  coverImageUrl?: string;
  relevanceScore: number;
  highlights: string[];
}
```

## 🏪 **Marketplace Search APIs**

### **GET /api/v1/search/marketplace**
**Search marketplace listings**

```typescript
interface MarketplaceSearchRequest {
  q?: string;
  categories?: string[];
  listingTypes?: string[];
  location?: string;
  priceRange?: {
    min: number;
    max: number;
  };
  condition?: string[];
  sellers?: string[];
  tags?: string[];
  availability?: 'available' | 'sold' | 'reserved';
  page?: number;
  limit?: number;
  sortBy?: 'relevance' | 'price' | 'date' | 'popularity';
}

interface MarketplaceSearchResponse {
  success: boolean;
  listings: MarketplaceSearchResult[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  filters: {
    categories: { category: string; count: number }[];
    listingTypes: { type: string; count: number }[];
    locations: { location: string; count: number }[];
    priceRanges: { range: string; count: number }[];
  };
}

interface MarketplaceSearchResult {
  id: string;
  title: string;
  description: string;
  category: string;
  listingType: string;
  price?: number;
  currency: string;
  negotiable: boolean;
  seller: {
    id: string;
    name: string;
    profileType: string;
    avatar?: string;
    rating?: number;
  };
  location?: string;
  condition?: string;
  tags: string[];
  images: string[];
  availability: string;
  viewCount: number;
  createdAt: string;
  relevanceScore: number;
  highlights: string[];
}
```

## 🔧 **Advanced Filtering APIs**

### **GET /api/v1/search/filters**
**Get available filters for search**

```typescript
interface SearchFiltersRequest {
  type: 'users' | 'content' | 'events' | 'marketplace' | 'groups';
  context?: string;
}

interface SearchFiltersResponse {
  success: boolean;
  filters: {
    categories: FilterOption[];
    locations: FilterOption[];
    tags: FilterOption[];
    dateRanges: FilterOption[];
    priceRanges?: FilterOption[];
    customFilters: FilterOption[];
  };
}

interface FilterOption {
  id: string;
  label: string;
  value: string;
  count: number;
  type: 'single' | 'multiple' | 'range';
  options?: FilterOption[];
}
```

### **POST /api/v1/search/saved**
**Save search query**

```typescript
interface SaveSearchRequest {
  name: string;
  query: string;
  filters: Record<string, any>;
  type: string;
  alertEnabled?: boolean;
  alertFrequency?: 'immediate' | 'daily' | 'weekly';
}

interface SaveSearchResponse {
  success: boolean;
  savedSearch: {
    id: string;
    name: string;
    query: string;
    filters: Record<string, any>;
    type: string;
    alertEnabled: boolean;
    alertFrequency?: string;
    resultCount: number;
    createdAt: string;
    lastRun?: string;
  };
}
```

### **GET /api/v1/search/saved**
**Get saved searches**

```typescript
interface SavedSearchesResponse {
  success: boolean;
  savedSearches: {
    id: string;
    name: string;
    query: string;
    type: string;
    resultCount: number;
    alertEnabled: boolean;
    lastRun?: string;
    createdAt: string;
  }[];
}
```

## 📊 **Search Analytics APIs**

### **GET /api/v1/search/analytics**
**Get search analytics**

```typescript
interface SearchAnalyticsRequest {
  timeRange: '7d' | '30d' | '90d' | '1y';
  type?: string;
}

interface SearchAnalyticsResponse {
  success: boolean;
  analytics: {
    overview: {
      totalSearches: number;
      uniqueQueries: number;
      averageResultsPerSearch: number;
      clickThroughRate: number;
    };
    topQueries: {
      query: string;
      count: number;
      resultCount: number;
      clickThroughRate: number;
    }[];
    searchTrends: {
      date: string;
      searches: number;
      uniqueQueries: number;
    }[];
    noResultQueries: {
      query: string;
      count: number;
    }[];
    popularFilters: {
      filter: string;
      usage: number;
    }[];
  };
}
```

---

## 📚 **Reference Documents**

**Content Management**: See `/2_technical_architecture/api_specifications/3_content_management_apis.md`
**User Management**: See `/2_technical_architecture/api_specifications/2_profile_management_apis.md`
**Advanced Community**: See `/2_technical_architecture/api_specifications/5_advanced_community_apis.md`
**AI Integration**: See `/2_technical_architecture/api_specifications/4_ai_integration_apis.md`

*These search and filtering APIs provide comprehensive functionality for content discovery, user search, advanced filtering, and search analytics across the ZbInnovation platform.*
