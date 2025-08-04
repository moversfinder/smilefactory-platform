# 2. Database Schema and Design

## 🗄️ **Database Architecture Overview**

The SmileFactory platform uses PostgreSQL as the primary database with specialized extensions for AI features and full-text search. The schema is designed to support 8 user types, 6 community tabs, and comprehensive social features.

## 📊 **Database Technology Stack**

### **Primary Database**
- **PostgreSQL 15+**: Main relational database
- **pgvector Extension**: Vector storage for AI embeddings
- **Full-Text Search**: Built-in PostgreSQL search capabilities
- **UUID Extensions**: Secure unique identifiers
- **Crypto Extensions**: Password hashing and security

### **Supporting Technologies**
- **Redis**: Session management and caching
- **Elasticsearch**: Advanced search and analytics (optional)
- **AWS S3**: File and media storage (external)

## 🏗️ **Core Database Schema**

### **User Management Tables**

#### **personal_details (Main User Table)**
```sql
CREATE TABLE personal_details (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_country_code VARCHAR(10),
    phone_number VARCHAR(20),
    gender VARCHAR(20),
    role VARCHAR(50) DEFAULT 'user',
    profile_name VARCHAR(200),
    profile_state VARCHAR(20) DEFAULT 'DRAFT',
    profile_type VARCHAR(50),
    profile_visibility VARCHAR(20) DEFAULT 'public',
    profile_completion INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    bio TEXT,
    hear_about_us TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);
```

#### **Profile Type-Specific Tables**

