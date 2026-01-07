---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/architecture.md'
  - '_bmad-output/planning-artifacts/ux-design-specification.md'
currentStep: 4
epicStructureApproved: true
allStoriesComplete: true
validationComplete: true
totalEpics: 5
totalStories: 24
workflowComplete: true
---

# w-diet - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for w-diet, decomposing the requirements from the PRD, UX Design, and Architecture into implementable stories.

## Requirements Inventory

### Functional Requirements

**FR-1: Authentication & User Management**
- FR-1.1: System SHALL support Google Sign-In, Apple Sign-In, and Email/Password authentication via Supabase
- FR-1.2: System SHALL present 5-step onboarding sequence (Auth → Goal → Calorie target → Eating window → Dashboard)
- FR-1.3: System SHALL store user profile (goal weight, current weight, calorie target, eating window, cycle state)

**FR-2: Manual Meal Logging**
- FR-2.1: System SHALL provide input fields (Meal name, Calories, Protein, Carbs, Fats, Fiber) with optional macros
- FR-2.2: System SHALL update dashboard in real-time (progress bars, macro smileys)
- FR-2.3: System SHALL validate eating window with 2-hour grace period

**FR-3: Daily Weight Tracking**
- FR-3.1: System SHALL provide weight input form (kg, 0.1kg precision) with timestamp

**FR-4: 7-Day Rolling Average & Roar Feedback**
- FR-4.2: System SHALL calculate 7-day rolling average starting Day 7 with trend indicators (📉/📊/📈)
- FR-4.3: System SHALL trigger roar feedback (haptic + sound): single on weight entry, double if trending toward goal

**FR-5: MATADOR Cycling Automation**
- FR-5.1: System SHALL auto-switch between Diet and Maintenance phases every 14 days with automatic calorie adjustment (Diet: deficit, Maintenance: +30%)
- FR-5.2: System SHALL start new users at Maintenance calories for Week 1 (Days 1-7), switch to Diet on Day 14
- FR-5.3: System SHALL persist cycle state in local SQLite and calculate phase switches based on midnight transitions

**FR-6: Dashboard & Core UI**
- FR-6.1: System SHALL display MATADOR cycle timer, calorie progress bar, macro smileys (70-100% = 😊, 50-69% = 😐, <50% = ☹️), streak counter, quick action buttons
- FR-6.2: System SHALL load dashboard in <50ms and render at 60fps with zero loading spinners
- FR-6.3: System SHALL display minimalist fire character (4 variations: default, glasses, strong, gentle)

**FR-7: Education & Transparency**
- FR-7.1: System SHALL provide "Why Like This?" markdown content explaining MATADOR research with links to academic papers
- FR-7.2: System SHALL display in-context tooltips at key moments (onboarding, phase switch, first 7-day average)

**FR-8: Offline-First Architecture**
- FR-8.1: System SHALL store ALL core data in SQLite (profile, weight logs, meal logs, streak data, analytics events, menu scan cache)
- FR-8.2: System SHALL provide 100% functionality offline (dashboard, logging, MATADOR calculations, education content)
- FR-8.3: System SHALL sync local SQLite to Supabase PostgreSQL when online with background sync and conflict resolution (cloud timestamp wins)

**FR-9: Analytics & Validation Tracking**
- FR-9.1: System SHALL track 15 core events (onboarding, menu scan, meal logged, weight logged, education opened, cycle phase switched, subscription events, session tracking, screen views)
- FR-9.2: System SHALL store events in local SQLite and sync to Supabase analytics_events table
- FR-8.3: System SHALL calculate POC validation metrics (activation rate, Week 1 retention, first cycle completion, education engagement, phase switch continuation)

**FR-10: Streak & Milestone System**
- FR-10.1: System SHALL increment daily streak on meal logging AND weight logging (both required), persist in SQLite
- FR-10.2: System SHALL trigger roar feedback at milestones (single: daily weight, double: 7-day average trending, triple: Day 28 first cycle)

### Non-Functional Requirements

**NFR-1: Performance**
- NFR-1.1: Dashboard SHALL load in <50ms (P99), all actions <300ms, menu scanning <60s total, zero loading spinners
- NFR-1.2: UI SHALL render at 60fps minimum with GPU-accelerated animations
- NFR-1.3: System SHALL use Xcode Instruments for profiling and optimization

**NFR-2: Battery Efficiency**
- NFR-2.1: Active use <5% battery/hour, menu scanning <2%/scan, background sync <1%/hour, idle <0.1%/hour
- NFR-2.2: System SHALL test on iPhone 12 with degraded battery
- NFR-2.3: Use on-device OCR, batch sync (15min intervals), minimize background refresh

