# 5. Frontend Testing and Validation

## 🧪 **Frontend Testing Overview**

This document provides comprehensive guidance for testing and validating the ZbInnovation platform frontend, including component testing, E2E testing strategies, performance testing, and accessibility validation using modern testing frameworks.

## 🏗️ **Testing Strategy Architecture**

### **Testing Pyramid for Frontend**
```
                    /\
                   /  \
                  /E2E \     <- End-to-End Tests (10%)
                 /______\
                /        \
               /Integration\ <- Integration Tests (20%)
              /__________\
             /            \
            /   Unit Tests  \  <- Unit Tests (70%)
           /________________\
```

### **Testing Framework Setup**
```typescript
// jest.config.js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.ts'],
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/index.tsx',
    '!src/reportWebVitals.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  testMatch: [
    '<rootDir>/src/**/__tests__/**/*.{js,jsx,ts,tsx}',
    '<rootDir>/src/**/*.(test|spec).{js,jsx,ts,tsx}',
  ],
};
```

## 🔧 **Component Testing**

### **Testing Utilities Setup**
```typescript
// src/test-utils/render.tsx
import React, { ReactElement } from 'react';
import { render, RenderOptions } from '@testing-library/react';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom';
import { ThemeProvider } from '@mui/material/styles';
import { configureStore } from '@reduxjs/toolkit';
import { theme } from '../theme/theme';

// Import your reducers
import authSlice from '../store/slices/authSlice';
import profileSlice from '../store/slices/profileSlice';

const createTestStore = (preloadedState = {}) => {
  return configureStore({
    reducer: {
      auth: authSlice,
      profile: profileSlice,
    },
    preloadedState,
  });
};

interface CustomRenderOptions extends Omit<RenderOptions, 'wrapper'> {
  preloadedState?: any;
  store?: any;
}

const AllTheProviders: React.FC<{
  children: React.ReactNode;
  store: any;
}> = ({ children, store }) => {
  return (
    <Provider store={store}>
      <BrowserRouter>
        <ThemeProvider theme={theme}>
          {children}
        </ThemeProvider>
      </BrowserRouter>
    </Provider>
  );
};

const customRender = (
  ui: ReactElement,
  {
    preloadedState = {},
    store = createTestStore(preloadedState),
    ...renderOptions
  }: CustomRenderOptions = {}
) => {
  const Wrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <AllTheProviders store={store}>{children}</AllTheProviders>
  );

  return {
    store,
    ...render(ui, { wrapper: Wrapper, ...renderOptions }),
  };
};

export * from '@testing-library/react';
export { customRender as render };
```

### **Component Test Examples**
```typescript
// src/components/common/Button/Button.test.tsx
import React from 'react';
import { render, screen, fireEvent, waitFor } from '../../../test-utils/render';
import { Button } from './Button';

describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('applies correct variant styles', () => {
    render(<Button variant="primary">Primary Button</Button>);
    const button = screen.getByRole('button');
    expect(button).toHaveClass('MuiButton-containedPrimary');
  });

  it('shows loading state correctly', () => {
    render(<Button loading>Loading Button</Button>);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
    expect(screen.getByRole('button')).toBeDisabled();
  });

  it('handles click events', async () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Clickable</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    await waitFor(() => {
      expect(handleClick).toHaveBeenCalledTimes(1);
    });
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Disabled Button</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

### **Form Component Testing**
```typescript
// src/components/forms/ProfileForm/ProfileForm.test.tsx
import React from 'react';
import { render, screen, fireEvent, waitFor } from '../../../test-utils/render';
import { ProfileForm } from './ProfileForm';
import { ProfileType } from '../../../types/user.types';

const mockOnSubmit = jest.fn();

const defaultProps = {
  profileType: ProfileType.INNOVATOR,
  onSubmit: mockOnSubmit,
  loading: false,
};

