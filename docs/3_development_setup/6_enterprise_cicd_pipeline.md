# 6. Enterprise CI/CD Pipeline Configuration

## 🚀 **CI/CD Pipeline Overview**

This document defines the comprehensive CI/CD pipeline for the ZbInnovation platform, supporting React frontend and Java Spring Boot backend with enterprise-grade quality gates, security scanning, and deployment automation.

## 🏗️ **Pipeline Architecture**

### **Multi-Stage Pipeline Strategy**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Development   │    │     Staging     │    │   Production    │
│   Environment   │    │   Environment   │    │   Environment   │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • Auto Deploy   │    │ • Auto Deploy   │    │ • Manual Deploy │
│ • Feature Tests │    │ • Integration   │    │ • Blue/Green    │
│ • Code Quality  │    │ • Performance   │    │ • Rollback      │
│ • Security Scan │    │ • User Testing  │    │ • Monitoring    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Quality Gates Framework**
```yaml
quality_gates:
  code_quality:
    - sonarqube_analysis: "A"
    - test_coverage: ">80%"
    - code_duplication: "<3%"
    - maintainability_rating: "A"
  
  security:
    - vulnerability_scan: "no_high_severity"
    - dependency_check: "no_known_vulnerabilities"
    - secrets_detection: "no_secrets_exposed"
    - license_compliance: "approved_licenses_only"
  
  performance:
    - build_time: "<10_minutes"
    - bundle_size: "<2MB"
    - lighthouse_score: ">90"
    - api_response_time: "<200ms"
  
  testing:
    - unit_tests: "100%_pass"
    - integration_tests: "100%_pass"
    - e2e_tests: "100%_pass"
    - accessibility_tests: "wcag_aa_compliant"
```

## 📋 **Comprehensive Bitbucket Pipelines Configuration**

