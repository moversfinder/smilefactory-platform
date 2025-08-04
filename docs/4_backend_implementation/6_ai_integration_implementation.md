# 6. AI Integration Implementation

## 🤖 **AI Integration Overview**

This document outlines the comprehensive AI integration implementation for the ZbInnovation platform, including DeepSeek API integration, streaming responses, context-aware assistance, RAG vs text2sql selection, and AI-powered features across the platform.

## 🏗️ **AI Service Architecture**

### **AI Integration Stack**
```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend AI Components                  │
│         (Chat Interface, Trigger Buttons, Streaming)       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    AI Gateway Service                      │
│        (Request Routing, Context Building, Caching)        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   DeepSeek API  │  │   Context       │  │   Vector DB     │
│   Integration   │  │   Builder       │  │   (pgvector)    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Database Layer                          │
│     (User Context, Conversation History, Preferences)      │
└─────────────────────────────────────────────────────────────┘
```

### **AI Service Configuration**
```java
// Backend: AIServiceConfig.java
@Configuration
@EnableConfigurationProperties(AIProperties.class)
public class AIServiceConfig {
    
    @Value("${ai.deepseek.api-key}")
    private String deepSeekApiKey;
    
    @Value("${ai.deepseek.base-url}")
    private String deepSeekBaseUrl;
    
    @Bean
    public WebClient aiWebClient() {
        return WebClient.builder()
            .baseUrl(deepSeekBaseUrl)
            .defaultHeader("Authorization", "Bearer " + deepSeekApiKey)
            .defaultHeader("Content-Type", "application/json")
            .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024))
            .build();
    }
    
    @Bean
    public AIContextBuilder aiContextBuilder() {
        return new AIContextBuilder();
    }
    
    @Bean
    public ConversationMemoryService conversationMemoryService() {
        return new ConversationMemoryService();
    }
}

@ConfigurationProperties(prefix = "ai")
@Data
public class AIProperties {
    private DeepSeek deepseek = new DeepSeek();
    private Context context = new Context();
    private Features features = new Features();
    
    @Data
    public static class DeepSeek {
        private String apiKey;
        private String baseUrl = "https://api.deepseek.com";
        private String model = "deepseek-chat";
        private Integer maxTokens = 4000;
        private Double temperature = 0.7;
        private Boolean stream = true;
    }
    
    @Data
    public static class Context {
        private Integer maxHistoryMessages = 10;
        private Integer contextWindowSize = 8000;
        private Boolean enableRAG = true;
        private Boolean enableText2SQL = true;
    }
    
    @Data
    public static class Features {
        private Boolean profileAwareness = true;
        private Boolean authenticationAwareness = true;
        private Boolean contextAwareness = true;
        private Boolean quickReplies = true;
        private Boolean databaseIntegration = true;
    }
}
```

## 🔄 **AI Chat Service Implementation**