describe('ProfileForm Component', () => {
  beforeEach(() => {
    mockOnSubmit.mockClear();
  });

  it('renders all required fields for innovator profile', () => {
    render(<ProfileForm {...defaultProps} />);
    
    expect(screen.getByLabelText(/first name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/last name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/industry focus/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/innovation stage/i)).toBeInTheDocument();
  });

  it('shows validation errors for empty required fields', async () => {
    render(<ProfileForm {...defaultProps} />);
    
    const submitButton = screen.getByRole('button', { name: /save profile/i });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(screen.getByText(/first name is required/i)).toBeInTheDocument();
      expect(screen.getByText(/last name is required/i)).toBeInTheDocument();
      expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    });
  });

  it('submits form with valid data', async () => {
    render(<ProfileForm {...defaultProps} />);
    
    // Fill in form fields
    fireEvent.change(screen.getByLabelText(/first name/i), {
      target: { value: 'John' },
    });
    fireEvent.change(screen.getByLabelText(/last name/i), {
      target: { value: 'Doe' },
    });
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'john@example.com' },
    });
    
    const submitButton = screen.getByRole('button', { name: /save profile/i });
    fireEvent.click(submitButton);
    
    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith(
        expect.objectContaining({
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
        })
      );
    });
  });

  it('shows different fields for different profile types', () => {
    const { rerender } = render(<ProfileForm {...defaultProps} />);
    
    // Innovator fields
    expect(screen.getByLabelText(/innovation stage/i)).toBeInTheDocument();
    
    // Change to investor profile
    rerender(
      <ProfileForm {...defaultProps} profileType={ProfileType.BUSINESS_INVESTOR} />
    );
    
    // Investor fields
    expect(screen.getByLabelText(/investment focus/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/ticket size/i)).toBeInTheDocument();
  });
});
```

## 🔗 **Integration Testing**

### **API Integration Tests**
```typescript
// src/store/api/__tests__/authApi.test.ts
import { setupApiStore } from '../../../test-utils/api';
import { authApi } from '../authApi';

describe('Auth API', () => {
  const storeRef = setupApiStore(authApi);

  beforeEach(() => {
    fetchMock.resetMocks();
  });

  it('should login successfully', async () => {
    const mockResponse = {
      user: { id: '1', email: 'test@example.com', firstName: 'Test' },
      token: 'mock-token',
      refreshToken: 'mock-refresh-token',
    };

    fetchMock.mockResponseOnce(JSON.stringify(mockResponse));

    const result = await storeRef.store.dispatch(
      authApi.endpoints.login.initiate({
        email: 'test@example.com',
        password: 'password123',
      })
    );

    expect(result.data).toEqual(mockResponse);
    expect(fetchMock).toHaveBeenCalledWith(
      expect.stringContaining('/api/v1/auth/login'),
      expect.objectContaining({
        method: 'POST',
        body: JSON.stringify({
          email: 'test@example.com',
          password: 'password123',
        }),
      })
    );
  });

  it('should handle login failure', async () => {
    fetchMock.mockRejectOnce(new Error('Invalid credentials'));

    const result = await storeRef.store.dispatch(
      authApi.endpoints.login.initiate({
        email: 'test@example.com',
        password: 'wrongpassword',
      })
    );

    expect(result.error).toBeDefined();
  });
});
```

### **Redux State Integration Tests**
```typescript
// src/store/__tests__/authSlice.test.ts
import { configureStore } from '@reduxjs/toolkit';
import authSlice, {
  loginStart,
  loginSuccess,
  loginFailure,
  logout,
} from '../slices/authSlice';

