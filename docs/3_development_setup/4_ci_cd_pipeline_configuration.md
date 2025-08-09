# 4. CI/CD Pipeline Configuration

## 🚀 **Enterprise CI/CD Pipeline Overview**

The SmileFactory platform uses a comprehensive enterprise-grade CI/CD pipeline designed for automated testing, building, and deployment. The pipeline ensures code quality, security, and reliable deployments across multiple environments with advanced monitoring and quality gates.

## 🏗️ **Pipeline Architecture**

### **Pipeline Stages**
```
┌─────────────────────────────────────────────────────────────┐
│                    SOURCE CONTROL                          │
│              Git Push/Pull Request                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   BUILD & TEST STAGE                       │
│    Code Quality, Unit Tests, Integration Tests             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  SECURITY & ANALYSIS                       │
│     Security Scans, Dependency Checks, SAST/DAST          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   ARTIFACT CREATION                        │
│        Docker Images, Application Packages                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT                             │
│      Dev → Staging → Production Environments               │
└─────────────────────────────────────────────────────────────┘
```

### **Technology Stack**
- **CI/CD Platform**: GitHub Actions (Primary), Jenkins (Backup)
- **Container Registry**: Docker Hub / AWS ECR
- **Deployment**: Kubernetes with Helm charts
- **Monitoring**: Prometheus, Grafana, New Relic
- **Security**: Trivy, SonarQube, OWASP ZAP

## 🔧 **GitHub Actions Workflows**

### **Main CI/CD Workflow**
```yaml
# .github/workflows/main.yml
name: Main CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  code-quality:
    name: Code Quality Checks
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Cache Maven dependencies
        uses: actions/cache@v3
        with:
          path: ~/.m2
          key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}

      - name: Run Checkstyle
        run: mvn checkstyle:check

      - name: Run SpotBugs
        run: mvn spotbugs:check

      - name: SonarQube Scan
        uses: sonarqube-quality-gate-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

  backend-tests:
    name: Backend Tests
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: zbinnovation_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Run unit tests
        run: mvn test

      - name: Run integration tests
        run: mvn verify -P integration-tests

      - name: Generate test report
        uses: dorny/test-reporter@v1
        if: success() || failure()
        with:
          name: Backend Test Results
          path: target/surefire-reports/*.xml
          reporter: java-junit

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: target/site/jacoco/jacoco.xml

  frontend-tests:
    name: Frontend Tests
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci

      - name: Run ESLint
        working-directory: ./frontend
        run: npm run lint

      - name: Run Prettier check
        working-directory: ./frontend
        run: npm run format:check

      - name: Run unit tests
        working-directory: ./frontend
        run: npm run test:coverage

      - name: Run E2E tests
        working-directory: ./frontend
        run: npm run test:e2e

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: frontend/coverage/lcov.info

  security-scan:
    name: Security Scanning
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

      - name: OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'zbinnovation-platform'
          path: '.'
          format: 'ALL'

  build-and-push:
    name: Build and Push Images
    runs-on: ubuntu-latest
    needs: [code-quality, backend-tests, frontend-tests, security-scan]
    if: github.event_name == 'push'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha,prefix={{branch}}-

      - name: Build and push backend image
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: ${{ steps.meta.outputs.tags }}-backend
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Build and push frontend image
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: ${{ steps.meta.outputs.tags }}-frontend
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build-and-push
    if: github.ref == 'refs/heads/develop'
    environment: staging
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure kubectl
        uses: azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}

      - name: Deploy to staging
        run: |
          helm upgrade --install zbinnovation-staging ./helm/zbinnovation \
            --namespace staging \
            --set image.tag=${{ github.sha }} \
            --set environment=staging \
            --values ./helm/values-staging.yaml

      - name: Run smoke tests
        run: |
          kubectl wait --for=condition=ready pod -l app=zbinnovation -n staging --timeout=300s
          npm run test:smoke -- --baseUrl=https://staging.zbinnovation.com

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: build-and-push
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure kubectl
        uses: azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}

      - name: Deploy to production
        run: |
          helm upgrade --install zbinnovation-prod ./helm/zbinnovation \
            --namespace production \
            --set image.tag=${{ github.sha }} \
            --set environment=production \
            --values ./helm/values-production.yaml

      - name: Run health checks
        run: |
          kubectl wait --for=condition=ready pod -l app=zbinnovation -n production --timeout=300s
          curl -f https://api.zbinnovation.com/health || exit 1

      - name: Notify deployment
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          channel: '#deployments'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### **Release Workflow**
```yaml
# .github/workflows/release.yml
name: Release Pipeline

