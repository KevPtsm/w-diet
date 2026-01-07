---
stepsCompleted: [1, 2, 3, 4, 6, 7, 8, 9, 10, 11]
inputDocuments:
  - '_bmad-output/analysis/brainstorming-session-2025-12-29.md'
workflowType: 'prd'
lastStep: 11
documentCounts:
  briefCount: 0
  researchCount: 0
  brainstormingCount: 1
  projectDocsCount: 0
status: 'complete'
---

# Product Requirements Document - w-diet

**Author:** Kevin
**Date:** 2025-12-30

## Executive Summary

w-diet is an iOS-native nutrition app that combines automated metabolic cycling with empowering coaching to help German students and young professionals lose weight without the shame, complexity, or cognitive load of traditional diet apps. Built on the research-backed MATADOR method, w-diet automates the decision-making around diet phases while providing transparent explanations of the science behind each recommendation.

The app centers on a simple promise: "Just follow the app and not think further." Users receive guidance through an empowering fire character that coaches rather than judges, with the system automatically managing 2-week diet/maintenance cycles, calorie targets, and eating windows. Unlike passive tracking apps, w-diet actively guides users through their weight loss journey while explaining the "why" behind every decision through integrated research references and educational content.

The product addresses a critical gap in the current market: existing diet apps either oversimplify (becoming mere calorie counters) or overcomplicate (overwhelming users with decisions). w-diet solves this by handling complexity through automation while satisfying intellectual curiosity through transparent education. The result is "guidance without shame" - users understand the science but don't have to manage the complexity.

### What Makes This Special

**The Core Differentiator: Guidance + Explanation**

What separates w-diet from "just another calorie tracking app" is the combination of **active guidance** with **transparent explanation**. The app doesn't just track - it directs, automates, and teaches.

**Guidance means:**
- Automated MATADOR cycling (app switches diet/maintenance phases every 2 weeks without user intervention)
- Proactive coaching through the fire character (tells users what to do, when, and why)
- Decision automation (calorie targets, phase transitions, meal timing all handled by the system)
- "Just follow" simplicity (users execute, app orchestrates)

**Explanation means:**
- "Why Like This?" educational section with academic research references
- Transparent methodology (MATADOR study, intermittent fasting research cited and linked)
- Just-in-time learning (when users experience phase switch, they can learn why it happened)
- Intellectual satisfaction for student/professional demographic

**Together, they create:**
- **Trust through transparency** - Users understand the research backing each recommendation
- **Simplicity through automation** - Users don't decide when to cycle or what their targets should be
- **Educated discipline** - Target demographic wants to understand the science but doesn't want to manage the complexity

**The breakthrough moment:** Week 3, when the app automatically switches to maintenance calories, the cycle timer updates, and users tap "Why am I eating more now?" They read about metabolic adaptation from the MATADOR study and realize: *"The app is smarter than me about this. I can just trust it and follow."*

**Unique Elements:**

1. **MATADOR Cycling Automation** - Only app that implements research-backed 2-week deficit/maintenance rotation fully automated
2. **Week 1 Strategy** - Starts at maintenance calories to build habit before stress, addressing 80% dropout rate
3. **Guidance + Explanation Combo** - Active coaching PLUS transparent research references (not just passive tracking)
4. **Fire Coach Character** - Empowering coach providing "guidance without shame" (forgiving thresholds, supportive messaging)
5. **Forgiving Design** - 70% macro threshold = success (green smiley), compassion built into core architecture
6. **Roar Reward System** - Haptic + audio celebrations for milestones, emotional validation without human judgment
7. **Offline-First Performance** - Native Swift architecture delivers <50ms dashboard loads, works without internet
8. **Ad-Free Free Tier** - Core features free forever (vs MyFitnessPal/Yazio ad fatigue)

**Future Vision (Phase 2+):**
- **Photo Food Scanning** - AI-powered plate recognition for instant meal logging (Phase 2 Premium)
- **Menu Scanning** - Camera OCR + AI analysis + A/B/C/D/E ratings for restaurant ordering (Phase 2 Premium)
- **Mental Focus Mode** - Cognitive performance meal recommendations (Phase 3 feature)
- **B2B Corporate Wellness** - HR dashboards, company-paid subscriptions (Phase 4 enterprise scale)

**Founder Credibility:** Built by Kevin, who lost 60kg using this exact methodology while balancing university studies. The app embodies lived experience: "guidance I wished for when I was overwhelmed by traditional diet apps."

### Design Language

**Minimalist Approach (Duolingo-inspired):**
- Clean, simple interface optimized for students and young professionals
- Generous white space, bold typography, clear hierarchy
- Simple color system aligned with emotional feedback (green = success, yellow = caution, red = concern)
- Friendly and approachable while maintaining professional credibility

**Fire Character Design:**
- Minimalist geometric fire face (app icon and in-app personality)
- Professional-friendly static illustrations with personality variations:
  - 🔥 Default: Confident, calm presence
  - 🔥🤓 Glasses: Educational content/"Why Like This?" explanations
  - 🔥💪 Strong: Milestone celebrations, cycle completions
  - 🔥😌 Gentle: Week 1 supportive messaging
- No animations in POC (performance-focused, add polish post-validation)
- Gender-neutral for POC (adaptive versions deferred to Phase 2)
- Subtle enough for professional settings while maintaining encouraging personality

**Primary action focus:**
- Dashboard → Meal logging → Weight tracking → Education (in that priority order)
- Every screen optimized for <2 minute interactions (quick check-in pattern)
- Progressive disclosure (complexity hidden until needed)

## Project Classification

**Technical Type:** mobile_app (iOS-native, Swift/SwiftUI)
**Domain:** general (nutrition/wellness, no medical device classification)
**Complexity:** low-to-medium
**Project Context:** Greenfield - new product

**Platform Strategy:**
- **Phase 1 (POC - Weeks 1-10):** iOS native app only (iPhone, iOS 16+)
- **Phase 2 (Future):** Native Android app (Kotlin/Jetpack Compose)
- **Phase 3 (Future):** Web app for cross-platform access

**Rationale for iOS-first approach:**
- Target demographic (students + young professionals) has high iOS adoption in Germany
- Native Swift performance meets core requirement (<50ms dashboard)
- Faster POC development with SwiftUI vs cross-platform frameworks
- Future Android build in Kotlin maintains platform-specific excellence rather than compromised cross-platform experience

**Technical Foundation:**
- **Frontend:** Swift + SwiftUI (native iOS performance)
- **Local Storage:** SQLite (Core Data or GRDB.swift for offline-first architecture)
- **Backend:** Supabase (PostgreSQL, Auth, Realtime sync)
- **Performance Targets:** <50ms dashboard load, <300ms actions, 60fps animations (where used)
- **Offline Capability:** 100% functional without internet (syncs in background when online)

**Domain Considerations:**
- Nutrition guidance (not medical diagnosis/treatment - avoids FDA/healthcare regulation)
- GDPR compliance for German/EU users (health data privacy)
- App Store nutritional content guidelines
- Clear disclaimers (guidance, not medical advice)
- Privacy-first design (data stays local, optional cloud sync)

**Business Model:**
- Freemium (Free tier with core features / Premium €5-7/month / Pro €10-15/month)
- Target market: German students (primary focus, 80%) + Young professionals (20%)
- Revenue strategy: Free tier drives adoption, Premium tier monetizes engaged users, Pro tier for power users
- Future B2B corporate wellness (Phase 4): €12-15/employee/month for enterprise clients

**Development Timeline:**
- University POC requirement: 10 weeks (Weeks 1-10)
- Soft launch with PwC/BCG pilot: Weeks 11-18
- B2B corporate pilot expansion: Weeks 19-30
- Legitimization & enterprise sales: Weeks 31-52

### POC Scope (Weeks 1-10)

**Goal:** Prove core hypothesis - MATADOR automation + Fire coaching + Educational transparency creates sustainable behavior change.

**Core Features (Must Have):**

**🎯 Foundation Features (The Basics):**

*Authentication & Onboarding:*
- Supabase authentication (Google/Apple Sign-In + Email/Password)
- 5-step onboarding flow:
  1. Authentication
  2. Goal selection (Weight Loss active, Maintain/Bulk "Coming Soon")
  3. Calorie target (manual entry OR calculated from weight/age/gender/activity/height)
  4. Eating window setup (6-hour constraint, user picks start time)
  5. Dashboard reveal with tour

*Core Dashboard:*
- MATADOR cycle timer ("Day X of 14 - Diet/Maintenance Phase")
- Calorie progress bar (consumed / target)
- Macro tracking with emotional smileys (Protein/Carbs/Fats/Fiber)
  - 70-100% = Green 😊 (forgiving threshold)
  - 50-69% = Yellow 😐
  - <50% = Red ☹️
- Smileys hidden until first meal logged (progressive disclosure)
- Quick action buttons (Brunch/Snack/Dinner shortcuts)

*Manual Meal Logging:*
- Simple form: Meal name, Calories, Protein, Carbs, Fats, Fiber
- Save to SQLite immediately (instant feedback)
- Dashboard updates in real-time (macro smileys, calorie progress)

*Daily Weight Tracking:*
- Weight entry form (kg, with 0.1kg precision)
- 7-day rolling average calculation (local logic)
- Trend indicator (📉 green down / 📊 yellow stable / 📈 red up)
- Single roar on weigh-in (haptic vibration + sound file)
- Double roar if 7-day average trending toward goal

*MATADOR Cycling Automation:*
- Auto-switch diet ↔ maintenance every 14 days
- Calorie target updates automatically (30% variance: e.g., 1900 diet / 2300 maintenance)
- Cycle timer counts down to next phase
- All logic runs locally (no server dependency)
- **Week 1 special:** Start at MAINTENANCE calories (build habit without stress)

*Fire Character (Minimalist):*
- Static minimalist geometric fire face (Duolingo-inspired)
- 4 variations:
  - 🔥 Default (confident, calm)
  - 🔥🤓 Glasses (educational content)
  - 🔥💪 Strong (milestone celebrations)
  - 🔥😌 Gentle (Week 1 supportive messaging)
- Gender-neutral for POC (single design)
- No animations (performance priority)
- Roar system: Haptic + sound only (no visual animation)

*"Why Like This?" Education Section:*
- Simple markdown page explaining MATADOR study
- Links to academic research (MATADOR study paper, intermittent fasting research)
- Sections: Why 2-week cycling? Why maintenance first? Why 6-hour window?
- Accessible via dashboard info button
- Tracked via `why_like_this_opened` event

*Streak Tracking:*
- Daily streak counter (increments on meal logging + weight logging)
- Displayed on dashboard
- Persists in SQLite (survives app restarts)

*Offline-First Implementation:*
- All features 100% functional without internet
- SQLite stores: user profile, weight logs, meal logs, cycle state, streak data, analytics events
- Background Supabase sync when online (unsynced records flagged `synced = 0`)
- Sync retry logic on reconnect

*Lightweight Analytics (Foundation):*
- 11 core events tracked (session, screen, onboarding, engagement)
- Single `logEvent()` function
- SQLite table → Supabase sync
- ~6 hours total implementation overhead

*Quality Infrastructure:*
- Unit tests for critical paths (MATADOR logic, calculations)
- Crashlytics/Sentry integration (crash monitoring)
- Error logging event tracking
- Week 9 TestFlight beta testing (10 users, crash/battery validation)

**Deferred to Phase 2+ (Good-to-Have, Not POC):**
- ❌ Photo food scanning (Phase 2 Premium feature)
- ❌ Menu scanning with AI ratings (Phase 2 Premium feature)
- ❌ AI meal recommendations (Phase 3 Premium feature)
- ❌ Food database search (Phase 3 Premium feature)
- ❌ Gender-adaptive fire (single design for POC)
- ❌ Fire roar animations (haptic + sound only, no visual animation)
- ❌ Mental Focus Mode (Phase 3 feature)
- ❌ Advanced analytics (30/90-day trends, Pro feature)
- ❌ Photo progress tracking (Pro feature)
- ❌ Social features/"Pride" system (post-validation)
- ❌ Barcode scanning (future enhancement)

**Rationale:** Focus POC on proving the **core differentiators** (MATADOR automation + Fire coaching + Education) work BEFORE adding scanning features. If the basics don't create behavior change, scanning won't save it. Validate the moat first, add accelerators later.

### POC Validation Strategy (Weeks 1-10)

The university POC focuses on behavioral validation with German students before optimizing monetization. Success will be measured through lightweight event tracking built into the offline-first architecture, with emphasis on **core loop adoption and engagement quality**.

**Core Validation Questions:**
1. **Do users complete onboarding?** (Target: >70% activation rate)
2. **Do users continue past Week 1?** (Target: >40% retention, beating 80% industry dropout)
3. **Do users complete first 28-day cycle?** (Target: >15% cycle completion validates MATADOR automation)
4. **Do users engage with educational content?** (Target: >40% tap "Why Like This?" section validates explanation differentiator)
5. **How much time do users spend in-app?** (Target: <3 min avg session validates "quick guidance" UX, >10% time in education validates intellectual engagement)
6. **Do users trust the automation?** (Target: >80% of users who reach Day 14 continue through phase switch validates trust in system)

**Measurement Approach:**

*Lightweight event tracking integrated into offline-first SQLite architecture:*

