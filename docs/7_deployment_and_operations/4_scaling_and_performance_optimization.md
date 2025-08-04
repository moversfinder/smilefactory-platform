# 4. Scaling and Performance Optimization

## ⚡ **Scaling and Performance Overview**

This document outlines the comprehensive scaling and performance optimization strategy for the ZbInnovation platform, including horizontal and vertical scaling approaches, auto-scaling configurations, performance optimization techniques, and capacity planning.

## 🏗️ **Scaling Architecture Strategy**

### **Multi-Tier Scaling Approach**
```
┌─────────────────────────────────────────────────────────────┐
│                    Load Balancer                           │
│              (Auto-scaling based on traffic)               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    CDN Layer                               │
│         (Global edge caching and distribution)             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Frontend      │  │   API Gateway   │  │   WebSocket     │
│   (React)       │  │   (Rate Limit)  │  │   Service       │
│   Min: 2        │  │   Min: 2        │  │   Min: 1        │
│   Max: 10       │  │   Max: 20       │  │   Max: 5        │
└─────────────────┘  └─────────────────┘  └─────────────────┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Backend       │  │   Background    │  │   AI Services   │
│   (Spring Boot) │  │   Workers       │  │   (ML/AI)       │
│   Min: 3        │  │   Min: 2        │  │   Min: 1        │
│   Max: 50       │  │   Max: 20       │  │   Max: 10       │
└─────────────────┘  └─────────────────┘  └─────────────────┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Database      │  │   Cache Layer   │  │   Search        │
│   (Read Replicas)│  │   (Redis)       │  │   (Elasticsearch)│
│   Min: 1        │  │   Min: 1        │  │   Min: 1        │
│   Max: 5        │  │   Max: 10       │  │   Max: 5        │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## 🔄 **Horizontal Pod Autoscaler (HPA)**

### **Backend Service HPA Configuration**
```yaml
# k8s/backend-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: zbinnovation-backend-hpa
  namespace: zbinnovation-prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: zbinnovation-backend
  minReplicas: 3
  maxReplicas: 50
  metrics:
  # CPU utilization
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  
  # Memory utilization
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  
  # Custom metrics - requests per second
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
  
  # Custom metrics - response time
  - type: Pods
    pods:
      metric:
        name: http_request_duration_p95
      target:
        type: AverageValue
        averageValue: "500m"  # 500ms
  
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # 5 minutes
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Min
    
    scaleUp:
      stabilizationWindowSeconds: 60   # 1 minute
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
      - type: Pods
        value: 5
        periodSeconds: 60
      selectPolicy: Max

---
# Frontend HPA
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: zbinnovation-frontend-hpa
  namespace: zbinnovation-prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: zbinnovation-frontend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
```

### **Vertical Pod Autoscaler (VPA)**
```yaml
# k8s/backend-vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: zbinnovation-backend-vpa
  namespace: zbinnovation-prod
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: zbinnovation-backend
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: backend
      minAllowed:
        cpu: 100m
        memory: 256Mi
      maxAllowed:
        cpu: 2000m
        memory: 4Gi
      controlledResources: ["cpu", "memory"]
      controlledValues: RequestsAndLimits
```

## 🚀 **Performance Optimization Techniques**

### **Database Performance Optimization**
```java
// Backend: DatabaseOptimizationConfig.java
@Configuration
public class DatabaseOptimizationConfig {
    
    @Bean
    @Primary
    public DataSource primaryDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(primaryDbUrl);
        config.setUsername(dbUsername);
        config.setPassword(dbPassword);
        
        // Connection pool optimization
        config.setMaximumPoolSize(20);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        config.setLeakDetectionThreshold(60000);
        
        // Performance tuning
        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", "250");
        config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        config.addDataSourceProperty("useServerPrepStmts", "true");
        config.addDataSourceProperty("useLocalSessionState", "true");
        config.addDataSourceProperty("rewriteBatchedStatements", "true");
        config.addDataSourceProperty("cacheResultSetMetadata", "true");
        config.addDataSourceProperty("cacheServerConfiguration", "true");
        config.addDataSourceProperty("elideSetAutoCommits", "true");
        config.addDataSourceProperty("maintainTimeStats", "false");
        
        return new HikariDataSource(config);
    }
    
    @Bean
    @Qualifier("readOnlyDataSource")
    public DataSource readOnlyDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(readOnlyDbUrl);
        config.setUsername(dbUsername);
        config.setPassword(dbPassword);
        config.setReadOnly(true);
        
        // Optimized for read operations
        config.setMaximumPoolSize(15);
        config.setMinimumIdle(3);
        
        return new HikariDataSource(config);
    }
}

