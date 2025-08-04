# 7. Advanced Community Features

## 🌐 **Advanced Community Features Overview**

This document outlines the implementation of advanced community features for the ZbInnovation platform, including Groups management, Events system, Marketplace functionality, and enhanced social interactions that were missing from the core implementation.

## 👥 **Groups Management System**

### **Groups Service Implementation**
```java
// Backend: GroupsService.java
@Service
@Slf4j
@Transactional
public class GroupsService {
    
    @Autowired
    private GroupRepository groupRepository;
    
    @Autowired
    private GroupMembershipRepository membershipRepository;
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private ActivityService activityService;
    
    public Group createGroup(CreateGroupRequest request, String creatorId) {
        // Validate group creation permissions
        validateGroupCreationPermissions(creatorId);
        
        Group group = Group.builder()
            .name(request.getName())
            .description(request.getDescription())
            .category(request.getCategory())
            .visibility(request.getVisibility())
            .membershipType(request.getMembershipType())
            .maxMembers(request.getMaxMembers())
            .createdBy(creatorId)
            .status(GroupStatus.ACTIVE)
            .memberCount(1)
            .build();
        
        group = groupRepository.save(group);
        
        // Add creator as admin member
        GroupMembership membership = GroupMembership.builder()
            .groupId(group.getId())
            .userId(creatorId)
            .role(GroupRole.ADMIN)
            .status(MembershipStatus.ACTIVE)
            .joinedAt(LocalDateTime.now())
            .build();
        
        membershipRepository.save(membership);
        
        // Log activity
        activityService.logActivity(creatorId, ActivityType.GROUP_CREATED, 
            Map.of("groupId", group.getId(), "groupName", group.getName()));
        
        log.info("Group created: {} by user {}", group.getId(), creatorId);
        return group;
    }
    
    public GroupMembership joinGroup(String groupId, String userId, String inviteCode) {
        Group group = groupRepository.findById(groupId)
            .orElseThrow(() -> new GroupNotFoundException("Group not found: " + groupId));
        
        // Validate join permissions
        validateJoinPermissions(group, userId, inviteCode);
        
        // Check if already a member
        Optional<GroupMembership> existingMembership = 
            membershipRepository.findByGroupIdAndUserId(groupId, userId);
        
        if (existingMembership.isPresent()) {
            if (existingMembership.get().getStatus() == MembershipStatus.ACTIVE) {
                throw new AlreadyMemberException("User is already a member of this group");
            } else {
                // Reactivate membership
                existingMembership.get().setStatus(MembershipStatus.ACTIVE);
                existingMembership.get().setJoinedAt(LocalDateTime.now());
                return membershipRepository.save(existingMembership.get());
            }
        }
        
        // Create new membership
        GroupMembership membership = GroupMembership.builder()
            .groupId(groupId)
            .userId(userId)
            .role(GroupRole.MEMBER)
            .status(group.getMembershipType() == MembershipType.APPROVAL_REQUIRED ? 
                MembershipStatus.PENDING : MembershipStatus.ACTIVE)
            .joinedAt(LocalDateTime.now())
            .build();
        
        membership = membershipRepository.save(membership);
        
        // Update group member count if approved
        if (membership.getStatus() == MembershipStatus.ACTIVE) {
            groupRepository.incrementMemberCount(groupId);
        }
        
        // Notify group admins if approval required
        if (membership.getStatus() == MembershipStatus.PENDING) {
            notifyGroupAdmins(group, userId, "join_request");
        } else {
            // Notify group members of new member
            notifyGroupMembers(group, userId, "member_joined");
        }
        
        // Log activity
        activityService.logActivity(userId, ActivityType.GROUP_JOINED, 
            Map.of("groupId", groupId, "groupName", group.getName()));
        
        return membership;
    }
    
    public Page<Group> searchGroups(GroupSearchRequest request, Pageable pageable) {
        return groupRepository.searchGroups(
            request.getQuery(),
            request.getCategory(),
            request.getVisibility(),
            request.getLocation(),
            pageable
        );
    }
    
    public List<Group> getRecommendedGroups(String userId, int limit) {
        // Get user's interests and connections for recommendations
        User user = userService.findById(userId);
        List<String> userInterests = profileService.getUserInterests(userId);
        List<String> connectionIds = connectionService.getConnectionIds(userId);
        
        return groupRepository.findRecommendedGroups(
            userId, userInterests, connectionIds, user.getProfileType(), limit);
    }
    
    private void validateGroupCreationPermissions(String userId) {
        // Check if user can create groups (e.g., profile completion, account status)
        User user = userService.findById(userId);
        if (user.getProfileCompletion() < 50) {
            throw new InsufficientPermissionsException(
                "Profile must be at least 50% complete to create groups");
        }
        
        // Check group creation limits
        long userGroupCount = groupRepository.countByCreatedBy(userId);
        if (userGroupCount >= 5) { // Max 5 groups per user
            throw new GroupLimitExceededException("Maximum group creation limit reached");
        }
    }
    
    private void validateJoinPermissions(Group group, String userId, String inviteCode) {
        if (group.getStatus() != GroupStatus.ACTIVE) {
            throw new GroupNotActiveException("Group is not active");
        }
        
        if (group.getMemberCount() >= group.getMaxMembers()) {
            throw new GroupFullException("Group has reached maximum member capacity");
        }
        
        if (group.getVisibility() == GroupVisibility.PRIVATE && 
            (inviteCode == null || !group.getInviteCode().equals(inviteCode))) {
            throw new InvalidInviteCodeException("Valid invite code required for private group");
        }
    }
}
```

