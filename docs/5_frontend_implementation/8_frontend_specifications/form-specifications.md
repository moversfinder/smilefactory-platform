# Platform Forms and User Input

## Overview

This document explains all the forms users interact with on the ZbInnovation platform. It details what information is collected, how forms work, and what validation rules ensure data quality and user experience.

## Form Design Principles

### User-Friendly Form Experience
The platform uses modern form design that makes data entry simple and intuitive:

- **Clear Labels**: Every field has descriptive labels explaining what information is needed
- **Real-time Validation**: Users get immediate feedback if they enter incorrect information
- **Progressive Disclosure**: Complex forms are broken into manageable steps
- **Smart Defaults**: Forms pre-fill information when possible to save user time
- **Error Prevention**: Forms guide users to enter correct information the first time
- **Accessibility**: All forms work with screen readers and keyboard navigation

## 1. User Registration Forms

### Sign Up Form
**Purpose**: Allow new users to create accounts and join the platform

**How the Sign Up Form Works**:
When someone wants to join ZbInnovation, they complete a registration form that collects essential information to create their account.

**Information Required**:
- **Email Address**: Must be a valid email format and not already registered
- **Password**: Must be at least 6 characters long for security
- **Confirm Password**: Must match the password to prevent typing errors
- **Terms Acceptance**: Must agree to platform terms and conditions before proceeding
- **Profile Type Selection**: Choose from 8 available profile types
- **Marketing Preferences**: Optional consent for promotional communications

**Form Validation Rules**:
- **Email Validation**: Checks for proper email format and uniqueness
- **Password Strength**: Ensures minimum security requirements
- **Required Fields**: All mandatory fields must be completed
- **Terms Agreement**: Cannot proceed without accepting terms

**Form Field Details**:
- **Email Field**: Text input, required, email format validation, maximum 255 characters
- **Password Field**: Password input, required, minimum 6 characters, hidden text
- **Confirm Password Field**: Password input, required, must match password field
- **Profile Type Field**: Dropdown selection, required, 8 options available
- **Terms Checkbox**: Checkbox input, required, must be checked to proceed
- **Marketing Consent**: Checkbox input, optional, defaults to unchecked

## 2. Dynamic Profile Creation Forms

### How Dynamic Profile Forms Work
Profile creation forms adapt based on the selected profile type, showing relevant fields and sections for each user type. The form structure changes dynamically to collect appropriate information.

**Dynamic Form Behavior**:
- **Profile Type Selection**: First step determines which form fields appear
- **Conditional Fields**: Some fields only appear based on previous answers
- **Section Organization**: Fields are grouped into logical sections
- **Progress Tracking**: Users see completion progress throughout the form
- **Validation**: Real-time validation ensures data quality

### Profile Type-Specific Form Sections

#### **Innovator Profile Form**
**Required Sections**:
- **Executive Summary**: Brief description of innovation focus and goals
- **Innovation Details**: Current projects, stage of development, industry focus
- **Team Information**: Team size, key roles, skills needed
- **Funding Status**: Current funding stage, amount seeking, investor preferences
- **Market Information**: Target market, customer validation, competitive landscape

**Field Types Used**:
- **Text Areas**: For descriptions and summaries (500-2000 character limits)
- **Dropdown Selections**: For industry, stage, funding type (predefined options)
- **Multi-Select**: For skills needed, market segments, SDG alignment
- **Number Inputs**: For funding amounts, team size, timeline
- **File Uploads**: For pitch decks, business plans, product demos

#### **Business Investor Profile Form**
**Required Sections**:
- **Investment Focus**: Industries, stages, geographic preferences
- **Investment Criteria**: Ticket sizes, due diligence requirements
- **Portfolio Information**: Current investments, success stories
- **Expertise Areas**: Value-add capabilities, mentoring focus
- **Contact Preferences**: Communication methods, meeting availability

**Field Types Used**:
- **Range Sliders**: For investment amounts (minimum/maximum)
- **Multi-Select Checkboxes**: For industries, stages, geographic areas
- **Text Areas**: For investment philosophy, value proposition
- **Dropdown Menus**: For investment types, involvement level
- **Toggle Switches**: For availability, communication preferences

#### **Mentor Profile Form**
**Required Sections**:
- **Expertise Areas**: Professional background, industry experience
- **Mentoring Focus**: Types of mentees, preferred topics
- **Availability**: Time commitment, meeting preferences
- **Success Stories**: Previous mentoring achievements
- **Approach**: Mentoring style and methodology

**Field Types Used**:
- **Tag Input**: For expertise areas (free text with suggestions)
- **Radio Buttons**: For mentoring style, time commitment level
- **Checkbox Groups**: For availability days/times, communication methods
- **Text Areas**: For mentoring philosophy, success stories
- **Slider Controls**: For experience level, time availability

#### **Professional Profile Form**
**Required Sections**:
- **Professional Background**: Current role, industry, experience level
- **Service Offerings**: Skills available, consulting areas
- **Portfolio**: Work samples, client testimonials
- **Networking Goals**: Connection objectives, collaboration interests
- **Availability**: Project availability, preferred engagement types

**Field Types Used**:
- **Autocomplete Fields**: For job titles, companies, skills
- **File Upload Areas**: For portfolio samples, certifications
- **Rating Scales**: For skill proficiency levels
- **Date Pickers**: For availability periods, project timelines
- **Rich Text Editors**: For service descriptions, case studies