describe('Auth Slice', () => {
  let store: any;

  beforeEach(() => {
    store = configureStore({
      reducer: {
        auth: authSlice,
      },
    });
  });

  it('should handle login start', () => {
    store.dispatch(loginStart());
    const state = store.getState().auth;
    
    expect(state.loading).toBe(true);
    expect(state.error).toBe(null);
  });

  it('should handle login success', () => {
    const mockUser = { id: '1', email: 'test@example.com' };
    const mockTokens = { token: 'token', refreshToken: 'refresh' };
    
    store.dispatch(loginSuccess({
      user: mockUser,
      ...mockTokens,
    }));
    
    const state = store.getState().auth;
    expect(state.user).toEqual(mockUser);
    expect(state.token).toBe('token');
    expect(state.isAuthenticated).toBe(true);
    expect(state.loading).toBe(false);
  });

  it('should handle logout', () => {
    // First login
    store.dispatch(loginSuccess({
      user: { id: '1', email: 'test@example.com' },
      token: 'token',
      refreshToken: 'refresh',
    }));
    
    // Then logout
    store.dispatch(logout());
    
    const state = store.getState().auth;
    expect(state.user).toBe(null);
    expect(state.token).toBe(null);
    expect(state.isAuthenticated).toBe(false);
  });
});
```

## 🎭 **End-to-End Testing with Playwright**

### **Playwright Configuration**
```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  webServer: {
    command: 'npm start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### **E2E Test Examples**
```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication Flow', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('[data-testid="email-input"]', 'test@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');
    await page.click('[data-testid="login-button"]');
    
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('[data-testid="email-input"]', 'test@example.com');
    await page.fill('[data-testid="password-input"]', 'wrongpassword');
    await page.click('[data-testid="login-button"]');
    
    await expect(page.locator('[data-testid="error-message"]')).toContainText(
      'Invalid credentials'
    );
  });

  test('should register new user', async ({ page }) => {
    await page.goto('/register');
    
    await page.fill('[data-testid="first-name-input"]', 'John');
    await page.fill('[data-testid="last-name-input"]', 'Doe');
    await page.fill('[data-testid="email-input"]', 'john@example.com');
    await page.fill('[data-testid="password-input"]', 'SecurePass123!');
    await page.selectOption('[data-testid="profile-type-select"]', 'innovator');
    await page.check('[data-testid="terms-checkbox"]');
    
    await page.click('[data-testid="register-button"]');
    
    await expect(page).toHaveURL('/dashboard');
  });
});
```

### **User Journey E2E Tests**
```typescript
// e2e/user-journey.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Complete User Journey', () => {
  test('innovator profile creation and community interaction', async ({ page }) => {
    // Register as innovator
    await page.goto('/register');
    await page.fill('[data-testid="first-name-input"]', 'Jane');
    await page.fill('[data-testid="last-name-input"]', 'Smith');
    await page.fill('[data-testid="email-input"]', 'jane@startup.com');
    await page.fill('[data-testid="password-input"]', 'SecurePass123!');
    await page.selectOption('[data-testid="profile-type-select"]', 'innovator');
    await page.check('[data-testid="terms-checkbox"]');
    await page.click('[data-testid="register-button"]');
    
    // Complete profile
    await page.click('[data-testid="complete-profile-button"]');
    await page.fill('[data-testid="startup-name-input"]', 'TechStartup');
    await page.selectOption('[data-testid="industry-select"]', 'technology');
    await page.selectOption('[data-testid="stage-select"]', 'mvp');
    await page.fill('[data-testid="funding-input"]', '100000');
    await page.click('[data-testid="save-profile-button"]');
    
    // Navigate to community
    await page.click('[data-testid="community-nav"]');
    
    // Create a post
    await page.fill('[data-testid="post-content-input"]', 'Excited to share our MVP!');
    await page.click('[data-testid="create-post-button"]');
    
    // Verify post appears in feed
    await expect(page.locator('[data-testid="post-content"]')).toContainText(
      'Excited to share our MVP!'
    );
  });
});
```

## 📊 **Performance Testing**

### **Performance Test Setup**
```typescript
// src/test-utils/performance.ts
import { render } from '@testing-library/react';
import { performance } from 'perf_hooks';

export const measureRenderTime = (component: React.ReactElement) => {
  const start = performance.now();
  render(component);
  const end = performance.now();
  return end - start;
};

export const measureMemoryUsage = () => {
  if (performance.memory) {
    return {
      used: performance.memory.usedJSHeapSize,
      total: performance.memory.totalJSHeapSize,
      limit: performance.memory.jsHeapSizeLimit,
    };
  }
  return null;
};
```

### **Performance Tests**
```typescript
// src/components/__tests__/performance.test.ts
import React from 'react';
import { measureRenderTime } from '../../test-utils/performance';
import { CommunityPage } from '../pages/Community/CommunityPage';
import { DashboardPage } from '../pages/Dashboard/DashboardPage';

describe('Performance Tests', () => {
  it('should render CommunityPage within acceptable time', () => {
    const renderTime = measureRenderTime(<CommunityPage />);
    expect(renderTime).toBeLessThan(100); // 100ms threshold
  });

  it('should render DashboardPage within acceptable time', () => {
    const renderTime = measureRenderTime(<DashboardPage />);
    expect(renderTime).toBeLessThan(150); // 150ms threshold
  });
});
```

## ♿ **Accessibility Testing**

### **Accessibility Test Setup**
```typescript
// src/test-utils/accessibility.ts
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

export const checkAccessibility = async (container: HTMLElement) => {
  const results = await axe(container);
  expect(results).toHaveNoViolations();
};
```

### **Accessibility Tests**
```typescript
// src/components/__tests__/accessibility.test.tsx
import React from 'react';
import { render } from '../../test-utils/render';
import { checkAccessibility } from '../../test-utils/accessibility';
import { Button } from '../common/Button/Button';
import { TextInput } from '../common/Input/TextInput';

describe('Accessibility Tests', () => {
  it('Button should be accessible', async () => {
    const { container } = render(<Button>Accessible Button</Button>);
    await checkAccessibility(container);
  });

  it('TextInput should be accessible', async () => {
    const { container } = render(
      <TextInput label="Accessible Input" name="test" />
    );
    await checkAccessibility(container);
  });

  it('Form should be accessible', async () => {
    const { container } = render(
      <form>
        <TextInput label="First Name" name="firstName" required />
        <TextInput label="Email" name="email" type="email" required />
        <Button type="submit">Submit</Button>
      </form>
    );
    await checkAccessibility(container);
  });
});
```

---

## 📚 **Reference Documents**

**UI Components**: See `/5_frontend_implementation/1_ui_component_development.md`
**State Management**: See `/5_frontend_implementation/4_state_management_implementation.md`
**Backend Testing**: See `/4_backend_implementation/5_api_testing_and_validation.md`
**Integration Testing**: See `/6_integration_and_testing/2_end_to_end_testing.md`

*This comprehensive frontend testing strategy ensures high-quality, accessible, and performant user interfaces for the ZbInnovation platform.*