**NFR-3: Reliability**
- NFR-3.1: System SHALL maintain >99.5% crash-free rate with Crashlytics/Sentry integration
- NFR-3.2: NEVER lose user data (zero tolerance), validate before saving, handle sync conflicts gracefully
- NFR-3.3: 100% offline functionality with transparent sync queue and exponential backoff retry

**NFR-4: Scalability**
- NFR-4.1: POC SHALL handle 100 concurrent users, architecture SHALL scale to 10K users without major rewrite
- NFR-4.2: Supabase costs <€100/month at 5K users, GPT-4 Vision <€2/user/month, infrastructure <20% MRR

**NFR-5: Security & Privacy**
- NFR-5.1: Store health data locally by default, encrypt in transit (HTTPS/TLS 1.3), encrypt at rest (Supabase)
- NFR-5.2: GDPR compliance (data export CSV, account deletion within 30 days, privacy policy, opt-in cloud sync)
- NFR-5.3: OAuth 2.0 for Google/Apple, bcrypt password hashing, 30-day session timeout, no third-party data sharing

**NFR-6: Usability & Accessibility**
- NFR-6.1: Onboarding <3min average, core loop understood <2min, menu scanning feels instant, no "slow" complaints
- NFR-6.2: POC basic accessibility (readable fonts, contrast), Phase 2+ VoiceOver, Dynamic Type, WCAG 2.1 AA

**NFR-7: Maintainability & Developer Experience**
- NFR-7.1: Swift best practices (async/await), unit tests for critical paths, integration tests for sync, >80% coverage
- NFR-7.2: Document API endpoints, database schema, analytics events, README with setup
- NFR-7.3: POC in 10 weeks, maintainable for Phase 2 features

**NFR-8: App Store Compliance**
- NFR-8.1: Comply with App Store Guidelines 5.1.1(v), provide disclaimers (guidance not medical advice), no medical claims, privacy nutrition label
- NFR-8.2: POC via TestFlight (10-15 users), Phase 2+ polish for App Store

**NFR-9: Error Handling & Monitoring**
- NFR-9.1: Log error_logged events, target <1% sessions with errors, integrate Crashlytics/Sentry
- NFR-9.2: Log dashboard load times, slow queries >100ms, profile with Xcode Instruments
- NFR-9.3: Gracefully handle OCR failures, AI errors, offline menu scanning

### Additional Requirements

**From Architecture:**
- NO starter template - custom Xcode project from scratch (Architecture explicitly rejects existing templates due to unique GRDB + Supabase stack)
- SwiftUI Native + Custom Singleton Managers for state management (@StateObject for ViewModels, @EnvironmentObject for app-wide singletons)
- GRDB for local SQLite database with DatabaseMigrator for schema versioning
- Supabase for cloud sync (PostgreSQL), authentication (OAuth + email/password), and analytics storage
- Sentry for crash monitoring and performance tracking
- Custom analytics pipeline to Supabase (reuses SQLite → Supabase sync infrastructure)
- Environment configuration via Xcode Schemes + .xcconfig files + Keychain for secrets (Dev/Staging/Prod builds)
- NavigationStack for navigation pattern (iOS 16+)
- Hybrid dependency injection (Environment + Constructor with default parameters)
- German-only localization for POC (JSON-based), English in Phase 2
- Custom error wrapper with analytics integration (domain-specific error types: AppError, DatabaseError, SyncError, etc.)
- OSLog for development debugging (subsystems: Database, Sync, MATADOR, UI)

**From UX Design:**
- iOS native only (Swift/SwiftUI), portrait orientation locked
- Thumb-zone optimized UI (60/40 split: upper 40% information, lower 60% interactions)
- Forgiving design philosophy (70% macro threshold = green smiley, not perfectionist 100%)
- Fire character integration (4 static variations: 🔥 default, 🔥🤓 glasses for education, 🔥💪 strong for milestones, 🔥😌 gentle for Week 1)
- Haptic roar feedback system (single/double/triple roars with device haptic engine + audio playback)
- Safe area handling (notch, Dynamic Island, home indicator support)
- iOS picker wheel for weight input (one-handed operation)
- Accessibility compliance (BITV 2.0 German law, WCAG 2.1 Level AA in Phase 2)
- Responsive design for all iPhone models (iPhone 12+, iOS 16+)

### FR Coverage Map