#### **Industry Expert Profile Form**
**Required Sections**:
- **Expertise Domain**: Specific industry or technology focus
- **Professional Credentials**: Education, certifications, achievements
- **Thought Leadership**: Publications, speaking engagements
- **Consulting Services**: Available services, engagement types
- **Knowledge Sharing**: Content creation preferences, topics

**Field Types Used**:
- **Hierarchical Selectors**: For industry/sub-industry selection
- **Achievement Lists**: For credentials, publications, awards
- **Content Type Checkboxes**: For preferred content formats
- **Availability Calendars**: For consulting and speaking availability
- **Link Input Fields**: For portfolio websites, social profiles

#### **Academic Student Profile Form**
**Required Sections**:
- **Academic Information**: Institution, program, year of study
- **Research Interests**: Academic focus areas, thesis topics
- **Skills Development**: Current skills, learning goals
- **Career Aspirations**: Post-graduation plans, industry interests
- **Project Portfolio**: Academic and personal projects

**Field Types Used**:
- **Institution Autocomplete**: For university/college selection
- **Program Dropdowns**: For degree types, majors, specializations
- **Skill Rating Matrices**: For current vs desired skill levels
- **Timeline Inputs**: For graduation dates, project timelines
- **Project Upload Areas**: For academic work, portfolios

#### **Academic Institution Profile Form**
**Required Sections**:
- **Institution Details**: Type, size, location, accreditation
- **Academic Programs**: Degrees offered, specializations
- **Research Focus**: Research areas, ongoing projects
- **Industry Partnerships**: Corporate collaborations, internship programs
- **Innovation Initiatives**: Incubators, competitions, startup support

**Field Types Used**:
- **Institution Type Selectors**: For university type, size categories
- **Program Matrices**: For degree levels and subject areas
- **Research Area Tags**: For research focus areas
- **Partnership Lists**: For corporate and institutional partnerships
- **Initiative Descriptions**: For innovation programs and support

#### **Organisation Profile Form**
**Required Sections**:
- **Organisation Details**: Type, size, industry, mission
- **Innovation Needs**: Challenges seeking solutions, collaboration areas
- **Resources Available**: Funding, mentorship, infrastructure support
- **Partnership Interests**: Types of partnerships sought
- **Corporate Social Responsibility**: Community involvement, sustainability

**Field Types Used**:
- **Organisation Type Selectors**: For company type, size, industry
- **Challenge Description Areas**: For innovation needs and problems
- **Resource Allocation Sliders**: For available support types
- **Partnership Type Checkboxes**: For collaboration preferences
- **Impact Measurement Tools**: For CSR goals and metrics

## 3. Dynamic Content Creation Forms

### How Dynamic Content Forms Work
Content creation forms adapt based on the active community tab and selected content type. Different tabs enable different content creation options with relevant fields.

**Dynamic Content Behavior**:
- **Tab-Based Forms**: Content options change based on active community tab
- **Content Type Selection**: First choice determines available form fields
- **Context-Aware Fields**: Forms include relevant metadata for each tab
- **Auto-Categorization**: Content is automatically tagged based on creation context
- **Preview Functionality**: Users can preview content before publishing

### Content Creation by Community Tab

#### **Feed Tab - General Posts**
**Content Types Available**:
- **Text Posts**: Quick updates, thoughts, questions
- **Image Posts**: Visual content with descriptions
- **Link Sharing**: External content with commentary
- **Poll Posts**: Community polls and surveys

**Form Fields**:
- **Content Text Area**: Main post content (up to 2000 characters)
- **Media Upload**: Images, videos, documents (optional)
- **Link Input**: URL for link sharing (optional)
- **Poll Options**: Multiple choice options for polls (optional)
- **Tags**: Hashtags for content discovery
- **Visibility**: Public, connections only, or specific groups

#### **Blog Tab - Article Creation**
**Content Types Available**:
- **Full Articles**: Long-form content with rich formatting
- **Quick Insights**: Shorter thought leadership pieces
- **Tutorial Content**: Step-by-step guides and how-tos
- **Case Studies**: Detailed project or success stories

**Form Fields**:
- **Article Title**: Compelling headline (required, 60 character limit)
- **Article Excerpt**: Brief summary for listings (required, 200 characters)
- **Featured Image**: Main article image (required)
- **Content Editor**: Rich text editor with formatting options
- **Category Selection**: Dropdown for article categorization
- **Tags**: Keywords for article discovery
- **Reading Time**: Auto-calculated based on content length
- **Publication Status**: Draft, scheduled, or immediate publication

#### **Events Tab - Event Creation**
**Content Types Available**:
- **Workshops**: Educational and skill-building events
- **Conferences**: Large-scale industry gatherings
- **Networking Events**: Community building and connections
- **Webinars**: Online educational sessions

**Form Fields**:
- **Event Title**: Clear, descriptive event name (required)
- **Event Description**: Detailed event information (required)
- **Event Type**: Workshop, conference, networking, webinar (required)
- **Date and Time**: Start and end date/time (required)
- **Location**: Physical address or online platform details (required)
- **Registration**: Registration requirements and limits (optional)
- **Pricing**: Free or paid event pricing (optional)
- **Event Image**: Promotional image for the event (optional)
- **Agenda**: Event schedule and speakers (optional)
- **Prerequisites**: Required skills or knowledge (optional)

#### **Groups Tab - Group Creation**
**Content Types Available**:
- **Public Groups**: Open community groups
- **Private Groups**: Invitation-only groups
- **Project Groups**: Collaboration-focused groups
- **Interest Groups**: Topic or industry-focused groups

