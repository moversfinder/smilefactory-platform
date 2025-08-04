# 1. Development Environment Setup

## 🛠️ **Development Environment Overview**

This document provides comprehensive setup instructions for the ZbInnovation platform development environment, including all necessary tools, dependencies, and configurations for both frontend and backend development.

## 💻 **System Requirements**

### **Hardware Requirements**
- **CPU**: Intel i5/AMD Ryzen 5 or better (8+ cores recommended)
- **RAM**: 16GB minimum (32GB recommended for optimal performance)
- **Storage**: 500GB SSD minimum (1TB recommended)
- **Network**: Stable internet connection for cloud services and dependencies

### **Operating System Support**
- **Windows**: Windows 10/11 with WSL2
- **macOS**: macOS 12+ (Monterey or later)
- **Linux**: Ubuntu 20.04+, CentOS 8+, or equivalent distributions

## 🔧 **Core Development Tools**

### **Version Control**
```bash
# Git installation and configuration
git --version  # Verify Git 2.30+ is installed
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

### **Code Editors and IDEs**
**Primary IDE Options**:
- **IntelliJ IDEA Ultimate**: Recommended for full-stack development
- **Visual Studio Code**: Lightweight option with extensions
- **Eclipse IDE**: Alternative Java development environment

**Required VS Code Extensions** (if using VS Code):
```
- Extension Pack for Java
- Spring Boot Extension Pack
- ES7+ React/Redux/React-Native snippets
- TypeScript Importer
- Prettier - Code formatter
- ESLint
- GitLens
- Thunder Client (API testing)
```

## ☕ **Backend Development Setup**

### **Java Development Kit (JDK)**
```bash
# Install Java 17 (LTS)
# Windows (using Chocolatey)
choco install openjdk17

# macOS (using Homebrew)
brew install openjdk@17

# Linux (Ubuntu)
sudo apt update
sudo apt install openjdk-17-jdk

# Verify installation
java -version
javac -version
```

### **Maven Build Tool**
```bash
# Install Maven 3.9+
# Windows (using Chocolatey)
choco install maven

# macOS (using Homebrew)
brew install maven

# Linux (Ubuntu)
sudo apt install maven

# Verify installation
mvn -version
```

### **Database Setup**

#### **PostgreSQL Installation**
```bash
# Windows (using Chocolatey)
choco install postgresql

# macOS (using Homebrew)
brew install postgresql
brew services start postgresql

# Linux (Ubuntu)
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create development database
sudo -u postgres createdb zbinnovation_dev
sudo -u postgres createuser --interactive zbinnovation_user
```

#### **Redis Installation**
```bash
# Windows (using Chocolatey)
choco install redis-64

# macOS (using Homebrew)
brew install redis
brew services start redis

# Linux (Ubuntu)
sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Verify Redis installation
redis-cli ping  # Should return PONG
```

### **Backend Environment Configuration**
```properties
# application-dev.properties
spring.datasource.url=jdbc:postgresql://localhost:5432/zbinnovation_dev
spring.datasource.username=zbinnovation_user
spring.datasource.password=your_password
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Redis configuration
spring.redis.host=localhost
spring.redis.port=6379
spring.redis.timeout=2000ms

# JWT configuration
jwt.secret=your-secret-key
jwt.expiration=86400000

# File upload configuration
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

## ⚛️ **Frontend Development Setup**

### **Node.js and npm**
```bash
# Install Node.js 18+ (LTS)
# Download from https://nodejs.org/ or use version manager

# Using nvm (recommended)
# Install nvm first, then:
nvm install 18
nvm use 18

# Verify installation
node --version  # Should be 18.x.x
npm --version   # Should be 9.x.x or higher
```

### **Package Manager Setup**
```bash
# Install yarn (optional, alternative to npm)
npm install -g yarn

# Install pnpm (optional, faster alternative)
npm install -g pnpm

# Verify installations
yarn --version
pnpm --version
```

### **Frontend Dependencies Installation**
```bash
# Navigate to frontend directory
cd frontend

# Install dependencies using npm
npm install

# Or using yarn
yarn install

# Or using pnpm
pnpm install
```

### **Frontend Environment Configuration**
```env
# .env.development
VITE_API_BASE_URL=http://localhost:8080/api
VITE_WEBSOCKET_URL=ws://localhost:8080/ws
VITE_APP_NAME=ZbInnovation Platform
VITE_APP_VERSION=1.0.0
VITE_ENVIRONMENT=development

# API Keys (development)
VITE_GOOGLE_MAPS_API_KEY=your_google_maps_key
VITE_ANALYTICS_ID=your_analytics_id
```