### **Core AI Chat Service**
```java
// Backend: AIChatService.java
@Service
@Slf4j
public class AIChatService {
    
    @Autowired
    private WebClient aiWebClient;
    
    @Autowired
    private AIContextBuilder contextBuilder;
    
    @Autowired
    private ConversationMemoryService memoryService;
    
    @Autowired
    private AIProperties aiProperties;
    
    public Flux<String> streamChatResponse(AIChatRequest request) {
        try {
            // Build context for the AI
            AIContext context = contextBuilder.buildContext(request);
            
            // Prepare the request payload
            DeepSeekChatRequest chatRequest = DeepSeekChatRequest.builder()
                .model(aiProperties.getDeepseek().getModel())
                .messages(buildMessages(context, request))
                .maxTokens(aiProperties.getDeepseek().getMaxTokens())
                .temperature(aiProperties.getDeepseek().getTemperature())
                .stream(true)
                .build();
            
            // Store conversation start
            memoryService.saveConversationStart(request.getUserId(), request.getMessage());
            
            return aiWebClient.post()
                .uri("/chat/completions")
                .bodyValue(chatRequest)
                .retrieve()
                .bodyToFlux(String.class)
                .map(this::parseStreamingResponse)
                .filter(Objects::nonNull)
                .doOnComplete(() -> {
                    // Save complete conversation
                    memoryService.saveConversationComplete(request.getUserId(), request.getConversationId());
                })
                .doOnError(error -> {
                    log.error("AI chat streaming error for user {}", request.getUserId(), error);
                    memoryService.saveConversationError(request.getUserId(), error.getMessage());
                });
                
        } catch (Exception e) {
            log.error("Failed to initiate AI chat for user {}", request.getUserId(), e);
            return Flux.error(new AIServiceException("Failed to process AI request", e));
        }
    }
    
    private List<ChatMessage> buildMessages(AIContext context, AIChatRequest request) {
        List<ChatMessage> messages = new ArrayList<>();
        
        // System message with context
        messages.add(ChatMessage.builder()
            .role("system")
            .content(buildSystemPrompt(context))
            .build());
        
        // Add conversation history
        List<ConversationMessage> history = memoryService.getConversationHistory(
            request.getUserId(), aiProperties.getContext().getMaxHistoryMessages());
        
        for (ConversationMessage msg : history) {
            messages.add(ChatMessage.builder()
                .role(msg.getRole())
                .content(msg.getContent())
                .build());
        }
        
        // Add current user message
        messages.add(ChatMessage.builder()
            .role("user")
            .content(request.getMessage())
            .build());
        
        return messages;
    }
    
    private String buildSystemPrompt(AIContext context) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("You are an AI assistant for ZbInnovation, Zimbabwe's premier innovation ecosystem platform. ");
        
        // Profile awareness
        if (context.getUser() != null) {
            prompt.append(String.format("You are assisting %s %s, a %s. ", 
                context.getUser().getFirstName(),
                context.getUser().getLastName(),
                context.getUser().getProfileType().getDisplayName()));
            
            if (context.getUser().getProfileCompletion() < 100) {
                prompt.append(String.format("Their profile is %d%% complete. ", 
                    context.getUser().getProfileCompletion()));
            }
        }
        
        // Context awareness
        if (context.getCurrentPage() != null) {
            prompt.append(String.format("The user is currently on the %s page. ", 
                context.getCurrentPage()));
        }
        
        // Platform-specific guidance
        prompt.append("Provide helpful, relevant advice for innovation, entrepreneurship, ");
        prompt.append("networking, and professional development in the Zimbabwean context. ");
        prompt.append("Be concise, actionable, and encouraging. ");
        
        // Quick replies guidance
        prompt.append("When appropriate, suggest quick action items or next steps. ");
        
        return prompt.toString();
    }
    
    private String parseStreamingResponse(String rawResponse) {
        try {
            if (rawResponse.startsWith("data: ")) {
                String jsonData = rawResponse.substring(6);
                if ("[DONE]".equals(jsonData.trim())) {
                    return null;
                }
                
                ObjectMapper mapper = new ObjectMapper();
                JsonNode response = mapper.readTree(jsonData);
                JsonNode choices = response.get("choices");
                
                if (choices != null && choices.isArray() && choices.size() > 0) {
                    JsonNode delta = choices.get(0).get("delta");
                    if (delta != null && delta.has("content")) {
                        return delta.get("content").asText();
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Failed to parse streaming response: {}", rawResponse, e);
        }
        return null;
    }
}
```

### **AI Context Builder**
```java
// Backend: AIContextBuilder.java
@Component
@Slf4j
public class AIContextBuilder {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private ProfileService profileService;
    
    @Autowired
    private ContentService contentService;
    
    @Autowired
    private VectorSearchService vectorSearchService;
    
    public AIContext buildContext(AIChatRequest request) {
        AIContext.AIContextBuilder contextBuilder = AIContext.builder();
        
        try {
            // User context
            User user = userService.findById(request.getUserId());
            contextBuilder.user(user);
            
            // Profile context
            if (user != null) {
                UserProfile profile = profileService.getUserProfile(user.getId());
                contextBuilder.profile(profile);
                
                // Profile completion context
                ProfileCompletion completion = profileService.getProfileCompletion(user.getId());
                contextBuilder.profileCompletion(completion);
            }
            
            // Page context
            contextBuilder.currentPage(request.getCurrentPage());
            contextBuilder.pageContext(request.getPageContext());
            
            // Recent activity context
            List<UserActivity> recentActivities = contentService.getRecentUserActivities(
                request.getUserId(), 10);
            contextBuilder.recentActivities(recentActivities);
            
            // Relevant content context (RAG)
            if (shouldUseRAG(request)) {
                List<RelevantContent> relevantContent = vectorSearchService.findRelevantContent(
                    request.getMessage(), request.getUserId(), 5);
                contextBuilder.relevantContent(relevantContent);
            }
            
            // Connection context
            List<Connection> connections = userService.getUserConnections(request.getUserId());
            contextBuilder.connections(connections);
            
            log.debug("Built AI context for user {} with {} components", 
                request.getUserId(), getContextComponentCount(contextBuilder.build()));
            
        } catch (Exception e) {
            log.error("Failed to build AI context for user {}", request.getUserId(), e);
            // Return minimal context to allow AI to still function
            contextBuilder.user(null).currentPage(request.getCurrentPage());
        }
        
        return contextBuilder.build();
    }
    
    private boolean shouldUseRAG(AIChatRequest request) {
        // Determine if RAG should be used based on query type
        String message = request.getMessage().toLowerCase();
        
        // Use RAG for content discovery, recommendations, and knowledge queries
        return message.contains("find") || 
               message.contains("recommend") || 
               message.contains("suggest") || 
               message.contains("who") || 
               message.contains("what") || 
               message.contains("how") ||
               message.contains("connect") ||
               message.contains("opportunity");
    }
    
    private int getContextComponentCount(AIContext context) {
        int count = 0;
        if (context.getUser() != null) count++;
        if (context.getProfile() != null) count++;
        if (context.getCurrentPage() != null) count++;
        if (context.getRecentActivities() != null) count += context.getRecentActivities().size();
        if (context.getRelevantContent() != null) count += context.getRelevantContent().size();
        if (context.getConnections() != null) count += context.getConnections().size();
        return count;
    }
}
```