**Form Fields**:
- **Group Name**: Descriptive group name (required)
- **Group Description**: Purpose and focus of the group (required)
- **Group Type**: Public, private, or invite-only (required)
- **Category**: Industry or topic category (required)
- **Group Image**: Group avatar or logo (optional)
- **Cover Image**: Group banner image (optional)
- **Group Rules**: Community guidelines and rules (optional)
- **Member Limit**: Maximum number of members (optional)
- **Approval Process**: Automatic or manual member approval (required)

#### **Marketplace Tab - Listing Creation**
**Content Types Available**:
- **Job Listings**: Employment opportunities
- **Service Offerings**: Professional services
- **Product Sales**: Physical or digital products
- **Partnership Opportunities**: Collaboration requests

**Form Fields**:
- **Listing Title**: Clear, descriptive title (required)
- **Listing Description**: Detailed description of offering (required)
- **Category**: Job, service, product, or partnership (required)
- **Pricing**: Cost information or salary range (optional)
- **Location**: Geographic location or remote options (required)
- **Contact Information**: How to respond to listing (required)
- **Requirements**: Skills, experience, or qualifications needed (optional)
- **Images**: Product photos or service examples (optional)
- **Deadline**: Application or availability deadline (optional)
- **Tags**: Keywords for listing discovery (optional)

## 4. Dynamic Search and Filter Forms

### How Dynamic Filters Work
Search and filter options change based on the active community tab, providing relevant filtering options for each content type.

**Dynamic Filter Behavior**:
- **Tab-Specific Filters**: Different filter options for each community tab
- **Contextual Search**: Search functionality adapts to content type
- **Filter Persistence**: User filter preferences are remembered
- **Real-Time Results**: Filters update content immediately
- **Advanced Options**: Expandable advanced filter sections

### Filter Specifications by Tab

#### **Feed Tab Filters**
**Available Filters**:
- **Content Type**: General posts, opportunities, announcements, success stories
- **Post Categories**: Innovation, technology, business, education, sustainability
- **Date Range**: Today, this week, this month, custom range
- **Engagement Level**: Most liked, most commented, trending
- **Author Type**: Filter by profile types of content creators
- **Media Type**: Text only, with images, with videos, with links

**Search Functionality**:
- **Global Search**: Search across all post content and titles
- **Hashtag Search**: Find posts with specific hashtags
- **Author Search**: Find posts by specific users
- **Keyword Highlighting**: Search terms highlighted in results

#### **Profiles Tab Filters**
**Available Filters**:
- **Profile Type**: All 8 profile types with multi-select
- **Location**: Country, city, or region filtering
- **Industry**: Industry categories and specializations
- **Experience Level**: Junior, mid-level, senior, expert
- **Availability**: Available for projects, mentoring, collaboration
- **Skills**: Specific skills and expertise areas

**Search Functionality**:
- **Name Search**: Find users by name or display name
- **Skill Search**: Search by specific skills or expertise
- **Company Search**: Find users by current or past companies
- **Bio Search**: Search within user profile descriptions

#### **Blog Tab Filters**
**Available Filters**:
- **Article Categories**: Innovation, technology, business, education
- **Reading Time**: Under 5 minutes, 5-10 minutes, 10+ minutes
- **Publication Date**: Recent, this week, this month, all time
- **Author Type**: Filter by author profile types
- **Content Format**: How-to guides, case studies, opinion pieces
- **Popularity**: Most viewed, most shared, trending

**Search Functionality**:
- **Title Search**: Search article titles and headlines
- **Content Search**: Full-text search within article content
- **Author Search**: Find articles by specific authors
- **Tag Search**: Search by article tags and keywords

#### **Events Tab Filters**
**Available Filters**:
- **Event Type**: Workshops, conferences, networking, webinars
- **Date Range**: Upcoming, this week, this month, custom range
- **Location**: In-person, online, hybrid, specific locations
- **Event Format**: Free, paid, members-only, public
- **Industry Focus**: Technology, business, education, sustainability
- **Event Size**: Small (under 50), medium (50-200), large (200+)

**Search Functionality**:
- **Event Name Search**: Search event titles and descriptions
- **Location Search**: Find events in specific locations
- **Speaker Search**: Find events by speaker or organizer
- **Topic Search**: Search by event topics and themes

#### **Groups Tab Filters**
**Available Filters**:
- **Group Type**: Public, private, invite-only
- **Group Category**: Industry, interest, project, location-based
- **Group Size**: Small (under 50), medium (50-200), large (200+)
- **Activity Level**: Very active, moderately active, new groups
- **Membership**: Open to join, requires approval, invite-only
- **Focus Area**: Networking, learning, collaboration, support

**Search Functionality**:
- **Group Name Search**: Search group names and descriptions
- **Topic Search**: Find groups by focus areas and interests
- **Member Search**: Find groups with specific members
- **Activity Search**: Search group discussions and posts

#### **Marketplace Tab Filters**
**Available Filters**:
- **Listing Type**: Jobs, services, products, partnerships
- **Category**: Technology, business, education, creative, other
- **Price Range**: Free, under $100, $100-$1000, $1000+, negotiable
- **Location**: Remote, on-site, hybrid, specific locations
- **Experience Level**: Entry-level, mid-level, senior, expert
- **Availability**: Immediate, within 1 month, flexible

**Search Functionality**:
- **Title Search**: Search listing titles and descriptions
- **Skills Search**: Find opportunities requiring specific skills
- **Company Search**: Find listings from specific organizations
- **Salary Search**: Search by salary range or compensation

## 5. Click Interactions and User Interface Behaviors

