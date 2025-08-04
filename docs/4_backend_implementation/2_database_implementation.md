# 2. Database Implementation

## 🗄️ **Database Implementation Overview**

This document outlines the comprehensive database implementation strategy for the ZbInnovation platform, including entity setup, data access layer implementation, migration management, and performance optimization using PostgreSQL with JPA/Hibernate.

## 🏗️ **Entity Relationship Implementation**

### **Base Entity Class**
```java
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public abstract class BaseEntity {
    
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    @EqualsAndHashCode.Include
    private String id;
    
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Version
    @Column(name = "version")
    private Long version;
    
    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (updatedAt == null) {
            updatedAt = LocalDateTime.now();
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
```

### **User Profile Entity**
```java
@Entity
@Table(name = "personal_details", indexes = {
    @Index(name = "idx_email", columnList = "email"),
    @Index(name = "idx_profile_type", columnList = "profile_type"),
    @Index(name = "idx_created_at", columnList = "created_at")
})
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PersonalDetails extends BaseEntity {
    
    @Column(name = "email", unique = true, nullable = false, length = 255)
    private String email;
    
    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;
    
    @Column(name = "first_name", length = 100)
    private String firstName;
    
    @Column(name = "last_name", length = 100)
    private String lastName;
    
    @Column(name = "phone_country_code", length = 10)
    private String phoneCountryCode;
    
    @Column(name = "phone_number", length = 20)
    private String phoneNumber;
    
    @Column(name = "gender", length = 20)
    private String gender;
    
    @Column(name = "role", length = 50)
    @Builder.Default
    private String role = "USER";
    
    @Column(name = "profile_name", length = 200)
    private String profileName;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "profile_state", length = 20)
    @Builder.Default
    private ProfileState profileState = ProfileState.DRAFT;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "profile_type", length = 50)
    private ProfileType profileType;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "profile_visibility", length = 20)
    @Builder.Default
    private ProfileVisibility profileVisibility = ProfileVisibility.PUBLIC;
    
    @Column(name = "profile_completion")
    @Builder.Default
    private Integer profileCompletion = 0;
    
    @Column(name = "is_verified")
    @Builder.Default
    private Boolean isVerified = false;
    
    @Column(name = "email_verified")
    @Builder.Default
    private Boolean emailVerified = false;
    
    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;
    
    @Type(JsonType.class)
    @Column(name = "hear_about_us", columnDefinition = "jsonb")
    private List<String> hearAboutUs;
    
    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;
    
    // Relationships
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private InnovatorProfile innovatorProfile;
    
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private BusinessInvestorProfile businessInvestorProfile;
    
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private MentorProfile mentorProfile;
    
    @OneToMany(mappedBy = "author", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Post> posts = new ArrayList<>();
    
    @OneToMany(mappedBy = "requester", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Connection> sentConnections = new ArrayList<>();
    
    @OneToMany(mappedBy = "recipient", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Connection> receivedConnections = new ArrayList<>();
}
```

### **Profile Type-Specific Entities**
```java
@Entity
@Table(name = "innovator_profiles")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InnovatorProfile extends BaseEntity {
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private PersonalDetails user;
    
    @Column(name = "industry_focus", length = 100)
    private String industryFocus;
    
    @Column(name = "innovation_stage", length = 50)
    private String innovationStage;
    
    @Column(name = "startup_name", length = 200)
    private String startupName;
    
    @Column(name = "startup_description", columnDefinition = "TEXT")
    private String startupDescription;
    
    @Column(name = "funding_amount_needed", precision = 15, scale = 2)
    private BigDecimal fundingAmountNeeded;
    
    @Column(name = "team_size")
    private Integer teamSize;
    
    @Column(name = "business_model", columnDefinition = "TEXT")
    private String businessModel;
    
    @Column(name = "target_market", columnDefinition = "TEXT")
    private String targetMarket;
    
    @Column(name = "competitive_advantage", columnDefinition = "TEXT")
    private String competitiveAdvantage;
    
    @Type(JsonType.class)
    @Column(name = "intellectual_property", columnDefinition = "jsonb")
    private List<String> intellectualProperty;
    
    @Type(JsonType.class)
    @Column(name = "current_challenges", columnDefinition = "jsonb")
    private List<String> currentChallenges;
    
    @Type(JsonType.class)
    @Column(name = "achievements", columnDefinition = "jsonb")
    private List<String> achievements;
}
```