## 🧠 **Conversation Memory Service**

### **Memory Management Implementation**
```java
// Backend: ConversationMemoryService.java
@Service
@Slf4j
public class ConversationMemoryService {
    
    @Autowired
    private ConversationRepository conversationRepository;
    
    @Autowired
    private ConversationMessageRepository messageRepository;
    
    @Autowired
    private VectorEmbeddingService embeddingService;
    
    public void saveConversationStart(String userId, String userMessage) {
        try {
            Conversation conversation = Conversation.builder()
                .userId(userId)
                .startedAt(LocalDateTime.now())
                .status(ConversationStatus.ACTIVE)
                .build();
            
            conversation = conversationRepository.save(conversation);
            
            // Save user message
            ConversationMessage message = ConversationMessage.builder()
                .conversationId(conversation.getId())
                .role("user")
                .content(userMessage)
                .timestamp(LocalDateTime.now())
                .build();
            
            messageRepository.save(message);
            
            // Generate and store embedding for semantic search
            embeddingService.generateAndStoreEmbedding(message);
            
        } catch (Exception e) {
            log.error("Failed to save conversation start for user {}", userId, e);
        }
    }
    
    public void saveAIResponse(String conversationId, String aiResponse) {
        try {
            ConversationMessage message = ConversationMessage.builder()
                .conversationId(conversationId)
                .role("assistant")
                .content(aiResponse)
                .timestamp(LocalDateTime.now())
                .build();
            
            messageRepository.save(message);
            
            // Generate embedding for AI response too
            embeddingService.generateAndStoreEmbedding(message);
            
        } catch (Exception e) {
            log.error("Failed to save AI response for conversation {}", conversationId, e);
        }
    }
    
    public List<ConversationMessage> getConversationHistory(String userId, int limit) {
        return messageRepository.findRecentByUserIdOrderByTimestampDesc(userId, limit);
    }
    
    public List<ConversationMessage> searchConversationHistory(String userId, String query) {
        // Use vector similarity search for semantic conversation history search
        return embeddingService.searchSimilarMessages(userId, query, 10);
    }
    
    public void saveConversationComplete(String userId, String conversationId) {
        try {
            conversationRepository.updateStatus(conversationId, ConversationStatus.COMPLETED);
            log.debug("Marked conversation {} as completed for user {}", conversationId, userId);
        } catch (Exception e) {
            log.error("Failed to mark conversation complete: {}", conversationId, e);
        }
    }
    
    public void saveConversationError(String userId, String errorMessage) {
        try {
            // Log error for analytics and debugging
            log.warn("AI conversation error for user {}: {}", userId, errorMessage);
        } catch (Exception e) {
            log.error("Failed to save conversation error for user {}", userId, e);
        }
    }
}
```

## 🎯 **Profile-Specific AI Triggers**

