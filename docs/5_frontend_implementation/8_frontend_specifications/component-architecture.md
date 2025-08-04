# Frontend Component Architecture

## Overview

This document specifies the frontend architecture for the ZbInnovation platform. The architecture defines how the user interface components work together to create a seamless user experience across all platform features.

## Platform Components

### User Interface Foundation
The platform uses modern web technologies to create responsive, accessible interfaces that work seamlessly across desktop, tablet, and mobile devices.

### Core Interface Elements
- **Navigation**: Intuitive menu systems and page routing
- **Forms**: User-friendly input forms with validation
- **Data Display**: Tables, cards, and lists for information presentation
- **Interactive Elements**: Buttons, modals, and dropdown menus
- **Real-time Updates**: Live notifications and content updates
- **File Management**: Upload and download capabilities for documents and media

### User Experience Features
- **Responsive Design**: Adapts to different screen sizes and devices
- **Accessibility**: Supports users with disabilities and assistive technologies
- **Performance**: Fast loading times and smooth interactions
- **Visual Feedback**: Loading indicators and success/error messages
- **Search and Filtering**: Easy content discovery and organization

## Project Structure

```
src/
├── components/                 # Reusable UI components
│   ├── common/                # Generic components
│   │   ├── Button/
│   │   ├── Input/
│   │   ├── Modal/
│   │   ├── Card/
│   │   ├── Avatar/
│   │   ├── Badge/
│   │   ├── Spinner/
│   │   └── ErrorBoundary/
│   ├── forms/                 # Form-specific components
│   │   ├── AuthForms/
│   │   ├── ProfileForms/
│   │   ├── PostForms/
│   │   ├── CommentForm/
│   │   └── SearchForm/
│   ├── layout/                # Layout components
│   │   ├── Header/
│   │   ├── Sidebar/
│   │   ├── Footer/
│   │   ├── Navigation/
│   │   └── PageLayout/
│   ├── content/               # Content display components
│   │   ├── PostCard/
│   │   ├── ProfileCard/
│   │   ├── EventCard/
│   │   ├── CommentThread/
│   │   └── FeedList/
│   ├── social/                # Social interaction components
│   │   ├── ConnectionRequest/
│   │   ├── MessageThread/
│   │   ├── NotificationList/
│   │   ├── LikeButton/
│   │   └── ShareButton/
│   └── ai/                    # AI integration components
│       ├── AIChat/
│       ├── AITriggerButton/
│       ├── QuickReplies/
│       └── AIInsights/
├── pages/                     # Page components
│   ├── auth/
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   ├── ForgotPasswordPage.tsx
│   │   └── VerifyEmailPage.tsx
│   ├── dashboard/
│   │   ├── DashboardPage.tsx
│   │   ├── ProfileCompletionSection.tsx
│   │   ├── ActivityFeedSection.tsx
│   │   └── AnalyticsSection.tsx
│   ├── community/
│   │   ├── CommunityPage.tsx
│   │   ├── FeedTab.tsx
│   │   ├── ProfilesTab.tsx
│   │   ├── BlogTab.tsx
│   │   ├── EventsTab.tsx
│   │   ├── GroupsTab.tsx
│   │   └── MarketplaceTab.tsx
│   ├── profile/
│   │   ├── ProfilePage.tsx
│   │   ├── ProfileEditPage.tsx
│   │   ├── ProfileCreationPage.tsx
│   │   └── ProfileViewPage.tsx
│   ├── messaging/
│   │   ├── MessagesPage.tsx
│   │   ├── ConversationList.tsx
│   │   └── MessageThread.tsx
│   └── admin/
│       ├── AdminDashboard.tsx
│       ├── UserManagement.tsx
│       └── ContentModeration.tsx
├── store/                     # Redux store configuration
│   ├── index.ts              # Store configuration
│   ├── slices/               # Redux slices
│   │   ├── authSlice.ts
│   │   ├── userSlice.ts
│   │   ├── postsSlice.ts
│   │   ├── connectionsSlice.ts
│   │   ├── notificationsSlice.ts
│   │   └── aiSlice.ts
│   └── api/                  # RTK Query API slices
│       ├── authApi.ts
│       ├── postsApi.ts
│       ├── usersApi.ts
│       ├── connectionsApi.ts
│       └── aiApi.ts
├── hooks/                    # Custom React hooks
│   ├── useAuth.ts
│   ├── useLocalStorage.ts
│   ├── useDebounce.ts
│   ├── useInfiniteScroll.ts
│   ├── useWebSocket.ts
│   └── useAI.ts
├── utils/                    # Utility functions
│   ├── api.ts               # API configuration
│   ├── auth.ts              # Authentication helpers
│   ├── validation.ts        # Form validation schemas
│   ├── formatters.ts        # Data formatting utilities
│   ├── constants.ts         # Application constants
│   └── helpers.ts           # General helper functions
├── types/                   # TypeScript type definitions
│   ├── auth.ts
│   ├── user.ts
│   ├── post.ts
│   ├── connection.ts
│   ├── notification.ts
│   └── api.ts
├── styles/                  # Global styles and themes
│   ├── globals.css
│   ├── theme.ts
│   └── components.css
└── assets/                  # Static assets
    ├── images/
    ├── icons/
    └── fonts/
```