@Service
@Transactional(readOnly = true)
public class OptimizedQueryService {
    
    @Autowired
    @Qualifier("readOnlyDataSource")
    private DataSource readOnlyDataSource;
    
    // Optimized pagination with cursor-based approach
    @Cacheable(value = "posts", key = "#lastId + '_' + #limit")
    public List<PostDTO> getPostsOptimized(String lastId, int limit) {
        String sql = """
            SELECT p.id, p.title, p.content, p.created_at,
                   u.id as author_id, u.first_name, u.last_name, u.profile_type
            FROM posts p
            INNER JOIN users u ON p.author_id = u.id
            WHERE (:lastId IS NULL OR p.id > :lastId)
              AND p.status = 'PUBLISHED'
              AND p.visibility = 'PUBLIC'
            ORDER BY p.id ASC
            LIMIT :limit
            """;
        
        return jdbcTemplate.query(sql, 
            Map.of("lastId", lastId, "limit", limit),
            new PostDTORowMapper());
    }
    
    // Batch loading to avoid N+1 queries
    @Cacheable(value = "user-profiles", key = "#userIds")
    public Map<String, UserProfile> getUserProfilesBatch(List<String> userIds) {
        if (userIds.isEmpty()) {
            return Collections.emptyMap();
        }
        
        String sql = """
            SELECT id, first_name, last_name, profile_type, profile_photo_url
            FROM users
            WHERE id = ANY(?)
            """;
        
        Array userIdArray = jdbcTemplate.getJdbcOperations().execute(
            (Connection conn) -> conn.createArrayOf("varchar", userIds.toArray())
        );
        
        List<UserProfile> profiles = jdbcTemplate.query(sql, 
            new Object[]{userIdArray}, 
            new UserProfileRowMapper());
        
        return profiles.stream()
            .collect(Collectors.toMap(UserProfile::getId, Function.identity()));
    }
}
```

### **Caching Strategy Implementation**
```java
// Backend: CacheOptimizationConfig.java
@Configuration
@EnableCaching
public class CacheOptimizationConfig {
    
    @Bean
    public CacheManager cacheManager() {
        RedisCacheManager.Builder builder = RedisCacheManager
            .RedisCacheManagerBuilder
            .fromConnectionFactory(redisConnectionFactory())
            .cacheDefaults(defaultCacheConfiguration())
            .withCacheConfiguration("posts", postsCacheConfiguration())
            .withCacheConfiguration("user-profiles", userProfilesCacheConfiguration())
            .withCacheConfiguration("search-results", searchCacheConfiguration());
        
        return builder.build();
    }
    
    private RedisCacheConfiguration defaultCacheConfiguration() {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()))
            .disableCachingNullValues();
    }
    
    private RedisCacheConfiguration postsCacheConfiguration() {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(5))  // Shorter TTL for dynamic content
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
    }
    
    private RedisCacheConfiguration userProfilesCacheConfiguration() {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofHours(1))  // Longer TTL for stable data
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
    }
    
    @Bean
    public RedisTemplate<String, Object> redisTemplate() {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(redisConnectionFactory());
        
        // Use Jackson2JsonRedisSerializer for values
        Jackson2JsonRedisSerializer<Object> serializer = new Jackson2JsonRedisSerializer<>(Object.class);
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        objectMapper.activateDefaultTyping(LaissezFaireSubTypeValidator.instance, 
            ObjectMapper.DefaultTyping.NON_FINAL);
        serializer.setObjectMapper(objectMapper);
        
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(serializer);
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(serializer);
        
        template.afterPropertiesSet();
        return template;
    }
}

@Service
public class CacheWarmupService {
    
    @Autowired
    private PostService postService;
    
    @Autowired
    private UserService userService;
    
    @EventListener(ApplicationReadyEvent.class)
    public void warmupCaches() {
        log.info("Starting cache warmup");
        
        CompletableFuture.runAsync(() -> {
            // Warmup popular posts
            postService.getPopularPosts(0, 50);
            
            // Warmup trending topics
            postService.getTrendingTopics();
            
            // Warmup active user profiles
            userService.getActiveUserProfiles();
            
            log.info("Cache warmup completed");
        });
    }
    
