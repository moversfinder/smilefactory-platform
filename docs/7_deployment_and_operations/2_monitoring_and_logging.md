# 2. Monitoring and Logging

## 📊 **Monitoring and Logging Overview**

This document outlines the comprehensive monitoring and logging strategy for the ZbInnovation platform, including application monitoring, infrastructure monitoring, log aggregation, alerting systems, and observability best practices.

## 🏗️ **Monitoring Architecture**

### **Observability Stack**
```
┌─────────────────────────────────────────────────────────────┐
│                    Grafana Dashboard                        │
│              (Visualization & Alerting)                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Prometheus    │  │   Jaeger        │  │   ELK Stack     │
│   (Metrics)     │  │   (Tracing)     │  │   (Logs)        │
└─────────────────┘  └─────────────────┘  └─────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                Application & Infrastructure                 │
│         (Spring Boot, React, Kubernetes, AWS)              │
└─────────────────────────────────────────────────────────────┘
```

### **Prometheus Configuration**
```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  # Kubernetes API Server
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
    - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
    - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
      action: keep
      regex: default;kubernetes;https

  # ZbInnovation Backend
  - job_name: 'zbinnovation-backend'
    kubernetes_sd_configs:
    - role: pod
    relabel_configs:
    - source_labels: [__meta_kubernetes_pod_label_app]
      action: keep
      regex: zbinnovation-backend
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: true
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
      action: replace
      target_label: __metrics_path__
      regex: (.+)

  # Node Exporter
  - job_name: 'node-exporter'
    kubernetes_sd_configs:
    - role: endpoints
    relabel_configs:
    - source_labels: [__meta_kubernetes_endpoints_name]
      regex: 'node-exporter'
      action: keep

  # PostgreSQL Exporter
  - job_name: 'postgres-exporter'
    static_configs:
    - targets: ['postgres-exporter:9187']

  # Redis Exporter
  - job_name: 'redis-exporter'
    static_configs:
    - targets: ['redis-exporter:9121']
```

## 📈 **Application Monitoring**

### **Spring Boot Actuator Configuration**
```java
// Backend: MonitoringConfig.java
@Configuration
@EnableConfigurationProperties(ManagementProperties.class)
public class MonitoringConfig {
    
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
    @ConditionalOnMissingBean
    public HealthIndicator customHealthIndicator() {
        return new CustomHealthIndicator();
    }
}

@Component
public class CustomHealthIndicator implements HealthIndicator {
    
    @Autowired
    private DataSource dataSource;
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    @Override
    public Health health() {
        Health.Builder builder = new Health.Builder();
        
        try {
            // Check database connectivity
            try (Connection connection = dataSource.getConnection()) {
                if (connection.isValid(1)) {
                    builder.withDetail("database", "UP");
                } else {
                    builder.down().withDetail("database", "Connection invalid");
                    return builder.build();
                }
            }
            
            // Check Redis connectivity
            try {
                redisTemplate.opsForValue().get("health-check");
                builder.withDetail("redis", "UP");
            } catch (Exception e) {
                builder.down().withDetail("redis", "Connection failed: " + e.getMessage());
                return builder.build();
            }
            
            // Check external services
            builder.withDetail("external-services", checkExternalServices());
            
            builder.up();
            
        } catch (Exception e) {
            builder.down().withException(e);
        }
        
        return builder.build();
    }
    
    private Map<String, String> checkExternalServices() {
        Map<String, String> services = new HashMap<>();
        
        // Check email service
        try {
            // Implement email service health check
            services.put("email-service", "UP");
        } catch (Exception e) {
            services.put("email-service", "DOWN: " + e.getMessage());
        }
        
        return services;
    }
}
```

