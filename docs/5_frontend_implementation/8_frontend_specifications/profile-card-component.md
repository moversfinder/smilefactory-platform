# Profile Card Component Specification

## 🎯 **Overview**

This document specifies the standardized profile card component design based on the "Test Profile" reference. All profile cards must use identical styling with only the profile type label having different colors.

## 🎨 **Visual Design Specification**

### **Card Container**
```css
.profile-card {
  background: #FFFFFF;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 24px;
  border: none;
  transition: box-shadow 0.2s ease;
}

.profile-card:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}
```

### **Avatar Section**
```css
.profile-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background-color: #4CAF50; /* Green for ALL profiles */
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px auto;
}

.profile-avatar-text {
  color: #FFFFFF;
  font-size: 24px;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
}
```

### **Profile Information**
```css
.profile-name {
  color: #212121;
  font-size: 20px;
  font-weight: 600;
  text-align: center;
  margin-bottom: 4px;
  font-family: 'Roboto', sans-serif;
}

.profile-summary {
  color: #757575;
  font-size: 14px;
  font-weight: 400;
  text-align: center;
  margin-bottom: 16px;
  font-family: 'Roboto', sans-serif;
}
```

### **Profile Type Label** (Only element with varying colors)
```css
.profile-type-label {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 500;
  text-align: center;
  margin-bottom: 8px;
  font-family: 'Roboto', sans-serif;
}

/* Profile type specific colors */
.profile-type-label.innovator {
  background-color: #4CAF50;
  color: #FFFFFF;
}

.profile-type-label.business-investor {
  background-color: #2196F3;
  color: #FFFFFF;
}

.profile-type-label.mentor {
  background-color: #9C27B0;
  color: #FFFFFF;
}

.profile-type-label.professional {
  background-color: #009688;
  color: #FFFFFF;
}

.profile-type-label.industry-expert {
  background-color: #3F51B5;
  color: #FFFFFF;
}

.profile-type-label.academic-student {
  background-color: #2196F3;
  color: #FFFFFF;
}

.profile-type-label.academic-institution {
  background-color: #673AB7;
  color: #FFFFFF;
}

.profile-type-label.organisation {
  background-color: #1976D2;
  color: #FFFFFF;
}
```

### **Completion Badge**
```css
.completion-badge {
  background-color: #4CAF50; /* Green for ALL profiles */
  color: #FFFFFF;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  display: inline-block;
  margin-left: 8px;
  font-family: 'Roboto', sans-serif;
}
```

### **Action Button**
```css
.profile-view-button {
  background-color: transparent;
  color: #4CAF50; /* Green for ALL profiles */
  border: 1px solid #4CAF50;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  width: 100%;
  margin-top: 16px;
  font-family: 'Roboto', sans-serif;
}

.profile-view-button:hover {
  background-color: #4CAF50;
  color: #FFFFFF;
}
```

## 🔧 **React Component Implementation**

### **TypeScript Interface**
```typescript
interface ProfileCardProps {
  profile: {
    id: string;
    firstName: string;
    lastName: string;
    profileType: ProfileType;
    summary: string;
    completionPercentage: number;
    profilePhoto?: string;
  };
  onViewProfile: (profileId: string) => void;
}

enum ProfileType {
  INNOVATOR = 'innovator',
  BUSINESS_INVESTOR = 'business_investor',
  MENTOR = 'mentor',
  PROFESSIONAL = 'professional',
  INDUSTRY_EXPERT = 'industry_expert',
  ACADEMIC_STUDENT = 'academic_student',
  ACADEMIC_INSTITUTION = 'academic_institution',
  ORGANISATION = 'organisation'
}
```

