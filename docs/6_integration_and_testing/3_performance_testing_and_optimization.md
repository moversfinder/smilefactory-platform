# 3. Performance Testing and Optimization

## ⚡ **Performance Testing Overview**

This document provides comprehensive guidance for performance testing and optimization of the ZbInnovation platform, including load testing strategies, performance monitoring, optimization techniques, and scalability testing approaches.

## 🏗️ **Performance Testing Strategy**

### **Performance Testing Pyramid**
```
                    /\
                   /  \
                  /Load \     <- Load & Stress Tests (20%)
                 /______\
                /        \
               /Integration\ <- Integration Performance (30%)
              /__________\
             /            \
            /   Unit Perf   \  <- Unit Performance Tests (50%)
           /________________\
```

### **Performance Metrics and Targets**
```yaml
# performance-targets.yml
performance_targets:
  response_time:
    api_endpoints:
      p50: 200ms
      p95: 500ms
      p99: 1000ms
    page_load:
      first_contentful_paint: 1.8s
      largest_contentful_paint: 2.5s
      time_to_interactive: 3.5s
  
  throughput:
    concurrent_users: 1000
    requests_per_second: 500
    transactions_per_minute: 10000
  
  resource_utilization:
    cpu_usage: 70%
    memory_usage: 80%
    disk_io: 80%
    network_bandwidth: 80%
  
  availability:
    uptime: 99.9%
    error_rate: 0.1%
```

## 🔧 **Load Testing Implementation**

### **JMeter Load Testing Configuration**
```xml
<!-- load-test-plan.jmx -->
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="ZbInnovation Load Test">
      <elementProp name="TestPlan.arguments" elementType="Arguments">
        <collectionProp name="Arguments.arguments">
          <elementProp name="baseUrl" elementType="Argument">
            <stringProp name="Argument.name">baseUrl</stringProp>
            <stringProp name="Argument.value">${__P(baseUrl,http://localhost:8080)}</stringProp>
          </elementProp>
          <elementProp name="users" elementType="Argument">
            <stringProp name="Argument.name">users</stringProp>
            <stringProp name="Argument.value">${__P(users,100)}</stringProp>
          </elementProp>
        </collectionProp>
      </elementProp>
    </TestPlan>
    
    <hashTree>
      <!-- User Authentication Scenario -->
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Authentication Load">
        <stringProp name="ThreadGroup.num_threads">${users}</stringProp>
        <stringProp name="ThreadGroup.ramp_time">60</stringProp>
        <stringProp name="ThreadGroup.duration">300</stringProp>
        <boolProp name="ThreadGroup.scheduler">true</boolProp>
      </ThreadGroup>
      
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="Login">
          <stringProp name="HTTPSampler.domain">${baseUrl}</stringProp>
          <stringProp name="HTTPSampler.path">/api/v1/auth/login</stringProp>
          <stringProp name="HTTPSampler.method">POST</stringProp>
          <stringProp name="HTTPSampler.postBodyRaw">{"email":"test${__threadNum}@example.com","password":"TestPass123!"}</stringProp>
        </HTTPSamplerProxy>
        
        <JSONExtractor guiclass="JSONPostProcessorGui" testclass="JSONExtractor" testname="Extract Token">
          <stringProp name="JSONExtractor.referenceNames">authToken</stringProp>
          <stringProp name="JSONExtractor.jsonPathExpressions">$.data.token</stringProp>
        </JSONExtractor>
      </hashTree>
      
      <!-- Community Feed Scenario -->
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Community Feed Load">
        <stringProp name="ThreadGroup.num_threads">${users}</stringProp>
        <stringProp name="ThreadGroup.ramp_time">30</stringProp>
        <stringProp name="ThreadGroup.duration">600</stringProp>
      </ThreadGroup>
      
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="Get Posts">
          <stringProp name="HTTPSampler.domain">${baseUrl}</stringProp>
          <stringProp name="HTTPSampler.path">/api/v1/posts</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
          <HeaderManager guiclass="HeaderPanel" testclass="HeaderManager">
            <collectionProp name="HeaderManager.headers">
              <elementProp name="" elementType="Header">
                <stringProp name="Header.name">Authorization</stringProp>
                <stringProp name="Header.value">Bearer ${authToken}</stringProp>
              </elementProp>
            </collectionProp>
          </HeaderManager>
        </HTTPSamplerProxy>
        
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="Create Post">
          <stringProp name="HTTPSampler.domain">${baseUrl}</stringProp>
          <stringProp name="HTTPSampler.path">/api/v1/posts</stringProp>
          <stringProp name="HTTPSampler.method">POST</stringProp>
          <stringProp name="HTTPSampler.postBodyRaw">{"title":"Load Test Post ${__time}","content":"This is a load test post created at ${__time}","category":"general"}</stringProp>
        </HTTPSamplerProxy>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
```