### **Groups Database Schema**
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

-- Group posts and discussions
CREATE TABLE group_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(500),
    content TEXT NOT NULL,
    post_type VARCHAR(50) DEFAULT 'discussion' CHECK (post_type IN ('discussion', 'announcement', 'poll', 'event')),
    pinned BOOLEAN DEFAULT false,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for groups
CREATE INDEX idx_groups_category ON groups(category);
CREATE INDEX idx_groups_visibility ON groups(visibility);
CREATE INDEX idx_groups_created_by ON groups(created_by);
CREATE INDEX idx_groups_status ON groups(status);

CREATE INDEX idx_group_memberships_group_user ON group_memberships(group_id, user_id);
CREATE INDEX idx_group_memberships_user ON group_memberships(user_id);
CREATE INDEX idx_group_memberships_status ON group_memberships(status);

CREATE INDEX idx_group_posts_group_id ON group_posts(group_id);
CREATE INDEX idx_group_posts_author_id ON group_posts(author_id);
CREATE INDEX idx_group_posts_created_at ON group_posts(created_at);
```

## 📅 **Events Management System**

### **Events Service Implementation**
```java
// Backend: EventsService.java
@Service
@Slf4j
@Transactional
public class EventsService {
    
    @Autowired
    private EventRepository eventRepository;
    
    @Autowired
    private EventAttendeeRepository attendeeRepository;
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private CalendarService calendarService;
    
    public Event createEvent(CreateEventRequest request, String organizerId) {
        validateEventCreationPermissions(organizerId);
        
        Event event = Event.builder()
            .title(request.getTitle())
            .description(request.getDescription())
            .eventType(request.getEventType())
            .startDateTime(request.getStartDateTime())
            .endDateTime(request.getEndDateTime())
            .timezone(request.getTimezone())
            .location(request.getLocation())
            .virtualMeetingUrl(request.getVirtualMeetingUrl())
            .maxAttendees(request.getMaxAttendees())
            .registrationRequired(request.isRegistrationRequired())
            .registrationDeadline(request.getRegistrationDeadline())
            .organizerId(organizerId)
            .status(EventStatus.PUBLISHED)
            .visibility(request.getVisibility())
            .tags(request.getTags())
            .build();
        
        event = eventRepository.save(event);
        
        // Auto-register organizer
        EventAttendee organizerAttendee = EventAttendee.builder()
            .eventId(event.getId())
            .userId(organizerId)
            .status(AttendeeStatus.CONFIRMED)
            .role(AttendeeRole.ORGANIZER)
            .registeredAt(LocalDateTime.now())
            .build();
        
        attendeeRepository.save(organizerAttendee);
        
        // Send notifications to relevant users
        notifyRelevantUsers(event);
        
        log.info("Event created: {} by user {}", event.getId(), organizerId);
        return event;
    }
    