## 🔧 **Data Access Layer (Repository Pattern)**

### **Base Repository Interface**
```java
@NoRepositoryBean
public interface BaseRepository<T extends BaseEntity> extends JpaRepository<T, String>, JpaSpecificationExecutor<T> {
    
    @Query("SELECT e FROM #{#entityName} e WHERE e.createdAt >= :startDate AND e.createdAt <= :endDate")
    List<T> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                           @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT COUNT(e) FROM #{#entityName} e WHERE e.createdAt >= :date")
    long countCreatedSince(@Param("date") LocalDateTime date);
    
    @Modifying
    @Query("UPDATE #{#entityName} e SET e.updatedAt = :now WHERE e.id = :id")
    void updateTimestamp(@Param("id") String id, @Param("now") LocalDateTime now);
}
```

### **User Repository**
```java
@Repository
public interface PersonalDetailsRepository extends BaseRepository<PersonalDetails> {
    
    Optional<PersonalDetails> findByEmail(String email);
    
    Optional<PersonalDetails> findByEmailAndEmailVerifiedTrue(String email);
    
    @Query("SELECT p FROM PersonalDetails p WHERE p.profileType = :profileType AND p.profileState = 'COMPLETE'")
    Page<PersonalDetails> findCompleteProfilesByType(@Param("profileType") ProfileType profileType, Pageable pageable);
    
    @Query("SELECT p FROM PersonalDetails p WHERE " +
           "(:profileType IS NULL OR p.profileType = :profileType) AND " +
           "(:location IS NULL OR LOWER(p.bio) LIKE LOWER(CONCAT('%', :location, '%'))) AND " +
           "p.profileVisibility = 'PUBLIC' AND p.profileState = 'COMPLETE'")
    Page<PersonalDetails> searchProfiles(@Param("profileType") ProfileType profileType,
                                       @Param("location") String location,
                                       Pageable pageable);
    
    @Query("SELECT COUNT(p) FROM PersonalDetails p WHERE p.profileType = :profileType")
    long countByProfileType(@Param("profileType") ProfileType profileType);
    
    @Query("SELECT p FROM PersonalDetails p WHERE p.lastLoginAt >= :since")
    List<PersonalDetails> findActiveUsersSince(@Param("since") LocalDateTime since);
    
    @Modifying
    @Query("UPDATE PersonalDetails p SET p.lastLoginAt = :loginTime WHERE p.id = :userId")
    void updateLastLoginTime(@Param("userId") String userId, @Param("loginTime") LocalDateTime loginTime);
}
```

### **Content Repository**
```java
@Repository
public interface PostRepository extends BaseRepository<Post> {
    
    @Query("SELECT p FROM Post p WHERE p.author.id = :authorId AND p.status = :status ORDER BY p.publishedAt DESC")
    Page<Post> findByAuthorAndStatus(@Param("authorId") String authorId, 
                                   @Param("status") PostStatus status, 
                                   Pageable pageable);
    
    @Query("SELECT p FROM Post p WHERE p.visibility = 'PUBLIC' AND p.status = 'PUBLISHED' " +
           "ORDER BY p.publishedAt DESC")
    Page<Post> findPublicPosts(Pageable pageable);
    
    @Query("SELECT p FROM Post p WHERE " +
           "p.visibility = 'PUBLIC' AND p.status = 'PUBLISHED' AND " +
           "(LOWER(p.title) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(p.content) LIKE LOWER(CONCAT('%', :query, '%'))) " +
           "ORDER BY p.publishedAt DESC")
    Page<Post> searchPublicPosts(@Param("query") String query, Pageable pageable);
    
    @Query("SELECT p FROM Post p WHERE p.author.profileType IN :profileTypes AND " +
           "p.visibility = 'PUBLIC' AND p.status = 'PUBLISHED' " +
           "ORDER BY p.likeCount DESC, p.publishedAt DESC")
    Page<Post> findTrendingPostsByProfileTypes(@Param("profileTypes") List<ProfileType> profileTypes, 
                                             Pageable pageable);
    
    @Modifying
    @Query("UPDATE Post p SET p.likeCount = p.likeCount + :increment WHERE p.id = :postId")
    void updateLikeCount(@Param("postId") String postId, @Param("increment") int increment);
    
    @Query("SELECT p FROM Post p JOIN p.author a WHERE a.id IN :connectionIds AND " +
           "p.visibility IN ('PUBLIC', 'CONNECTIONS_ONLY') AND p.status = 'PUBLISHED' " +
           "ORDER BY p.publishedAt DESC")
    Page<Post> findPostsFromConnections(@Param("connectionIds") List<String> connectionIds, 
                                      Pageable pageable);
}
```

