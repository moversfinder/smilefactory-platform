# 12. Virtual Community Tabs APIs

## 🌐 **Virtual Community Overview**

This document specifies APIs for the 6 main virtual community tabs: Feed, Profiles, Blog, Events, Groups, and Marketplace. Each tab provides specialized functionality for different aspects of community interaction and content discovery.

## 📱 **Community Tab Structure**

### **Tab Configuration**
```typescript
interface CommunityTab {
  id: string;
  name: string;
  icon: string;
  description: string;
  isActive: boolean;
  order: number;
  permissions: string[];
  features: string[];
}

interface CommunityTabsResponse {
  success: boolean;
  tabs: CommunityTab[];
  activeTab: string;
  userPermissions: string[];
}
```

## 📰 **Feed Tab APIs**

### **GET /api/v1/community/feed**
**Get community feed**

```typescript
interface CommunityFeedRequest {
  feedType?: 'all' | 'following' | 'trending' | 'recent';
  contentTypes?: ('post' | 'article' | 'announcement' | 'opportunity')[];
  profileTypes?: string[];
  tags?: string[];
  page?: number;
  limit?: number;
  since?: string;
}

interface CommunityFeedResponse {
  success: boolean;
  posts: FeedPost[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    hasMore: boolean;
  };
  filters: {
    contentTypes: { type: string; count: number }[];
    profileTypes: { type: string; count: number }[];
    tags: { tag: string; count: number }[];
  };
}

interface FeedPost {
  id: string;
  type: 'post' | 'article' | 'announcement' | 'opportunity';
  title?: string;
  content: string;
  excerpt: string;
  author: {
    id: string;
    name: string;
    profileType: string;
    avatar?: string;
    verified: boolean;
  };
  media: MediaItem[];
  tags: string[];
  category?: string;
  engagement: {
    likes: number;
    comments: number;
    shares: number;
    saves: number;
    views: number;
  };
  userInteraction: {
    liked: boolean;
    commented: boolean;
    shared: boolean;
    saved: boolean;
  };
  createdAt: string;
  updatedAt: string;
  isPinned: boolean;
  isPromoted: boolean;
}

interface MediaItem {
  id: string;
  type: 'image' | 'video' | 'document' | 'link';
  url: string;
  thumbnailUrl?: string;
  title?: string;
  description?: string;
  metadata?: Record<string, any>;
}
```

### **POST /api/v1/community/feed/posts**
**Create feed post**

```typescript
interface CreateFeedPostRequest {
  type: 'post' | 'article' | 'announcement' | 'opportunity';
  title?: string;
  content: string;
  tags?: string[];
  category?: string;
  media?: string[];
  visibility: 'public' | 'connections' | 'private';
  allowComments?: boolean;
  isPinned?: boolean;
}

interface CreateFeedPostResponse {
  success: boolean;
  post: FeedPost;
  message: string;
}
```

## 👥 **Profiles Tab APIs**

### **GET /api/v1/community/profiles**
**Get community profiles**

```typescript
interface CommunityProfilesRequest {
  profileTypes?: string[];
  location?: string;
  skills?: string[];
  interests?: string[];
  isOnline?: boolean;
  isVerified?: boolean;
  sortBy?: 'name' | 'joinDate' | 'activity' | 'connections';
  page?: number;
  limit?: number;
}

interface CommunityProfilesResponse {
  success: boolean;
  profiles: CommunityProfile[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  stats: {
    totalProfiles: number;
    onlineProfiles: number;
    byType: { type: string; count: number }[];
    byLocation: { location: string; count: number }[];
  };
}

interface CommunityProfile {
  id: string;
  firstName: string;
  lastName: string;
  displayName: string;
  profileType: string;
  title?: string;
  bio?: string;
  avatar?: string;
  coverImage?: string;
  location?: string;
  skills: string[];
  interests: string[];
  stats: {
    connections: number;
    posts: number;
    likes: number;
    profileViews: number;
  };
  isOnline: boolean;
  isVerified: boolean;
  lastActive: string;
  joinedAt: string;
  connectionStatus: 'none' | 'pending' | 'connected';
  mutualConnections: number;
}
```

### **GET /api/v1/community/profiles/featured**
**Get featured profiles**

```typescript
interface FeaturedProfilesResponse {
  success: boolean;
  featured: {
    profileOfTheWeek: CommunityProfile;
    topContributors: CommunityProfile[];
    newMembers: CommunityProfile[];
    mostConnected: CommunityProfile[];
    expertSpotlight: CommunityProfile[];
  };
}
```

