---
stepsCompleted: [1, 2]
inputDocuments: []
session_topic: 'Weight-loss meal recommendation web app for university course (high availability focus)'
session_goals: 'Create simple, research-backed user experience for personalized meal planning with accountability features, intermittent fasting support, and educational transparency'
selected_approach: 'ai-recommended'
techniques_used: ['First Principles Thinking', 'Six Thinking Hats', 'Resource Constraints']
ideas_generated: []
context_file: '_bmad/bmm/data/project-context-template.md'
---

# Brainstorming Session Results

**Facilitator:** Kevin
**Date:** 2025-12-29

## Session Overview

**Topic:** Weight-loss meal recommendation web app for university course (high availability focus)

**Goals:** Create simple, research-backed user experience for personalized meal planning with accountability features, intermittent fasting support, and educational transparency

### Context Guidance

This brainstorming session focuses on software and product development for a university course project emphasizing availability and incremental development. Key exploration areas include user problems, feature ideas, technical approaches, UX simplicity, and integration of academic research.

### Session Setup

**Scope & Vision:**
- Active development: Weight loss functionality
- Future roadmap: Bulk/Maintain modes (visible as "Coming Soon")
- Incremental delivery with step-by-step review
- High availability as top priority

**Core Features Identified:**
- User authentication and personalized meal recommendations
- Intermittent fasting schedule support (customizable eating windows, e.g., 12-18:00)
- Calorie-structured meals (e.g., 700 kcal brunch, 500 kcal pre-workout, 700 kcal dinner)
- Hybrid meal sourcing: AI-recommended + user-added custom meals
- Daily streak tracking for food logging
- Educational component: Academic research references and user testimonials
- Extreme UI/UX simplicity

**Personalization Features:**
- Food blacklist system (exclude specific foods/ingredients)
- Priority/favorites system (preferred foods for frequent recommendations)
- Daily staples list (foods included every day)
- AI-generated meal suggestions based on preferences and constraints
- Visual meal cards with scraped food images

## Technique Selection

**Approach:** AI-Recommended Techniques
**Analysis Context:** Weight-loss meal recommendation web app with focus on simple, research-backed UX for academic delivery

**Recommended Techniques:**

- **First Principles Thinking:** Strip away assumptions about meal apps to identify fundamental user needs and technical constraints - prevents over-engineering and ensures focus on core value
- **Six Thinking Hats:** Explore app from six perspectives (facts, emotions, benefits, risks, creativity, process) to ensure comprehensive thinking across research, UX, personalization, and technical reliability
- **Resource Constraints:** Use extreme limitations to identify essential MVP features and prioritize incremental delivery aligned with availability requirements

**AI Rationale:** This sequence balances innovation with practical constraints for academic delivery, starting with fundamental truth-finding, expanding to comprehensive perspective-taking, then narrowing to essential scope definition.

## Technique Execution Results

### Technique 1: First Principles Thinking

**Core First Principles Discovered:**

1. **Automated Cycling (MATADOR Study)** - App owns 2-week deficit/maintenance schedule (30% variance: 1900 kcal diet / 2300 kcal maintain)
2. **User Autonomy** - Calculate or manual calorie entry; adjustable anytime via calculator icon
3. **6-Hour Eating Window** - Opinionated constraint with gentle enforcement (can break, but app nudges)
4. **Education as Foundation** - "Why Like This?" section with academic research + user testimonials
5. **Emotional Feedback Design** - Smiley-based macro tracking with forgiving thresholds (70-100% green, 50-69% yellow, <50% red)
6. **Progressive Complexity** - Simple onboarding, features unlock through usage
7. **Coach, Not Judge** - Supportive nudges over punishment
8. **Gut Health Priority** - Fiber, fermented foods, anti-inflammatory focus in meal recommendations
9. **Transparency** - Cycle timer as core UI element showing days remaining in current phase
10. **High Availability** - Google/Apple + Email auth, minimal failure points

**Onboarding Flow:**
- Step 1: Authentication (Google/Apple or Email+Password)
- Step 2: Diet mode selection (Loss active, Maintain/Bulk greyed "Coming Soon")
- Step 3: Calorie target (manual entry OR calculated from weight/activity/age/gender/height + optional Apple Watch)
- Step 4: Eating window (6-hour constraint, user picks start time)
- Step 5: Dashboard reveal

**Dashboard Design (First Impression):**
- Cycle timer: "Day X of 14 - Diet/Maintenance Phase"
- Calorie progress bar
- Macro tracking with emotional smileys (Protein/Carbs/Fats/Fiber) - hidden until first meal logged
- Quick shortcuts: Brunch/Snack/Dinner
- Navigation bar: Home, Meals, Profile, Education

