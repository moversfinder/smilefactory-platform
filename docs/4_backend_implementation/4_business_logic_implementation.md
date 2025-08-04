# 4. Business Logic Implementation

## 🏢 **Business Logic Implementation Overview**

This document outlines the comprehensive business logic implementation for the ZbInnovation platform, including service layer architecture, profile type-specific logic, AI integration services, and business rule enforcement.

## 🏗️ **Service Layer Architecture**

### **Base Service Pattern**
```java
@Transactional
@Slf4j
public abstract class BaseService<T extends BaseEntity, R extends BaseRepository<T>> {
    
    protected final R repository;
    protected final ApplicationEventPublisher eventPublisher;
    
    public BaseService(R repository, ApplicationEventPublisher eventPublisher) {
        this.repository = repository;
        this.eventPublisher = eventPublisher;
    }
    
    @Transactional(readOnly = true)
    public Optional<T> findById(String id) {
        return repository.findById(id);
    }
    
    @Transactional(readOnly = true)
    public Page<T> findAll(Pageable pageable) {
        return repository.findAll(pageable);
    }
    
    public T save(T entity) {
        T savedEntity = repository.save(entity);
        publishEntityEvent(savedEntity, EntityEventType.CREATED);
        return savedEntity;
    }
    
    public T update(T entity) {
        T updatedEntity = repository.save(entity);
        publishEntityEvent(updatedEntity, EntityEventType.UPDATED);
        return updatedEntity;
    }
    
    public void deleteById(String id) {
        T entity = findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Entity not found with id: " + id));
        repository.deleteById(id);
        publishEntityEvent(entity, EntityEventType.DELETED);
    }
    
    protected void publishEntityEvent(T entity, EntityEventType eventType) {
        EntityEvent<T> event = new EntityEvent<>(entity, eventType);
        eventPublisher.publishEvent(event);
    }
    
    protected abstract void validateBusinessRules(T entity);
    protected abstract void enrichEntity(T entity);
}
```