### **Custom Metrics Implementation**
```java
// Backend: CustomMetricsService.java
@Service
@Slf4j
public class CustomMetricsService {
    
    private final MeterRegistry meterRegistry;
    private final Counter userRegistrationCounter;
    private final Counter postCreationCounter;
    private final Timer apiResponseTimer;
    private final Gauge activeUsersGauge;
    
    public CustomMetricsService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        
        this.userRegistrationCounter = Counter.builder("user.registrations.total")
            .description("Total number of user registrations")
            .tag("application", "zbinnovation")
            .register(meterRegistry);
            
        this.postCreationCounter = Counter.builder("posts.created.total")
            .description("Total number of posts created")
            .tag("application", "zbinnovation")
            .register(meterRegistry);
            
        this.apiResponseTimer = Timer.builder("api.response.time")
            .description("API response time")
            .tag("application", "zbinnovation")
            .register(meterRegistry);
            
        this.activeUsersGauge = Gauge.builder("users.active.current")
            .description("Current number of active users")
            .tag("application", "zbinnovation")
            .register(meterRegistry, this, CustomMetricsService::getActiveUserCount);
    }
    
    public void incrementUserRegistration(String profileType) {
        userRegistrationCounter.increment(Tags.of("profile_type", profileType));
    }
    
    public void incrementPostCreation(String category) {
        postCreationCounter.increment(Tags.of("category", category));
    }
    
    public void recordApiResponseTime(String endpoint, long duration) {
        apiResponseTimer.record(duration, TimeUnit.MILLISECONDS, Tags.of("endpoint", endpoint));
    }
    
    private double getActiveUserCount() {
        // Implement logic to get current active user count
        // This could query Redis for active sessions
        return activeUserService.getActiveUserCount();
    }
    
    @EventListener
    public void handleUserLoginEvent(UserLoginEvent event) {
        meterRegistry.counter("user.logins.total",
            "profile_type", event.getUser().getProfileType().toString())
            .increment();
    }
    
    @EventListener
    public void handlePostLikedEvent(PostLikedEvent event) {
        meterRegistry.counter("posts.likes.total",
            "post_category", event.getPost().getCategory())
            .increment();
    }
}
```

### **Frontend Monitoring**
```typescript
// Frontend: monitoring.ts
interface PerformanceMetrics {
  pageLoadTime: number;
  apiResponseTime: number;
  errorRate: number;
  userInteractions: number;
}

class FrontendMonitoring {
  private metrics: PerformanceMetrics = {
    pageLoadTime: 0,
    apiResponseTime: 0,
    errorRate: 0,
    userInteractions: 0,
  };

  constructor() {
    this.initializeMonitoring();
  }

  private initializeMonitoring() {
    // Monitor page load performance
    window.addEventListener('load', () => {
      const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
      this.metrics.pageLoadTime = navigation.loadEventEnd - navigation.fetchStart;
      this.sendMetric('page_load_time', this.metrics.pageLoadTime);
    });

    // Monitor API calls
    this.interceptFetch();

    // Monitor errors
    window.addEventListener('error', (event) => {
      this.recordError(event.error);
    });

    // Monitor unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      this.recordError(event.reason);
    });

    // Send metrics periodically
    setInterval(() => {
      this.sendBatchMetrics();
    }, 60000); // Every minute
  }

  private interceptFetch() {
    const originalFetch = window.fetch;
    
    window.fetch = async (...args) => {
      const startTime = performance.now();
      
      try {
        const response = await originalFetch(...args);
        const endTime = performance.now();
        const duration = endTime - startTime;
        
        this.recordApiCall(args[0].toString(), duration, response.status);
        
        return response;
      } catch (error) {
        const endTime = performance.now();
        const duration = endTime - startTime;
        
        this.recordApiCall(args[0].toString(), duration, 0);
        throw error;
      }
    };
  }

  private recordApiCall(url: string, duration: number, status: number) {
    this.metrics.apiResponseTime = duration;
    
    if (status >= 400) {
      this.metrics.errorRate++;
    }

    this.sendMetric('api_response_time', duration, {
      endpoint: this.extractEndpoint(url),
      status: status.toString(),
    });
  }

  private recordError(error: any) {
    this.metrics.errorRate++;
    
    this.sendMetric('frontend_error', 1, {
      error_type: error.name || 'Unknown',
      error_message: error.message || 'Unknown error',
      stack_trace: error.stack || '',
    });
  }

  private sendMetric(name: string, value: number, tags: Record<string, string> = {}) {
    fetch('/api/v1/metrics', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name,
        value,
        tags: {
          ...tags,
          source: 'frontend',
          user_agent: navigator.userAgent,
          timestamp: Date.now(),
        },
      }),
    }).catch(error => {
      console.error('Failed to send metric:', error);
    });
  }

  private sendBatchMetrics() {
    const batchMetrics = [
      { name: 'user_interactions', value: this.metrics.userInteractions },
      { name: 'error_rate', value: this.metrics.errorRate },
    ];

    fetch('/api/v1/metrics/batch', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ metrics: batchMetrics }),
    }).catch(error => {
      console.error('Failed to send batch metrics:', error);
    });

    // Reset counters
    this.metrics.userInteractions = 0;
    this.metrics.errorRate = 0;
  }

  private extractEndpoint(url: string): string {
    try {
      const urlObj = new URL(url);
      return urlObj.pathname.replace(/\/\d+/g, '/:id'); // Replace IDs with :id
    } catch {
      return url;
    }
  }

  public recordUserInteraction(action: string, component: string) {
    this.metrics.userInteractions++;
    
    this.sendMetric('user_interaction', 1, {
      action,
      component,
    });
  }
}

export const frontendMonitoring = new FrontendMonitoring();
```

