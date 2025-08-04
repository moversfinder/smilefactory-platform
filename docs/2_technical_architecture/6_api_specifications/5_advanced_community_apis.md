# 5. Advanced Community APIs

## 🌐 **Advanced Community APIs Overview**

This document outlines the comprehensive API specifications for advanced community features including Groups management, Events system, Marketplace functionality, and enhanced social interactions for the ZbInnovation platform.

## 👥 **Groups Management APIs**

### **POST /api/v1/groups**
**Create a new group**

```typescript
interface CreateGroupRequest {
  name: string;
  description: string;
  category: string;
  visibility: 'public' | 'private' | 'hidden';
  membershipType: 'open' | 'approval_required' | 'invite_only';
  maxMembers?: number;
  tags?: string[];
  location?: string;
  coverImage?: string;
}

interface CreateGroupResponse {
  id: string;
  name: string;
  description: string;
  category: string;
  visibility: string;
  membershipType: string;
  maxMembers: number;
  memberCount: number;
  createdBy: string;
  status: string;
  inviteCode?: string;
  coverImageUrl?: string;
  tags: string[];
  location?: string;
  createdAt: string;
  updatedAt: string;
}
```

### **GET /api/v1/groups**
**Search and list groups**

```typescript
interface GroupSearchParams {
  query?: string;
  category?: string;
  visibility?: 'public' | 'private';
  location?: string;
  tags?: string[];
  page?: number;
  limit?: number;
  sortBy?: 'name' | 'memberCount' | 'createdAt' | 'activity';
  sortOrder?: 'asc' | 'desc';
}

interface GroupSearchResponse {
  groups: Group[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  filters: {
    categories: string[];
    locations: string[];
    popularTags: string[];
  };
}
```

### **POST /api/v1/groups/{groupId}/join**
**Join a group**

```typescript
interface JoinGroupRequest {
  inviteCode?: string;
  message?: string;
}

interface JoinGroupResponse {
  membership: {
    id: string;
    groupId: string;
    userId: string;
    role: 'admin' | 'moderator' | 'member';
    status: 'active' | 'pending' | 'banned';
    joinedAt: string;
  };
  requiresApproval: boolean;
  message: string;
}
```

### **GET /api/v1/groups/{groupId}/members**
**Get group members**

```typescript
interface GroupMembersResponse {
  members: GroupMember[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
}

interface GroupMember {
  id: string;
  userId: string;
  user: {
    id: string;
    firstName: string;
    lastName: string;
    profileType: string;
    profilePhotoUrl?: string;
    title?: string;
  };
  role: 'admin' | 'moderator' | 'member';
  status: 'active' | 'pending';
  joinedAt: string;
}
```

### **POST /api/v1/groups/{groupId}/posts**
**Create a group post**

```typescript
interface CreateGroupPostRequest {
  title?: string;
  content: string;
  postType: 'discussion' | 'announcement' | 'poll' | 'event';
  pinned?: boolean;
  attachments?: string[];
  pollOptions?: string[];
}

interface CreateGroupPostResponse {
  id: string;
  groupId: string;
  authorId: string;
  title?: string;
  content: string;
  postType: string;
  pinned: boolean;
  likeCount: number;
  commentCount: number;
  createdAt: string;
  updatedAt: string;
}
```

## 📅 **Events Management APIs**

### **POST /api/v1/events**
**Create a new event**