### Platform-Wide Click Interactions

#### **Navigation Interactions**
**Tab Switching**:
- **Click Behavior**: Instant tab switching with content loading
- **Visual Feedback**: Active tab highlighting, loading indicators
- **State Preservation**: Filter and search states maintained per tab
- **URL Updates**: Browser URL updates to reflect current tab

**Menu Interactions**:
- **Main Navigation**: Smooth transitions between platform sections
- **User Menu**: Dropdown with profile, settings, logout options
- **Breadcrumb Navigation**: Click to navigate to parent sections
- **Back Button**: Browser back button support for all navigation

#### **Content Interaction Behaviors**
**Post Engagement**:
- **Like Button**: Single click to like/unlike with visual feedback
- **Comment Button**: Opens comment section or focuses comment input
- **Share Button**: Opens sharing options modal with platform and external options
- **Save Button**: Bookmarks content with confirmation feedback
- **Author Click**: Navigates to author's profile page

**Profile Interactions**:
- **Profile Card Click**: Opens full profile view in modal or new page
- **Connect Button**: Sends connection request with confirmation message
- **Message Button**: Opens direct message dialog with pre-filled recipient
- **Follow Button**: Follows/unfollows user with immediate feedback
- **Skill Tag Click**: Filters content by that skill or expertise area

#### **Form Interaction Behaviors**
**Dynamic Form Responses**:
- **Field Dependencies**: Fields appear/disappear based on previous selections
- **Auto-Save**: Form progress automatically saved every 30 seconds
- **Validation Feedback**: Real-time validation with helpful error messages
- **Progress Indicators**: Visual progress bars for multi-step forms
- **Smart Suggestions**: Auto-complete and suggestion dropdowns

**Button Interactions**:
- **Primary Actions**: Clear visual hierarchy with prominent primary buttons
- **Secondary Actions**: Subtle styling for secondary options
- **Destructive Actions**: Warning colors and confirmation dialogs
- **Loading States**: Buttons show loading spinners during processing
- **Success Feedback**: Confirmation messages and visual success indicators

## 6. Comprehensive Form Field Specifications

### Field Type Definitions and Behaviors

#### **Text Input Fields**
**Standard Text Input**:
- **Character Limits**: Configurable minimum and maximum lengths
- **Validation**: Real-time format validation (email, phone, URL)
- **Placeholder Text**: Helpful examples and guidance
- **Auto-Complete**: Browser auto-complete support where appropriate
- **Clear Button**: X button to clear field content

**Text Area Fields**:
- **Expandable Height**: Auto-resize based on content length
- **Character Counters**: Live character count with limit indicators
- **Rich Text Options**: Bold, italic, links for content creation
- **Paste Handling**: Smart paste formatting and cleanup
- **Draft Saving**: Auto-save for longer content fields

#### **Selection Fields**
**Dropdown Menus**:
- **Search Functionality**: Type-to-search within dropdown options
- **Option Grouping**: Logical grouping of related options
- **Custom Options**: "Other" option with text input for unlisted items
- **Multi-Select**: Checkbox-style selection for multiple choices
- **Dependent Dropdowns**: Options change based on previous selections

**Checkbox and Radio Groups**:
- **Visual Grouping**: Clear visual separation of option groups
- **Select All**: Option to select/deselect all checkboxes
- **Conditional Logic**: Show/hide options based on other selections
- **Validation**: Minimum/maximum selection requirements
- **Custom Styling**: Platform-consistent styling across all browsers

#### **Specialized Input Fields**
**Date and Time Pickers**:
- **Calendar Interface**: Visual calendar for date selection
- **Time Zones**: Automatic time zone detection and conversion
- **Date Ranges**: Start and end date selection with validation
- **Recurring Events**: Options for repeating dates and times
- **Availability**: Integration with calendar systems

**File Upload Fields**:
- **Drag and Drop**: Intuitive file dropping interface
- **File Type Validation**: Automatic validation of allowed file types
- **Size Limits**: Clear file size restrictions with helpful messaging
- **Preview Functionality**: Image and document previews before upload
- **Progress Indicators**: Upload progress bars and status messages
- **Multiple Files**: Support for multiple file selection and upload

**Number and Range Inputs**:
- **Increment Controls**: Plus/minus buttons for number adjustment
- **Range Sliders**: Visual sliders for range selection
- **Currency Formatting**: Automatic currency formatting for monetary values
- **Percentage Inputs**: Specialized inputs for percentage values
- **Validation**: Minimum/maximum value enforcement

#### **Advanced Field Types**
**Tag Input Fields**:
- **Auto-Suggestions**: Dropdown suggestions based on existing tags
- **Free Text Entry**: Ability to create new tags
- **Tag Validation**: Duplicate prevention and format validation
- **Visual Tags**: Chip-style display of selected tags
- **Bulk Operations**: Select and delete multiple tags

**Location Fields**:
- **Address Auto-Complete**: Integration with mapping services
- **Geographic Validation**: Verification of valid addresses
- **Map Integration**: Visual map display for location confirmation
- **Multiple Locations**: Support for multiple location entries
- **Location Hierarchy**: Country, state/province, city selection

**Rich Content Editors**:
- **WYSIWYG Interface**: What-you-see-is-what-you-get editing
- **Formatting Tools**: Bold, italic, lists, headers, links
- **Media Embedding**: Image and video insertion capabilities
- **Link Management**: URL validation and preview generation
- **Content Templates**: Pre-defined content structures and layouts

## 7. JSON Structure Specifications