### **Main Pipeline Configuration**
```yaml
# bitbucket-pipelines.yml
image: atlassian/default-image:3

definitions:
  caches:
    sonar: ~/.sonar/cache
    maven-custom: ~/.m2/repository
    node-custom: node_modules
  
  services:
    postgres:
      image: postgres:13
      variables:
        POSTGRES_DB: zbinnovation_test
        POSTGRES_USER: test
        POSTGRES_PASSWORD: test
    
    redis:
      image: redis:7-alpine
    
    elasticsearch:
      image: elasticsearch:8.8.0
      variables:
        discovery.type: single-node
        xpack.security.enabled: false

  steps:
    - step: &frontend-quality-gates
        name: Frontend Quality Gates
        image: node:18
        caches:
          - node-custom
        script:
          - cd frontend
          - npm ci
          # Code Quality
          - npm run lint:check
          - npm run prettier:check
          - npm run type-check
          # Security Scanning
          - npm audit --audit-level=moderate
          - npx snyk test
          # Testing
          - npm run test:unit -- --coverage --watchAll=false
          - npm run test:integration
          # Performance
          - npm run build
          - npm run analyze:bundle
        artifacts:
          - frontend/coverage/**
          - frontend/dist/**
          - frontend/reports/**
    
    - step: &backend-quality-gates
        name: Backend Quality Gates
        image: maven:3.8.6-openjdk-17
        caches:
          - maven-custom
          - sonar
        services:
          - postgres
          - redis
        script:
          - cd backend
          # Code Quality
          - mvn clean compile
          - mvn checkstyle:check
          - mvn spotbugs:check
          # Security Scanning
          - mvn dependency-check:check
          - mvn org.owasp:dependency-check-maven:check
          # Testing
          - mvn test jacoco:report
          - mvn verify
          # SonarQube Analysis
          - mvn sonar:sonar -Dsonar.projectKey=$SONAR_PROJECT_KEY
        artifacts:
          - backend/target/**
          - backend/reports/**
    
    - step: &integration-tests
        name: Integration & E2E Tests
        image: atlassian/default-image:3
        services:
          - postgres
          - redis
          - elasticsearch
        script:
          # Start application stack
          - docker-compose -f docker-compose.test.yml up -d
          - sleep 30  # Wait for services to be ready
          # API Integration Tests
          - cd backend && mvn test -Dtest=**/*IntegrationTest
          # Frontend E2E Tests
          - cd frontend && npm run test:e2e:headless
          # Performance Tests
          - npm run test:performance
          # Accessibility Tests
          - npm run test:accessibility
          # Cleanup
          - docker-compose -f docker-compose.test.yml down
        artifacts:
          - test-results/**
          - performance-reports/**
    
    - step: &security-scan
        name: Security & Compliance Scan
        image: owasp/zap2docker-stable
        script:
          # OWASP ZAP Security Scan
          - zap-baseline.py -t http://localhost:3000 -r security-report.html
          # Container Security Scan
          - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock 
            aquasec/trivy image zbinnovation/frontend:latest
          - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock 
            aquasec/trivy image zbinnovation/backend:latest
        artifacts:
          - security-report.html
          - trivy-reports/**
    
    - step: &build-and-package
        name: Build & Package Applications
        script:
          # Build Docker images
          - docker build -t zbinnovation/frontend:$BITBUCKET_BUILD_NUMBER ./frontend
          - docker build -t zbinnovation/backend:$BITBUCKET_BUILD_NUMBER ./backend
          # Tag for registry
          - docker tag zbinnovation/frontend:$BITBUCKET_BUILD_NUMBER 
            $DOCKER_REGISTRY/zbinnovation/frontend:$BITBUCKET_BUILD_NUMBER
          - docker tag zbinnovation/backend:$BITBUCKET_BUILD_NUMBER 
            $DOCKER_REGISTRY/zbinnovation/backend:$BITBUCKET_BUILD_NUMBER
          # Push to registry
          - docker push $DOCKER_REGISTRY/zbinnovation/frontend:$BITBUCKET_BUILD_NUMBER
          - docker push $DOCKER_REGISTRY/zbinnovation/backend:$BITBUCKET_BUILD_NUMBER
    
    - step: &deploy-staging
        name: Deploy to Staging
        deployment: staging
        script:
          # Update Kubernetes manifests
          - sed -i "s/IMAGE_TAG/$BITBUCKET_BUILD_NUMBER/g" k8s/staging/*.yml
          # Deploy to staging
          - kubectl apply -f k8s/staging/
          # Wait for deployment
          - kubectl rollout status deployment/frontend-staging
          - kubectl rollout status deployment/backend-staging
          # Run smoke tests
          - npm run test:smoke:staging
        after-script:
          # Update JIRA with deployment status
          - pipe: atlassian/jira-integration:1.0.0
            variables:
              JIRA_ISSUE_KEY: $BITBUCKET_BRANCH
              DEPLOYMENT_STATUS: "staging_deployed"
              DEPLOYMENT_URL: $STAGING_URL
    
    - step: &deploy-production
        name: Deploy to Production
        deployment: production
        trigger: manual
        script:
          # Blue/Green Deployment
          - ./scripts/blue-green-deploy.sh $BITBUCKET_BUILD_NUMBER
          # Health checks
          - ./scripts/health-check.sh
          # Update monitoring
          - ./scripts/update-monitoring.sh $BITBUCKET_BUILD_NUMBER
        after-script:
          # Notify stakeholders
          - pipe: atlassian/slack:0.1.5
            variables:
              WEBHOOK_URL: $SLACK_WEBHOOK
              MESSAGE: "🚀 ZbInnovation v$BITBUCKET_BUILD_NUMBER deployed to production"

pipelines:
  default:
    - parallel:
        - step: *frontend-quality-gates
        - step: *backend-quality-gates
    - step: *integration-tests
    - step: *security-scan
    - step: *build-and-package

  branches:
    develop:
      - parallel:
          - step: *frontend-quality-gates
          - step: *backend-quality-gates
      - step: *integration-tests
      - step: *security-scan
      - step: *build-and-package
      - step: *deploy-staging
    
    main:
      - parallel:
          - step: *frontend-quality-gates
          - step: *backend-quality-gates
      - step: *integration-tests
      - step: *security-scan
      - step: *build-and-package
      - step: *deploy-staging
      - step: *deploy-production

  pull-requests:
    '**':
      - parallel:
          - step: *frontend-quality-gates
          - step: *backend-quality-gates
      - step: *integration-tests

  custom:
    security-scan-only:
      - step: *security-scan
    
    performance-test:
      - step:
          name: Performance Testing
          script:
            - npm run test:performance:full
            - npm run test:load:staging
```