## 🔄 **Database Migration Management**

### **Flyway Configuration**
```java
@Configuration
public class FlywayConfig {
    
    @Bean
    @Primary
    public Flyway flyway(@Qualifier("dataSource") DataSource dataSource) {
        return Flyway.configure()
            .dataSource(dataSource)
            .locations("classpath:db/migration")
            .baselineOnMigrate(true)
            .validateOnMigrate(true)
            .cleanDisabled(true)
            .load();
    }
    
    @EventListener
    public void handleContextRefresh(ContextRefreshedEvent event) {
        flyway(null).migrate();
    }
}
```

### **Migration Script Example**
```sql
-- V1_001__Create_personal_details_table.sql
CREATE TABLE personal_details (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_country_code VARCHAR(10),
    phone_number VARCHAR(20),
    gender VARCHAR(20),
    role VARCHAR(50) DEFAULT 'USER',
    profile_name VARCHAR(200),
    profile_state VARCHAR(20) DEFAULT 'DRAFT',
    profile_type VARCHAR(50),
    profile_visibility VARCHAR(20) DEFAULT 'PUBLIC',
    profile_completion INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    bio TEXT,
    hear_about_us JSONB,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    version BIGINT DEFAULT 0
);

-- Create indexes
CREATE INDEX idx_personal_details_email ON personal_details(email);
CREATE INDEX idx_personal_details_profile_type ON personal_details(profile_type);
CREATE INDEX idx_personal_details_created_at ON personal_details(created_at);
CREATE INDEX idx_personal_details_profile_state ON personal_details(profile_state);

-- Add constraints
ALTER TABLE personal_details ADD CONSTRAINT chk_profile_completion 
    CHECK (profile_completion >= 0 AND profile_completion <= 100);
```

## 📊 **Database Performance Optimization**

### **JPA Configuration**
```java
@Configuration
@EnableJpaRepositories(basePackages = "com.zbinnovation.repository")
@EnableJpaAuditing
public class JpaConfig {
    
    @Bean
    public PlatformTransactionManager transactionManager(EntityManagerFactory entityManagerFactory) {
        JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(entityManagerFactory);
        return transactionManager;
    }
    
    @Bean
    public AuditorAware<String> auditorProvider() {
        return new SpringSecurityAuditorAware();
    }
    
    @Bean
    public HibernatePropertiesCustomizer hibernatePropertiesCustomizer() {
        return hibernateProperties -> {
            hibernateProperties.put("hibernate.jdbc.batch_size", 25);
            hibernateProperties.put("hibernate.order_inserts", true);
            hibernateProperties.put("hibernate.order_updates", true);
            hibernateProperties.put("hibernate.jdbc.batch_versioned_data", true);
            hibernateProperties.put("hibernate.generate_statistics", true);
            hibernateProperties.put("hibernate.cache.use_second_level_cache", true);
            hibernateProperties.put("hibernate.cache.use_query_cache", true);
            hibernateProperties.put("hibernate.cache.region.factory_class", 
                "org.hibernate.cache.jcache.JCacheRegionFactory");
        };
    }
}
```

### **Connection Pool Configuration**
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/zbinnovation
    username: ${DB_USERNAME:zbinnovation_user}
    password: ${DB_PASSWORD:password}
    driver-class-name: org.postgresql.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 300000
      max-lifetime: 1200000
      connection-timeout: 20000
      leak-detection-threshold: 60000
      pool-name: ZbInnovationHikariCP
      
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
        use_sql_comments: true
        jdbc:
          lob:
            non_contextual_creation: true
```

### **Query Optimization Strategies**
```java
@Service
@Transactional(readOnly = true)
public class OptimizedQueryService {
    
    @PersistenceContext
    private EntityManager entityManager;
    
