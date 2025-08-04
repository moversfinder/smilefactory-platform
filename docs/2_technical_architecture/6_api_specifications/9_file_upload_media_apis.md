# 9. File Upload & Media Management APIs

## 📁 **File Upload & Media Overview**

This document specifies comprehensive file upload and media management APIs supporting images, videos, documents, and other media types with processing, optimization, and secure access controls for the ZbInnovation platform.

## 📋 **Supported File Types**

### **Image Files**
- **Formats**: JPEG, PNG, GIF, WebP, SVG
- **Max Size**: 10MB per file
- **Processing**: Automatic resizing, thumbnail generation, format optimization

### **Video Files**
- **Formats**: MP4, WebM, MOV, AVI
- **Max Size**: 100MB per file
- **Processing**: Thumbnail extraction, format conversion, compression

### **Document Files**
- **Formats**: PDF, DOC, DOCX, PPT, PPTX, XLS, XLSX
- **Max Size**: 25MB per file
- **Processing**: Thumbnail generation, metadata extraction

### **Audio Files**
- **Formats**: MP3, WAV, OGG
- **Max Size**: 50MB per file
- **Processing**: Waveform generation, metadata extraction

## 📤 **File Upload APIs**

### **POST /api/v1/media/upload**
**Upload single file**

```typescript
interface FileUploadRequest {
  file: File; // Binary file data
  context: 'profile_avatar' | 'post_media' | 'event_image' | 'group_avatar' | 'listing_image' | 'document' | 'message_attachment';
  description?: string;
  tags?: string[];
  folder?: string;
  isPublic?: boolean;
}

interface FileUploadResponse {
  success: boolean;
  file: {
    id: string;
    filename: string;
    originalName: string;
    mimeType: string;
    size: number;
    url: string;
    thumbnailUrl?: string;
    context: string;
    folder?: string;
    isPublic: boolean;
    metadata: {
      width?: number;
      height?: number;
      duration?: number;
      pages?: number;
      format?: string;
    };
    processing: {
      status: 'pending' | 'processing' | 'completed' | 'failed';
      progress?: number;
      variants?: FileVariant[];
    };
    uploadedBy: string;
    uploadedAt: string;
    expiresAt?: string;
  };
}

interface FileVariant {
  type: 'thumbnail' | 'small' | 'medium' | 'large' | 'compressed';
  url: string;
  width?: number;
  height?: number;
  size: number;
}
```

**Request Example (multipart/form-data)**:
```
POST /api/v1/media/upload
Content-Type: multipart/form-data
Authorization: Bearer jwt-token

file: [binary file data]
context: "profile_avatar"
description: "User profile picture"
tags: "profile,avatar,user"
isPublic: true
```

### **POST /api/v1/media/upload/multiple**
**Upload multiple files**

```typescript
interface MultipleFileUploadRequest {
  files: File[];
  context: string;
  folder?: string;
  isPublic?: boolean;
  descriptions?: string[];
  tags?: string[][];
}

interface MultipleFileUploadResponse {
  success: boolean;
  files: FileUploadResponse['file'][];
  summary: {
    total: number;
    successful: number;
    failed: number;
    totalSize: number;
  };
  errors?: {
    filename: string;
    error: string;
  }[];
}
```

### **POST /api/v1/media/upload/url**
**Upload file from URL**

```typescript
interface URLUploadRequest {
  url: string;
  context: string;
  filename?: string;
  description?: string;
  tags?: string[];
  folder?: string;
  isPublic?: boolean;
}

interface URLUploadResponse {
  success: boolean;
  file: FileUploadResponse['file'];
  downloadInfo: {
    originalUrl: string;
    downloadedAt: string;
    downloadSize: number;
  };
}
```

## 📁 **File Management APIs**

### **GET /api/v1/media/files**
**List user files**

```typescript
interface ListFilesRequest {
  context?: string;
  folder?: string;
  mimeType?: string;
  tags?: string[];
  dateRange?: {
    start: string;
    end: string;
  };
  page?: number;
  limit?: number;
  sortBy?: 'name' | 'size' | 'uploadedAt' | 'type';
  sortOrder?: 'asc' | 'desc';
}

interface ListFilesResponse {
  success: boolean;
  files: FileInfo[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  summary: {
    totalFiles: number;
    totalSize: number;
    byType: Record<string, number>;
    byContext: Record<string, number>;
  };
}

interface FileInfo {
  id: string;
  filename: string;
  originalName: string;
  mimeType: string;
  size: number;
  url: string;
  thumbnailUrl?: string;
  context: string;
  folder?: string;
  isPublic: boolean;
  tags: string[];
  description?: string;
  metadata: Record<string, any>;
  processing: {
    status: string;
    variants: FileVariant[];
  };
  uploadedAt: string;
  lastAccessedAt?: string;
  accessCount: number;
}
```

### **GET /api/v1/media/files/{fileId}**
**Get file details**

```typescript
interface FileDetailsResponse {
  success: boolean;
  file: FileInfo & {
    downloadUrl: string;
    shareUrl?: string;
    analytics: {
      views: number;
      downloads: number;
      lastAccessed?: string;
      accessHistory: {
        date: string;
        count: number;
      }[];
    };
    permissions: {
      canEdit: boolean;
      canDelete: boolean;
      canShare: boolean;
      canDownload: boolean;
    };
  };
}
```

### **PUT /api/v1/media/files/{fileId}**
**Update file metadata**

```typescript
interface UpdateFileRequest {
  filename?: string;
  description?: string;
  tags?: string[];
  folder?: string;
  isPublic?: boolean;
}

interface UpdateFileResponse {
  success: boolean;
  file: FileInfo;
  message: string;
}
```