## 🔧 **Pipeline Optimization Strategies**

### **Caching Strategy**
- **Node Modules**: Cache npm dependencies between builds
- **Maven Dependencies**: Cache .m2 repository
- **Docker Layers**: Use multi-stage builds with layer caching
- **SonarQube Cache**: Cache analysis data

### **Parallel Execution**
- Frontend and backend quality gates run in parallel
- Independent test suites run concurrently
- Multi-environment deployments when applicable

### **Conditional Execution**
- Security scans only on main branches
- Performance tests only on release branches
- Full E2E tests only on staging deployments

## 📊 **Pipeline Monitoring & Alerting**

### **Build Metrics Dashboard**
```yaml
metrics_collection:
  build_metrics:
    - build_duration
    - success_rate
    - failure_reasons
    - queue_time

  quality_metrics:
    - test_coverage_trend
    - code_quality_score
    - security_vulnerabilities
    - performance_regression

  deployment_metrics:
    - deployment_frequency
    - lead_time
    - mean_time_to_recovery
    - change_failure_rate
```

### **Alert Configuration**
```yaml
alerts:
  build_failures:
    condition: "build_failure_rate > 10%"
    notification: ["slack", "email", "jira"]
    escalation: "tech_lead"

  security_vulnerabilities:
    condition: "high_severity_vulnerabilities > 0"
    notification: ["security_team", "tech_lead"]
    action: "block_deployment"

  performance_regression:
    condition: "response_time_increase > 20%"
    notification: ["performance_team"]
    action: "rollback_consideration"

  deployment_failures:
    condition: "deployment_failure"
    notification: ["ops_team", "on_call"]
    action: "immediate_investigation"
```

### **Pipeline Health Checks**
```bash
# Automated pipeline health monitoring
#!/bin/bash
# pipeline-health-check.sh

# Check build queue health
check_build_queue() {
    queue_length=$(bitbucket-api get-queue-length)
    if [ $queue_length -gt 10 ]; then
        alert "Build queue length: $queue_length"
    fi
}

# Check deployment success rate
check_deployment_success() {
    success_rate=$(get_deployment_success_rate_last_24h)
    if [ $success_rate -lt 95 ]; then
        alert "Deployment success rate below 95%: $success_rate%"
    fi
}

# Check test stability
check_test_stability() {
    flaky_tests=$(get_flaky_test_count)
    if [ $flaky_tests -gt 5 ]; then
        alert "Flaky test count: $flaky_tests"
    fi
}
```

## 🔄 **Continuous Improvement Process**

### **Pipeline Optimization Cycle**
1. **Weekly Metrics Review**
   - Build time analysis
   - Failure pattern identification
   - Resource utilization assessment

2. **Monthly Pipeline Audit**
   - Security scan effectiveness
   - Test coverage gaps
   - Deployment reliability

3. **Quarterly Strategy Review**
   - Tool evaluation
   - Process improvements
   - Team feedback integration

### **Feedback Loops**
```yaml
feedback_mechanisms:
  developer_feedback:
    - build_time_satisfaction
    - pipeline_usability
    - blocker_identification

  operations_feedback:
    - deployment_reliability
    - monitoring_effectiveness
    - incident_response_time

  business_feedback:
    - feature_delivery_speed
    - quality_perception
    - customer_impact
```

---

*This comprehensive enterprise CI/CD pipeline with monitoring and continuous improvement ensures high-quality, secure, and reliable deployments for the ZbInnovation platform while maintaining developer productivity and operational excellence.*