## 📝 **Logging Strategy**

### **Structured Logging Configuration**
```java
// Backend: LoggingConfig.java
@Configuration
public class LoggingConfig {
    
    @Bean
    public Logger structuredLogger() {
        LoggerContext context = (LoggerContext) LoggerFactory.getILoggerFactory();
        
        // JSON Encoder for structured logging
        JsonEncoder jsonEncoder = new JsonEncoder();
        jsonEncoder.setContext(context);
        jsonEncoder.start();
        
        // Console Appender
        ConsoleAppender<ILoggingEvent> consoleAppender = new ConsoleAppender<>();
        consoleAppender.setContext(context);
        consoleAppender.setEncoder(jsonEncoder);
        consoleAppender.start();
        
        // File Appender with rotation
        RollingFileAppender<ILoggingEvent> fileAppender = new RollingFileAppender<>();
        fileAppender.setContext(context);
        fileAppender.setFile("logs/application.log");
        fileAppender.setEncoder(jsonEncoder);
        
        TimeBasedRollingPolicy<ILoggingEvent> rollingPolicy = new TimeBasedRollingPolicy<>();
        rollingPolicy.setContext(context);
        rollingPolicy.setParent(fileAppender);
        rollingPolicy.setFileNamePattern("logs/application.%d{yyyy-MM-dd}.%i.log.gz");
        rollingPolicy.setMaxHistory(30);
        
        SizeAndTimeBasedFNATP<ILoggingEvent> sizeAndTimeBasedFNATP = new SizeAndTimeBasedFNATP<>();
        sizeAndTimeBasedFNATP.setMaxFileSize(FileSize.valueOf("100MB"));
        rollingPolicy.setTimeBasedFileNamingAndTriggeringPolicy(sizeAndTimeBasedFNATP);
        
        rollingPolicy.start();
        fileAppender.setRollingPolicy(rollingPolicy);
        fileAppender.start();
        
        // Root Logger
        ch.qos.logback.classic.Logger rootLogger = context.getLogger(Logger.ROOT_LOGGER_NAME);
        rootLogger.addAppender(consoleAppender);
        rootLogger.addAppender(fileAppender);
        rootLogger.setLevel(Level.INFO);
        
        return rootLogger;
    }
}

@Component
@Slf4j
public class StructuredLoggingService {
    
    public void logUserAction(String userId, String action, Map<String, Object> context) {
        MDC.put("userId", userId);
        MDC.put("action", action);
        MDC.put("timestamp", Instant.now().toString());
        
        try {
            log.info("User action performed: {}", action, kv("context", context));
        } finally {
            MDC.clear();
        }
    }
    
    public void logApiRequest(HttpServletRequest request, HttpServletResponse response, long duration) {
        MDC.put("method", request.getMethod());
        MDC.put("uri", request.getRequestURI());
        MDC.put("status", String.valueOf(response.getStatus()));
        MDC.put("duration", String.valueOf(duration));
        MDC.put("userAgent", request.getHeader("User-Agent"));
        MDC.put("remoteAddr", getClientIpAddress(request));
        
        try {
            if (response.getStatus() >= 400) {
                log.warn("API request failed: {} {}", request.getMethod(), request.getRequestURI());
            } else {
                log.info("API request completed: {} {}", request.getMethod(), request.getRequestURI());
            }
        } finally {
            MDC.clear();
        }
    }
    
    public void logBusinessEvent(String eventType, String entityId, Map<String, Object> eventData) {
        MDC.put("eventType", eventType);
        MDC.put("entityId", entityId);
        MDC.put("timestamp", Instant.now().toString());
        
        try {
            log.info("Business event: {}", eventType, kv("eventData", eventData));
        } finally {
            MDC.clear();
        }
    }
    
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
```

