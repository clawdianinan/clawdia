# Accessibility Information

PRDForge is committed to making our platform accessible to everyone. This document outlines the accessibility features, keyboard shortcuts, and customization options available to ensure all users can effectively use our platform.

## Keyboard Shortcuts Reference

### Global Shortcuts
These shortcuts work throughout the PRDForge application:

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl/Cmd + N` | New Project | Create a new PRD project |
| `Ctrl/Cmd + O` | Open Project | Open an existing project |
| `Ctrl/Cmd + S` | Save | Save current project |
| `Ctrl/Cmd + Shift + S` | Save As | Save project with new name |
| `Ctrl/Cmd + P` | Print/Export | Open export dialog |
| `Ctrl/Cmd + F` | Find | Search within current document |
| `Ctrl/Cmd + G` | Find Next | Find next occurrence |
| `Ctrl/Cmd + Shift + G` | Find Previous | Find previous occurrence |
| `Ctrl/Cmd + Z` | Undo | Undo last action |
| `Ctrl/Cmd + Y` | Redo | Redo last undone action |
| `Ctrl/Cmd + /` | Help | Open help menu |
| `Esc` | Close/Cancel | Close current dialog or menu |

### Editor Shortcuts
When working in the PRD editor:

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Tab` | Indent | Indent selected text |
| `Shift + Tab` | Outdent | Outdent selected text |
| `Ctrl/Cmd + B` | Bold | Toggle bold formatting |
| `Ctrl/Cmd + I` | Italic | Toggle italic formatting |
| `Ctrl/Cmd + U` | Underline | Toggle underline formatting |
| `Ctrl/Cmd + K` | Insert Link | Add hyperlink |
| `Ctrl/Cmd + Shift + 1` | Heading 1 | Apply Heading 1 style |
| `Ctrl/Cmd + Shift + 2` | Heading 2 | Apply Heading 2 style |
| `Ctrl/Cmd + Shift + 3` | Heading 3 | Apply Heading 3 style |
| `Ctrl/Cmd + Shift + L` | Bulleted List | Toggle bulleted list |
| `Ctrl/Cmd + Shift + N` | Numbered List | Toggle numbered list |
| `Ctrl/Cmd + Shift + C` | Code Block | Insert code block |
| `Ctrl/Cmd + Shift + T` | Table | Insert table |