## Component Design Patterns

### 1. Compound Components Pattern

```tsx
// Example: Modal component with compound pattern
export const Modal = ({ children, isOpen, onClose }: ModalProps) => {
  if (!isOpen) return null;
  
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        {children}
      </div>
    </div>
  );
};

Modal.Header = ({ children }: { children: React.ReactNode }) => (
  <div className="modal-header">{children}</div>
);

Modal.Body = ({ children }: { children: React.ReactNode }) => (
  <div className="modal-body">{children}</div>
);

Modal.Footer = ({ children }: { children: React.ReactNode }) => (
  <div className="modal-footer">{children}</div>
);

// Usage
<Modal isOpen={isOpen} onClose={handleClose}>
  <Modal.Header>
    <h2>Create Post</h2>
  </Modal.Header>
  <Modal.Body>
    <PostForm onSubmit={handleSubmit} />
  </Modal.Body>
  <Modal.Footer>
    <Button onClick={handleClose}>Cancel</Button>
    <Button type="submit">Create</Button>
  </Modal.Footer>
</Modal>
```

### 2. Render Props Pattern for Data Fetching

```tsx
// Example: Data fetcher with render props
interface DataFetcherProps<T> {
  url: string;
  children: (data: {
    data: T | null;
    loading: boolean;
    error: string | null;
    refetch: () => void;
  }) => React.ReactNode;
}

export const DataFetcher = <T,>({ url, children }: DataFetcherProps<T>) => {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      const response = await api.get<T>(url);
      setData(response.data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  }, [url]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return <>{children({ data, loading, error, refetch: fetchData })}</>;
};

// Usage
<DataFetcher<Post[]> url="/api/posts">
  {({ data: posts, loading, error, refetch }) => {
    if (loading) return <Spinner />;
    if (error) return <ErrorMessage message={error} onRetry={refetch} />;
    return <PostList posts={posts || []} />;
  }}
</DataFetcher>
```

### 3. Custom Hooks for Business Logic

```tsx
// Example: useAuth hook
export const useAuth = () => {
  const dispatch = useAppDispatch();
  const { user, isAuthenticated, loading } = useAppSelector(state => state.auth);

  const login = useCallback(async (credentials: LoginCredentials) => {
    try {
      const response = await authApi.login(credentials);
      dispatch(setUser(response.user));
      dispatch(setTokens(response.tokens));
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }, [dispatch]);

  const logout = useCallback(() => {
    dispatch(clearAuth());
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  }, [dispatch]);

  const updateProfile = useCallback(async (profileData: Partial<User>) => {
    try {
      const response = await userApi.updateProfile(profileData);
      dispatch(updateUser(response.user));
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }, [dispatch]);

  return {
    user,
    isAuthenticated,
    loading,
    login,
    logout,
    updateProfile
  };
};
```

## State Management Architecture

### Redux Store Structure

```tsx
// store/index.ts
export const store = configureStore({
  reducer: {
    auth: authSlice.reducer,
    user: userSlice.reducer,
    posts: postsSlice.reducer,
    connections: connectionsSlice.reducer,
    notifications: notificationsSlice.reducer,
    ai: aiSlice.reducer,
    api: apiSlice.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: [FLUSH, REHYDRATE, PAUSE, PERSIST, PURGE, REGISTER],
      },
    }).concat(apiSlice.middleware),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

### RTK Query API Slice Example

```tsx
// store/api/postsApi.ts
export const postsApi = apiSlice.injectEndpoints({
  endpoints: (builder) => ({
    getPosts: builder.query<PostsResponse, PostsQuery>({
      query: (params) => ({
        url: '/posts/feed',
        params,
      }),
      providesTags: ['Post'],
    }),
    createPost: builder.mutation<Post, CreatePostRequest>({
      query: (postData) => ({
        url: '/posts',
        method: 'POST',
        body: postData,
      }),
      invalidatesTags: ['Post'],
    }),
    likePost: builder.mutation<LikeResponse, { postId: number }>({
      query: ({ postId }) => ({
        url: `/posts/${postId}/like`,
        method: 'POST',
      }),
      async onQueryStarted({ postId }, { dispatch, queryFulfilled }) {
        // Optimistic update
        const patchResult = dispatch(
          postsApi.util.updateQueryData('getPosts', undefined, (draft) => {
            const post = draft.posts.find(p => p.id === postId);
            if (post) {
              post.isLikedByUser = !post.isLikedByUser;
              post.likesCount += post.isLikedByUser ? 1 : -1;
            }
          })
        );
        
        try {
          await queryFulfilled;
        } catch {
          patchResult.undo();
        }
      },
    }),
  }),
});