### **React Component**
```typescript
import React from 'react';
import { Card, CardContent, Avatar, Typography, Button, Chip, Box } from '@mui/material';
import { styled } from '@mui/material/styles';

const StyledCard = styled(Card)(({ theme }) => ({
  backgroundColor: '#FFFFFF',
  borderRadius: '12px',
  boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)',
  padding: '24px',
  border: 'none',
  transition: 'box-shadow 0.2s ease',
  '&:hover': {
    boxShadow: '0 4px 16px rgba(0, 0, 0, 0.15)',
  },
}));

const StyledAvatar = styled(Avatar)(({ theme }) => ({
  width: 80,
  height: 80,
  backgroundColor: '#4CAF50', // Green for ALL profiles
  color: '#FFFFFF',
  fontSize: '24px',
  fontWeight: 600,
  margin: '0 auto 16px auto',
}));

const ProfileTypeChip = styled(Chip)<{ profiletype: ProfileType }>(({ theme, profiletype }) => {
  const getProfileTypeColor = (type: ProfileType) => {
    const colors = {
      [ProfileType.INNOVATOR]: '#4CAF50',
      [ProfileType.BUSINESS_INVESTOR]: '#2196F3',
      [ProfileType.MENTOR]: '#9C27B0',
      [ProfileType.PROFESSIONAL]: '#009688',
      [ProfileType.INDUSTRY_EXPERT]: '#3F51B5',
      [ProfileType.ACADEMIC_STUDENT]: '#2196F3',
      [ProfileType.ACADEMIC_INSTITUTION]: '#673AB7',
      [ProfileType.ORGANISATION]: '#1976D2',
    };
    return colors[type] || '#4CAF50';
  };

  return {
    backgroundColor: getProfileTypeColor(profiletype),
    color: '#FFFFFF',
    fontSize: '12px',
    fontWeight: 500,
    marginBottom: '8px',
  };
});

const CompletionChip = styled(Chip)(({ theme }) => ({
  backgroundColor: '#4CAF50', // Green for ALL profiles
  color: '#FFFFFF',
  fontSize: '12px',
  fontWeight: 500,
  marginLeft: '8px',
}));

const ViewButton = styled(Button)(({ theme }) => ({
  backgroundColor: 'transparent',
  color: '#4CAF50', // Green for ALL profiles
  border: '1px solid #4CAF50',
  borderRadius: '6px',
  fontSize: '14px',
  fontWeight: 500,
  width: '100%',
  marginTop: '16px',
  '&:hover': {
    backgroundColor: '#4CAF50',
    color: '#FFFFFF',
  },
}));

export const ProfileCard: React.FC<ProfileCardProps> = ({ profile, onViewProfile }) => {
  const getInitials = (firstName: string, lastName: string) => {
    return `${firstName.charAt(0)}${lastName.charAt(0)}`.toUpperCase();
  };

  const getProfileTypeLabel = (type: ProfileType) => {
    const labels = {
      [ProfileType.INNOVATOR]: 'Innovator',
      [ProfileType.BUSINESS_INVESTOR]: 'Business Investor',
      [ProfileType.MENTOR]: 'Mentor',
      [ProfileType.PROFESSIONAL]: 'Professional',
      [ProfileType.INDUSTRY_EXPERT]: 'Industry Expert',
      [ProfileType.ACADEMIC_STUDENT]: 'Academic Student',
      [ProfileType.ACADEMIC_INSTITUTION]: 'Academic Institution',
      [ProfileType.ORGANISATION]: 'Organisation',
    };
    return labels[type] || 'User';
  };

  return (
    <StyledCard>
      <CardContent sx={{ textAlign: 'center', padding: 0 }}>
        <StyledAvatar>
          {profile.profilePhoto ? (
            <img src={profile.profilePhoto} alt={`${profile.firstName} ${profile.lastName}`} />
          ) : (
            getInitials(profile.firstName, profile.lastName)
          )}
        </StyledAvatar>
        
        <Typography
          variant="h6"
          sx={{
            color: '#212121',
            fontSize: '20px',
            fontWeight: 600,
            marginBottom: '4px',
          }}
        >
          {profile.firstName} {profile.lastName}
        </Typography>
        
        <Typography
          variant="body2"
          sx={{
            color: '#757575',
            fontSize: '14px',
            marginBottom: '16px',
          }}
        >
          {profile.summary}
        </Typography>
        
        <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', marginBottom: '16px' }}>
          <ProfileTypeChip
            label={getProfileTypeLabel(profile.profileType)}
            profiletype={profile.profileType}
            size="small"
          />
          <CompletionChip
            label={`${profile.completionPercentage}% Complete`}
            size="small"
          />
        </Box>
        
        <ViewButton onClick={() => onViewProfile(profile.id)}>
          VIEW PROFILE
        </ViewButton>
      </CardContent>
    </StyledCard>
  );
};
```

## 📱 **Responsive Design**

### **Mobile Adaptations**
```css
@media (max-width: 768px) {
  .profile-card {
    padding: 16px;
    margin-bottom: 16px;
  }
  
  .profile-avatar {
    width: 60px;
    height: 60px;
  }
  
  .profile-avatar-text {
    font-size: 20px;
  }
  
  .profile-name {
    font-size: 18px;
  }
}
```

## ✅ **Implementation Checklist**

### **Design Consistency**
- [ ] All profile cards use white (#FFFFFF) background
- [ ] All avatars use green (#4CAF50) background
- [ ] All completion badges use green (#4CAF50) background
- [ ] All action buttons use green (#4CAF50) color scheme
- [ ] Only profile type labels use different colors per type

### **Component Features**
- [ ] Hover effects implemented
- [ ] Responsive design for mobile devices
- [ ] Accessibility features (ARIA labels, keyboard navigation)
- [ ] Loading states for profile data
- [ ] Error handling for missing profile information

### **Testing Requirements**
- [ ] Visual regression tests for all profile types
- [ ] Accessibility testing with screen readers
- [ ] Mobile responsiveness testing
- [ ] Color contrast validation for all profile type labels

---

*This standardized profile card design ensures visual consistency across the platform while maintaining profile type identification through the colored labels.*