## 📝 **Blog Tab APIs**

### **GET /api/v1/community/blog**
**Get blog articles**

```typescript
interface CommunityBlogRequest {
  categories?: string[];
  authors?: string[];
  tags?: string[];
  featured?: boolean;
  dateRange?: {
    start: string;
    end: string;
  };
  sortBy?: 'date' | 'popularity' | 'views' | 'engagement';
  page?: number;
  limit?: number;
}

interface CommunityBlogResponse {
  success: boolean;
  articles: BlogArticle[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  categories: { category: string; count: number }[];
  featuredArticles: BlogArticle[];
}

interface BlogArticle {
  id: string;
  title: string;
  content: string;
  excerpt: string;
  author: {
    id: string;
    name: string;
    profileType: string;
    avatar?: string;
    bio?: string;
  };
  category: string;
  tags: string[];
  featuredImage?: string;
  readTime: number;
  engagement: {
    views: number;
    likes: number;
    comments: number;
    shares: number;
  };
  publishedAt: string;
  updatedAt: string;
  isFeatured: boolean;
  status: 'draft' | 'published' | 'archived';
}
```

### **POST /api/v1/community/blog/articles**
**Create blog article**

```typescript
interface CreateBlogArticleRequest {
  title: string;
  content: string;
  excerpt?: string;
  category: string;
  tags?: string[];
  featuredImage?: string;
  status: 'draft' | 'published';
  publishAt?: string;
}

interface CreateBlogArticleResponse {
  success: boolean;
  article: BlogArticle;
  message: string;
}
```

## 📅 **Events Tab APIs**

### **GET /api/v1/community/events**
**Get community events**

```typescript
interface CommunityEventsRequest {
  timeframe?: 'upcoming' | 'past' | 'today' | 'this_week' | 'this_month';
  eventTypes?: string[];
  location?: string;
  organizers?: string[];
  tags?: string[];
  priceRange?: {
    min: number;
    max: number;
  };
  registrationStatus?: 'open' | 'closed' | 'waitlist';
  sortBy?: 'date' | 'popularity' | 'price' | 'attendees';
  page?: number;
  limit?: number;
}

interface CommunityEventsResponse {
  success: boolean;
  events: CommunityEvent[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  calendar: {
    date: string;
    eventCount: number;
    events: CommunityEvent[];
  }[];
  stats: {
    totalEvents: number;
    upcomingEvents: number;
    todayEvents: number;
    thisWeekEvents: number;
  };
}

interface CommunityEvent {
  id: string;
  title: string;
  description: string;
  eventType: string;
  startDateTime: string;
  endDateTime: string;
  timezone: string;
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
  registrationStatus: 'open' | 'closed' | 'waitlist';
  tags: string[];
  coverImageUrl?: string;
  userRegistration?: {
    status: 'registered' | 'waitlist' | 'not_registered';
    registeredAt?: string;
  };
}
```

### **GET /api/v1/community/events/calendar**
**Get events calendar view**

```typescript
interface EventsCalendarRequest {
  year: number;
  month: number;
  view?: 'month' | 'week' | 'day';
}

interface EventsCalendarResponse {
  success: boolean;
  calendar: {
    year: number;
    month: number;
    days: CalendarDay[];
  };
  events: CommunityEvent[];
}

interface CalendarDay {
  date: string;
  dayOfWeek: number;
  eventCount: number;
  hasEvents: boolean;
  isToday: boolean;
  isCurrentMonth: boolean;
}
```

## 👥 **Groups Tab APIs**

### **GET /api/v1/community/groups**
**Get community groups**

```typescript
interface CommunityGroupsRequest {
  categories?: string[];
  visibility?: 'public' | 'private';
  membershipType?: 'open' | 'approval_required' | 'invite_only';
  location?: string;
  tags?: string[];
  sortBy?: 'name' | 'members' | 'activity' | 'created';
  page?: number;
  limit?: number;
}

interface CommunityGroupsResponse {
  success: boolean;
  groups: CommunityGroup[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  categories: { category: string; count: number }[];
  myGroups: CommunityGroup[];
  recommendedGroups: CommunityGroup[];
}

interface CommunityGroup {
  id: string;
  name: string;
  description: string;
  category: string;
  visibility: 'public' | 'private' | 'hidden';
  membershipType: 'open' | 'approval_required' | 'invite_only';
  memberCount: number;
  maxMembers: number;
  creator: {
    id: string;
    name: string;
    profileType: string;
    avatar?: string;
  };
  coverImageUrl?: string;
  tags: string[];
  location?: string;
  stats: {
    posts: number;
    activeMembers: number;
    weeklyActivity: number;
  };
  userMembership?: {
    status: 'member' | 'pending' | 'not_member';
    role?: 'admin' | 'moderator' | 'member';
    joinedAt?: string;
  };
  createdAt: string;
  lastActivity: string;
}
```