FR-1.1: Epic 1 - User authentication (Google/Apple/Email via Supabase)
FR-1.2: Epic 1 - 5-step onboarding flow
FR-1.3: Epic 1 - User profile storage (SQLite + Supabase sync)
FR-2.1: Epic 3 - Manual meal logging form (calories required, macros optional)
FR-2.2: Epic 3 - Real-time dashboard updates (progress bars, macro smileys)
FR-2.3: Epic 3 - Eating window validation with 2-hour grace period
FR-3.1: Epic 3 - Weight logging with iOS picker wheel (0.1kg precision)
FR-4.2: Epic 4 - 7-day rolling average with trend indicators (📉/📊/📈)
FR-4.3: Epic 4 - Roar feedback system (haptic + audio, single/double/triple)
FR-5.1: Epic 2 - Automatic MATADOR phase switching every 14 days
FR-5.2: Epic 2 - Week 1 special strategy (Maintenance → Diet on Day 14)
FR-5.3: Epic 2 - Cycle state persistence and midnight transitions
FR-6.1: Epic 1 + Epic 2 - Dashboard components (cycle timer, progress bars, fire character, streak counter)
FR-6.2: Epic 1 + Epic 2 - Performance requirements (<50ms load, 60fps rendering)
FR-6.3: Epic 2 - Fire character variations (4 static variations based on context)
FR-7.1: Epic 2 - "Why Like This?" educational content (markdown, research links)
FR-7.2: Epic 2 - In-context tooltips (onboarding, phase switch, 7-day average)
FR-8.1: Epic 1 - SQLite local storage setup (GRDB migrations, schema)
FR-8.2: Epic 3 - Offline functionality (logging works 100% offline)
FR-8.3: Epic 1 + Epic 3 + Epic 5 - Cloud sync infrastructure (SQLite → Supabase background sync)
FR-9.1: Epic 5 - Analytics event tracking (15 core events)
FR-9.2: Epic 5 - SQLite → Supabase analytics pipeline
FR-9.3: Epic 5 - POC validation metrics (activation, retention, cycle completion)
FR-10.1: Epic 4 - Streak tracking (daily logging consistency)
FR-10.2: Epic 4 - Milestone celebrations (roar feedback at key moments)

All NFRs addressed across all epics:
- Performance (NFR-1): Epic 1, 2, 3 (dashboard <50ms, 60fps UI)
- Battery Efficiency (NFR-2): Epic 1, 3, 5 (on-device processing, batch sync)
- Reliability (NFR-3): Epic 1, 3 (offline-first, crash-free >99.5%)
- Scalability (NFR-4): Epic 1, 5 (architecture supports 10K users)
- Security & Privacy (NFR-5): Epic 1 (GDPR compliance, encryption, OAuth)
- Usability & Accessibility (NFR-6): Epic 1, 2, 3 (onboarding <3min, accessible UI)
- Maintainability (NFR-7): Epic 1 (Swift best practices, test coverage >80%)
- App Store Compliance (NFR-8): Epic 1, 5 (TestFlight distribution, privacy labels)
- Error Handling & Monitoring (NFR-9): Epic 1, 5 (Sentry integration, error tracking)

## Epic List

### Epic 1: Get Started - Onboarding & First Login
Users can create an account (Google/Apple/Email), complete 5-step onboarding (goal, calorie target, eating window), and see their personalized MATADOR dashboard for the first time.

**FRs covered:** FR-1.1, FR-1.2, FR-1.3, FR-6.1 (dashboard shell), FR-6.2, FR-8.1, FR-8.3 (sync foundation)

**Stories include:**
- 1.1: Project Setup & Core Infrastructure (GRDB, Supabase, environment config, custom Xcode project)
- 1.2: Authentication Implementation (Google/Apple/Email OAuth via Supabase)
- 1.3: 5-Step Onboarding Flow (goal selection, calorie target, eating window)
- 1.4: Basic Dashboard Shell (empty state with Day 1 cycle timer, fire character, quick action buttons)

**Shippable:** ✅ Users can sign up and see "Day 1 - Maintenance Phase" dashboard (even with zero logged data)

---

