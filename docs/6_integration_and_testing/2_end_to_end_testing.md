# 2. End-to-End Testing

## 🎭 **End-to-End Testing Overview**

This document provides comprehensive guidance for implementing end-to-end testing for the ZbInnovation platform, including E2E testing framework setup, user journey testing, cross-browser testing, and mobile testing strategies using Playwright and Cypress.

## 🏗️ **E2E Testing Framework Setup**

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
  reporter: [
    ['html'],
    ['junit', { outputFile: 'test-results/junit.xml' }],
    ['json', { outputFile: 'test-results/results.json' }],
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10000,
    navigationTimeout: 30000,
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
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'mobile-safari',
      use: { ...devices['iPhone 12'] },
    },
  ],
  webServer: {
    command: 'npm start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
```

### **Test Utilities and Helpers**
```typescript
// e2e/utils/testHelpers.ts
import { Page, expect } from '@playwright/test';

export class TestHelpers {
  constructor(private page: Page) {}

  async loginAsUser(email: string, password: string) {
    await this.page.goto('/login');
    await this.page.fill('[data-testid="email-input"]', email);
    await this.page.fill('[data-testid="password-input"]', password);
    await this.page.click('[data-testid="login-button"]');
    await expect(this.page).toHaveURL('/dashboard');
  }

  async registerNewUser(userData: {
    firstName: string;
    lastName: string;
    email: string;
    password: string;
    profileType: string;
  }) {
    await this.page.goto('/register');
    await this.page.fill('[data-testid="first-name-input"]', userData.firstName);
    await this.page.fill('[data-testid="last-name-input"]', userData.lastName);
    await this.page.fill('[data-testid="email-input"]', userData.email);
    await this.page.fill('[data-testid="password-input"]', userData.password);
    await this.page.selectOption('[data-testid="profile-type-select"]', userData.profileType);
    await this.page.check('[data-testid="terms-checkbox"]');
    await this.page.click('[data-testid="register-button"]');
    await expect(this.page).toHaveURL('/dashboard');
  }

  async createPost(content: string, category?: string) {
    await this.page.goto('/virtual-community');
    await this.page.fill('[data-testid="post-content-input"]', content);
    
    if (category) {
      await this.page.selectOption('[data-testid="post-category-select"]', category);
    }
    
    await this.page.click('[data-testid="create-post-button"]');
    await this.page.waitForSelector(`[data-testid="post-content"]:has-text("${content}")`);
  }

  async waitForNotification(message: string) {
    await this.page.waitForSelector(`[data-testid="notification"]:has-text("${message}")`);
  }

  async uploadFile(inputSelector: string, filePath: string) {
    const fileInput = this.page.locator(inputSelector);
    await fileInput.setInputFiles(filePath);
  }

  async takeScreenshot(name: string) {
    await this.page.screenshot({ path: `screenshots/${name}.png`, fullPage: true });
  }
}
```

## 🚀 **User Journey Testing**

### **Complete User Registration Journey**
```typescript
// e2e/journeys/userRegistration.spec.ts
import { test, expect } from '@playwright/test';
import { TestHelpers } from '../utils/testHelpers';

test.describe('User Registration Journey', () => {
  let helpers: TestHelpers;

  test.beforeEach(async ({ page }) => {
    helpers = new TestHelpers(page);
  });

  test('should complete full innovator registration and profile setup', async ({ page }) => {
    const userData = {
      firstName: 'John',
      lastName: 'Innovator',
      email: `john.innovator.${Date.now()}@test.com`,
      password: 'SecurePass123!',
      profileType: 'innovator',
    };

    // Step 1: Register new user
    await helpers.registerNewUser(userData);

    // Step 2: Verify dashboard access
    await expect(page.locator('[data-testid="welcome-message"]')).toContainText(userData.firstName);

    // Step 3: Complete profile
    await page.click('[data-testid="complete-profile-button"]');
    
    // Fill innovator-specific fields
    await page.fill('[data-testid="startup-name-input"]', 'TechStartup Inc');
    await page.selectOption('[data-testid="industry-select"]', 'technology');
    await page.selectOption('[data-testid="innovation-stage-select"]', 'mvp');
    await page.fill('[data-testid="funding-needed-input"]', '100000');
    await page.fill('[data-testid="bio-input"]', 'Passionate innovator building the future');
    
    await page.click('[data-testid="save-profile-button"]');

    // Step 4: Verify profile completion
    await helpers.waitForNotification('Profile updated successfully');
    
    // Step 5: Navigate to community
    await page.click('[data-testid="community-nav"]');
    await expect(page).toHaveURL('/virtual-community');

    // Step 6: Create first post
    await helpers.createPost('Excited to join the ZbInnovation community!', 'general');

    // Step 7: Verify post appears in feed
    await expect(page.locator('[data-testid="post-content"]').first())
      .toContainText('Excited to join the ZbInnovation community!');
  });

  test('should handle investor registration with investment preferences', async ({ page }) => {
    const userData = {
      firstName: 'Jane',
      lastName: 'Investor',
      email: `jane.investor.${Date.now()}@test.com`,
      password: 'SecurePass123!',
      profileType: 'business_investor',
    };

    await helpers.registerNewUser(userData);

    // Complete investor profile
    await page.click('[data-testid="complete-profile-button"]');
    
    await page.selectOption('[data-testid="investment-focus-select"]', ['technology', 'healthcare']);
    await page.fill('[data-testid="ticket-size-min-input"]', '10000');
    await page.fill('[data-testid="ticket-size-max-input"]', '500000');
    await page.selectOption('[data-testid="stage-preference-select"]', ['seed', 'series-a']);
    
    await page.click('[data-testid="save-profile-button"]');

    // Verify investor dashboard features
    await expect(page.locator('[data-testid="investment-opportunities"]')).toBeVisible();
    await expect(page.locator('[data-testid="portfolio-overview"]')).toBeVisible();
  });
});
```

### **Community Interaction Journey**
```typescript
// e2e/journeys/communityInteraction.spec.ts
import { test, expect } from '@playwright/test';
import { TestHelpers } from '../utils/testHelpers';

test.describe('Community Interaction Journey', () => {
  let helpers: TestHelpers;

  test.beforeEach(async ({ page }) => {
    helpers = new TestHelpers(page);
    // Login with existing test user
    await helpers.loginAsUser('test.user@example.com', 'TestPass123!');
  });

  test('should complete full community interaction flow', async ({ page }) => {
    // Navigate to community
    await page.click('[data-testid="community-nav"]');

    // Test 1: Create a post
    await helpers.createPost('Looking for co-founders for my AI startup!', 'opportunities');

    // Test 2: Like a post
    await page.click('[data-testid="like-button"]');
    await expect(page.locator('[data-testid="like-count"]')).toContainText('1');

    // Test 3: Comment on a post
    await page.click('[data-testid="comment-button"]');
    await page.fill('[data-testid="comment-input"]', 'Great opportunity! I\'m interested.');
    await page.click('[data-testid="submit-comment-button"]');
    await expect(page.locator('[data-testid="comment-content"]'))
      .toContainText('Great opportunity! I\'m interested.');

    // Test 4: Search for profiles
    await page.click('[data-testid="profiles-tab"]');
    await page.fill('[data-testid="search-input"]', 'technology');
    await page.click('[data-testid="search-button"]');
    await expect(page.locator('[data-testid="profile-card"]')).toHaveCount.greaterThan(0);

    // Test 5: Send connection request
    await page.click('[data-testid="profile-card"]').first();
    await page.click('[data-testid="connect-button"]');
    await helpers.waitForNotification('Connection request sent');

    // Test 6: Join a group
    await page.click('[data-testid="groups-tab"]');
    await page.click('[data-testid="group-card"]').first();
    await page.click('[data-testid="join-group-button"]');
    await helpers.waitForNotification('Successfully joined group');
  });

  test('should handle event creation and participation', async ({ page }) => {
    await page.click('[data-testid="community-nav"]');
    await page.click('[data-testid="events-tab"]');

    // Create new event
    await page.click('[data-testid="create-event-button"]');
    await page.fill('[data-testid="event-title-input"]', 'Tech Innovation Meetup');
    await page.fill('[data-testid="event-description-input"]', 'Monthly meetup for tech innovators');
    await page.fill('[data-testid="event-date-input"]', '2024-02-15');
    await page.fill('[data-testid="event-time-input"]', '18:00');
    await page.fill('[data-testid="event-location-input"]', 'Harare Innovation Hub');
    
    await page.click('[data-testid="create-event-submit-button"]');
    await helpers.waitForNotification('Event created successfully');

    // Verify event appears in list
    await expect(page.locator('[data-testid="event-title"]'))
      .toContainText('Tech Innovation Meetup');

    // RSVP to event
    await page.click('[data-testid="rsvp-button"]');
    await helpers.waitForNotification('RSVP confirmed');
  });
});
```

## 🌐 **Cross-Browser Testing**

### **Browser Compatibility Tests**
```typescript
// e2e/compatibility/browserCompatibility.spec.ts
import { test, expect, devices } from '@playwright/test';

const browsers = [
  { name: 'Chrome', device: devices['Desktop Chrome'] },
  { name: 'Firefox', device: devices['Desktop Firefox'] },
  { name: 'Safari', device: devices['Desktop Safari'] },
  { name: 'Edge', device: devices['Desktop Edge'] },
];

browsers.forEach(({ name, device }) => {
  test.describe(`${name} Compatibility`, () => {
    test.use(device);

    test(`should render landing page correctly in ${name}`, async ({ page }) => {
      await page.goto('/');
      
      // Check critical elements
      await expect(page.locator('[data-testid="hero-title"]')).toBeVisible();
      await expect(page.locator('[data-testid="cta-button"]')).toBeVisible();
      await expect(page.locator('[data-testid="features-section"]')).toBeVisible();
      
      // Take screenshot for visual comparison
      await page.screenshot({ path: `screenshots/landing-${name.toLowerCase()}.png` });
    });

    test(`should handle authentication flow in ${name}`, async ({ page }) => {
      await page.goto('/login');
      
      await page.fill('[data-testid="email-input"]', 'test@example.com');
      await page.fill('[data-testid="password-input"]', 'TestPass123!');
      await page.click('[data-testid="login-button"]');
      
      await expect(page).toHaveURL('/dashboard');
      await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
    });

    test(`should handle responsive design in ${name}`, async ({ page }) => {
      // Test desktop view
      await page.setViewportSize({ width: 1920, height: 1080 });
      await page.goto('/virtual-community');
      await expect(page.locator('[data-testid="sidebar"]')).toBeVisible();
      
      // Test tablet view
      await page.setViewportSize({ width: 768, height: 1024 });
      await page.reload();
      await expect(page.locator('[data-testid="mobile-menu-button"]')).toBeVisible();
      
      // Test mobile view
      await page.setViewportSize({ width: 375, height: 667 });
      await page.reload();
      await expect(page.locator('[data-testid="bottom-navigation"]')).toBeVisible();
    });
  });
});
```

## 📱 **Mobile Testing Strategy**

### **Mobile-Specific Tests**
```typescript
// e2e/mobile/mobileExperience.spec.ts
import { test, expect, devices } from '@playwright/test';

test.describe('Mobile Experience', () => {
  test.use(devices['iPhone 12']);

  test('should provide optimal mobile experience', async ({ page }) => {
    await page.goto('/');

    // Test mobile navigation
    await expect(page.locator('[data-testid="mobile-header"]')).toBeVisible();
    await page.click('[data-testid="mobile-menu-button"]');
    await expect(page.locator('[data-testid="mobile-menu"]')).toBeVisible();

    // Test touch interactions
    await page.tap('[data-testid="login-link"]');
    await expect(page).toHaveURL('/login');

    // Test form inputs on mobile
    await page.fill('[data-testid="email-input"]', 'mobile@test.com');
    await page.fill('[data-testid="password-input"]', 'MobilePass123!');
    
    // Test virtual keyboard handling
    await expect(page.locator('[data-testid="login-form"]')).toBeVisible();
    
    // Test swipe gestures (if applicable)
    await page.goto('/virtual-community');
    const feedContainer = page.locator('[data-testid="feed-container"]');
    await feedContainer.swipeUp();
  });

  test('should handle mobile-specific features', async ({ page }) => {
    await page.goto('/profile');

    // Test file upload on mobile
    await page.click('[data-testid="upload-photo-button"]');
    
    // Test geolocation (if enabled)
    await page.context().grantPermissions(['geolocation']);
    await page.click('[data-testid="add-location-button"]');
    
    // Test camera access for profile photo
    await page.context().grantPermissions(['camera']);
    await page.click('[data-testid="take-photo-button"]');
  });
});

test.describe('Tablet Experience', () => {
  test.use(devices['iPad Pro']);

  test('should adapt layout for tablet', async ({ page }) => {
    await page.goto('/virtual-community');

    // Verify tablet-specific layout
    await expect(page.locator('[data-testid="tablet-sidebar"]')).toBeVisible();
    await expect(page.locator('[data-testid="main-content"]')).toHaveCSS('width', /70%/);
    
    // Test split-screen functionality
    await page.click('[data-testid="profile-card"]');
    await expect(page.locator('[data-testid="profile-detail-panel"]')).toBeVisible();
  });
});
```

## 🔄 **Performance Testing in E2E**

### **Performance Monitoring**
```typescript
// e2e/performance/performanceTests.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Performance Tests', () => {
  test('should meet performance benchmarks', async ({ page }) => {
    // Start performance monitoring
    await page.coverage.startJSCoverage();
    await page.coverage.startCSSCoverage();

    const startTime = Date.now();
    await page.goto('/');
    const loadTime = Date.now() - startTime;

    // Check page load time
    expect(loadTime).toBeLessThan(3000); // 3 seconds

    // Check Core Web Vitals
    const metrics = await page.evaluate(() => {
      return new Promise((resolve) => {
        new PerformanceObserver((list) => {
          const entries = list.getEntries();
          const vitals = {};
          
          entries.forEach((entry) => {
            if (entry.name === 'first-contentful-paint') {
              vitals.fcp = entry.startTime;
            }
            if (entry.name === 'largest-contentful-paint') {
              vitals.lcp = entry.startTime;
            }
          });
          
          resolve(vitals);
        }).observe({ entryTypes: ['paint', 'largest-contentful-paint'] });
      });
    });

    expect(metrics.fcp).toBeLessThan(1800); // FCP < 1.8s
    expect(metrics.lcp).toBeLessThan(2500); // LCP < 2.5s

    // Check bundle size
    const jsCoverage = await page.coverage.stopJSCoverage();
    const cssCoverage = await page.coverage.stopCSSCoverage();
    
    const totalJSSize = jsCoverage.reduce((sum, entry) => sum + entry.text.length, 0);
    const totalCSSSize = cssCoverage.reduce((sum, entry) => sum + entry.text.length, 0);
    
    expect(totalJSSize).toBeLessThan(1000000); // 1MB JS limit
    expect(totalCSSSize).toBeLessThan(200000);  // 200KB CSS limit
  });

  test('should handle concurrent users', async ({ browser }) => {
    const contexts = await Promise.all(
      Array.from({ length: 10 }, () => browser.newContext())
    );

    const pages = await Promise.all(
      contexts.map(context => context.newPage())
    );

    // Simulate 10 concurrent users
    const startTime = Date.now();
    await Promise.all(
      pages.map(async (page, index) => {
        await page.goto('/login');
        await page.fill('[data-testid="email-input"]', `user${index}@test.com`);
        await page.fill('[data-testid="password-input"]', 'TestPass123!');
        await page.click('[data-testid="login-button"]');
        await expect(page).toHaveURL('/dashboard');
      })
    );
    const totalTime = Date.now() - startTime;

    expect(totalTime).toBeLessThan(15000); // All users should login within 15s

    // Cleanup
    await Promise.all(contexts.map(context => context.close()));
  });
});
```

---

## 📚 **Reference Documents**

**System Integration**: See `/6_integration_and_testing/1_system_integration.md`
**Frontend Testing**: See `/5_frontend_implementation/5_frontend_testing_and_validation.md`
**Backend Testing**: See `/4_backend_implementation/5_api_testing_and_validation.md`
**Performance Testing**: See `/6_integration_and_testing/3_performance_testing_and_optimization.md`

*This comprehensive E2E testing strategy ensures reliable, cross-platform functionality for the ZbInnovation platform.*
