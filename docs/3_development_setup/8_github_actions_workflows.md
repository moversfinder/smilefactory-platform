# 8. GitHub Actions Workflows

## 🚀 **GitHub Actions CI/CD Overview**

This document defines comprehensive GitHub Actions workflows for the ZbInnovation platform, replacing Bitbucket Pipelines with GitHub-native CI/CD automation for React frontend and Java Spring Boot backend.

## 🏗️ **Workflow Architecture**

### **Multi-Workflow Strategy**
```
.github/workflows/
├── ci.yml                    # Continuous Integration
├── frontend-deploy.yml       # Frontend Deployment
├── backend-deploy.yml        # Backend Deployment
├── security-scan.yml         # Security Scanning
├── performance-test.yml      # Performance Testing
└── release.yml              # Release Management
```

## 📋 **Core CI/CD Workflow**

### **Main CI Workflow (.github/workflows/ci.yml)**
```yaml
name: Continuous Integration

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  NODE_VERSION: '18'
  JAVA_VERSION: '17'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  frontend-quality-gates:
    name: Frontend Quality Gates
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        run: npm ci
      
      - name: Code Quality Checks
        run: |
          npm run lint:check
          npm run prettier:check
          npm run type-check
      
      - name: Security Audit
        run: |
          npm audit --audit-level=moderate
          npx snyk test --severity-threshold=medium
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      
      - name: Unit Tests
        run: npm run test:unit -- --coverage --watchAll=false
      
      - name: Integration Tests
        run: npm run test:integration
      
      - name: Build Application
        run: npm run build
      
      - name: Bundle Analysis
        run: npm run analyze:bundle
      
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./frontend/coverage/lcov.info
          flags: frontend
      
      - name: Upload Build Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: frontend-build
          path: frontend/dist/

  backend-quality-gates:
    name: Backend Quality Gates
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend
    
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_DB: zbinnovation_test
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
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
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: ${{ env.JAVA_VERSION }}
          distribution: 'temurin'
          cache: maven
      
      - name: Code Quality Checks
        run: |
          mvn clean compile
          mvn checkstyle:check
          mvn spotbugs:check
      
      - name: Security Scanning
        run: |
          mvn dependency-check:check
          mvn org.owasp:dependency-check-maven:check
      
      - name: Unit Tests
        run: mvn test jacoco:report
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/zbinnovation_test
          SPRING_DATASOURCE_USERNAME: test
          SPRING_DATASOURCE_PASSWORD: test
          SPRING_REDIS_HOST: localhost
          SPRING_REDIS_PORT: 6379
      
      - name: Integration Tests
        run: mvn verify
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/zbinnovation_test
          SPRING_DATASOURCE_USERNAME: test
          SPRING_DATASOURCE_PASSWORD: test
      
      - name: SonarQube Analysis
        run: |
          mvn sonar:sonar \
            -Dsonar.projectKey=${{ secrets.SONAR_PROJECT_KEY }} \
            -Dsonar.host.url=${{ secrets.SONAR_HOST_URL }} \
            -Dsonar.login=${{ secrets.SONAR_TOKEN }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      
      - name: Build Application
        run: mvn package -DskipTests
      
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./backend/target/site/jacoco/jacoco.xml
          flags: backend
      
      - name: Upload Build Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: backend-build
          path: backend/target/*.jar

  integration-tests:
    name: Integration & E2E Tests
    runs-on: ubuntu-latest
    needs: [frontend-quality-gates, backend-quality-gates]
    
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_DB: zbinnovation_test
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Download Frontend Build
        uses: actions/download-artifact@v4
        with:
          name: frontend-build
          path: frontend/dist/
      
      - name: Download Backend Build
        uses: actions/download-artifact@v4
        with:
          name: backend-build
          path: backend/target/
      
      - name: Setup Docker Compose
        run: |
          docker-compose -f docker-compose.test.yml up -d
          sleep 30  # Wait for services to be ready
      
      - name: API Integration Tests
        working-directory: ./backend
        run: mvn test -Dtest=**/*IntegrationTest
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/zbinnovation_test
          SPRING_DATASOURCE_USERNAME: test
          SPRING_DATASOURCE_PASSWORD: test
      
      - name: Setup Node.js for E2E
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install Frontend Dependencies
        working-directory: ./frontend
        run: npm ci
      
      - name: E2E Tests
        working-directory: ./frontend
        run: npm run test:e2e:headless
      
      - name: Performance Tests
        working-directory: ./frontend
        run: npm run test:performance
      
      - name: Accessibility Tests
        working-directory: ./frontend
        run: npm run test:accessibility
      
      - name: Cleanup
        if: always()
        run: docker-compose -f docker-compose.test.yml down
      
      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: |
            frontend/test-results/
            backend/target/surefire-reports/

  security-scan:
    name: Security & Compliance Scan
    runs-on: ubuntu-latest
    needs: [frontend-quality-gates, backend-quality-gates]
    
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
      
      - name: OWASP ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.7.0
        with:
          target: 'http://localhost:3000'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a'
```