### Epic 2: Understand My Journey - MATADOR Cycle Intelligence
Users understand their MATADOR cycle (why it works, what phase they're in, when it switches) and see the cycle timer update in real-time with educational transparency.

**FRs covered:** FR-5.1, FR-5.2, FR-5.3, FR-6.1 (cycle timer), FR-6.3, FR-7.1, FR-7.2

**Stories include:**
- 2.1: MATADOR Cycle Engine (state machine, phase switching logic, midnight transitions, fail-safe recovery)
- 2.2: Cycle Timer Dashboard Component (Day X of 14, Diet vs Maintenance phase display)
- 2.3: "Why Like This?" Education Content (markdown content, MATADOR research links)
- 2.4: In-Context Tooltips (onboarding explanation, phase switch nudges)
- 2.5: Fire Character System (4 variations: default 🔥, glasses 🔥🤓, strong 🔥💪, gentle 🔥😌)

**Shippable:** ✅ Users see live cycle countdown, learn why MATADOR works, even without logging data yet

---

### Epic 3: Track My Progress - Daily Logging
Users can log meals (calories + macros) and daily weight, seeing instant dashboard updates with real-time visual feedback.

**FRs covered:** FR-2.1, FR-2.2, FR-2.3, FR-3.1, FR-6.1 (progress bars, smileys), FR-8.2, FR-8.3 (sync queue)

**Stories include:**
- 3.1: Meal Logging Form (calories required, macros optional, meal type shortcuts)
- 3.2: Weight Logging (iOS picker wheel for one-handed input, 0.1kg precision)
- 3.3: Real-Time Dashboard Updates (calorie progress bar, macro smileys 😊/😐/☹️)
- 3.4: Eating Window Validation (2-hour grace period, gentle nudges)
- 3.5: SQLite Persistence + Sync Queue (offline-first storage, background sync to Supabase)

**Shippable:** ✅ Complete tracking system with immediate visual feedback

---

### Epic 4: Celebrate Wins - Insights & Motivation
Users receive motivational feedback through 7-day rolling averages, trend indicators, haptic roar celebrations, and streak tracking.

**FRs covered:** FR-4.2, FR-4.3, FR-10.1, FR-10.2

**Stories include:**
- 4.1: 7-Day Rolling Average Calculation (starts Day 7, updates daily)
- 4.2: Trend Indicators (📉 green down, 📊 yellow stable, 📈 red up)
- 4.3: Haptic Roar Feedback System (single roar: weight log, double: trending down, triple: Day 28 milestone)
- 4.4: Streak Tracking (daily logging consistency, persisted in SQLite)
- 4.5: Milestone Celebrations UI (streak counter on dashboard)

**Shippable:** ✅ Complete gamification layer analyzing logged data from Epic 3

---

### Epic 5: Validate & Learn - Analytics Infrastructure
Development team can track POC validation metrics (activation rate, Week 1 retention, first cycle completion) to validate product-market fit for university thesis.

**FRs covered:** FR-9.1, FR-9.2, FR-9.3, FR-8.3 (analytics sync)

**Stories include:**
- 5.1: Analytics Event Schema (15 core events: onboarding, logging, education, phase switch, etc.)
- 5.2: Event Tracking Integration (logEvent() function across all features)
- 5.3: SQLite → Supabase Analytics Pipeline (background sync, reuses sync infrastructure)
- 5.4: POC Metrics Dashboard (activation, retention, cycle completion calculations)

**Shippable:** ✅ Complete analytics system for POC validation and business plan data

---

## Epic 1: Get Started - Onboarding & First Login

Users can create an account (Google/Apple/Email), complete 5-step onboarding (goal, calorie target, eating window), and see their personalized MATADOR dashboard for the first time.

### Story 1.1: User Authentication & Profile Creation

As a new user,
I want to create an account using Google, Apple, or Email,
So that I can start tracking my MATADOR journey.

**Implementation Tasks:**
1. Project setup (custom Xcode project, GRDB/Supabase/Sentry packages)
2. Environment configuration (.xcconfig files for Dev/Staging/Prod)
3. GRDB migrations for user_profile table
4. Supabase client initialization
5. Error handling framework (AppError, Sentry integration)
6. Authentication UI and logic (Google/Apple/Email OAuth)

**Acceptance Criteria:**

**Given** I am a new user opening the app
**When** I select a sign-in method (Google, Apple, or Email/Password)
**Then** I can successfully authenticate and my profile is created in local SQLite

**And** my session persists locally for offline access
**And** app handles authentication errors gracefully with user-friendly messages

### Story 1.2: 5-Step Onboarding Flow

As a newly authenticated user,
I want to complete a guided onboarding flow,
So that the app knows my goals and can personalize my MATADOR cycle.

**Acceptance Criteria:**

**Given** I just authenticated for the first time
**When** I go through the 5-step onboarding
**Then** I complete these steps in sequence:
1. Goal selection (Weight Loss active, Maintain/Bulk "Coming Soon")
2. Calorie target (manual entry OR auto-calculated from stats)
3. Eating window setup (6-hour constraint, user-selected start time)
4. Micro-intervention tooltip explaining Week 1 strategy
5. Dashboard reveal

**And** my onboarding data is saved to local SQLite (user_profile table)
**And** the entire flow completes in under 3 minutes

### Story 1.3: Dashboard Shell with Empty State

As a user who completed onboarding,
I want to see my personalized dashboard,
So that I understand what the app will track.

**Acceptance Criteria:**

**Given** I completed onboarding
**When** I reach the dashboard
**Then** I see:
- "Day 1 of 14 - Maintenance Phase" cycle timer
- Fire character (🔥😌 gentle Week 1 variant)
- Calorie progress bar showing 0 / [my target] kcal
- Empty macro progress (hidden until first meal logged per FR-6.1)
- Quick action buttons (Log Meal, Log Weight, Why Like This?)
- Streak counter (0 days)

**And** dashboard loads in under 50ms
**And** UI renders at 60fps on iPhone 12+

### Story 1.4: Cloud Sync Foundation

As a user with an account,
I want my data to sync to the cloud when online,
So that I don't lose my data if I switch devices.

**Acceptance Criteria:**

**Given** I have logged data in local SQLite
**When** the app has internet connectivity
**Then** unsynced records are pushed to Supabase PostgreSQL in the background

**And** sync happens transparently (no loading spinners)
**And** sync failures are retried with exponential backoff
**And** sync conflicts are resolved using cloud timestamp wins strategy

---

## Epic 2: Understand My Journey - MATADOR Cycle Intelligence

Users understand their MATADOR cycle (why it works, what phase they're in, when it switches) and see the cycle timer update in real-time with educational transparency.

### Story 2.1: MATADOR Cycle Engine

As a user in the MATADOR program,
I want the app to automatically manage my diet/maintenance cycle phases,
So that I don't have to manually track which phase I'm in or when to switch.

**Implementation Tasks:**
1. GRDB migration for cycle_state table
2. CycleEngine singleton with state machine logic
3. Automatic phase switching every 14 days (midnight transitions)
4. Week 1 special logic (Maintenance calories Days 1-7, Diet starts Day 14)
5. Fail-safe recovery on app launch (validate cycle state against calendar)
6. Calorie target adjustment (+30% for Maintenance phase)

**Acceptance Criteria:**

**Given** I completed onboarding
**When** the app initializes my cycle
**Then** I start on Day 1 in Maintenance Phase with Week 1 calories

**And** at midnight on Day 14, the app automatically switches to Diet Phase with deficit calories
**And** at midnight on Day 28, the app switches back to Maintenance Phase
**And** if I force-quit or the app crashes, the cycle state recovers correctly on next launch
**And** calorie targets update automatically based on current phase

### Story 2.2: Cycle Timer Dashboard Component

As a user tracking my MATADOR cycle,
I want to see which day I'm on and which phase I'm in,
So that I always know my current cycle status at a glance.

**Acceptance Criteria:**

**Given** I'm logged into the app with an active cycle
**When** I view the dashboard
**Then** I see a prominent cycle timer displaying "Day X of 14 - Diet Phase" or "Day X of 14 - Maintenance Phase"

**And** the day counter increments automatically at midnight
**And** the phase label updates automatically when switching phases
**And** the timer is visible on every dashboard load without delay

### Story 2.3: "Why Like This?" Education Content

As a user curious about the MATADOR approach,
I want to access educational content explaining the science,
So that I understand why the app uses 2-week cycling instead of continuous dieting.

**Acceptance Criteria:**

**Given** I'm on the dashboard
**When** I tap "Why Like This?" or the info icon (ℹ️)
**Then** I see markdown-formatted content explaining:
- MATADOR study methodology and results
- Why 2-week cycling prevents metabolic adaptation
- Why Week 1 starts at maintenance (habit formation before stress)
- Why 6-hour eating window (intermittent fasting benefits)

**And** content includes links to academic research papers (MATADOR study, IF research)
**And** the app tracks `why_like_this_opened` analytics event
**And** I can easily return to the dashboard

### Story 2.4: In-Context Tooltips

As a user going through key moments in my MATADOR journey,
I want to see helpful tooltips that explain what's happening,
So that I understand important transitions and features without feeling confused.

**Acceptance Criteria:**

**Given** I'm using the app for the first time or experiencing a key moment
**When** I reach specific triggers
**Then** I see auto-popup tooltips at these moments:
- Onboarding Step 4: "🔥 Week 1 starts gentle. Why? [Tap to learn]"
- First phase switch (Day 14): "Why am I eating more now?" (or "Why less?" depending on direction)
- First 7-day average appears (Day 7): "What does this trend mean?"

**And** after I dismiss a tooltip, a small info icon (ℹ️) remains next to the relevant UI element
**And** tapping the ℹ️ icon shows the same tooltip content again
**And** dismissed state is persisted in UserDefaults so tooltips don't auto-popup again
**And** tooltips are non-blocking and can be dismissed easily

### Story 2.5: Fire Character System

As a user interacting with the app,
I want to see a supportive fire coach character that changes based on context,
So that the app feels personable and motivating.

**Acceptance Criteria:**

**Given** I'm using different features of the app
**When** the context changes
**Then** I see the appropriate fire variation:
- 🔥 Default (confident, calm) - standard dashboard view
- 🔥🤓 Glasses - when viewing "Why Like This?" educational content
- 🔥💪 Strong - when celebrating milestones (streaks, weight trending down)
- 🔥😌 Gentle - Week 1 and during onboarding

**And** the fire character is displayed as a static image (no animations in POC)
**And** fire transitions happen instantly based on app context
**And** the fire character is positioned subtly in the background (upper corner/header area) as a supportive observer, not prominently competing with user data

---

## Epic 3: Track My Progress - Daily Logging

Users can log meals via food database search, OCR scanning, or manual entry, and log daily weight, seeing instant dashboard updates with real-time visual feedback.

### Story 3.1: Manual Meal Entry

As a user tracking my nutrition,
I want to manually enter meal details when needed,
So that I can log any food even if it's not in a database or I prefer direct input.

**Implementation Tasks:**
1. GRDB migration for meal_logs table (id, user_id, meal_name, calories_kcal, protein_g, carbs_g, fat_g, fiber_g, source [manual/db_search/ocr_scan], logged_at, created_at, updated_at, synced_at)
2. Manual entry form UI (meal name, calories required, macros optional)
3. Meal type shortcuts (Brunch/Snack/Dinner buttons)
4. Save to SQLite immediately

**Acceptance Criteria:**

**Given** I'm on the dashboard
**When** I tap "Log Meal" → "Enter Manually"
**Then** I see a form with meal name, calories (required), protein/carbs/fats/fiber (optional)

**And** I can select meal type via shortcut buttons
**And** when I submit, meal is saved to SQLite with source='manual'
**And** the form works 100% offline

### Story 3.2: Food Database Search

As a user logging meals,
I want to search a food database and auto-fill nutrition data,
So that I don't have to manually enter calories/macros for common foods.

**Implementation Tasks:**
1. Integrate Nutritionix API (or USDA FoodData Central)
2. Search UI with query input and results list
3. Cache search results in SQLite for offline access
4. Auto-fill meal_logs from selected food

**Acceptance Criteria:**

**Given** I'm on the dashboard
**When** I tap "Log Meal" → food search is the default option
**Then** I can type a food name and see search results from the food database

**And** when I select a food, nutrition data (calories, protein, carbs, fats) auto-fills
**And** I can adjust serving size/quantity before saving
**And** meal is saved to SQLite with source='db_search'
**And** if API fails or I'm offline, I see "Search unavailable - Enter Manually" fallback option

### Story 3.3: Nutrition Label OCR Scanner

As a user eating packaged foods,
I want to scan nutrition labels with my camera,
So that I can quickly log meals without typing.

**Implementation Tasks:**
1. Camera permission request
2. Apple Vision framework text recognition
3. Parse nutrition label text (calories, protein, carbs, fats extraction)
4. Auto-fill form with extracted data

**Acceptance Criteria:**

**Given** I'm on the dashboard
**When** I tap "Log Meal" → "Scan Label"
**Then** my camera opens and I can point it at a nutrition label

**And** the app extracts nutrition data (calories, protein, carbs, fats) using on-device OCR
**And** extracted data auto-fills the meal entry form for review
**And** I can edit OCR results before saving if extraction was incorrect
**And** meal is saved to SQLite with source='ocr_scan'
**And** if OCR fails (<85% confidence), I see "Try manual entry" fallback

### Story 3.4: Weight Logging with iOS Picker Wheel

As a user tracking my weight,
I want to log my daily weight using an intuitive iOS picker wheel,
So that I can easily track my progress with one-handed operation.

**Implementation Tasks:**
1. GRDB migration for weight_logs table (id, user_id, weight_kg, logged_at, created_at, updated_at, synced_at)
2. Weight logging UI with iOS Picker wheel (kg, 0.1kg precision)
3. Save to SQLite immediately

**Acceptance Criteria:**

**Given** I'm on the dashboard
**When** I tap "Log Weight"
**Then** I see an iOS picker wheel for selecting weight in kg (0.1kg precision, range 40-200kg)

**And** when I confirm, my weight is saved to SQLite with timestamp
**And** weight logging works 100% offline
**And** picker wheel is optimized for one-handed thumb-zone operation

### Story 3.5: Real-Time Dashboard Updates

As a user logging meals and weight,
I want to see my progress update instantly on the dashboard,
So that I get immediate visual feedback on my tracking.

**Acceptance Criteria:**

**Given** I just logged a meal or weight
**When** I return to the dashboard
**Then** I see updated values without delay:
- Calorie progress bar: "X / Target kcal" with visual fill
- Macro smileys (😊/😐/☹️) based on thresholds: 70-100% = 😊 green, 50-69% = 😐 yellow, <50% = ☹️ red
- Macro smileys are hidden until first meal is logged (progressive disclosure per FR-6.1)

**And** updates happen in <30ms (no loading spinner)
**And** UI renders at 60fps during updates

### Story 3.6: SQLite Persistence + Sync Queue

As a user with logged data,
I want my meals and weight logs to sync to the cloud when online,
So that my data is backed up and accessible across devices.

**Implementation Tasks:**
1. GRDB migration for sync_queue table (if not created in Epic 1)
2. Background sync logic: unsynced records (synced_at = NULL) push to Supabase
3. Conflict resolution (cloud timestamp wins)
4. Exponential backoff retry on sync failures

**Acceptance Criteria:**

**Given** I have unsynced meal_logs or weight_logs in SQLite
**When** the app has internet connectivity
**Then** records are pushed to Supabase PostgreSQL in the background

**And** sync happens transparently (no loading spinners)
**And** synced records are marked with synced_at timestamp
**And** sync failures retry automatically with exponential backoff
**And** conflicts are resolved using cloud timestamp wins strategy

---

## Epic 4: Celebrate Wins - Insights & Motivation

Users receive motivational feedback through 7-day rolling averages, trend indicators, haptic roar celebrations, and streak tracking.

### Story 4.1: 7-Day Rolling Average Calculation

As a user tracking my weight over time,
I want to see a 7-day rolling average,
So that I can understand my true progress trend beyond daily fluctuations.

**Acceptance Criteria:**

**Given** I have logged weight for at least 7 days
**When** I view the dashboard on Day 7 or later
**Then** I see my 7-day rolling average displayed beneath today's weight

**And** the average updates automatically each day at midnight
**And** the calculation uses the most recent 7 weight entries
**And** the average is hidden until Day 7 (progressive disclosure)

### Story 4.2: Trend Indicators

As a user viewing my 7-day average,
I want to see if my weight is trending in the right direction,
So that I know if my MATADOR cycle is working.

**Acceptance Criteria:**

**Given** I have a 7-day rolling average
**When** I view my weight tracking section
**Then** I see a trend indicator next to my average:
- 📉 Green down arrow: average decreasing (success - moving toward goal)
- 📊 Yellow flat: average stable (±0.2kg, neutral)
- 📈 Red up arrow: average increasing (caution)

**And** trend indicator updates automatically when average changes
**And** trend calculation compares current average to previous day's average

### Story 4.3: Haptic Roar Feedback System

As a user celebrating my progress,
I want to receive satisfying haptic and audio feedback,
So that I feel motivated and rewarded for my efforts.

**Implementation Tasks:**
1. Audio asset creation (fire roar sound at 3 intensity levels)
2. Haptic engine integration (UIImpactFeedbackGenerator)
3. Trigger logic for different roar types

**Acceptance Criteria:**

**Given** I complete key actions in the app
**When** triggers occur
**Then** I receive appropriate roar feedback:
- **Single roar** (light haptic + soft audio): When I log my daily weight
- **Double roar** (medium haptic + louder audio): When my 7-day average is trending down 📉
- **Triple roar** (heavy haptic + loudest audio): When I complete my first full cycle (Day 28)

**And** haptic and audio are synchronized
**And** audio respects device silent mode (haptic still works)
**And** roar feedback feels rewarding, not annoying

### Story 4.4: Streak Tracking

As a user building consistency,
I want to see my daily logging streak,
So that I'm motivated to maintain my tracking habit.

**Acceptance Criteria:**

**Given** I'm using the app regularly
**When** I log both a meal AND weight on the same day
**Then** my streak counter increments by 1

**And** my current streak is displayed on the dashboard
**And** streak count persists in SQLite
**And** streak does NOT break if I only miss logging (forgiving design - no punishment)
**And** streak resets to 0 only if I don't log for 2+ consecutive days

### Story 4.5: Milestone Celebrations UI

As a user reaching milestones,
I want to see visual celebration when I hit streak milestones,
So that I feel recognized for my consistency.

**Acceptance Criteria:**

**Given** I reach specific streak milestones
**When** the streak counter updates
**Then** I see special UI indicators:
- 7-day streak: Fire character switches to 🔥💪 (strong variant) + badge icon
- 14-day streak: First half-cycle complete badge
- 28-day streak: Triple roar + "First Cycle Complete!" celebration message

**And** milestone celebrations are non-intrusive (dismissible)
**And** past milestones are viewable in a streak history (optional POC feature)

---

## Epic 5: Validate & Learn - Analytics Infrastructure

Development team can track POC validation metrics (activation rate, Week 1 retention, first cycle completion) to validate product-market fit for university thesis.

### Story 5.1: Analytics Event Schema

As a development team,
I want a structured event tracking system,
So that we can capture user behavior for POC validation.

**Implementation Tasks:**
1. GRDB migration for analytics_events table (id, user_id, event_name, metadata_json, created_at, synced_at)
2. Codable event structs for 15 core events
3. AnalyticsManager singleton with logEvent() function

**Acceptance Criteria:**

**Given** the app is running
**When** the analytics system is initialized
**Then** analytics_events table exists in SQLite

**And** the following 15 core event types are defined:
- onboarding_started, onboarding_step_completed, onboarding_finished
- meal_logged (metadata: source [manual/db_search/ocr_scan], meal_type)
- weight_logged
- why_like_this_opened (metadata: topic)
- cycle_phase_switched (metadata: from/to phase)
- session_start, session_end (metadata: duration_seconds)
- screen_view, screen_exit (metadata: screen_name, time_spent_seconds)
- error_logged (metadata: error_type, screen_name)

**And** events are stored locally in SQLite immediately
**And** logEvent() function is available app-wide

### Story 5.2: Event Tracking Integration

As a development team,
I want analytics events tracked throughout all app features,
So that we can measure user engagement and behavior patterns.

**Acceptance Criteria:**

**Given** analytics system is initialized
**When** users interact with app features
**Then** events are logged automatically at key moments:
- App launch: session_start
- Each onboarding step: onboarding_step_completed
- Meal logging: meal_logged with source metadata
- Weight logging: weight_logged
- Education opened: why_like_this_opened
- Phase switch: cycle_phase_switched (midnight transitions)
- Screen navigation: screen_view, screen_exit with time tracking
- Errors: error_logged with context

**And** events include relevant metadata as JSON
**And** events are non-blocking (don't slow down user actions)
**And** failed event logging doesn't crash the app

### Story 5.3: SQLite → Supabase Analytics Pipeline

As a development team,
I want analytics events synced to Supabase,
So that we can query and analyze POC metrics using SQL.

**Acceptance Criteria:**

**Given** analytics events exist in local SQLite
**When** the app has internet connectivity
**Then** unsynced events (synced_at = NULL) are pushed to Supabase analytics_events table in the background

**And** sync reuses existing sync infrastructure from Epic 1/Epic 3
**And** synced events are marked with synced_at timestamp
**And** sync failures retry automatically
**And** events remain in local SQLite even after sync (for offline analysis)

### Story 5.4: POC Metrics Dashboard

As a development team validating the POC,
I want to calculate key validation metrics from analytics data,
So that we can measure product-market fit for the university thesis.

**Acceptance Criteria:**

**Given** analytics events are synced to Supabase
**When** we query the analytics_events table
**Then** we can calculate these POC validation metrics:
- **Activation rate:** % of users who complete onboarding (onboarding_finished / onboarding_started)
- **Week 1 retention:** % of users who log a meal on Day 7 (meal_logged WHERE day=7 / total users)
- **First cycle completion:** % of users who reach Day 28 (session_start WHERE day≥28 / total users)
- **Education engagement:** % of users who open "Why Like This?" (why_like_this_opened / total users)
- **Phase switch continuation:** % of users who continue logging after Day 14 phase switch

**And** metrics can be queried via SQL (no custom dashboard UI needed for POC)
**And** metrics inform business plan validation for university thesis