### Profile Creation Form Data Structures

#### **Innovator Profile JSON Structure**
```json
{
  "profileType": "innovator",
  "executiveSummary": {
    "description": "string (500-2000 chars)",
    "innovationFocus": "string",
    "goals": "string"
  },
  "innovationDetails": {
    "currentProjects": ["array of project objects"],
    "developmentStage": "idea|prototype|mvp|scaling|established",
    "industryFocus": ["array of industry strings"],
    "targetMarket": "string",
    "competitiveLandscape": "string"
  },
  "teamInformation": {
    "teamSize": "number",
    "keyRoles": ["array of role strings"],
    "skillsNeeded": ["array of skill strings"],
    "cofounderSearch": "boolean"
  },
  "fundingStatus": {
    "currentStage": "pre-seed|seed|series-a|series-b|growth|established",
    "amountSeeking": "number",
    "investorPreferences": ["array of investor type strings"],
    "fundingTimeline": "string"
  },
  "contactPreferences": {
    "availableForMentoring": "boolean",
    "collaborationInterests": ["array of collaboration types"],
    "communicationMethods": ["array of communication preferences"]
  }
}
```

#### **Business Investor Profile JSON Structure**
```json
{
  "profileType": "business_investor",
  "investmentFocus": {
    "industries": ["array of industry strings"],
    "stages": ["array of investment stage strings"],
    "geographicPreferences": ["array of location strings"],
    "investmentThesis": "string"
  },
  "investmentCriteria": {
    "ticketSizeMin": "number",
    "ticketSizeMax": "number",
    "dueDiligenceRequirements": ["array of requirement strings"],
    "timelineExpectations": "string",
    "involvementLevel": "hands-off|advisory|board-member|active"
  },
  "portfolioInformation": {
    "currentInvestments": "number",
    "successStories": ["array of success story objects"],
    "totalInvested": "number",
    "averageTicketSize": "number"
  },
  "expertiseAreas": {
    "valueAddCapabilities": ["array of capability strings"],
    "mentoringFocus": ["array of mentoring area strings"],
    "networkAccess": ["array of network type strings"]
  },
  "contactPreferences": {
    "meetingAvailability": "string",
    "communicationMethods": ["array of communication preferences"],
    "pitchPreferences": "string"
  }
}
```

### Content Creation Form Data Structures

#### **Blog Article Creation JSON Structure**
```json
{
  "contentType": "blog",
  "articleData": {
    "title": "string (max 60 chars)",
    "excerpt": "string (max 200 chars)",
    "content": "string (rich text)",
    "featuredImage": "file upload object",
    "category": "innovation|technology|business|education|sustainability",
    "tags": ["array of tag strings"],
    "readingTime": "number (auto-calculated)",
    "publicationStatus": "draft|scheduled|published",
    "scheduledDate": "ISO date string (optional)",
    "seoMetadata": {
      "metaDescription": "string",
      "keywords": ["array of keyword strings"]
    }
  },
  "authorInfo": {
    "authorId": "string",
    "authorType": "profile type string",
    "authorCredentials": "string"
  },
  "engagementSettings": {
    "allowComments": "boolean",
    "allowSharing": "boolean",
    "notifyOnEngagement": "boolean"
  }
}
```

#### **Event Creation JSON Structure**
```json
{
  "contentType": "event",
  "eventData": {
    "title": "string",
    "description": "string",
    "eventType": "workshop|conference|networking|webinar",
    "startDateTime": "ISO date string",
    "endDateTime": "ISO date string",
    "timeZone": "string",
    "location": {
      "type": "physical|online|hybrid",
      "address": "string (if physical)",
      "onlinePlatform": "string (if online)",
      "platformLink": "string (if online)"
    },
    "registration": {
      "required": "boolean",
      "capacity": "number",
      "deadline": "ISO date string",
      "approvalRequired": "boolean"
    },
    "pricing": {
      "isFree": "boolean",
      "price": "number",
      "currency": "string",
      "paymentMethods": ["array of payment method strings"]
    },
    "media": {
      "eventImage": "file upload object",
      "additionalImages": ["array of file upload objects"]
    },
    "agenda": ["array of agenda item objects"],
    "speakers": ["array of speaker objects"],
    "prerequisites": "string",
    "tags": ["array of tag strings"]
  },
  "organizerInfo": {
    "organizerId": "string",
    "organizerType": "profile type string",
    "contactEmail": "string",
    "contactPhone": "string"
  }
}
```

### Search and Filter Form Data Structures

