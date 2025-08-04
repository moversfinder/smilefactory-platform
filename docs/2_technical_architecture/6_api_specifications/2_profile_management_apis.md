# 2. Profile Management APIs

## 👤 **Profile Management Overview**

The Profile Management APIs handle all aspects of user profile creation, updates, and management for the 8 different profile types in the ZbInnovation platform. These APIs support dynamic profile forms, completion tracking, and type-specific functionality.

## 🏗️ **Profile Architecture**

### **Profile Type System**
```typescript
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

interface BaseProfile {
  userId: string;
  profileType: ProfileType;
  completionPercentage: number;
  profileState: 'DRAFT' | 'INCOMPLETE' | 'COMPLETE';
  visibility: 'PUBLIC' | 'PRIVATE' | 'CONNECTIONS_ONLY';
}
```

### **Profile Completion Scoring**
```typescript
interface ProfileCompletionScoring {
  basicInformation: 20; // Name, email, phone, photo
  profileSpecificInfo: 40; // Type-specific fields
  socialInformation: 25; // Bio, location, social links
  engagementInfo: 15; // First post, connections, activity
}
```

## 📋 **Core Profile Management Endpoints**

### **1. Get Current User Profile**
```http
GET /api/v1/profiles/me
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "userId": "uuid-string",
    "profileType": "innovator",
    "basicInfo": {
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@example.com",
      "phone": "+263123456789",
      "profilePhoto": "https://cdn.zbinnovation.com/photos/user123.jpg"
    },
    "profileSpecific": {
      "industry": "Technology",
      "innovationStage": "MVP",
      "startupName": "TechCorp",
      "fundingNeeded": 50000
    },
    "socialInfo": {
      "bio": "Passionate innovator building the future",
      "location": "Harare, Zimbabwe",
      "website": "https://techcorp.com",
      "linkedIn": "https://linkedin.com/in/johndoe"
    },
    "completionPercentage": 85,
    "profileState": "COMPLETE",
    "visibility": "PUBLIC",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-20T14:45:00Z"
  }
}
```

### **2. Update Current User Profile**
```http
PUT /api/v1/profiles/me
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "basicInfo": {
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+263123456789"
  },
  "profileSpecific": {
    "industry": "Technology",
    "innovationStage": "Scaling",
    "fundingNeeded": 100000
  },
  "socialInfo": {
    "bio": "Updated bio with new achievements",
    "website": "https://newtechcorp.com"
  }
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "userId": "uuid-string",
    "completionPercentage": 90,
    "profileState": "COMPLETE",
    "updatedFields": ["profileSpecific.innovationStage", "profileSpecific.fundingNeeded", "socialInfo.bio", "socialInfo.website"],
    "updatedAt": "2024-01-20T15:30:00Z"
  }
}
```

### **3. Get User Profile by ID**
```http
GET /api/v1/profiles/{userId}
Authorization: Bearer {access-token}
```

**Response (200 OK)** - Returns public profile information based on visibility settings:
```json
{
  "success": true,
  "data": {
    "userId": "uuid-string",
    "profileType": "innovator",
    "publicInfo": {
      "firstName": "John",
      "lastName": "Doe",
      "profilePhoto": "https://cdn.zbinnovation.com/photos/user123.jpg",
      "bio": "Passionate innovator building the future",
      "location": "Harare, Zimbabwe"
    },
    "professionalInfo": {
      "industry": "Technology",
      "innovationStage": "Scaling",
      "startupName": "TechCorp"
    },
    "connectionStatus": "CONNECTED",
    "mutualConnections": 5,
    "profileViews": 150,
    "isVerified": true
  }
}
```

## 🎯 **Profile Type-Specific Endpoints**

### **4. Create/Update Innovator Profile**
```http
POST /api/v1/profiles/innovator
PUT /api/v1/profiles/innovator
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "industry": "Technology",
  "innovationStage": "MVP",
  "startupName": "TechCorp",
  "startupDescription": "Revolutionary AI platform",
  "fundingAmountNeeded": 50000,
  "teamSize": 3,
  "businessModel": "SaaS subscription",
  "targetMarket": "SME businesses",
  "competitiveAdvantage": "Proprietary AI algorithms",
  "intellectualProperty": ["Patent pending AI algorithm"],
  "currentChallenges": ["Market validation", "Team expansion"],
  "achievements": ["MVP completed", "First customers acquired"]
}
```

### **5. Create/Update Business Investor Profile**
```http
POST /api/v1/profiles/investor
PUT /api/v1/profiles/investor
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "investmentFocus": ["Technology", "Healthcare", "Fintech"],
  "investmentStagePreference": ["Seed", "Series A"],
  "ticketSizeMin": 10000,
  "ticketSizeMax": 500000,
  "geographicFocus": ["Zimbabwe", "Southern Africa"],
  "portfolioCompanies": ["TechStart", "HealthCorp", "FinanceApp"],
  "investmentCriteria": "Strong team, scalable business model",
  "dueDiligenceProcess": "3-stage evaluation process",
  "investmentPhilosophy": "Long-term value creation",
  "exitStrategy": "IPO or strategic acquisition"
}
```

### **6. Create/Update Mentor Profile**
```http
POST /api/v1/profiles/mentor
PUT /api/v1/profiles/mentor
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "expertiseAreas": ["Business Strategy", "Product Development", "Fundraising"],
  "mentoringExperienceYears": 10,
  "mentoringApproach": "Hands-on guidance with regular check-ins",
  "availabilityHoursPerMonth": 20,
  "preferredCommunicationMethods": ["Video calls", "In-person meetings"],
  "successStories": "Helped 15+ startups raise funding",
  "mentoringPhilosophy": "Empowering entrepreneurs to achieve their vision",
  "industryExperience": ["Technology", "Finance"],
  "currentMentees": 5,
  "maxMentees": 10
}
```

