# 6. Profile Type Specifications

## 👥 **Profile Type Overview**

This document outlines the detailed specifications for all 8 profile types in the SmileFactory platform, including unique features, dashboard widgets, AI assistance, and specific functionality for each user type.

## 🚀 **1. Innovator Profile**

### **Core Features**
- **Startup Management**: Track startup progress, milestones, and metrics
- **Funding Pipeline**: Manage funding rounds, investor communications
- **Team Building**: Find co-founders, employees, and advisors
- **Pitch Deck Management**: Upload, version, and share pitch materials

### **Dashboard Widgets**
```typescript
interface InnovatorDashboard {
  fundingProgress: {
    currentRound: string;
    targetAmount: number;
    raisedAmount: number;
    investorCount: number;
  };
  startupMetrics: {
    revenue: number;
    users: number;
    growth: number;
    burnRate: number;
  };
  teamStatus: {
    currentTeamSize: number;
    openPositions: number;
    recentApplications: number;
  };
  upcomingMilestones: Milestone[];
  recommendedOpportunities: Opportunity[];
}
```

### **AI Assistance Features**
- **Funding Guidance**: "Help me find investors for my fintech startup"
- **Team Building**: "Find a technical co-founder with blockchain experience"
- **Market Analysis**: "Analyze the competition in my industry"
- **Pitch Optimization**: "Review my pitch deck and suggest improvements"
- **Milestone Planning**: "Create a roadmap for the next 6 months"

### **Unique Permissions**
- Create funding requests
- Post in investor matching
- Access startup resources
- Join accelerator programs

## 💼 **2. Business Investor Profile**

### **Core Features**
- **Deal Flow Management**: Track investment opportunities and pipeline
- **Portfolio Tracking**: Monitor invested companies and returns
- **Due Diligence Tools**: Access to startup financials and metrics
- **Investment Analytics**: Performance tracking and reporting

### **Dashboard Widgets**
```typescript
interface BusinessInvestorDashboard {
  portfolioOverview: {
    totalInvestments: number;
    activeDeals: number;
    portfolioValue: number;
    roi: number;
  };
  dealPipeline: {
    newOpportunities: number;
    underReview: number;
    dueDiligence: number;
    readyToInvest: number;
  };
  portfolioCompanies: PortfolioCompany[];
  marketInsights: MarketTrend[];
  upcomingEvents: InvestorEvent[];
}
```

### **AI Assistance Features**
- **Deal Sourcing**: "Find AI startups seeking Series A funding"
- **Due Diligence**: "Analyze this startup's financial projections"
- **Market Research**: "What's the market size for fintech in Zimbabwe?"
- **Portfolio Management**: "How is my portfolio performing this quarter?"
- **Risk Assessment**: "Evaluate the risks of this investment"

### **Unique Permissions**
- Access startup financials
- Participate in funding rounds
- View detailed startup metrics
- Connect with other investors

## 🎓 **3. Mentor Profile**

### **Core Features**
- **Mentee Management**: Track mentoring relationships and progress
- **Knowledge Sharing**: Create content, guides, and resources
- **Session Scheduling**: Manage mentoring sessions and availability
- **Impact Tracking**: Monitor mentee success and outcomes

### **Dashboard Widgets**
```typescript
interface MentorDashboard {
  mentoringStats: {
    activeMentees: number;
    totalSessions: number;
    averageRating: number;
    impactScore: number;
  };
  upcomingSessions: MentoringSession[];
  menteeProgress: MenteeProgress[];
  contentPerformance: ContentMetrics[];
  mentoringRequests: MentoringRequest[];
}
```

### **AI Assistance Features**
- **Mentee Matching**: "Find mentees who need guidance in fintech"
- **Content Creation**: "Help me create a guide on startup fundraising"
- **Session Planning**: "Suggest topics for my next mentoring session"
- **Impact Analysis**: "How can I improve my mentoring effectiveness?"
- **Resource Recommendations**: "What resources should I share with my mentees?"

## 🏛️ **4. Government Official Profile**

### **Core Features**
- **Policy Development**: Create and manage innovation policies
- **Ecosystem Monitoring**: Track innovation ecosystem health
- **Program Management**: Oversee government innovation programs
- **Stakeholder Engagement**: Connect with private sector and academia

