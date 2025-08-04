# 4. State Management Implementation

## 🔄 **State Management Overview**

This document outlines the comprehensive state management implementation for the ZbInnovation platform using Redux Toolkit, RTK Query, and modern React patterns for efficient data flow and performance optimization.

## 🏗️ **Redux Toolkit Store Configuration**

### **Store Setup**
```typescript
// src/store/store.ts
import { configureStore } from '@reduxjs/toolkit';
import { setupListeners } from '@reduxjs/toolkit/query';
import { persistStore, persistReducer } from 'redux-persist';
import storage from 'redux-persist/lib/storage';

// Slice Imports
import authSlice from './slices/authSlice';
import profileSlice from './slices/profileSlice';
import communitySlice from './slices/communitySlice';
import notificationSlice from './slices/notificationSlice';

// API Imports
import { authApi } from './api/authApi';
import { profileApi } from './api/profileApi';
import { contentApi } from './api/contentApi';
import { communityApi } from './api/communityApi';

const persistConfig = {
  key: 'root',
  storage,
  whitelist: ['auth', 'profile'], // Only persist auth and profile
};

const rootReducer = {
  auth: persistReducer(persistConfig, authSlice),
  profile: profileSlice,
  community: communitySlice,
  notifications: notificationSlice,
  
  // RTK Query APIs
  [authApi.reducerPath]: authApi.reducer,
  [profileApi.reducerPath]: profileApi.reducer,
  [contentApi.reducerPath]: contentApi.reducer,
  [communityApi.reducerPath]: communityApi.reducer,
};

export const store = configureStore({
  reducer: rootReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['persist/PERSIST', 'persist/REHYDRATE'],
      },
    })
      .concat(authApi.middleware)
      .concat(profileApi.middleware)
      .concat(contentApi.middleware)
      .concat(communityApi.middleware),
  devTools: process.env.NODE_ENV !== 'production',
});

export const persistor = persistStore(store);

setupListeners(store.dispatch);

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

### **Typed Hooks**
```typescript
// src/store/hooks.ts
import { useDispatch, useSelector, TypedUseSelectorHook } from 'react-redux';
import type { RootState, AppDispatch } from './store';

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

## 🔐 **Authentication State Management**

### **Auth Slice**
```typescript
// src/store/slices/authSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { User } from '../../types/user.types';

interface AuthState {
  user: User | null;
  token: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  user: null,
  token: null,
  refreshToken: null,
  isAuthenticated: false,
  loading: false,
  error: null,
};

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    loginStart: (state) => {
      state.loading = true;
      state.error = null;
    },
    loginSuccess: (state, action: PayloadAction<{
      user: User;
      token: string;
      refreshToken: string;
    }>) => {
      state.user = action.payload.user;
      state.token = action.payload.token;
      state.refreshToken = action.payload.refreshToken;
      state.isAuthenticated = true;
      state.loading = false;
      state.error = null;
    },
    loginFailure: (state, action: PayloadAction<string>) => {
      state.loading = false;
      state.error = action.payload;
      state.isAuthenticated = false;
    },
    logout: (state) => {
      state.user = null;
      state.token = null;
      state.refreshToken = null;
      state.isAuthenticated = false;
      state.loading = false;
      state.error = null;
    },
    updateUser: (state, action: PayloadAction<Partial<User>>) => {
      if (state.user) {
        state.user = { ...state.user, ...action.payload };
      }
    },
    clearError: (state) => {
      state.error = null;
    },
  },
});

export const {
  loginStart,
  loginSuccess,
  loginFailure,
  logout,
  updateUser,
  clearError,
} = authSlice.actions;

export default authSlice.reducer;
```