```typescript
interface CreateEventRequest {
  title: string;
  description: string;
  eventType: 'conference' | 'workshop' | 'networking' | 'webinar' | 'meetup' | 'pitch' | 'demo';
  startDateTime: string;
  endDateTime: string;
  timezone?: string;
  location?: string;
  virtualMeetingUrl?: string;
  maxAttendees?: number;
  registrationRequired?: boolean;
  registrationDeadline?: string;
  visibility: 'public' | 'private' | 'members_only';
  tags?: string[];
  price?: number;
  currency?: string;
  coverImage?: string;
}

interface CreateEventResponse {
  id: string;
  title: string;
  description: string;
  eventType: string;
  startDateTime: string;
  endDateTime: string;
  timezone: string;
  location?: string;
  virtualMeetingUrl?: string;
  maxAttendees?: number;
  currentAttendees: number;
  registrationRequired: boolean;
  registrationDeadline?: string;
  organizerId: string;
  status: 'draft' | 'published' | 'cancelled' | 'completed';
  visibility: string;
  coverImageUrl?: string;
  tags: string[];
  price: number;
  currency: string;
  createdAt: string;
  updatedAt: string;
}
```

### **GET /api/v1/events**
**Search and list events**

```typescript
interface EventSearchParams {
  query?: string;
  eventType?: string;
  location?: string;
  dateRange?: {
    start: string;
    end: string;
  };
  tags?: string[];
  priceRange?: {
    min: number;
    max: number;
  };
  page?: number;
  limit?: number;
  sortBy?: 'startDateTime' | 'title' | 'attendeeCount' | 'createdAt';
  sortOrder?: 'asc' | 'desc';
}

interface EventSearchResponse {
  events: Event[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  filters: {
    eventTypes: string[];
    locations: string[];
    popularTags: string[];
  };
}
```

### **POST /api/v1/events/{eventId}/rsvp**
**RSVP to an event**

```typescript
interface RSVPRequest {
  status: 'confirmed' | 'maybe' | 'declined';
  dietaryRestrictions?: string;
  specialRequests?: string;
}

interface RSVPResponse {
  attendee: {
    id: string;
    eventId: string;
    userId: string;
    status: 'confirmed' | 'maybe' | 'declined' | 'pending' | 'waitlist';
    role: 'organizer' | 'speaker' | 'sponsor' | 'attendee';
    registeredAt: string;
    dietaryRestrictions?: string;
    specialRequests?: string;
  };
  waitlisted: boolean;
  message: string;
}
```

### **GET /api/v1/events/{eventId}/attendees**
**Get event attendees**

```typescript
interface EventAttendeesResponse {
  attendees: EventAttendee[];
  summary: {
    confirmed: number;
    maybe: number;
    declined: number;
    pending: number;
    waitlist: number;
  };
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
}

interface EventAttendee {
  id: string;
  userId: string;
  user: {
    id: string;
    firstName: string;
    lastName: string;
    profileType: string;
    profilePhotoUrl?: string;
    title?: string;
  };
  status: string;
  role: string;
  registeredAt: string;
}
```

## 🛒 **Marketplace APIs**

### **POST /api/v1/marketplace/listings**
**Create a marketplace listing**

```typescript
interface CreateListingRequest {
  title: string;
  description: string;
  category: string;
  listingType: 'product' | 'service' | 'job' | 'partnership' | 'investment';
  price?: number;
  currency?: string;
  negotiable?: boolean;
  location?: string;
  tags?: string[];
  images?: string[];
  contactMethod: 'platform' | 'email' | 'phone' | 'website';
  contactDetails?: string;
}

interface CreateListingResponse {
  id: string;
  title: string;
  description: string;
  category: string;
  listingType: string;
  price?: number;
  currency: string;
  negotiable: boolean;
  sellerId: string;
  status: 'active' | 'sold' | 'expired' | 'removed';
  location?: string;
  tags: string[];
  images: string[];
  contactMethod: string;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}
```

### **GET /api/v1/marketplace/listings**
**Search marketplace listings**

```typescript
interface MarketplaceSearchParams {
  query?: string;
  category?: string;
  listingType?: string;
  location?: string;
  priceRange?: {
    min: number;
    max: number;
  };
  tags?: string[];
  page?: number;
  limit?: number;
  sortBy?: 'createdAt' | 'price' | 'title' | 'viewCount';
  sortOrder?: 'asc' | 'desc';
}

interface MarketplaceSearchResponse {
  listings: MarketplaceListing[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  filters: {
    categories: string[];
    listingTypes: string[];
    locations: string[];
    priceRanges: PriceRange[];
  };
}
```