    @Scheduled(cron = "0 */30 * * * ?") // Every 30 minutes
    public void refreshCriticalCaches() {
        // Refresh caches for critical data
        cacheManager.getCache("trending-topics").clear();
        postService.getTrendingTopics(); // This will repopulate the cache
    }
}
```

## 📊 **Performance Monitoring and Metrics**

### **Custom Performance Metrics**
```java
// Backend: PerformanceMetricsService.java
@Service
@Slf4j
public class PerformanceMetricsService {
    
    private final MeterRegistry meterRegistry;
    private final Timer databaseQueryTimer;
    private final Timer cacheOperationTimer;
    private final Counter cacheHitCounter;
    private final Counter cacheMissCounter;
    private final Gauge activeConnectionsGauge;
    
    public PerformanceMetricsService(MeterRegistry meterRegistry, DataSource dataSource) {
        this.meterRegistry = meterRegistry;
        
        this.databaseQueryTimer = Timer.builder("database.query.duration")
            .description("Database query execution time")
            .register(meterRegistry);
            
        this.cacheOperationTimer = Timer.builder("cache.operation.duration")
            .description("Cache operation duration")
            .register(meterRegistry);
            
        this.cacheHitCounter = Counter.builder("cache.hit.total")
            .description("Cache hit count")
            .register(meterRegistry);
            
        this.cacheMissCounter = Counter.builder("cache.miss.total")
            .description("Cache miss count")
            .register(meterRegistry);
            
        this.activeConnectionsGauge = Gauge.builder("database.connections.active")
            .description("Active database connections")
            .register(meterRegistry, dataSource, this::getActiveConnections);
    }
    
    @EventListener
    public void handleDatabaseQuery(DatabaseQueryEvent event) {
        databaseQueryTimer.record(event.getDuration(), TimeUnit.MILLISECONDS,
            Tags.of("query_type", event.getQueryType(), "table", event.getTable()));
        
        if (event.getDuration() > 1000) { // Log slow queries
            log.warn("Slow query detected: {} took {}ms", 
                event.getQueryType(), event.getDuration());
        }
    }
    
    @EventListener
    public void handleCacheOperation(CacheOperationEvent event) {
        cacheOperationTimer.record(event.getDuration(), TimeUnit.MILLISECONDS,
            Tags.of("cache_name", event.getCacheName(), "operation", event.getOperation()));
        
        if (event.isHit()) {
            cacheHitCounter.increment(Tags.of("cache_name", event.getCacheName()));
        } else {
            cacheMissCounter.increment(Tags.of("cache_name", event.getCacheName()));
        }
    }
    
    private double getActiveConnections(DataSource dataSource) {
        if (dataSource instanceof HikariDataSource) {
            HikariPoolMXBean poolMXBean = ((HikariDataSource) dataSource).getHikariPoolMXBean();
            return poolMXBean != null ? poolMXBean.getActiveConnections() : 0;
        }
        return 0;
    }
    
    @Scheduled(fixedRate = 60000) // Every minute
    public void recordPerformanceMetrics() {
        // Record JVM metrics
        Runtime runtime = Runtime.getRuntime();
        long totalMemory = runtime.totalMemory();
        long freeMemory = runtime.freeMemory();
        long usedMemory = totalMemory - freeMemory;
        
        Gauge.builder("jvm.memory.used")
            .description("Used JVM memory")
            .register(meterRegistry, usedMemory, value -> value);
        
        Gauge.builder("jvm.memory.free")
            .description("Free JVM memory")
            .register(meterRegistry, freeMemory, value -> value);
        
        // Record thread pool metrics
        ThreadPoolTaskExecutor executor = (ThreadPoolTaskExecutor) applicationContext.getBean("taskExecutor");
        if (executor != null) {
            Gauge.builder("thread.pool.active")
                .description("Active threads in pool")
                .register(meterRegistry, executor.getActiveCount(), value -> value);
            
            Gauge.builder("thread.pool.queue.size")
                .description("Thread pool queue size")
                .register(meterRegistry, executor.getThreadPoolExecutor().getQueue().size(), value -> value);
        }
    }
}
```

### **Frontend Performance Optimization**
```typescript
// Frontend: performanceOptimization.ts
import { lazy, Suspense, memo, useMemo, useCallback } from 'react';
import { debounce } from 'lodash';

// Code splitting with lazy loading
const CommunityPage = lazy(() => import('../pages/Community/CommunityPage'));
const DashboardPage = lazy(() => import('../pages/Dashboard/DashboardPage'));
const ProfilePage = lazy(() => import('../pages/Profile/ProfilePage'));