export const { useGetPostsQuery, useCreatePostMutation, useLikePostMutation } = postsApi;
```

## Form Handling Architecture

### React Hook Form with Zod Validation

```tsx
// Example: Post creation form
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const postSchema = z.object({
  content: z.string().min(1, 'Content is required').max(2000, 'Content too long'),
  title: z.string().optional(),
  tags: z.array(z.string()).max(10, 'Maximum 10 tags allowed'),
  postType: z.enum(['general', 'blog', 'event']),
  mediaFiles: z.array(z.instanceof(File)).max(4, 'Maximum 4 files allowed'),
});

type PostFormData = z.infer<typeof postSchema>;

export const PostForm = ({ onSubmit }: { onSubmit: (data: PostFormData) => void }) => {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    watch,
    setValue,
  } = useForm<PostFormData>({
    resolver: zodResolver(postSchema),
    defaultValues: {
      postType: 'general',
      tags: [],
      mediaFiles: [],
    },
  });

  const postType = watch('postType');

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label htmlFor="postType">Post Type</label>
        <select {...register('postType')} id="postType">
          <option value="general">General Post</option>
          <option value="blog">Blog Article</option>
          <option value="event">Event</option>
        </select>
        {errors.postType && (
          <span className="error">{errors.postType.message}</span>
        )}
      </div>

      {postType === 'blog' && (
        <div>
          <label htmlFor="title">Title</label>
          <input {...register('title')} id="title" type="text" />
          {errors.title && (
            <span className="error">{errors.title.message}</span>
          )}
        </div>
      )}

      <div>
        <label htmlFor="content">Content</label>
        <textarea {...register('content')} id="content" rows={4} />
        {errors.content && (
          <span className="error">{errors.content.message}</span>
        )}
      </div>

      <TagInput
        value={watch('tags')}
        onChange={(tags) => setValue('tags', tags)}
        error={errors.tags?.message}
      />

      <FileUpload
        multiple
        accept="image/*,video/*"
        maxFiles={4}
        onFilesChange={(files) => setValue('mediaFiles', files)}
        error={errors.mediaFiles?.message}
      />

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  );
};
```

## Error Handling Strategy

### Error Boundary Component

```tsx
interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<
  { children: ReactNode; fallback?: ComponentType<{ error: Error }> },
  ErrorBoundaryState
> {
  constructor(props: any) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Send to error reporting service
  }

  render() {
    if (this.state.hasError) {
      const FallbackComponent = this.props.fallback || DefaultErrorFallback;
      return <FallbackComponent error={this.state.error!} />;
    }

    return this.props.children;
  }
}

const DefaultErrorFallback = ({ error }: { error: Error }) => (
  <div className="error-fallback">
    <h2>Something went wrong</h2>
    <p>{error.message}</p>
    <button onClick={() => window.location.reload()}>
      Reload page
    </button>
  </div>
);
```

## Performance Optimization Strategies

### 1. Code Splitting and Lazy Loading

```tsx
// Lazy load page components
const DashboardPage = lazy(() => import('../pages/dashboard/DashboardPage'));
const CommunityPage = lazy(() => import('../pages/community/CommunityPage'));
const ProfilePage = lazy(() => import('../pages/profile/ProfilePage'));

// Route configuration with suspense
<Routes>
  <Route path="/dashboard" element={
    <Suspense fallback={<PageSkeleton />}>
      <DashboardPage />
    </Suspense>
  } />
  <Route path="/community" element={
    <Suspense fallback={<PageSkeleton />}>
      <CommunityPage />
    </Suspense>
  } />
</Routes>
```

### 2. Memoization and Optimization

```tsx
// Memoized component for expensive renders
export const PostCard = memo(({ post, onLike, onComment }: PostCardProps) => {
  const handleLike = useCallback(() => {
    onLike(post.id);
  }, [post.id, onLike]);

  const handleComment = useCallback((content: string) => {
    onComment(post.id, content);
  }, [post.id, onComment]);

  return (
    <Card>
      <PostContent post={post} />
      <PostActions onLike={handleLike} onComment={handleComment} />
    </Card>
  );
});
```

### 3. Virtual Scrolling for Large Lists

```tsx
// Using react-window for large lists
import { FixedSizeList as List } from 'react-window';

const PostList = ({ posts }: { posts: Post[] }) => {
  const Row = ({ index, style }: { index: number; style: CSSProperties }) => (
    <div style={style}>
      <PostCard post={posts[index]} />
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

---

*This React component architecture provides a scalable, maintainable foundation for the ZbInnovation platform frontend migration from Vue.js to React.*