**Innovator Profiles**:
```sql
CREATE TABLE innovator_profiles (
    user_id UUID PRIMARY KEY REFERENCES personal_details(user_id),
    industry_focus VARCHAR(100),
    innovation_stage VARCHAR(50),
    startup_name VARCHAR(200),
    startup_description TEXT,
    funding_amount_needed DECIMAL(15,2),
    team_size INTEGER,
    business_model TEXT,
    target_market TEXT,
    competitive_advantage TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Business Investor Profiles**:
```sql
CREATE TABLE business_investor_profiles (
    user_id UUID PRIMARY KEY REFERENCES personal_details(user_id),
    investment_focus TEXT[],
    investment_stage_preference TEXT[],
    ticket_size_min DECIMAL(15,2),
    ticket_size_max DECIMAL(15,2),
    geographic_focus TEXT[],
    portfolio_companies TEXT[],
    investment_criteria TEXT,
    due_diligence_process TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Mentor Profiles**:
```sql
CREATE TABLE mentor_profiles (
    user_id UUID PRIMARY KEY REFERENCES personal_details(user_id),
    expertise_areas TEXT[],
    mentoring_experience_years INTEGER,
    mentoring_approach TEXT,
    availability_hours_per_month INTEGER,
    preferred_communication_methods TEXT[],
    success_stories TEXT,
    mentoring_philosophy TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### **Content Management Tables**

#### **Posts and Content**
```sql
CREATE TABLE posts (
    post_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES personal_details(user_id),
    title VARCHAR(500),
    content TEXT,
    post_type VARCHAR(50), -- 'general', 'blog', 'announcement', 'opportunity'
    category VARCHAR(100),
    tags TEXT[],
    visibility VARCHAR(20) DEFAULT 'public',
    status VARCHAR(20) DEFAULT 'published',
    featured_image_url TEXT,
    media_urls TEXT[],
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    published_at TIMESTAMPTZ
);
```

#### **Comments System**
```sql
CREATE TABLE comments (
    comment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES posts(post_id) ON DELETE CASCADE,
    author_id UUID REFERENCES personal_details(user_id),
    parent_comment_id UUID REFERENCES comments(comment_id),
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### **Social Features Tables**

#### **Connections and Networking**
```sql
CREATE TABLE connections (
    connection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID REFERENCES personal_details(user_id),
    recipient_id UUID REFERENCES personal_details(user_id),
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'declined', 'blocked'
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(requester_id, recipient_id)
);
```

#### **Direct Messages**
```sql
CREATE TABLE messages (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID,
    sender_id UUID REFERENCES personal_details(user_id),
    recipient_id UUID REFERENCES personal_details(user_id),
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text', -- 'text', 'file', 'image'
    file_url TEXT,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### **Community Features Tables**

#### **Groups and Communities**
```sql
CREATE TABLE groups (
    group_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES personal_details(user_id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    group_type VARCHAR(20) DEFAULT 'public', -- 'public', 'private', 'invite-only'
    category VARCHAR(100),
    member_count INTEGER DEFAULT 0,
    rules TEXT,
    cover_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### **Events Management**
```sql
CREATE TABLE events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organizer_id UUID REFERENCES personal_details(user_id),
    title VARCHAR(300) NOT NULL,
    description TEXT,
    event_type VARCHAR(50), -- 'workshop', 'conference', 'networking', 'webinar'
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    location TEXT,
    is_online BOOLEAN DEFAULT FALSE,
    online_platform VARCHAR(100),
    registration_required BOOLEAN DEFAULT TRUE,
    max_attendees INTEGER,
    current_attendees INTEGER DEFAULT 0,
    registration_fee DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'upcoming',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### **AI and Recommendation Tables**

#### **User Embeddings for AI**
```sql
CREATE TABLE user_embeddings (
    user_id UUID PRIMARY KEY REFERENCES personal_details(user_id),
    profile_embedding vector(1536), -- OpenAI embedding dimension
    interest_embedding vector(1536),
    activity_embedding vector(1536),
    last_updated TIMESTAMPTZ DEFAULT NOW()
);
```

#### **Content Embeddings**
```sql
CREATE TABLE content_embeddings (
    content_id UUID PRIMARY KEY,
    content_type VARCHAR(50), -- 'post', 'profile', 'event', 'group'
    embedding vector(1536),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## 🔗 **Database Relationships**

### **Key Relationships**
- **Users → Profile Types**: One-to-one relationship with profile-specific tables
- **Users → Posts**: One-to-many relationship for content creation
- **Posts → Comments**: One-to-many with threading support
- **Users → Connections**: Many-to-many through connections table
- **Users → Groups**: Many-to-many through group_members table
- **Users → Events**: Many-to-many through event_registrations table

### **Referential Integrity**
- **CASCADE DELETE**: Profile deletions cascade to related data
- **FOREIGN KEY CONSTRAINTS**: Maintain data consistency
- **UNIQUE CONSTRAINTS**: Prevent duplicate relationships
- **CHECK CONSTRAINTS**: Validate data integrity

## 📈 **Performance Optimization**

### **Indexing Strategy**
```sql
-- User lookup indexes
CREATE INDEX idx_personal_details_email ON personal_details(email);
CREATE INDEX idx_personal_details_profile_type ON personal_details(profile_type);
CREATE INDEX idx_personal_details_created_at ON personal_details(created_at);

-- Content indexes
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_category ON posts(category);
CREATE INDEX idx_posts_tags ON posts USING GIN(tags);

-- Social feature indexes
CREATE INDEX idx_connections_requester ON connections(requester_id);
CREATE INDEX idx_connections_recipient ON connections(recipient_id);
CREATE INDEX idx_connections_status ON connections(status);

-- Full-text search indexes
CREATE INDEX idx_posts_content_search ON posts USING GIN(to_tsvector('english', content));
CREATE INDEX idx_posts_title_search ON posts USING GIN(to_tsvector('english', title));
```

### **Vector Search Optimization**
```sql
-- Vector similarity indexes for AI features
CREATE INDEX idx_user_embeddings_profile ON user_embeddings 
USING ivfflat (profile_embedding vector_cosine_ops) WITH (lists = 100);

CREATE INDEX idx_content_embeddings_vector ON content_embeddings 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

## 🤖 **AI Integration Tables**

### **AI Conversations and Memory**
```sql
-- AI conversation tracking
CREATE TABLE ai_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id VARCHAR(255),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'error', 'timeout')),
    context_data JSONB,
    total_messages INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI conversation messages with vector embeddings
CREATE TABLE ai_conversation_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    content_embedding vector(1536), -- OpenAI embedding dimension
    tokens_used INTEGER,
    response_time_ms INTEGER,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- AI user preferences and settings
CREATE TABLE ai_user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ai_enabled BOOLEAN DEFAULT true,
    preferred_response_style VARCHAR(50) DEFAULT 'balanced' CHECK (preferred_response_style IN ('concise', 'detailed', 'balanced')),
    context_awareness_level VARCHAR(50) DEFAULT 'full' CHECK (context_awareness_level IN ('minimal', 'moderate', 'full')),
    quick_replies_enabled BOOLEAN DEFAULT true,
    profile_assistance_enabled BOOLEAN DEFAULT true,
    notification_preferences JSONB DEFAULT '{"ai_suggestions": true, "conversation_summaries": false}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- AI context data storage
CREATE TABLE ai_context_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    context_type VARCHAR(50) NOT NULL CHECK (context_type IN ('profile', 'activity', 'preferences', 'connections', 'content')),
    context_key VARCHAR(255) NOT NULL,
    context_value JSONB NOT NULL,
    context_embedding vector(1536),
    relevance_score DECIMAL(3,2) DEFAULT 1.0,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI analytics and insights
CREATE TABLE ai_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    ai_response_quality DECIMAL(3,2),
    user_satisfaction_rating INTEGER CHECK (user_satisfaction_rating BETWEEN 1 AND 5),
    response_time_ms INTEGER,
    tokens_used INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for AI tables
CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX idx_ai_conversations_status ON ai_conversations(status);
CREATE INDEX idx_ai_conversations_started_at ON ai_conversations(started_at);

CREATE INDEX idx_ai_messages_conversation_id ON ai_conversation_messages(conversation_id);
CREATE INDEX idx_ai_messages_role ON ai_conversation_messages(role);
CREATE INDEX idx_ai_messages_timestamp ON ai_conversation_messages(timestamp);

-- Vector similarity search index
CREATE INDEX idx_ai_messages_embedding ON ai_conversation_messages USING ivfflat (content_embedding vector_cosine_ops);
CREATE INDEX idx_ai_context_embedding ON ai_context_data USING ivfflat (context_embedding vector_cosine_ops);

CREATE INDEX idx_ai_context_user_type ON ai_context_data(user_id, context_type);
CREATE INDEX idx_ai_context_key ON ai_context_data(context_key);
CREATE INDEX idx_ai_context_expires ON ai_context_data(expires_at);

CREATE INDEX idx_ai_analytics_user_id ON ai_analytics(user_id);
CREATE INDEX idx_ai_analytics_event_type ON ai_analytics(event_type);
CREATE INDEX idx_ai_analytics_created_at ON ai_analytics(created_at);
```

## 👥 **Advanced Community Tables**

### **Groups and Events System**
```sql
-- Groups table
CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    visibility VARCHAR(50) DEFAULT 'public' CHECK (visibility IN ('public', 'private', 'hidden')),
    membership_type VARCHAR(50) DEFAULT 'open' CHECK (membership_type IN ('open', 'approval_required', 'invite_only')),
    max_members INTEGER DEFAULT 1000,
    member_count INTEGER DEFAULT 0,
    created_by UUID NOT NULL REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
    invite_code VARCHAR(50) UNIQUE,
    cover_image_url TEXT,
    tags TEXT[],
    location VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Group memberships
CREATE TABLE group_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'pending', 'banned', 'left')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    invited_by UUID REFERENCES users(id),
    UNIQUE(group_id, user_id)
);

-- Events table
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    event_type VARCHAR(100) NOT NULL CHECK (event_type IN ('conference', 'workshop', 'networking', 'webinar', 'meetup', 'pitch', 'demo')),
    start_date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    timezone VARCHAR(50) DEFAULT 'Africa/Harare',
    location VARCHAR(500),
    virtual_meeting_url TEXT,
    max_attendees INTEGER,
    current_attendees INTEGER DEFAULT 0,
    registration_required BOOLEAN DEFAULT true,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    organizer_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'cancelled', 'completed')),
    visibility VARCHAR(50) DEFAULT 'public' CHECK (visibility IN ('public', 'private', 'members_only')),
    cover_image_url TEXT,
    tags TEXT[],
    price DECIMAL(10,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Event attendees and RSVPs
CREATE TABLE event_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('confirmed', 'maybe', 'declined', 'pending', 'waitlist')),
    role VARCHAR(50) DEFAULT 'attendee' CHECK (role IN ('organizer', 'speaker', 'sponsor', 'attendee')),
    registered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    dietary_restrictions TEXT,
    special_requests TEXT,
    check_in_time TIMESTAMP WITH TIME ZONE,
    UNIQUE(event_id, user_id)
);

