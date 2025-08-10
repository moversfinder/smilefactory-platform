# 19. Process Flow Implementation Guidelines

## 🎯 **Overview**

This document provides comprehensive implementation guidelines for development teams to build the Authentication and Profile Creation Process Flows. It includes specific technical requirements, code examples, and best practices for both frontend and backend development.

## 🏗️ **Architecture Implementation Priorities**

### **Phase 1: Database Foundation (Week 1)**
1. **Personal Details Table Enhancement**
   - Verify UUID primary key implementation
   - Add social authentication fields
   - Implement auto-save draft columns
   - Create proper indexes for performance

2. **Profile Type Tables Setup**
   - Create all 8 profile-specific tables
   - Establish foreign key relationships to personal_details
   - Add completion tracking fields
   - Implement audit trail columns

### **Phase 2: Backend API Development (Weeks 2-3)**
1. **Authentication Endpoints**
   - Email/password registration and login
   - Social authentication integration
   - Phone/SMS verification system
   - JWT token management

2. **Profile Management Endpoints**
   - Profile type selection and validation
   - Personal information collection
   - Profile-specific data management
   - Auto-save functionality

### **Phase 3: Frontend Implementation (Weeks 3-4)**
1. **Authentication UI Components**
   - Method selection interface
   - Registration and login forms
   - Social authentication buttons
   - Dashboard with profile prompt

2. **Profile Creation UI Components**
   - Profile type selection cards
   - Personal information forms
   - Dynamic profile-specific forms
   - Progress tracking and completion

## 🔧 **Backend Implementation Guidelines**

### **Database Schema Implementation**

#### **Enhanced Personal Details Table**
```sql
-- Add fields for process flow support
ALTER TABLE personal_details ADD COLUMN IF NOT EXISTS social_provider VARCHAR(50);
ALTER TABLE personal_details ADD COLUMN IF NOT EXISTS social_provider_id VARCHAR(255);
ALTER TABLE personal_details ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE personal_details ADD COLUMN IF NOT EXISTS profile_creation_step INTEGER DEFAULT 0;
ALTER TABLE personal_details ADD COLUMN IF NOT EXISTS draft_data JSONB;
ALTER TABLE personal_details ADD COLUMN IF NOT EXISTS last_auto_save TIMESTAMP;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_personal_details_social_provider ON personal_details(social_provider);
CREATE INDEX IF NOT EXISTS idx_personal_details_profile_step ON personal_details(profile_creation_step);
CREATE INDEX IF NOT EXISTS idx_personal_details_last_auto_save ON personal_details(last_auto_save);
```

#### **Auto-Save Draft Table**
```sql
CREATE TABLE IF NOT EXISTS profile_creation_drafts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES personal_details(id) ON DELETE CASCADE,
    step INTEGER NOT NULL CHECK (step IN (1, 2, 3)),
    draft_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, step)
);

CREATE INDEX idx_profile_drafts_user_step ON profile_creation_drafts(user_id, step);
```

### **Authentication Service Implementation**