#### **Dynamic Filter State JSON Structure**
```json
{
  "activeTab": "feed|profiles|blog|events|groups|marketplace",
  "searchQuery": "string",
  "dateRange": {
    "startDate": "ISO date string",
    "endDate": "ISO date string",
    "preset": "today|week|month|custom"
  },
  "tabSpecificFilters": {
    "feed": {
      "postTypes": ["array of post type strings"],
      "categories": ["array of category strings"],
      "authorTypes": ["array of profile type strings"],
      "engagementLevel": "all|trending|popular",
      "mediaType": "all|text|images|videos|links"
    },
    "profiles": {
      "profileTypes": ["array of profile type strings"],
      "locations": ["array of location strings"],
      "industries": ["array of industry strings"],
      "experienceLevel": ["array of experience level strings"],
      "availability": ["array of availability type strings"],
      "skills": ["array of skill strings"]
    },
    "blog": {
      "categories": ["array of category strings"],
      "readingTime": "any|under-5|5-10|over-10",
      "authorTypes": ["array of profile type strings"],
      "contentFormat": ["array of format strings"],
      "popularity": "recent|trending|popular|all-time"
    },
    "events": {
      "eventTypes": ["array of event type strings"],
      "locations": ["array of location strings"],
      "formats": ["array of format strings"],
      "pricing": "all|free|paid",
      "industryFocus": ["array of industry strings"],
      "eventSize": "all|small|medium|large"
    },
    "groups": {
      "groupTypes": ["array of group type strings"],
      "categories": ["array of category strings"],
      "groupSize": "all|small|medium|large",
      "activityLevel": "all|very-active|moderate|new",
      "membership": "all|open|approval|invite-only",
      "focusArea": ["array of focus area strings"]
    },
    "marketplace": {
      "listingTypes": ["array of listing type strings"],
      "categories": ["array of category strings"],
      "priceRange": {
        "min": "number",
        "max": "number",
        "preset": "all|free|under-100|100-1000|over-1000"
      },
      "locations": ["array of location strings"],
      "experienceLevel": ["array of experience level strings"],
      "availability": ["array of availability strings"]
    }
  },
  "sortOptions": {
    "sortBy": "date|relevance|popularity|alphabetical",
    "sortOrder": "asc|desc"
  },
  "pagination": {
    "page": "number",
    "limit": "number",
    "totalResults": "number"
  }
}
```

---

*These comprehensive form specifications ensure complete functional coverage of all user interactions, dynamic behaviors, and data structures across the ZbInnovation platform, maintaining consistency with our established functional scope.*
      // Handle error
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <TextField
        {...register('email')}
        label="Email Address"
        type="email"
        error={!!errors.email}
        helperText={errors.email?.message}
        fullWidth
        margin="normal"
      />
      <TextField
        {...register('password')}
        label="Password"
        type="password"
        error={!!errors.password}
        helperText={errors.password?.message}
        fullWidth
        margin="normal"
      />
      <TextField
        {...register('confirmPassword')}
        label="Confirm Password"
        type="password"
        error={!!errors.confirmPassword}
        helperText={errors.confirmPassword?.message}
        fullWidth
        margin="normal"
      />
      <FormControlLabel
        control={<Checkbox {...register('acceptTerms')} />}
        label="I accept the Terms and Conditions"
      />
      <FormControlLabel
        control={<Checkbox {...register('marketingConsent')} />}
        label="Send me marketing updates"
      />
      <Button type="submit" variant="contained" disabled={isSubmitting} fullWidth>
        {isSubmitting ? 'Creating Account...' : 'Sign Up'}
      </Button>
    </form>
  );
};
```

## 2. Post Creation Forms

### General Post Form Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "General Post Form",
  "type": "object",
  "properties": {
    "postType": {
      "type": "string",
      "enum": ["general", "blog", "event", "marketplace", "opportunity"],
      "default": "general"
    },
    "content": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000,
      "description": "Post content"
    },
    "title": {
      "type": "string",
      "maxLength": 200,
      "description": "Post title (optional for general posts)"
    },
    "tags": {
      "type": "array",
      "items": { "type": "string" },
      "maxItems": 10,
      "description": "Post tags"
    },
    "mediaFiles": {
      "type": "array",
      "items": { "type": "object" },
      "maxItems": 4,
      "description": "Uploaded media files"
    },
    "status": {
      "type": "string",
      "enum": ["draft", "published"],
      "default": "published"
    }
  },
  "required": ["postType", "content"],
  "additionalProperties": false
}
```

### Event Post Form Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Event Post Form",
  "type": "object",
  "allOf": [
    { "$ref": "#/definitions/basePost" },
    {
      "properties": {
        "eventTitle": {
          "type": "string",
          "minLength": 1,
          "maxLength": 200,
          "description": "Event title"
        },
        "eventType": {
          "type": "string",
          "enum": ["workshop", "conference", "networking", "hackathon", "training", "webinar"],
          "description": "Type of event"
        },
        "eventStartDatetime": {
          "type": "string",
          "format": "date-time",
          "description": "Event start date and time"
        },
        "eventEndDatetime": {
          "type": "string",
          "format": "date-time",
          "description": "Event end date and time"
        },
        "eventLocation": {
          "type": "string",
          "minLength": 1,
          "maxLength": 300,
          "description": "Event location or online link"
        },
        "eventRegistrationUrl": {
          "type": "string",
          "format": "uri",
          "description": "Registration URL"
        },
        "eventOrganizer": {
          "type": "string",
          "maxLength": 100,
          "description": "Event organizer name"
        }
      },
      "required": ["eventTitle", "eventType", "eventStartDatetime", "eventLocation"]
    }
  ]
}
```

### React Event Form Implementation
```tsx
// EventPostForm.tsx
const eventPostSchema = z.object({
  postType: z.literal('event'),
  content: z.string().min(1, 'Content is required').max(2000),
  eventTitle: z.string().min(1, 'Event title is required').max(200),
  eventType: z.enum(['workshop', 'conference', 'networking', 'hackathon', 'training', 'webinar']),
  eventStartDatetime: z.string().min(1, 'Start date is required'),
  eventEndDatetime: z.string().optional(),
  eventLocation: z.string().min(1, 'Location is required').max(300),
  eventRegistrationUrl: z.string().url().optional().or(z.literal('')),
  eventOrganizer: z.string().max(100).optional(),
  tags: z.array(z.string()).max(10),
  mediaFiles: z.array(z.instanceof(File)).max(4)
});

type EventPostFormData = z.infer<typeof eventPostSchema>;