### **K6 Load Testing Scripts**
```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export let options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up to 100 users
    { duration: '5m', target: 100 }, // Stay at 100 users
    { duration: '2m', target: 200 }, // Ramp up to 200 users
    { duration: '5m', target: 200 }, // Stay at 200 users
    { duration: '2m', target: 0 },   // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.01'],   // Error rate must be below 1%
    errors: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export function setup() {
  // Create test users
  const users = [];
  for (let i = 0; i < 50; i++) {
    const userData = {
      email: `loadtest${i}@example.com`,
      password: 'LoadTest123!',
      firstName: `User${i}`,
      lastName: 'LoadTest',
      profileType: 'innovator',
      agreeToTerms: true,
    };
    
    const response = http.post(`${BASE_URL}/api/v1/auth/register`, JSON.stringify(userData), {
      headers: { 'Content-Type': 'application/json' },
    });
    
    if (response.status === 201) {
      users.push({
        email: userData.email,
        password: userData.password,
        token: response.json().data.token,
      });
    }
  }
  
  return { users };
}

export default function(data) {
  const user = data.users[Math.floor(Math.random() * data.users.length)];
  
  // Login
  const loginResponse = http.post(`${BASE_URL}/api/v1/auth/login`, JSON.stringify({
    email: user.email,
    password: user.password,
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  const loginSuccess = check(loginResponse, {
    'login successful': (r) => r.status === 200,
    'login response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  if (!loginSuccess) {
    errorRate.add(1);
    return;
  }
  
  const token = loginResponse.json().data.token;
  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };
  
  // Get user profile
  const profileResponse = http.get(`${BASE_URL}/api/v1/profiles/me`, { headers });
  check(profileResponse, {
    'profile fetch successful': (r) => r.status === 200,
    'profile response time < 300ms': (r) => r.timings.duration < 300,
  });
  
  // Get community posts
  const postsResponse = http.get(`${BASE_URL}/api/v1/posts?page=0&size=20`, { headers });
  check(postsResponse, {
    'posts fetch successful': (r) => r.status === 200,
    'posts response time < 400ms': (r) => r.timings.duration < 400,
  });
  
  // Create a post (20% of users)
  if (Math.random() < 0.2) {
    const postData = {
      title: `Load Test Post ${Date.now()}`,
      content: `This is a load test post created by ${user.email}`,
      category: 'general',
    };
    
    const createPostResponse = http.post(`${BASE_URL}/api/v1/posts`, JSON.stringify(postData), { headers });
    check(createPostResponse, {
      'post creation successful': (r) => r.status === 201,
      'post creation response time < 600ms': (r) => r.timings.duration < 600,
    });
  }
  
  sleep(1);
}

export function teardown(data) {
  // Cleanup test data if needed
  console.log('Load test completed');
}
```

## 📊 **Performance Monitoring**

### **Application Performance Monitoring Setup**
```java
// Backend: PerformanceMonitoringConfig.java
@Configuration
@EnableConfigurationProperties(PerformanceProperties.class)
public class PerformanceMonitoringConfig {
    
    @Bean
    public MeterRegistry meterRegistry() {
        return new PrometheusMeterRegistry(PrometheusConfig.DEFAULT);
    }
    
    @Bean
    public TimedAspect timedAspect(MeterRegistry registry) {
        return new TimedAspect(registry);
    }
    
    @Bean
    public CountedAspect countedAspect(MeterRegistry registry) {
        return new CountedAspect(registry);
    }
    
    @Bean
    public PerformanceInterceptor performanceInterceptor() {
        return new PerformanceInterceptor();
    }
}

@Component
@Slf4j
public class PerformanceInterceptor implements HandlerInterceptor {
    
    private final MeterRegistry meterRegistry;
    private final Timer.Sample sample;
    
    public PerformanceInterceptor(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        Timer.Sample sample = Timer.start(meterRegistry);
        request.setAttribute("timer.sample", sample);
        request.setAttribute("start.time", System.currentTimeMillis());
        return true;
    }
    
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        Timer.Sample sample = (Timer.Sample) request.getAttribute("timer.sample");
        Long startTime = (Long) request.getAttribute("start.time");
        
        if (sample != null) {
            sample.stop(Timer.builder("http.server.requests")
                .tag("method", request.getMethod())
                .tag("uri", request.getRequestURI())
                .tag("status", String.valueOf(response.getStatus()))
                .register(meterRegistry));
        }
        
        if (startTime != null) {
            long duration = System.currentTimeMillis() - startTime;
            if (duration > 1000) { // Log slow requests
                log.warn("Slow request detected: {} {} took {}ms", 
                    request.getMethod(), request.getRequestURI(), duration);
            }
        }
    }
}
```