#### **Multi-Method Authentication Service**
```java
@Service
@Transactional
public class AuthenticationService {
    
    @Autowired
    private PersonalDetailsRepository personalDetailsRepository;
    
    @Autowired
    private JwtTokenService jwtTokenService;
    
    @Autowired
    private EmailVerificationService emailVerificationService;
    
    @Autowired
    private SmsVerificationService smsVerificationService;
    
    public AuthenticationResponse registerWithEmail(EmailRegistrationRequest request) {
        // Validate email uniqueness
        if (personalDetailsRepository.existsByEmail(request.getEmail())) {
            throw new EmailAlreadyExistsException("Email already registered");
        }
        
        // Create personal details record
        PersonalDetails user = PersonalDetails.builder()
            .id(UUID.randomUUID())
            .email(request.getEmail())
            .passwordHash(passwordEncoder.encode(request.getPassword()))
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .emailVerified(false)
            .profileCreationStep(0)
            .profileCompletion(0)
            .build();
        
        personalDetailsRepository.save(user);
        
        // Send verification email
        emailVerificationService.sendVerificationEmail(user);
        
        return AuthenticationResponse.builder()
            .userId(user.getId())
            .email(user.getEmail())
            .requiresEmailVerification(true)
            .build();
    }
    
    public AuthenticationResponse registerWithSocial(SocialRegistrationRequest request) {
        // Validate social provider token
        SocialUserInfo socialInfo = socialAuthService.validateToken(
            request.getProvider(), request.getToken()
        );
        
        // Check if user exists by social provider ID
        Optional<PersonalDetails> existingUser = personalDetailsRepository
            .findBySocialProviderAndSocialProviderId(
                request.getProvider(), socialInfo.getId()
            );
        
        if (existingUser.isPresent()) {
            return loginExistingUser(existingUser.get());
        }
        
        // Create new user from social data
        PersonalDetails user = PersonalDetails.builder()
            .id(UUID.randomUUID())
            .email(socialInfo.getEmail())
            .firstName(socialInfo.getFirstName())
            .lastName(socialInfo.getLastName())
            .socialProvider(request.getProvider())
            .socialProviderId(socialInfo.getId())
            .emailVerified(true) // Social providers verify email
            .profileCreationStep(0)
            .profileCompletion(0)
            .build();
        
        personalDetailsRepository.save(user);
        
        return AuthenticationResponse.builder()
            .userId(user.getId())
            .email(user.getEmail())
            .accessToken(jwtTokenService.generateAccessToken(user))
            .refreshToken(jwtTokenService.generateRefreshToken(user))
            .requiresProfileCreation(true)
            .build();
    }
    
    public AuthenticationResponse registerWithPhone(PhoneRegistrationRequest request) {
        // Validate phone number format
        String normalizedPhone = phoneNumberService.normalize(request.getPhoneNumber());
        
        if (personalDetailsRepository.existsByPhoneNumber(normalizedPhone)) {
            throw new PhoneAlreadyExistsException("Phone number already registered");
        }
        
        // Create user with phone
        PersonalDetails user = PersonalDetails.builder()
            .id(UUID.randomUUID())
            .phoneNumber(normalizedPhone)
            .phoneVerified(false)
            .profileCreationStep(0)
            .profileCompletion(0)
            .build();
        
        personalDetailsRepository.save(user);
        
        // Send SMS verification
        smsVerificationService.sendVerificationCode(user);
        
        return AuthenticationResponse.builder()
            .userId(user.getId())
            .phoneNumber(normalizedPhone)
            .requiresPhoneVerification(true)
            .build();
    }
}
```

### **Profile Creation Service Implementation**

#### **Auto-Save Profile Service**
```java
@Service
@Transactional
public class ProfileCreationService {
    
    @Autowired
    private PersonalDetailsRepository personalDetailsRepository;
    
    @Autowired
    private ProfileCreationDraftRepository draftRepository;
    
    public void autoSaveStep(String userId, int step, Object stepData) {
        UUID userUuid = UUID.fromString(userId);
        
        // Convert step data to JSON
        String jsonData = objectMapper.writeValueAsString(stepData);
        
        // Save or update draft
        ProfileCreationDraft draft = draftRepository
            .findByUserIdAndStep(userUuid, step)
            .orElse(ProfileCreationDraft.builder()
                .userId(userUuid)
                .step(step)
                .build());
        
        draft.setDraftData(jsonData);
        draft.setUpdatedAt(LocalDateTime.now());
        
        draftRepository.save(draft);
        
        // Update last auto-save timestamp
        personalDetailsRepository.updateLastAutoSave(userUuid, LocalDateTime.now());
    }
    
    public ProfileCreationState getProfileCreationState(String userId) {
        UUID userUuid = UUID.fromString(userId);
        PersonalDetails user = personalDetailsRepository.findById(userUuid)
            .orElseThrow(() -> new UserNotFoundException("User not found"));
        
        // Get all draft data
        List<ProfileCreationDraft> drafts = draftRepository.findByUserId(userUuid);
        Map<Integer, Object> stepData = drafts.stream()
            .collect(Collectors.toMap(
                ProfileCreationDraft::getStep,
                draft -> parseJsonData(draft.getDraftData())
            ));
        
        return ProfileCreationState.builder()
            .currentStep(user.getProfileCreationStep())
            .completionPercentage(user.getProfileCompletion())
            .stepData(stepData)
            .lastAutoSave(user.getLastAutoSave())
            .build();
    }
    
    public void completeProfileStep(String userId, int step, Object stepData) {
        UUID userUuid = UUID.fromString(userId);
        
        switch (step) {
            case 1: // Profile type selection
                completeProfileTypeSelection(userUuid, (ProfileTypeSelection) stepData);
                break;
            case 2: // Personal information
                completePersonalInformation(userUuid, (PersonalInformation) stepData);
                break;
            case 3: // Profile-specific details
                completeProfileDetails(userUuid, stepData);
                break;
        }
        
        // Update completion step and percentage
        int completionPercentage = calculateCompletionPercentage(step);
        personalDetailsRepository.updateProfileProgress(userUuid, step, completionPercentage);
        
        // Clear draft for completed step
        draftRepository.deleteByUserIdAndStep(userUuid, step);
    }
}
```