### **Profile Management Service**
```java
@Service
@Transactional
@Slf4j
public class ProfileService extends BaseService<PersonalDetails, PersonalDetailsRepository> {
    
    @Autowired
    private ProfileCompletionService profileCompletionService;
    
    @Autowired
    private ProfileValidationService profileValidationService;
    
    @Autowired
    private AIRecommendationService aiRecommendationService;
    
    @Autowired
    private NotificationService notificationService;
    
    public ProfileService(PersonalDetailsRepository repository, ApplicationEventPublisher eventPublisher) {
        super(repository, eventPublisher);
    }
    
    public PersonalDetails createProfile(CreateProfileRequest request) {
        log.info("Creating profile for email: {}", request.getEmail());
        
        // Validate business rules
        validateEmailUniqueness(request.getEmail());
        validateProfileTypeRequirements(request);
        
        // Create base profile
        PersonalDetails profile = PersonalDetails.builder()
            .email(request.getEmail())
            .passwordHash(passwordService.hashPassword(request.getPassword()))
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .profileType(request.getProfileType())
            .profileState(ProfileState.DRAFT)
            .profileVisibility(ProfileVisibility.PUBLIC)
            .profileCompletion(0)
            .isVerified(false)
            .emailVerified(false)
            .build();
        
        // Enrich with initial data
        enrichEntity(profile);
        
        // Save profile
        PersonalDetails savedProfile = save(profile);
        
        // Create profile type-specific data
        createProfileTypeSpecificData(savedProfile);
        
        // Calculate initial completion
        updateProfileCompletion(savedProfile.getId());
        
        // Send welcome email
        notificationService.sendWelcomeEmail(savedProfile);
        
        // Generate AI recommendations
        aiRecommendationService.generateInitialRecommendations(savedProfile.getId());
        
        log.info("Profile created successfully for user: {}", savedProfile.getId());
        return savedProfile;
    }
    
    public PersonalDetails updateProfile(String userId, UpdateProfileRequest request) {
        log.info("Updating profile for user: {}", userId);
        
        PersonalDetails profile = findById(userId)
            .orElseThrow(() -> new EntityNotFoundException("Profile not found"));
        
        // Validate update permissions
        validateUpdatePermissions(profile, request);
        
        // Apply updates
        applyProfileUpdates(profile, request);
        
        // Validate business rules
        validateBusinessRules(profile);
        
        // Update profile
        PersonalDetails updatedProfile = update(profile);
        
        // Recalculate completion
        updateProfileCompletion(userId);
        
        // Update AI embeddings
        aiRecommendationService.updateUserEmbeddings(userId);
        
        log.info("Profile updated successfully for user: {}", userId);
        return updatedProfile;
    }
    
    @Override
    protected void validateBusinessRules(PersonalDetails profile) {
        profileValidationService.validateProfile(profile);
        
        // Profile type-specific validation
        switch (profile.getProfileType()) {
            case INNOVATOR:
                validateInnovatorProfile(profile);
                break;
            case BUSINESS_INVESTOR:
                validateInvestorProfile(profile);
                break;
            case MENTOR:
                validateMentorProfile(profile);
                break;
            // Add other profile types
        }
    }
    
    @Override
    protected void enrichEntity(PersonalDetails profile) {
        // Set default values
        if (profile.getRole() == null) {
            profile.setRole("USER");
        }
        
        // Generate profile name
        if (profile.getProfileName() == null && profile.getFirstName() != null && profile.getLastName() != null) {
            profile.setProfileName(profile.getFirstName() + " " + profile.getLastName());
        }
        
        // Set initial completion
        profile.setProfileCompletion(profileCompletionService.calculateCompletion(profile));
    }
    
    private void createProfileTypeSpecificData(PersonalDetails profile) {
        switch (profile.getProfileType()) {
            case INNOVATOR:
                createInnovatorProfile(profile);
                break;
            case BUSINESS_INVESTOR:
                createInvestorProfile(profile);
                break;
            case MENTOR:
                createMentorProfile(profile);
                break;
            // Add other profile types
        }
    }
    
    private void createInnovatorProfile(PersonalDetails user) {
        InnovatorProfile innovatorProfile = InnovatorProfile.builder()
            .user(user)
            .innovationStage("Idea")
            .teamSize(1)
            .build();
        
        innovatorProfileRepository.save(innovatorProfile);
        log.info("Created innovator profile for user: {}", user.getId());
    }
    
    public void updateProfileCompletion(String userId) {
        PersonalDetails profile = findById(userId)
            .orElseThrow(() -> new EntityNotFoundException("Profile not found"));
        
        int completion = profileCompletionService.calculateCompletion(profile);
        int previousCompletion = profile.getProfileCompletion();
        
        profile.setProfileCompletion(completion);
        
        // Update profile state based on completion
        if (completion >= 60 && profile.getProfileState() == ProfileState.DRAFT) {
            profile.setProfileState(ProfileState.INCOMPLETE);
        } else if (completion >= 80 && profile.getProfileState() == ProfileState.INCOMPLETE) {
            profile.setProfileState(ProfileState.COMPLETE);
            
            // Trigger completion event
            eventPublisher.publishEvent(new ProfileCompletedEvent(profile));
        }
        
        repository.save(profile);
        
        // Send completion milestone notifications
        if (completion > previousCompletion && completion % 20 == 0) {
            notificationService.sendCompletionMilestoneNotification(profile, completion);
        }
    }
}
```

## 🎯 **Profile Type-Specific Business Logic**

