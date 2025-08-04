# 1. System Integration

## 🔗 **System Integration Overview**

This document outlines the comprehensive system integration strategy for the ZbInnovation platform, including frontend-backend integration, API integration patterns, real-time features integration, and third-party service integration.

## 🏗️ **Integration Architecture**

### **System Integration Layers**
```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                           │
│  React Components, State Management, UI Logic              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  API Gateway Layer                         │
│     Authentication, Rate Limiting, Request Routing        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Backend Services                         │
│   Spring Boot APIs, Business Logic, Data Processing        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Data Layer                               │
│    PostgreSQL, Redis, File Storage, Search Engine         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                External Services                           │
│   Email, SMS, AI Services, Payment, Analytics             │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 **Frontend-Backend Integration**

### **API Client Configuration**
```typescript
// src/services/apiClient.ts
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { store } from '../store/store';
import { logout } from '../store/slices/authSlice';

class ApiClient {
  private client: AxiosInstance;
  private refreshPromise: Promise<string> | null = null;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.REACT_APP_API_BASE_URL || 'http://localhost:8080/api/v1',
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor for auth token
    this.client.interceptors.request.use(
      (config) => {
        const state = store.getState();
        const token = state.auth.token;
        
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor for token refresh
    this.client.interceptors.response.use(
      (response) => response,
      async (error) => {
        const originalRequest = error.config;
        
        if (error.response?.status === 401 && !originalRequest._retry) {
          originalRequest._retry = true;
          
          try {
            const newToken = await this.refreshToken();
            originalRequest.headers.Authorization = `Bearer ${newToken}`;
            return this.client(originalRequest);
          } catch (refreshError) {
            store.dispatch(logout());
            window.location.href = '/login';
            return Promise.reject(refreshError);
          }
        }
        
        return Promise.reject(error);
      }
    );
  }

  private async refreshToken(): Promise<string> {
    if (this.refreshPromise) {
      return this.refreshPromise;
    }

    this.refreshPromise = this.performTokenRefresh();
    
    try {
      const token = await this.refreshPromise;
      return token;
    } finally {
      this.refreshPromise = null;
    }
  }

  private async performTokenRefresh(): Promise<string> {
    const state = store.getState();
    const refreshToken = state.auth.refreshToken;
    
    if (!refreshToken) {
      throw new Error('No refresh token available');
    }

    const response = await axios.post('/api/v1/auth/refresh', {
      refreshToken,
    });

    const { token } = response.data;
    
    // Update token in store
    store.dispatch({ type: 'auth/updateToken', payload: token });
    
    return token;
  }

  // HTTP Methods
  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.client.get(url, config);
    return response.data;
  }

  async post<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.client.post(url, data, config);
    return response.data;
  }

  async put<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.client.put(url, data, config);
    return response.data;
  }

  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.client.delete(url, config);
    return response.data;
  }

  // File upload with progress
  async uploadFile<T>(
    url: string,
    file: File,
    onProgress?: (progress: number) => void
  ): Promise<T> {
    const formData = new FormData();
    formData.append('file', file);

    const response: AxiosResponse<T> = await this.client.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      onUploadProgress: (progressEvent) => {
        if (onProgress && progressEvent.total) {
          const progress = (progressEvent.loaded / progressEvent.total) * 100;
          onProgress(Math.round(progress));
        }
      },
    });

    return response.data;
  }
}

export const apiClient = new ApiClient();
```

### **Error Handling Integration**
```typescript
// src/services/errorHandler.ts
import { AxiosError } from 'axios';
import { toast } from 'react-toastify';

export interface ApiError {
  message: string;
  code?: string;
  field?: string;
  details?: Record<string, any>;
}

export class ErrorHandler {
  static handle(error: unknown): ApiError {
    if (error instanceof AxiosError) {
      return this.handleAxiosError(error);
    }
    
    if (error instanceof Error) {
      return {
        message: error.message,
      };
    }
    
    return {
      message: 'An unexpected error occurred',
    };
  }