## 🎨 **Frontend Implementation Guidelines**

### **Authentication Component Architecture**

#### **Authentication Method Selector**
```typescript
// AuthenticationMethodSelector.tsx
import React, { useState } from 'react';
import { AuthMethod } from '../types/auth.types';

interface AuthMethodSelectorProps {
  onMethodSelect: (method: AuthMethod) => void;
}

export const AuthenticationMethodSelector: React.FC<AuthMethodSelectorProps> = ({
  onMethodSelect
}) => {
  const [selectedMethod, setSelectedMethod] = useState<AuthMethod | null>(null);

  const authMethods = [
    {
      id: 'email' as AuthMethod,
      title: 'Email & Password',
      description: 'Traditional registration with email verification',
      icon: '📧',
      recommended: false
    },
    {
      id: 'social' as AuthMethod,
      title: 'Social Authentication',
      description: 'Quick sign-up with Google, Facebook, or LinkedIn',
      icon: '🔗',
      recommended: true
    },
    {
      id: 'phone' as AuthMethod,
      title: 'Phone Number',
      description: 'SMS-based verification and authentication',
      icon: '📱',
      recommended: false
    }
  ];

  const handleMethodSelect = (method: AuthMethod) => {
    setSelectedMethod(method);
    onMethodSelect(method);
  };

  return (
    <div className="auth-method-selector">
      <h2>Choose Your Sign-Up Method</h2>
      <p>Select the method that works best for you</p>
      
      <div className="method-grid">
        {authMethods.map((method) => (
          <div
            key={method.id}
            className={`method-card ${selectedMethod === method.id ? 'selected' : ''} ${method.recommended ? 'recommended' : ''}`}
            onClick={() => handleMethodSelect(method.id)}
          >
            <div className="method-icon">{method.icon}</div>
            <h3>{method.title}</h3>
            <p>{method.description}</p>
            {method.recommended && <span className="recommended-badge">Recommended</span>}
          </div>
        ))}
      </div>
    </div>
  );
};
```

### **Profile Creation Component Architecture**