**Key Breakthroughs:**
- Smiley feedback as emotional design addressing user psychology (daily averages, not per-meal)
- Cycle timer solving multiple needs: removes anxiety, builds anticipation, reinforces trust, gamification
- 70% threshold as "forgiving by design" - compassion built into core architecture
- Just-in-time learning (explain cycling when user experiences first phase switch)

**User Creative Strengths:** Research-backed thinking (MATADOR study), psychological insight about feedback design, commitment to educational transparency

### Technique 2: Six Thinking Hats - White Hat (Facts)

**German Food Database:**
- OpenFoodFacts recommended for POC (free, German coverage)
- Hybrid approach: Start free, build proprietary DB from user inputs

**Business Model - Three Tiers:**
- **FREE:** MATADOR cycling, calorie/macro tracking with smileys, 6h window, streak, manual meal entry, daily weight + 7-day average with trend
- **PREMIUM (€5-7):** AI meal recommendations, weight logging with trends, basic blacklist (10), basic favorites (10), 30-day meal history, ad-free
- **PRO (€10-15):** All Premium + unlimited blacklist/favorites/staples, photo progress, advanced analytics, data export, Apple Watch, custom cycles, unlimited history, priority support

**Kevin's Background:**
- Working student at PwC (insider access to consulting world)
- Potentially 3-month visiting associate at BCG Platinion
- Lost 60kg while balancing university + consulting

### Technique 2: Six Thinking Hats - Red Hat (Emotions)

**Core Emotional Truth:** "Guidance without shame. Not being judged by another person."

**The Fire Character:**
- Gender-adaptive (male/female based on user)
- Empowering coach, never judge
- "Your journey is yours. The fire guards it." (motto)
- In-app: Supportive and empowering
- Notifications: Aggressive accountability (direct, not passive-aggressive) + Big celebrations

**The Roar Reward System:**
1. **Daily weigh-in roar** (single vibrate) - Action acknowledgment
2. **7-day average trending right** (double vibrate + roar) - Progress celebration
3. **Daily completion roar** (single vibrate) - Consistency reward
4. **Milestone super roar** (triple vibrate pattern) - Major achievements

**Week 1 Emotional Strategy:**
- Start at MAINTENANCE calories (not deficit) - Get used to app without stress
- Extra supportive messaging - "Day 1. Just data, no judgment."
- First 7-day average = Critical validation moment