### **ELK Stack Configuration**
```yaml
# monitoring/elasticsearch.yml
cluster.name: zbinnovation-logs
node.name: elasticsearch-master
network.host: 0.0.0.0
discovery.type: single-node
xpack.security.enabled: false
xpack.monitoring.collection.enabled: true

---
# monitoring/logstash.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][service] == "zbinnovation-backend" {
    json {
      source => "message"
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    mutate {
      add_field => { "service" => "backend" }
    }
  }
  
  if [fields][service] == "zbinnovation-frontend" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    
    mutate {
      add_field => { "service" => "frontend" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "zbinnovation-logs-%{+YYYY.MM.dd}"
  }
}

---
# monitoring/kibana.yml
server.name: kibana
server.host: 0.0.0.0
elasticsearch.hosts: ["http://elasticsearch:9200"]
monitoring.ui.container.elasticsearch.enabled: true
```

## 🚨 **Alerting Configuration**

### **Prometheus Alert Rules**
```yaml
# monitoring/alert_rules.yml
groups:
- name: zbinnovation.rules
  rules:
  # High error rate
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value }} errors per second"

  # High response time
  - alert: HighResponseTime
    expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High response time detected"
      description: "95th percentile response time is {{ $value }} seconds"

  # Database connection issues
  - alert: DatabaseDown
    expr: up{job="postgres-exporter"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Database is down"
      description: "PostgreSQL database is not responding"

  # High memory usage
  - alert: HighMemoryUsage
    expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage"
      description: "Memory usage is {{ $value | humanizePercentage }}"

  # Pod restart frequency
  - alert: PodRestartingFrequently
    expr: rate(kube_pod_container_status_restarts_total[1h]) > 0.1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Pod restarting frequently"
      description: "Pod {{ $labels.pod }} is restarting frequently"
```

### **Alertmanager Configuration**
```yaml
# monitoring/alertmanager.yml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alerts@zbinnovation.com'
  smtp_auth_username: 'alerts@zbinnovation.com'
  smtp_auth_password: 'app-password'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
  routes:
  - match:
      severity: critical
    receiver: 'critical-alerts'
  - match:
      severity: warning
    receiver: 'warning-alerts'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://slack-webhook-service:8080/webhook'

- name: 'critical-alerts'
  email_configs:
  - to: 'devops@zbinnovation.com'
    subject: 'CRITICAL: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      Alert: {{ .Annotations.summary }}
      Description: {{ .Annotations.description }}
      {{ end }}
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
    channel: '#alerts-critical'
    title: 'Critical Alert'
    text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'

- name: 'warning-alerts'
  email_configs:
  - to: 'team@zbinnovation.com'
    subject: 'WARNING: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      Alert: {{ .Annotations.summary }}
      Description: {{ .Annotations.description }}
      {{ end }}
```

---

## 📚 **Reference Documents**

**Production Deployment**: See `/7_deployment_and_operations/1_production_deployment_setup.md`
**System Architecture**: See `/2_technical_architecture/1_system_architecture_design.md`
**Performance Testing**: See `/6_integration_and_testing/3_performance_testing_and_optimization.md`
**Backup and Recovery**: See `/7_deployment_and_operations/3_backup_and_disaster_recovery.md`

*This comprehensive monitoring and logging strategy ensures complete observability and proactive issue detection for the ZbInnovation platform.*