#### **Auto-Save Hook Implementation**
```typescript
// hooks/useAutoSave.ts
import { useEffect, useCallback, useState } from 'react';
import { debounce } from 'lodash';
import { profileAPI } from '../services/profile.api';

interface UseAutoSaveOptions {
  step: number;
  data: any;
  enabled?: boolean;
  interval?: number;
}

export const useAutoSave = ({ step, data, enabled = true, interval = 30000 }: UseAutoSaveOptions) => {
  const [saveStatus, setSaveStatus] = useState<'idle' | 'saving' | 'saved' | 'error'>('idle');
  const [lastSaved, setLastSaved] = useState<Date | null>(null);

  const saveData = useCallback(async () => {
    if (!enabled || !data) return;

    setSaveStatus('saving');
    try {
      await profileAPI.autoSave(step, data);
      setSaveStatus('saved');
      setLastSaved(new Date());
    } catch (error) {
      setSaveStatus('error');
      console.error('Auto-save failed:', error);
    }
  }, [step, data, enabled]);

  // Debounced save function to avoid excessive API calls
  const debouncedSave = useCallback(
    debounce(saveData, 2000), // Wait 2 seconds after last change
    [saveData]
  );

  // Auto-save on data changes
  useEffect(() => {
    if (enabled && data) {
      debouncedSave();
    }
  }, [data, enabled, debouncedSave]);

  // Periodic auto-save
  useEffect(() => {
    if (!enabled) return;

    const intervalId = setInterval(saveData, interval);
    return () => clearInterval(intervalId);
  }, [saveData, interval, enabled]);

  // Save on page unload
  useEffect(() => {
    const handleBeforeUnload = () => {
      if (enabled && data) {
        // Use sendBeacon for reliable saving on page unload
        navigator.sendBeacon('/api/v1/profiles/auto-save', JSON.stringify({ step, data }));
      }
    };

    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => window.removeEventListener('beforeunload', handleBeforeUnload);
  }, [step, data, enabled]);

  return {
    saveStatus,
    lastSaved,
    forceSave: saveData
  };
};
```

#### **Profile Type Selector Component**
```typescript
// ProfileTypeSelector.tsx
import React, { useState } from 'react';
import { ProfileType } from '../types/profile.types';
import { profileCardTheme } from '../theme/profileCardTheme';

interface ProfileTypeSelectorProps {
  onTypeSelect: (type: ProfileType) => void;
  selectedType?: ProfileType;
}

export const ProfileTypeSelector: React.FC<ProfileTypeSelectorProps> = ({
  onTypeSelect,
  selectedType
}) => {
  const [hoveredType, setHoveredType] = useState<ProfileType | null>(null);

  const profileTypes = [
    {
      id: 'innovator' as ProfileType,
      title: 'Innovator',
      emoji: '🚀',
      description: 'I have innovative ideas and need funding, mentorship, or team members',
      benefits: ['Showcase projects', 'Find funding', 'Build teams', 'Access mentorship'],
      idealFor: 'Entrepreneurs, startup founders, people developing new solutions'
    },
    {
      id: 'business_investor' as ProfileType,
      title: 'Business Investor',
      emoji: '💰',
      description: 'I invest in startups and innovative projects',
      benefits: ['Discover startups', 'Evaluate opportunities', 'Connect with entrepreneurs'],
      idealFor: 'Angel investors, VCs, funding organizations'
    },
    // ... other profile types
  ];

  const getProfileTypeColor = (type: ProfileType) => {
    return profileCardTheme.profileTypeColors[type] || '#4CAF50';
  };

  return (
    <div className="profile-type-selector">
      <h2>What Best Describes You?</h2>
      <p>Choose the profile type that best matches your goals and interests</p>

      <div className="profile-type-grid">
        {profileTypes.map((type) => (
          <div
            key={type.id}
            className={`profile-type-card ${selectedType === type.id ? 'selected' : ''}`}
            onClick={() => onTypeSelect(type.id)}
            onMouseEnter={() => setHoveredType(type.id)}
            onMouseLeave={() => setHoveredType(null)}
            style={{
              backgroundColor: profileCardTheme.card.background,
              borderRadius: profileCardTheme.card.borderRadius,
              boxShadow: profileCardTheme.card.boxShadow,
              padding: profileCardTheme.card.padding,
            }}
          >
            <div className="type-header">
              <span className="type-emoji">{type.emoji}</span>
              <h3>{type.title}</h3>
              <span
                className="type-label"
                style={{
                  backgroundColor: getProfileTypeColor(type.id),
                  color: '#FFFFFF',
                  padding: '4px 12px',
                  borderRadius: '16px',
                  fontSize: '12px',
                  fontWeight: 500,
                }}
              >
                {type.title}
              </span>
            </div>

            <p className="type-description">{type.description}</p>

            {(hoveredType === type.id || selectedType === type.id) && (
              <div className="type-details">
                <div className="benefits">
                  <h4>Benefits:</h4>
                  <ul>
                    {type.benefits.map((benefit, index) => (
                      <li key={index}>{benefit}</li>
                    ))}
                  </ul>
                </div>
                <div className="ideal-for">
                  <h4>Ideal For:</h4>
                  <p>{type.idealFor}</p>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      {selectedType && (
        <div className="selection-confirmation">
          <p>You've selected: <strong>{profileTypes.find(t => t.id === selectedType)?.title}</strong></p>
          <p className="change-note">You can change this later if needed</p>
        </div>
      )}
    </div>
  );
};
```