**11 Core Events Tracked:**
- `onboarding_started`, `onboarding_step_completed` (each of 5 steps), `onboarding_finished`
- `meal_logged` (with metadata: source [manual], meal_type)
- `weight_logged`
- `why_like_this_opened` (with metadata: topic)
- `cycle_phase_switched` (with metadata: from/to phase)
- `session_start`, `session_end` (with metadata: duration_seconds)
- `screen_view`, `screen_exit` (with metadata: screen_name, time_spent_seconds)

**Implementation:**
- Single `logEvent()` function called at key user actions
- Events stored in local SQLite table (same offline-first pattern as meal/weight data)
- Background sync to Supabase `analytics_events` table when online
- SwiftUI `.onAppear`/`.onDisappear` modifiers for automatic screen time tracking
- Total implementation overhead: ~6 hours across 10-week POC

**Screen-Level Engagement Tracking:**
Priority screens monitored for time-on-screen analysis:
- Dashboard (home screen engagement)
- Meal Logging (core action validation)
- "Why Like This?" Education (differentiator validation)
- Onboarding steps (friction point identification)
- Weight Logging (secondary habit tracker)
- Profile/Settings (customization interest)

**Analysis Framework:**

*Session Metrics:*
- Average session duration (target: <3 minutes = efficient "quick check-in" pattern)
- Median sessions per day (target: 3 = brunch log, dinner log, evening weight check)
- Total daily active time per user

*Screen Time Distribution:*
- % of time on each major screen (identifies high-value features)
- Onboarding step duration analysis (identifies friction/confusion points)
- Education section time (validates professional engagement with science)

*Cohort Analysis:*
- Weekly cohorts tracked separately (Cohort 1: Direct recruitment, Cohort 2: Guerrilla marketing flyers, Cohort 3: Word-of-mouth)
- Compare activation, retention, education engagement, cycle completion rates across acquisition channels
- Informs Phase 2 student acquisition strategy

*Qualitative Validation:*
- 10-15 user interviews at Day 14 and Day 28 (post-phase-switch feedback)
- Questions focus on: **MATADOR automation trust**, education content value, fire character appeal, willingness-to-pay for future Premium features
- Test price sensitivity: "Would you pay €5/month? €7/month? €10/month for AI meal recommendations?" (inform Phase 3 pricing)
- Document insights for UX refinement and business plan narrative

**Success Criteria:**

| Metric | Target | Minimum Viable |
|--------|--------|----------------|
| Activation Rate | >70% | >60% |
| Week 1 Retention | >40% (beating 80% dropout) | >30% |
| First Cycle Completion | >15% (Day 28 reached) | >10% |
| Education Engagement | >40% tap "Why Like This?" | >25% |
| Phase Switch Continuation | >80% continue past Day 14 | >65% |
| Avg Session Duration | <3 min (efficient check-in) | <5 min |
| Meal Logging Consistency | >70% log 5+ meals/week | >50% |

**Outcome Scenarios:**
- **Target met:** Strong fundamentals validation, proceed confidently to Phase 2 (add Photo/Menu scanning Premium features)
- **Minimum Viable met:** Qualified validation, identify specific weaknesses (onboarding friction, education clarity, phase switch confusion) and fix before scaling
- **Below Minimum Viable:** Pivot required - fundamentals don't create behavior change, MATADOR automation not trusted, education not valued

**Deliverable for Business Plan:**

The POC validation section of the business plan will include:
1. **Hypothesis:** MATADOR automation + Fire coaching + Educational transparency creates sustainable behavior change without manual decision-making
2. **Measurement Framework:** 11 tracked events across onboarding, engagement, education, and phase switching
3. **Early Results:** Week 1-10 actual cohort data (activation, Week 1 retention, cycle completion, education engagement)
4. **Behavioral Insights:** How users respond to automated phase switches, education content consumption patterns, trust formation timeline
5. **Qualitative Findings:** Student interview themes about automation trust, fire character appeal, education value, willingness-to-pay for future features
6. **Pricing Validation:** Data to support €5-7/month Premium tier (Phase 2) with scanning features
7. **Next Steps:** How Phase 2 adds Photo/Menu scanning to unlock monetization, Phase 3 adds AI recommendations

This data-driven approach validates the core differentiators (Guidance + Explanation + MATADOR) before adding scanning accelerators in Phase 2.

## Success Criteria

### User Success (The Cascade Model)

User success in w-diet follows a causal chain where each stage unlocks the next:

**Stage 1: Results Formation (Days 1-14)**
- User experiences weight loss (7-day average trending downward by Day 14)
- User feels physical changes (slimmer, clothes fitting better)
- **Success indicator:** Any downward trend in 7-day average = movement toward goal

**Stage 2: Trust Formation (Days 14-21)**
- User completes first phase switch (diet → maintenance on Day 14)
- User doesn't panic when calorie target increases
- User taps "Why Like This?" to understand MATADOR cycling
- **Success indicator:** User continues logging through maintenance phase

**Stage 3: Educated Discipline (Days 21-28+)**
- User completes full 28-day cycle (validates trust in automation)
- User understands why the system works (education engagement)
- User develops "just follow" behavior (logs consistently without questioning phases)
- **Success indicator:** User reaches Day 28 and starts second cycle

**Minimum Viable User Success (Dual Track):**

*Track 1: Outcome Success*
- 7-day average shows downward trend by Day 14 (any movement = success)
- User feels slimmer (measured via continued engagement = proxy for feeling results)