### **Innovator Business Logic**
```java
@Service
@Transactional
@Slf4j
public class InnovatorBusinessService {
    
    @Autowired
    private InnovatorProfileRepository innovatorRepository;
    
    @Autowired
    private FundingOpportunityService fundingOpportunityService;
    
    @Autowired
    private TeamMatchingService teamMatchingService;
    
    public InnovatorProfile updateInnovatorProfile(String userId, UpdateInnovatorRequest request) {
        InnovatorProfile profile = innovatorRepository.findByUserId(userId)
            .orElseThrow(() -> new EntityNotFoundException("Innovator profile not found"));
        
        // Apply updates
        if (request.getIndustryFocus() != null) {
            profile.setIndustryFocus(request.getIndustryFocus());
        }
        
        if (request.getInnovationStage() != null) {
            validateInnovationStageTransition(profile.getInnovationStage(), request.getInnovationStage());
            profile.setInnovationStage(request.getInnovationStage());
        }
        
        if (request.getFundingAmountNeeded() != null) {
            validateFundingAmount(request.getFundingAmountNeeded());
            profile.setFundingAmountNeeded(request.getFundingAmountNeeded());
        }
        
        InnovatorProfile updatedProfile = innovatorRepository.save(profile);
        
        // Trigger business logic based on updates
        if (request.getFundingAmountNeeded() != null) {
            fundingOpportunityService.findMatchingOpportunities(userId);
        }
        
        if (request.getTeamSize() != null && request.getTeamSize() < 5) {
            teamMatchingService.suggestTeamMembers(userId);
        }
        
        return updatedProfile;
    }
    
    public List<FundingOpportunity> getFundingRecommendations(String userId) {
        InnovatorProfile profile = innovatorRepository.findByUserId(userId)
            .orElseThrow(() -> new EntityNotFoundException("Innovator profile not found"));
        
        return fundingOpportunityService.findRecommendations(
            profile.getIndustryFocus(),
            profile.getInnovationStage(),
            profile.getFundingAmountNeeded()
        );
    }
    
    public InnovationMetrics getInnovationMetrics(String userId) {
        InnovatorProfile profile = innovatorRepository.findByUserId(userId)
            .orElseThrow(() -> new EntityNotFoundException("Innovator profile not found"));
        
        return InnovationMetrics.builder()
            .profileViews(analyticsService.getProfileViews(userId))
            .investorInterest(investorInterestService.getInterestLevel(userId))
            .networkGrowth(connectionService.getNetworkGrowthRate(userId))
            .contentEngagement(contentService.getEngagementMetrics(userId))
            .fundingReadiness(assessFundingReadiness(profile))
            .build();
    }
    
    private void validateInnovationStageTransition(String currentStage, String newStage) {
        List<String> validTransitions = getValidStageTransitions(currentStage);
        if (!validTransitions.contains(newStage)) {
            throw new InvalidStageTransitionException(
                "Invalid stage transition from " + currentStage + " to " + newStage);
        }
    }
    
    private List<String> getValidStageTransitions(String currentStage) {
        Map<String, List<String>> transitions = Map.of(
            "Idea", Arrays.asList("Prototype", "MVP"),
            "Prototype", Arrays.asList("MVP", "Beta"),
            "MVP", Arrays.asList("Beta", "Scaling"),
            "Beta", Arrays.asList("Scaling", "Growth"),
            "Scaling", Arrays.asList("Growth", "Mature")
        );
        
        return transitions.getOrDefault(currentStage, Collections.emptyList());
    }
    
    private FundingReadiness assessFundingReadiness(InnovatorProfile profile) {
        int score = 0;
        
        // Business model clarity
        if (profile.getBusinessModel() != null && !profile.getBusinessModel().isEmpty()) {
            score += 20;
        }
        
        // Market validation
        if (profile.getTargetMarket() != null && !profile.getTargetMarket().isEmpty()) {
            score += 20;
        }
        
        // Competitive advantage
        if (profile.getCompetitiveAdvantage() != null && !profile.getCompetitiveAdvantage().isEmpty()) {
            score += 20;
        }
        
        // Team size
        if (profile.getTeamSize() != null && profile.getTeamSize() >= 2) {
            score += 20;
        }
        
        // Innovation stage
        if (Arrays.asList("MVP", "Beta", "Scaling").contains(profile.getInnovationStage())) {
            score += 20;
        }
        
        return FundingReadiness.fromScore(score);
    }
}
```