### **Auth API with RTK Query**
```typescript
// src/store/api/authApi.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { RootState } from '../store';
import { loginSuccess, logout } from '../slices/authSlice';

interface LoginRequest {
  email: string;
  password: string;
}

interface RegisterRequest {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  profileType: string;
  agreeToTerms: boolean;
}

interface AuthResponse {
  user: User;
  token: string;
  refreshToken: string;
}

export const authApi = createApi({
  reducerPath: 'authApi',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api/v1/auth',
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token;
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  tagTypes: ['Auth'],
  endpoints: (builder) => ({
    login: builder.mutation<AuthResponse, LoginRequest>({
      query: (credentials) => ({
        url: '/login',
        method: 'POST',
        body: credentials,
      }),
      async onQueryStarted(arg, { dispatch, queryFulfilled }) {
        try {
          const { data } = await queryFulfilled;
          dispatch(loginSuccess(data));
        } catch (error) {
          // Handle error in component
        }
      },
    }),
    
    register: builder.mutation<AuthResponse, RegisterRequest>({
      query: (userData) => ({
        url: '/register',
        method: 'POST',
        body: userData,
      }),
      async onQueryStarted(arg, { dispatch, queryFulfilled }) {
        try {
          const { data } = await queryFulfilled;
          dispatch(loginSuccess(data));
        } catch (error) {
          // Handle error in component
        }
      },
    }),
    
    refreshToken: builder.mutation<{ token: string }, { refreshToken: string }>({
      query: ({ refreshToken }) => ({
        url: '/refresh',
        method: 'POST',
        body: { refreshToken },
      }),
    }),
    
    logout: builder.mutation<void, void>({
      query: () => ({
        url: '/logout',
        method: 'POST',
      }),
      async onQueryStarted(arg, { dispatch, queryFulfilled }) {
        try {
          await queryFulfilled;
          dispatch(logout());
        } catch (error) {
          // Even if logout fails on server, clear local state
          dispatch(logout());
        }
      },
    }),
  }),
});

export const {
  useLoginMutation,
  useRegisterMutation,
  useRefreshTokenMutation,
  useLogoutMutation,
} = authApi;
```

## 👤 **Profile State Management**

### **Profile API**
```typescript
// src/store/api/profileApi.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { RootState } from '../store';

export const profileApi = createApi({
  reducerPath: 'profileApi',
  baseQuery: fetchBaseQuery({
    baseUrl: '/api/v1/profiles',
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token;
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  tagTypes: ['Profile', 'ProfileCompletion'],
  endpoints: (builder) => ({
    getCurrentProfile: builder.query<User, void>({
      query: () => '/me',
      providesTags: ['Profile'],
    }),
    
    updateProfile: builder.mutation<User, Partial<User>>({
      query: (updates) => ({
        url: '/me',
        method: 'PUT',
        body: updates,
      }),
      invalidatesTags: ['Profile', 'ProfileCompletion'],
      async onQueryStarted(arg, { dispatch, queryFulfilled, getState }) {
        // Optimistic update
        const patchResult = dispatch(
          profileApi.util.updateQueryData('getCurrentProfile', undefined, (draft) => {
            Object.assign(draft, arg);
          })
        );
        
        try {
          await queryFulfilled;
        } catch {
          patchResult.undo();
        }
      },
    }),
    
    getProfileCompletion: builder.query<{
      completionPercentage: number;
      missingSections: string[];
      recommendations: string[];
    }, void>({
      query: () => '/completion',
      providesTags: ['ProfileCompletion'],
    }),
    
    searchProfiles: builder.query<{
      profiles: User[];
      pagination: any;
    }, {
      query?: string;
      profileType?: string;
      location?: string;
      page?: number;
      limit?: number;
    }>({
      query: (params) => ({
        url: '/search',
        params,
      }),
      providesTags: ['Profile'],
    }),
  }),
});

export const {
  useGetCurrentProfileQuery,
  useUpdateProfileMutation,
  useGetProfileCompletionQuery,
  useSearchProfilesQuery,
} = profileApi;
```

## 🌐 **Community State Management**

### **Community Slice**
```typescript
// src/store/slices/communitySlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CommunityState {
  activeTab: number;
  feedFilters: {
    profileTypes: string[];
    categories: string[];
    sortBy: 'recent' | 'popular' | 'trending';
  };
  searchQuery: string;
  selectedPost: string | null;
}

const initialState: CommunityState = {
  activeTab: 0,
  feedFilters: {
    profileTypes: [],
    categories: [],
    sortBy: 'recent',
  },
  searchQuery: '',
  selectedPost: null,
};

const communitySlice = createSlice({
  name: 'community',
  initialState,
  reducers: {
    setActiveTab: (state, action: PayloadAction<number>) => {
      state.activeTab = action.payload;
    },
    updateFeedFilters: (state, action: PayloadAction<Partial<CommunityState['feedFilters']>>) => {
      state.feedFilters = { ...state.feedFilters, ...action.payload };
    },
    setSearchQuery: (state, action: PayloadAction<string>) => {
      state.searchQuery = action.payload;
    },
    selectPost: (state, action: PayloadAction<string | null>) => {
      state.selectedPost = action.payload;
    },
    clearFilters: (state) => {
      state.feedFilters = initialState.feedFilters;
      state.searchQuery = '';
    },
  },
});

export const {
  setActiveTab,
  updateFeedFilters,
  setSearchQuery,
  selectPost,
  clearFilters,
} = communitySlice.actions;

export default communitySlice.reducer;
```