-- Marketplace listings
CREATE TABLE marketplace_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    listing_type VARCHAR(50) NOT NULL CHECK (listing_type IN ('product', 'service', 'job', 'partnership', 'investment')),
    price DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'USD',
    negotiable BOOLEAN DEFAULT false,
    seller_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'sold', 'expired', 'removed')),
    location VARCHAR(255),
    tags TEXT[],
    images TEXT[],
    contact_method VARCHAR(100),
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Marketplace transactions
CREATE TABLE marketplace_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES marketplace_listings(id),
    seller_id UUID NOT NULL REFERENCES users(id),
    buyer_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(50) DEFAULT 'initiated' CHECK (status IN ('initiated', 'negotiating', 'agreed', 'completed', 'cancelled')),
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for advanced community tables
CREATE INDEX idx_groups_category ON groups(category);
CREATE INDEX idx_groups_visibility ON groups(visibility);
CREATE INDEX idx_groups_created_by ON groups(created_by);
CREATE INDEX idx_groups_status ON groups(status);

CREATE INDEX idx_group_memberships_group_user ON group_memberships(group_id, user_id);
CREATE INDEX idx_group_memberships_user ON group_memberships(user_id);
CREATE INDEX idx_group_memberships_status ON group_memberships(status);

CREATE INDEX idx_events_organizer_id ON events(organizer_id);
CREATE INDEX idx_events_event_type ON events(event_type);
CREATE INDEX idx_events_start_date ON events(start_date_time);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_location ON events(location);