### **Frontend Performance Monitoring**
```typescript
// src/utils/performanceMonitoring.ts
interface PerformanceMetrics {
  fcp: number; // First Contentful Paint
  lcp: number; // Largest Contentful Paint
  fid: number; // First Input Delay
  cls: number; // Cumulative Layout Shift
  ttfb: number; // Time to First Byte
}

class PerformanceMonitor {
  private metrics: Partial<PerformanceMetrics> = {};

  constructor() {
    this.observeWebVitals();
    this.observeCustomMetrics();
  }

  private observeWebVitals() {
    // Observe Core Web Vitals
    new PerformanceObserver((list) => {
      list.getEntries().forEach((entry) => {
        switch (entry.name) {
          case 'first-contentful-paint':
            this.metrics.fcp = entry.startTime;
            break;
          case 'largest-contentful-paint':
            this.metrics.lcp = entry.startTime;
            break;
        }
      });
    }).observe({ entryTypes: ['paint', 'largest-contentful-paint'] });

    // Observe First Input Delay
    new PerformanceObserver((list) => {
      list.getEntries().forEach((entry) => {
        this.metrics.fid = entry.processingStart - entry.startTime;
      });
    }).observe({ entryTypes: ['first-input'] });

    // Observe Cumulative Layout Shift
    new PerformanceObserver((list) => {
      let clsValue = 0;
      list.getEntries().forEach((entry) => {
        if (!entry.hadRecentInput) {
          clsValue += entry.value;
        }
      });
      this.metrics.cls = clsValue;
    }).observe({ entryTypes: ['layout-shift'] });
  }

  private observeCustomMetrics() {
    // Observe navigation timing
    window.addEventListener('load', () => {
      const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
      this.metrics.ttfb = navigation.responseStart - navigation.fetchStart;
      
      this.sendMetrics();
    });
  }

  measureComponentRender(componentName: string, renderFunction: () => void) {
    const startTime = performance.now();
    renderFunction();
    const endTime = performance.now();
    
    const renderTime = endTime - startTime;
    
    // Log slow renders
    if (renderTime > 16) { // 60fps threshold
      console.warn(`Slow render detected for ${componentName}: ${renderTime.toFixed(2)}ms`);
    }
    
    // Send to analytics
    this.sendCustomMetric('component_render_time', renderTime, {
      component: componentName,
    });
  }

  measureApiCall(endpoint: string, duration: number, status: number) {
    this.sendCustomMetric('api_call_duration', duration, {
      endpoint,
      status: status.toString(),
    });
  }

  private sendMetrics() {
    // Send metrics to analytics service
    fetch('/api/v1/analytics/performance', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        metrics: this.metrics,
        userAgent: navigator.userAgent,
        timestamp: Date.now(),
      }),
    }).catch(error => {
      console.error('Failed to send performance metrics:', error);
    });
  }

  private sendCustomMetric(name: string, value: number, tags: Record<string, string> = {}) {
    fetch('/api/v1/analytics/metrics', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name,
        value,
        tags,
        timestamp: Date.now(),
      }),
    }).catch(error => {
      console.error('Failed to send custom metric:', error);
    });
  }
}

export const performanceMonitor = new PerformanceMonitor();

// React Hook for performance monitoring
export const usePerformanceMonitoring = (componentName: string) => {
  useEffect(() => {
    const startTime = performance.now();
    
    return () => {
      const endTime = performance.now();
      performanceMonitor.measureComponentRender(componentName, () => {});
    };
  }, [componentName]);
};
```

## 🚀 **Performance Optimization Techniques**