on:
  push:
    tags:
      - 'v*'

jobs:
  create-release:
    name: Create Release
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate changelog
        id: changelog
        uses: conventional-changelog/conventional-changelog-action@v3
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}

      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body: ${{ steps.changelog.outputs.changelog }}
          draft: false
          prerelease: false

  deploy-production:
    name: Production Deployment
    runs-on: ubuntu-latest
    needs: create-release
    environment: production
    steps:
      - name: Deploy release to production
        run: |
          helm upgrade --install zbinnovation-prod ./helm/zbinnovation \
            --namespace production \
            --set image.tag=${{ github.ref_name }} \
            --set environment=production \
            --values ./helm/values-production.yaml
```

## 🐳 **Docker Configuration**

### **Backend Dockerfile**
```dockerfile
# backend/Dockerfile
FROM openjdk:17-jdk-slim as builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN ./mvnw clean package -DskipTests

FROM openjdk:17-jre-slim

RUN addgroup --system spring && adduser --system spring --ingroup spring
USER spring:spring

WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### **Frontend Dockerfile**
```dockerfile
# frontend/Dockerfile
FROM node:18-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

## ☸️ **Kubernetes Deployment**

### **Helm Chart Structure**
```
helm/zbinnovation/
├── Chart.yaml
├── values.yaml
├── values-staging.yaml
├── values-production.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── configmap.yaml
    ├── secret.yaml
    └── hpa.yaml