## 📊 **Performance Optimization**

### **Selector Optimization**
```typescript
// src/store/selectors/index.ts
import { createSelector } from '@reduxjs/toolkit';
import { RootState } from '../store';

// Memoized selectors for performance
export const selectAuth = (state: RootState) => state.auth;
export const selectProfile = (state: RootState) => state.profile;
export const selectCommunity = (state: RootState) => state.community;

export const selectIsAuthenticated = createSelector(
  [selectAuth],
  (auth) => auth.isAuthenticated
);

export const selectCurrentUser = createSelector(
  [selectAuth],
  (auth) => auth.user
);

export const selectProfileCompletion = createSelector(
  [selectCurrentUser],
  (user) => user?.profileCompletion || 0
);

export const selectFilteredPosts = createSelector(
  [
    (state: RootState) => state.community.feedFilters,
    (state: RootState, posts: any[]) => posts,
  ],
  (filters, posts) => {
    return posts.filter(post => {
      if (filters.profileTypes.length > 0 && 
          !filters.profileTypes.includes(post.author.profileType)) {
        return false;
      }
      
      if (filters.categories.length > 0 && 
          !filters.categories.includes(post.category)) {
        return false;
      }
      
      return true;
    }).sort((a, b) => {
      switch (filters.sortBy) {
        case 'popular':
          return b.likeCount - a.likeCount;
        case 'trending':
          return b.engagementRate - a.engagementRate;
        case 'recent':
        default:
          return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
      }
    });
  }
);
```

### **Custom Hooks for State Management**
```typescript
// src/hooks/useAuth.ts
import { useAppSelector, useAppDispatch } from '../store/hooks';
import { useLoginMutation, useLogoutMutation } from '../store/api/authApi';
import { clearError } from '../store/slices/authSlice';

export const useAuth = () => {
  const dispatch = useAppDispatch();
  const auth = useAppSelector((state) => state.auth);
  
  const [login, { isLoading: isLoggingIn }] = useLoginMutation();
  const [logout, { isLoading: isLoggingOut }] = useLogoutMutation();

  const handleLogin = async (credentials: { email: string; password: string }) => {
    try {
      await login(credentials).unwrap();
    } catch (error) {
      throw error;
    }
  };

  const handleLogout = async () => {
    try {
      await logout().unwrap();
    } catch (error) {
      // Handle error if needed
    }
  };

  const clearAuthError = () => {
    dispatch(clearError());
  };

  return {
    ...auth,
    login: handleLogin,
    logout: handleLogout,
    clearError: clearAuthError,
    isLoggingIn,
    isLoggingOut,
  };
};
```

### **Real-time Updates with WebSocket**
```typescript
// src/hooks/useWebSocket.ts
import { useEffect, useRef } from 'react';
import { useAppDispatch, useAppSelector } from '../store/hooks';
import { contentApi } from '../store/api/contentApi';

export const useWebSocket = () => {
  const dispatch = useAppDispatch();
  const { token, isAuthenticated } = useAppSelector((state) => state.auth);
  const wsRef = useRef<WebSocket | null>(null);

  useEffect(() => {
    if (!isAuthenticated || !token) return;

    const ws = new WebSocket(`ws://localhost:8080/ws?token=${token}`);
    wsRef.current = ws;

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      
      switch (data.type) {
        case 'NEW_POST':
          // Invalidate posts cache to refetch
          dispatch(contentApi.util.invalidateTags(['Post']));
          break;
        case 'POST_LIKED':
          // Update specific post in cache
          dispatch(
            contentApi.util.updateQueryData('getPosts', undefined, (draft) => {
              const post = draft.find(p => p.id === data.postId);
              if (post) {
                post.likeCount = data.newLikeCount;
              }
            })
          );
          break;
        case 'NEW_CONNECTION':
          dispatch(contentApi.util.invalidateTags(['Connection']));
          break;
      }
    };

    return () => {
      ws.close();
    };
  }, [isAuthenticated, token, dispatch]);

  return wsRef.current;
};
```

---

## 📚 **Reference Documents**

**UI Components**: See `/5_frontend_implementation/1_ui_component_development.md`
**Form Handling**: See `/5_frontend_implementation/3_form_handling_and_validation.md`
**API Specifications**: See `/2_technical_architecture/api_specifications/`
**Backend Implementation**: See `/4_backend_implementation/`

*This state management implementation provides efficient, scalable data flow for the ZbInnovation platform.*