  private static handleAxiosError(error: AxiosError): ApiError {
    const response = error.response;
    
    if (!response) {
      return {
        message: 'Network error. Please check your connection.',
        code: 'NETWORK_ERROR',
      };
    }

    const { status, data } = response;
    
    switch (status) {
      case 400:
        return this.handleValidationError(data);
      case 401:
        return {
          message: 'Authentication required. Please log in.',
          code: 'UNAUTHORIZED',
        };
      case 403:
        return {
          message: 'You do not have permission to perform this action.',
          code: 'FORBIDDEN',
        };
      case 404:
        return {
          message: 'The requested resource was not found.',
          code: 'NOT_FOUND',
        };
      case 429:
        return {
          message: 'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
        };
      case 500:
        return {
          message: 'Server error. Please try again later.',
          code: 'SERVER_ERROR',
        };
      default:
        return {
          message: data?.message || 'An error occurred',
          code: data?.code,
          details: data,
        };
    }
  }

  private static handleValidationError(data: any): ApiError {
    if (data?.errors && typeof data.errors === 'object') {
      const firstError = Object.values(data.errors)[0] as string;
      return {
        message: firstError,
        code: 'VALIDATION_ERROR',
        details: data.errors,
      };
    }
    
    return {
      message: data?.message || 'Validation failed',
      code: 'VALIDATION_ERROR',
    };
  }

  static showToast(error: ApiError) {
    toast.error(error.message, {
      position: 'top-right',
      autoClose: 5000,
      hideProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
    });
  }
}
```

## 🔄 **Real-time Integration**

### **WebSocket Service**
```typescript
// src/services/websocketService.ts
import { store } from '../store/store';
import { addNotification } from '../store/slices/notificationSlice';

export enum WebSocketEventType {
  NEW_MESSAGE = 'NEW_MESSAGE',
  POST_LIKED = 'POST_LIKED',
  NEW_CONNECTION = 'NEW_CONNECTION',
  PROFILE_VIEWED = 'PROFILE_VIEWED',
  SYSTEM_NOTIFICATION = 'SYSTEM_NOTIFICATION',
}

interface WebSocketMessage {
  type: WebSocketEventType;
  payload: any;
  timestamp: string;
}

class WebSocketService {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectInterval = 1000;
  private heartbeatInterval: NodeJS.Timeout | null = null;

  connect(token: string) {
    const wsUrl = `${process.env.REACT_APP_WS_URL || 'ws://localhost:8080'}/ws?token=${token}`;
    
    try {
      this.ws = new WebSocket(wsUrl);
      this.setupEventListeners();
      this.startHeartbeat();
    } catch (error) {
      console.error('WebSocket connection failed:', error);
      this.scheduleReconnect();
    }
  }

  private setupEventListeners() {
    if (!this.ws) return;

    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectAttempts = 0;
    };

    this.ws.onmessage = (event) => {
      try {
        const message: WebSocketMessage = JSON.parse(event.data);
        this.handleMessage(message);
      } catch (error) {
        console.error('Failed to parse WebSocket message:', error);
      }
    };

    this.ws.onclose = (event) => {
      console.log('WebSocket disconnected:', event.code, event.reason);
      this.stopHeartbeat();
      
      if (event.code !== 1000) { // Not a normal closure
        this.scheduleReconnect();
      }
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }

  private handleMessage(message: WebSocketMessage) {
    const { type, payload } = message;

    switch (type) {
      case WebSocketEventType.NEW_MESSAGE:
        this.handleNewMessage(payload);
        break;
      case WebSocketEventType.POST_LIKED:
        this.handlePostLiked(payload);
        break;
      case WebSocketEventType.NEW_CONNECTION:
        this.handleNewConnection(payload);
        break;
      case WebSocketEventType.PROFILE_VIEWED:
        this.handleProfileViewed(payload);
        break;
      case WebSocketEventType.SYSTEM_NOTIFICATION:
        this.handleSystemNotification(payload);
        break;
      default:
        console.warn('Unknown WebSocket message type:', type);
    }
  }

  private handleNewMessage(payload: any) {
    store.dispatch(addNotification({
      id: Date.now().toString(),
      type: 'message',
      title: 'New Message',
      message: `You have a new message from ${payload.senderName}`,
      timestamp: new Date().toISOString(),
      read: false,
    }));
  }

  private handlePostLiked(payload: any) {
    // Update post like count in store
    // This would integrate with your content management state
  }

  private handleNewConnection(payload: any) {
    store.dispatch(addNotification({
      id: Date.now().toString(),
      type: 'connection',
      title: 'New Connection',
      message: `${payload.requesterName} wants to connect with you`,
      timestamp: new Date().toISOString(),
      read: false,
    }));
  }

  private handleProfileViewed(payload: any) {
    // Handle profile view analytics
  }