export const EventPostForm: React.FC<{
  onSubmit: (data: EventPostFormData) => void;
}> = ({ onSubmit }) => {
  const { register, handleSubmit, control, formState: { errors } } = useForm<EventPostFormData>({
    resolver: zodResolver(eventPostSchema),
    defaultValues: {
      postType: 'event',
      tags: [],
      mediaFiles: []
    }
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <TextField
        {...register('eventTitle')}
        label="Event Title"
        error={!!errors.eventTitle}
        helperText={errors.eventTitle?.message}
        fullWidth
        margin="normal"
      />
      
      <FormControl fullWidth margin="normal" error={!!errors.eventType}>
        <InputLabel>Event Type</InputLabel>
        <Select {...register('eventType')}>
          <MenuItem value="workshop">Workshop</MenuItem>
          <MenuItem value="conference">Conference</MenuItem>
          <MenuItem value="networking">Networking Event</MenuItem>
          <MenuItem value="hackathon">Hackathon</MenuItem>
          <MenuItem value="training">Training Session</MenuItem>
          <MenuItem value="webinar">Webinar</MenuItem>
        </Select>
        {errors.eventType && (
          <FormHelperText>{errors.eventType.message}</FormHelperText>
        )}
      </FormControl>
      
      <TextField
        {...register('eventStartDatetime')}
        label="Start Date & Time"
        type="datetime-local"
        error={!!errors.eventStartDatetime}
        helperText={errors.eventStartDatetime?.message}
        fullWidth
        margin="normal"
        InputLabelProps={{ shrink: true }}
      />
      
      <TextField
        {...register('eventEndDatetime')}
        label="End Date & Time (Optional)"
        type="datetime-local"
        fullWidth
        margin="normal"
        InputLabelProps={{ shrink: true }}
      />
      
      <TextField
        {...register('eventLocation')}
        label="Location"
        error={!!errors.eventLocation}
        helperText={errors.eventLocation?.message}
        fullWidth
        margin="normal"
        placeholder="Physical address or online meeting link"
      />
      
      <TextField
        {...register('eventRegistrationUrl')}
        label="Registration URL (Optional)"
        type="url"
        error={!!errors.eventRegistrationUrl}
        helperText={errors.eventRegistrationUrl?.message}
        fullWidth
        margin="normal"
      />
      
      <TextField
        {...register('content')}
        label="Event Description"
        multiline
        rows={4}
        error={!!errors.content}
        helperText={errors.content?.message}
        fullWidth
        margin="normal"
      />
      
      <TagInput
        label="Event Tags"
        predefinedOptions={eventTagOptions}
        maxTags={10}
        onChange={(tags) => setValue('tags', tags)}
      />
      
      <FileUpload
        multiple
        accept="image/*,video/*"
        maxFiles={4}
        onFilesChange={(files) => setValue('mediaFiles', files)}
      />
      
      <Button type="submit" variant="contained" size="large">
        Create Event
      </Button>
    </form>
  );
};
```

## 3. Dynamic Profile Forms

### Profile Form Schema Generator
```typescript
// profileFormSchemas.ts
export interface ProfileQuestion {
  id: string;
  name: string;
  label: string;
  type: 'text' | 'number' | 'select' | 'multiselect' | 'textarea' | 'date' | 'url';
  required?: boolean;
  options?: string[] | { label: string; value: string }[];
  condition?: {
    field: string;
    value: any;
  };
  hint?: string;
  fullWidth?: boolean;
  validation?: {
    min?: number;
    max?: number;
    pattern?: string;
  };
}

export interface ProfileSection {
  title: string;
  icon?: string;
  description?: string;
  questions: ProfileQuestion[];
}

export interface ProfileFormSchema {
  profileType: string;
  displayName: string;
  description: string;
  sections: ProfileSection[];
}

// Generate Zod schema from profile questions
export const generateProfileValidationSchema = (schema: ProfileFormSchema) => {
  const schemaFields: Record<string, z.ZodTypeAny> = {};
  
  schema.sections.forEach(section => {
    section.questions.forEach(question => {
      let fieldSchema: z.ZodTypeAny;
      
      switch (question.type) {
        case 'text':
        case 'textarea':
        case 'url':
          fieldSchema = z.string();
          if (question.validation?.min) {
            fieldSchema = fieldSchema.min(question.validation.min);
          }
          if (question.validation?.max) {
            fieldSchema = fieldSchema.max(question.validation.max);
          }
          if (question.type === 'url') {
            fieldSchema = fieldSchema.url('Please enter a valid URL');
          }
          break;
          
        case 'number':
          fieldSchema = z.number();
          if (question.validation?.min) {
            fieldSchema = fieldSchema.min(question.validation.min);
          }
          if (question.validation?.max) {
            fieldSchema = fieldSchema.max(question.validation.max);
          }
          break;
          
        case 'select':
          if (question.options) {
            const values = question.options.map(opt => 
              typeof opt === 'string' ? opt : opt.value
            );
            fieldSchema = z.enum(values as [string, ...string[]]);
          } else {
            fieldSchema = z.string();
          }
          break;
          
        case 'multiselect':
          fieldSchema = z.array(z.string());
          break;
          
        case 'date':
          fieldSchema = z.string().refine(val => !isNaN(Date.parse(val)), {
            message: 'Please enter a valid date'
          });
          break;
          
        default:
          fieldSchema = z.string();
      }
      
      if (!question.required) {
        fieldSchema = fieldSchema.optional();
      }
      
      schemaFields[question.name] = fieldSchema;
    });
  });
  
  return z.object(schemaFields);
};
```

## 4. Filter Forms

### Community Page Filters Schema
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Community Filters",
  "type": "object",
  "properties": {
    "activeTab": {
      "type": "string",
      "enum": ["feed", "profiles", "blog", "events", "groups", "marketplace"]
    },
    "searchQuery": {
      "type": "string",
      "maxLength": 200
    },
    "dateRange": {
      "type": "string",
      "enum": ["all", "today", "week", "month", "year"]
    },
    "feedFilters": {
      "type": "object",
      "properties": {
        "postTypes": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["general", "opportunity", "success_story", "question_help", "resource", "job_talent"]
          }
        },
        "categories": {
          "type": "array",
          "items": { "type": "string" }
        }
      }
    },
    "profileFilters": {
      "type": "object",
      "properties": {
        "profileTypes": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["innovator", "investor", "mentor", "professional", "industry_expert", "academic_student", "academic_institution", "organisation"]
          }
        }
      }
    },
    "marketplaceFilters": {
      "type": "object",
      "properties": {
        "listingTypes": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["product", "service", "equipment", "space", "job", "free"]
          }
        },
        "priceRange": {
          "type": "object",
          "properties": {
            "min": { "type": "number", "minimum": 0 },
            "max": { "type": "number", "minimum": 0 }
          }
        }
      }
    }
  }
}
```

### React Filter Implementation
```tsx
// CommunityFilters.tsx
const filterSchema = z.object({
  searchQuery: z.string().max(200).optional(),
  dateRange: z.enum(['all', 'today', 'week', 'month', 'year']),
  postTypes: z.array(z.string()).optional(),
  profileTypes: z.array(z.string()).optional(),
  listingTypes: z.array(z.string()).optional()
});

type FilterFormData = z.infer<typeof filterSchema>;

export const CommunityFilters: React.FC<{
  activeTab: string;
  onFiltersChange: (filters: FilterFormData) => void;
}> = ({ activeTab, onFiltersChange }) => {
  const { register, handleSubmit, control, reset } = useForm<FilterFormData>({
    resolver: zodResolver(filterSchema),
    defaultValues: {
      searchQuery: '',
      dateRange: 'all',
      postTypes: [],
      profileTypes: [],
      listingTypes: []
    }
  });

  const getTabSpecificFilters = () => {
    switch (activeTab) {
      case 'feed':
        return (
          <Controller
            name="postTypes"
            control={control}
            render={({ field }) => (
              <FormControl fullWidth>
                <InputLabel>Post Types</InputLabel>
                <Select multiple {...field} renderValue={(selected) => selected.join(', ')}>
                  {postTypeOptions.map(option => (
                    <MenuItem key={option.value} value={option.value}>
                      <Checkbox checked={field.value?.includes(option.value)} />
                      <ListItemText primary={option.label} />
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            )}
          />
        );
        
      case 'profiles':
        return (
          <Controller
            name="profileTypes"
            control={control}
            render={({ field }) => (
              <FormControl fullWidth>
                <InputLabel>Profile Types</InputLabel>
                <Select multiple {...field}>
                  {profileTypeOptions.map(option => (
                    <MenuItem key={option.value} value={option.value}>
                      <Checkbox checked={field.value?.includes(option.value)} />
                      <ListItemText primary={option.label} />
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            )}
          />
        );
        
      default:
        return null;
    }
  };

  return (
    <Box component="form" onSubmit={handleSubmit(onFiltersChange)}>
      <Grid container spacing={2}>
        <Grid item xs={12} md={4}>
          <TextField
            {...register('searchQuery')}
            label="Search"
            placeholder="Search content..."
            fullWidth
            InputProps={{
              startAdornment: <SearchIcon />
            }}
          />
        </Grid>
        
        <Grid item xs={12} md={2}>
          <FormControl fullWidth>
            <InputLabel>Date Range</InputLabel>
            <Select {...register('dateRange')}>
              <MenuItem value="all">All Time</MenuItem>
              <MenuItem value="today">Today</MenuItem>
              <MenuItem value="week">This Week</MenuItem>
              <MenuItem value="month">This Month</MenuItem>
            </Select>
          </FormControl>
        </Grid>
        
        <Grid item xs={12} md={3}>
          {getTabSpecificFilters()}
        </Grid>
        
        <Grid item xs={12} md={3}>
          <Box sx={{ display: 'flex', gap: 1 }}>
            <Button variant="outlined" onClick={() => reset()}>
              Reset
            </Button>
            <Button type="submit" variant="contained">
              Apply
            </Button>
          </Box>
        </Grid>
      </Grid>
    </Box>
  );
};
```

## Form Validation Patterns

### Common Validation Rules
```typescript
// validationRules.ts
export const commonValidationRules = {
  email: z.string().email('Invalid email address').max(255),
  password: z.string().min(6, 'Password must be at least 6 characters').max(128),
  url: z.string().url('Please enter a valid URL').optional().or(z.literal('')),
  phone: z.string().regex(/^\+?[\d\s\-\(\)]+$/, 'Invalid phone number').optional(),
  required: (fieldName: string) => z.string().min(1, `${fieldName} is required`),
  maxLength: (max: number, fieldName: string) => 
    z.string().max(max, `${fieldName} must be less than ${max} characters`),
  minLength: (min: number, fieldName: string) => 
    z.string().min(min, `${fieldName} must be at least ${min} characters`)
};
```

---

*This form specification document provides complete migration guidance for all forms from Vue.js + Quasar to React + Material-UI with proper validation and type safety.*