### **GET /api/v1/community/groups/trending**
**Get trending groups**

```typescript
interface TrendingGroupsResponse {
  success: boolean;
  trending: {
    mostActive: CommunityGroup[];
    fastestGrowing: CommunityGroup[];
    newGroups: CommunityGroup[];
    popularThisWeek: CommunityGroup[];
  };
}
```

## 🛒 **Marketplace Tab APIs**

### **GET /api/v1/community/marketplace**
**Get marketplace listings**

```typescript
interface CommunityMarketplaceRequest {
  categories?: string[];
  listingTypes?: string[];
  location?: string;
  priceRange?: {
    min: number;
    max: number;
  };
  condition?: string[];
  tags?: string[];
  availability?: 'available' | 'sold' | 'reserved';
  sortBy?: 'date' | 'price' | 'popularity' | 'relevance';
  page?: number;
  limit?: number;
}

interface CommunityMarketplaceResponse {
  success: boolean;
  listings: MarketplaceListing[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
  categories: { category: string; count: number }[];
  featuredListings: MarketplaceListing[];
  recentlyViewed: MarketplaceListing[];
}

interface MarketplaceListing {
  id: string;
  title: string;
  description: string;
  category: string;
  listingType: 'product' | 'service' | 'job' | 'partnership' | 'investment';
  price?: number;
  currency: string;
  negotiable: boolean;
  seller: {
    id: string;
    name: string;
    profileType: string;
    avatar?: string;
    rating?: number;
    responseTime?: string;
  };
  location?: string;
  condition?: string;
  tags: string[];
  images: string[];
  availability: 'available' | 'sold' | 'reserved';
  stats: {
    views: number;
    inquiries: number;
    favorites: number;
  };
  userInteraction?: {
    favorited: boolean;
    inquired: boolean;
    viewed: boolean;
  };
  createdAt: string;
  updatedAt: string;
  expiresAt?: string;
}
```

### **GET /api/v1/community/marketplace/categories**
**Get marketplace categories**

```typescript
interface MarketplaceCategoriesResponse {
  success: boolean;
  categories: {
    id: string;
    name: string;
    description: string;
    icon: string;
    listingCount: number;
    subcategories: {
      id: string;
      name: string;
      listingCount: number;
    }[];
  }[];
}
```

## 📊 **Community Analytics APIs**

### **GET /api/v1/community/analytics**
**Get community analytics**

```typescript
interface CommunityAnalyticsResponse {
  success: boolean;
  analytics: {
    overview: {
      totalMembers: number;
      activeMembers: number;
      totalPosts: number;
      totalEvents: number;
      totalGroups: number;
      totalListings: number;
    };
    engagement: {
      dailyActiveUsers: number;
      weeklyActiveUsers: number;
      monthlyActiveUsers: number;
      averageSessionDuration: number;
      postsPerDay: number;
      commentsPerPost: number;
    };
    growth: {
      memberGrowthRate: number;
      contentGrowthRate: number;
      engagementGrowthRate: number;
    };
    topContent: {
      posts: FeedPost[];
      articles: BlogArticle[];
      events: CommunityEvent[];
      groups: CommunityGroup[];
    };
  };
}
```

---

## 📚 **Reference Documents**

**Content Management**: See `/2_technical_architecture/api_specifications/3_content_management_apis.md`
**Advanced Community**: See `/2_technical_architecture/api_specifications/5_advanced_community_apis.md`
**Social Features**: See `/2_technical_architecture/api_specifications/7_social_features_apis.md`
**Search & Filtering**: See `/2_technical_architecture/api_specifications/10_search_filtering_apis.md`

*These virtual community tabs APIs provide comprehensive functionality for all 6 community sections, enabling rich social interaction, content discovery, and community engagement on the ZbInnovation platform.*