### **Business Investor Logic**
```java
@Service
@Transactional
@Slf4j
public class BusinessInvestorService {
    
    @Autowired
    private BusinessInvestorProfileRepository investorRepository;
    
    @Autowired
    private InvestmentMatchingService matchingService;
    
    @Autowired
    private DueDiligenceService dueDiligenceService;
    
    public List<InvestmentOpportunity> getMatchingOpportunities(String userId) {
        BusinessInvestorProfile investor = investorRepository.findByUserId(userId)
            .orElseThrow(() -> new EntityNotFoundException("Investor profile not found"));
        
        InvestmentCriteria criteria = InvestmentCriteria.builder()
            .investmentFocus(investor.getInvestmentFocus())
            .stagePreference(investor.getInvestmentStagePreference())
            .ticketSizeMin(investor.getTicketSizeMin())
            .ticketSizeMax(investor.getTicketSizeMax())
            .geographicFocus(investor.getGeographicFocus())
            .build();
        
        return matchingService.findMatchingOpportunities(criteria);
    }
    
    public InvestmentDecision evaluateInvestmentOpportunity(String investorId, String innovatorId) {
        BusinessInvestorProfile investor = investorRepository.findByUserId(investorId)
            .orElseThrow(() -> new EntityNotFoundException("Investor profile not found"));
        
        InnovatorProfile innovator = innovatorRepository.findByUserId(innovatorId)
            .orElseThrow(() -> new EntityNotFoundException("Innovator profile not found"));
        
        // Perform automated due diligence
        DueDiligenceReport report = dueDiligenceService.generateReport(innovator);
        
        // Calculate investment score
        int investmentScore = calculateInvestmentScore(investor, innovator, report);
        
        return InvestmentDecision.builder()
            .investorId(investorId)
            .innovatorId(innovatorId)
            .score(investmentScore)
            .recommendation(getRecommendation(investmentScore))
            .dueDiligenceReport(report)
            .riskFactors(identifyRiskFactors(innovator))
            .opportunities(identifyOpportunities(innovator))
            .build();
    }
    
    private int calculateInvestmentScore(BusinessInvestorProfile investor, 
                                       InnovatorProfile innovator, 
                                       DueDiligenceReport report) {
        int score = 0;
        
        // Industry alignment
        if (investor.getInvestmentFocus().contains(innovator.getIndustryFocus())) {
            score += 25;
        }
        
        // Stage alignment
        if (investor.getInvestmentStagePreference().contains(innovator.getInnovationStage())) {
            score += 25;
        }
        
        // Funding amount fit
        BigDecimal fundingNeeded = innovator.getFundingAmountNeeded();
        if (fundingNeeded != null && 
            fundingNeeded.compareTo(investor.getTicketSizeMin()) >= 0 &&
            fundingNeeded.compareTo(investor.getTicketSizeMax()) <= 0) {
            score += 25;
        }
        
        // Due diligence score
        score += (report.getOverallScore() / 4); // Scale to 25 points
        
        return Math.min(score, 100);
    }
}
```

## 🤖 **AI Integration Services**

### **AI Recommendation Service**
```java
@Service
@Slf4j
public class AIRecommendationService {
    
    @Autowired
    private OpenAIService openAIService;
    
    @Autowired
    private UserEmbeddingService embeddingService;
    
    @Autowired
    private RecommendationRepository recommendationRepository;
    
    @Async
    public CompletableFuture<Void> generateInitialRecommendations(String userId) {
        try {
            PersonalDetails user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
            
            // Generate user embeddings
            embeddingService.generateUserEmbeddings(userId);
            
            // Generate profile-specific recommendations
            List<Recommendation> recommendations = generateProfileRecommendations(user);
            
            // Save recommendations
            recommendationRepository.saveAll(recommendations);
            
            log.info("Generated {} initial recommendations for user: {}", recommendations.size(), userId);
            
        } catch (Exception e) {
            log.error("Failed to generate initial recommendations for user: {}", userId, e);
        }
        
        return CompletableFuture.completedFuture(null);
    }
    
    public List<Recommendation> getPersonalizedRecommendations(String userId, RecommendationType type) {
        PersonalDetails user = userRepository.findById(userId)
            .orElseThrow(() -> new EntityNotFoundException("User not found"));
        
        switch (type) {
            case CONNECTIONS:
                return generateConnectionRecommendations(user);
            case CONTENT:
                return generateContentRecommendations(user);
            case OPPORTUNITIES:
                return generateOpportunityRecommendations(user);
            case LEARNING:
                return generateLearningRecommendations(user);
            default:
                return Collections.emptyList();
        }
    }
    
    private List<Recommendation> generateConnectionRecommendations(PersonalDetails user) {
        // Get user embedding
        UserEmbedding userEmbedding = embeddingService.getUserEmbedding(user.getId());
        
        // Find similar users
        List<UserEmbedding> similarUsers = embeddingService.findSimilarUsers(
            userEmbedding.getProfileEmbedding(), 10);
        
        return similarUsers.stream()
            .filter(similar -> !similar.getUserId().equals(user.getId()))
            .filter(similar -> !connectionService.areConnected(user.getId(), similar.getUserId()))
            .map(similar -> createConnectionRecommendation(user.getId(), similar.getUserId()))
            .collect(Collectors.toList());
    }
    
    private List<Recommendation> generateContentRecommendations(PersonalDetails user) {
        // Get user interests and activity
        UserInterests interests = userInterestService.getUserInterests(user.getId());
        
        // Find relevant content
        List<Post> relevantPosts = contentService.findRelevantContent(
            interests.getTopics(),
            user.getProfileType(),
            20
        );
        
        return relevantPosts.stream()
            .map(post -> createContentRecommendation(user.getId(), post.getId()))
            .collect(Collectors.toList());
    }
    
    @Async
    public CompletableFuture<Void> updateUserEmbeddings(String userId) {
        try {
            embeddingService.updateUserEmbeddings(userId);
            
            // Refresh recommendations based on updated embeddings
            refreshRecommendations(userId);
            
        } catch (Exception e) {
            log.error("Failed to update user embeddings for user: {}", userId, e);
        }
        
        return CompletableFuture.completedFuture(null);
    }
    
    private void refreshRecommendations(String userId) {
        // Remove old recommendations
        recommendationRepository.deleteByUserIdAndCreatedAtBefore(
            userId, LocalDateTime.now().minusDays(7));
        
        // Generate new recommendations
        generateInitialRecommendations(userId);
    }
}
```