### **POST /api/v1/marketplace/listings/{listingId}/inquire**
**Inquire about a listing**

```typescript
interface InquiryRequest {
  message: string;
  offeredAmount?: number;
  contactPreference: 'platform' | 'email' | 'phone';
}

interface InquiryResponse {
  transaction: {
    id: string;
    listingId: string;
    sellerId: string;
    buyerId: string;
    amount?: number;
    currency: string;
    status: 'initiated' | 'negotiating' | 'agreed' | 'completed' | 'cancelled';
    message: string;
    createdAt: string;
  };
  message: string;
}
```

## 🔍 **Advanced Search APIs**

### **GET /api/v1/search/global**
**Global platform search**

```typescript
interface GlobalSearchParams {
  query: string;
  types?: ('users' | 'posts' | 'groups' | 'events' | 'listings')[];
  filters?: {
    location?: string;
    profileType?: string;
    dateRange?: {
      start: string;
      end: string;
    };
  };
  page?: number;
  limit?: number;
}

interface GlobalSearchResponse {
  results: {
    users: SearchResult[];
    posts: SearchResult[];
    groups: SearchResult[];
    events: SearchResult[];
    listings: SearchResult[];
  };
  totalResults: number;
  suggestions: string[];
  pagination: {
    page: number;
    limit: number;
    total: number;
  };
}

interface SearchResult {
  id: string;
  type: string;
  title: string;
  description: string;
  imageUrl?: string;
  relevanceScore: number;
  metadata: Record<string, any>;
}
```

## 📊 **Community Analytics APIs**

### **GET /api/v1/analytics/community**
**Get community analytics**

```typescript
interface CommunityAnalyticsResponse {
  overview: {
    totalUsers: number;
    activeUsers: number;
    totalPosts: number;
    totalGroups: number;
    totalEvents: number;
    totalListings: number;
  };
  engagement: {
    dailyActiveUsers: number;
    weeklyActiveUsers: number;
    monthlyActiveUsers: number;
    averageSessionDuration: number;
    postsPerUser: number;
    commentsPerPost: number;
  };
  growth: {
    userGrowthRate: number;
    contentGrowthRate: number;
    engagementGrowthRate: number;
  };
  trends: {
    popularTopics: string[];
    trendingGroups: Group[];
    upcomingEvents: Event[];
    activeListings: MarketplaceListing[];
  };
}
```

## 🚨 **Error Handling**

### **Common Error Responses**
```typescript
interface CommunityAPIError {
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
  requestId: string;
  timestamp: string;
}
```

**Common Error Codes:**
- `GROUP_NOT_FOUND` - Group does not exist
- `ALREADY_MEMBER` - User is already a member of the group
- `GROUP_FULL` - Group has reached maximum capacity
- `INVALID_INVITE_CODE` - Invalid or expired invite code
- `EVENT_NOT_FOUND` - Event does not exist
- `REGISTRATION_CLOSED` - Event registration has closed
- `EVENT_FULL` - Event has reached maximum capacity
- `LISTING_NOT_FOUND` - Marketplace listing does not exist
- `INSUFFICIENT_PERMISSIONS` - User lacks required permissions
- `VALIDATION_ERROR` - Request validation failed

---

## 📚 **Reference Documents**

**Advanced Community Implementation**: See `/4_backend_implementation/7_advanced_community_features.md`
**Database Schema**: See `/2_technical_architecture/2_database_schema_and_design.md`
**Authentication APIs**: See `/2_technical_architecture/api_specifications/1_authentication_apis.md`
**Core APIs**: See `/2_technical_architecture/api_specifications/2_user_management_apis.md`

*These advanced community APIs provide comprehensive functionality for Groups, Events, Marketplace, and enhanced social interactions on the ZbInnovation platform.*