## 🐳 **Docker Development Environment**

### **Docker Installation**
```bash
# Windows: Download Docker Desktop from docker.com
# macOS: Download Docker Desktop from docker.com
# Linux (Ubuntu):
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker-compose --version
```

### **Docker Development Setup**
```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: zbinnovation_dev
      POSTGRES_USER: zbinnovation_user
      POSTGRES_PASSWORD: dev_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

volumes:
  postgres_data:
  redis_data:
  elasticsearch_data:
```

```bash
# Start development services
docker-compose -f docker-compose.dev.yml up -d

# Stop development services
docker-compose -f docker-compose.dev.yml down
```

## 🔧 **Development Tools Configuration**

### **IntelliJ IDEA Setup**
1. **Install Required Plugins**:
   - Spring Boot
   - Lombok
   - Database Navigator
   - GitToolBox
   - SonarLint

2. **Project Configuration**:
   - Set Project SDK to Java 17
   - Configure Maven settings
   - Set up code style and formatting
   - Configure database connections

### **VS Code Setup**
```json
// .vscode/settings.json
{
  "java.home": "/path/to/java17",
  "java.configuration.runtimes": [
    {
      "name": "JavaSE-17",
      "path": "/path/to/java17"
    }
  ],
  "spring-boot.ls.java.home": "/path/to/java17",
  "typescript.preferences.importModuleSpecifier": "relative",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```

### **Git Hooks Setup**
```bash
# Install pre-commit hooks
npm install -g @commitlint/cli @commitlint/config-conventional
npm install -g husky

# Initialize husky
npx husky install

# Add pre-commit hook
npx husky add .husky/pre-commit "npm run lint && npm run test"

# Add commit message hook
npx husky add .husky/commit-msg "npx commitlint --edit $1"
```

## 🧪 **Testing Environment Setup**

### **Backend Testing**
```xml
<!-- pom.xml testing dependencies -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <scope>test</scope>
</dependency>
```

### **Frontend Testing**
```json
// package.json testing dependencies
{
  "devDependencies": {
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/user-event": "^14.4.3",
    "jest": "^29.5.0",
    "jest-environment-jsdom": "^29.5.0"
  }
}
```

## 🚀 **Development Workflow**

### **Daily Development Routine**
```bash
# 1. Start development services
docker-compose -f docker-compose.dev.yml up -d

# 2. Start backend application
cd backend
mvn spring-boot:run

# 3. Start frontend development server
cd frontend
npm run dev

# 4. Access application
# Frontend: http://localhost:5173
# Backend API: http://localhost:8080
# Database: localhost:5432
```

### **Code Quality Checks**
```bash
# Backend code quality
mvn clean compile
mvn test
mvn checkstyle:check

# Frontend code quality
npm run lint
npm run type-check
npm run test
npm run build
```

## 📊 **Development Monitoring**

### **Local Monitoring Setup**
- **Application Logs**: Console output and log files
- **Database Monitoring**: pgAdmin or DBeaver
- **Redis Monitoring**: Redis CLI or RedisInsight
- **API Testing**: Postman or Thunder Client

### **Performance Monitoring**
- **Frontend**: Browser DevTools, Lighthouse
- **Backend**: Spring Boot Actuator endpoints
- **Database**: Query performance analysis
- **Network**: Browser Network tab, API response times

---

## ✅ **Environment Verification Checklist**

### **Backend Verification**
- [ ] Java 17 installed and configured
- [ ] Maven 3.9+ installed
- [ ] PostgreSQL running and accessible
- [ ] Redis running and accessible
- [ ] Spring Boot application starts successfully
- [ ] API endpoints respond correctly

### **Frontend Verification**
- [ ] Node.js 18+ installed
- [ ] npm/yarn/pnpm working correctly
- [ ] Dependencies installed successfully
- [ ] Development server starts
- [ ] Application loads in browser
- [ ] Hot reload working

### **Integration Verification**
- [ ] Frontend can connect to backend APIs
- [ ] Database connections working
- [ ] File upload functionality working
- [ ] WebSocket connections established
- [ ] Authentication flow working

**This development environment setup ensures consistent, efficient development across the team.** 🛠️