  private handleSystemNotification(payload: any) {
    store.dispatch(addNotification({
      id: Date.now().toString(),
      type: 'system',
      title: payload.title,
      message: payload.message,
      timestamp: new Date().toISOString(),
      read: false,
    }));
  }

  private startHeartbeat() {
    this.heartbeatInterval = setInterval(() => {
      if (this.ws?.readyState === WebSocket.OPEN) {
        this.ws.send(JSON.stringify({ type: 'PING' }));
      }
    }, 30000); // Send ping every 30 seconds
  }

  private stopHeartbeat() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }
  }

  private scheduleReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('Max reconnection attempts reached');
      return;
    }

    setTimeout(() => {
      this.reconnectAttempts++;
      const state = store.getState();
      const token = state.auth.token;
      
      if (token) {
        this.connect(token);
      }
    }, this.reconnectInterval * Math.pow(2, this.reconnectAttempts));
  }

  send(message: any) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    } else {
      console.warn('WebSocket is not connected');
    }
  }

  disconnect() {
    this.stopHeartbeat();
    if (this.ws) {
      this.ws.close(1000, 'Client disconnect');
      this.ws = null;
    }
  }
}

export const websocketService = new WebSocketService();
```

## 🔌 **Third-Party Service Integration**

### **Email Service Integration**
```java
// Backend: EmailService.java
@Service
@Slf4j
public class EmailService {
    
    @Autowired
    private JavaMailSender mailSender;
    
    @Value("${app.mail.from}")
    private String fromEmail;
    
    @Async
    public CompletableFuture<Void> sendWelcomeEmail(String toEmail, String firstName) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("Welcome to ZbInnovation Platform!");
            
            String htmlContent = buildWelcomeEmailTemplate(firstName);
            helper.setText(htmlContent, true);
            
            mailSender.send(message);
            log.info("Welcome email sent successfully to: {}", toEmail);
            
        } catch (Exception e) {
            log.error("Failed to send welcome email to: {}", toEmail, e);
            throw new EmailSendException("Failed to send welcome email", e);
        }
        
        return CompletableFuture.completedFuture(null);
    }
    
    @Async
    public CompletableFuture<Void> sendNotificationEmail(String toEmail, String subject, String content) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject(subject);
            message.setText(content);
            
            mailSender.send(message);
            log.info("Notification email sent successfully to: {}", toEmail);
            
        } catch (Exception e) {
            log.error("Failed to send notification email to: {}", toEmail, e);
            throw new EmailSendException("Failed to send notification email", e);
        }
        
        return CompletableFuture.completedFuture(null);
    }
    
    private String buildWelcomeEmailTemplate(String firstName) {
        return """
            <html>
            <body>
                <h2>Welcome to ZbInnovation Platform, %s!</h2>
                <p>Thank you for joining Zimbabwe's premier innovation ecosystem.</p>
                <p>Get started by completing your profile and connecting with other innovators.</p>
                <a href="%s/dashboard" style="background-color: #1976d2; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
                    Complete Your Profile
                </a>
            </body>
            </html>
            """.formatted(firstName, getBaseUrl());
    }
    
    private String getBaseUrl() {
        return "https://zbinnovation.com"; // Configure based on environment
    }
}
```

### **File Storage Integration**
```java
// Backend: FileStorageService.java
@Service
@Slf4j
public class FileStorageService {
    
    @Value("${app.file.upload-dir}")
    private String uploadDir;
    
    @Value("${app.file.max-size}")
    private long maxFileSize;
    
    private final Set<String> allowedExtensions = Set.of(
        "jpg", "jpeg", "png", "gif", "pdf", "doc", "docx"
    );
    
    public FileUploadResponse uploadFile(MultipartFile file, String userId) {
        validateFile(file);
        
        try {
            String fileName = generateUniqueFileName(file.getOriginalFilename());
            String filePath = Paths.get(uploadDir, userId, fileName).toString();
            
            // Create directory if it doesn't exist
            Files.createDirectories(Paths.get(uploadDir, userId));
            
            // Save file
            file.transferTo(new File(filePath));
            
            // Generate public URL
            String publicUrl = generatePublicUrl(userId, fileName);
            
            // Save file metadata to database
            FileMetadata metadata = FileMetadata.builder()
                .fileName(fileName)
                .originalFileName(file.getOriginalFilename())
                .filePath(filePath)
                .publicUrl(publicUrl)
                .fileSize(file.getSize())
                .contentType(file.getContentType())
                .uploadedBy(userId)
                .build();
            
            fileMetadataRepository.save(metadata);
            
            log.info("File uploaded successfully: {} for user: {}", fileName, userId);
            
            return FileUploadResponse.builder()
                .fileId(metadata.getId())
                .fileName(fileName)
                .publicUrl(publicUrl)
                .fileSize(file.getSize())
                .build();
                
        } catch (Exception e) {
            log.error("Failed to upload file for user: {}", userId, e);
            throw new FileUploadException("Failed to upload file", e);
        }
    }
    