## 🧪 **Testing Implementation Guidelines**

### **Backend Testing Requirements**
```java
// AuthenticationServiceTest.java
@SpringBootTest
@Transactional
class AuthenticationServiceTest {
    
    @Test
    void shouldCreateUserWithEmailAuthentication() {
        EmailRegistrationRequest request = EmailRegistrationRequest.builder()
            .email("test@example.com")
            .password("SecurePassword123!")
            .firstName("John")
            .lastName("Doe")
            .build();
        
        AuthenticationResponse response = authenticationService.registerWithEmail(request);
        
        assertThat(response.getUserId()).isNotNull();
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        assertThat(response.isRequiresEmailVerification()).isTrue();
        
        // Verify database record
        PersonalDetails user = personalDetailsRepository.findById(response.getUserId()).orElseThrow();
        assertThat(user.getEmail()).isEqualTo("test@example.com");
        assertThat(user.getProfileCreationStep()).isEqualTo(0);
        assertThat(user.getProfileCompletion()).isEqualTo(0);
    }
    
    @Test
    void shouldAutoSaveProfileData() {
        String userId = createTestUser();
        PersonalInformation personalInfo = PersonalInformation.builder()
            .firstName("Jane")
            .lastName("Smith")
            .build();
        
        profileCreationService.autoSaveStep(userId, 2, personalInfo);
        
        ProfileCreationState state = profileCreationService.getProfileCreationState(userId);
        assertThat(state.getStepData()).containsKey(2);
        assertThat(state.getLastAutoSave()).isNotNull();
    }
}
```

### **Frontend Testing Requirements**
```typescript
// ProfileTypeSelector.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { ProfileTypeSelector } from './ProfileTypeSelector';

describe('ProfileTypeSelector', () => {
  const mockOnTypeSelect = jest.fn();

  beforeEach(() => {
    mockOnTypeSelect.mockClear();
  });

  test('renders all profile types', () => {
    render(<ProfileTypeSelector onTypeSelect={mockOnTypeSelect} />);
    
    expect(screen.getByText('Innovator')).toBeInTheDocument();
    expect(screen.getByText('Business Investor')).toBeInTheDocument();
    // ... test for all 8 profile types
  });

  test('calls onTypeSelect when profile type is clicked', () => {
    render(<ProfileTypeSelector onTypeSelect={mockOnTypeSelect} />);
    
    fireEvent.click(screen.getByText('Innovator'));
    
    expect(mockOnTypeSelect).toHaveBeenCalledWith('innovator');
  });

  test('shows selection confirmation when type is selected', () => {
    render(<ProfileTypeSelector onTypeSelect={mockOnTypeSelect} selectedType="innovator" />);
    
    expect(screen.getByText(/You've selected: Innovator/)).toBeInTheDocument();
    expect(screen.getByText(/You can change this later/)).toBeInTheDocument();
  });
});
```

---

## 📚 **Reference Implementation**

**Process Flow Documentation**: See `/1_planning_and_requirements/2_user_journeys/16_authentication_and_profile_creation_process_flows.md`
**JIRA Workflow**: See `/3_development_setup/18_process_flow_jira_workflow.md`
**Database Schema**: See `/2_technical_architecture/2_database_schema_and_design.md`
**API Specifications**: See `/2_technical_architecture/6_api_specifications/`

*These implementation guidelines ensure consistent, scalable development of the authentication and profile creation process flows across both frontend and backend teams.*