## 📊 **Business Rule Enforcement**

### **Business Rule Engine**
```java
@Service
@Slf4j
public class BusinessRuleEngine {
    
    private final Map<String, BusinessRule> rules = new HashMap<>();
    
    @PostConstruct
    public void initializeRules() {
        // Profile completion rules
        registerRule("profile.completion.minimum", new MinimumProfileCompletionRule());
        registerRule("profile.verification.required", new ProfileVerificationRule());
        
        // Content creation rules
        registerRule("content.creation.limits", new ContentCreationLimitsRule());
        registerRule("content.moderation.required", new ContentModerationRule());
        
        // Connection rules
        registerRule("connection.limits.daily", new DailyConnectionLimitsRule());
        registerRule("connection.spam.prevention", new ConnectionSpamPreventionRule());
        
        // Investment rules
        registerRule("investment.eligibility", new InvestmentEligibilityRule());
        registerRule("investment.amount.validation", new InvestmentAmountValidationRule());
    }
    
    public void registerRule(String ruleId, BusinessRule rule) {
        rules.put(ruleId, rule);
        log.info("Registered business rule: {}", ruleId);
    }
    
    public BusinessRuleResult validateRule(String ruleId, BusinessRuleContext context) {
        BusinessRule rule = rules.get(ruleId);
        if (rule == null) {
            throw new BusinessRuleNotFoundException("Rule not found: " + ruleId);
        }
        
        return rule.validate(context);
    }
    
    public List<BusinessRuleResult> validateAllRules(BusinessRuleContext context, String category) {
        return rules.entrySet().stream()
            .filter(entry -> entry.getKey().startsWith(category))
            .map(entry -> entry.getValue().validate(context))
            .collect(Collectors.toList());
    }
    
    public void enforceRule(String ruleId, BusinessRuleContext context) {
        BusinessRuleResult result = validateRule(ruleId, context);
        
        if (!result.isValid()) {
            throw new BusinessRuleViolationException(
                "Business rule violation: " + ruleId + " - " + result.getMessage());
        }
    }
}

// Example business rule implementation
@Component
public class MinimumProfileCompletionRule implements BusinessRule {
    
    @Override
    public BusinessRuleResult validate(BusinessRuleContext context) {
        PersonalDetails user = (PersonalDetails) context.get("user");
        String action = (String) context.get("action");
        
        int requiredCompletion = getRequiredCompletion(action);
        
        if (user.getProfileCompletion() < requiredCompletion) {
            return BusinessRuleResult.invalid(
                String.format("Profile completion must be at least %d%% to perform this action", 
                    requiredCompletion));
        }
        
        return BusinessRuleResult.valid();
    }
    
    private int getRequiredCompletion(String action) {
        Map<String, Integer> requirements = Map.of(
            "create_post", 30,
            "send_connection", 50,
            "create_event", 70,
            "access_marketplace", 60
        );
        
        return requirements.getOrDefault(action, 0);
    }
}
```

---

## 📚 **Reference Documents**

**Core API Development**: See `/4_backend_implementation/1_core_api_development.md`
**Database Implementation**: See `/4_backend_implementation/2_database_implementation.md`
**Authentication Security**: See `/4_backend_implementation/3_authentication_and_security.md`
**API Testing**: See `/4_backend_implementation/5_api_testing_and_validation.md`

*This business logic implementation provides comprehensive service layer architecture and business rule enforcement for the ZbInnovation platform.*
