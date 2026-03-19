# VIS-003: Email Templates Design

## Brand Identity Reference
- **Primary Color:** Royal Blue (#3F63FF)
- **Secondary Color:** Dark Slate (#2F3A43)
- **Typography:** Geometric sans-serif (Montserrat/Avenir style)
- **Logo:** Horizontal lockup with icon left, wordmark right
- **Style:** Modern, minimal, tech-oriented with industrial/craft metaphor

## Email Design Principles

### Technical Requirements
- **Width:** 600px maximum for desktop compatibility
- **Mobile-first:** Responsive design essential
- **Web-safe fonts:** Fallback to Arial/Helvetica
- **Image optimization:** Compressed, with alt text
- **Dark mode:** Tested compatibility
- **Email clients:** Tested across Gmail, Outlook, Apple Mail

### Brand Consistency Rules
1. **Header:** Always include PRDForge logo with proper color split
2. **Colors:** Primary (#3F63FF) for CTAs, Secondary (#2F3A43) for headings
3. **Typography:** Geometric sans-serif style, clean hierarchy
4. **Spacing:** Consistent padding (20px sections, 10px elements)
5. **Footer:** Standard signature with unsubscribe link

## Template 1: Welcome/Onboarding Series

### Email 1: Welcome & Account Confirmation
**Sent:** Immediately after signup
**Purpose:** Confirm account, set expectations, first step guidance

**Design Elements:**
- Header: Full-width royal blue background with white logo
- Hero section: "Welcome to PRDForge" in dark slate
- Body: Clean white background with geometric divider lines
- CTA: "Create Your First PRD" button in royal blue
- Footer: Standard with social links and unsubscribe

**Content Structure:**
```
[PRDForge Logo Header]

Welcome to PRDForge, [First Name]!

We're excited to help you build better products faster. 
With PRDForge, you can:

• Generate comprehensive PRDs in minutes
• Collaborate with your team in real-time
• Export to multiple formats (PDF, DOCX, Markdown)
• Track changes and version history

[Create Your First PRD Button]

Getting Started Guide:
1. Create a new project
2. Define your requirements
3. Generate your first PRD
4. Share with your team

Need help? Check our [Help Center] or reply to this email.

[Footer with social links and unsubscribe]
```

### Email 2: First PRD Success
**Sent:** 24 hours after signup (or after first PRD creation)
**Purpose:** Celebrate milestone, encourage next steps

**Design Elements:**
- Header: Gradient background (dark slate to royal blue)
- Hero section: "Great job on your first PRD!" with hammer icon
- Body: Light gray background with success checklist
- CTA: "Explore Advanced Features" button
- Footer: Standard

**Content Structure:**
```
[Gradient Header with Logo]

Great job on your first PRD, [First Name]!

You've taken the first step toward faster, better product development.

✅ PRD created: "[PRD Name]"
✅ Team invited: [Number] members
✅ Export generated: [Format]

[Explore Advanced Features Button]

Next Steps to Master PRDForge:
• Set up team permissions and workflows
• Explore template library for your industry
• Connect with your existing tools (Jira, Slack, etc.)
• Schedule a demo with our team

[Footer]
```

### Email 3: Advanced Features Introduction
**Sent:** 3 days after signup
**Purpose:** Feature discovery, increase engagement

**Design Elements:**
- Header: Split layout with logo left, feature icon right
- Body: Feature cards with icons and brief descriptions
- CTA: "Try [Feature]" buttons for each card
- Footer: Standard

**Content Structure:**
```
[Split Header: Logo + Feature Icon]

Unlock More Power with PRDForge

Discover features that will transform your product development:

[Feature Card 1: AI Suggestions]
Icon: Brain icon
Title: AI-Powered Suggestions
Description: Get intelligent recommendations for requirements, user stories, and acceptance criteria.
[Try AI Suggestions Button]

[Feature Card 2: Team Collaboration]
Icon: Team icon  
Title: Real-time Collaboration
Description: Work simultaneously with your team, with comments, mentions, and version history.
[Invite Team Members Button]

[Feature Card 3: Integrations]
Icon: Puzzle icon
Title: Seamless Integrations
Description: Connect with Jira, Slack, GitHub, and more for streamlined workflows.
[Explore Integrations Button]

[Footer]
```

## Template 2: Feature Announcements

### Major Feature Launch
**Sent:** To all users when major feature releases
**Purpose:** Announce new capability, drive adoption

**Design Elements:**
- Header: Full-width feature announcement banner
- Hero section: Feature name with "NEW" badge
- Body: Before/after comparison or benefits list
- CTA: "Try It Now" primary button
- Secondary CTA: "Learn More" link
- Footer: Standard

**Content Structure:**
```
[Feature Announcement Banner]

NEW: [Feature Name] is here!

We're excited to introduce [Feature Name] – designed to [key benefit].

What you can do now:
• [Benefit 1 with brief description]
• [Benefit 2 with brief description]  
• [Benefit 3 with brief description]

[Try It Now Button]

See it in action:
[Embedded GIF or screenshot with caption]

How to get started:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Questions? Join our [Webinar Date] or read the [Documentation].

[Footer]
```

### Minor Feature Update
**Sent:** To relevant user segments
**Purpose:** Inform about improvements, maintain engagement

**Design Elements:**
- Header: Standard logo header
- Body: Clean update list with improvement icons
- CTA: Optional based on feature
- Footer: Standard

**Content Structure:**
```
[Standard Logo Header]

Latest Improvements to PRDForge

We're constantly improving based on your feedback. Here's what's new:

✓ [Improvement 1] – [Brief description]
✓ [Improvement 2] – [Brief description]
✓ [Improvement 3] – [Brief description]

These updates will help you [key benefit].

[Optional CTA Button]

As always, we'd love to hear what you think. Reply to this email with feedback or suggestions.

[Footer]
```

## Template 3: Notification Emails

### PRD Comment/Update Notification
**Sent:** When user is mentioned or PRD is updated
**Purpose:** Drive re-engagement, collaboration

**Design Elements:**
- Header: Notification-style with bell icon
- Body: Clear context of what happened and who did it
- CTA: "View Update" button
- Preview: Snippet of comment or change
- Footer: Standard with notification settings link

**Content Structure:**
```
[Notification Header with Bell Icon]

[User Name] mentioned you in a comment on [PRD Name]

"[Comment snippet...]"

[View Update Button]

Project: [Project Name]
Updated by: [User Name]  
Time: [Timestamp]

[Notification Settings Link] | [View All Notifications]

[Footer]
```

### Weekly Digest
**Sent:** Weekly to active users
**Purpose:** Recap activity, maintain engagement

**Design Elements:**
- Header: "Your PRDForge Weekly Digest"
- Body: Activity summary cards
- CTA: "Continue Working" button
- Footer: Standard with digest frequency options

**Content Structure:**
```
[Weekly Digest Header]

Your PRDForge Weekly Digest

Here's what happened in your workspace this week:

📊 Activity Summary
• PRDs created: [Number]
• Comments added: [Number]
• Team members active: [Number]

👥 Team Updates
• [Team member 1] updated [PRD 1]
• [Team member 2] commented on [PRD 2]

📈 Top Projects
1. [Project 1 name] – [Activity metric]
2. [Project 2 name] – [Activity metric]
3. [Project 3 name] – [Activity metric]

[Continue Working Button]

[Footer with digest frequency options]
```

## Template 4: Transactional Emails

### Password Reset
**Sent:** When user requests password reset
**Purpose:** Security, account recovery

**Design Elements:**
- Header: Security-focused with lock icon
- Body: Clear instructions, security warning
- CTA: "Reset Password" button (with unique token)
- Footer: Security notice, support contact

**Content Structure:**
```
[Security Header with Lock Icon]

Reset your PRDForge password

We received a request to reset your password for [email address].

[Reset Password Button]

This link will expire in 1 hour for security.

If you didn't request this password reset, please ignore this email or contact support if you have concerns.

Security reminder: Never share your password or this link with anyone.

[Footer with support contact]
```

### Invoice/Receipt
**Sent:** After payment
**Purpose:** Transaction confirmation, record keeping

**Design Elements:**
- Header: Standard logo
- Body: Clean invoice table
- Download links: PDF, HTML versions
- Footer: Billing support contact

**Content Structure:**
```
[Standard Logo Header]

Invoice for your PRDForge subscription

Invoice #: [Invoice Number]
Date: [Date]
Amount: [Amount]

[Invoice Table]
• Description: [Plan name] - [Billing period]
• Amount: [Amount]
• Tax: [Tax amount]
• Total: [Total amount]

Payment Method: [Payment method]
Status: Paid

[Download PDF] | [View Online]

Thank you for your business!

Billing questions? Contact our support team.

[Footer]
```

## Template 5: Re-engagement Series

### Inactive User (7 days)
**Sent:** After 7 days of inactivity
**Purpose:** Re-engage, offer help

**Design Elements:**
- Header: Friendly "We miss you" style
- Body: Personalized based on previous activity
- CTA: "Continue Where You Left Off" button
- Secondary: "Need help?" link
- Footer: Standard

**Content Structure:**
```
[Friendly Header]

We haven't seen you in a while!

Your last project "[Project Name]" is waiting for you.

[Continue Where You Left Off Button]

Quick tips to get back on track:
• Review your pending comments
• Check team updates
• Explore new templates added

Need a refresher? [Watch tutorial] or [Schedule a quick call].

[Footer]
```

### Win-back (30 days inactive)
**Sent:** After 30 days of inactivity
**Purpose:** Serious re-engagement, offer incentive

**Design Elements:**
- Header: "We'd love to have you back"
- Body: What's new since they left
- CTA: Special offer or incentive
- Footer: Final chance messaging

**Content Structure:**
```
[Win-back Header]

We'd love to have you back at PRDForge

Since you've been away, we've added:
• [New feature 1]
• [New feature 2]
• [New feature 3]

[Special Offer: 30% off next 3 months Button]

Your data is safe and waiting:
• [Number] projects
• [Number] PRDs
• [Number] team members

This offer expires in [Number] days.

[Footer with final chance messaging]
```

## Implementation Guidelines

### HTML/CSS Requirements
- **Inline CSS:** All styles must be inline for email client compatibility
- **Table-based layout:** For maximum compatibility
- **Web-safe fonts:** Arial, Helvetica, sans-serif fallback
- **Image hosting:** CDN with proper compression
- **Alt text:** Descriptive for all images
- **Dark mode:** Test with forced colors

### Testing Checklist
- [ ] Desktop clients (Outlook, Apple Mail, Gmail)
- [ ] Mobile clients (iOS Mail, Gmail app, Outlook app)
- [ ] Dark mode compatibility
- [ ] Image loading disabled
- [ ] Spam filter testing
- [ ] Link tracking working
- [ ] Unsubscribe functionality
- [ ] Responsive breakpoints

### Personalization Tokens
Available tokens for dynamic content:
- `{{first_name}}` - User's first name
- `{{company_name}}` - User's company
- `{{prd_name}}` - Most recent PRD name
- `{{project_name}}` - Most recent project
- `{{team_count}}` - Number of team members
- `{{activity_count}}` - Recent activity metric

### File Locations

#### Template Source Files
- `/Users/clawdia/.openclaw/workspace/prdforge-pack/assets/email-templates/`
  - `welcome-series/`
    - `welcome-1.html`
    - `welcome-2.html`
    - `welcome-3.html`
  - `feature-announcements/`
    - `major-feature.html`
    - `minor-update.html`
  - `notifications/`
    - `comment-notification.html`
    - `weekly-digest.html`
  - `transactional/`
    - `password-reset.html`
    - `invoice-receipt.html`
  - `re-engagement/`
    - `inactive-7days.html`
    - `winback-30days.html`

#### Design Assets
- `/Users/clawdia/.openclaw/workspace/prdforge-pack/assets/email-assets/`
  - `header-banners/` (various header images)
  - `icons/` (email-specific icons)
  - `product-shots/` (feature screenshots)
  - `social-icons/` (social media icons)

#### Testing Reports
- `/Users/clawdia/.openclaw/workspace/prdforge-pack/artifacts/visuals/`
  - `email-client-testing-report.md`
  - `email-performance-metrics.csv`
  - `a-b-testing-results.md`

## Next Steps
1. **Create HTML templates** with inline CSS
2. **Design header images** and icons
3. **Set up email testing** with Litmus/Email on Acid
4. **Integrate with email service** (SendGrid, Postmark, etc.)
5. **Configure automation workflows** for each series
6. **Monitor performance metrics** and optimize

## Success Metrics
- **Open rate:** > 30% for marketing emails
- **Click-through rate:** > 5% for CTAs
- **Conversion rate:** > 2% for feature adoption
- **Unsubscribe rate:** < 0.5%
- **Spam complaints:** < 0.1%
- **Re-engagement:** > 15% of inactive users