### **AI Trigger Service**
```java
// Backend: AITriggerService.java
@Service
@Slf4j
public class AITriggerService {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private ProfileService profileService;
    
    public List<AITrigger> getProfileSpecificTriggers(String userId, String currentPage) {
        try {
            User user = userService.findById(userId);
            if (user == null) {
                return getDefaultTriggers(currentPage);
            }
            
            ProfileType profileType = user.getProfileType();
            List<AITrigger> triggers = new ArrayList<>();
            
            // Add profile-specific triggers
            triggers.addAll(getProfileTypeTriggers(profileType));
            
            // Add page-specific triggers
            triggers.addAll(getPageSpecificTriggers(currentPage, profileType));
            
            // Add completion-based triggers
            if (user.getProfileCompletion() < 100) {
                triggers.addAll(getCompletionTriggers(user));
            }
            
            return triggers;
            
        } catch (Exception e) {
            log.error("Failed to get AI triggers for user {}", userId, e);
            return getDefaultTriggers(currentPage);
        }
    }
    
    private List<AITrigger> getProfileTypeTriggers(ProfileType profileType) {
        List<AITrigger> triggers = new ArrayList<>();
        
        switch (profileType) {
            case INNOVATOR:
                triggers.add(AITrigger.builder()
                    .id("find-funding")
                    .title("Find Funding Opportunities")
                    .description("AI helps discover relevant investors and funding sources")
                    .icon("💰")
                    .prompt("Help me find funding opportunities for my startup")
                    .category("funding")
                    .build());
                
                triggers.add(AITrigger.builder()
                    .id("build-team")
                    .title("Build Your Team")
                    .description("Assistance finding co-founders, developers, and team members")
                    .icon("👥")
                    .prompt("Help me find team members for my startup")
                    .category("team")
                    .build());
                
                triggers.add(AITrigger.builder()
                    .id("get-mentorship")
                    .title("Get Expert Mentorship")
                    .description("Connect with experienced mentors and advisors")
                    .icon("🎓")
                    .prompt("Help me find mentors in my industry")
                    .category("mentorship")
                    .build());
                break;
                
            case BUSINESS_INVESTOR:
                triggers.add(AITrigger.builder()
                    .id("discover-investments")
                    .title("Discover Investment Opportunities")
                    .description("AI-curated deal flow based on investment criteria")
                    .icon("📈")
                    .prompt("Show me investment opportunities matching my criteria")
                    .category("investment")
                    .build());
                
                triggers.add(AITrigger.builder()
                    .id("evaluate-startups")
                    .title("Evaluate Startups")
                    .description("Due diligence assistance and startup analysis")
                    .icon("🔍")
                    .prompt("Help me evaluate this startup opportunity")
                    .category("analysis")
                    .build());
                break;
                
            case MENTOR:
                triggers.add(AITrigger.builder()
                    .id("find-mentees")
                    .title("Find Mentees")
                    .description("Discover users seeking mentorship in your expertise areas")
                    .icon("🌱")
                    .prompt("Help me find mentees who need guidance in my expertise areas")
                    .category("mentoring")
                    .build());
                
                triggers.add(AITrigger.builder()
                    .id("share-knowledge")
                    .title("Share Knowledge")
                    .description("Suggestions for content creation and knowledge sharing")
                    .icon("📚")
                    .prompt("Help me create content to share my expertise")
                    .category("content")
                    .build());
                break;
                
            // Add other profile types...
        }
        
        return triggers;
    }
    
    private List<AITrigger> getPageSpecificTriggers(String currentPage, ProfileType profileType) {
        List<AITrigger> triggers = new ArrayList<>();
        
        if ("virtual-community".equals(currentPage)) {
            triggers.add(AITrigger.builder()
                .id("discover-content")
                .title("Discover Relevant Content")
                .description("Find posts and discussions relevant to your interests")
                .icon("🔍")
                .prompt("Help me find relevant content and discussions")
                .category("discovery")
                .build());
                
            triggers.add(AITrigger.builder()
                .id("networking-opportunities")
                .title("Find Networking Opportunities")
                .description("Discover people and events for networking")
                .icon("🤝")
                .prompt("Help me find networking opportunities")
                .category("networking")
                .build());
        }
        
        if ("dashboard".equals(currentPage)) {
            triggers.add(AITrigger.builder()
                .id("optimize-profile")
                .title("Optimize Your Profile")
                .description("Get suggestions to improve your profile visibility")
                .icon("⚡")
                .prompt("Help me optimize my profile for better visibility")
                .category("optimization")
                .build());
        }
        
        return triggers;
    }
}
```

---

## 📚 **Reference Documents**

**Backend Implementation**: See `/4_backend_implementation/1_core_api_development.md`
**Database Design**: See `/2_technical_architecture/2_database_design_and_schema.md`
**API Specifications**: See `/2_technical_architecture/3_api_specifications.md`
**Frontend Integration**: See `/5_frontend_implementation/4_state_management_implementation.md`

*This AI integration implementation provides comprehensive AI-powered assistance with DeepSeek API, streaming responses, context awareness, and profile-specific features for the ZbInnovation platform.*