## 🚀 **Deployment Workflows**

### **Frontend Deployment (.github/workflows/frontend-deploy.yml)**
```yaml
name: Frontend Deployment

on:
  push:
    branches: [ main ]
    paths: [ 'frontend/**' ]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: zbinnovation/frontend

jobs:
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci
      
      - name: Build for staging
        working-directory: ./frontend
        run: npm run build:staging
        env:
          VITE_API_URL: ${{ secrets.STAGING_API_URL }}
          VITE_SUPABASE_URL: ${{ secrets.STAGING_SUPABASE_URL }}
          VITE_SUPABASE_ANON_KEY: ${{ secrets.STAGING_SUPABASE_ANON_KEY }}
      
      - name: Deploy to Staging
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./frontend/dist
          cname: staging.zbinnovation.co.zw
      
      - name: Run Smoke Tests
        working-directory: ./frontend
        run: npm run test:smoke:staging
        env:
          STAGING_URL: https://staging.zbinnovation.co.zw
      
      - name: Update JIRA
        uses: atlassian/gajira-transition@master
        with:
          issue: ${{ github.event.head_commit.message }}
          transition: "Deploy to Staging"
        env:
          JIRA_BASE_URL: ${{ secrets.JIRA_BASE_URL }}
          JIRA_USER_EMAIL: ${{ secrets.JIRA_USER_EMAIL }}
          JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    environment: production
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci
      
      - name: Build for production
        working-directory: ./frontend
        run: npm run build:production
        env:
          VITE_API_URL: ${{ secrets.PRODUCTION_API_URL }}
          VITE_SUPABASE_URL: ${{ secrets.PRODUCTION_SUPABASE_URL }}
          VITE_SUPABASE_ANON_KEY: ${{ secrets.PRODUCTION_SUPABASE_ANON_KEY }}
      
      - name: Deploy to Production
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./frontend/dist
          cname: zbinnovation.co.zw
      
      - name: Health Check
        run: |
          curl -f https://zbinnovation.co.zw/health || exit 1
      
      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          channel: '#deployments'
          message: '🚀 Frontend deployed to production'
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### **Backend Deployment (.github/workflows/backend-deploy.yml)**
```yaml
name: Backend Deployment

on:
  push:
    branches: [ main ]
    paths: [ 'backend/**' ]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: zbinnovation/backend

jobs:
  deploy-staging:
    name: Deploy Backend to Staging
    runs-on: ubuntu-latest
    environment: staging

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Build Application
        working-directory: ./backend
        run: mvn clean package -DskipTests

      - name: Build Docker Image
        working-directory: ./backend
        run: |
          docker build -t ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:staging-${{ github.sha }} .
          docker build -t ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:staging-latest .

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Push Docker Image
        run: |
          docker push ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:staging-${{ github.sha }}
          docker push ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:staging-latest

      - name: Deploy to Kubernetes Staging
        uses: azure/k8s-deploy@v1
        with:
          manifests: |
            k8s/staging/backend-deployment.yml
            k8s/staging/backend-service.yml
          images: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:staging-${{ github.sha }}
          kubectl-version: 'latest'
        env:
          KUBE_CONFIG: ${{ secrets.KUBE_CONFIG_STAGING }}

      - name: Health Check
        run: |
          sleep 60  # Wait for deployment
          curl -f ${{ secrets.STAGING_API_URL }}/health || exit 1

  deploy-production:
    name: Deploy Backend to Production
    runs-on: ubuntu-latest
    environment: production
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Build Application
        working-directory: ./backend
        run: mvn clean package -DskipTests

      - name: Build Docker Image
        working-directory: ./backend
        run: |
          docker build -t ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} .
          docker build -t ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest .

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Push Docker Image
        run: |
          docker push ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          docker push ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest

      - name: Blue-Green Deployment
        uses: azure/k8s-deploy@v1
        with:
          strategy: blue-green
          manifests: |
            k8s/production/backend-deployment.yml
            k8s/production/backend-service.yml
          images: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          kubectl-version: 'latest'
        env:
          KUBE_CONFIG: ${{ secrets.KUBE_CONFIG_PRODUCTION }}

      - name: Health Check
        run: |
          sleep 120  # Wait for blue-green deployment
          curl -f ${{ secrets.PRODUCTION_API_URL }}/health || exit 1