    public EventAttendee rsvpToEvent(String eventId, String userId, RSVPRequest request) {
        Event event = eventRepository.findById(eventId)
            .orElseThrow(() -> new EventNotFoundException("Event not found: " + eventId));
        
        validateRSVPPermissions(event, userId);
        
        Optional<EventAttendee> existingRSVP = 
            attendeeRepository.findByEventIdAndUserId(eventId, userId);
        
        EventAttendee attendee;
        if (existingRSVP.isPresent()) {
            // Update existing RSVP
            attendee = existingRSVP.get();
            attendee.setStatus(request.getStatus());
            attendee.setUpdatedAt(LocalDateTime.now());
        } else {
            // Create new RSVP
            attendee = EventAttendee.builder()
                .eventId(eventId)
                .userId(userId)
                .status(request.getStatus())
                .role(AttendeeRole.ATTENDEE)
                .registeredAt(LocalDateTime.now())
                .dietaryRestrictions(request.getDietaryRestrictions())
                .specialRequests(request.getSpecialRequests())
                .build();
        }
        
        attendee = attendeeRepository.save(attendee);
        
        // Update event attendee count
        updateEventAttendeeCount(eventId);
        
        // Add to user's calendar if confirmed
        if (request.getStatus() == AttendeeStatus.CONFIRMED) {
            calendarService.addEventToUserCalendar(userId, event);
        }
        
        // Notify organizer
        notificationService.sendEventRSVPNotification(event.getOrganizerId(), userId, event, request.getStatus());
        
        return attendee;
    }
    
    public Page<Event> searchEvents(EventSearchRequest request, Pageable pageable) {
        return eventRepository.searchEvents(
            request.getQuery(),
            request.getEventType(),
            request.getLocation(),
            request.getDateRange(),
            request.getTags(),
            pageable
        );
    }
    
    public List<Event> getRecommendedEvents(String userId, int limit) {
        User user = userService.findById(userId);
        List<String> userInterests = profileService.getUserInterests(userId);
        String userLocation = user.getLocation();
        
        return eventRepository.findRecommendedEvents(
            userId, userInterests, userLocation, user.getProfileType(), limit);
    }
    
    private void validateEventCreationPermissions(String userId) {
        User user = userService.findById(userId);
        if (user.getProfileCompletion() < 70) {
            throw new InsufficientPermissionsException(
                "Profile must be at least 70% complete to create events");
        }
    }
    
    private void validateRSVPPermissions(Event event, String userId) {
        if (event.getStatus() != EventStatus.PUBLISHED) {
            throw new EventNotAvailableException("Event is not available for registration");
        }
        
        if (event.getRegistrationDeadline() != null && 
            LocalDateTime.now().isAfter(event.getRegistrationDeadline())) {
            throw new RegistrationClosedException("Registration deadline has passed");
        }
        
        if (event.getMaxAttendees() != null) {
            long confirmedCount = attendeeRepository.countByEventIdAndStatus(
                event.getId(), AttendeeStatus.CONFIRMED);
            if (confirmedCount >= event.getMaxAttendees()) {
                throw new EventFullException("Event has reached maximum capacity");
            }
        }
    }
}
```

### **Events Database Schema**
```sql
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