**Evening Completion Feeling:**
- "Not hungry, not sleepy, just GOOD" (Kevin's lived experience)
- Fire acknowledges this state: "Fed, fueled, finished. This is discipline."

**Localization - Native Emotional Tone:**
- Notification ID system (not 1:1 translation)
- German should sound natively German, not translated English
- Directness works well in German (matches fire personality)

**Habit Formation - Hook Model:**
- **Triggers:** Morning motivation, eating window alerts, streak protection, phase transitions
- **Action:** Easiest = AI meal accept (one tap); Harder = Manual search/entry
- **Reward:** Roars, smileys, streak milestones, weight trending
- **Investment:** Daily logging, personalization setup, photo uploads, completed cycles

### Technique 2: Six Thinking Hats - Yellow Hat (Benefits)

**Mission Statement:**
"Fight the obesity pandemic by showing people life is colorful and you can change it anytime you want. All it needs is to just follow the app and not think further."

**Core Value Proposition:**
- NOT just "lose weight"
- YES "Your life can change. Starting today. Just follow."

**Unique Benefits vs Competitors:**
1. **MATADOR Cycling** (automated 2-week deficit/maintenance)
2. **Mental Focus Mode** (cognitive performance meals for students/professionals)
3. **Active Daily Guidance** (fire coaches through the day)
4. **Goal-Based Food Selection** (not just macro-fitting, optimized for weight loss/gut health/brain performance)
5. **Meal Timing Optimization** (pre-workout, post-workout, training session integration)
6. **Education On-Demand** (tooltips, "Why Like This?" section, no forced learning)
7. **Privacy-First Design** (just you + fire, optional social features)

**Kevin's Unfair Advantage:**
- Lost 60kg using this exact methodology (lived credibility)
- Student AND PwC consultant (dual-market access)
- Understands target audience intimately (been there)
- Can execute guerrilla marketing personally (campus access)

**B2B Corporate Wellness Opportunity:**
- Partner with companies as employee benefit (like Hansefit model)
- €5/employee/month (company pays)
- Employees get Pro features free
- Pitch: Reduce healthcare costs, improve productivity
- **Target firms:** PwC, BCG Platinion, other consulting/tech companies
- Kevin's insider access = Pilot opportunity

**Exit Strategy:**
- Potential acquirers: MyFitnessPal, Noom, Freeletics, health insurers, food delivery services
- Acquisition drivers: German food database, engaged user base, MATADOR IP, student/professional demographic capture
- Mission continues: Use exit funding for next health intervention project

### Technique 2: Six Thinking Hats - Black Hat (Risks)

**Critical Risks Identified:**

**1. Marketing Weakness (Priority #1)**
- Risk: Great product but no users
- Kevin acknowledges: "Not a marketing person, scared to have good product but bad marketing"
- Mitigation: Lean guerrilla tactics, leverage 60kg story, student network advantages

**2. Performance/Responsiveness (New Critical Risk)**
- Risk: Slow, laggy app = User churn (Kevin: "I hate apps that load long and get stuck in animations")
- Mitigation strategies:
  - Local-first architecture (SQLite on device)
  - Optimistic UI (show result first, save second)
  - Aggressive caching (pre-fetch meals overnight)
  - Performance budget: Dashboard <500ms, Actions <300ms, 60fps animations
  - No loading spinners on critical paths

**3. Monetization Failure (Priority #2)**
- Risk: Users love free tier, never upgrade
- Mitigation: Free tier enables success but has friction points justifying upgrade

**4. Week 1 Dropout**
- Risk: 80% of diet apps lose users in first week
- Mitigation: Start with maintenance calories (Week 1), extra gentle fire messaging, 7-day average validation

**5. GDPR Compliance**
- Risk: Collecting sensitive health data (weight, photos, meals) in Germany/EU
- Mitigation: Transparent privacy policy, explicit consent, right to deletion, data export

**University Course Requirements (Not a Risk - Kevin is Confident):**
- Working POC prototype (MANDATORY)
- Business plan (MANDATORY)
- Focus on design and simplicity

### Technique 2: Six Thinking Hats - Green Hat (Creativity)

**80/20 Strategy - Students + Young Professionals:**
- **80% effort:** Student acquisition (guerrilla campus, content, Fire's Den)
- **20% effort:** Professional preparation (mental focus mode, LinkedIn, B2B research)

**Kevin's Dual Identity Advantage:**
- University student (authentic campus access)
- PwC working student (insider consulting world)
- Potentially BCG Platinion visiting associate (3 months)
- Can credibly target BOTH markets from personal experience

**Guerrilla Marketing Arsenal (Smart-Aggressive, Not Illegal):**

1. **Campus Saturation (100km radius from Lübeck):**
   - Universities: Lübeck, Hamburg, Kiel, Flensburg (~100k students)
   - Flyers: Bathrooms, Mensa, gym locker rooms, libraries, bike racks
   - Events: "MATADOR Method Workshop" monthly, "Weigh-In Wednesdays"
   - Ambassadors: 1-2 per campus (Lifetime Pro + €100/month)

2. **Strategic Placement Tactics:**
   - Gym lamppost flyers (target fitness-conscious)
   - Grocery store guerrilla (health aisle, frozen meals, checkout)
   - Coffee shop table tents (student study spots)
   - Public transit (leave on seats during commute)
   - Library book inserts (nutrition/fitness section bookmarks)
   - Bike rack bombing (slip flyer under handlebars)
   - Sticker campaign (mirrors, water fountains, elevators)

3. **Content Empire (Multi-Channel Synergy):**
   - **TikTok/Reels:** "60 Seconds of Truth" series (60 videos, one per kg lost), Fire's Wisdom, Student hacks, Behind-the-app dev vlogs
   - **YouTube Longform:** "How I Lost 60kg" pillar video, MATADOR explained, App dev journey, User transformations, Meal prep tutorials
   - **Cross-channel:** TikTok → YouTube (full story), YouTube → App (download links), App → Content (education links to videos)
   - **Flyers → Landing page** with embedded video (seamless funnel)

4. **Fire's Den Beta Program:**
   - 100 students from different universities
   - Get: Lifetime Pro, founder access, shape features, exclusive badge, early access
   - Give: Feedback, testimonials, word-of-mouth, usage data
   - Monthly group calls, transformation highlights, weekly challenges

5. **Reddit Authentic Engagement:**
   - r/loseit, r/fitness, r/de (German market)
   - Phase 1: Build credibility (helpful comments, share knowledge)
   - Phase 2: AMA ("I lost 60kg and built an app. AMA")
   - Phase 3: Ongoing value (never spam, always add)

6. **PwC/BCG Professional Tactics (20% Effort):**
   - Colleague beta testing (5-10 users at PwC)
   - LinkedIn "dual identity" content (student + consultant)
   - Document consulting use cases (day-in-life content)
   - Internal wellness pilot pitch (after student traction)
   - BCG cohort offer if visiting associate role happens

7. **Corporate Wellness B2B Model:**
   - Partner with companies as employee benefit (Hansefit model)
   - Pitch to PwC HR, BCG, consulting firms, tech startups
   - €5/employee/month, company pays, employees get Pro free
   - Dashboard for HR: Aggregate engagement (privacy-compliant)
   - Kevin's insider access = Credible pilot opportunity

**Creative Features (Wild Ideas):**
- Meal Memory (photo recognition AI)
- Energy Forecast (tomorrow's prediction based on today's food/sleep)
- Fire's Wisdom (daily micro-lessons via notifications)
- Cycle Buddy Matching (anonymous pairs, 4-week commitment)
- Reverse Engineer Restaurant Meals (photo of menu → macro estimates)
- Progress Playlist (Spotify integration, milestone rewards)
- "What Would Fire Eat?" (real-time decision helper at grocery store)

**Creative Monetization:**
- Pay-what-you-want launch pricing (first 1000 users set own price €0-10)
- Cycle completion rewards (badges unlock features)
- Nutrition Coaching AI - Elite tier (€30/month, weekly AI voice coaching)
- 30-Day Transformation Bet (€30 upfront, complete = refund + 3 months Pro free, fail = charity)
- Unlimited referrals (both get Premium free when friend completes first cycle)

**Momentum Strategy:**
- Week 1-2: Lübeck saturation, 10 TikToks, 1 YouTube, Fire's Den recruitment
- Week 3-4: Hamburg expansion, Reddit AMA, 50 Fire's Den members
- Month 2: Multi-city presence, daily content, PwC colleague testing
- Month 3: 1000 downloads goal, corporate wellness pilot pitch
- Guerrilla success → Legitimacy → Official university/corporate partnerships

**"Stupid Student" Shield:**
- When pushing boundaries: "I'm just a student trying to help!"
- Controversy = Attention = Momentum
- Use momentum to legitimize and scale
- Ask forgiveness, not permission (within legal boundaries)

### Technique 3: Blue Hat (Process & Planning)

**Technical Architecture Decision: Offline-First with SQLite + Supabase**

**Frontend:**
- React Native (cross-platform, iOS + Android from one codebase)
- Local SQLite database (expo-sqlite or react-native-sqlite-storage)

**Backend:**
- Supabase (PostgreSQL cloud, auth, real-time sync)

**Architecture Pattern: Offline-First**
```
User Phone
  ↓
React Native App
  ↓
SQLite (local) ← INSTANT reads/writes, works 100% offline
  ↓
Supabase (cloud) ← Background sync when online
```

**Offline Capabilities (Works WITHOUT Internet):**
- ✅ Full dashboard (cycle timer, streaks, weight trends, meal history)
- ✅ Weight logging (with 7-day average calculation, trend arrows, roars)
- ✅ Manual meal entry (user types name + macros, no database needed)
- ✅ MATADOR cycling (auto-switches phases, updates calorie targets - all local logic)
- ✅ Streak tracking (increments, persists locally)
- ✅ Macro smileys (real-time feedback, calculated locally)
- ✅ Education section (cached "Why Like This?" content)
- ✅ Roars (sounds + vibrations, all local files)

**Online-Only Features:**
- ❌ First-time login (requires Supabase auth - one-time only)
- ❌ AI meal recommendations (Premium, requires API call)
- ❌ Food database search (Premium, requires OpenFoodFacts API)
- ❌ Cloud sync (background process, user doesn't see)

**Sync Strategy:**
- User actions save to SQLite immediately (instant UI updates)
- Background process syncs to Supabase when online
- Unsynced records marked with `synced = 0` flag
- On reconnect: Batch upload pending changes, download cloud updates
- Conflict resolution: Cloud timestamp wins (rare edge case)

**Performance Targets:**
- Dashboard load: <100ms (read from local SQLite)
- Weight logging: <100ms (save local, roar immediately, sync background)
- Meal logging: <200ms (save local, update smileys, sync background)
- No loading spinners on critical paths (data is always local)
- 60fps animations (lightweight, GPU-accelerated)

**SQLite Schema (Key Tables):**
- `user_profile` - Cached user data (calorie targets, preferences, cycle state)
- `weight_logs` - Daily weights with sync status
- `meal_logs` - All meals with macros, source (manual/AI/database), sync status
- `cached_ai_meals` - Yesterday's AI recommendations for offline access
- `cached_foods` - Popular foods from database for offline search

**Free Tier Users:**
- Work 100% offline (manual meal entry, weight tracking, all core features)
- No dependency on APIs (except initial login)
- Can use app on subway, airplane, anywhere

**Premium/Pro Users:**
- Work 95% offline (cached AI meals from previous day)
- Cached food database (top 100 German foods available offline)
- Fresh AI meals require internet

**Why This Architecture:**
1. **Performance** - Kevin's #1 requirement ("I hate slow apps")
2. **Reliability** - Works without internet (subway, travel, poor WiFi)
3. **Battery efficiency** - Fewer network calls
4. **User trust** - Data feels local and private
5. **Industry standard** - WhatsApp, Spotify, Notion use same pattern
6. **Scales well** - SQLite handles milfires of rows efficiently

---

## 12-Month Execution Roadmap

### **PHASE 1: University POC (Weeks 1-10)**

**Objective:** Pass university course + Validate core concept

**Timeline:** NOW → 10 weeks

**Must-Have Features:**
1. **Onboarding Flow**
   - Auth (Google/Apple Sign-In + Email/Password via Supabase)
   - Diet mode selection (Loss active, Maintain/Bulk greyed "Coming Soon")
   - Calorie target (manual entry OR calculated from: weight, age, gender, activity, height)
   - Eating window setup (6-hour constraint, user picks start time e.g., 12:00-18:00)

2. **Core Dashboard**
   - Cycle timer display ("Day X of 14 - Diet/Maintenance Phase")
   - Calorie progress bar (consumed / target)
   - Macro tracking with emotional smileys (Protein/Carbs/Fats/Fiber)
     - 70-100% = Green 😊
     - 50-69% = Yellow 😐
     - <50% = Red ☹️
   - Smileys hidden until first meal logged
   - Quick action shortcuts (Brunch/Snack/Dinner buttons)

3. **Meal Logging (Manual Only for POC)**
   - Form: Meal name, Calories, Protein, Carbs, Fats, Fiber
   - Save to SQLite immediately
   - Dashboard smileys update in real-time
   - NO AI recommendations yet (Premium feature, post-POC)
   - NO food database search yet (too complex for POC)

4. **Weight Tracking**
   - Daily weight entry form
   - Save to SQLite immediately
   - 7-day rolling average calculation (local logic)
   - Trend indicator (📉 green down / 📊 yellow stable / 📈 red up)
   - Single roar on weigh-in (vibrate + sound)
   - Double roar if 7-day average trending toward goal

5. **MATADOR Cycling Automation**
   - Auto-switch between Diet/Maintenance every 14 days
   - Calorie target updates automatically (30% variance)
   - Cycle timer counts down to next phase
   - All logic runs locally (no server needed)
   - Week 1 special: Start at MAINTENANCE calories (reduce stress, build habit)

6. **Fire Character**
   - Gender-adaptive static image (male/female based on user input)
   - Basic roar sound file + haptic vibration
   - Supportive text messaging in-app
   - NO complex animations yet (performance risk for POC)

7. **Streak Tracking**
   - Daily streak counter (increments on meal logging + weight logging)
   - Displayed on dashboard
   - Persists in SQLite

8. **Navigation**
   - Home (Dashboard)
   - Profile/Settings (basic: Edit calorie target, eating window, logout)
   - Education ("Why Like This?" section - simple markdown page with MATADOR study explanation)

9. **Offline-First Implementation**
   - All features work 100% offline (SQLite)
   - Background sync to Supabase when online
   - Unsynced records queue (retry on reconnect)

**Technology Stack:**
- Frontend: React Native
- Local: SQLite (expo-sqlite)
- Backend: Supabase (auth + cloud sync)
- Performance: Optimistic UI, local-first, <500ms dashboard load

**Deliverables:**
- ✅ Working POC demo (all features functional)
- ✅ 5-10 beta testers (friends + yourself)
- ✅ University presentation deck
- ✅ Business plan document:
  - Executive summary
  - Market analysis (German obesity stats, student/professional demographics)
  - Competitive analysis (vs MyFitnessPal, Noom, LoseIt)
  - Business model (3-tier freemium + B2B corporate wellness)
  - Financial projections (user acquisition, conversion rates, MRR growth)
  - Marketing strategy (guerrilla campus + content + Fire's Den)
  - Exit strategy (potential acquirers, valuation drivers)
  - Founder background (60kg transformation, PwC/BCG experience)

**Success Criteria:**
- ✅ POC runs smoothly (no crashes, <500ms performance)
- ✅ All core features work offline
- ✅ University course passed ✓
- ✅ Business plan approved ✓

---

### **PHASE 2: Soft Launch (Weeks 11-18, Months 3-4.5)**

**Objective:** Fire's Den beta + Initial student traction + Premium tier validation

**New Features to Add:**

1. **Premium Tier (AI Meal Recommendations)**
   - Integration with AI API (ChatGPT, Claude, or custom)
   - Prompt: "Generate 3 meals (brunch/snack/dinner) for [calories] kcal, [macros], gut health focus, German-available ingredients, student budget"
   - Cache daily recommendations in SQLite (available offline)
   - One-tap meal acceptance (add to meal log instantly)
   - Premium paywall (€5-7/month via Supabase subscriptions or Stripe)

2. **Food Database Search (Premium)**
   - OpenFoodFacts API integration
   - Search bar (debounced, 300ms delay)
   - Local cache of popular German foods (top 100: chicken, rice, eggs, etc.)
   - Barcode scanning (future enhancement, not POC)
   - Select food → Auto-populate macros → Save to meal log

3. **Enhanced Roar System**
   - Different roar sounds (daily vs milestone)
   - Triple vibration pattern for major milestones
   - Milestone badges (7-day streak, 30-day streak, first cycle complete)
   - Badge gallery in profile

4. **Fire Animations (If Performance Allows)**
   - Lightweight roar animation (2-second clip)
   - Static → Roaring → Static (60fps, GPU-accelerated)
   - Skip if device is slow (graceful degradation)

5. **Week 1 Special Messaging**
   - Maintenance calories for first 7 days (coded into onboarding logic)
   - Extra gentle fire dialogue ("Day 1. Just data, no judgment.")
   - First 7-day average = Big celebration moment (special notification)

6. **Meal History View**
   - Last 30 days of meals (Premium feature)
   - Scroll through past days
   - See macro performance over time

7. **Basic Blacklist (Premium)**
   - User can blacklist up to 10 foods
   - AI meal recommendations avoid blacklisted items
   - Stored in SQLite, synced to Supabase

**Marketing & Launch Activities:**

1. **Fire's Den Recruitment**
   - Announce on TikTok/YouTube: "Looking for 100 warriors to join Fire's Den"
   - Application: Google Form ("Why do you want to join? What's your weight loss goal?")
   - Selection criteria: Diverse universities, committed individuals, engaged personalities
   - Onboard via Discord/Telegram group
   - Grant: Lifetime Pro access codes (Supabase coupon system)

2. **Guerrilla Marketing - Lübeck Saturation**
   - Design flyer (3 versions, A/B test):
     ```
     Version A: Before/after photo + "I lost 60kg. You can too."
     Version B: "The app with a roaring fire 🔥"
     Version C: "MATADOR cycling: Lose weight, keep metabolism"
     ```
   - Print 2000 flyers (€100-150)
   - Distribution plan:
     - Bathroom stalls (every bathroom on campus)
     - Mensa tables (during lunch rush)
     - Gym locker rooms
     - Library study desks
     - Bike racks (slip under handlebars - 500 bikes in 30 minutes)
     - Coffee shops (table tents)
     - Bulletin boards
   - Track: QR code scans per flyer version (UTM parameters)

3. **Campus Events**
   - "MATADOR Method Workshop" (monthly)
     - Book university room (free for students)
     - Promote: Flyers + student Facebook groups + Instagram stories
     - 45-min presentation: Your story (10 min) + MATADOR study (15 min) + Live app demo (10 min) + Q&A (10 min)
     - Attendees get 3 months Premium free (QR code at exit)
   - "Weigh-In Wednesdays" (weekly)
     - Set up table in Mensa with scale
     - Free weigh-ins, app demo
     - Sign up on spot → 1 month Premium free

4. **Content Empire Launch**
   - **TikTok/Reels:** 3-5 videos/week
     - "60 Seconds of Truth" series (60 videos, one per kg lost)
       - Video 1: "Why I started. The day I stepped on the scale and cried."
       - Video 15: "The MATADOR study that changed everything."
       - Video 30: "Halfway there. What discipline really means."
       - Video 60: "How I built w-diet to help you."
     - Fire's Wisdom (30-sec educational clips: "Why intermittent fasting works")
     - Student hacks ("How to eat healthy on €5/day")
   - **YouTube:** Weekly longform
     - Pillar video (20-30 min): "How I Lost 60kg While Studying and Working at PwC"
     - MATADOR Method Explained (education series)
     - App dev vlogs ("Building the roar feature")
   - **Reddit:** Build credibility
     - r/loseit: Helpful comments, share knowledge (no app mention yet)
     - r/fitness: Answer questions about MATADOR cycling
     - r/de: Connect with German weight loss community

5. **PwC Colleague Beta (20% Effort)**
   - Identify 5-10 PwC colleagues who might be interested
   - Casual approach: "Hey, I built this nutrition app for my side project, mind testing it? Free Pro forever."
   - Weekly check-ins: Gather feedback on professional use cases
   - Document: "Day in consulting life with w-diet" content (LinkedIn/TikTok)

**Success Metrics:**
- 🎯 100 Fire's Den members recruited and onboarded
- 🎯 500 total downloads (Fire's Den 100 + Guerrilla 250 + Content 150)
- 🎯 200 active weekly users (40% activation rate)
- 🎯 50 Premium conversions (test €5-7 pricing)
- 🎯 €250-350 MRR (Monthly Recurring Revenue)
- 🎯 First 10 testimonials collected
- 🎯 5,000 TikTok followers, 500 YouTube subscribers

**Timeline:** 8 weeks

---

### **PHASE 3: Multi-City Expansion (Weeks 19-30, Months 5-7.5)**

**Objective:** Geographic expansion + Professional market testing + Feature maturity

**New Features:**

1. **Mental Focus Mode**
   - Toggle on dashboard: "Need mental focus today? 🧠"
   - AI adjusts meal recommendations:
     - Prioritize: Omega-3 rich foods, complex carbs, leafy greens, antioxidants
     - Avoid: Sugar spikes, heavy fats, processed foods
   - Tooltip: "Why these foods help focus? [Links to research]"
   - Premium feature

2. **Pro Tier Features**
   - 30-day + 90-day weight averages (long-term trend analysis)
   - Unlimited blacklist/favorites/daily staples
   - Photo progress tracking (before/after gallery, private)
   - Advanced analytics dashboard:
     - Weight trend graphs
     - Macro adherence charts over time
     - Cycle completion history
   - Data export (CSV/PDF reports)
   - Pricing: €10-15/month

3. **Social Features (Optional, Privacy-First)**
   - "Pride" system (friend groups, 5-10 people)
   - See friends' milestones only (NOT weight)
   - Notifications: "Your pride member Alex just completed 30 days!"
   - Opt-in only, can leave anytime
   - Anonymous option: Join random pride

4. **Advanced Roar Celebrations**
   - Milestone-specific roars (7-day different from 30-day different from cycle complete)
   - Full-screen fire animation on major milestones (Pride Rock moment)
   - Confetti effects (can be disabled in settings)
   - Shareable milestone cards (screenshot-worthy for social media)

**Expansion Activities:**

1. **Hamburg Launch**
   - Execute proven Lübeck tactics at scale
   - Universities: University of Hamburg, HAW Hamburg (~60k students)
   - Recruit 2 campus ambassadors:
     - Compensation: Lifetime Pro + €100/month
     - Responsibilities: Flyer distribution, event hosting, social media posting
   - Weekend guerrilla blitz: 1000 flyers across Hamburg campuses
   - Host workshop at University of Hamburg (partner with student wellness org)

2. **Kiel & Flensburg Launch**
   - Kiel University, FH Kiel (~25k students)
   - Europa-Universität Flensburg (~6k students)
   - 1 ambassador per city (€100/month + Lifetime Pro)
   - Smaller scale: 500 flyers per city
   - Monthly workshops

3. **Content Ramp-Up**
   - **TikTok:** Daily posts (7/week)
     - User transformation highlights (Fire's Den members)
     - Behind-the-scenes (building features)
     - Controversial takes ("Why calorie counting apps are broken")
   - **YouTube:** 2 videos/week
     - User interviews ("Meet Lisa: Lost 12kg in 3 months with w-diet")
     - Meal prep tutorials ("Student budget gut-health meals")
     - Technical deep-dives ("How the fire roar works")
   - **Reddit AMA:** "I lost 60kg as a student, built an app, now 1000 people use it. AMA"
     - Post in r/loseit, r/fitness, r/de
     - Transparent about app, focus on story
     - Link to Fire's Den (still accepting members)

4. **PwC/BCG Professional Push (20% Effort)**
   - **If BCG Platinion happens:**
     - Onboard analyst cohort (20-30 users)
     - Offer: 6 months Pro free for all 2025 analysts
     - Weekly group feedback sessions
     - Document consulting use cases (LinkedIn content series)
   - **PwC Internal:**
     - Expand to 15-20 colleague testers
     - Collect testimonials: "How w-diet helps me manage consulting stress"
   - **LinkedIn Content:**
     - "Balancing consulting, university, and building w-diet" (dual identity narrative)
     - "3 lessons from PwC that improved w-diet" (professional credibility)
     - "Mental Focus Mode: Why consultants need nutrition optimization"

5. **B2B Corporate Pilot Prep**
   - Create HR-facing pitch deck:
     - Problem: Employee burnout, poor nutrition, rising healthcare costs
     - Solution: w-diet corporate wellness (Hansefit model)
     - Pricing: €5/employee/month (company pays, employees get Pro free)
     - Dashboard: Aggregate engagement metrics (anonymized, GDPR-compliant)
     - Case study: PwC beta results (if strong)
   - Target firms: PwC HR, BCG, Deloitte, McKinsey, tech startups (Personio, Celonis, N26)

**Success Metrics:**
- 🎯 2,000 total downloads (across 7 universities)
- 🎯 800 active weekly users (40% activation maintained)
- 🎯 150 Premium + 30 Pro conversions
- 🎯 €1,200-1,800 MRR
- 🎯 10k TikTok followers, 2k YouTube subscribers
- 🎯 20-30 professional users (PwC/BCG)
- 🎯 B2B pitch deck ready + 1 pilot discussion initiated

**Timeline:** 12 weeks

---

### **PHASE 4: Legitimization & Scale Prep (Weeks 31-52, Months 8-12)**

**Objective:** Official partnerships + Corporate pilot + Media coverage + Sustainable growth

**New Features:**

1. **B2B Corporate Dashboard**
   - HR admin panel (Supabase roles/permissions)
   - Aggregate metrics (anonymized):
     - Employee participation rate
     - Average streak length
     - Engagement trends
   - NO individual weight data (GDPR privacy)
   - Export reports (monthly wellness summaries)

2. **Advanced Integrations**
   - Apple Watch: Activity data → Meal timing suggestions ("Workout detected, here's your post-workout meal")
   - Calendar sync: Detect "important meeting" → Trigger Mental Focus Mode automatically
   - Strava/Fitness apps: Training data influences meal recommendations

3. **Localization Refinement**
   - Native German notifications (not literal translations)
   - Notification ID system fully implemented
   - A/B test German vs English messaging effectiveness

4. **Performance Optimizations**
   - Dashboard load: <300ms (optimize SQLite queries)
   - Lazy loading for education content
   - Image compression for meal photos
   - Battery optimization (reduce background sync frequency)

**Legitimization Activities:**

1. **University Partnership**
   - Approach Universität zu Lübeck wellness center
   - Pitch: "2,000 students using w-diet across Germany. Let's make it official."
   - Proposal: Integrate with student health program
   - Offer: Free Pro for all Lübeck students (sponsored partnership)
   - Benefits for uni: Student wellness initiative, positive PR
   - Benefits for w-diet: Official endorsement, access to 15k students

2. **Corporate Wellness Pilot**
   - **Target: PwC Germany**
     - Leverage colleague relationships + beta success
     - Pitch to HR: "Free 3-month pilot for 50 employees"
     - Metrics: Track engagement, satisfaction, wellness improvements
     - Case study: Document results for other firms
   - **Backup: Smaller consulting firm or startup**
     - If PwC too slow, approach Platinion, Deloitte Digital, or tech startup
     - Easier decision-making, faster pilots

3. **Media Outreach**
   - **Local news:** "Lübeck student's app reaches 2,000 users, fights obesity"
   - **German tech blogs:**
     - t3n: "Student baut Ernährungs-App mit KI-Löwen"
     - Gründerszene: "Wie ein Student PwC, Uni und Startup vereint"
     - Deutsche Startups: "w-diet: Die App gegen Adipositas"
   - **Health publications:**
     - Fit for Fun: "Die MATADOR-Methode: Abnehmen ohne Jojo-Effekt"
     - Men's Health Germany: "Vom Studenten zum Gründer: 60kg Transformation"
   - Press kit: Logo, screenshots, founder photo, press release, media contact

4. **Product Hunt Launch**
   - Prepare assets:
     - Hero image (fire + dashboard screenshot)
     - Demo video (60 seconds: Problem → Solution → Roar)
     - Tagline: "The nutrition app with a roaring fire 🔥"
     - Description: MATADOR cycling, mental focus, gut health, built by student who lost 60kg
   - Launch strategy:
     - Post at 12:01 AM PST (midnight launch)
     - Rally Fire's Den to upvote + comment
     - Respond to every comment within 1 hour
     - Offer: "Product Hunt exclusive - 50% off Pro for life"
   - Goal: Top 5 product of the day (500+ upvotes)

5. **Referral Program Launch**
   - Unlimited referrals: Invite friend → Both get 1 month Premium free
   - Friend completes first cycle → Both get another month free
   - Viral loop mechanics
   - Track referral source (UTM codes)

**Success Metrics:**
- 🎯 5,000 total downloads
- 🎯 2,000 active weekly users (40% activation)
- 🎯 400 Premium + 80 Pro conversions
- 🎯 €3,000-4,500 MRR
- 🎯 1 university partnership (official endorsement)
- 🎯 1 corporate pilot (50+ employees)
- 🎯 Media coverage (5+ publications)
- 🎯 Product Hunt: Top 10 of the day
- 🎯 20k TikTok followers, 5k YouTube subscribers
- 🎯 Sustainable growth (15-20% MoM)

**Timeline:** 22 weeks

---

## Summary: 12-Month Roadmap at a Glance

| Phase | Timeline | Focus | Key Metrics |
|-------|----------|-------|-------------|
| **POC** | Weeks 1-10 | University course + Core features | POC working, course passed |
| **Soft Launch** | Weeks 11-18 | Fire's Den + Lübeck saturation | 500 downloads, 50 Premium, €350 MRR |
| **Expansion** | Weeks 19-30 | Multi-city + Professional testing | 2k downloads, 150 paid, €1.5k MRR |
| **Legitimization** | Weeks 31-52 | Partnerships + Corporate + Media | 5k downloads, 400 paid, €3.5k MRR |

---

## Immediate Next Steps (This Week)

1. ✅ Review this brainstorming document thoroughly
2. ✅ Make architectural decision: Confirm React Native + SQLite + Supabase
3. ✅ Set up development environment (install React Native, Expo, Supabase CLI)
4. ✅ Create wireframes in Figma (onboarding, dashboard, meal logging)
5. ✅ Start business plan document (use Yellow/Black Hat insights)
6. ✅ Design first flyer version (test concept with 3 friends)
7. ✅ Outline first 10 TikTok video scripts
8. ✅ Start coding: Onboarding flow (auth screen first)

**First Code Sprint Goal (Week 1):** Working authentication with Supabase