*Track 2: Behavioral Success (if outcome not achieved yet)*
- User logged meals 12+ days out of 14 (85%+ adherence)
- User logged weight 10+ days out of 14 (71%+ adherence)
- User reached Day 14 phase switch (didn't abandon app)

**Success Philosophy:**
- If Track 1 achieved: Full success, trust formed via results
- If Track 2 achieved but not Track 1: Partial success, user built habit, just needs more time
- Movement toward goal matters more than absolute numbers. The trend (📉) validates guidance, which unlocks trust, which enables long-term behavior change
- Some users are slow responders (genetics, stress, water retention) - they'll succeed in Week 3-4, not Week 2. Behavioral adherence proves engagement even when early results lag

**This dual-track approach prevents false negatives:** Users who follow the system perfectly but haven't seen scale movement yet are still on path to success.

### Business Success (Priority Hierarchy)

**Primary Success: User Traction (Proves Interest)**

*POC (Week 10):*
- 15-25 consultant beta testers (PwC colleagues + BCG network)
- POC demonstrates all core features working (especially menu scanning)
- University course passed with business plan approved

*Phase 2 (Week 18):*
- 100-150 total users (quality over quantity - consultants who actually pay)
- 80+ active weekly users (targeting high-engagement professionals)
- PwC pilot complete (20-30 users validated)
- Initial BCG cohort onboarded (if visiting associate role happens)

*Phase 3 (Week 30):*
- 300-500 total users
- 250+ active weekly users
- 2-3 corporate pilots initiated (PwC, BCG, or other consulting firms)
- Referral network growing organically within firms

*Phase 4 (Week 52):*
- 800-1,200 total users
- 600+ active weekly users
- 3-5 active corporate wellness contracts
- Established presence in German consulting/corporate market

**Validation Success: Engagement Quality (Proves It Works)**

*Key Metrics:*
- **Menu scanning adoption: 60%+** (validates killer feature - most users actually use it)
- **Menu scanning success rate: 85%+** OCR accuracy (validates technical feasibility)
- **Scan-to-order conversion: 70%+** (validates utility - scans lead to actual ordering decisions)
- Week 1 retention: 40% (beating 80% industry dropout = 2x better)
- First cycle completion: 15%+ (validates MATADOR automation)
- **Average session duration: <90 seconds** (validates time-saving for busy consultants)
- Education engagement: 30%+ tap "Why Like This?" (consultants value science but are time-constrained)
- Behavioral adherence: 70%+ meal logging among engaged users (lower than students but acceptable for busy professionals)

*These metrics prove:* **Menu scanning solves a real problem.** Consultants don't just try it once - they use it repeatedly. The core loop (menu scan + MATADOR automation) works for traveling professionals.

**Sustainability Success: Revenue (Proves Business Viability)**

*Phase 2 (Week 18):*
- **30%+ free trial → Pro conversion** (€14.99/month pricing validated)
- 25-40 Pro subscriptions (€375-600 MRR)
- €400-700 MRR target
- Track Customer Acquisition Cost (CAC): Referral-based ~€0-5/user (organic growth within firms)

*Phase 3 (Week 30):*
- **1-2 B2B corporate contracts** (€12/employee/month, 50-100 employees per contract = €600-1,200/month per contract)
- 75-125 individual Pro subscriptions (€1,125-1,875/month from B2C)
- €1,700-3,100 MRR target (B2C + B2B blended)

*Phase 4 (Week 52):*
- **3-5 B2B corporate contracts** (150-300 employees total = €1,800-3,600/month from B2B alone)
- 150-250 individual Pro subscriptions (€2,250-3,750/month from B2C)
- €4,000-7,400 MRR target (sustainable post-university income)

*Revenue philosophy:* **B2C validates product-market fit, B2B scales revenue.** Individual consultants prove willingness-to-pay, corporate contracts provide sustainable revenue at scale.

**Cost Awareness:**
- Track infrastructure costs (Supabase, GPT-4 Vision API, domain, hosting): Estimated €200-400/month at 1,000 users (higher due to AI API costs)
- Monitor CAC vs Lifetime Value (LTV): Need users to stay 2+ months if CAC = €10 (referral-based) and ARPU = €14.99/month
- **API cost management:** Menu scanning costs ~€0.02-0.05 per scan (GPT-4 Vision). At 50 scans/user/month = €1.50-1.80/user. **Gross margin: 88%** (€14.99 - €1.80 = €13.19 profit per user)
- **Cost buffer:** 8.3x coverage (€14.99 / €1.80) protects against API price increases
- Revenue should exceed infrastructure + API costs for true sustainability

**Strategic Validation: Legitimacy & Motivation (Proves External Value)**

*Phase 4 targets:*
- **3-5 corporate wellness contracts** (PwC, BCG, Deloitte, McKinsey, or tech companies)
- **HR endorsements** from at least 2 major consulting firms
- Media coverage (5+ publications: German business press, tech blogs, health/wellness publications)
- Product Hunt launch (Top 10 of the day goal - tech professional demographic)
- **Referral program success:** >40% new users come from within-company referrals

*These milestones:* Provide external validation, energize continued development, open doors to enterprise sales and larger corporate partnerships.

### 12-Month Pivot vs Persevere Thresholds

**PERSEVERE (Continue post-university):**

*Option 1: B2B Traction + Revenue*
- 2-3 corporate wellness contracts signed + €2,500+ MRR
- Proves enterprise buyers value product, sustainable post-university
- Clear path to scaling B2B sales

*Option 2: High Engagement + Willingness-to-Pay*
- Strong engagement (60%+ menu scan adoption, 30%+ free trial conversion at €14.99, 40% retention) even with only 200 users
- Proves product-market fit with consultants, needs better distribution within firms
- Clear path to monetization already working at €14.99 (room to increase to €19.99)

**PIVOT (Adjust strategy, keep core):**

*Scenario: B2C Success, No B2B Interest*
- 300+ individual Pro subscriptions (€4,500 MRR at €14.99) but zero corporate pilots
- **Pivot:** Double-down on B2C, optimize referral program, skip B2B for now. Consider increasing to €19.99 if retention strong.

*Scenario: Menu Scanning Fails, Core Tracking Works*
- Low menu scan adoption (<30%) but strong retention with manual tracking
- **Pivot:** De-emphasize menu scanning, focus on different USP (maybe Mental Focus Mode or AI meal recommendations)

*Scenario: Strong Usage, Weak Monetization*
- 500+ users, 60%+ menu scan adoption, but <10% free trial conversion at €14.99
- **Pivot:** Price resistance detected. Test €9.99/month with 50 scans/month limit, or keep €14.99 but extend free trial to 14 days

*Scenario: Unsustainable API Costs*
- 800 users but GPT-4 Vision API costs (€600/month) exceed revenue (€450 MRR at 30 Pro users)
- **Pivot:** Switch to cheaper AI model (Claude 3 Haiku), pre-load common restaurant database, optimize prompt engineering, or add usage limits

**STOP (Fundamental failure):**
- <100 users + <20% menu scan adoption + <5% conversion at €14.99 + €0 corporate interest by Week 52
- Indicates: Menu scanning doesn't solve €15/month problem, consultants don't value time-saving enough, fundamental product-market fit failure

**Decision Philosophy:** "Any outcome is data to improve from." Every scenario informs what to adjust (pricing, features, target segment, distribution). Only complete failure across all dimensions justifies stopping.

### Technical Success

**Performance (Non-Negotiable):**
- Dashboard loads <50ms (native Swift advantage)
- All user actions respond <300ms
- **Menu scanning:** <60 seconds total (camera open → OCR → AI analysis → results display)
- **OCR processing:** <3 seconds for text extraction
- **AI analysis:** <10 seconds for GPT-4 Vision response
- 60fps animations (where used, no jank)
- Zero loading spinners on critical paths (meal logging, weight logging, dashboard)
- **User perception metric:** No complaints about "slow" or "stuck" in user interviews
- **Validation:** Use Xcode Instruments in Week 8 to profile actual performance

**Battery Efficiency (Critical for Traveling Consultants):**
- **Active use:** <5% battery drain per hour (consultants travel all day, can't charge mid-flight/meeting)
- **Menu scanning:** <2% battery per scan (camera + OCR + API call - optimized for quick bursts)
- **Background:** <1% drain per hour (sync only when data changes, no polling)
- **Idle (app closed):** <0.1% drain per hour
- **Testing:** Week 9 TestFlight beta on older iPhones (iPhone 12, degraded battery)
- **Rationale:** Consultants travel 8-12 hours (flights, meetings, client dinners) without charging access - aggressive battery drain = immediate uninstall

**Reliability (Offline-First Validation):**
- 100% core features functional without internet
- SQLite ↔ Supabase sync works flawlessly (no data loss during offline→online transitions)
- App handles network failures gracefully (queue sync, retry logic, user never sees errors)
- Crash-free rate: >99.5% (industry standard for production apps)

**Data Integrity (Trust Foundation):**
- User data NEVER lost (weight logs, meal logs, streak data, cycle state)
- Sync conflicts handled gracefully (cloud timestamp wins, logged for debugging)
- GDPR compliance: User can export all data (CSV) and delete account (full purge)
- Privacy-first: Data stays local by default, cloud sync is optional enhancement
- **Zero tolerance:** Any data loss incident = critical bug, must fix before POC demo

**Quality Metrics (POC Minimum):**

*Test Coverage:*
- Critical paths 100% covered (onboarding, meal logging, weight logging, phase switching)
- Unit tests for MATADOR cycling logic (Day 14/28 transitions, calorie calculations)
- Integration tests for SQLite ↔ Supabase sync
- **Week 9 validation:** All tests passing before university demo

*Error Rate Monitoring:*
- Track `error_logged` event (metadata: error_type, screen_name, user_action)
- Target: <1% of sessions encounter errors
- Zero tolerance: Data loss errors (meal/weight log failed to save)

*Crash Reporting:*
- Integrate Crashlytics or Sentry (30 mins setup, Week 2)
- Target: >99.5% crash-free rate
- **Week 9 testing:** TestFlight beta with 10 users, monitor crashes before university demo

*Performance Monitoring:*
- Track actual dashboard load times (not just target <50ms)
- Log slow queries (>100ms) for optimization
- Use Instruments (Xcode tool) to profile Week 8 build
- Identify bottlenecks, optimize before POC demo

**For Business Plan:** Can report "POC achieved 99.8% crash-free rate, <40ms average dashboard load, 0 data loss incidents across 28-day test period with 25 beta users" - professional-grade metrics for university project.

**Scalability Readiness:**
- POC handles 100 concurrent users smoothly
- Architecture scales to 10,000 users without major rewrite
  - ✅ Acceptable: Add Redis cache, optimize queries, scale Supabase tier
  - ❌ Major rewrite: Change from SQLite to Realm, rewrite sync logic, migrate auth system
- Supabase costs stay <€100/month at 5,000 users (validates business model sustainability)
- Database schema supports future features (AI meals, social features, analytics) without migration

**Accessibility (Phase 2+ Awareness):**
- **POC:** Basic accessibility (readable fonts, adequate contrast)
- **Phase 2+:** VoiceOver support, Dynamic Type, WCAG 2.1 AA compliance
- **Rationale:** Germany has strong accessibility laws; required for university partnerships and App Store featuring

**Developer Experience (POC Constraints):**
- POC delivered in 10 weeks (university deadline met)
- Business plan completed on time with validation data
- Codebase maintainable (can add Phase 2 features without rewrite)
- Event tracking integrated from Day 1 (analytics foundation ready)
- Total quality overhead: ~4 hours across 10 weeks (unit tests as you build, Crashlytics setup, Week 9 profiling)

**Technical Failure Modes (Unacceptable):**
- Data loss (user loses weight logs or streak progress)
- Performance below targets (>100ms dashboard, >500ms actions)
- Offline mode broken (core features require internet)
- Security breach (user data exposed, auth compromised)
- Battery drain >10% per hour active use (students will uninstall)

## Product Scope

### MVP - Minimum Viable Product (POC - Weeks 1-10)

**Goal:** Prove core hypothesis (guidance + explanation + MATADOR automation works) with German student beta testers.

**Must-Have Features:**

*Authentication & Onboarding:*
- Supabase authentication (Google/Apple Sign-In + Email/Password)
- 5-step onboarding flow:
  1. Authentication
  2. Goal selection (Weight Loss active, Maintain/Bulk "Coming Soon")
  3. Calorie target (manual entry OR calculated from weight/age/gender/activity/height)
  4. Eating window setup (6-hour constraint, user picks start time)
  5. Dashboard reveal with tour

*Core Dashboard:*
- MATADOR cycle timer ("Day X of 14 - Diet/Maintenance Phase")
- Calorie progress bar (consumed / target)
- Macro tracking with emotional smileys (Protein/Carbs/Fats/Fiber)
  - 70-100% = Green 😊 (forgiving threshold)
  - 50-69% = Yellow 😐
  - <50% = Red ☹️
- Smileys hidden until first meal logged (progressive disclosure)
- Quick action buttons (Brunch/Snack/Dinner shortcuts)

*Manual Meal Logging:*
- Simple form: Meal name, Calories, Protein, Carbs, Fats, Fiber
- Save to SQLite immediately (instant feedback)
- Dashboard updates in real-time (macro smileys, calorie progress)
- No AI recommendations (deferred to Phase 3 Premium feature)
- No food database search (deferred to Phase 3 Premium feature)

*Daily Weight Tracking:*
- Weight entry form (kg, with 0.1kg precision)
- 7-day rolling average calculation (local logic)
- Trend indicator (📉 green down / 📊 yellow stable / 📈 red up)
- Single roar on weigh-in (haptic vibration + sound file)
- Double roar if 7-day average trending toward goal

*MATADOR Cycling Automation:*
- Auto-switch diet ↔ maintenance every 14 days
- Calorie target updates automatically (30% variance: e.g., 1900 diet / 2300 maintenance)
- Cycle timer counts down to next phase
- All logic runs locally (no server dependency)
- **Week 1 special:** Start at MAINTENANCE calories (build habit without stress)

*Fire Character (Minimalist):*
- Static minimalist geometric fire face (Duolingo-inspired)
- 4 variations:
  - 🔥 Default (confident, calm)
  - 🔥🤓 Glasses (educational content)
  - 🔥💪 Strong (milestone celebrations)
  - 🔥😌 Gentle (Week 1 supportive messaging)
- Gender-neutral for POC (single design)
- No animations (performance priority)
- Roar system: Haptic + sound only (no visual animation)

*"Why Like This?" Education Section:*
- Simple markdown page explaining MATADOR study
- Links to academic research (MATADOR study paper, intermittent fasting research)
- Sections: Why 2-week cycling? Why maintenance first? Why 6-hour window?
- Accessible via dashboard info button
- Tracked via `why_like_this_opened` event

*Streak Tracking:*
- Daily streak counter (increments on meal logging + weight logging)
- Displayed on dashboard
- Persists in SQLite (survives app restarts)

*Offline-First Implementation:*
- All features 100% functional without internet
- SQLite stores: user profile, weight logs, meal logs, cycle state, streak data, analytics events
- Background Supabase sync when online (unsynced records flagged `synced = 0`)
- Sync retry logic on reconnect

*Lightweight Analytics (Foundation):*
- 11 core events tracked (session, screen, onboarding, engagement)
- Single `logEvent()` function
- SQLite table → Supabase sync
- ~6 hours total implementation overhead

*Quality Infrastructure:*
- Unit tests for critical paths (MATADOR logic, calculations)
- Crashlytics/Sentry integration (crash monitoring)
- Error logging event tracking
- Week 9 TestFlight beta testing (10 users, crash/battery validation)

**Out of Scope for POC:**
- ❌ Gender-adaptive fire (single design sufficient)
- ❌ Fire roar animations (haptic + sound only)
- ❌ Mental Focus Mode (Phase 3 feature)
- ❌ AI meal recommendations (Phase 3 Premium feature)
- ❌ Food database search (Phase 3 Premium feature)
- ❌ Advanced analytics (30/90-day trends, Pro feature)
- ❌ Photo progress tracking (Pro feature)
- ❌ Social features / "Pride" system (post-validation)
- ❌ Barcode scanning (future enhancement)
- ❌ Apple Watch integration (Phase 3+)

**POC Success Criteria:**
- All must-have features functional and tested
- Performance targets met (<50ms dashboard, <5% battery active use)
- 20-30 beta testers complete at least 7 days
- Validation metrics: 60%+ activation, 30%+ Week 1 retention, 40%+ education engagement
- University business plan approved with validation data
- >99.5% crash-free rate, 0 data loss incidents

### Growth Phase (Phase 2 - Weeks 11-18)

**Goal:** Launch Premium tier with scanning features + Validate market demand.

**DUAL FOCUS:** Premium Feature Launch + Marketing Expansion

**🚀 New Premium Features (€7/month):**

**1. Photo Food Scanning (AI Plate Recognition)**
- **Integration:** Passio.ai SDK for iOS (~40-50 hours development)
- **User flow:**
  - Tap "Log Meal" → Choose "📸 Photo Scan" (Premium badge)
  - Camera opens → Take photo of plate
  - AI analyzes → Results: "Chicken breast (200g), Rice (150g), Broccoli (100g)"
  - Shows macros: 520 kcal, 45g protein, 55g carbs, 8g fat
  - User can edit before saving
  - Fire roars: "🔥 Logged! 520 kcal added to your day"
- **API Cost:** ~$0.0125/scan (1.25 cents), ~$0.625/user/month (50 scans)
- **Features:**
  - Offline queue (save photo, analyze when online)
  - Confidence scoring ("85% sure, please verify")
  - Manual editing allowed
  - Works with Fire coaching context
- **Value prop:** "Log meals in 5 seconds with AI"

**2. Menu Scanning (AI Menu Analysis + Ratings)**
- **Integration:** OCR (Google Vision or Passio OCR) + AI analysis (~50 hours development)
- **User flow:**
  - At restaurant → Tap "🍽️ Eating Out"
  - Point camera at menu → AI reads dishes
  - Fire shows A/B/C/D/E ratings for each dish
  - "🟢 Grilled Salmon (A) - 520 kcal, perfect for Diet Phase Day 5"
  - "🟡 Pasta (C) - 850 kcal, would use 80% of daily target"
  - Smart modifications: "Ask for no dressing", "Sub fries for salad"
  - One-tap to select → Auto-logs to meal
- **API Cost:** ~$0.01/scan for OCR
- **Features:**
  - Works even without nutrition data (AI estimates)
  - "Verified by community" badges (learning loop for Phase 3)
  - MATADOR context: "You're Day 5/14, I recommend the salmon"
- **Value prop:** "Know what to order before the waiter arrives"

**3. Combined Experience (The Killer Combo)**
- **Before ordering:** Menu scan → Guidance ("Order salmon")
- **After food arrives:** Photo scan → Verification ("Yep, 485 kcal - close to estimate!")
- **Learning loop:** Over time, menu estimates improve with photo data
- **Unique differentiator:** NO competitor combines both

**4. Enhanced Roar System**
- Different roar sounds (daily vs milestone)
- Triple vibration pattern for major milestones
- Milestone badges (7-day streak, 30-day streak, first cycle complete)
- Badge gallery in profile

**5. Meal History View**
- Last 30 days of meals (Premium feature)
- Scroll through past days
- See macro performance over time

**Marketing Activities:**

*Guerrilla Marketing Execution:*
- Lübeck saturation (2,000 flyers, bathroom stalls, Mensa, gym, bike racks)
- Campus events ("MATADOR Method Workshop" monthly, "Weigh-In Wednesdays" weekly)
- Fire's Den beta recruitment (100 members, Lifetime Pro access)
- Hamburg expansion initiation (identify 2 campus ambassadors)

*Content Empire Launch:*
- TikTok/Reels: 3-5 videos/week ("60 Seconds of Truth" series, Fire's Wisdom, student hacks, **scanning demos**)
- YouTube: Weekly longform (pillar video "How I Lost 60kg", MATADOR explained, app dev vlogs, **"Scan any menu" feature showcase**)
- Reddit: Build credibility + **AMA about menu/photo scanning tech**

*User Validation:*
- 5-10 user interviews at Day 28 (scanning feature adoption, Premium value perception)
- Track: Photo scan usage, menu scan usage, Premium conversion rate
- A/B test: Free tier only vs Premium upsell messaging

**Deferred to Phase 3:**
- ❌ AI meal recommendations (ChatGPT/Claude daily meal generation)
- ❌ Food database search (OpenFoodFacts integration)
- ❌ Learning loop optimization (menu + photo verification database)

**Rationale:** POC proved core loop works. Phase 2 adds the scanning "accelerators" that make Premium worth €7/month for consultants/students eating out. Justifies pricing while maintaining free tier value.

**Phase 2 Success Criteria:**
- 500 total downloads (validates guerrilla + content marketing)
- 200 active weekly users (40% activation maintained)
- **50 Premium conversions** (validates €7/month scanning features)
- **€250-350 MRR** (50 Premium × €7)
- **>60% Premium users use photo scan weekly** (validates utility)
- **>40% Premium users use menu scan monthly** (validates restaurant use case)
- 100 Fire's Den members recruited
- 5,000 TikTok followers, 500 YouTube subscribers (content traction)

### Expansion Phase (Phase 3 - Weeks 19-30)

**Goal:** Geographic expansion + Premium tier enhancements + Learning loop optimization.

**Premium Tier Enhancements (€7/month - Already Launched in Phase 2):**

*New Premium Features Added in Phase 3:*
- **AI meal recommendations** (ChatGPT/Claude API integration)
  - Prompt: "Generate 3 meals (brunch/snack/dinner) for [calories] kcal, [macros], gut health focus, German ingredients, student budget"
  - Cache daily recommendations in SQLite (available offline)
  - One-tap meal acceptance (add to log instantly)
  - MATADOR context aware ("You're in Diet Phase, here are lower-calorie options")
- **Food database search** (OpenFoodFacts API)
  - Search bar with German food database
  - Local cache of top 100 popular foods (chicken, rice, eggs, etc.)
  - Barcode scanning (future enhancement)
- **Learning Loop Optimization** (Menu + Photo Verification Database)
  - Store both menu estimates and photo actuals
  - Calculate delta: Menu said 520, photo showed 485 (7% difference)
  - Update confidence: "±10% accuracy (verified 5x)"
  - Community data: Aggregate scans across users
  - "Verified by community" badges on popular restaurants
- **Basic blacklist** (10 foods)
- **Basic favorites** (10 foods)

*Polish & Refinements:*
- Lightweight fire animations (if performance allows, 2-second clips, GPU-accelerated)
- Week 1 special messaging refinement (extra gentle fire dialogue)
- Milestone badges (7-day streak, 30-day streak, first cycle complete)
- Badge gallery in profile

*Marketing Infrastructure:*
- Referral system (invite friend → both get 1 month Premium free)
- In-app feedback mechanism

**Geographic Expansion:**
- Hamburg launch (2 campus ambassadors, 1,000 flyers, workshop)
- Kiel & Flensburg launch (1 ambassador each, 500 flyers per city)

**Professional Market Testing (20% Effort):**
- PwC colleague beta (15-20 users, collect testimonials)
- LinkedIn content (dual identity narrative: student + consultant)
- BCG cohort offer (if visiting associate role happens)

**Phase 3 Success Criteria:**
- 2,000 total downloads
- 800 active weekly users
- 150 Premium + 30 Pro conversions
- €1,200-1,800 MRR
- 20-30 professional users (PwC/BCG testing)
- 10k TikTok followers, 2k YouTube subscribers

### Vision Phase (Phase 4 - Weeks 31-52)

**Goal:** Legitimization, corporate pilot, media coverage, sustainable growth.

**Pro Tier (€10-15/month):**
- Unlimited blacklist/favorites/daily staples
- Photo progress tracking (before/after gallery, private)
- Advanced analytics (30/90-day trends, weight graphs, macro adherence charts)
- Data export (CSV/PDF reports)
- Priority support

**Mental Focus Mode:**
- Toggle on dashboard: "Need mental focus today? 🧠"
- AI meal recommendations prioritize: Omega-3, complex carbs, leafy greens, antioxidants
- Avoid sugar spikes, heavy fats, processed foods
- Tooltip links to cognitive performance research

**Social Features (Optional, Privacy-First):**
- "Pride" system (friend groups, 5-10 people)
- See friends' milestones only (NOT weight)
- Anonymous option (join random pride)
- Opt-in only

**Gender-Adaptive Fire:**
- Male/female fire variants based on user preference
- Culturally appropriate coaching tone variations

**Apple Ecosystem Integration:**
- Apple Watch: Activity data → meal timing suggestions
- Calendar sync: Detect "important meeting" → auto-trigger Mental Focus Mode
- Strava/fitness app integration

**B2B Corporate Dashboard:**
- HR admin panel (Supabase roles/permissions)
- Aggregate anonymized metrics (participation rate, engagement trends)
- NO individual weight data (GDPR compliance)
- Monthly wellness reports export

**Localization:**
- Native German notifications (not literal translations)
- Notification ID system (culturally appropriate messaging)
- A/B test German vs English effectiveness

**Legitimization Activities:**
- University partnership (official Lübeck wellness program integration)
- Corporate pilot (PwC Germany or startup, 50+ employees, 3-month trial)
- Media outreach (local news, German tech blogs, health publications)
- Product Hunt launch (Top 10 of day goal)

**Phase 4 Success Criteria:**
- 5,000 total downloads
- 2,000 active weekly users (40% activation maintained)
- 400 Premium + 80 Pro conversions
- €3,000-4,500 MRR (sustainable, enables hiring or full-time focus)
- 1 university partnership + 1 corporate pilot
- Media coverage (5+ publications)
- Product Hunt Top 10
- 20k TikTok followers, 5k YouTube subscribers

## User Journeys

### Journey 1: Lukas Weber - From Ad Fatigue to Earned Trust (Student Segment)

Lukas is a 22-year-old computer science student at Universität zu Lübeck. He's tried losing weight twice before - first with MyFitnessPal (abandoned after 2 weeks of confusing macro calculations and overwhelming features), then Yazio (which he actually liked... until they started showing ads after *every single meal log*). The ads broke his flow. Log breakfast, watch ad. Log lunch, watch ad. After three weeks of this, he uninstalled it in frustration. He wants something that *doesn't cost* but also doesn't interrupt him with ads every 30 seconds.

One Tuesday morning, sitting in a Mensa bathroom stall between lectures, he spots a flyer: "Lost 60kg. You can too. No shame, just science." A QR code leads to w-diet. The landing page shows a roaring fire and promises "Just follow the app and not think further." Free tier listed: MATADOR cycling, calorie/macro tracking, streak tracking, manual meal entry. No "watch 3 ads to unlock" nonsense. Skeptical but intrigued, he downloads it during his next lecture break.

Onboarding takes 3 minutes. Google Sign-In (he hates making new passwords). Goal: Weight Loss (Maintain/Bulk greyed out "Coming Soon" - fair enough). Calorie target: He enters his stats, app calculates 1900 kcal.

**The app shows:** "Week 1: Maintenance Phase. Target: 2300 kcal today."

Before he can react, a tooltip appears: **"🔥 Week 1 starts gentle. Why? [Tap to learn]"**

He taps. Mini-explanation (30 seconds read):
*"Most diet apps throw you into deficit on Day 1. You stress, you quit. We start Week 1 at maintenance. Build the habit first. Stress later. Trust the process."* [Start Day 1]

Okay, that makes sense. He continues to eating window setup: 12:00-18:00 fits his schedule perfectly (skips breakfast anyway, dinner before library). Dashboard loads instantly - no loading spinner, **no ads**.

Day 7: Lukas has logged meals every day. Sometimes he forgets macros, just types "Chicken wrap, 600 kcal" and moves on. The app doesn't judge. Green smileys show up when he hits 70% protein - easier threshold than other apps. No ads. No interruptions. Just... tracking. He weighs in daily, and this morning the 7-day average appeared for the first time: **📉 Trending down**. A single vibration + roar sound. He smiles. It's working. And still no ads.

Day 14: The app switches to Diet Phase. "Target: 1900 kcal today." This time, Lukas doesn't panic - he read the explanation during onboarding. The cycle timer counts down: "Day 1 of 14 - Diet Phase." He gets it now. The app is smarter than him about this timing. He just follows.

Day 19: Lukas has a late study session at a friend's dorm. They order pizza at 20:00 - two hours after his 18:00 eating window closes. He logs the meal anyway (650 kcal, pepperoni pizza). The app shows a gentle message: *"Noticed you ate at 20:00 (outside 12-18 window). Tomorrow's a new day. Back to 12-18?"* His streak isn't broken. No shame. He appreciates this.

Day 28: First cycle complete. Triple roar vibration + badge: "First Cycle Warrior 🔥💪". Lukas looks in the mirror. His jeans fit better. The 7-day average is down 3.2kg. More importantly, he *trusts* the app. He's not thinking about macros or phases anymore - he just logs, weighs in, and follows.

**POC Reality (Week 6):** Lukas is stressed about his algorithms exam. He sees a banner in the app: *"Coming Soon: AI meal recommendations optimized for mental focus during exams. Would you use this for €7/month?"* He taps "Yes, I'd pay for this." (Validation data collected)

He tells his roommate about w-diet. His roommate asks where he found it. "Mensa bathroom flyer," Lukas says. The roommate downloads it that evening.

**POC Interview (Day 28):**
- Researcher: "Would you pay €7/month for AI meal recommendations during exam stress?"
- Lukas: "Yeah, definitely. If the AI can help me focus like the app helped me lose weight? Worth it."
- Researcher: "How many people have you told about w-diet?"
- Lukas: "One - my roommate. He's using it now."

**Vision Story (Phase 3 - Post-POC):**

Week 18 (Phase 3): Premium tier launches. Lukas upgrades (€7/month). The AI suggests omega-3 rich meals, complex carbs for sustained energy during exam prep. During his study sessions, he feels sharper. Maybe it's placebo, maybe it's real - doesn't matter. The app helped him lose weight *and* gave him the focus boost when he needed it. Two more friends ask about it. He shares the download link.

**This journey reveals requirements for:**
- **Onboarding micro-intervention:** Tooltip explaining "Week 1: Maintenance" BEFORE user can bounce (prevents confusion abandonment)
- Frictionless authentication (Google/Apple Sign-In, <3 minutes total)
- Instant performance (no loading spinners, offline-first)
- Ad-free free tier (core differentiator vs Yazio, MyFitnessPal)
- Educational transparency ("Why Like This?" + in-context tooltips)
- Forgiving UX (70% threshold green smileys, flexible meal logging)
- **Grace period system:** 2-hour buffer after eating window closes (19:30 meal after 18:00 window = no penalty, gentle nudge only)
- **Flexible eating window enforcement:** Meal logged outside window doesn't break streak, shows supportive message not shame
- Automated MATADOR cycling (no user decisions required)
- Week 1 maintenance strategy (habit formation before stress)
- Trust-building progression (results → trust → understanding → monetization readiness)
- **POC willingness-to-pay validation** (in-app prompts + interview questions, no actual Premium features in POC)
- Guerrilla marketing discovery path (flyers, QR codes, campus presence)
- **Referral tracking:** Count how many people users tell (Lukas = 1 direct referral)

### Journey 2: Sarah Hoffmann - From Burnout Eating to Strategic Fuel (Professional Segment)

Sarah is a 26-year-old strategy consultant at a Big 4 firm in Hamburg. She travels Monday-Thursday to client sites, lives out of hotels, and eats most meals from client cafeterias or late-night room service. She's gained 8kg in the past year - not from lack of knowledge (she *knows* what healthy eating looks like), but from sheer mental exhaustion. After 12-hour client days, the last thing she wants to do is track macros in MyFitnessPal or think about meal planning.

One Monday morning in the Hamburg office kitchen, her colleague Kevin mentions he's lost 6kg in the past month. "You look great, what are you doing?" she asks. Kevin pulls out his phone, shows her w-diet. "I built it for my university project, but it actually works. Free tier has everything you need - it just thinks for you. No decisions." He shows her the cycle timer, the MATADOR automation, the tooltip explaining maintenance Week 1. Sarah is skeptical - another diet app? - but Kevin's results are visible. "Try it for two weeks. If it doesn't work, just delete it," he says.

She downloads it during her train ride to the client site that afternoon. Onboarding is fast - Apple Sign-In, enters stats, calorie target auto-calculated at 1900 kcal. The "Week 1: Maintenance" tooltip appears. She reads it, appreciates the explanation upfront. Eating window: 12:00-18:00 works (skips breakfast anyway, focusing on morning coffee). Dashboard loads instantly.

Day 3 (Wednesday): Client dinner ran until 21:00 - three hours outside her eating window. She ate anyway (it's her job). She logs the meal: "Steak, potatoes, wine, ~850 kcal." The app shows: *"Noticed you ate at 21:00 (outside 12-18 window). Tomorrow's a new day. Back to 12-18?"* Her streak isn't broken. She appreciates the gentle nudge, not the guilt trip Noom used to give her.

Day 10: Sarah is on the train home Friday evening. She weighs herself in the hotel bathroom before checkout - the 7-day average shows **📉 trending down** by 1.2kg. She smiles. Between client chaos and business dinners, she's still making progress. The free tier is working. She texts Kevin: "Okay, you were right. This actually works."

Day 14: Phase switches to Diet. "Target: 1900 kcal." Sarah continues logging. The app handles the thinking - she just follows.

**POC Reality (Day 21):** Big client presentation today. High stress. She sees a banner in the app: *"Coming Soon: Mental Focus Mode - AI meal recommendations optimized for cognitive performance during high-stress work. Would you pay €7/month for this?"* She taps "Yes, definitely." (Validation data collected)

That evening, she manually logs focus-friendly meals she researched: overnight oats with walnuts (breakfast), salmon salad (lunch). She feels sharp during the presentation. Client signs the contract extension. She messages Kevin: "Your app helped me prep for that presentation. Seriously."

Day 42 (6 weeks): Down 4.8kg. More importantly, Sarah has *energy* again. She's not stress-eating after client days. The app automated the thinking - she logs quickly (2 mins/day max), trusts the MATADOR cycling. Her colleagues notice. "You look good, what are you doing?" She tells them about w-diet - the app Kevin built. Two of them download it that week.

**POC Interview (Day 42):**
- Researcher: "Would you pay €7/month for AI meal recommendations optimized for client days and presentations?"
- Sarah: "Absolutely. €7 is less than one client dinner drink. If it helps me perform better? No-brainer."
- Researcher: "How many people have you told about w-diet?"
- Sarah: "Five. Kevin first (feedback), then two colleagues who asked about my weight loss, then two more after they saw results. All five downloaded it."

**Vision Story (Phase 3-4 - Post-POC):**

Week 24 (Phase 3): Premium tier launches. Sarah upgrades immediately (€7/month). Mental Focus Mode suggests omega-3 meals, complex carbs, anti-inflammatory foods before big presentations. She orders similar options from client cafeterias. Feels sharper. Tells three more colleagues.

Month 6 (Phase 4): Sarah's firm announces employee wellness partnership - w-diet logo. Company pays €5/employee/month for Pro access. She gets unlimited features free. She messages Kevin: "Your university project just became our company wellness program. That's insane. Congrats 🔥💪"

Professional network effect compounds. Ten downloads from her Hamburg office in one month.

**This journey reveals requirements for:**
- **Word-of-mouth acquisition path:** Colleague referrals with visible proof (Kevin's 6kg loss)
- **Onboarding tooltip** (same as student journey - prevents professional confusion too)
- **Grace period system:** Client dinners at 21:00 (3 hours after window) = gentle nudge, no streak penalty
- **No shame UX:** Professionals MUST have flexibility for client obligations (dinners, travel, irregular schedules)
- Time efficiency (2-minute daily interactions, automated decisions)
- **POC willingness-to-pay validation** (in-app prompts + interviews, actual Mental Focus Mode built in Phase 3)
- **Faster monetization timeline:** Day 21 vs Week 6 for students (higher willingness-to-pay, clearer ROI)
- **Referral tracking:** Sarah = 5 direct referrals (professionals have stronger network effects than students)
- Trust through peer proof (colleague's visible results > marketing claims)
- B2B corporate wellness integration (Phase 4 - HR dashboard, company-paid Pro)
- Professional network effects (office conversations, team adoption, LinkedIn posts)

### Journey Requirements Summary

**POC Hybrid Testing Strategy (Weeks 1-10):**

Both journeys will be tested simultaneously with separate cohorts to determine optimal Phase 2 focus:

**Student Cohort (Target: 20 users)**

*Acquisition channels:*
- **Direct recruitment:** 10-12 users (friends, roommates, Fire's Den early signups via Google Form)
- **Guerrilla marketing:** 8-10 users from 1,000+ flyers
  - Realistic conversion: 1,000 flyers → 50 QR scans (5% scan rate) → 25 downloads (50% scan-to-install) → 8-10 active users (80% activation)
  - High-traffic placements: Mensa bathrooms, gym locker rooms, library study desks
- **Backup plan:** If flyers underperform, increase direct recruitment to 15+ via campus workshops

*Metrics tracked:*
- Activation rate (completed onboarding)
- Week 1 retention (logged meals on Day 7)
- Cycle completion (reached Day 28)
- Education engagement (tapped "Why Like This?")
- Willingness-to-pay (in-app prompts + Day 28 interviews: "Would you pay €7/month for AI meals during exams?")
- **Referral behavior:** How many friends did they tell? (Lukas = 1 referral)

*Success threshold:*
- 40%+ Week 1 retention
- 50%+ say "I would pay €5-7/month for Premium features"
- Average 1+ referral per engaged user

**Professional Cohort (Target: 5-7 users)**

*Acquisition channels:*
- **Word-of-mouth:** PwC colleagues (Kevin's direct access)
- **Direct outreach:** "Testing my university project, need consultant feedback - 2 weeks, free, interested?"
- Low-friction ask: Free tier, 2-week commitment, peer-to-peer trust

*Metrics tracked:*
- Same as student cohort
- **Referral behavior emphasis:** Professionals expected to have higher network effects (Sarah = 5 referrals vs Lukas = 1)

*Success threshold:*
- 60%+ Week 1 retention (higher bar than students)
- 80%+ willing to pay €7-15/month
- Average 3+ referrals per engaged user (professional network effect hypothesis)

**Week 10 Decision Point:**

*Scenario 1: Professionals significantly outperform students (>20% retention delta)*
- **Action:** Pivot to professionals-first in Phase 2
- **Rationale:** Higher retention + higher willingness-to-pay + stronger referral network = faster path to sustainability

*Scenario 2: Students significantly outperform professionals*
- **Action:** Stay student-first (original 80/20 plan)
- **Rationale:** Larger market, Kevin's authentic campus access, guerrilla marketing validated

*Scenario 3: Both strong (both meet success thresholds)*
- **Action:** Dual-track expansion (maintain 80/20 split)
- **Rationale:** Both segments validated, leverage Kevin's dual identity (student + PwC consultant)

*Scenario 4: Both weak (<30% retention for students, <50% for professionals)*
- **Action:** Pivot core product (UX issues, value prop unclear)
- **Rationale:** Fundamental product-market fit problem, needs redesign before scaling

**Core Capabilities Revealed by Both Journeys:**

*Onboarding & Authentication:*
- Google/Apple Sign-In (frictionless, no password creation)
- <3-minute onboarding flow (5 steps: auth, goal, calorie, eating window, dashboard)
- **Micro-intervention tooltip:** "🔥 Week 1 starts gentle. Why? [Tap to learn]" appears BEFORE user can close app in confusion
- Mini-explanation (30-second read) addresses "Why maintenance calories?" question immediately
- Instant dashboard load (<50ms, no loading spinners)

*Core Experience:*
- MATADOR cycling automation (14-day diet/maintenance phases, no user decisions)
- Week 1 maintenance strategy (build habit before stress)
- Forgiving macro thresholds (70% = green smiley, compassion built-in)
- Flexible meal logging (manual entry, optional macros, no judgment)
- Daily weight tracking with 7-day rolling average
- Trend indicators (📉 green down / 📊 yellow stable / 📈 red up)
- Roar reward system (haptic + sound, milestone celebrations)

*Eating Window Flexibility (Critical for Both Segments):*
- **Grace period system:** 2-hour buffer after window closes
  - User with 12-18 window eats at 19:30 → No penalty, no nudge (within grace)
  - User with 12-18 window eats at 21:00 → Gentle nudge: "Tomorrow's a new day. Back to 12-18?" (outside grace)
- **No streak penalty for window violations:** Meal logged outside window doesn't break streak
- **Supportive messaging:** "Noticed you ate at [time]" not "You failed" or "Window broken"
- **Database tracking:** `gracePeriodApplied: Bool` field logs whether meal was within grace period (for analytics, not punishment)

*Educational Transparency:*
- "Why Like This?" section (MATADOR study explanation, research links)
- In-context tooltips (onboarding, phase switches, first 7-day average)
- Fire with glasses 🔥🤓 character for education moments
- Just-in-time learning (explain concepts when user experiences them)

*Trust Formation:*
- Ad-free experience (critical differentiator vs Yazio, MyFitnessPal free tiers)
- Offline-first architecture (works on subway, airplane mode, poor WiFi, travel)
- No shame-based UX (gentle nudges, not guilt trips)
- Results before monetization (earn trust via free tier, validate willingness-to-pay, build Premium in Phase 3)

*POC Willingness-to-Pay Validation (NO Premium Features in POC):*
- **In-app prompts:** Banner showing "Coming Soon: [Premium feature]. Would you pay €X/month for this?" with Yes/No/Maybe options
- **Day 28/42 interviews:** "Would you pay €7/month for AI meal recommendations optimized for [exams/client presentations]?"
- **Data collected:** Percentage who say "Yes" validates monetization path for Phase 3
- **User expectation management:** POC users experience free tier only, Premium features built in Phase 3 based on validation data

*Phase 3 Premium Tier (Post-POC Validation):*
- AI meal recommendations (ChatGPT/Claude API, German ingredients, budget-conscious for students)
- Mental Focus Mode (cognitive performance optimization for professionals during exams/presentations)
- Food database search (OpenFoodFacts integration, offline cache)
- Enhanced features (meal history, blacklist/favorites, advanced analytics)

*Phase 4 B2B Corporate Wellness:*
- HR admin dashboard (aggregate metrics, GDPR-compliant, no individual weight data)
- Company-paid Pro access (€5/employee/month, Hansefit model)
- Employee engagement reporting (participation rates, streak trends)
- Word-of-mouth network effects through professional teams

**Critical Success Dependencies:**

Both journeys depend on:
1. **Performance:** <50ms dashboard, offline-first, no interruptions
2. **Onboarding safety net:** Tooltip prevents "maintenance calories confusion bounce"
3. **Eating window flexibility:** Grace period + no streak penalty = realistic for irregular schedules
4. **Automation:** MATADOR cycling requires zero user decisions
5. **Trust cascade:** Results (weight trending down) → Trust (follow guidance) → Understanding (read education) → Monetization readiness (validate willingness-to-pay) → Actual Premium upgrades (Phase 3)
6. **Dual acquisition paths:** Guerrilla (students, 1,000+ flyers realistic) + Word-of-mouth (professionals, direct colleague referrals)
7. **Referral tracking:** Students expected ~1 referral/user, professionals ~3-5 referrals/user (network effect hypothesis)

**Week 9 TestFlight Critical Test Cases:**

Based on journey failure points identified by Murat (TEA):

*Test Case 1: Onboarding abandonment prevention*
- **Setup:** 10 users with tooltip, 10 users without
- **Measure:** Day 2 return rate (did they come back after seeing "maintenance calories"?)
- **Expected:** Tooltip group has >20% higher Day 2 return
- **Validation:** Tooltip prevents confusion bounce

*Test Case 2: Ad-free experience validation*
- **Setup:** All 20 users log 10+ meals over 3 days
- **Measure:** User interview question "Did you see any ads?"
- **Expected:** 100% answer "No"
- **Validation:** Ad-free promise delivered

*Test Case 3: Offline reliability during travel*
- **Setup:** 2 professional users, ask them to enable airplane mode, log meal + weight
- **Measure:** Data saves to SQLite, syncs correctly when back online, no duplicates/conflicts
- **Expected:** Zero data loss, clean sync
- **Validation:** Offline-first architecture works for traveling consultants

*Test Case 4: Eating window violation handling*
- **Setup:** Ask 3 users to intentionally log meal 3+ hours outside window (e.g., 21:00 for 12-18 window)
- **Measure:** App shows gentle nudge, streak NOT broken, meal logged successfully
- **Expected:** Supportive UX, no punishment
- **Validation:** Flexible eating window system works as designed

**POC Validation Framework:**

Both cohorts measured independently to determine optimal Phase 2 focus based on real behavioral data, not assumptions. Decision made Week 10 based on retention, willingness-to-pay, and referral network effects.

## Innovation & Novel Patterns

### Detected Innovation Areas

**1. Automated MATADOR Cycling (Primary Innovation)**
- **What's novel:** Only app implementing research-backed metabolic cycling (2-week diet/maintenance rotation) fully automated
- **Research basis:** MATADOR study (2018) showed 30% better fat loss retention vs continuous deficit
- **User experience:** App switches phases automatically every 14 days, adjusts calorie targets, explains science via "Why Like This?" education
- **Market gap:** MyFitnessPal/Yazio are passive trackers - user must manually manage diet phases
- **Innovation:** Zero user decisions required - app orchestrates entire diet strategy based on peer-reviewed research

**2. Guidance + Explanation Model**
- **What's novel:** Combines active coaching (telling users what to do) with transparent research references (explaining why)
- **Market gap:** Apps either oversimplify (passive trackers) or overcomplicate (manual decision-making)
- **Innovation:** Just-in-time learning - education appears contextually when users experience it (phase switch → read about metabolic adaptation)
- **Target user:** Students and professionals who want to understand the science but don't want to manage the complexity

**3. Week 1 Maintenance Strategy**
- **What's novel:** Starts users at maintenance calories to build habit before introducing deficit stress
- **Research basis:** 80% diet app dropout happens in Week 1 due to immediate deficit overwhelm
- **Innovation:** Behavior formation before calorie restriction - addresses largest failure point
- **Competitive advantage:** Micro-intervention tooltip prevents "maintenance confusion bounce"

### Market Context & Competitive Landscape

**Existing Solutions:**
- **MyFitnessPal:** 200M+ users, manual food database search, ad-heavy free tier, passive tracking only
- **Yazio:** Popular in Germany, barcode scanning, ads after every meal log (user complaint), no coaching
- **Noom:** Psychology-focused coaching, manual tracking, $60/month premium pricing, shame-based UX, no automation
- **Lifesum:** Recipe focus, manual tracking, limited education, no metabolic cycling

**w-diet's differentiation:**
- **Only app** with automated MATADOR cycling (evidence-based phase management, zero user decisions)
- **Only app** combining active guidance with transparent research explanations (not just passive tracking)
- **Ad-free free tier** (vs MyFitnessPal/Yazio ad fatigue) with core features free forever
- **Week 1 maintenance strategy** addresses 80% dropout rate competitors ignore
- **Forgiving design** (70% threshold = success) vs shame-based competitors

### Validation Approach

**Technical Validation (POC - Weeks 1-10):**
- MATADOR cycling logic accuracy: Phase switches occur exactly on Day 14/28 (automated, local SQLite-based)
- Calorie target calculations: 30% variance between diet/maintenance phases (e.g., 1900 ↔ 2300 kcal)
- Dashboard performance: <50ms load time, 60fps rendering, <5% battery drain per hour active use
- Offline reliability: 100% core features functional without internet, sync works flawlessly when online

**Market Validation (POC):**
- Week 1 retention: >40% (beats 80% industry dropout = 2x better fundamentals)
- Phase switch continuation: >80% of users who reach Day 14 continue through maintenance phase (validates automation trust)
- Education engagement: >40% tap "Why Like This?" section (validates explanation differentiator)
- Cycle completion: >15% reach Day 28 (validates MATADOR full-cycle effectiveness)
- Student interviews: "Do you trust the app to manage your diet phases?" (target: >70% say "yes")

**Behavioral Validation:**
- Meal logging consistency: >70% of engaged users log 5+ meals/week (validates core loop stickiness)
- Weight logging habit: >60% weigh in 4+ times/week (validates daily habit formation)
- Qualitative feedback: "Does the fire character help or annoy?" / "Is the education valuable or overwhelming?"

**Future Innovation Validation (Phase 2+):**
- Photo/Menu scanning added in Phase 2 once fundamentals validated
- Willingness-to-pay for Premium: "Would you pay €5-7/month for AI photo scanning + meal recommendations?"

### Risk Mitigation

**Innovation Risk 1: Users Don't Trust Automated Phase Switches**
- **Risk:** Users panic when calorie target increases on Day 14, abandon app thinking it's broken
- **Mitigation:** Micro-intervention tooltip in onboarding explains Week 1 maintenance strategy, "Why Like This?" education accessible from dashboard
- **Validation:** Week 9 TestFlight - ask 10 users to reach Day 14, measure continuation rate (target >80%)

**Innovation Risk 2: Education Content Too Dense**
- **Risk:** Students skip "Why Like This?" section, miss differentiator value
- **Mitigation:** Just-in-time tooltips (contextual nudges when phase switches), fire with glasses character signals "learning moment"
- **Validation:** Track `why_like_this_opened` event, target >40% engagement in POC

**Innovation Risk 3: Week 1 Maintenance Confuses Users**
- **Risk:** Users expect immediate deficit, see "2300 kcal" and think app calculated wrong
- **Mitigation:** Onboarding tooltip BEFORE entering dashboard: "🔥 Week 1 starts gentle. Why? [Tap to learn]"
- **Validation:** A/B test in Week 9 TestFlight (10 users with tooltip, 10 without), measure Day 2 return rate

**Innovation Risk 4: Fire Character Feels Childish**
- **Risk:** University students/professionals reject app as "too gamified" or "Duolingo ripoff"
- **Mitigation:** Minimalist design (not cartoon), professional color palette, subtle coaching (not overbearing)
- **Validation:** User interviews ask "Does the fire enhance or detract?" (target: >60% say "enhances")

**Innovation Risk 5: Manual Logging Too Tedious**
- **Risk:** Without scanning features in POC, students abandon due to logging friction
- **Mitigation:** Quick meal shortcuts (Brunch/Snack/Dinner buttons), optional macros (only calories required), <30 second logging target
- **Validation:** Track session duration on meal logging screen, target <2 minutes average
- **Phase 2 unlock:** Add Photo/Menu scanning to reduce manual logging friction

## Mobile App Technical Requirements

### Platform Requirements

**Primary Platform: iOS Native (Swift + SwiftUI)**
- **Minimum iOS Version:** iOS 16+ (supports 95%+ of active iPhone users in Germany)
- **Target Devices:** iPhone only (no iPad optimization in POC)
- **Development Stack:**
  - Language: Swift 5.9+
  - UI Framework: SwiftUI (declarative, modern, performant)
  - Local Storage: SQLite via GRDB.swift or Core Data
  - Backend: Supabase (PostgreSQL, Auth, Realtime)
  - AI Integration (Phase 2+): GPT-4 Vision or Claude Vision for Photo/Menu scanning

**Future Platforms (Post-POC):**
- **Phase 2:** Android (Kotlin + Jetpack Compose, native development)
- **Phase 3:** Web app (responsive dashboard for desktop access)

**Rationale for iOS-first:**
- Target demographic (consultants, professionals) has high iOS adoption in Germany
- Native Swift delivers required performance (<50ms dashboard, 60fps)
- Apple Vision framework provides FREE on-device OCR (privacy-first, works offline)
- Faster POC development vs cross-platform frameworks
- Premium pricing model converts better on iOS professional demographic

### Device Permissions & Features

**Required Permissions:**
- **Camera** (NSCameraUsageDescription): "Scan restaurant menus to analyze nutritional information"
  - Primary use: Menu scanning OCR + AI analysis
  - Frequency: 1-3 times per day (lunch + dinner scans)
  - Battery impact: <2% per scan (optimized for quick bursts)

**Optional Permissions (Future):**
- **Notifications** (NSUserNotificationsUsageDescription): "Remind you to log meals and track weight"
  - Frequency: 2-3 per day max (meal reminders, phase switch notifications)
  - User control: Opt-in during onboarding, configurable in settings
  - Phase: Deferred to Phase 2 (POC doesn't need push notifications)
  
- **Location** (NSLocationWhenInUseUsageDescription): "Suggest nearby restaurants from your scan history"
  - Future enhancement: Location-based restaurant recommendations
  - Phase: Deferred to Phase 3+

**Hardware Features Used:**
- **Camera:** OCR menu scanning, future photo progress tracking
- **Haptic Engine:** Roar feedback system (single/double/triple vibrations)
- **Speaker:** Roar sound effects (milestone celebrations)
- **Biometric Auth (Face ID/Touch ID):** Optional quick login (Phase 2+)

**NOT Used (Explicitly Avoided):**
- ❌ Accelerometer/Gyroscope (no step counting - focus on nutrition not exercise)
- ❌ HealthKit integration (POC complexity, deferred to Phase 3)
- ❌ Apple Watch (deferred to Phase 4)

### Offline Mode Strategy

**Offline-First Architecture:**
- **100% core functionality works without internet**
- Local SQLite database stores:
  - User profile (calorie target, eating window, cycle state)
  - Weight logs (daily entries, 7-day rolling average)
  - Meal logs (name, macros, timestamp, source)
  - Streak data (daily logging consistency)
  - Analytics events (offline-queued, sync when online)
  - Menu scan cache (previously scanned menus, learning database)

**Cloud Sync Strategy:**
- Background sync to Supabase when internet available
- Conflict resolution: Cloud timestamp wins (last-write-wins policy)
- Unsynced records flagged `synced = 0` in SQLite
- Automatic retry on reconnect (exponential backoff)
- User never sees sync errors (queue builds, syncs transparently)

**Features Requiring Internet:**
- ❌ **Menu scanning AI analysis** (GPT-4 Vision API requires connectivity)
  - Graceful degradation: "Menu scanning requires internet. Use manual meal logging." message
  - Cached results: Previously scanned menus load from local database (works offline)
- ❌ Authentication (initial sign-in/sign-up)
- ❌ Password reset
- ✅ **Everything else works offline**

**Traveling Consultant Use Case:**
- Airplane mode: Dashboard, manual logging, weight tracking all functional
- Hotel WiFi: Menu scanning works, data syncs in background
- Poor connectivity: Core features unaffected, sync queues in background

### Push Notification Strategy (Phase 2+)

**Deferred to Phase 2 - Not in POC**

**Future Notification Types:**
- **Meal reminders:** "Haven't logged lunch yet. Quick scan?" (12:30, 18:30)
- **Phase switches:** "Day 14 complete! Switching to Maintenance Phase 🔥💪" (midnight, cycle day 14/28)
- **Streak milestones:** "7-day streak! Keep roaring 🔥" (achievement unlocked)
- **Weight reminders:** "Morning weigh-in?" (07:00, configurable)

**Rationale for deferral:** POC users are highly engaged beta testers, don't need nudges. Phase 2+ scales to less motivated users who benefit from reminders.

### Store Compliance (App Store Guidelines)

**App Store Requirements:**

**1. Health & Nutrition Content (Guideline 5.1.1(v))**
- ✅ w-diet provides **guidance, not medical diagnosis or treatment**
- ✅ Clear disclaimers: "Nutritional guidance only. Consult healthcare provider for medical advice."
- ✅ No medical claims: "Helps you lose weight" not "Treats obesity" or "Cures metabolic syndrome"
- ✅ MATADOR cycling presented as research-backed method, not medical protocol

**2. User-Generated Content (Menu Scanning)**
- ✅ Users can correct AI estimates (manual override available)
- ✅ No social features in POC (no user-reported content moderation needed)
- ✅ Learning database = aggregated anonymous data (no UGC exposure)

**3. In-App Purchases / Subscriptions (Phase 3)**
- ✅ Clear free tier vs Pro tier differentiation
- ✅ 7-day free trial disclosed upfront ("First week free, then €19.99/month")
- ✅ Cancel anytime policy
- ✅ Restore purchases functionality

**4. Privacy (Guideline 5.1.2)**
- ✅ Privacy policy: Health data stays local by default, cloud sync optional
- ✅ GDPR compliance: User can export data (CSV), delete account (full purge)
- ✅ No third-party data sharing (Supabase backend only)
- ✅ Camera usage: Menu scanning only, no photos stored without consent

**5. App Completeness (POC Exception)**
- ⚠️ POC submitted as TestFlight beta (no App Store review needed)
- ✅ Phase 2+ public release: All features polished, onboarding complete, no placeholder content

**6. Performance (Guideline 2.3)**
- ✅ <50ms dashboard load
- ✅ No crashes (>99.5% crash-free rate target)
- ✅ Battery efficient (<5% active use per hour)
- ✅ Works on iPhone 12+ (no requiring latest hardware)

**Metadata Requirements:**
- App Name: "w-diet - Smart Nutrition Coach"
- Category: Health & Fitness
- Age Rating: 4+ (no objectionable content)
- Keywords: diet, nutrition, MATADOR, calorie tracker, weight loss, meal scanner, AI menu
- Privacy Nutrition Label: Health data (weight, meals) collected, linked to user, optional cloud sync

**Rejection Risks Mitigated:**
- ❌ Medical device claim → ✅ Nutrition guidance tool
- ❌ Incomplete app → ✅ POC via TestFlight, Phase 2+ fully polished
- ❌ Privacy violations → ✅ Local-first, clear disclosures, GDPR compliant
- ❌ Performance issues → ✅ Native Swift, <50ms targets, Week 9 profiling

## Scope Summary & Prioritization

### MVP Boundaries (POC - Weeks 1-10)

**Core Loop (Must Ship):**
1. **Manual Meal Logging** - Simple form (meal name, calories, macros), instant save to SQLite
2. **MATADOR Cycling Automation** - 14-day phase switches, Week 1 maintenance strategy, zero user decisions
3. **Weight Tracking** - Daily logging with 7-day rolling average, trend indicators
4. **Dashboard** - Cycle timer, calorie progress, macro smileys, roar feedback
5. **Fire Coach Character** - 4 variations (default, glasses, strong, gentle), haptic + sound roars
6. **Authentication & Onboarding** - 5-step flow with micro-intervention tooltip
7. **"Why Like This?" Education** - MATADOR study explanation, research links
8. **Offline-First Implementation** - SQLite + Supabase sync, 100% core functionality works offline
9. **Lightweight Analytics** - 11 core events tracked for POC validation

**Deferred (Not MVP):**
- ❌ **Photo food scanning** (Phase 2 Premium) - AI-powered plate recognition for instant meal logging
- ❌ **Menu scanning** (Phase 2 Premium) - Camera OCR + AI analysis + Nutri-Score ratings for restaurant ordering
- ❌ AI meal recommendations (Phase 3 Premium)
- ❌ Food database search (Phase 3 Premium)
- ❌ Mental Focus Mode (Phase 3 Pro feature)
- ❌ Advanced analytics (Phase 3 Pro) - 30/90-day trends
- ❌ Photo progress tracking (Phase 4 Pro)
- ❌ Social features / "Pride" system (Phase 4)
- ❌ Gender-adaptive fire (Phase 4)
- ❌ Fire roar animations (Phase 3 polish)
- ❌ Push notifications (Phase 2+)
- ❌ Apple Watch integration (Phase 4)

**Prioritization Philosophy:**
- **POC proves core hypothesis:** Guidance + Explanation + MATADOR Automation creates sustainable behavior change
- **Phase 2 adds Premium features:** Photo food scanning + Menu scanning (restaurant AI analysis) unlock monetization
- **Phase 3 builds depth:** AI meal recommendations, Mental Focus Mode, food database search
- **Phase 4 scales with B2B:** Corporate dashboards, social features, ecosystem integration

### Feature Prioritization Framework

**Tier 1: POC Critical (Week 1-10)**
- Blocks university project completion
- Validates core value proposition
- Required for menu scanning + MATADOR automation + basic tracking

**Tier 2: Growth Enablers (Week 11-18)**
- Marketing infrastructure (referral system, in-app feedback)
- Bug fixes from POC user feedback
- ONE critical UX improvement based on data (e.g., onboarding friction)

**Tier 3: Monetization Features (Week 19-30)**
- Premium tier (AI meals, food database, enhanced roar)
- Stripe/Supabase subscriptions integration
- Professional market testing (PwC pilot, LinkedIn content)

**Tier 4: Legitimization & Scale (Week 31-52)**
- Pro tier (unlimited features, photo progress, advanced analytics)
- Mental Focus Mode (cognitive performance optimization)
- B2B corporate dashboard (HR admin panel, anonymized metrics)
- Social features (optional "Pride" system, privacy-first)

**Decision Criteria:**
- **Must Have:** Blocks core loop, required for POC demo, validates hypothesis
- **Should Have:** Significantly improves UX, enables growth, monetization-critical
- **Nice to Have:** Polish, competitive parity, future vision
- **Won't Have (this phase):** Low ROI, complex implementation, unvalidated assumptions

## Functional Requirements

### FR-1: Authentication & User Management

**FR-1.1: User Authentication**
- System SHALL support Google Sign-In (OAuth 2.0)
- System SHALL support Apple Sign-In (Sign in with Apple)
- System SHALL support Email/Password authentication via Supabase
- System SHALL persist user session locally (offline access after initial login)

**FR-1.2: Onboarding Flow**
- System SHALL present 5-step onboarding sequence:
  1. Authentication (Google/Apple/Email)
  2. Goal selection (Weight Loss active, Maintain/Bulk "Coming Soon")
  3. Calorie target (manual entry OR auto-calculated from user stats)
  4. Eating window setup (6-hour constraint, user-selected start time)
  5. Dashboard reveal with guided tour
- System SHALL display micro-intervention tooltip at Step 4: "🔥 Week 1 starts gentle. Why? [Tap to learn]"
- System SHALL complete onboarding in <3 minutes average duration

**FR-1.3: User Profile Management**
- System SHALL store: goal weight, current weight, calorie target, eating window, cycle state
- System SHALL allow users to export all data (CSV format)
- System SHALL allow users to delete account (full data purge, GDPR-compliant)

### FR-2: Manual Meal Logging

**FR-2.1: Manual Entry Form**
- System SHALL provide input fields: Meal name, Calories, Protein, Carbs, Fats, Fiber
- System SHALL allow optional macro entry (only calories required minimum)
- System SHALL provide meal type shortcuts (Brunch/Snack/Dinner quick buttons)

**FR-2.2: Real-Time Dashboard Updates**
- System SHALL update calorie progress bar immediately after logging
- System SHALL recalculate macro smileys (😊 green / 😐 yellow / ☹️ red) in real-time
- System SHALL save to local SQLite immediately (no loading spinners)

**FR-2.3: Eating Window Validation**
- System SHALL track meal timestamp against user's eating window
- System SHALL apply 2-hour grace period after window closes
- System SHALL display gentle nudge if meal logged >2 hours outside window
- System SHALL NOT break streak for window violations (supportive UX, not punishment)

### FR-3: Daily Weight Tracking

**FR-3.1: Weight Entry**
- System SHALL provide weight input form (kg, 0.1kg precision)
- System SHALL timestamp weight entry
- System SHALL save to local SQLite immediately

**FR-4.2: 7-Day Rolling Average**
- System SHALL calculate 7-day rolling average starting Day 7
- System SHALL display trend indicator:
  - 📉 Green down: average decreasing (success)
  - 📊 Yellow stable: average ±0.2kg (neutral)
  - 📈 Red up: average increasing (caution)

**FR-4.3: Roar Feedback System**
- System SHALL trigger single roar (haptic + sound) on weight entry
- System SHALL trigger double roar if 7-day average trending toward goal
- System SHALL use device haptic engine + audio file playback

### FR-4: MATADOR Cycling Automation

**FR-5.1: Automatic Phase Switching**
- System SHALL auto-switch between Diet and Maintenance phases every 14 days
- System SHALL adjust calorie target automatically:
  - Diet Phase: User's calculated deficit (e.g., 1900 kcal)
  - Maintenance Phase: +30% (e.g., 2300 kcal)
- System SHALL update dashboard cycle timer to reflect new phase

**FR-5.2: Week 1 Special Strategy**
- System SHALL start new users at Maintenance calories (Week 1 = Day 1-7)
- System SHALL display tooltip explaining Week 1 strategy during onboarding
- System SHALL switch to Diet Phase on Day 14 (Week 2 start)

**FR-5.3: Cycle State Persistence**
- System SHALL persist cycle state in local SQLite (current phase, day count, phase start date)
- System SHALL calculate phase switches based on elapsed days (midnight transitions)
- System SHALL run phase logic locally (no server dependency)

### FR-5: Dashboard & Core UI

**FR-6.1: Dashboard Components**
- System SHALL display MATADOR cycle timer: "Day X of 14 - Diet/Maintenance Phase"
- System SHALL display calorie progress bar: "Consumed / Target" with visual fill
- System SHALL display macro tracking smileys (Protein/Carbs/Fats/Fiber):
  - 70-100% = 😊 Green (forgiving threshold)
  - 50-69% = 😐 Yellow
  - <50% = ☹️ Red
- System SHALL hide macro smileys until first meal logged (progressive disclosure)
- System SHALL display streak counter (daily logging consistency)
- System SHALL provide quick action buttons: "Scan Menu", "Log Meal", "Log Weight"

**FR-6.2: Performance Requirements**
- System SHALL load dashboard in <50ms (native Swift advantage)
- System SHALL render all UI at 60fps (no jank)
- System SHALL display zero loading spinners on critical paths

**FR-6.3: Fire Character Integration**
- System SHALL display minimalist geometric fire face (4 variations):
  - 🔥 Default (confident, calm)
  - 🔥🤓 Glasses (educational content)
  - 🔥💪 Strong (milestone celebrations)
  - 🔥😌 Gentle (Week 1 supportive messaging)
- POC: System SHALL use static images (no animations)
- System SHALL select fire variant contextually (e.g., glasses for "Why Like This?")

### FR-6: Education & Transparency

**FR-7.1: "Why Like This?" Section**
- System SHALL provide markdown-formatted educational content explaining:
  - MATADOR study methodology and results
  - Why 2-week cycling prevents metabolic adaptation
  - Why Week 1 starts at maintenance (habit formation before stress)
  - Why 6-hour eating window (intermittent fasting benefits)
- System SHALL link to academic research papers (MATADOR study, IF research)
- System SHALL track `why_like_this_opened` event (education engagement metric)

**FR-7.2: In-Context Tooltips**
- System SHALL display tooltips at key moments:
  - Onboarding: Week 1 maintenance explanation
  - First phase switch: "Why am I eating more now?"
  - First 7-day average: "What does this trend mean?"
- System SHALL allow user to dismiss tooltips (don't repeat every session)

### FR-7: Offline-First Architecture

**FR-8.1: Local Data Storage**
- System SHALL store ALL core data in SQLite:
  - User profile (calorie target, eating window, cycle state)
  - Weight logs (daily entries, 7-day rolling average)
  - Meal logs (name, macros, timestamp, source [manual | menu_scan])
  - Streak data (daily logging consistency)
  - Analytics events (offline-queued, sync when online)
  - Menu scan cache (restaurant, dish, AI estimates, verified data)

**FR-8.2: Core Features Work Offline**
- System SHALL provide 100% functionality offline:
  - Dashboard viewing
  - Manual meal logging
  - Weight logging
  - MATADOR phase calculations
  - Streak tracking
  - Education content reading
- Menu scanning SHALL require internet (AI API dependency) but display graceful degradation message

**FR-8.3: Cloud Sync Strategy**
- System SHALL sync local SQLite to Supabase PostgreSQL when online
- System SHALL flag unsynced records: `synced = 0` in SQLite
- System SHALL use background sync (transparent to user, no loading spinners)
- System SHALL retry sync on reconnect (exponential backoff)
- System SHALL resolve conflicts: cloud timestamp wins (last-write-wins policy)

### FR-8: Analytics & Validation Tracking

**FR-9.1: Event Tracking**
- System SHALL track 15 core events:
  - `onboarding_started`, `onboarding_step_completed` (Steps 1-5), `onboarding_finished`
  - `menu_scan_started`, `menu_scan_completed`, `menu_scan_failed`, `menu_item_selected`
  - `meal_logged` (metadata: source [manual | menu_scan | ai_recommendation], meal_type)
  - `weight_logged`
  - `why_like_this_opened` (metadata: topic)
  - `cycle_phase_switched` (metadata: from/to phase)
  - `free_trial_started`, `pro_paywall_shown`, `pro_subscription_purchased`
  - `session_start`, `session_end` (metadata: duration_seconds)
  - `screen_view`, `screen_exit` (metadata: screen_name, time_spent_seconds)

**FR-9.2: Analytics Implementation**
- System SHALL provide single `logEvent()` function for all tracking
- System SHALL store events in local SQLite table
- System SHALL sync events to Supabase `analytics_events` table when online
- System SHALL use SwiftUI `.onAppear`/`.onDisappear` modifiers for screen tracking

**FR-8.3: POC Validation Metrics**
- System SHALL calculate activation rate (onboarding completion %)
- System SHALL calculate Week 1 retention (Day 7 meal logging %)
- System SHALL calculate first cycle completion rate (% users who reach Day 28)
- System SHALL calculate education engagement (% users who open "Why Like This?")
- System SHALL calculate phase switch continuation rate (% users who continue past Day 14)

### FR-9: Streak & Milestone System

**FR-10.1: Streak Tracking**
- System SHALL increment daily streak on meal logging AND weight logging (both required)
- System SHALL persist streak count in SQLite
- System SHALL display streak counter on dashboard
- System SHALL NOT break streak for eating window violations (grace period applied)

**FR-10.2: Milestone Celebrations**
- System SHALL trigger roar feedback at milestones:
  - Single roar: Daily weight log
  - Double roar: 7-day average trending toward goal
  - Triple roar: First cycle complete (Day 28)
- POC: System SHALL use haptic + sound only (no visual animations)
- Phase 3+: System SHALL add milestone badges (7-day streak, 30-day streak, first cycle badge gallery)

## Non-Functional Requirements

### NFR-1: Performance

**NFR-1.1: Response Times**
- Dashboard SHALL load in <50ms (P99 target)
- All user actions SHALL respond in <300ms
- Menu scanning SHALL complete in <60 seconds total:
  - OCR processing: <3 seconds
  - AI analysis: <10 seconds
  - Results display: <1 second
- Zero loading spinners on critical paths (meal logging, weight logging, dashboard)

**NFR-1.2: Frame Rate**
- UI SHALL render at 60fps minimum (no jank, smooth scrolling)
- Animations SHALL use GPU acceleration (where implemented in Phase 3+)

**NFR-1.3: Validation**
- System SHALL use Xcode Instruments (Week 8 profiling) to measure actual performance
- System SHALL identify bottlenecks and optimize before POC demo

### NFR-2: Battery Efficiency

**NFR-2.1: Power Consumption Targets**
- Active use SHALL consume <5% battery per hour (critical for traveling consultants)
- Menu scanning SHALL consume <2% battery per scan (camera + OCR + API call)
- Background sync SHALL consume <1% battery per hour
- Idle (app closed) SHALL consume <0.1% battery per hour

**NFR-2.2: Validation**
- System SHALL test on iPhone 12 (degraded battery) in Week 9 TestFlight
- System SHALL measure battery drain over 8-hour consultant workday simulation

**NFR-2.3: Optimization Strategies**
- Use on-device OCR (Apple Vision framework, no cloud processing)
- Batch sync operations (sync every 15 minutes, not real-time)
- Minimize background refresh (only when data changes)
- Use efficient SwiftUI rendering (lazy loading, view recycling)

### NFR-3: Reliability

**NFR-3.1: Crash-Free Rate**
- System SHALL maintain >99.5% crash-free rate (industry standard)
- System SHALL integrate Crashlytics or Sentry (Week 2 setup)
- System SHALL monitor crashes in Week 9 TestFlight beta

**NFR-3.2: Data Integrity**
- System SHALL NEVER lose user data (weight logs, meal logs, streak data, cycle state)
- System SHALL handle sync conflicts gracefully (cloud timestamp wins, log for debugging)
- System SHALL validate data before saving (no negative calories, weight within human range)
- **Zero tolerance:** Any data loss incident = critical bug, must fix before POC demo

**NFR-3.3: Offline Reliability**
- System SHALL function 100% offline for core features
- System SHALL queue sync operations transparently (user never sees sync errors)
- System SHALL retry failed syncs on reconnect (exponential backoff, max 3 retries)

### NFR-4: Scalability

**NFR-4.1: User Capacity**
- POC SHALL handle 100 concurrent users smoothly
- Architecture SHALL scale to 10,000 users without major rewrite
- Acceptable scaling: Add Redis cache, optimize queries, scale Supabase tier
- Unacceptable scaling: Rewrite sync logic, migrate auth system, change database paradigm

**NFR-4.2: Cost Efficiency**
- Supabase costs SHALL stay <€100/month at 5,000 users
- GPT-4 Vision API costs SHALL stay <€2/user/month (covered by €19.99 Pro pricing)
- Infrastructure costs SHALL not exceed 20% of MRR at scale

### NFR-5: Security & Privacy

**NFR-5.1: Data Privacy**
- System SHALL store health data locally by default (offline-first = privacy-first)
- System SHALL make cloud sync optional enhancement (user control)
- System SHALL encrypt data in transit (HTTPS/TLS 1.3)
- System SHALL encrypt data at rest (Supabase PostgreSQL encryption)

**NFR-5.2: GDPR Compliance**
- System SHALL allow users to export all data (CSV format)
- System SHALL allow users to delete account (full purge within 30 days)
- System SHALL provide privacy policy (health data collection disclosed)
- System SHALL obtain user consent for cloud sync (opt-in, not default)

**NFR-5.3: Authentication Security**
- System SHALL use OAuth 2.0 for Google/Apple Sign-In (no password storage)
- System SHALL hash passwords using bcrypt (Supabase default)
- System SHALL implement session timeout (30 days, refresh token rotation)
- System SHALL NOT share data with third parties (Supabase backend only)

### NFR-6: Usability & Accessibility

**NFR-6.1: Usability Targets**
- Onboarding SHALL complete in <3 minutes average
- New users SHALL understand core loop within 2 minutes (micro-intervention tooltips)
- Menu scanning SHALL feel "instant" (<60 seconds perceived time)
- No user SHALL complain about "slow" or "stuck" in interviews (validation metric)

**NFR-6.2: Accessibility (Phase 2+)**
- POC: System SHALL provide readable fonts, adequate contrast (basic accessibility)
- Phase 2+: System SHALL support VoiceOver (screen reader)
- Phase 2+: System SHALL support Dynamic Type (user-controlled text size)
- Phase 2+: System SHALL meet WCAG 2.1 AA compliance (German accessibility laws)

### NFR-7: Maintainability & Developer Experience

**NFR-7.1: Code Quality**
- System SHALL use Swift best practices (async/await, structured concurrency)
- System SHALL provide unit tests for critical paths (MATADOR logic, calculations)
- System SHALL provide integration tests for SQLite ↔ Supabase sync
- System SHALL maintain >80% test coverage for core logic (Week 9 target)

**NFR-7.2: Documentation**
- System SHALL document API endpoints (Supabase functions)
- System SHALL document database schema (SQLite + PostgreSQL)
- System SHALL document event tracking schema (analytics events)
- System SHALL provide README with setup instructions

**NFR-7.3: POC Timeline**
- System SHALL deliver POC in 10 weeks (university deadline)
- System SHALL complete business plan with validation data on time
- System SHALL be maintainable (Phase 2 features add-able without rewrite)

### NFR-8: App Store Compliance

**NFR-8.1: Guidelines Adherence**
- System SHALL comply with App Store Review Guidelines 5.1.1(v) (health content)
- System SHALL provide clear disclaimers (nutrition guidance, not medical advice)
- System SHALL NOT make medical claims (no "treats obesity" or "cures metabolic syndrome")
- System SHALL implement privacy nutrition label (health data collection disclosed)

**NFR-8.2: TestFlight Beta (POC)**
- POC SHALL distribute via TestFlight (no App Store review required)
- Week 9 beta SHALL include 10-15 users (crash/battery/usability validation)
- Phase 2+ public release SHALL polish all features before App Store submission

### NFR-9: Error Handling & Monitoring

**NFR-9.1: Error Tracking**
- System SHALL log `error_logged` event (metadata: error_type, screen_name, user_action)
- System SHALL target <1% of sessions encounter errors
- System SHALL integrate error monitoring (Crashlytics/Sentry)

**NFR-9.2: Performance Monitoring**
- System SHALL log actual dashboard load times (not just target <50ms)
- System SHALL log slow queries (>100ms) for optimization
- System SHALL use Xcode Instruments to profile Week 8 build

**NFR-9.3: Menu Scanning Error Handling**
- System SHALL gracefully handle OCR failures (<85% confidence): "Adjust camera angle or enter meal manually"
- System SHALL gracefully handle AI API failures (timeout/error): "Menu scanning unavailable. Try manual logging."
- System SHALL fallback to manual meal logging (never blocks user)

### NFR-10: Internationalization (Future)

**NFR-10.1: Language Support**
- POC: System SHALL support English and German only
- Phase 3+: System SHALL support localization framework (SwiftUI LocalizedStringKey)
- Phase 3+: System SHALL provide German-native notifications (not literal translations)

**NFR-10.2: Regional Settings**
- System SHALL use metric units (kg for weight, km for distance)
- System SHALL use 24-hour time format (European standard)
- System SHALL use dd.mm.yyyy date format (German standard)

## Appendix

### Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-30 | Kevin | Initial PRD - POC scope for w-diet iOS app |

### Key Decisions & Rationale

**Decision 1: iOS-first (not cross-platform)**
- **Rationale:** Target demographic (students + young professionals) has high iOS adoption in Germany; native Swift delivers required <50ms performance; faster POC development
- **Trade-off:** Android users wait until Phase 2, but faster POC delivery and superior user experience justify delay

**Decision 2: Fundamentals First (defer scanning to Phase 2)**
- **Rationale:** POC validates core differentiators (MATADOR automation + Guidance + Explanation) BEFORE adding scanning features; if fundamentals don't create behavior change, scanning won't save it
- **Trade-off:** Manual logging is slower in POC, but validates moat before adding accelerators

**Decision 3: MATADOR Cycling Automation as Primary Innovation**
- **Rationale:** Research-backed method (30% better fat loss retention vs continuous deficit); fully automated = zero user decisions; only app implementing this methodology
- **Trade-off:** Some users prefer continuous deficit, but education ("Why Like This?") builds trust in methodology

**Decision 4: Week 1 Maintenance Strategy**
- **Rationale:** 80% of diet app users quit within first week due to stress; starting at maintenance builds habit before introducing deficit stress; onboarding tooltip prevents confusion bounce
- **Trade-off:** Users don't see immediate weight loss Day 1-7, but behavioral adherence metrics show 2x better Week 1 retention

**Decision 5: Guidance + Explanation Model**
- **Rationale:** Students/professionals want to understand the science but don't want to manage the complexity; active coaching PLUS transparent research references differentiates from passive trackers
- **Trade-off:** Education content requires careful UX (just-in-time tooltips, not overwhelming docs), but intellectual satisfaction builds trust

**Decision 6: Offline-First Architecture**
- **Rationale:** Core features must work 100% without internet; local SQLite ensures zero data loss; students have unreliable campus WiFi, traveling users need reliability
- **Trade-off:** More complex sync logic vs server-first architecture, but critical for user trust

**Decision 7: Ad-Free Free Tier**
- **Rationale:** User feedback shows Yazio ad fatigue = primary churn driver; ad-free experience differentiates w-diet; freemium monetizes engaged users in Phase 2+
- **Trade-off:** No ad revenue stream, but better user experience drives retention and willingness-to-pay for Premium

**Decision 8: POC via TestFlight (not public App Store release)**
- **Rationale:** University deadline = 10 weeks; TestFlight bypasses App Store review (faster iteration); 20-25 student beta testers sufficient for POC validation
- **Trade-off:** Limited user acquisition, but focuses on quality feedback over vanity metrics

### Success Metrics Summary

**POC Validation Targets (Week 10):**
- ✅ 20-25 student beta testers (direct recruitment + flyer campaigns + word-of-mouth)
- ✅ >70% activation rate (onboarding completion)
- ✅ >40% Week 1 retention (beats 80% industry dropout = 2x better)
- ✅ >15% first cycle completion (reach Day 28, validates MATADOR automation)
- ✅ >40% education engagement (tap "Why Like This?", validates explanation differentiator)
- ✅ >80% phase switch continuation (users trust automation and continue past Day 14)
- ✅ >99.5% crash-free rate, 0 data loss incidents
- ✅ <3 min avg session duration (validates "quick check-in" UX)

**Phase 2 Targets (Week 18):**
- Add Photo/Menu scanning Premium features (unlock monetization)
- 100-150 total users (student expansion + early professional testers)
- Test willingness-to-pay for Premium tier (€5-7/month target)
- Referral network growing organically (students ~1 referral/user)

**Phase 3 Targets (Week 30):**
- 300-500 total users
- 20-30% Premium conversion rate (€500-1,000 MRR from Premium tier)
- Add AI meal recommendations and Mental Focus Mode

**Phase 4 Targets (Week 52):**
- 800-1,200 total users
- 1-2 B2B corporate wellness pilots (€600-1,500/month per contract)
- €2,000-3,500 MRR (B2C Premium + B2B blended)
- Media coverage (university publication, Product Hunt launch)

### Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **OCR accuracy <85% in real restaurants** | Medium | High | Manual correction fallback, Week 9 real-world testing, optimize for low-light conditions |
| **AI macro estimation inaccurate (>20% error)** | Medium | High | Learning database improves over time, show confidence indicators, allow user corrections |
| **GPT-4 Vision API costs exceed revenue** | Medium | High | Limit free trial to 7 days, Pro paywall covers costs (€19.99 >> €1-2 API cost/user) |
| **Professionals don't convert to paid (<20%)** | Medium | High | POC validates willingness-to-pay via interviews before building Premium tier; pivot to €12.99 pricing if needed |
| **Menu scanning doesn't save time (<60 sec)** | Low | Critical | Optimize OCR + AI pipeline, use Apple Vision (on-device OCR), async API calls |
| **Battery drain >10% per hour** | Low | High | Native Swift optimization, on-device OCR, batch sync operations, Week 9 battery testing |
| **Data loss incident** | Low | Critical | Offline-first SQLite, cloud sync with conflict resolution, automated backups, extensive testing |
| **App Store rejection (Phase 2+)** | Low | Medium | Clear disclaimers (guidance not medical advice), GDPR compliance, privacy policy, no medical claims |

### Technical Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        w-diet iOS App                        │
│                     (Swift + SwiftUI)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Dashboard  │  │ Menu Scanner │  │ Meal Logger  │        │
│  │ (Cycle UI) │  │ (OCR + AI)   │  │ (Manual)     │        │
│  └────────────┘  └──────────────┘  └──────────────┘        │
│                                                              │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Weight Log │  │ Education    │  │ Auth/Profile │        │
│  │ (7-day avg)│  │ (Why Like?)  │  │ (Supabase)   │        │
│  └────────────┘  └──────────────┘  └──────────────┘        │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                     Business Logic                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ MATADOR Cycling Engine (Local, Swift)                │  │
│  │ - 14-day phase calculations                          │  │
│  │ - Calorie target automation (+30% variance)          │  │
│  │ - Week 1 maintenance strategy                        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Menu Scanning Pipeline                                │  │
│  │ 1. Camera → Apple Vision OCR (on-device)             │  │
│  │ 2. OCR text → GPT-4 Vision API (cloud)               │  │
│  │ 3. AI response → Nutri-Score algorithm (local)       │  │
│  │ 4. Save to learning database (SQLite)                │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                    Data Layer (Offline-First)                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ SQLite (GRDB.swift or Core Data)                     │  │
│  │ - User profile, weight logs, meal logs               │  │
│  │ - Cycle state, streak data, analytics events         │  │
│  │ - Menu scan cache (learning database)                │  │
│  │ - Unsynced records flagged (synced = 0)              │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ↕ (Background Sync)                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Supabase Backend (Cloud)                             │  │
│  │ - PostgreSQL (user data, weight/meal logs)           │  │
│  │ - Auth (Google/Apple/Email)                          │  │
│  │ - Realtime sync (conflict resolution: cloud wins)    │  │
│  │ - Analytics events table                             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕
                 (API Calls, Internet Required)
                            ↕
        ┌────────────────────────────────────────┐
        │ External Services                      │
        │ - OpenAI GPT-4 Vision API (menu scan)  │
        │ - Stripe (subscriptions, Phase 3+)     │
        │ - Crashlytics/Sentry (error monitoring)│
        └────────────────────────────────────────┘
```

### Glossary

**MATADOR:** Minimising Adaptive Thermogenesis And Deactivating Obesity Rebound - Research study (2018) showing 2-week diet/maintenance cycling improves long-term fat loss retention by 30% vs continuous deficit

**Nutri-Score:** European food rating system (A/B/C/D/E) based on nutritional composition; w-diet applies algorithm to menu items for instant health ratings

**OCR:** Optical Character Recognition - Technology to extract text from images; w-diet uses Apple Vision framework for on-device menu text extraction

**Offline-First Architecture:** Design pattern where app functions 100% without internet, syncing to cloud when online; critical for traveling consultants with unreliable connectivity

**Learning Database:** Hybrid AI + crowdsourced data model; first scan = AI estimate, repeated scans use median/average of AI + user corrections for improving accuracy

**Grace Period:** 2-hour buffer after eating window closes; meal logged within grace period = gentle nudge, not streak penalty; supports flexible eating for irregular schedules

**POC:** Proof of Concept - University project deliverable (Weeks 1-10), validates core hypothesis with 15-25 beta testers before scaling

**Freemium Model:** Business model with free tier (basic tracking) and paid tier (Premium €19.99/month with AI menu scanning, Mental Focus Mode)

**B2B Corporate Wellness:** Phase 4 revenue stream where companies pay €12-15/employee/month for Pro access (Hansefit model); targets consulting firms, tech companies

**Roar System:** Haptic + audio feedback celebrating milestones (single roar = weight log, double roar = trending toward goal, triple roar = cycle complete)

---

**Document Complete**

This PRD defines the complete scope for w-diet, from 10-week university POC through 52-week vision. Core innovation: AI menu scanning + automated MATADOR cycling solves restaurant ordering problem for traveling consultants. POC validates willingness-to-pay (€19.99/month) before building full Premium tier in Phase 3. Success depends on three pillars: (1) Technical - OCR accuracy >85%, menu scanning <60 seconds; (2) Market - >60% scan adoption, >30% conversion; (3) Business - B2B corporate contracts scale revenue beyond individual subscriptions.

Next step: Begin POC development (Week 1) with focus on menu scanning pipeline and MATADOR cycling automation.