### **Dashboard Widgets**
```typescript
interface GovernmentOfficialDashboard {
  ecosystemHealth: {
    startupCount: number;
    jobsCreated: number;
    investmentVolume: number;
    exportValue: number;
  };
  programMetrics: GovernmentProgram[];
  policyImpact: PolicyMetric[];
  stakeholderEngagement: EngagementMetric[];
  upcomingInitiatives: Initiative[];
}
```

### **AI Assistance Features**
- **Policy Analysis**: "Analyze the impact of our startup tax incentives"
- **Ecosystem Insights**: "What are the key challenges facing our innovation ecosystem?"
- **Program Optimization**: "How can we improve our incubator program?"
- **Stakeholder Mapping**: "Identify key stakeholders for our new initiative"

## 🏢 **5. Corporate Partner Profile**

### **Core Features**
- **Innovation Scouting**: Discover startups for partnerships
- **Partnership Management**: Track corporate-startup collaborations
- **Procurement Opportunities**: Post corporate procurement needs
- **Innovation Challenges**: Host innovation competitions

### **Dashboard Widgets**
```typescript
interface CorporatePartnerDashboard {
  partnershipPortfolio: {
    activePartnerships: number;
    pilotPrograms: number;
    successfulIntegrations: number;
    totalInvestment: number;
  };
  innovationPipeline: StartupMatch[];
  procurementOpportunities: ProcurementListing[];
  challengeMetrics: ChallengeMetric[];
  industryInsights: IndustryTrend[];
}
```

### **AI Assistance Features**
- **Startup Discovery**: "Find startups working on supply chain automation"
- **Partnership Strategy**: "Suggest partnership models for our innovation goals"
- **Market Intelligence**: "What emerging technologies should we watch?"
- **Procurement Matching**: "Match our procurement needs with startup solutions"

## 🎓 **6. Academic Researcher Profile**

### **Core Features**
- **Research Collaboration**: Connect with industry for research projects
- **Technology Transfer**: Commercialize research findings
- **Student Engagement**: Connect students with industry opportunities
- **Publication Management**: Track research publications and impact

### **Dashboard Widgets**
```typescript
interface AcademicResearcherDashboard {
  researchMetrics: {
    activeProjects: number;
    publications: number;
    citations: number;
    collaborations: number;
  };
  industryConnections: IndustryCollaboration[];
  studentPlacements: StudentPlacement[];
  technologyTransfer: TechTransferOpportunity[];
  fundingOpportunities: ResearchGrant[];
}
```

### **AI Assistance Features**
- **Research Collaboration**: "Find industry partners for my AI research"
- **Technology Transfer**: "How can I commercialize my research findings?"
- **Grant Opportunities**: "Find funding for my renewable energy research"
- **Student Connections**: "Connect my students with relevant internships"

## 🌍 **7. Development Partner Profile**

### **Core Features**
- **Program Implementation**: Manage development programs and initiatives
- **Impact Measurement**: Track social and economic impact
- **Beneficiary Management**: Connect with program beneficiaries
- **Resource Allocation**: Optimize resource distribution

### **Dashboard Widgets**
```typescript
interface DevelopmentPartnerDashboard {
  programImpact: {
    beneficiariesReached: number;
    programsActive: number;
    fundingDeployed: number;
    impactScore: number;
  };
  activePrograms: DevelopmentProgram[];
  impactMetrics: ImpactMetric[];
  beneficiaryFeedback: Feedback[];
  partnershipOpportunities: Partnership[];
}
```

### **AI Assistance Features**
- **Impact Analysis**: "Analyze the impact of our entrepreneurship program"
- **Beneficiary Matching**: "Find entrepreneurs who would benefit from our program"
- **Program Optimization**: "How can we improve our program effectiveness?"
- **Partnership Strategy**: "Identify potential implementation partners"

## 🎯 **8. Service Provider Profile**

### **Core Features**
- **Service Marketplace**: List and promote professional services
- **Client Management**: Track client relationships and projects
- **Expertise Showcase**: Demonstrate capabilities and experience
- **Network Building**: Connect with potential clients and partners

### **Dashboard Widgets**
```typescript
interface ServiceProviderDashboard {
  businessMetrics: {
    activeClients: number;
    projectsCompleted: number;
    revenue: number;
    clientSatisfaction: number;
  };
  servicePerformance: ServiceMetric[];
  clientPipeline: ClientOpportunity[];
  marketingMetrics: MarketingMetric[];
  networkingOpportunities: NetworkingEvent[];
}
```