```

### **Deployment Template**
```yaml
# helm/zbinnovation/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "zbinnovation.fullname" . }}
  labels:
    {{- include "zbinnovation.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "zbinnovation.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "zbinnovation.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: backend
        image: "{{ .Values.backend.image.repository }}:{{ .Values.backend.image.tag }}"
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: {{ .Values.environment }}
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: {{ include "zbinnovation.fullname" . }}-secret
              key: database-url
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
      - name: frontend
        image: "{{ .Values.frontend.image.repository }}:{{ .Values.frontend.image.tag }}"
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
```

## 📊 **Pipeline Monitoring and Metrics**

### **Pipeline Metrics**
```yaml
# .github/workflows/metrics.yml
name: Pipeline Metrics

on:
  workflow_run:
    workflows: ["Main CI/CD Pipeline"]
    types: [completed]

jobs:
  collect-metrics:
    runs-on: ubuntu-latest
    steps:
      - name: Collect pipeline metrics
        run: |
          echo "Pipeline duration: ${{ github.event.workflow_run.run_duration_ms }}ms"
          echo "Pipeline status: ${{ github.event.workflow_run.conclusion }}"
          
      - name: Send metrics to monitoring
        uses: ./.github/actions/send-metrics
        with:
          metric_name: "pipeline_duration"
          metric_value: ${{ github.event.workflow_run.run_duration_ms }}
          labels: |
            workflow=${{ github.event.workflow_run.name }}
            status=${{ github.event.workflow_run.conclusion }}
```

### **Quality Gates**
```yaml
# Quality gate configuration
quality_gates:
  code_coverage:
    backend: 80%
    frontend: 85%
  
  security_scan:
    max_critical: 0
    max_high: 2
    max_medium: 10
  
  performance:
    build_time: 10m
    test_time: 5m
    deployment_time: 3m
  
  code_quality:
    sonar_gate: PASSED
    technical_debt: <30min
    duplicated_lines: <3%
```

## 🔧 **Environment Configuration**

### **Environment Variables**
```bash
# Development Environment
SPRING_PROFILES_ACTIVE=development
DATABASE_URL=jdbc:postgresql://localhost:5432/zbinnovation_dev
REDIS_URL=redis://localhost:6379
JWT_SECRET=dev-secret-key
EMAIL_SERVICE_API_KEY=dev-email-key

# Staging Environment
SPRING_PROFILES_ACTIVE=staging
DATABASE_URL=jdbc:postgresql://staging-db:5432/zbinnovation_staging
REDIS_URL=redis://staging-redis:6379
JWT_SECRET=${STAGING_JWT_SECRET}
EMAIL_SERVICE_API_KEY=${STAGING_EMAIL_KEY}

# Production Environment
SPRING_PROFILES_ACTIVE=production
DATABASE_URL=${PROD_DATABASE_URL}
REDIS_URL=${PROD_REDIS_URL}
JWT_SECRET=${PROD_JWT_SECRET}
EMAIL_SERVICE_API_KEY=${PROD_EMAIL_KEY}
```

### **Secrets Management**
```yaml
# GitHub Secrets Configuration
secrets:
  # Database
  PROD_DATABASE_URL: "encrypted-database-url"
  STAGING_DATABASE_URL: "encrypted-staging-db-url"
  
  # Authentication
  PROD_JWT_SECRET: "encrypted-jwt-secret"
  STAGING_JWT_SECRET: "encrypted-staging-jwt"
  
  # External Services
  PROD_EMAIL_KEY: "encrypted-email-api-key"
  STAGING_EMAIL_KEY: "encrypted-staging-email-key"
  
  # Infrastructure
  KUBE_CONFIG: "encrypted-kubernetes-config"
  DOCKER_REGISTRY_TOKEN: "encrypted-registry-token"
  
  # Monitoring
  SLACK_WEBHOOK: "encrypted-slack-webhook"
  NEW_RELIC_LICENSE_KEY: "encrypted-newrelic-key"
```

---

## 📚 **Reference Documents**

**Development Environment**: See `/3_development_setup/1_development_environment_setup.md`
**Version Control**: See `/3_development_setup/3_version_control_and_workflow.md`
**Security Design**: See `/2_technical_architecture/4_security_and_authentication_design.md`
**Deployment Operations**: See `/7_deployment_and_operations/1_production_deployment_setup.md`

## 🔄 **Enterprise Monitoring & Continuous Improvement**

### **Pipeline Optimization Cycle**
1. **Weekly Metrics Review**
   - Build time analysis and optimization
   - Failure pattern identification and resolution
   - Resource utilization assessment

2. **Monthly Pipeline Audit**
   - Security scan effectiveness evaluation
   - Test coverage gaps identification
   - Deployment reliability assessment

3. **Quarterly Strategy Review**
   - Tool evaluation and upgrades
   - Process improvements implementation
   - Team feedback integration

### **Quality Metrics & Feedback Loops**
- **Developer Feedback**: Build time satisfaction, pipeline usability, blocker identification
- **Operations Feedback**: Deployment reliability, monitoring effectiveness, incident response time
- **Business Feedback**: Feature delivery speed, quality perception, customer impact

### **Automated Monitoring**
- **Build Queue Monitoring**: Alert when queue length exceeds thresholds
- **Deployment Success Rate**: Monitor and alert on deployment success rates below 95%
- **Test Stability**: Track and alert on flaky test counts
- **Performance Metrics**: Continuous monitoring of pipeline performance

*This comprehensive enterprise CI/CD pipeline with monitoring and continuous improvement ensures high-quality, secure, and reliable deployments for the SmileFactory platform while maintaining developer productivity and operational excellence.*
