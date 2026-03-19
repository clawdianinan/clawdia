# Documentation Linking System for Accessibility Info Buttons

## Overview
The Accessibility Info Buttons system links UI elements to relevant documentation sections. Each info button opens the corresponding documentation section in a new tab.

## Documentation Structure
```
/docs
├── index.html
├── usage/
│   ├── credits.md          # Credit system explanation
│   └── getting-started.md  # Basic usage guide
├── ai/
│   ├── models.md           # AI model overview
│   ├── models/gpt-3.5.md   # GPT-3.5 details
│   ├── models/gpt-4.md     # GPT-4 details
│   └── models/claude-3.md  # Claude 3 details
├── export/
│   ├── formats.md          # Export formats overview
│   ├── pdf.md              # PDF export details
│   ├── docx.md             # Word export details
│   └── markdown.md         # Markdown export details
├── billing/
│   ├── plans.md            # Plan comparison
│   ├── free.md             # Free plan details
│   ├── pro.md              # Pro plan details
│   ├── enterprise.md       # Enterprise plan details
│   ├── upgrades.md         # Upgrade process
│   └── cancellation.md     # Cancellation policy
└── help/
    ├── export.md           # Export help
    └── faq.md              # Frequently asked questions
```

## Anchor Link System
Each documentation section should have anchor links for direct navigation:

```html
<!-- In usage/credits.md -->
<h2 id="credit-system">Credit System</h2>
<p>Credits are used for PRD generation and exports...</p>

<h3 id="monthly-reset">Monthly Reset</h3>
<p>Credits reset on the first of each month...</p>

<h3 id="unused-credits">Unused Credits</h3>
<p>Unused credits do not roll over to the next month...</p>
```

## Component Integration Examples

### 1. Credit Counter
```typescript
<AccessibilityInfo
  elementId="credit-counter"
  docSection="usage/credits"
  tooltipText="Credits are used for PRD generation and exports. Free tier includes 10 monthly credits."
/>
```
**Opens:** `/docs#usage/credits`

### 2. Model Selection
```typescript
<AccessibilityInfo
  elementId="model-selection"
  docSection="ai/models"
  tooltipText="Choose the AI model that best fits your needs..."
/>
```
**Opens:** `/docs#ai/models`

### 3. Export Button
```typescript
<AccessibilityInfo
  elementId="export-pdf"
  docSection="export/pdf"
  tooltipText="PDF format provides professional formatting..."
/>
```
**Opens:** `/docs#export/pdf`

## Implementation Notes

### 1. URL Construction
The component constructs URLs using:
```typescript
const docUrl = `/docs#${docSection}`;
window.open(docUrl, '_blank', 'noopener,noreferrer');
```

### 2. Security Considerations
- Use `noopener` and `noreferrer` for security
- Ensure documentation is served over HTTPS
- Validate docSection input to prevent XSS

### 3. Fallback Behavior
If a documentation section doesn't exist:
1. Open the main documentation page
2. Show a toast notification
3. Log the missing section for tracking

### 4. Analytics Tracking
Track documentation access:
```typescript
// In the component
const handleClick = () => {
  trackEvent('docs_access', {
    elementId,
    docSection,
    timestamp: Date.now()
  });
  window.open(`/docs#${docSection}`, '_blank', 'noopener,noreferrer');
};
```

## Testing Checklist

### Documentation Links
- [ ] All docSection values map to existing documentation
- [ ] Anchor links work correctly
- [ ] Documentation opens in new tab
- [ ] Security attributes are set (noopener, noreferrer)

### Component Integration
- [ ] Info buttons appear beside target elements
- [ ] Tooltips show on hover/focus
- [ ] Click opens correct documentation
- [ ] Keyboard navigation works (Tab, Enter)
- [ ] Screen readers announce correctly

### Mobile Experience
- [ ] Touch targets are large enough (44px minimum)
- [ ] Tooltips are positioned correctly on mobile
- [ ] Documentation is mobile-responsive

## Maintenance Guidelines

### Adding New Documentation Sections
1. Create the documentation file in `/docs/`
2. Add anchor links for key sections
3. Update the component's `docSection` prop
4. Test the link works correctly

### Updating Tooltip Text
1. Keep tooltips concise (2-3 sentences max)
2. Focus on what the user needs to know
3. Include action-oriented language
4. Test with screen readers

### Monitoring Usage
1. Track which documentation sections are accessed
2. Monitor for broken links
3. Gather feedback on helpfulness
4. Update documentation based on usage patterns

## Example Documentation Page Structure

```markdown
# Usage: Credits

## Credit System
Credits are the currency used within PRDForge for generating PRDs and exporting documents.

### How Credits Work
- Each PRD generation consumes credits based on the AI model used
- Exporting documents also consumes credits
- Credits are replenished monthly based on your plan

### Plan Tiers
- **Free:** 10 credits/month
- **Pro:** 50 credits/month  
- **Enterprise:** 200 credits/month + rollover

### Best Practices
- Use GPT-3.5 for simple PRDs to save credits
- Export only when you need to share externally
- Upgrade your plan if you regularly run out of credits

---

*Last updated: March 18, 2026*
```

This documentation structure ensures users get the information they need while maintaining a clean, organized help system.