### **AI Assistance Features**
- **Client Discovery**: "Find startups needing legal services"
- **Service Optimization**: "How can I improve my service offerings?"
- **Market Positioning**: "Position my consulting services in the market"
- **Networking Strategy**: "Find networking opportunities in my industry"

## 🎨 **Profile-Specific UI Components**

### **Dynamic Dashboard Layout**
```typescript
// Profile-specific dashboard component
export const ProfileDashboard: React.FC<{ profileType: ProfileType }> = ({ profileType }) => {
  const getDashboardConfig = (type: ProfileType) => {
    const configs = {
      [ProfileType.INNOVATOR]: {
        widgets: ['fundingProgress', 'startupMetrics', 'teamStatus', 'milestones'],
        layout: 'startup-focused',
        aiTriggers: ['funding', 'team', 'mentorship'],
      },
      [ProfileType.BUSINESS_INVESTOR]: {
        widgets: ['portfolioOverview', 'dealPipeline', 'portfolioCompanies'],
        layout: 'investment-focused',
        aiTriggers: ['investment', 'analysis', 'discovery'],
      },
      // ... other profile configurations
    };
    return configs[type];
  };

  const config = getDashboardConfig(profileType);
  
  return (
    <DashboardLayout layout={config.layout}>
      {config.widgets.map(widget => (
        <DashboardWidget key={widget} type={widget} />
      ))}
      <AITriggerButtons triggers={config.aiTriggers} />
    </DashboardLayout>
  );
};
```

### **Profile-Specific Forms**
```typescript
// Dynamic form fields based on profile type
export const ProfileForm: React.FC<{ profileType: ProfileType }> = ({ profileType }) => {
  const getProfileFields = (type: ProfileType) => {
    const fieldConfigs = {
      [ProfileType.INNOVATOR]: [
        { name: 'startupName', type: 'text', required: false },
        { name: 'industry', type: 'select', required: true },
        { name: 'innovationStage', type: 'select', required: true },
        { name: 'fundingNeeded', type: 'number', required: false },
        { name: 'teamSize', type: 'number', required: false },
      ],
      [ProfileType.BUSINESS_INVESTOR]: [
        { name: 'investmentFocus', type: 'multiselect', required: true },
        { name: 'ticketSizeMin', type: 'number', required: true },
        { name: 'ticketSizeMax', type: 'number', required: true },
        { name: 'stagePreference', type: 'multiselect', required: true },
        { name: 'geographicFocus', type: 'multiselect', required: false },
      ],
      // ... other profile field configurations
    };
    return fieldConfigs[type] || [];
  };

  const fields = getProfileFields(profileType);
  
  return (
    <Form>
      {fields.map(field => (
        <DynamicField key={field.name} config={field} />
      ))}
    </Form>
  );
};
```

## 🔐 **Profile-Specific Permissions**

### **Permission Matrix**
```typescript
interface ProfilePermissions {
  [ProfileType.INNOVATOR]: {
    canCreateFundingRequests: true;
    canAccessInvestorDirectory: true;
    canJoinAccelerators: true;
    canPostInMarketplace: true;
  };
  [ProfileType.BUSINESS_INVESTOR]: {
    canViewStartupFinancials: true;
    canParticipateInFunding: true;
    canAccessDealFlow: true;
    canCreateInvestmentGroups: true;
  };
  [ProfileType.MENTOR]: {
    canCreateMentoringPrograms: true;
    canAccessMenteeDirectory: true;
    canScheduleSessions: true;
    canCreateContent: true;
  };
  // ... other profile permissions
}
```

---

## 📚 **Reference Documents**

**User Requirements**: See `/1_planning_and_requirements/2_user_requirements_and_journeys.md`
**Database Schema**: See `/2_technical_architecture/2_database_schema_and_design.md`
**AI Integration**: See `/4_backend_implementation/6_ai_integration_implementation.md`
**Frontend Implementation**: See `/5_frontend_implementation/2_user_interface_implementation.md`

*This comprehensive profile type specification ensures each user type has tailored features, AI assistance, and dashboard experiences optimized for their specific needs and goals on the ZbInnovation platform.*