    private void validateFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new InvalidFileException("File is empty");
        }
        
        if (file.getSize() > maxFileSize) {
            throw new InvalidFileException("File size exceeds maximum allowed size");
        }
        
        String extension = getFileExtension(file.getOriginalFilename());
        if (!allowedExtensions.contains(extension.toLowerCase())) {
            throw new InvalidFileException("File type not allowed");
        }
    }
    
    private String generateUniqueFileName(String originalFileName) {
        String extension = getFileExtension(originalFileName);
        return UUID.randomUUID().toString() + "." + extension;
    }
    
    private String getFileExtension(String fileName) {
        return fileName.substring(fileName.lastIndexOf(".") + 1);
    }
    
    private String generatePublicUrl(String userId, String fileName) {
        return String.format("/api/v1/files/%s/%s", userId, fileName);
    }
}
```

## 📊 **Integration Testing Strategy**

### **Integration Test Configuration**
```java
// Backend: IntegrationTestConfig.java
@TestConfiguration
@Profile("integration-test")
public class IntegrationTestConfig {
    
    @Bean
    @Primary
    public DataSource testDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE");
        config.setUsername("sa");
        config.setPassword("");
        config.setDriverClassName("org.h2.Driver");
        return new HikariDataSource(config);
    }
    
    @Bean
    @Primary
    public JavaMailSender mockMailSender() {
        return Mockito.mock(JavaMailSender.class);
    }
    
    @Bean
    @Primary
    public RedisTemplate<String, Object> mockRedisTemplate() {
        return Mockito.mock(RedisTemplate.class);
    }
}
```

### **End-to-End Integration Test**
```java
// Backend: SystemIntegrationTest.java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("integration-test")
@Transactional
class SystemIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private PersonalDetailsRepository userRepository;
    
    @Test
    @DisplayName("Complete user registration and profile creation flow")
    void shouldCompleteUserRegistrationFlow() {
        // 1. Register user
        CreateUserRequest registerRequest = CreateUserRequest.builder()
            .email("integration@test.com")
            .password("SecurePass123!")
            .firstName("Integration")
            .lastName("Test")
            .profileType(ProfileType.INNOVATOR)
            .agreeToTerms(true)
            .build();
        
        ResponseEntity<ApiResponse> registerResponse = restTemplate.postForEntity(
            "/api/v1/auth/register", registerRequest, ApiResponse.class);
        
        assertThat(registerResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        
        // Extract token from response
        Map<String, Object> data = (Map<String, Object>) registerResponse.getBody().getData();
        String token = (String) data.get("token");
        
        // 2. Update profile with token
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        
        UpdateProfileRequest profileRequest = UpdateProfileRequest.builder()
            .bio("Integration test bio")
            .build();
        
        HttpEntity<UpdateProfileRequest> profileEntity = new HttpEntity<>(profileRequest, headers);
        
        ResponseEntity<ApiResponse> profileResponse = restTemplate.exchange(
            "/api/v1/profiles/me", HttpMethod.PUT, profileEntity, ApiResponse.class);
        
        assertThat(profileResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        
        // 3. Verify user exists in database
        Optional<PersonalDetails> user = userRepository.findByEmail("integration@test.com");
        assertThat(user).isPresent();
        assertThat(user.get().getBio()).isEqualTo("Integration test bio");
    }
}
```

---

## 📚 **Reference Documents**

**Backend Implementation**: See `/4_backend_implementation/`
**Frontend Implementation**: See `/5_frontend_implementation/`
**API Specifications**: See `/2_technical_architecture/api_specifications/`
**Security Design**: See `/2_technical_architecture/4_security_and_authentication_design.md`

*This system integration framework ensures seamless communication between all components of the ZbInnovation platform.*