CREATE INDEX idx_event_attendees_event_user ON event_attendees(event_id, user_id);
CREATE INDEX idx_event_attendees_user ON event_attendees(user_id);
CREATE INDEX idx_event_attendees_status ON event_attendees(status);

CREATE INDEX idx_marketplace_listings_seller ON marketplace_listings(seller_id);
CREATE INDEX idx_marketplace_listings_category ON marketplace_listings(category);
CREATE INDEX idx_marketplace_listings_type ON marketplace_listings(listing_type);
CREATE INDEX idx_marketplace_listings_status ON marketplace_listings(status);

CREATE INDEX idx_marketplace_transactions_listing ON marketplace_transactions(listing_id);
CREATE INDEX idx_marketplace_transactions_seller ON marketplace_transactions(seller_id);
CREATE INDEX idx_marketplace_transactions_buyer ON marketplace_transactions(buyer_id);
```

## 🔒 **Security and Privacy**

### **Data Protection**
- **Password Hashing**: bcrypt with salt for password security
- **UUID Primary Keys**: Prevent enumeration attacks
- **Row Level Security**: PostgreSQL RLS for data access control
- **Audit Logging**: Track data changes and access

### **Privacy Controls**
- **Profile Visibility**: Control who can see profile information
- **Content Privacy**: Manage content visibility and access
- **Data Retention**: Configurable data retention policies
- **GDPR Compliance**: Support for data export and deletion

## 📊 **Data Migration and Versioning**

### **Migration Strategy**
- **Flyway Integration**: Version-controlled database migrations
- **Backward Compatibility**: Maintain compatibility during updates
- **Data Validation**: Ensure data integrity during migrations
- **Rollback Procedures**: Safe rollback mechanisms

### **Schema Versioning**
- **Version Control**: Track schema changes in Git
- **Environment Consistency**: Ensure consistency across environments
- **Testing**: Comprehensive testing of schema changes
- **Documentation**: Maintain migration documentation

---

## 📚 **Reference Documents**

**Complete Schema**: See `/database-schema/core-tables.sql` for full SQL implementation
**API Integration**: See `/api-specifications/` for database interaction patterns
**Performance Tuning**: See `/7_deployment_and_operations/` for optimization strategies

*This database design provides a scalable, secure foundation for the SmileFactory platform's comprehensive feature set.*
