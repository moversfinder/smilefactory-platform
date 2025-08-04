# 1. Production Deployment Setup

## 🚀 **Production Deployment Overview**

This document outlines the comprehensive production deployment setup for the ZbInnovation platform, including infrastructure provisioning, containerization, orchestration, and deployment automation using modern DevOps practices.

## 🏗️ **Infrastructure Architecture**

### **Production Environment Architecture**
```
┌─────────────────────────────────────────────────────────────┐
│                    Load Balancer (ALB)                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Frontend      │  │   Backend       │  │   WebSocket     │
│   (React)       │  │   (Spring Boot) │  │   Service       │
│   Pods: 3       │  │   Pods: 5       │  │   Pods: 2       │
└─────────────────┘  └─────────────────┘  └─────────────────┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   PostgreSQL    │  │   Redis Cache   │  │   File Storage  │
│   (RDS)         │  │   (ElastiCache) │  │   (S3)          │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### **Kubernetes Cluster Configuration**
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: zbinnovation-prod
  labels:
    environment: production
    app: zbinnovation

---
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: zbinnovation-config
  namespace: zbinnovation-prod
data:
  ENVIRONMENT: "production"
  LOG_LEVEL: "INFO"
  DATABASE_HOST: "zbinnovation-db.cluster-xyz.us-east-1.rds.amazonaws.com"
  REDIS_HOST: "zbinnovation-cache.abc123.cache.amazonaws.com"
  S3_BUCKET: "zbinnovation-prod-assets"
  API_BASE_URL: "https://api.zbinnovation.com"
  FRONTEND_URL: "https://zbinnovation.com"

---
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: zbinnovation-secrets
  namespace: zbinnovation-prod
type: Opaque
data:
  DATABASE_PASSWORD: <base64-encoded-password>
  JWT_SECRET: <base64-encoded-jwt-secret>
  REDIS_PASSWORD: <base64-encoded-redis-password>
  AWS_ACCESS_KEY_ID: <base64-encoded-access-key>
  AWS_SECRET_ACCESS_KEY: <base64-encoded-secret-key>
```

## 🐳 **Containerization Strategy**

### **Backend Dockerfile**
```dockerfile
# backend/Dockerfile
FROM openjdk:17-jdk-slim as builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build application
RUN ./mvnw clean package -DskipTests

# Production image
FROM openjdk:17-jre-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy application jar
COPY --from=builder /app/target/zbinnovation-*.jar app.jar

# Change ownership to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

### **Frontend Dockerfile**
```dockerfile
# frontend/Dockerfile
FROM node:18-alpine as builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production image
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### **Nginx Configuration**
```nginx
# frontend/nginx.conf
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                   '$status $body_bytes_sent "$http_referer" '
                   '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/javascript application/xml+rss 
               application/json application/xml;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    server {
        listen 80;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        # Static assets with long cache
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        # API proxy
        location /api/ {
            proxy_pass http://zbinnovation-backend:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # SPA routing
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
```

## ⚙️ **Kubernetes Deployments**

### **Backend Deployment**
```yaml
# k8s/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: zbinnovation-backend
  namespace: zbinnovation-prod
  labels:
    app: zbinnovation-backend
    version: v1
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
  selector:
    matchLabels:
      app: zbinnovation-backend
  template:
    metadata:
      labels:
        app: zbinnovation-backend
        version: v1
    spec:
      containers:
      - name: backend
        image: zbinnovation/backend:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "production"
        envFrom:
        - configMapRef:
            name: zbinnovation-config
        - secretRef:
            name: zbinnovation-secrets
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 3
        volumeMounts:
        - name: logs
          mountPath: /app/logs
      volumes:
      - name: logs
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: zbinnovation-backend
  namespace: zbinnovation-prod
spec:
  selector:
    app: zbinnovation-backend
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
```

### **Frontend Deployment**
```yaml
# k8s/frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: zbinnovation-frontend
  namespace: zbinnovation-prod
  labels:
    app: zbinnovation-frontend
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: zbinnovation-frontend
  template:
    metadata:
      labels:
        app: zbinnovation-frontend
        version: v1
    spec:
      containers:
      - name: frontend
        image: zbinnovation/frontend:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10

---
apiVersion: v1
kind: Service
metadata:
  name: zbinnovation-frontend
  namespace: zbinnovation-prod
spec:
  selector:
    app: zbinnovation-frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

## 🔄 **CI/CD Pipeline**

### **GitHub Actions Workflow**
```yaml
# .github/workflows/deploy-production.yml
name: Deploy to Production

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: zbinnovation

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: frontend/package-lock.json
    
    - name: Run backend tests
      run: |
        cd backend
        ./mvnw test
    
    - name: Run frontend tests
      run: |
        cd frontend
        npm ci
        npm run test:ci
    
    - name: Run E2E tests
      run: |
        cd frontend
        npm run test:e2e

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v')
    
    strategy:
      matrix:
        component: [backend, frontend]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/${{ matrix.component }}
        tags: |
          type=ref,event=branch
          type=ref,event=tag
          type=sha,prefix={{branch}}-
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: ./${{ matrix.component }}
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --name zbinnovation-prod-cluster
    
    - name: Deploy to Kubernetes
      run: |
        # Update image tags in deployment files
        sed -i "s|image: zbinnovation/backend:.*|image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/backend:main|" k8s/backend-deployment.yaml
        sed -i "s|image: zbinnovation/frontend:.*|image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/frontend:main|" k8s/frontend-deployment.yaml
        
        # Apply deployments
        kubectl apply -f k8s/
        
        # Wait for rollout to complete
        kubectl rollout status deployment/zbinnovation-backend -n zbinnovation-prod --timeout=600s
        kubectl rollout status deployment/zbinnovation-frontend -n zbinnovation-prod --timeout=600s
    
    - name: Run smoke tests
      run: |
        # Wait for services to be ready
        sleep 60
        
        # Run basic health checks
        kubectl exec -n zbinnovation-prod deployment/zbinnovation-backend -- curl -f http://localhost:8080/actuator/health
        
        # Run external smoke tests
        curl -f https://api.zbinnovation.com/health
        curl -f https://zbinnovation.com/health
```

## 🔒 **Security Configuration**

### **Network Policies**
```yaml
# k8s/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: zbinnovation-network-policy
  namespace: zbinnovation-prod
spec:
  podSelector:
    matchLabels:
      app: zbinnovation-backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: zbinnovation-frontend
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 5432  # PostgreSQL
    - protocol: TCP
      port: 6379  # Redis
    - protocol: TCP
      port: 443   # HTTPS
    - protocol: TCP
      port: 53    # DNS
    - protocol: UDP
      port: 53    # DNS
```

### **Pod Security Standards**
```yaml
# k8s/pod-security-policy.yaml
apiVersion: v1
kind: Pod
metadata:
  name: zbinnovation-backend
  namespace: zbinnovation-prod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: backend
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: logs
      mountPath: /app/logs
  volumes:
  - name: tmp
    emptyDir: {}
  - name: logs
    emptyDir: {}
```

---

## 📚 **Reference Documents**

**CI/CD Configuration**: See `/3_development_setup/4_ci_cd_pipeline_configuration.md`
**System Architecture**: See `/2_technical_architecture/1_system_architecture_design.md`
**Security Design**: See `/2_technical_architecture/4_security_and_authentication_design.md`
**Monitoring Setup**: See `/7_deployment_and_operations/2_monitoring_and_logging.md`

*This production deployment setup ensures secure, scalable, and reliable deployment of the ZbInnovation platform using modern containerization and orchestration technologies.*