    // Batch processing for large datasets
    @Transactional
    public void batchUpdateProfileCompletion() {
        String jpql = "UPDATE PersonalDetails p SET p.profileCompletion = " +
                     "(SELECT COALESCE(SUM(CASE " +
                     "WHEN p.firstName IS NOT NULL THEN 5 " +
                     "WHEN p.lastName IS NOT NULL THEN 5 " +
                     "WHEN p.email IS NOT NULL THEN 5 " +
                     "WHEN p.bio IS NOT NULL THEN 10 " +
                     "ELSE 0 END), 0))";
        
        entityManager.createQuery(jpql).executeUpdate();
    }
    
    // Optimized pagination with cursor-based approach
    public Page<PersonalDetails> findUsersWithCursorPagination(String lastId, int limit) {
        String jpql = "SELECT p FROM PersonalDetails p WHERE " +
                     "(:lastId IS NULL OR p.id > :lastId) " +
                     "ORDER BY p.id ASC";
        
        TypedQuery<PersonalDetails> query = entityManager.createQuery(jpql, PersonalDetails.class);
        query.setParameter("lastId", lastId);
        query.setMaxResults(limit + 1); // +1 to check if there are more results
        
        List<PersonalDetails> results = query.getResultList();
        boolean hasNext = results.size() > limit;
        
        if (hasNext) {
            results.remove(results.size() - 1);
        }
        
        return new PageImpl<>(results, PageRequest.of(0, limit), results.size());
    }
    
    // Native query for complex analytics
    @Query(value = """
        SELECT 
            profile_type,
            COUNT(*) as total_users,
            AVG(profile_completion) as avg_completion,
            COUNT(CASE WHEN last_login_at >= NOW() - INTERVAL '30 days' THEN 1 END) as active_users
        FROM personal_details 
        WHERE profile_state = 'COMPLETE'
        GROUP BY profile_type
        ORDER BY total_users DESC
        """, nativeQuery = true)
    List<Object[]> getUserStatsByProfileType();
}
```

## 🔍 **Database Monitoring and Health Checks**

### **Database Health Indicator**
```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    
    @Autowired
    private DataSource dataSource;
    
    @Override
    public Health health() {
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(1)) {
                return Health.up()
                    .withDetail("database", "PostgreSQL")
                    .withDetail("status", "Connection successful")
                    .withDetail("validationQuery", "SELECT 1")
                    .build();
            } else {
                return Health.down()
                    .withDetail("database", "PostgreSQL")
                    .withDetail("status", "Connection validation failed")
                    .build();
            }
        } catch (Exception e) {
            return Health.down()
                .withDetail("database", "PostgreSQL")
                .withDetail("status", "Connection failed")
                .withDetail("error", e.getMessage())
                .build();
        }
    }
}
```

### **Database Metrics**
```java
@Component
public class DatabaseMetrics {
    
    private final MeterRegistry meterRegistry;
    private final DataSource dataSource;
    
    public DatabaseMetrics(MeterRegistry meterRegistry, DataSource dataSource) {
        this.meterRegistry = meterRegistry;
        this.dataSource = dataSource;
        
        // Register custom metrics
        Gauge.builder("database.connections.active")
            .description("Number of active database connections")
            .register(meterRegistry, this, DatabaseMetrics::getActiveConnections);
            
        Gauge.builder("database.connections.idle")
            .description("Number of idle database connections")
            .register(meterRegistry, this, DatabaseMetrics::getIdleConnections);
    }
    
    private double getActiveConnections() {
        if (dataSource instanceof HikariDataSource) {
            return ((HikariDataSource) dataSource).getHikariPoolMXBean().getActiveConnections();
        }
        return 0;
    }
    
    private double getIdleConnections() {
        if (dataSource instanceof HikariDataSource) {
            return ((HikariDataSource) dataSource).getHikariPoolMXBean().getIdleConnections();
        }
        return 0;
    }
}
```

---

## 📚 **Reference Documents**

**Database Schema**: See `/2_technical_architecture/2_database_schema_and_design.md`
**Core API Development**: See `/4_backend_implementation/1_core_api_development.md`
**Authentication Implementation**: See `/4_backend_implementation/3_authentication_and_security.md`
**API Testing**: See `/4_backend_implementation/5_api_testing_and_validation.md`

*This database implementation provides a robust, scalable data layer for the ZbInnovation platform with optimized performance and comprehensive monitoring.*