// Memoized components for performance
export const OptimizedPostCard = memo<{ post: Post }>(({ post }) => {
  const formattedDate = useMemo(() => 
    new Intl.DateTimeFormat('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    }).format(new Date(post.createdAt))
  , [post.createdAt]);

  const handleLike = useCallback(async () => {
    await apiClient.post(`/posts/${post.id}/like`);
  }, [post.id]);

  return (
    <Card>
      <CardContent>
        <Typography variant="h6">{post.title}</Typography>
        <Typography variant="body2" color="text.secondary">
          {formattedDate}
        </Typography>
        <Typography variant="body1">{post.content}</Typography>
        <Button onClick={handleLike}>Like</Button>
      </CardContent>
    </Card>
  );
});

// Virtual scrolling for large lists
import { FixedSizeList as List } from 'react-window';
import { FixedSizeGrid as Grid } from 'react-window';

export const VirtualizedPostList: React.FC<{ posts: Post[] }> = ({ posts }) => {
  const Row = useCallback(({ index, style }) => (
    <div style={style}>
      <OptimizedPostCard post={posts[index]} />
    </div>
  ), [posts]);

  return (
    <List
      height={600}
      itemCount={posts.length}
      itemSize={200}
      width="100%"
    >
      {Row}
    </List>
  );
};

// Debounced search optimization
export const useOptimizedSearch = () => {
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);

  const debouncedSearch = useMemo(
    () => debounce(async (query: string) => {
      if (!query.trim()) {
        setSearchResults([]);
        return;
      }

      setLoading(true);
      try {
        const results = await apiClient.get(`/search?q=${encodeURIComponent(query)}`);
        setSearchResults(results.data);
      } catch (error) {
        console.error('Search failed:', error);
      } finally {
        setLoading(false);
      }
    }, 300),
    []
  );

  useEffect(() => {
    return () => {
      debouncedSearch.cancel();
    };
  }, [debouncedSearch]);

  return { searchResults, loading, search: debouncedSearch };
};

// Image optimization with lazy loading
export const OptimizedImage: React.FC<{
  src: string;
  alt: string;
  width?: number;
  height?: number;
}> = ({ src, alt, width, height }) => {
  const [loaded, setLoaded] = useState(false);
  const [inView, setInView] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setInView(true);
          observer.disconnect();
        }
      },
      { threshold: 0.1 }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <Box
      ref={imgRef}
      width={width}
      height={height}
      display="flex"
      alignItems="center"
      justifyContent="center"
      bgcolor="grey.200"
    >
      {inView && (
        <img
          src={src}
          alt={alt}
          style={{
            width: '100%',
            height: '100%',
            objectFit: 'cover',
            opacity: loaded ? 1 : 0,
            transition: 'opacity 0.3s ease',
          }}
          onLoad={() => setLoaded(true)}
        />
      )}
      {!loaded && inView && (
        <CircularProgress size={24} />
      )}
    </Box>
  );
};
```

## 📈 **Capacity Planning**

### **Resource Allocation Strategy**
```yaml
# Resource allocation based on load patterns
resource_allocation:
  peak_hours: "09:00-17:00 CAT"  # Central Africa Time
  peak_days: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  
  scaling_targets:
    normal_load:
      backend_pods: 3
      frontend_pods: 2
      database_connections: 50
      cache_memory: "2Gi"
    
    peak_load:
      backend_pods: 15
      frontend_pods: 6
      database_connections: 150
      cache_memory: "8Gi"
    
    high_load:
      backend_pods: 30
      frontend_pods: 10
      database_connections: 300
      cache_memory: "16Gi"
  
  growth_projections:
    year_1:
      users: 10000
      daily_active_users: 2000
      posts_per_day: 500
      api_requests_per_minute: 1000
    
    year_2:
      users: 50000
      daily_active_users: 10000
      posts_per_day: 2500
      api_requests_per_minute: 5000
    
    year_3:
      users: 100000
      daily_active_users: 25000
      posts_per_day: 5000
      api_requests_per_minute: 10000
```

---

## 📚 **Reference Documents**

**Production Deployment**: See `/7_deployment_and_operations/1_production_deployment_setup.md`
**Monitoring and Logging**: See `/7_deployment_and_operations/2_monitoring_and_logging.md`
**Performance Testing**: See `/6_integration_and_testing/3_performance_testing_and_optimization.md`
**System Architecture**: See `/2_technical_architecture/1_system_architecture_design.md`

*This comprehensive scaling and performance optimization strategy ensures the ZbInnovation platform can handle growth and maintain optimal performance under varying load conditions.*