### **Database Query Optimization**
```java
// Backend: OptimizedQueryService.java
@Service
@Transactional(readOnly = true)
public class OptimizedQueryService {
    
    @PersistenceContext
    private EntityManager entityManager;
    
    // Optimized pagination with cursor-based approach
    public Page<PostDTO> getPostsOptimized(String lastPostId, int limit) {
        String jpql = """
            SELECT new com.zbinnovation.dto.PostDTO(
                p.id, p.title, p.content, p.createdAt,
                a.id, a.firstName, a.lastName, a.profileType
            )
            FROM Post p 
            JOIN p.author a
            WHERE (:lastPostId IS NULL OR p.id > :lastPostId)
            AND p.status = 'PUBLISHED'
            AND p.visibility = 'PUBLIC'
            ORDER BY p.id ASC
            """;
        
        TypedQuery<PostDTO> query = entityManager.createQuery(jpql, PostDTO.class);
        query.setParameter("lastPostId", lastPostId);
        query.setMaxResults(limit + 1); // +1 to check if there are more results
        
        List<PostDTO> results = query.getResultList();
        boolean hasNext = results.size() > limit;
        
        if (hasNext) {
            results.remove(results.size() - 1);
        }
        
        return new PageImpl<>(results, PageRequest.of(0, limit), results.size());
    }
    
    // Batch loading to avoid N+1 queries
    @Query("SELECT p FROM Post p JOIN FETCH p.author WHERE p.id IN :ids")
    List<Post> findPostsWithAuthors(@Param("ids") List<String> postIds);
    
    // Optimized search with full-text search
    @Query(value = """
        SELECT p.*, ts_rank(to_tsvector('english', p.title || ' ' || p.content), plainto_tsquery('english', :query)) as rank
        FROM posts p
        WHERE to_tsvector('english', p.title || ' ' || p.content) @@ plainto_tsquery('english', :query)
        AND p.status = 'PUBLISHED'
        ORDER BY rank DESC, p.created_at DESC
        LIMIT :limit OFFSET :offset
        """, nativeQuery = true)
    List<Post> searchPostsFullText(@Param("query") String query, 
                                  @Param("limit") int limit, 
                                  @Param("offset") int offset);
}
```

### **Frontend Performance Optimization**
```typescript
// src/hooks/useOptimizedQuery.ts
import { useQuery, useInfiniteQuery } from '@tanstack/react-query';
import { useMemo } from 'react';

export const useOptimizedPosts = () => {
  return useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: ({ pageParam = null }) => 
      apiClient.get(`/posts?lastId=${pageParam || ''}&limit=20`),
    getNextPageParam: (lastPage) => lastPage.hasNext ? lastPage.lastId : undefined,
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
};

// Memoized component for performance
export const OptimizedPostCard = React.memo<{ post: Post }>(({ post }) => {
  const formattedDate = useMemo(() => 
    new Intl.DateTimeFormat('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    }).format(new Date(post.createdAt))
  , [post.createdAt]);

  return (
    <Card>
      <CardContent>
        <Typography variant="h6">{post.title}</Typography>
        <Typography variant="body2" color="text.secondary">
          {formattedDate}
        </Typography>
        <Typography variant="body1">{post.content}</Typography>
      </CardContent>
    </Card>
  );
});

// Virtual scrolling for large lists
import { FixedSizeList as List } from 'react-window';

export const VirtualizedPostList: React.FC<{ posts: Post[] }> = ({ posts }) => {
  const Row = ({ index, style }) => (
    <div style={style}>
      <OptimizedPostCard post={posts[index]} />
    </div>
  );

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
```

### **Caching Strategy**
```java
// Backend: CacheConfig.java
@Configuration
@EnableCaching
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager() {
        RedisCacheManager.Builder builder = RedisCacheManager
            .RedisCacheManagerBuilder
            .fromConnectionFactory(redisConnectionFactory())
            .cacheDefaults(cacheConfiguration());
        
        return builder.build();
    }
    
    private RedisCacheConfiguration cacheConfiguration() {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
    }
    
    @Bean
    public RedisTemplate<String, Object> redisTemplate() {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(redisConnectionFactory());
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        return template;
    }
}

@Service
public class CachedPostService {
    
    @Cacheable(value = "posts", key = "#page + '_' + #size")
    public Page<Post> getPosts(int page, int size) {
        return postRepository.findAll(PageRequest.of(page, size));
    }
    
    @CacheEvict(value = "posts", allEntries = true)
    public Post createPost(Post post) {
        return postRepository.save(post);
    }
    
    @Cacheable(value = "user-profile", key = "#userId")
    public UserProfile getUserProfile(String userId) {
        return userRepository.findById(userId).orElse(null);
    }
}
```

---

## 📚 **Reference Documents**

**System Integration**: See `/6_integration_and_testing/1_system_integration.md`
**End-to-End Testing**: See `/6_integration_and_testing/2_end_to_end_testing.md`
**Backend Implementation**: See `/4_backend_implementation/`
**Frontend Implementation**: See `/5_frontend_implementation/`

*This performance testing and optimization strategy ensures the ZbInnovation platform meets high-performance standards under various load conditions.*
