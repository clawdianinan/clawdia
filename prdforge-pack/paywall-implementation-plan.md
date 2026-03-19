# PRDForge Paywall Implementation Plan

## Final Decisions (Confirmed)
- **Pro Plan:** $19/month with 300 credits (was $29 with 500)
- **Export:** Included in credits for all tiers (1 credit = PRD generation + export)
- **API Access:** Available for all tiers
- **All other features:** As existing in codebase

## Paywall Placement Strategy

### Primary Paywall Triggers (Priority 1)

#### 1. Credit Check Before PRD Generation
**Location:** `src/components/workspace/views/IdeaIntakeView.tsx` (Line 484)
**Trigger:** In `handleGeneratePRD()` function before `generatePRD.mutate()`
**Logic:**
```javascript
const handleGeneratePRD = () => {
  // Check if user has enough credits
  if (userCredits < creditsNeededPerPRD) {
    showPaywallModal({
      type: 'credits',
      needed: creditsNeededPerPRD,
      current: userCredits,
      upgradeTo: userTier === 'free' ? 'starter' : 'pro'
    });
    return;
  }
  generatePRD.mutate();
};
```

**Benefits:**
- Prevents failed generation attempts
- Clear upfront communication
- Good user experience
- High conversion (user wants the result)

#### 2. Project Creation Limit
**Location:** `src/pages/Dashboard.tsx` (Project creation logic)
**Trigger:** When Free user tries to create 4th project (limit is 3)
**Logic:**
```javascript
const handleCreateProject = () => {
  if (userTier === 'free' && projectCount >= 3) {
    showPaywallModal({
      type: 'projects',
      current: 3,
      limit: 3,
      upgradeTo: 'starter',
      message: "You've reached your project limit. Upgrade for 15 projects."
    });
    return;
  }
  // Create project logic
};
```

**Benefits:**
- Clear, enforceable boundary
- Natural progression point
- Users understand project value

### Secondary Paywall Triggers (Priority 2)

#### 3. Model Selection Paywall
**Location:** Model selection component (to be identified)
**Trigger:** When Free/Starter user selects Premium/Advanced model
**Logic:**
```javascript
const handleModelSelect = (model) => {
  if (model.requiresPremium && userTier === 'free') {
    showPaywallModal({
      type: 'models',
      model: model.name,
      upgradeTo: 'starter',
      message: "Unlock Premium AI models for higher quality PRDs"
    });
    return;
  }
  if (model.requiresAdvanced && userTier !== 'pro') {
    showPaywallModal({
      type: 'models',
      model: model.name,
      upgradeTo: 'pro',
      message: "Unlock Advanced AI models for expert-level PRDs"
    });
    return;
  }
  // Select model logic
};
```

**Benefits:**
- Targets users seeking higher quality
- Clear value proposition
- Natural upgrade path

#### 4. Credit Dashboard Warnings
**Location:** Credit display component (to be identified)
**Trigger:** When credits drop below threshold
**Logic:**
```javascript
// In credit display component
useEffect(() => {
  if (userCredits <= 4 && userTier === 'free') {
    showSoftWarning({
      type: 'credits_low',
      remaining: userCredits,
      upgradeTo: 'starter',
      message: `Only ${userCredits} credits left this month`
    });
  }
}, [userCredits]);
```

**Benefits:**
- Proactive, not reactive
- Gives users time to decide
- Less disruptive

### Tertiary Triggers (Priority 3)

#### 5. Export Paywall (Already Implemented)
**Location:** `src/components/workspace/views/ExportPaywallModal.tsx`
**Note:** Already exists - ensure it works with new credit model

#### 6. Usage-Based Upgrade Suggestions
**Trigger:** When user consistently uses 80%+ of monthly credits
**Logic:** Analytics-based, triggered at end of billing cycle

## Implementation Phases

### Phase 1: Critical Paywalls (Today)
1. **Credit check before PRD generation** (IdeaIntakeView.tsx)
2. **Project creation limit** (Dashboard.tsx)

### Phase 2: Secondary Paywalls (Post-Launch)
1. **Model selection paywall**
2. **Credit dashboard warnings**

### Phase 3: Optimization (Post-Launch)
1. **Usage-based upgrade suggestions**
2. **A/B testing different paywall timings**
3. **Personalized offers based on user behavior**

## Paywall Messaging Strategy

### Free → Starter Upgrade:
- **Value Prop:** "10x more credits (10 → 100)"
- **Message:** "You've created [X] PRDs! Upgrade for 10x more credits"
- **Social Proof:** "Join 1,000+ teams using PRDForge"

### Starter → Pro Upgrade:
- **Value Prop:** "3x more credits + Unlimited projects"
- **Message:** "Heavy user detected! Upgrade to Pro for 300 credits"
- **Discount Highlight:** "30% cheaper per credit than Starter"

### Credit-Based Messages:
- **Low credits:** "Only [X] credits left this month"
- **Out of credits:** "You need [Y] more credits to generate this PRD"
- **Project limit:** "Project limit reached ([X]/3)"

## Technical Implementation Details

### Files to Modify:
1. **`IdeaIntakeView.tsx`** - Line 484 (`handleGeneratePRD`)
2. **`Dashboard.tsx`** - Project creation logic
3. **Credit checking utility** (to be created)
4. **Paywall modal enhancements** (ExportPaywallModal.tsx)

### New Components Needed:
1. **`CreditCheckUtility.ts`** - Reusable credit checking logic
2. **`PaywallManager.tsx`** - Centralized paywall triggering
3. **`UpgradeComparisonModal.tsx`** - Tier comparison component

### Database Changes:
1. **Track paywall exposures** for analytics
2. **Monitor conversion rates** per paywall type
3. **A/B test variations** storage

## Success Metrics

### Primary Metrics:
- **Time to first paywall:** Target 15-30 minutes
- **Paywall conversion rate:** Target 3-5%
- **Revenue per paywall view**
- **Upgrade rate by paywall type**

### User Experience Metrics:
- **Satisfaction scores** after paywall exposure
- **Support tickets** about limits
- **Churn rate** after paywall

### Business Metrics:
- **Free → Paid conversion rate**
- **Average Revenue Per User (ARPU)**
- **Customer Lifetime Value (LTV)**

## Risk Mitigation

### User Experience Risks:
- **Risk:** Paywalls feel too aggressive
- **Mitigation:** Soft modals, clear value, easy dismissal
- **Monitoring:** Track abandonment rates

### Conversion Risks:
- **Risk:** Users leave instead of upgrading
- **Mitigation:** Clear benefits, testimonials, limited-time offers
- **Monitoring:** A/B test messaging

### Technical Risks:
- **Risk:** Paywall bugs block legitimate usage
- **Mitigation:** Thorough testing, fallback mechanisms
- **Monitoring:** Error tracking, user feedback

## Timeline

### Immediate (Today):
1. Implement Phase 1 paywalls
2. Test with mock users
3. Deploy with Phase 2 completion

### Week 1 Post-Launch:
1. Monitor conversion metrics
2. Adjust timing based on data
3. Implement Phase 2 paywalls

### Month 1 Post-Launch:
1. A/B test optimizations
2. Implement Phase 3 features
3. Analyze full funnel conversion

## Next Steps

1. **Implement credit check** in `IdeaIntakeView.tsx`
2. **Implement project limit** in `Dashboard.tsx`
3. **Test paywall flows** with QA team
4. **Deploy with Phase 2 completion**
5. **Monitor and optimize** based on real user data

This plan ensures paywalls feel like natural progression points rather than barriers, optimizing conversion while maintaining excellent user experience.