### **DELETE /api/v1/media/files/{fileId}**
**Delete file**

```typescript
interface DeleteFileResponse {
  success: boolean;
  message: string;
  deletedAt: string;
  recoverable: boolean;
  recoveryExpiresAt?: string;
}
```

### **POST /api/v1/media/files/{fileId}/copy**
**Copy file**

```typescript
interface CopyFileRequest {
  newFilename?: string;
  folder?: string;
  context?: string;
}

interface CopyFileResponse {
  success: boolean;
  originalFile: { id: string; filename: string };
  copiedFile: FileInfo;
}
```

## 🔄 **File Processing APIs**

### **GET /api/v1/media/files/{fileId}/processing**
**Get file processing status**

```typescript
interface ProcessingStatusResponse {
  success: boolean;
  processing: {
    status: 'pending' | 'processing' | 'completed' | 'failed';
    progress: number;
    startedAt?: string;
    completedAt?: string;
    error?: string;
    variants: FileVariant[];
    operations: {
      operation: string;
      status: string;
      progress: number;
      error?: string;
    }[];
  };
}
```

### **POST /api/v1/media/files/{fileId}/reprocess**
**Reprocess file**

```typescript
interface ReprocessFileRequest {
  operations?: ('thumbnail' | 'resize' | 'compress' | 'convert')[];
  options?: {
    thumbnailSize?: { width: number; height: number };
    resizeDimensions?: { width: number; height: number }[];
    compressionQuality?: number;
    outputFormat?: string;
  };
}

interface ReprocessFileResponse {
  success: boolean;
  processing: {
    jobId: string;
    status: string;
    estimatedDuration: number;
  };
}
```

## 🔗 **File Sharing APIs**

### **POST /api/v1/media/files/{fileId}/share**
**Create file share link**

```typescript
interface CreateShareLinkRequest {
  expiresAt?: string;
  password?: string;
  allowDownload?: boolean;
  allowPreview?: boolean;
  maxAccess?: number;
}

interface CreateShareLinkResponse {
  success: boolean;
  shareLink: {
    id: string;
    url: string;
    shortUrl: string;
    expiresAt?: string;
    hasPassword: boolean;
    allowDownload: boolean;
    allowPreview: boolean;
    maxAccess?: number;
    accessCount: number;
    createdAt: string;
  };
}
```

### **GET /api/v1/media/files/{fileId}/shares**
**List file share links**

```typescript
interface FileSharesResponse {
  success: boolean;
  shares: {
    id: string;
    url: string;
    shortUrl: string;
    expiresAt?: string;
    hasPassword: boolean;
    allowDownload: boolean;
    allowPreview: boolean;
    maxAccess?: number;
    accessCount: number;
    isActive: boolean;
    createdAt: string;
  }[];
}
```

### **DELETE /api/v1/media/shares/{shareId}**
**Revoke share link**

```typescript
interface RevokeShareLinkResponse {
  success: boolean;
  message: string;
  revokedAt: string;
}
```

## 📊 **Media Analytics APIs**

### **GET /api/v1/media/analytics**
**Get media usage analytics**

```typescript
interface MediaAnalyticsRequest {
  timeRange: '7d' | '30d' | '90d' | '1y';
  groupBy?: 'day' | 'week' | 'month';
  context?: string;
}

interface MediaAnalyticsResponse {
  success: boolean;
  analytics: {
    overview: {
      totalFiles: number;
      totalSize: number;
      totalViews: number;
      totalDownloads: number;
      storageUsed: number;
      storageLimit: number;
    };
    usage: {
      uploads: DataPoint[];
      views: DataPoint[];
      downloads: DataPoint[];
      storage: DataPoint[];
    };
    breakdown: {
      byType: { type: string; count: number; size: number }[];
      byContext: { context: string; count: number; size: number }[];
      topFiles: {
        id: string;
        filename: string;
        views: number;
        downloads: number;
        size: number;
      }[];
    };
  };
}

interface DataPoint {
  date: string;
  value: number;
}
```

## 🗂️ **Folder Management APIs**

### **POST /api/v1/media/folders**
**Create folder**

```typescript
interface CreateFolderRequest {
  name: string;
  parentFolder?: string;
  description?: string;
  isPublic?: boolean;
}

interface CreateFolderResponse {
  success: boolean;
  folder: {
    id: string;
    name: string;
    path: string;
    parentFolder?: string;
    description?: string;
    isPublic: boolean;
    fileCount: number;
    totalSize: number;
    createdAt: string;
  };
}
```

### **GET /api/v1/media/folders**
**List folders**

```typescript
interface ListFoldersResponse {
  success: boolean;
  folders: {
    id: string;
    name: string;
    path: string;
    parentFolder?: string;
    description?: string;
    isPublic: boolean;
    fileCount: number;
    totalSize: number;
    createdAt: string;
    updatedAt: string;
  }[];
  tree: FolderNode[];
}

interface FolderNode {
  id: string;
  name: string;
  path: string;
  children: FolderNode[];
  fileCount: number;
  totalSize: number;
}
```

---

## 📚 **Reference Documents**

**Content Management**: See `/2_technical_architecture/api_specifications/3_content_management_apis.md`
**User Management**: See `/2_technical_architecture/api_specifications/2_profile_management_apis.md`
**Security Design**: See `/2_technical_architecture/4_security_and_authentication_design.md`
**Storage Implementation**: See `/4_backend_implementation/3_file_storage_implementation.md`

*These file upload and media management APIs provide comprehensive functionality for secure file handling, processing, sharing, and analytics on the ZbInnovation platform.*