### Navigation Shortcuts
For moving around the application:

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl/Cmd + 1` | Dashboard | Go to dashboard |
| `Ctrl/Cmd + 2` | Projects | Go to projects list |
| `Ctrl/Cmd + 3` | Templates | Go to templates library |
| `Ctrl/Cmd + 4` | Credits | Go to credits page |
| `Ctrl/Cmd + 5` | Settings | Go to settings |
| `Ctrl/Cmd + ,` | Preferences | Open preferences |
| `Ctrl/Cmd + L` | Focus Search | Focus on search bar |
| `Tab` / `Shift + Tab` | Navigate Elements | Move between interactive elements |
| `Enter` / `Space` | Activate | Activate focused element |
| `Arrow Keys` | Navigate | Move within lists and menus |

## Screen Reader Compatibility

PRDForge is designed to work seamlessly with popular screen readers including:

### Supported Screen Readers
- **NVDA** (Windows)
- **JAWS** (Windows)
- **VoiceOver** (macOS, iOS)
- **TalkBack** (Android)
- **Narrator** (Windows)

### Screen Reader Optimizations

#### 1. Semantic HTML Structure
- Proper heading hierarchy (h1-h6)
- ARIA landmarks and roles
- Descriptive link text
- Form labels and instructions

#### 2. Dynamic Content Announcements
- Live region for notifications
- Status updates for async operations
- Error message announcements
- Success confirmation alerts

#### 3. Focus Management
- Logical tab order
- Skip navigation links
- Focus trapping in modals
- Return focus after dialog close

#### 4. Image Alternatives
- Descriptive alt text for all images
- Decorative images marked as aria-hidden
- Complex diagrams with long descriptions
- Chart data in accessible tables

### Screen Reader Testing
We regularly test with:
- VoiceOver on macOS and iOS
- NVDA on Windows
- JAWS on Windows
- TalkBack on Android

## High Contrast Mode Setup

### Browser High Contrast Mode
PRDForge automatically detects and adapts to system high contrast settings:

#### Windows
1. Open Settings → Ease of Access → High contrast
2. Toggle "Turn on high contrast"
3. PRDForge will automatically adjust colors

#### macOS
1. Open System Preferences → Accessibility → Display
2. Check "Increase contrast"
3. PRDForge will use high contrast theme

#### Browser Extensions
PRDForge is compatible with:
- **High Contrast** (Chrome extension)
- **Dark Reader** (all browsers)
- **NoSquint** (Firefox)

### PRDForge High Contrast Theme
Enable our built-in high contrast theme:

1. Go to Settings → Appearance
2. Select "High Contrast" theme
3. Customize colors if needed

#### High Contrast Theme Features:
- **Text/Background Ratio**: Minimum 7:1 contrast ratio
- **Color Independence**: All information conveyed with color also available without color
- **Focus Indicators**: Clear, high-contrast focus rings
- **Button States**: Distinct styles for hover, focus, active states

### Custom Color Overrides
For users with specific color needs:

1. **Custom CSS Injection**:
   ```css
   /* Example: Yellow text on black background */
   body {
     background-color: #000000 !important;
     color: #FFFF00 !important;
   }
   
   a {
     color: #FFA500 !important;
   }
   ```

2. **Browser Style Overrides**:
   - Firefox: `about:config` → `browser.display.document_color_use`
   - Chrome: Extensions like "Stylus" or "User CSS"

## Reduced Motion Preferences

### System-Level Reduction
PRDForge respects system reduced motion settings:

#### Windows
1. Settings → Ease of Access → Display
2. Turn on "Show animations in Windows"

#### macOS
1. System Preferences → Accessibility → Display
2. Check "Reduce motion"

#### Web Standards
PRDForge uses the `prefers-reduced-motion` media query:
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### PRDForge Motion Reduction Options

#### 1. Animation Controls
In Settings → Accessibility:
- **Reduce animations**: Minimize UI animations
- **Disable parallax**: Remove parallax scrolling effects
- **Simplify transitions**: Use simple fade transitions

#### 2. Progress Indicators
Alternative progress indicators when motion is reduced:
- Static progress bars
- Percentage text display
- Step-by-step lists instead of animated sequences

#### 3. Loading States
- Static loading messages instead of spinners
- Progress percentage instead of indeterminate indicators
- Immediate content display when possible

### Custom Motion Preferences
Advanced users can customize:

1. **Animation Speed Control**:
   - 0.5x speed
   - 1x speed (default)
   - 2x speed
   - Disable all animations

2. **Transition Preferences**:
   - Fade transitions only
   - Slide transitions only
   - No transitions

## Additional Accessibility Features

### 1. Text Size Adjustment
- Browser zoom support up to 400%
- Independent text scaling in editor
- Responsive layout that adapts to text size

### 2. Focus Management
- Visible focus indicators
- Logical tab order
- Skip to content links
- Keyboard trap prevention

### 3. Form Accessibility
- All form fields have labels
- Error messages are announced
- Required fields are clearly marked
- Form validation is accessible

### 4. Multimedia Accessibility
- Video captions support
- Audio transcripts
- Accessible media players
- Descriptive audio tracks

### 5. Cognitive Accessibility
- Clear, consistent navigation
- Predictable interactions
- Error prevention and recovery
- Help and documentation

## Assistive Technology Support

### 1. Switch Devices
- Full keyboard navigation
- Customizable keyboard shortcuts
- Switch access compatibility

### 2. Voice Control
- VoiceOver/Voice Control compatibility
- Dragon NaturallySpeaking support
- Windows Speech Recognition

### 3. Screen Magnifiers
- ZoomText compatibility
- Windows Magnifier support
- macOS Zoom compatibility

### 4. Braille Displays
- Refreshable braille support
- Braille translation for content
- Navigation via braille display

## Reporting Accessibility Issues

### How to Report
1. **Email**: accessibility@prdforge.com
2. **In-app**: Help → Report Accessibility Issue
3. **GitHub**: [PRDForge Accessibility Issues](https://github.com/prdforge/accessibility/issues)

### What to Include
- Description of the issue
- Steps to reproduce
- Assistive technology used
- Browser and OS information
- Screenshots or screen recordings (optional)

### Response Time
- **Critical issues**: 24-48 hours
- **Major issues**: 3-5 business days
- **Minor issues**: 1-2 weeks
- **Enhancement requests**: Added to roadmap

## Accessibility Compliance

### Standards Compliance
PRDForge aims to comply with:
- **WCAG 2.1 AA**: Web Content Accessibility Guidelines
- **Section 508**: U.S. federal accessibility standard
- **ADA**: Americans with Disabilities Act
- **EN 301 549**: European accessibility standard

### Ongoing Improvements
- Monthly accessibility audits
- Regular user testing with disabled users
- Continuous compliance monitoring
- Quarterly accessibility training for team

## Resources and Support

### Documentation
- [Accessibility User Guide](https://docs.prdforge.com/accessibility)
- [Keyboard Shortcuts Cheat Sheet](https://docs.prdforge.com/shortcuts)
- [Screen Reader Testing Guide](https://docs.prdforge.com/screen-readers)

### Community Support
- [Accessibility Forum](https://community.prdforge.com/accessibility)
- [User Groups](https://community.prdforge.com/groups)
- [Monthly Webinars](https://prdforge.com/webinars)

### Training
- Free accessibility training sessions
- Custom training for organizations
- Certification program (coming soon)

---

**Our Commitment**: PRDForge is dedicated to making our platform accessible to everyone. If you encounter any accessibility barriers or have suggestions for improvement, please contact our accessibility team at accessibility@prdforge.com.

Last Updated: March 2026  
Accessibility Version: 2.1