```

### **Release Management (.github/workflows/release.yml)**
```yaml
name: Release Management

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    inputs:
      version:
        description: 'Release version (e.g., v1.2.0)'
        required: true
        type: string

jobs:
  create-release:
    name: Create Release
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Generate Release Notes
        id: release_notes
        run: |
          ./scripts/generate-release-notes.sh ${{ github.ref_name }} > release-notes.md
          echo "release_notes<<EOF" >> $GITHUB_OUTPUT
          cat release-notes.md >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Build Frontend
        working-directory: ./frontend
        run: |
          npm ci
          npm run build:production

      - name: Build Backend
        working-directory: ./backend
        run: mvn clean package -DskipTests

      - name: Create Release Archive
        run: |
          mkdir -p release-artifacts
          cp -r frontend/dist release-artifacts/frontend
          cp backend/target/*.jar release-artifacts/
          tar -czf zbinnovation-${{ github.ref_name }}.tar.gz release-artifacts/

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ github.ref_name }}
          name: ZbInnovation ${{ github.ref_name }}
          body: ${{ steps.release_notes.outputs.release_notes }}
          files: |
            zbinnovation-${{ github.ref_name }}.tar.gz
            release-artifacts/*.jar
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Update JIRA Release
        run: |
          curl -X POST \
            -H "Authorization: Basic ${{ secrets.JIRA_AUTH }}" \
            -H "Content-Type: application/json" \
            -d '{
              "name": "${{ github.ref_name }}",
              "description": "Release ${{ github.ref_name }}",
              "released": true,
              "releaseDate": "'$(date -I)'"
            }' \
            "${{ secrets.JIRA_BASE_URL }}/rest/api/3/project/${{ secrets.JIRA_PROJECT_KEY }}/version"

      - name: Notify Stakeholders
        uses: 8398a7/action-slack@v3
        with:
          status: success
          channel: '#releases'
          message: |
            🎉 ZbInnovation ${{ github.ref_name }} has been released!

            📋 Release Notes: ${{ github.server_url }}/${{ github.repository }}/releases/tag/${{ github.ref_name }}
            🚀 Production URL: https://zbinnovation.co.zw
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## 🔧 **Workflow Configuration Files**

### **Dependabot Configuration (.github/dependabot.yml)**
```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/frontend"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "frontend-team"
    assignees:
      - "tech-lead"

  - package-ecosystem: "maven"
    directory: "/backend"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "backend-team"
    assignees:
      - "tech-lead"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
    reviewers:
      - "devops-team"
```

### **Issue Templates (.github/ISSUE_TEMPLATE/)**
```yaml
# .github/ISSUE_TEMPLATE/bug_report.yml
name: Bug Report
description: File a bug report
title: "[Bug]: "
labels: ["bug", "triage"]
assignees:
  - tech-lead
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to fill out this bug report!
  - type: input
    id: contact
    attributes:
      label: Contact Details
      description: How can we get in touch with you if we need more info?
      placeholder: ex. email@example.com
    validations:
      required: false
  - type: textarea
    id: what-happened
    attributes:
      label: What happened?
      description: Also tell us, what did you expect to happen?
      placeholder: Tell us what you see!
    validations:
      required: true
```

---

*This comprehensive GitHub Actions setup provides enterprise-grade CI/CD automation for the ZbInnovation platform with quality gates, security scanning, automated deployments, and release management.*