-- Event sessions (for multi-session events)
CREATE TABLE event_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    speaker_id UUID REFERENCES users(id),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    location VARCHAR(500),
    session_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for events
CREATE INDEX idx_events_organizer_id ON events(organizer_id);
CREATE INDEX idx_events_event_type ON events(event_type);
CREATE INDEX idx_events_start_date ON events(start_date_time);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_location ON events(location);

CREATE INDEX idx_event_attendees_event_user ON event_attendees(event_id, user_id);
CREATE INDEX idx_event_attendees_user ON event_attendees(user_id);
CREATE INDEX idx_event_attendees_status ON event_attendees(status);

CREATE INDEX idx_event_sessions_event_id ON event_sessions(event_id);
CREATE INDEX idx_event_sessions_speaker_id ON event_sessions(speaker_id);
CREATE INDEX idx_event_sessions_start_time ON event_sessions(start_time);
```

## 🛒 **Marketplace System**

### **Marketplace Service Implementation**
```java
// Backend: MarketplaceService.java
@Service
@Slf4j
@Transactional
public class MarketplaceService {
    
    @Autowired
    private MarketplaceListingRepository listingRepository;
    
    @Autowired
    private MarketplaceTransactionRepository transactionRepository;
    
    @Autowired
    private NotificationService notificationService;
    
    public MarketplaceListing createListing(CreateListingRequest request, String sellerId) {
        validateListingCreationPermissions(sellerId);
        
        MarketplaceListing listing = MarketplaceListing.builder()
            .title(request.getTitle())
            .description(request.getDescription())
            .category(request.getCategory())
            .listingType(request.getListingType())
            .price(request.getPrice())
            .currency(request.getCurrency())
            .negotiable(request.isNegotiable())
            .sellerId(sellerId)
            .status(ListingStatus.ACTIVE)
            .location(request.getLocation())
            .tags(request.getTags())
            .images(request.getImages())
            .contactMethod(request.getContactMethod())
            .build();
        
        listing = listingRepository.save(listing);
        
        log.info("Marketplace listing created: {} by user {}", listing.getId(), sellerId);
        return listing;
    }
    
    public MarketplaceTransaction initiateTransaction(String listingId, String buyerId, 
                                                    InitiateTransactionRequest request) {
        MarketplaceListing listing = listingRepository.findById(listingId)
            .orElseThrow(() -> new ListingNotFoundException("Listing not found: " + listingId));
        
        validateTransactionPermissions(listing, buyerId);
        
        MarketplaceTransaction transaction = MarketplaceTransaction.builder()
            .listingId(listingId)
            .sellerId(listing.getSellerId())
            .buyerId(buyerId)
            .amount(request.getOfferedAmount())
            .currency(listing.getCurrency())
            .status(TransactionStatus.INITIATED)
            .message(request.getMessage())
            .build();
        
        transaction = transactionRepository.save(transaction);
        
        // Notify seller
        notificationService.sendMarketplaceInquiryNotification(
            listing.getSellerId(), buyerId, listing, transaction);
        
        return transaction;
    }
    
    public Page<MarketplaceListing> searchListings(MarketplaceSearchRequest request, Pageable pageable) {
        return listingRepository.searchListings(
            request.getQuery(),
            request.getCategory(),
            request.getListingType(),
            request.getLocation(),
            request.getPriceRange(),
            pageable
        );
    }
}
```

---

## 📚 **Reference Documents**

**Core API Development**: See `/4_backend_implementation/1_core_api_development.md`
**Database Schema**: See `/2_technical_architecture/2_database_schema_and_design.md`
**API Specifications**: See `/2_technical_architecture/3_api_specifications_and_endpoints.md`
**Frontend Implementation**: See `/5_frontend_implementation/2_user_interface_implementation.md`

*This advanced community features implementation provides comprehensive Groups, Events, and Marketplace functionality for enhanced user engagement and community building on the ZbInnovation platform.*