## 📊 **Profile Analytics and Management**

### **7. Get Profile Analytics**
```http
GET /api/v1/profiles/analytics
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "profileViews": {
      "total": 150,
      "thisWeek": 25,
      "thisMonth": 80
    },
    "connectionRequests": {
      "received": 12,
      "sent": 8,
      "accepted": 15
    },
    "contentEngagement": {
      "postsCreated": 5,
      "totalLikes": 45,
      "totalComments": 20
    },
    "searchAppearances": {
      "total": 75,
      "keywords": ["innovation", "technology", "startup"]
    },
    "completionScore": 90,
    "profileStrength": "STRONG"
  }
}
```

### **8. Update Profile Visibility**
```http
PUT /api/v1/profiles/visibility
Authorization: Bearer {access-token}
Content-Type: application/json

{
  "visibility": "PUBLIC",
  "showEmail": false,
  "showPhone": false,
  "showLocation": true,
  "showConnections": true,
  "searchable": true
}
```

### **9. Get Profile Completion Status**
```http
GET /api/v1/profiles/completion
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "completionPercentage": 85,
    "profileState": "COMPLETE",
    "completedSections": {
      "basicInformation": 20,
      "profileSpecific": 35,
      "socialInformation": 25,
      "engagement": 5
    },
    "missingSections": [
      {
        "section": "profileSpecific",
        "missingFields": ["achievements"],
        "points": 5
      }
    ],
    "recommendations": [
      "Add your recent achievements to boost profile strength",
      "Upload a professional profile photo",
      "Connect with more professionals in your industry"
    ],
    "nextMilestone": {
      "percentage": 90,
      "benefits": ["Enhanced search visibility", "Priority in recommendations"]
    }
  }
}
```

## 🔍 **Profile Search and Discovery**

### **10. Search User Profiles**
```http
GET /api/v1/profiles/search
Authorization: Bearer {access-token}
Query Parameters:
- q: Search query
- profileType: Filter by profile type
- location: Filter by location
- industry: Filter by industry
- page: Page number
- limit: Results per page
```

**Example Request**:
```http
GET /api/v1/profiles/search?q=technology&profileType=innovator&location=Harare&page=1&limit=20
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "profiles": [
      {
        "userId": "uuid-1",
        "firstName": "John",
        "lastName": "Doe",
        "profileType": "innovator",
        "profilePhoto": "https://cdn.zbinnovation.com/photos/user1.jpg",
        "bio": "Tech innovator building AI solutions",
        "location": "Harare, Zimbabwe",
        "industry": "Technology",
        "connectionStatus": "NOT_CONNECTED",
        "mutualConnections": 3,
        "relevanceScore": 0.95
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3
    },
    "filters": {
      "appliedFilters": {
        "profileType": "innovator",
        "location": "Harare"
      },
      "availableFilters": {
        "industries": ["Technology", "Healthcare", "Finance"],
        "locations": ["Harare", "Bulawayo", "Mutare"]
      }
    }
  }
}
```

## 🔒 **Profile Security and Validation**

### **Input Validation Rules**
```typescript
interface ProfileValidation {
  basicInfo: {
    firstName: { required: true, minLength: 2, maxLength: 50 };
    lastName: { required: true, minLength: 2, maxLength: 50 };
    email: { required: true, format: 'email', unique: true };
    phone: { format: 'international', optional: true };
  };
  profileSpecific: {
    // Validation rules vary by profile type
    industry: { required: true, enum: VALID_INDUSTRIES };
    fundingNeeded: { type: 'number', min: 1000, max: 10000000 };
  };
  socialInfo: {
    bio: { maxLength: 500, optional: true };
    website: { format: 'url', optional: true };
    linkedIn: { format: 'linkedin-url', optional: true };
  };
}
```

### **Privacy Controls**
- **Profile Visibility**: Control who can see profile information
- **Contact Information**: Granular control over email/phone visibility
- **Search Visibility**: Option to appear in search results
- **Connection Privacy**: Control who can send connection requests

## 📈 **Profile Optimization Features**

### **11. Get Profile Suggestions**
```http
GET /api/v1/profiles/suggestions
Authorization: Bearer {access-token}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "profileOptimization": [
      {
        "type": "MISSING_FIELD",
        "field": "achievements",
        "impact": "HIGH",
        "description": "Adding achievements increases profile views by 40%"
      },
      {
        "type": "PHOTO_QUALITY",
        "impact": "MEDIUM", 
        "description": "Professional photos get 60% more connection requests"
      }
    ],
    "connectionSuggestions": [
      {
        "userId": "uuid-2",
        "reason": "Similar industry and location",
        "mutualConnections": 5
      }
    ],
    "contentSuggestions": [
      {
        "type": "FIRST_POST",
        "description": "Share your innovation story to increase visibility"
      }
    ]
  }
}
```

---

## 📚 **Reference Documents**

**Authentication**: See `/2_technical_architecture/api_specifications/1_authentication_apis.md`
**Database Schema**: See `/2_technical_architecture/2_database_schema_and_design.md`
**User Requirements**: See `/1_planning_and_requirements/2_user_requirements_and_journeys.md`
**Frontend Forms**: See `/5_frontend_implementation/3_form_handling_and_validation.md`

*These profile management APIs provide comprehensive user profile functionality for all 8 profile types in the ZbInnovation platform.*
