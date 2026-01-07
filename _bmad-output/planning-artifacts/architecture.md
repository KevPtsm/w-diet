---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/ux-design-specification.md'
workflowType: 'architecture'
project_name: 'w-diet'
user_name: 'Kevin'
date: '2026-01-02'
lastStep: 8
status: 'complete'
completedAt: '2026-01-04'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**

w-diet is an iOS-native nutrition app implementing automated MATADOR metabolic cycling with empowering fire coach guidance. The core functional requirements center on three pillars:

1. **MATADOR Cycling Automation**
   - 14-day automated phase switching (diet ↔ maintenance)
   - Automatic calorie target adjustments (30% variance: e.g., 1900 kcal diet / 2300 kcal maintenance)
   - Week 1 special: Start at maintenance calories to build habit before introducing deficit stress
   - Calendar-based cycling (midnight transitions, no user decisions required)
   - **Fail-safe state recovery**: On every app launch, validate cycle state against calendar math to handle app crashes, force-quits, timezone changes, or iOS background task termination
   - Local SQLite state management (no server dependency for phase logic)

2. **Core Tracking & Feedback**
   - Manual meal logging (calories required, macros optional with incentive nudge)
   - Real-time dashboard updates (macro smileys, calorie progress bar)
   - Daily weight tracking with 7-day rolling average calculation
   - Trend indicators (green ↓ when weight decreasing, hidden otherwise)
   - Streak tracking (activates on weight OR meal log)
   - Variable reward system (haptic roars: single/double/triple based on achievement)

3. **Educational Transparency**
   - "Why Like This?" markdown content explaining MATADOR research
   - Just-in-time tooltips (Day 1 onboarding, Day 14 phase switch)
   - Research citations (MATADOR study, intermittent fasting papers)
   - Info icons (ℹ️) on all calculated values for transparency

4. **Fire Coach Character**
   - 4 static minimalist variations (default 🔥, glasses 🔥🤓, strong 🔥💪, gentle 🔥😌)
   - Supportive messaging (coach not judge, forgiving thresholds)
   - Roar celebration system (haptic + audio feedback)

**Non-Functional Requirements:**

Critical NFRs that will drive architectural decisions:

1. **Performance (Non-Negotiable)**
   - Dashboard load: <50ms P95 target (must support iPhone 12+, iOS 16+)
   - User actions: <300ms response time
   - Meal logging: <30 sec experienced users, <60 sec new users
   - UI rendering: 60fps (no jank, GPU-accelerated SwiftUI)
   - Zero loading spinners on critical paths (meal log, weight log, dashboard)

2. **Battery Efficiency**
   - Active use: <5% battery drain per hour
   - Idle (app closed): <0.1% drain per hour
   - Critical for traveling consultants (8-12 hour days without charging)
   - Testing on degraded batteries (iPhone 12 with aged battery)

3. **Reliability & Data Integrity**
   - 100% core features functional offline (no internet dependency)
   - Crash-free rate: >99.5%
   - Zero tolerance for data loss (weight logs, meal logs, streak data, cycle state)
   - SQLite ↔ Supabase sync with conflict resolution (cloud timestamp wins)
   - Sync queue retry logic on reconnect

4. **Privacy & Compliance**
   - GDPR compliance (German/EU market)
   - Local-first data storage (SQLite), optional cloud sync
   - User data export (CSV) and account deletion (full purge)
   - BITV 2.0 (German accessibility law) + WCAG 2.1 Level AA
   - App Store nutritional content guidelines (disclaimer: guidance not medical advice)

5. **Usability & Accessibility**
   - One-handed operation (iOS picker wheel for weight input, thumb-zone optimized UI)
   - Forgiving design (70% macro threshold = green smiley, not 100% perfectionism)
   - Safe area handling (notch, Dynamic Island, home indicator)
   - Portrait orientation locked
   - German language support (Phase 1), German VoiceOver (Phase 2)

**Scale & Complexity:**

- **Primary domain**: Mobile-first (iOS native Swift/SwiftUI)
- **Complexity level**: Medium
  - Native mobile architecture with offline-first requirements
  - State machine complexity (MATADOR cycling engine with fail-safe recovery)
  - Sync coordination (SQLite ↔ Supabase background sync)
  - Real-time UI updates from local data changes
  - Performance optimization critical paths
- **Estimated architectural components**: 8-10 major components
  - Authentication & Onboarding
  - Dashboard (cycle timer, calorie progress, macro tracker)
  - Meal Logging
  - Weight Tracking
  - MATADOR Cycling Engine (state machine with recovery protocol)
  - Data Sync Layer (offline queue → Supabase)
  - Analytics Event Tracking
  - Education Content Delivery
  - Fire Character System
  - Settings & Profile

**Component Implementation Phasing (10-Week Timeline):**

- **Weeks 1-2 (Foundation)**: SQLite + GRDB.swift setup, Supabase Auth, MATADOR cycling engine
- **Weeks 3-5 (Core Loop)**: Dashboard UI, Meal Logging, real-time macro smiley updates
- **Weeks 6-7 (Trust Features)**: Weight Tracking, Education modals, Day 14 phase switch UX
- **Weeks 8-9 (Quality & Testing)**: Analytics integration, Crashlytics, TestFlight beta (10 users)
- **Week 10 (Polish & Demo)**: Performance profiling, university demo preparation

### Technical Constraints & Dependencies

**Platform Constraints:**
- iOS 16+ only (iPhone, no iPad optimization in POC)
- Swift + SwiftUI (native performance requirement)
- Portrait orientation locked
- iPhone 12 and newer target devices

**Performance Constraints:**
- <50ms dashboard load drives SQLite schema optimization decisions
- <5% battery/hour drives background sync strategy (no polling, event-driven only)
- 60fps UI drives animation choices (GPU-accelerated, minimal Core Animation)

**Data Architecture Constraints:**
- Offline-first = SQLite primary source of truth
- Supabase secondary (cloud backup + multi-device sync)
- All core features must work without network (no API dependencies on critical paths)
- Sync must be transparent (queue offline, retry on reconnect, no user-facing errors)

**Architectural Decisions Made:**

1. **Data Layer: GRDB.swift (iOS)**
   - Rationale: Raw SQL performance for <50ms dashboard queries, built-in schema migrations, Android symmetry (Room will use similar patterns in Phase 2)
   - Scalability: Supports thousands of records, battle-tested (Wikipedia iOS app)
   - Trade-off: More manual than Core Data, but faster and more predictable

2. **MATADOR State Recovery Protocol**
   - Pattern: On every app launch + midnight local notification, validate stored cycle state against calendar-based calculation
   - Fail-safe: Auto-correct mismatches (handles crashes, force-quits, timezone changes)
   - Analytics: Log recovery events for monitoring state integrity

3. **Thumb-Zone UI Architecture**
   - Layout: Top 40% = glanceable visuals (no interaction), Bottom 60% = thumb-reach interactive zone
   - One-handed operation: Morning routine context (user holding coffee/phone while logging)
   - Component ordering: Prioritize interaction frequency over visual hierarchy

**Timeline Constraint:**
- POC delivery: 10 weeks (university deadline)
- Drives scope discipline (deferred: photo/menu scanning, AI recommendations, social features)

**External Dependencies:**
- Supabase: PostgreSQL backend, Auth, Realtime sync
- GRDB.swift: SQLite wrapper for iOS (performance + migrations)
- Crashlytics/Sentry: Crash monitoring
- TestFlight: Beta distribution (90-day builds, 10K tester limit)

**Known Technical Risks:**
- SQLite ↔ Supabase sync conflict resolution (must handle offline→online transitions gracefully)
- Day 14 phase switch UX (80% continuation target = make-or-break moment)
- Battery optimization on older devices (iPhone 12 with degraded battery)
- Data loss prevention (zero tolerance = comprehensive error handling required)
- MATADOR state machine failure scenarios (crash during midnight transition, timezone changes)

### Cross-Cutting Concerns Identified

**1. Offline-First Data Sync**
- Affects: All features (meal logging, weight tracking, cycle state, analytics events)
- Architectural impact: Dual-layer data architecture (GRDB.swift + Supabase), sync queue management, conflict resolution strategy
- Critical paths: Dashboard load, meal save, weight save must work offline
- Technology: GRDB.swift for iOS, Room for Android (Phase 2)

**2. Performance Optimization**
- Affects: Dashboard rendering, meal logging flow, weight input modal
- Architectural impact: SQLite query optimization (GRDB indexes), SwiftUI view hierarchy, lazy loading
- Measurement: Xcode Instruments profiling in Week 8-9
- Target: <50ms P95 dashboard load on iPhone 12

**3. MATADOR Cycling State Machine**
- Affects: Calorie targets, UI (cycle timer), education tooltips, analytics events
- Architectural impact: Centralized state management, calendar-based triggers, phase transition logic, **fail-safe recovery protocol**
- Critical: Midnight transitions must be reliable (local computation, no server dependency)
- Recovery: On launch, validate stored state vs calculated state, auto-correct mismatches

**4. Analytics Event Tracking**
- Affects: All user interactions (11 core events across onboarding, engagement, education)
- Architectural impact: Single `logEvent()` function, SQLite event queue, background Supabase sync
- Implementation overhead: ~6 hours across 10-week POC

**5. Error Handling & Crash Prevention**
- Affects: All features (zero tolerance for data loss)
- Architectural impact: Comprehensive try-catch, Crashlytics integration, error event logging
- Testing: Week 9 TestFlight beta (10 users, crash/battery validation)

**6. Accessibility Compliance**
- Affects: All UI components (WCAG 2.1 AA + BITV 2.0)
- Architectural impact: Color contrast ratios (4.5:1 minimum), 44×44pt tap targets, VoiceOver labels (Phase 2)
- POC scope: Basic compliance (contrast, tap targets), full VoiceOver in Phase 2

**7. Trust-Building UX Patterns**
- Affects: Onboarding, Day 14 phase switch, education delivery
- Architectural impact: Tooltip state management (UserDefaults), just-in-time education triggers, cycle timer prominence
- Critical moment: Day 14 automated calorie increase (requires transparent UI + accessible education)

**8. Variable Reward System (Hooked Model)**
- Affects: Macro smileys, streak counter, roar celebrations
- Architectural impact: Real-time feedback on meal log, haptic engine integration, achievement tracking
- Engagement driver: Unpredictable macro smiley timing creates dopamine anticipation

**9. Thumb-Zone Interaction Architecture**
- Affects: All screens (dashboard, meal logging, weight input, education)
- Architectural impact: Component positioning prioritizes thumb reach (bottom 60% = interactive, top 40% = glanceable), safe area handling for notch + home indicator, SwiftUI layout strategy
- Design principle: One-handed operation throughout app (morning routine context - user holding coffee/phone charger/toothbrush)
- Dashboard layout:
  - **Top 40%**: Cycle Timer Card, Weight Card (glanceable, read-only)
  - **Bottom 60%**: Calorie Progress Card with macro smileys, Quick Action Buttons, Tab Bar Navigation
- SwiftUI implementation: `.safeAreaInset(edge: .bottom)` for tab bar, `.padding(.top, .safeArea)` for status bar

---

## Starter Template Evaluation

### Primary Technology Domain

**iOS Native Mobile Application** - Swift + SwiftUI with offline-first architecture

### Technical Stack (Established from Project Context)

- **Platform**: iOS 16+ (iPhone only, portrait orientation)
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Local Database**: SQLite via GRDB.swift 7.9.0
- **Backend**: Supabase (Auth, PostgreSQL sync)
- **Crash Monitoring**: Crashlytics/Sentry (TBD)
- **Distribution**: TestFlight

### Starter Options Considered

**1. SwiftUI Indie Stack**
- **URL**: https://github.com/cliffordh/swiftui-indie-stack
- **Status**: Active (created Dec 2025, 6 commits)
- **Technologies**: Firebase/Firestore, RevenueCat, TelemetryDeck, UserDefaults
- **Architecture**: Offline-first with local/cloud mode toggle
- **Evaluation**: Strong offline-first patterns, but incompatible tech stack (Firebase instead of Supabase+GRDB)
- **Verdict**: ❌ Rejected - Would require Week 1 gutting Firebase, rewriting data layer, introducing technical debt

**2. Supabase iOS SwiftUI Quickstart**
- **URL**: https://supabase.com/docs/guides/getting-started/quickstarts/ios-swiftui
- **Type**: Integration guide only (not complete template)
- **Technologies**: Supabase Swift client
- **Evaluation**: Provides Supabase setup steps but no project structure or offline-first architecture
- **Verdict**: ❌ Not a starter template - integration guide only

**3. GRDB.swift Examples**
- **URL**: https://github.com/groue/GRDB.swift
- **Type**: Library with sample code
- **Evaluation**: Excellent GRDB patterns but no Supabase integration or complete app structure
- **Verdict**: ❌ Library examples only, not a full starter

### Selected Approach: Custom Xcode Project with Borrowed Patterns

**Rationale for Custom Setup:**

1. **No template matches our unique stack** - GRDB + Supabase is an uncommon pairing (most use one OR the other)
2. **Custom sync engine required** - SQLite ↔ Supabase dual-layer architecture with offline queue, conflict resolution, and MATADOR fail-safe recovery is unique to our use case
3. **Avoid template bloat** - Existing templates include technologies we'd need to remove (Firebase, RevenueCat, Core Data), costing more time than building from scratch
4. **Clean slate for UX implementation** - Our thumb-zone architecture (60/40 split), cycle timer prominence, and iOS picker wheel patterns don't exist in any template
5. **Faster Week 1 execution** - Custom project setup (3-4 days) faster than fork-and-gut approach (5+ days + technical debt)

**Architectural Patterns Borrowed from SwiftUI Indie Stack:**

While not using their template, we adopt these proven patterns:

1. **Service Abstraction Pattern**
   ```swift
   protocol DataService {
       func save(_ item: MealLog) async throws
       func fetch() async throws -> [MealLog]
   }

   class GRDBDataService: DataService { /* Local SQLite - always active */ }
   class SupabaseSyncService: DataService { /* Cloud sync - optional */ }
   ```

2. **Offline-First State Machine**
   - Local GRDB state is **always authoritative**
   - Supabase sync is enhancement, not dependency
   - Toggle sync mode via `AppConfiguration.enableSync` flag

3. **Feature-Based Folder Structure**
   ```
   Features/
   ├── Dashboard/
   ├── MealLogging/
   ├── WeightTracking/
   └── Onboarding/
   Core/
   ├── Database/    # GRDB layer
   ├── Sync/        # Supabase sync engine
   └── MATADOR/     # Cycling state machine
   ```

### Project Initialization Approach

**Step 1: Create New Xcode Project**

Via Xcode GUI:
1. File → New → Project → iOS → App
2. Configuration:
   - Product Name: `w-diet`
   - Team: (Your Apple Developer account)
   - Organization Identifier: `com.w-diet` (or your domain)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployment: **iOS 16.0**
   - Storage: None (we'll add GRDB manually)

**Step 2: Add Swift Package Dependencies**

In Xcode: File → Add Package Dependencies

1. **GRDB.swift**
   - URL: `https://github.com/groue/GRDB.swift`
   - Version: `7.9.0` (or "Up to Next Major Version" from 7.9.0)

2. **Supabase Swift**
   - URL: `https://github.com/supabase-community/supabase-swift`
   - Version: "Up to Next Major Version" (latest)

3. **Sentry Swift** (Crash Monitoring - optional, can add later)
   - URL: `https://github.com/getsentry/sentry-cocoa`
   - Version: Latest

**Step 3: Initial Project Structure**

Create this folder structure in Xcode:

```
w-diet/
├── App/
│   ├── w_dietApp.swift              # @main entry point
│   ├── AppConfiguration.swift       # Environment config, feature flags
│   └── AppDelegate.swift            # (if needed for push notifications)
│
├── Core/
│   ├── Database/
│   │   ├── GRDBManager.swift        # Database setup, migrations
│   │   ├── Models/
│   │   │   ├── User.swift           # Codable + GRDB record
│   │   │   ├── MealLog.swift
│   │   │   ├── WeightLog.swift
│   │   │   ├── CycleState.swift
│   │   │   └── AnalyticsEvent.swift
│   │   └── Migrations/
│   │       └── V1_Initial.swift     # GRDB migration
│   │
│   ├── Sync/
│   │   ├── SupabaseClient.swift     # Singleton wrapper
│   │   ├── SyncEngine.swift         # Offline queue → Supabase sync
│   │   └── ConflictResolver.swift   # Cloud timestamp wins
│   │
│   └── MATADOR/
│       ├── CycleEngine.swift        # State machine
│       └── RecoveryProtocol.swift   # Launch validation
│
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── DashboardViewModel.swift
│   │   ├── Components/
│   │   │   ├── CycleTimerCard.swift
│   │   │   ├── WeightCard.swift
│   │   │   ├── CalorieProgressCard.swift
│   │   │   └── MacroTrackerCard.swift
│   │
│   ├── MealLogging/
│   │   ├── MealLoggingView.swift
│   │   ├── MealLoggingViewModel.swift
│   │   └── Components/
│   │       └── QuickActionButtons.swift
│   │
│   ├── WeightTracking/
│   │   ├── WeightInputView.swift
│   │   ├── WeightInputViewModel.swift
│   │   └── Components/
│   │       └── WeightPickerWheel.swift
│   │
│   ├── Onboarding/
│   │   ├── OnboardingFlow.swift
│   │   └── Steps/
│   │       ├── GenderSelectionView.swift
│   │       ├── AgeInputView.swift
│   │       └── (8 onboarding steps)
│   │
│   └── Education/
│       └── WhyLikeThisView.swift
│
├── Shared/
│   ├── UI/
│   │   ├── Components/
│   │   │   ├── FireCharacter.swift
│   │   │   ├── MacroSmiley.swift
│   │   │   └── ProgressBar.swift
│   │   └── Styles/
│   │       └── AppTheme.swift
│   │
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   └── Color+Extensions.swift
│   │
│   └── Utilities/
│       ├── HapticManager.swift
│       └── AudioPlayer.swift
│
└── Resources/
    ├── Assets.xcassets
    │   ├── AppIcon
    │   ├── Colors/
    │   │   ├── FireGold
    │   │   ├── MacroGreen
    │   │   ├── MacroOrange
    │   │   └── MacroRed
    │   └── FireCharacters/
    │       ├── fire-default.svg
    │       ├── fire-glasses.svg
    │       ├── fire-strong.svg
    │       └── fire-gentle.svg
    │
    └── Sounds/
        ├── roar-single.mp3
        ├── roar-double.mp3
        └── roar-triple.mp3
```

### Architectural Decisions Made by Custom Approach

**Language & Runtime:**
- Swift 5.9+ (Xcode default for iOS 17+ development)
- iOS 16.0 minimum deployment target (supports iPhone 12+)
- SwiftUI app lifecycle (no UIKit AppDelegate unless needed for push notifications)
- Swift Concurrency (async/await) for all async operations

**Data Layer Architecture:**
- **GRDB.swift** for local SQLite (primary source of truth)
  - Custom migrations for schema evolution
  - Codable conformance for type-safe models
  - Query optimization with indexes for <50ms dashboard load
- **Supabase Swift client** for backend sync (secondary, optional)
  - Auth: Apple Sign-In, Google Sign-In, Email/Password
  - PostgreSQL sync with conflict resolution
  - Realtime subscriptions (deferred to Phase 2)
- **Custom SyncEngine** bridging GRDB ↔ Supabase
  - Offline queue pattern (SQLite sync flag: synced = 0/1)
  - Background sync on network reconnect
  - Conflict resolution: cloud timestamp wins

**Build Tooling:**
- Xcode build system (standard for iOS)
- Swift Package Manager (SPM) for dependencies
- No additional build tools needed (pure Swift/SwiftUI)
- Performance profiling via Xcode Instruments (Week 8-9)

**Testing Framework:**
- XCTest (Xcode default)
- Unit tests for:
  - MATADOR state machine (phase transitions, recovery protocol)
  - GRDB migrations (schema evolution, data integrity)
  - Sync engine (conflict resolution, offline queue)
  - Calculation logic (TDEE, macro targets, rolling averages)
- UI tests deferred to Phase 2 (POC focuses on unit tests for critical logic)

**Code Organization Philosophy:**
- **Feature-based modules** (Dashboard, MealLogging, WeightTracking) for UI/ViewModels
- **Core layer** for cross-cutting concerns (Database, Sync, MATADOR)
- **Shared** for reusable UI components and utilities
- **Protocol-driven architecture** for testability and abstraction
- **MVVM pattern** with ViewModels managing business logic

**Development Experience:**
- Xcode SwiftUI preview canvas for rapid UI iteration
- Hot reloading via Xcode (SwiftUI live previews)
- GRDB database inspection via SQLite browser tools
- Supabase dashboard for backend data validation
- TestFlight for beta distribution (Week 9 onward)

**Week 1-2 Foundation Implementation Tasks:**

1. **Day 1: Project Setup**
   - Create Xcode project
   - Add SPM dependencies (GRDB, Supabase)
   - Configure AppConfiguration.swift with environment variables

2. **Day 2-3: GRDB Layer**
   - GRDBManager singleton setup
   - Initial schema migration (User, MealLog, WeightLog, CycleState, AnalyticsEvent tables)
   - Codable models with GRDB record conformance
   - Basic CRUD operations

3. **Day 4: Supabase Integration**
   - SupabaseClient singleton wrapper
   - Auth setup (Apple Sign-In, Email/Password)
   - Test connection to Supabase project

4. **Day 5: MATADOR Engine Foundation**
   - CycleEngine state machine (phase calculation logic)
   - Recovery protocol (launch validation against calendar math)
   - Unit tests for phase transitions and fail-safe recovery

5. **Week 2: Sync Engine + Onboarding**
   - SyncEngine offline queue implementation
   - Background sync trigger on network reconnect
   - Basic onboarding flow (5 steps: Auth → Goal → Calorie → Eating Window → Dashboard)

**Note:** This custom setup approach becomes the **first epic** in the implementation phase. All architectural decisions documented here guide Week 1-2 foundation work.

### Sources & References

- [Use Supabase with iOS and SwiftUI | Supabase Docs](https://supabase.com/docs/guides/getting-started/quickstarts/ios-swiftui)
- [SwiftUI Indie Stack - GitHub](https://github.com/cliffordh/swiftui-indie-stack) (patterns borrowed, not template used)
- [GRDB.swift - GitHub](https://github.com/groue/GRDB.swift)
- [The Ultimate Guide to Modern iOS Architecture in 2025 | Medium](https://medium.com/@csmax/the-ultimate-guide-to-modern-ios-architecture-in-2025-9f0d5fdc892f)
- [Designing Offline-First iOS Architecture with Swift Concurrency | Medium](https://medium.com/@er.rajatlakhina/designing-offline-first-architecture-with-swift-concurrency-and-core-data-sync-46ad5008c7b5)

---

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
1. ✅ State Management → SwiftUI Native + Custom Managers
2. ✅ Error Handling → Custom Error Wrapper + Analytics
3. ✅ Environment Configuration → Xcode Schemes + .xcconfig + Keychain
4. ✅ Logging & Monitoring → Sentry + Custom Analytics to Supabase
5. ✅ Database Schema → GRDB DatabaseMigrator

**Important Decisions (Shape Architecture):**
6. ✅ Navigation Pattern → NavigationStack (iOS 16+)
7. ✅ Dependency Injection → Hybrid (Environment + Constructor)
8. ✅ Analytics Event Structure → Codable Event Structs
9. ✅ Asset Management → Xcode Asset Catalog Only
10. ✅ Localization → German-only for POC (JSON-based), English in Phase 2

**Deferred Decisions (Post-POC):**
- Performance monitoring tools → Phase 2 (Xcode Instruments sufficient for POC)
- A/B testing infrastructure → Phase 3 (after core validation)
- Feature flags system → Phase 2 (if needed for gradual rollout)

---

### 1. State Management Architecture

**Decision:** SwiftUI Native + Custom Singleton Managers

**Implementation Pattern:**
- **ViewModels**: `@StateObject` for feature-specific state (DashboardViewModel, MealLoggingViewModel)
- **Shared Services**: `@EnvironmentObject` for app-wide singletons (GRDBManager, CycleEngine, SupabaseClient)
- **View State**: `@State` for local UI state (button pressed, sheet visibility)
- **Derived State**: `@Published` properties in ViewModels

**Rationale:**
- MATADOR CycleEngine is a singleton state machine → EnvironmentObject
- GRDB and Supabase clients are singletons → EnvironmentObject
- Feature ViewModels manage their own state → StateObject
- Balances simplicity (no external frameworks) with structure

**Example:**
```swift
// App-level injection
@main
struct w_dietApp: App {
    @StateObject private var dbManager = GRDBManager.shared
    @StateObject private var cycleEngine = CycleEngine.shared
    @StateObject private var supabaseClient = SupabaseClient.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dbManager)
                .environmentObject(cycleEngine)
                .environmentObject(supabaseClient)
                .environmentObject(localizationManager)
        }
    }
}

// ViewModel usage with default parameters
class DashboardViewModel: ObservableObject {
    @Published var mealLogs: [MealLog] = []
    @Published var currentPhase: CyclePhase
    
    private let dbManager: GRDBManager
    private let cycleEngine: CycleEngine
    
    // Default parameters for production, overridable for tests
    init(dbManager: GRDBManager = .shared, cycleEngine: CycleEngine = .shared) {
        self.dbManager = dbManager
        self.cycleEngine = cycleEngine
        self.currentPhase = cycleEngine.currentPhase
    }
}

// View usage
struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()  // Uses singletons
    
    var body: some View {
        // UI
    }
}
```

**Affects:** All features, Core layer services

---

### 2. Error Handling Standards

**Decision:** Custom Error Wrapper + Analytics Integration

**Implementation Pattern:**

Domain-specific error types with analytics logging:

```swift
// Core error types
enum AppError: Error {
    case database(DatabaseError)
    case sync(SyncError)
    case network(NetworkError)
    case matador(CycleError)
    case validation(ValidationError)
}

enum DatabaseError: Error, Loggable {
    case migrationFailed(String)
    case queryFailed(String)
    case saveFailed(String)
    case connectionFailed
}

enum SyncError: Error, Loggable {
    case offlineQueueFull
    case conflictResolutionFailed
    case authenticationRequired
}

// Error logging protocol
protocol Loggable {
    var eventName: String { get }
    var metadata: [String: Any] { get }
}

// Error reporting (both analytics + Sentry)
extension AppError {
    func report() {
        // 1. Log to custom analytics (SQLite → Supabase)
        AnalyticsManager.shared.logEvent(
            "error_occurred",
            metadata: [
                "error_type": eventName,
                "error_details": metadata
            ]
        )
        
        // 2. Report to Sentry for crash tracking
        SentrySDK.capture(error: self)
    }
}

// Usage in catch blocks
do {
    try await dbManager.save(mealLog)
} catch let error as AppError {
    error.report()  // Both analytics + Sentry
    showErrorAlert(message: error.userFacingMessage)
}
```

**Error Handling at Boundaries:**
- **Data Layer**: Throw domain errors (DatabaseError, SyncError)
- **ViewModel Layer**: Catch and convert to user-facing messages
- **UI Layer**: Display user-friendly alerts, errors automatically logged

**Rationale:**
- Type-safe error handling with compile-time checking
- All errors automatically logged to analytics (supports >99.5% crash-free target)
- Sentry captures for crash analysis
- Domain errors aid debugging (DatabaseError.migrationFailed vs generic errors)

**Implementation Timeline:** Week 2-3 (deferred from Week 1 per John's feedback)

**Affects:** All layers (Database, Sync, ViewModels, UI)

---

### 3. Environment Configuration Strategy

**Decision:** Xcode Schemes + .xcconfig Files + Keychain for Secrets

**Implementation Pattern:**

**Build Configurations:**
- Dev (local development, test Supabase project)
- Staging (pre-production, staging Supabase project)
- Prod (production, live Supabase project)

**Configuration Files (.xcconfig):**

```xcconfig
// Dev.xcconfig
SUPABASE_URL = https://dev-w-diet.supabase.co
SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... // Dev key
APP_ENVIRONMENT = development
ENABLE_SYNC = true

// Prod.xcconfig  
SUPABASE_URL = https://prod-w-diet.supabase.co
SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... // Prod key
APP_ENVIRONMENT = production
ENABLE_SYNC = true
```

**AppConfiguration.swift:**
```swift
struct AppConfiguration {
    static let supabaseURL = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
    static let supabaseAnonKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
    static let environment = Bundle.main.infoDictionary?["APP_ENVIRONMENT"] as? String ?? "development"
    static let enableSync = Bundle.main.infoDictionary?["ENABLE_SYNC"] as? Bool ?? false
}
```

**Git Strategy:**
- `.xcconfig` files are git-ignored (contain secrets)
- `Config.xcconfig.template` checked into git (example structure)
- Developer copies template to Dev.xcconfig and adds actual keys

**Rationale:**
- Industry standard for iOS configuration management
- Supabase project URLs + anon keys need environment-specific values
- TestFlight distribution requires clean prod/staging separation
- Secure (secrets never committed to git)

**Affects:** App initialization, Supabase client setup, GRDB database paths

---

### 4. Logging & Monitoring Approach

**Decision:** Sentry for Crashes + Custom Analytics to Supabase

**Implementation Pattern:**

**Crash Monitoring (Sentry):**
- Sentry SDK integration for crash reporting
- Automatic crash capture + symbolication
- Performance monitoring (API call duration, database query times)
- Free tier: 5K events/month (sufficient for POC)

**Analytics Events (Custom to Supabase):**
- 11 core events stored in SQLite `analytics_events` table
- Background sync to Supabase PostgreSQL
- SQL-queryable for POC validation metrics

**Debug Logging (OSLog):**
- Development-only logging via Apple's unified logging
- Subsystems: Database, Sync, MATADOR, UI
- Xcode Console integration

**Architecture:**
```swift
// Sentry initialization
import Sentry

@main
struct w_dietApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://...@sentry.io/..."
            options.tracesSampleRate = 1.0 // 100% in dev, 10% in prod
            options.environment = AppConfiguration.environment
        }
    }
}

// Error reporting pattern
extension AppError {
    func report() {
        // 1. Log to custom analytics (SQLite → Supabase)
        AnalyticsManager.shared.logEvent(
            "error_occurred",
            metadata: ["error_type": eventName, "details": metadata]
        )
        
        // 2. Report to Sentry for crash tracking
        SentrySDK.capture(error: self)
    }
}

// Analytics to Supabase
class AnalyticsManager {
    func logEvent<T: AnalyticsEvent>(_ event: T) async {
        // Save to SQLite
        try? await dbManager.save(event)
        
        // Background sync will push to Supabase
        // (uses existing sync engine)
    }
}
```

**Rationale:**
- Reuses existing SQLite → Supabase sync infrastructure for analytics
- Own analytics data = no vendor lock-in, unlimited events, SQL queries
- Sentry free tier sufficient for POC crash monitoring (>99.5% crash-free target)
- OSLog for development debugging (free, privacy-respecting)

**Affects:** App initialization, Error handling, Analytics event tracking

---

### 5. Database Schema Versioning/Migration Strategy

**Decision:** GRDB DatabaseMigrator (Official Pattern)

**Implementation Pattern:**

```swift
import GRDB

class GRDBManager {
    static let shared = GRDBManager()
    private var dbQueue: DatabaseQueue!
    
    func setupDatabase() throws {
        let databaseURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("w-diet.sqlite")
        
        dbQueue = try DatabaseQueue(path: databaseURL.path)
        
        var migrator = DatabaseMigrator()
        
        // V1: Initial schema
        migrator.registerMigration("v1_initial") { db in
            try db.create(table: "user") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("email", .text).notNull().unique()
                t.column("gender", .text).notNull()
                t.column("age", .integer).notNull()
                t.column("height_cm", .integer).notNull()
                t.column("activity_level", .text).notNull()
                t.column("goal", .text).notNull()
                t.column("created_at", .datetime).notNull()
            }
            
            try db.create(table: "meal_logs") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .integer).notNull().references("user")
                t.column("meal_name", .text).notNull()
                t.column("calories", .integer).notNull()
                t.column("protein_g", .integer)
                t.column("carbs_g", .integer)
                t.column("fats_g", .integer)
                t.column("fiber_g", .integer)
                t.column("logged_at", .datetime).notNull()
                t.column("synced", .boolean).notNull().defaults(to: false)
            }
            
            try db.create(table: "weight_logs") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .integer).notNull().references("user")
                t.column("weight_kg", .double).notNull()
                t.column("logged_at", .datetime).notNull()
                t.column("synced", .boolean).notNull().defaults(to: false)
            }
            
            try db.create(table: "cycle_state") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .integer).notNull().references("user")
                t.column("cycle_start_date", .datetime).notNull()
                t.column("current_phase", .text).notNull()
                t.column("current_day", .integer).notNull()
                t.column("synced", .boolean).notNull().defaults(to: false)
            }
            
            try db.create(table: "analytics_events") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("event_type", .text).notNull()
                t.column("event_data", .blob).notNull() // JSON
                t.column("timestamp", .datetime).notNull()
                t.column("synced", .boolean).notNull().defaults(to: false)
            }
            
            // Indexes for performance (<50ms dashboard load target)
            try db.create(index: "idx_meal_logs_user_date", on: "meal_logs", columns: ["user_id", "logged_at"])
            try db.create(index: "idx_weight_logs_user_date", on: "weight_logs", columns: ["user_id", "logged_at"])
        }
        
        // Future migrations (Phase 2+)
        // migrator.registerMigration("v2_add_streak_tracking") { db in ... }
        // migrator.registerMigration("v3_add_education_progress") { db in ... }
        
        try migrator.migrate(dbQueue)
    }
}
```

**Migration Tracking:**
- GRDB automatically tracks applied migrations in `grdb_migrations` table
- Safe to run migrations multiple times (idempotent)
- Rollback not supported by default (forward-only migrations)

**Rationale:**
- GRDB's recommended pattern (official documentation)
- Automatic tracking prevents duplicate migrations
- Safe, battle-tested approach
- Incremental schema evolution for Phase 2+ features

**Affects:** Database layer, All data models, Sync engine

---

### 6. Navigation Pattern

**Decision:** SwiftUI NavigationStack (iOS 16+)

**Implementation Pattern:**

```swift
// Root TabView with NavigationStack per tab
struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            NavigationStack {
                MealLoggingView()
            }
            .tabItem {
                Label("Log", systemImage: "plus.circle.fill")
            }
            
            NavigationStack {
                WeightTrackingView()
            }
            .tabItem {
                Label("Weight", systemImage: "scalemass.fill")
            }
            
            NavigationStack {
                EducationView()
            }
            .tabItem {
                Label("Learn", systemImage: "book.fill")
            }
        }
    }
}

// Programmatic navigation (if needed)
@State private var path = NavigationPath()

NavigationStack(path: $path) {
    DashboardView()
        .navigationDestination(for: MealLog.self) { mealLog in
            MealDetailView(mealLog: mealLog)
        }
}
```

**Rationale:**
- iOS 16+ is minimum deployment target (requirement)
- NavigationStack is modern, type-safe API
- Tab bar navigation specified in UX spec (4 tabs: 🏠📊⚖️🎓)
- Supports deep linking and programmatic navigation

**Affects:** All feature views, Tab bar structure

---

### 7. Dependency Injection Pattern

**Decision:** Hybrid (EnvironmentObject for Singletons + Default Parameters for Testability)

**Implementation Pattern:**

**Singletons via EnvironmentObject:**
```swift
// App-level injection
@main
struct w_dietApp: App {
    @StateObject private var dbManager = GRDBManager.shared
    @StateObject private var cycleEngine = CycleEngine.shared
    @StateObject private var supabaseClient = SupabaseClient.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dbManager)
                .environmentObject(cycleEngine)
                .environmentObject(supabaseClient)
                .environmentObject(localizationManager)
        }
    }
}
```

**ViewModels with Default Parameters (Testability):**
```swift
class DashboardViewModel: ObservableObject {
    @Published var mealLogs: [MealLog] = []
    
    private let dbManager: GRDBManager
    private let cycleEngine: CycleEngine
    
    // Default to singletons, allow injection for tests
    init(dbManager: GRDBManager = .shared, cycleEngine: CycleEngine = .shared) {
        self.dbManager = dbManager
        self.cycleEngine = cycleEngine
    }
}

// Production usage
struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()  // Uses singletons by default
    
    var body: some View {
        // UI
    }
}

// Test usage
func testDashboardViewModel() {
    let mockDB = MockGRDBManager()
    let mockCycle = MockCycleEngine()
    let viewModel = DashboardViewModel(dbManager: mockDB, cycleEngine: mockCycle)
    // Test...
}
```

**Time-Mockable Testing Pattern for MATADOR:**
```swift
// Protocol for time injection
protocol TimeProvider {
    var now: Date { get }
}

class SystemTimeProvider: TimeProvider {
    var now: Date { Date() }
}

// CycleEngine with time injection
class CycleEngine: ObservableObject {
    @Published var currentPhase: CyclePhase = .diet
    
    private let timeProvider: TimeProvider
    
    init(timeProvider: TimeProvider = SystemTimeProvider()) {
        self.timeProvider = timeProvider
    }
    
    func calculatePhase(cycleStartDate: Date) -> CyclePhase {
        let now = timeProvider.now  // Mockable for tests
        let daysSinceStart = Calendar.current.dateComponents([.day], from: cycleStartDate, to: now).day ?? 0
        let dayInCycle = (daysSinceStart % 28) + 1
        
        return dayInCycle <= 14 ? .diet : .maintenance
    }
    
    func validateCycleState() {
        // Fail-safe recovery protocol
        let storedState = /* load from GRDB */
        let calculatedState = calculatePhase(cycleStartDate: storedState.cycleStartDate)
        
        if storedState.currentPhase != calculatedState {
            // State mismatch - recover
            currentPhase = calculatedState
            AnalyticsManager.shared.logEvent(CycleStateRecoveredEvent(
                storedPhase: storedState.currentPhase,
                calculatedPhase: calculatedState
            ))
        }
    }
}

// Test midnight phase transitions
class MockTimeProvider: TimeProvider {
    var now = Date()
}

func testPhaseSwitchAtMidnight() {
    let mockTime = MockTimeProvider()
    let cycleStartDate = Calendar.current.date(byAdding: .day, value: -13, to: Date())!
    
    // Day 14 at 23:59:59
    mockTime.now = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Calendar.current.date(byAdding: .day, value: 13, to: cycleStartDate)!)!
    let engine = CycleEngine(timeProvider: mockTime)
    XCTAssertEqual(engine.calculatePhase(cycleStartDate: cycleStartDate), .diet)
    
    // Day 15 at 00:00:00 (phase switch)
    mockTime.now = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 14, to: cycleStartDate)!)!
    XCTAssertEqual(engine.calculatePhase(cycleStartDate: cycleStartDate), .maintenance)
}
```

**Rationale:**
- Core services (Database, Sync, MATADOR) are true singletons → EnvironmentObject for convenience
- Feature ViewModels use default parameters → testable with mocks
- Time-based logic testable via TimeProvider protocol
- Balance of SwiftUI-native patterns and testability

**Affects:** All ViewModels, Testing strategy, MATADOR engine

---

### 8. Analytics Event Structure

**Decision:** Codable Event Structs (Type-Safe)

**Implementation Pattern:**

```swift
// Base protocol
protocol AnalyticsEvent: Codable {
    var eventType: String { get }
    var timestamp: Date { get }
}

// Concrete events
struct MealLoggedEvent: AnalyticsEvent {
    let eventType = "meal_logged"
    let timestamp: Date
    let calories: Int
    let protein: Int?
    let carbs: Int?
    let fats: Int?
    let source: String // "manual" | "photo_scan" (Phase 2)
}

struct WeightLoggedEvent: AnalyticsEvent {
    let eventType = "weight_logged"
    let timestamp: Date
    let weight_kg: Double
}

struct OnboardingStepCompletedEvent: AnalyticsEvent {
    let eventType = "onboarding_step_completed"
    let timestamp: Date
    let step_number: Int
    let step_name: String
}

struct CyclePhaseSwitchedEvent: AnalyticsEvent {
    let eventType = "cycle_phase_switched"
    let timestamp: Date
    let from_phase: String
    let to_phase: String
    let day_number: Int
}

// Storage in SQLite
struct AnalyticsEventRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "analytics_events"
    
    let id: Int64?
    let eventType: String
    let eventData: Data // JSON-encoded event
    let timestamp: Date
    let synced: Bool
}

// Usage
func logMealLogged(calories: Int, protein: Int?, source: String) async {
    let event = MealLoggedEvent(
        timestamp: Date(),
        calories: calories,
        protein: protein,
        carbs: nil,
        fats: nil,
        source: source
    )
    
    await AnalyticsManager.shared.log(event)
}
```

**Rationale:**
- Type-safe: Can't log wrong metadata (compile-time checking)
- Supabase PostgreSQL benefits from structured JSON columns
- Easy to query: `SELECT * FROM analytics_events WHERE event_type = 'meal_logged' AND (event_data->>'calories')::int > 500`
- Codable makes SQLite storage and Supabase sync seamless

**Affects:** Analytics event tracking, Supabase sync, POC validation queries

---

### 9. Asset Management Strategy

**Decision:** Xcode Asset Catalog Only

**Implementation Pattern:**

**Assets.xcassets Structure:**
```
Assets.xcassets/
├── AppIcon.appiconset/
├── Colors/
│   ├── FireGold.colorset/
│   ├── MacroGreen.colorset/
│   ├── MacroOrange.colorset/
│   ├── MacroRed.colorset/
│   └── BackgroundGray.colorset/
├── FireCharacters/
│   ├── fire-default.imageset/  (PDF vector)
│   ├── fire-glasses.imageset/  (PDF vector)
│   ├── fire-strong.imageset/   (PDF vector)
│   └── fire-gentle.imageset/   (PDF vector)
```

**Sounds (Resources/Sounds/):**
```
Resources/
└── Sounds/
    ├── roar-single.mp3
    ├── roar-double.mp3
    └── roar-triple.mp3
```

**SwiftUI Usage:**
```swift
// Colors
Color("FireGold")
Color("MacroGreen")

// Images
Image("fire-default")
    .resizable()
    .scaledToFit()

// Sounds
class AudioPlayer {
    func playRoar(type: RoarType) {
        guard let url = Bundle.main.url(forResource: type.filename, withExtension: "mp3") else { return }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
```

**Rationale:**
- SwiftUI has excellent Asset Catalog integration
- Fire SVGs exported as PDF vectors (Xcode standard for vector assets)
- No build complexity, no extra dependencies
- Phase 2 can add SwiftGen if type-safety becomes critical

**Affects:** UI components, Fire character system, Audio feedback

---

### 10. Localization Strategy

**Decision:** German-only for POC (JSON-based), English in Phase 2

**Implementation Pattern:**

**JSON-Based LocalizationManager (Scalable):**

```swift
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language = .german
    private var strings: [Language: [String: String]] = [:]
    
    enum Language: String, CaseIterable {
        case german = "de"
        case english = "en"
        
        var displayName: String {
            switch self {
            case .german: return "Deutsch"
            case .english: return "English"
            }
        }
        
        var flag: String {
            switch self {
            case .german: return "🇩🇪"
            case .english: return "🇬🇧"
            }
        }
    }
    
    init() {
        // Load language files at startup
        loadStrings(for: .german)
        // English will be added in Phase 2
        
        // Restore user preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }
    
    private func loadStrings(for language: Language) {
        guard let url = Bundle.main.url(
            forResource: language.rawValue,
            withExtension: "json",
            subdirectory: "Localizations"
        ),
        let data = try? Data(contentsOf: url),
        let json = try? JSONDecoder().decode([String: String].self, from: data) else {
            print("Failed to load \(language.rawValue) strings")
            return
        }
        strings[language] = json
    }
    
    func string(for key: String) -> String {
        strings[currentLanguage]?[key] ?? key
    }
    
    func toggleLanguage() {
        currentLanguage = currentLanguage == .german ? .english : .german
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
    }
}

// SwiftUI Helper
extension View {
    func localized(_ key: String) -> some View {
        Text(LocalizationManager.shared.string(for: key))
    }
}

// Usage
Text(LocalizationManager.shared.string(for: "dashboard.calories"))
// or
view.localized("dashboard.calories")
```

**Resources/Localizations/de.json:**
```json
{
  "dashboard.title": "Dashboard",
  "dashboard.calories": "Kalorien",
  "dashboard.protein": "Protein",
  "dashboard.carbs": "Kohlenhydrate",
  "dashboard.fats": "Fette",
  "dashboard.fiber": "Ballaststoffe",
  
  "onboarding.welcome": "Willkommen bei w-diet",
  "onboarding.gender": "Geschlecht auswählen",
  "onboarding.gender.male": "Männlich",
  "onboarding.gender.female": "Weiblich",
  "onboarding.gender.other": "Divers",
  
  "button.save": "Speichern",
  "button.cancel": "Abbrechen",
  "button.continue": "Weiter",
  "button.log_meal": "Mahlzeit eintragen",
  "button.log_weight": "Gewicht eintragen",
  
  "meal_logging.title": "Mahlzeit eintragen",
  "meal_logging.meal_name": "Mahlzeit",
  "meal_logging.calories": "Kalorien (kcal)",
  
  "weight_tracking.title": "Gewicht eintragen",
  "weight_tracking.current_weight": "Aktuelles Gewicht"
}
```

**POC UX Decision:**
- **No language toggle in POC** (German-only, no UI suggesting other languages)
- Phase 2: Add language toggle when English strings are ready
- Avoids disabled/confusing UI elements

**Rationale:**
- JSON files scale better than hardcoded strings (Barry's feedback)
- German-first for POC authenticity with German student testers
- Manual entry (no food database) = no language conflict
- Phase 3 food database (OpenFoodFacts) has multilingual support
- Runtime switching architecture ready for Phase 2 English addition

**Affects:** All UI text, Onboarding flow, Education content

---

### Decision Impact Analysis

**Implementation Sequence (Week 1-10 POC) - Updated:**

1. **Week 1: Foundation**
   - Xcode project setup + .xcconfig files
   - GRDB + V1 migration (schema with indexes)
   - Supabase client connection test
   - StateObject pattern for ViewModels
   - Basic EnvironmentObject injection

2. **Week 2: Core Services**
   - MATADOR CycleEngine (with TimeProvider for testing)
   - Dependency Injection (default parameters pattern)
   - **Custom Error Wrapper** (moved from Week 1 per John's feedback)
   - Sentry integration
   - LocalizationManager setup (German JSON)

3. **Weeks 3-5: Features**
   - Navigation (TabView + NavigationStack)
   - Dashboard + MealLogging ViewModels
   - Analytics events (Codable structs)
   - Error reporting (both analytics + Sentry)
   - Asset Catalog (fire characters, colors, sounds)

4. **Weeks 6-7: Trust Features**
   - Weight Tracking
   - German localization strings (complete JSON)
   - Education content ("Why Like This?")

5. **Weeks 8-9: Quality**
   - Time-based MATADOR tests (midnight transitions)
   - Analytics validation queries
   - Performance profiling (Xcode Instruments)
   - Error logging review

6. **Week 10: Polish**
   - TestFlight preparation
   - Final POC demo

**Cross-Component Dependencies:**

- **State Management** → affects all ViewModels, Core services
- **Error Handling** → integrates with Analytics + Sentry, affects all data operations
- **Environment Configuration** → affects Supabase client, GRDB paths
- **GRDB Migrator** → foundation for all data operations
- **Dependency Injection** → affects ViewModel initialization, testing (TimeProvider pattern)
- **Analytics Event Structs** → requires Codable support in GRDB schema
- **Navigation** → affects all feature views, tab bar structure
- **Localization** → affects all UI text (JSON loading at app startup)
- **Asset Management** → affects UI components (fire characters, colors), audio system
- **Logging** → Error handling reports to both analytics + Sentry

---

## Phase 2 Feature Roadmap

### Gamification System: Badge & Points with Decay

**Feature Overview:**
- Duolingo-style badge system with tiered achievements (Bronze, Silver, Gold, Platinum)
- Point-based progression with time decay mechanics
- Encourages consistent engagement and adherence to MATADOR protocol

**Badge Categories:**

1. **Streak Badges**
   - Bronze: 7-day logging streak
   - Silver: 30-day logging streak
   - Gold: 90-day logging streak
   - Platinum: 365-day logging streak

2. **Adherence Badges**
   - Bronze: Complete 1 MATADOR cycle within macro targets (70% threshold)
   - Silver: Complete 5 cycles within targets
   - Gold: Complete 10 cycles within targets
   - Platinum: Complete 25 cycles within targets

3. **Milestone Badges**
   - Bronze: Log 50 meals
   - Silver: Log 200 meals
   - Gold: Log 500 meals
   - Platinum: Log 1,000 meals

4. **Weight Progress Badges**
   - Bronze: Achieve 2% body weight change (gain or loss depending on goal)
   - Silver: Achieve 5% body weight change
   - Gold: Achieve 10% body weight change
   - Platinum: Maintain goal weight for 90 days

**Points System:**

**Point Earning:**
- Daily meal logging: +10 points
- Logging all macros within 70% threshold: +5 bonus points
- Weight entry: +5 points
- Completing full MATADOR cycle within targets: +100 points
- Daily login: +2 points

**Decay Mechanics:**
- Points decay by 1% per day of inactivity (no logging or weight entry)
- Streak breaks reset decay rate to 5% per day for next 7 days (penalty for abandonment)
- Decay stops when user resumes logging (encourages return)
- Badges earned are permanent (never lost), but point totals decay

**Leaderboard (Optional):**
- Weekly leaderboard among friends (opt-in only)
- Points shown with decay applied
- Privacy-first: No weight or body metrics shown, only badges and points

**UI Integration:**
- Badge display in profile tab (Phase 2 feature)
- Point counter in dashboard header (small, non-intrusive)
- Streak flame icon next to cycle timer (shows current streak days)
- Achievement unlock animations (confetti, fire character celebration)

**Database Schema (Phase 2):**

```sql
-- Badges earned by users
CREATE TABLE user_badges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    badge_type TEXT NOT NULL,  -- 'streak', 'adherence', 'milestone', 'weight_progress'
    badge_tier TEXT NOT NULL,  -- 'bronze', 'silver', 'gold', 'platinum'
    earned_at DATETIME NOT NULL,
    UNIQUE(user_id, badge_type, badge_tier)
);

-- Points ledger
CREATE TABLE user_points (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    points_earned INTEGER NOT NULL,
    points_reason TEXT NOT NULL,  -- 'meal_logged', 'cycle_completed', etc.
    earned_at DATETIME NOT NULL
);

-- Decay tracking
CREATE TABLE points_decay (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    decay_amount INTEGER NOT NULL,
    decay_date DATE NOT NULL,
    last_activity_date DATE NOT NULL
);

-- Streak tracking
CREATE TABLE user_streaks (
    user_id TEXT PRIMARY KEY,
    current_streak_days INTEGER DEFAULT 0,
    longest_streak_days INTEGER DEFAULT 0,
    last_activity_date DATE NOT NULL,
    streak_broken_at DATETIME
);
```

**Analytics Events (Phase 2):**
- `badge_earned`: Tracks badge unlocks
- `points_awarded`: Tracks point earning events
- `streak_broken`: Tracks when users break streaks
- `streak_milestone_reached`: Tracks 7-day, 30-day, etc. milestones
- `decay_applied`: Tracks point decay events for churn analysis

**Technical Considerations:**
- Nightly background task calculates decay (local notifications permission required)
- Badge unlock logic runs after every meal log / weight entry
- Point totals cached in-memory, recalculated on app launch
- Supabase sync for cross-device badge/point consistency

**Design Notes:**
- Keep badge UI subtle in POC (no gamification in Phase 1)
- Fire character variations can celebrate badge unlocks (Phase 2)
- Forgiving design: 70% threshold applies to badge eligibility (consistent with core UX principle)


---

## Implementation Patterns & Consistency Rules

### Pattern Categories Overview

**15 critical conflict points** identified where AI agents could make different implementation choices, organized into 5 pattern categories.

### 1. Naming Patterns

#### Database Naming (GRDB/SQLite)

**Table Naming:**
- ✅ **Pattern:** Lowercase, plural, snake_case
- ✅ **Examples:** `meal_logs`, `weight_entries`, `cycle_states`, `analytics_events`
- ❌ **Anti-pattern:** `MealLog`, `mealLogs`, `meal-logs`

**Column Naming:**
- ✅ **Pattern:** Lowercase, snake_case, descriptive
- ✅ **Examples:** `user_id`, `meal_name`, `calories_kcal`, `logged_at`, `created_at`
- ❌ **Anti-pattern:** `userId`, `mealName`, `ID`, `timestamp`

**Foreign Key Naming:**
- ✅ **Pattern:** `{referenced_table}_id`
- ✅ **Examples:** `user_id`, `cycle_state_id`, `meal_log_id`
- ❌ **Anti-pattern:** `fk_user`, `userID`, `user_fk`

**Index Naming:**
- ✅ **Pattern:** `idx_{table}_{column(s)}`
- ✅ **Examples:** `idx_meal_logs_user_id`, `idx_weight_entries_logged_at`, `idx_cycle_states_user_id_start_date`
- ❌ **Anti-pattern:** `meal_logs_user_id_index`, `user_idx`

**Migration File Naming:**
- ✅ **Pattern:** `Migration_YYYYMMDD_HHMMSS_{description}.swift`
- ✅ **Examples:** `Migration_20260103_120000_CreateMealLogsTable.swift`, `Migration_20260104_093000_AddCycleStateRecovery.swift`
- ❌ **Anti-pattern:** `001_meal_logs.swift`, `create_tables.swift`

#### Swift Code Naming

**Type Naming (Classes, Structs, Enums, Protocols):**
- ✅ **Pattern:** PascalCase, descriptive, no abbreviations
- ✅ **Examples:** `DashboardViewModel`, `MealLog`, `CyclePhase`, `TimeProvider`, `GRDBManager`
- ❌ **Anti-pattern:** `dashboardVM`, `MealLogEntry`, `CP`, `time_provider`

**File Naming:**
- ✅ **Pattern:** Match type name exactly (PascalCase)
- ✅ **Examples:** `DashboardViewModel.swift`, `MealLog.swift`, `CycleEngine.swift`
- ❌ **Anti-pattern:** `dashboard-view-model.swift`, `mealLog.swift`, `cycle_engine.swift`

**Extension File Naming:**
- ✅ **Pattern:** `{TypeName}+{Functionality}.swift`
- ✅ **Examples:** `Date+MATADOR.swift`, `MealLog+Validation.swift`, `CyclePhase+Display.swift`
- ❌ **Anti-pattern:** `DateExtensions.swift`, `meal_log_helpers.swift`

**Property/Variable Naming:**
- ✅ **Pattern:** camelCase, descriptive
- ✅ **Examples:** `mealLogs`, `currentPhase`, `cycleStartDate`, `proteinGrams`
- ❌ **Anti-pattern:** `meal_logs`, `phase`, `start_date`, `protein`

**Function Naming:**
- ✅ **Pattern:** camelCase, verb-first, descriptive
- ✅ **Examples:** `fetchMealLogs()`, `calculatePhase()`, `validateCycleState()`, `logAnalyticsEvent()`
- ❌ **Anti-pattern:** `get_meal_logs()`, `phase()`, `validate()`

**Protocol Naming:**
- ✅ **Pattern:** PascalCase, noun or adjective (not -Protocol suffix)
- ✅ **Examples:** `TimeProvider`, `DataSyncable`, `Validatable`
- ❌ **Anti-pattern:** `TimeProviderProtocol`, `IDataSync`, `ValidatableProtocol`

**Published Property Naming:**
- ✅ **Pattern:** `@Published var {descriptiveName}: Type`
- ✅ **Examples:** `@Published var mealLogs: [MealLog] = []`, `@Published var isLoading: Bool = false`, `@Published var errorMessage: String?`
- ❌ **Anti-pattern:** `@Published var logs`, `@Published var loading`, `@Published var error`

#### Analytics Event Naming

**Event Naming:**
- ✅ **Pattern:** snake_case, past_tense, `{noun}_{verb_past}`
- ✅ **Examples:** `meal_logged`, `weight_recorded`, `phase_switched`, `onboarding_completed`, `cycle_recovered`
- ❌ **Anti-pattern:** `logMeal`, `WeightRecorded`, `phase-switch`, `user.onboarding.complete`

**Event Property Naming:**
- ✅ **Pattern:** snake_case, descriptive
- ✅ **Examples:** `meal_name`, `calories_kcal`, `logged_at`, `current_phase`, `recovery_reason`
- ❌ **Anti-pattern:** `mealName`, `cals`, `timestamp`, `phase`

### 2. Structure Patterns

#### Project Organization

**Feature-Based Organization:**
- ✅ **Pattern:** Group by feature, not by type
```
App/
  Features/
    Dashboard/
      DashboardView.swift
      DashboardViewModel.swift
      DashboardViewModel+Tests.swift (if co-located tests)
      Components/
        CycleTimerCard.swift
        WeightCard.swift
        MacroTrackerCard.swift
    MealLogging/
      MealLoggingView.swift
      MealLoggingViewModel.swift
      Components/
        MacroPicker.swift
    WeightTracking/
      WeightEntryView.swift
      WeightEntryViewModel.swift
```
- ❌ **Anti-pattern:** Organizing by type (Views/, ViewModels/, Models/)

**Core Components Organization:**
```
Core/
  Database/
    GRDBManager.swift
    Migrations/
      Migration_20260103_120000_CreateMealLogsTable.swift
      Migration_20260104_093000_AddCycleStateRecovery.swift
  Services/
    SupabaseService.swift
    SyncEngine.swift
  Models/
    MealLog.swift
    WeightEntry.swift
    CycleState.swift
  Utilities/
    TimeProvider.swift
    LocalizationManager.swift
```

**Test File Location:**
- ✅ **Pattern:** Co-located with implementation file, `{TypeName}+Tests.swift`
- ✅ **Examples:** `DashboardViewModel+Tests.swift`, `CycleEngine+Tests.swift`
- ❌ **Anti-pattern:** Separate Tests/ folder (breaks feature cohesion)

**Configuration Files:**
```
Config/
  Dev.xcconfig
  Staging.xcconfig
  Production.xcconfig
  Secrets.xcconfig (gitignored)
```

**Resources Organization:**
```
Resources/
  Assets.xcassets/
    Colors/
      PrimaryBackground.colorset
      AccentGreen.colorset
    Icons/
      FireHappy.imageset
      FireConcerned.imageset
  Localizations/
    de.json
    en.json (Phase 2)
```

#### GRDB Migration Organization

**Migration Pattern:**
- ✅ **Pattern:** Numbered migrations in `Core/Database/Migrations/`
- ✅ **Execution:** All migrations run in `GRDBManager.setupDatabase()` via `migrator.migrate(dbQueue)`
- ✅ **Naming:** `Migration_YYYYMMDD_HHMMSS_{description}.swift`

**Migration Registration:**
```swift
// Core/Database/GRDBManager.swift
private func setupMigrations() -> DatabaseMigrator {
    var migrator = DatabaseMigrator()
    
    // v1.0 - Initial schema
    migrator.registerMigration("v1_create_meal_logs") { db in
        try db.create(table: "meal_logs") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("user_id", .text).notNull()
            t.column("meal_name", .text).notNull()
            t.column("calories_kcal", .integer).notNull()
            t.column("protein_g", .integer).notNull()
            t.column("carbs_g", .integer).notNull()
            t.column("fats_g", .integer).notNull()
            t.column("logged_at", .datetime).notNull()
            t.column("created_at", .datetime).notNull()
        }
        try db.create(index: "idx_meal_logs_user_id", on: "meal_logs", columns: ["user_id"])
    }
    
    // v1.1 - Cycle state recovery
    migrator.registerMigration("v1_add_cycle_state_recovery") { db in
        try db.alter(table: "cycle_states") { t in
            t.add(column: "last_validated_at", .datetime)
            t.add(column: "recovery_count", .integer).defaults(to: 0)
        }
    }
    
    return migrator
}
```

### 3. Format Patterns

#### Supabase API Response Handling

**Response Unwrapping Pattern:**
```swift
// ✅ Correct: Handle response, extract data, map to domain models
func fetchUserProfile() async throws -> UserProfile {
    let response: PostgrestResponse<SupabaseUserProfile> = try await supabase
        .from("user_profiles")
        .select()
        .eq("user_id", value: userId)
        .single()
        .execute()
    
    guard let data = response.data else {
        throw AppError.sync(.noDataReturned)
    }
    
    return UserProfile(from: data)  // Map to domain model
}
```

**Error Handling Pattern:**
```swift
// ✅ Correct: Catch specific errors, wrap in AppError
do {
    let profile = try await supabaseService.fetchUserProfile()
} catch let error as PostgrestError {
    throw AppError.sync(.supabaseError(underlying: error))
} catch {
    throw AppError.sync(.unknownError(underlying: error))
}
```

#### Date/Time Format Patterns

**SQLite Storage:**
- ✅ **Pattern:** ISO8601 strings (`YYYY-MM-DD HH:MM:SS`)
- ✅ **Example:** `"2026-01-03 14:30:00"`
- ✅ **Column Type:** `.datetime` in GRDB

**Supabase Sync:**
- ✅ **Pattern:** ISO8601 strings with timezone (`YYYY-MM-DDTHH:MM:SSZ`)
- ✅ **Example:** `"2026-01-03T14:30:00Z"`
- ✅ **Encoding:** `JSONEncoder().dateEncodingStrategy = .iso8601`

**Swift Code:**
- ✅ **Pattern:** `Date` type everywhere
- ✅ **TimeProvider Protocol:** `protocol TimeProvider { var now: Date { get } }`
- ✅ **Usage:** `let now = timeProvider.now` (testable)

#### JSON Field Mapping

**Swift ↔ PostgreSQL Mapping:**
- ✅ **Pattern:** Use custom CodingKeys for snake_case ↔ camelCase
```swift
struct MealLog: Codable {
    let mealName: String
    let caloriesKcal: Int
    let proteinGrams: Int
    let loggedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case mealName = "meal_name"
        case caloriesKcal = "calories_kcal"
        case proteinGrams = "protein_g"
        case loggedAt = "logged_at"
    }
}
```

**Analytics Event Payload:**
```swift
struct AnalyticsEvent: Codable {
    let eventName: String
    let metadata: [String: String]
    let occurredAt: Date
    
    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case metadata
        case occurredAt = "occurred_at"
    }
}
```

### 4. Communication Patterns

#### ViewModel State Updates

**Published Property Pattern:**
```swift
class DashboardViewModel: ObservableObject {
    @Published var mealLogs: [MealLog] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // ✅ Correct: Update @Published properties on main thread
    @MainActor
    func fetchMealLogs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let logs = try await dbManager.fetchMealLogs()
            self.mealLogs = logs  // Triggers view update
        } catch let error as AppError {
            self.errorMessage = error.userMessage
            error.report()  // Analytics + Sentry
        }
        
        isLoading = false
    }
}
```

**Anti-pattern (Manual objectWillChange):**
```swift
// ❌ Incorrect: Don't use manual objectWillChange when @Published works
func updateLogs(_ logs: [MealLog]) {
    objectWillChange.send()  // Unnecessary!
    self.mealLogs = logs
}
```

#### NotificationCenter Events

**Notification Naming:**
- ✅ **Pattern:** `Notification.Name.{feature}{Event}` extension
```swift
extension Notification.Name {
    static let cyclePhaseDidChange = Notification.Name("cyclePhaseDidChange")
    static let midnightTransitionOccurred = Notification.Name("midnightTransitionOccurred")
    static let syncDidComplete = Notification.Name("syncDidComplete")
}
```

**Usage:**
```swift
// ✅ Post notification
NotificationCenter.default.post(
    name: .cyclePhaseDidChange,
    object: nil,
    userInfo: ["previousPhase": oldPhase, "newPhase": newPhase]
)

// ✅ Observe notification
NotificationCenter.default.addObserver(
    forName: .cyclePhaseDidChange,
    object: nil,
    queue: .main
) { notification in
    // Handle phase change
}
```

#### Analytics Event Structure

**Event Definition Pattern:**
```swift
struct AnalyticsEvent: Codable {
    let eventName: String
    let metadata: [String: String]
    let occurredAt: Date
    let userId: String?
}

// ✅ Factory methods for type safety
extension AnalyticsEvent {
    static func mealLogged(
        mealName: String,
        calories: Int,
        phase: CyclePhase
    ) -> AnalyticsEvent {
        AnalyticsEvent(
            eventName: "meal_logged",
            metadata: [
                "meal_name": mealName,
                "calories_kcal": "\(calories)",
                "current_phase": phase.rawValue
            ],
            occurredAt: Date(),
            userId: AuthManager.shared.currentUserId
        )
    }
    
    static func phaseSwitched(
        from: CyclePhase,
        to: CyclePhase,
        automatic: Bool
    ) -> AnalyticsEvent {
        AnalyticsEvent(
            eventName: "phase_switched",
            metadata: [
                "previous_phase": from.rawValue,
                "new_phase": to.rawValue,
                "automatic": "\(automatic)"
            ],
            occurredAt: Date(),
            userId: AuthManager.shared.currentUserId
        )
    }
}
```

### 5. Process Patterns

#### Loading State Pattern

**Standard Loading Pattern:**
```swift
class FeatureViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @MainActor
    func performAsyncTask() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }  // Always reset loading state
        
        do {
            // Async work
        } catch let error as AppError {
            errorMessage = error.userMessage
            error.report()
        }
    }
}
```

**View Loading UI:**
```swift
struct FeatureView: View {
    @StateObject var viewModel = FeatureViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                // Content
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
```

#### Error Handling Flow

**Consistent Error Flow:**
```swift
// 1. Catch error
catch let error as AppError {
    // 2. Report to analytics + Sentry
    error.report()
    
    // 3. Set user-facing message
    self.errorMessage = error.userMessage
    
    // 4. View shows alert automatically via .alert() modifier
}

// Alternative: Return Result<T, AppError> for non-throwing functions
func validateInput() -> Result<ValidatedData, AppError> {
    guard !input.isEmpty else {
        return .failure(.validation(.emptyField(field: "meal_name")))
    }
    return .success(validatedData)
}
```

#### GRDB Transaction Pattern

**Write Transaction Pattern:**
```swift
// ✅ Correct: Use write transaction for multi-step operations
func saveMealLog(_ log: MealLog) throws {
    try dbQueue.write { db in
        // Insert meal log
        try log.insert(db)
        
        // Update daily totals
        let today = Calendar.current.startOfDay(for: Date())
        let totalCalories = try MealLog
            .filter(Column("logged_at") >= today)
            .fetchAll(db)
            .reduce(0) { $0 + $1.caloriesKcal }
        
        // Update cache
        try db.execute(
            sql: "INSERT OR REPLACE INTO daily_totals (date, total_calories) VALUES (?, ?)",
            arguments: [today, totalCalories]
        )
    }
}
```

**Read Pattern:**
```swift
// ✅ Correct: Use read for queries
func fetchMealLogs() throws -> [MealLog] {
    try dbQueue.read { db in
        try MealLog
            .order(Column("logged_at").desc)
            .limit(100)
            .fetchAll(db)
    }
}
```

#### Supabase Sync Queue Pattern

**Offline Queue Pattern:**
```swift
class SyncEngine {
    private let queue: DispatchQueue = DispatchQueue(label: "com.w-diet.sync")
    
    func queueSyncOperation(_ operation: SyncOperation) async throws {
        // 1. Store operation in local database
        try dbManager.insertSyncOperation(operation)
        
        // 2. Attempt immediate sync if online
        if NetworkMonitor.shared.isConnected {
            try await executeSyncOperation(operation)
        }
        
        // 3. If offline, mark as pending (will retry on next connection)
    }
    
    func processPendingOperations() async {
        let pending = try await dbManager.fetchPendingSyncOperations()
        
        for operation in pending {
            do {
                try await executeSyncOperation(operation)
                try await dbManager.markSyncOperationCompleted(operation.id)
            } catch {
                // Log failure, will retry later
                print("Sync failed for operation \(operation.id): \(error)")
            }
        }
    }
}
```

### Enforcement Guidelines

**All AI Agents MUST:**

1. **Follow naming conventions exactly** - Use snake_case for database, camelCase for Swift, PascalCase for types
2. **Organize by feature, not by type** - Group related files in feature folders
3. **Use @Published for ViewModel state** - Never use manual objectWillChange.send() when @Published works
4. **Handle dates with TimeProvider** - Make time-dependent logic testable via protocol injection
5. **Map JSON fields with CodingKeys** - Always define snake_case ↔ camelCase mapping explicitly
6. **Co-locate tests with implementation** - `{TypeName}+Tests.swift` pattern
7. **Use AppError.report()** - All errors must be logged to both analytics and Sentry
8. **Wrap async work in isLoading state** - Use defer to ensure loading state is reset
9. **Use GRDB transactions** - Write operations must use `dbQueue.write`, reads use `dbQueue.read`
10. **Queue offline operations** - All Supabase writes must queue locally for offline resilience

**Pattern Verification:**

- **Linting:** SwiftLint rules enforce naming conventions
- **Code Review:** PR template includes pattern compliance checklist
- **Testing:** Pattern violations break tests (e.g., wrong date format causes decode failure)

**Updating Patterns:**

- All pattern changes must be documented in architecture.md
- Notify all active AI agents of pattern updates
- Retroactive refactoring required if breaking pattern change

### Pattern Examples

**Good Example - Feature Implementation:**
```swift
// ✅ App/Features/MealLogging/MealLoggingView.swift
struct MealLoggingView: View {
    @StateObject var viewModel = MealLoggingViewModel()
    
    var body: some View {
        // View code
    }
}

// ✅ App/Features/MealLogging/MealLoggingViewModel.swift
class MealLoggingViewModel: ObservableObject {
    @Published var mealLogs: [MealLog] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dbManager: GRDBManager
    private let timeProvider: TimeProvider
    
    init(dbManager: GRDBManager = .shared, timeProvider: TimeProvider = SystemTimeProvider()) {
        self.dbManager = dbManager
        self.timeProvider = timeProvider
    }
    
    @MainActor
    func saveMealLog(name: String, calories: Int, protein: Int, carbs: Int, fats: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let log = MealLog(
            mealName: name,
            caloriesKcal: calories,
            proteinGrams: protein,
            carbsGrams: carbs,
            fatsGrams: fats,
            loggedAt: timeProvider.now
        )
        
        do {
            try await dbManager.saveMealLog(log)
            AnalyticsManager.shared.logEvent(.mealLogged(
                mealName: name,
                calories: calories,
                phase: CycleEngine.shared.currentPhase
            ))
        } catch let error as AppError {
            errorMessage = error.userMessage
            error.report()
        }
    }
}

// ✅ Core/Models/MealLog.swift
struct MealLog: Codable, FetchableRecord, PersistableRecord {
    let id: Int64?
    let userId: String
    let mealName: String
    let caloriesKcal: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatsGrams: Int
    let loggedAt: Date
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mealName = "meal_name"
        case caloriesKcal = "calories_kcal"
        case proteinGrams = "protein_g"
        case carbsGrams = "carbs_g"
        case fatsGrams = "fats_g"
        case loggedAt = "logged_at"
        case createdAt = "created_at"
    }
    
    static let databaseTableName = "meal_logs"
}
```

**Anti-Patterns to Avoid:**

```swift
// ❌ Wrong: Organizing by type instead of feature
ViewModels/
  MealLoggingViewModel.swift
  DashboardViewModel.swift
Views/
  MealLoggingView.swift
  DashboardView.swift

// ❌ Wrong: Manual objectWillChange instead of @Published
class BadViewModel: ObservableObject {
    var mealLogs: [MealLog] = [] {
        didSet {
            objectWillChange.send()  // Use @Published instead!
        }
    }
}

// ❌ Wrong: No CodingKeys mapping
struct BadMealLog: Codable {
    let meal_name: String  // Swift uses camelCase!
    let calories_kcal: Int  // This won't match PostgreSQL snake_case
}

// ❌ Wrong: Hardcoded Date() instead of TimeProvider
func calculatePhase() -> CyclePhase {
    let now = Date()  // Impossible to test midnight transitions!
    // ...
}

// ❌ Wrong: Not using defer for loading state
func badAsyncFunction() async {
    isLoading = true
    // If this throws, isLoading stays true forever!
    try await somethingThatMightThrow()
    isLoading = false
}

// ❌ Wrong: PascalCase database table
try db.create(table: "MealLogs") { t in  // Use "meal_logs"!
    // ...
}

// ❌ Wrong: Separate Tests/ folder breaks feature cohesion
Tests/
  DashboardViewModelTests.swift  // Should be DashboardViewModel+Tests.swift in Features/Dashboard/
```


---

## Project Structure & Boundaries

### Complete Project Directory Structure

```
w-diet/
├── README.md
├── .gitignore
├── w-diet.xcodeproj/
│   └── project.pbxproj
├── Package.swift                      # Swift Package Manager (GRDB, Supabase, Sentry)
│
├── Scripts/                           # Development automation
│   ├── generate-migration.sh          # Auto-generates migration with unique timestamp
│   └── setup-ci-database.sh           # PostgreSQL container setup for CI
│
├── Config/                            # Build configurations
│   ├── Dev.xcconfig                   # Development environment
│   ├── Staging.xcconfig               # Staging environment
│   ├── Production.xcconfig            # Production environment
│   └── Secrets.xcconfig               # API keys, tokens (gitignored)
│
├── App/                               # Application entry point
│   ├── w_dietApp.swift                # @main entry point
│   ├── AppDelegate.swift              # App lifecycle (Sentry init, notifications)
│   ├── AppConfiguration.swift         # Environment-based config loader
│   │
│   ├── Features/                      # Feature modules (organized by feature)
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift
│   │   │   ├── DashboardViewModel.swift
│   │   │   ├── DashboardViewModel+Tests.swift
│   │   │   └── Components/
│   │   │       ├── CycleTimerCard.swift
│   │   │       ├── CycleTimerCard+Tests.swift
│   │   │       ├── WeightCard.swift
│   │   │       ├── WeightCard+Tests.swift
│   │   │       ├── MacroTrackerCard.swift
│   │   │       └── MacroTrackerCard+Tests.swift
│   │   │
│   │   ├── MealLogging/
│   │   │   ├── MealLoggingView.swift
│   │   │   ├── MealLoggingViewModel.swift
│   │   │   ├── MealLoggingViewModel+Tests.swift
│   │   │   └── Components/
│   │   │       ├── MacroPicker.swift
│   │   │       ├── MacroPicker+Tests.swift
│   │   │       ├── MealNameInput.swift
│   │   │       └── CalorieInput.swift
│   │   │
│   │   ├── WeightTracking/
│   │   │   ├── WeightEntryView.swift
│   │   │   ├── WeightEntryViewModel.swift
│   │   │   ├── WeightEntryViewModel+Tests.swift
│   │   │   └── Components/
│   │   │       ├── WeightPicker.swift              # iOS picker wheel
│   │   │       ├── WeightPicker+Tests.swift
│   │   │       └── WeightHistoryChart.swift        # 7-day rolling average
│   │   │
│   │   ├── Onboarding/
│   │   │   ├── OnboardingFlow.swift                # NavigationStack coordinator
│   │   │   ├── OnboardingViewModel.swift
│   │   │   ├── OnboardingViewModel+Tests.swift
│   │   │   └── Steps/
│   │   │       ├── WelcomeStep.swift
│   │   │       ├── GoalSelectionStep.swift         # Weight loss/gain
│   │   │       ├── MacroInputStep.swift            # Target macros
│   │   │       ├── CycleStartStep.swift            # Set cycle start date
│   │   │       └── PermissionsStep.swift           # Notifications
│   │   │
│   │   ├── Profile/
│   │   │   ├── ProfileView.swift
│   │   │   ├── ProfileViewModel.swift
│   │   │   ├── ProfileViewModel+Tests.swift
│   │   │   └── Components/
│   │   │       ├── SettingsRow.swift
│   │   │       ├── AccountSection.swift
│   │   │       └── DataExportSection.swift
│   │   │
│   │   └── Education/                              # Fire coach educational content
│   │       ├── EducationView.swift
│   │       ├── EducationViewModel.swift
│   │       └── Components/
│   │           ├── FireTipCard.swift
│   │           └── MATADORExplainer.swift
│   │
│   └── Navigation/
│       ├── TabNavigationView.swift                 # Root TabView
│       └── AppRouter.swift                         # Deep link handling
│
├── Core/                                           # Core business logic
│   ├── Database/
│   │   ├── GRDBManager.swift                       # Database singleton
│   │   ├── GRDBManager+Tests.swift
│   │   └── Migrations/
│   │       ├── v1.0-POC/                           # POC phase migrations
│   │       │   ├── Migration_20260103_120000_CreateMealLogsTable.swift
│   │       │   ├── Migration_20260103_121500_CreateWeightEntriesTable.swift
│   │       │   ├── Migration_20260103_123000_CreateCycleStatesTable.swift
│   │       │   ├── Migration_20260103_124500_CreateAnalyticsEventsTable.swift
│   │       │   ├── Migration_20260103_130000_CreateUserProfilesTable.swift
│   │       │   ├── Migration_20260103_131500_CreateSyncQueueTable.swift
│   │       │   └── Migration_20260104_093000_AddCycleStateRecovery.swift
│   │       └── v1.1-Phase2/                        # Phase 2 migrations (badges, points)
│   │           └── [Future migration files]
│   │
│   ├── Models/                                     # Domain models
│   │   ├── MealLog.swift                           # Codable, FetchableRecord, PersistableRecord
│   │   ├── MealLog+Tests.swift
│   │   ├── WeightEntry.swift
│   │   ├── WeightEntry+Tests.swift
│   │   ├── CycleState.swift
│   │   ├── CycleState+Tests.swift
│   │   ├── UserProfile.swift
│   │   ├── UserProfile+Tests.swift
│   │   ├── AnalyticsEvent.swift
│   │   ├── AnalyticsEvent+Tests.swift
│   │   ├── SyncOperation.swift
│   │   └── SyncOperation+Tests.swift
│   │
│   ├── Services/
│   │   ├── SupabaseService.swift                   # Supabase client wrapper
│   │   ├── SupabaseService+Tests.swift
│   │   ├── SyncEngine.swift                        # Offline-first sync queue
│   │   ├── SyncEngine+Tests.swift
│   │   ├── AuthManager.swift                       # Supabase Auth wrapper
│   │   ├── AuthManager+Tests.swift
│   │   ├── AnalyticsManager.swift                  # Event logging
│   │   ├── AnalyticsManager+Tests.swift
│   │   └── NetworkMonitor.swift                    # Online/offline detection
│   │
│   ├── CycleEngine/
│   │   ├── CycleEngine.swift                       # MATADOR phase calculations
│   │   ├── CycleEngine+Tests.swift
│   │   ├── CyclePhase.swift                        # Enum: diet, maintenance
│   │   ├── CycleRecoveryProtocol.swift             # Fail-safe recovery logic
│   │   └── CycleRecoveryProtocol+Tests.swift
│   │
│   ├── Errors/
│   │   ├── AppError.swift                          # Top-level error hierarchy
│   │   ├── DatabaseError.swift
│   │   ├── SyncError.swift
│   │   ├── ValidationError.swift
│   │   └── AuthError.swift
│   │
│   └── Utilities/
│       ├── TimeProvider.swift                      # Protocol for mockable Date()
│       ├── SystemTimeProvider.swift                # Production implementation
│       ├── MockTimeProvider.swift                  # Test implementation
│       ├── LocalizationManager.swift               # JSON-based i18n
│       ├── LocalizationManager+Tests.swift
│       ├── Constants.swift                         # App-wide constants
│       └── Extensions/
│           ├── Date+MATADOR.swift                  # MATADOR-specific date helpers
│           ├── Date+MATADOR+Tests.swift
│           ├── Color+Theme.swift                   # SwiftUI color extensions
│           └── View+Extensions.swift               # Reusable view modifiers
│
├── Shared/                                         # Shared UI components
│   ├── Components/
│   │   ├── FireCharacter/
│   │   │   ├── FireCharacterView.swift             # Presentational only: takes FireVariation enum
│   │   │   ├── FireCharacterView+Tests.swift
│   │   │   └── FireVariation.swift                 # Enum: happy, concerned, celebrating, sleeping
│   │   │
│   │   ├── MacroProgressBar.swift                  # Reusable macro bar
│   │   ├── MacroProgressBar+Tests.swift
│   │   ├── LoadingView.swift                       # Standard loading spinner
│   │   └── ErrorAlertModifier.swift                # Reusable error alert
│   │
│   └── ViewModifiers/
│       ├── ThumbZoneLayout.swift                   # 60/40 split modifier
│       └── ForgivingThreshold.swift                # 70% success visualization
│
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Colors/
│   │   │   ├── PrimaryBackground.colorset
│   │   │   ├── SecondaryBackground.colorset
│   │   │   ├── AccentGreen.colorset               # Phase: Diet (green)
│   │   │   ├── AccentOrange.colorset              # Phase: Maintenance (orange)
│   │   │   ├── TextPrimary.colorset
│   │   │   └── TextSecondary.colorset
│   │   └── Fires/
│   │       ├── FireHappy.imageset/
│   │       ├── FireConcerned.imageset/
│   │       ├── FireCelebrating.imageset/
│   │       └── FireSleeping.imageset/
│   │
│   └── Localizations/
│       ├── de.json                                 # German strings (POC)
│       └── en.json                                 # English strings (Phase 2)
│
├── Tests/                                          # Integration & E2E tests (unit tests co-located)
│   ├── IntegrationTests/
│   │   ├── DatabaseSyncTests.swift                 # GRDB ↔ Supabase sync
│   │   ├── CycleRecoveryTests.swift                # MATADOR fail-safe recovery
│   │   └── OfflineQueueTests.swift                 # Offline sync queue
│   │
│   ├── E2ETests/
│   │   ├── OnboardingFlowTests.swift               # First user experience
│   │   ├── MealLoggingFlowTests.swift              # Core value prop
│   │   ├── PhaseTransitionTests.swift              # Day 14 → Day 15 midnight
│   │   └── OfflineSyncRecoveryTests.swift          # Critical: offline → crash → online sync
│   │
│   └── Fixtures/
│       ├── MockData.swift                          # Sample meal logs, weights
│       └── TestTimeProvider.swift                  # Fixed dates for tests
│
├── CI/                                             # CI/CD configuration
│   ├── docker-compose.yml                          # PostgreSQL + Supabase local stack
│   └── .github/
│       └── workflows/
│           ├── ci.yml                              # Run tests, lint, build
│           └── testflight-deploy.yml               # Archive + upload to TestFlight
│
└── Docs/
    ├── ARCHITECTURE.md                             # This document
    ├── DATABASE_SCHEMA.md                          # GRDB schema reference
    ├── SYNC_PROTOCOL.md                            # Offline-first sync design
    └── DEPLOYMENT.md                               # TestFlight deployment guide
```

### Architectural Boundaries

#### API Boundaries

**Supabase API Layer:**
- **Entry Point:** `Core/Services/SupabaseService.swift`
- **Responsibilities:** 
  - User authentication (Apple Sign-In, Google, Email/Password)
  - Cloud data sync (user_profiles, meal_logs, weight_entries, cycle_states)
  - Analytics event upload
- **Boundary:** All Supabase calls go through `SupabaseService`, no direct SDK usage in ViewModels
- **Error Handling:** All errors wrapped in `AppError.sync()`

**GRDB Database Layer:**
- **Entry Point:** `Core/Database/GRDBManager.swift`
- **Responsibilities:**
  - Local SQLite database (primary source of truth)
  - Schema migrations
  - Read/write transactions
  - Query optimization (<50ms P95)
- **Boundary:** All database operations go through `GRDBManager`, no direct GRDB calls in ViewModels
- **Error Handling:** All errors wrapped in `AppError.database()`

**Sync Queue Layer:**
- **Entry Point:** `Core/Services/SyncEngine.swift`
- **Responsibilities:**
  - Offline operation queuing
  - Conflict resolution (last-write-wins)
  - Retry logic with exponential backoff
  - Network state monitoring
- **Boundary:** Sits between `GRDBManager` (local) and `SupabaseService` (cloud)
- **Communication:** Observes `NetworkMonitor` for online/offline state

#### Component Boundaries

**Feature Module Pattern:**
- Each feature is self-contained in `App/Features/{FeatureName}/`
- **Exports:** View, ViewModel
- **Imports:** Core models, services, shared components
- **Communication:** Features do NOT import other features (use shared components instead)

**ViewModel → Service Communication:**
```swift
// ✅ Correct: ViewModel calls service via dependency injection
class DashboardViewModel: ObservableObject {
    private let dbManager: GRDBManager
    private let cycleEngine: CycleEngine
    
    init(dbManager: GRDBManager = .shared, cycleEngine: CycleEngine = .shared) {
        self.dbManager = dbManager
        self.cycleEngine = cycleEngine
    }
    
    func fetchData() async {
        let logs = try await dbManager.fetchMealLogs()  // Service boundary
        let phase = cycleEngine.calculatePhase()         // Engine boundary
    }
}
```

**View → ViewModel Communication:**
```swift
// ✅ Correct: View owns ViewModel via @StateObject
struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    
    var body: some View {
        // View reacts to @Published properties
        Text(viewModel.currentPhase.displayName)
    }
}
```

**Shared Component Contract (Fire Character):**
```swift
// ✅ Shared/Components/FireCharacter/FireCharacterView.swift
// PRESENTATIONAL ONLY - No business logic, just rendering

struct FireCharacterView: View {
    let variation: FireVariation
    let size: CGFloat
    
    var body: some View {
        Image(variation.imageName)
            .resizable()
            .frame(width: size, height: size)
    }
}

// Business logic stays in feature ViewModels
class DashboardViewModel: ObservableObject {
    @Published var fireVariation: FireVariation = .happy
    
    func updateFireBasedOnProgress() {
        // Calculate which fire to show based on macro progress
        if macroProgress >= 0.7 {
            fireVariation = .happy
        } else if macroProgress >= 0.4 {
            fireVariation = .concerned
        } else {
            fireVariation = .sleeping
        }
    }
}

// View just passes the variation
struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    
    var body: some View {
        FireCharacterView(variation: viewModel.fireVariation, size: 120)
    }
}
```

**Cross-Feature Communication:**
- **Via NotificationCenter:** For event-driven updates (e.g., phase change)
- **Via Shared State:** `EnvironmentObject` for app-wide state (e.g., AuthManager)
- **NOT via direct imports:** Features remain decoupled

#### Service Boundaries

**Core Service Hierarchy:**

1. **Database Layer (Primary):**
   - `GRDBManager` → SQLite (always accessible, offline-first)
   - All read/write operations synchronous or async with GRDB

2. **Sync Layer (Secondary):**
   - `SyncEngine` → Mediates between GRDB and Supabase
   - Queues operations when offline
   - Processes queue when online

3. **Cloud Layer (Optional):**
   - `SupabaseService` → PostgreSQL (requires network)
   - Never blocks UI (all operations async)

**Service Communication Flow:**
```
ViewModel
    ↓
GRDBManager (local write)
    ↓
SyncEngine.queueSyncOperation() (async)
    ↓
NetworkMonitor (check connectivity)
    ↓
SupabaseService (cloud sync if online)
```

#### Data Boundaries

**Local Database (GRDB/SQLite):**
- **Schema:** See `Core/Database/Migrations/v1.0-POC/`
- **Tables:** meal_logs, weight_entries, cycle_states, user_profiles, analytics_events, sync_queue
- **Access Pattern:** All reads/writes via `GRDBManager`
- **Naming:** snake_case (e.g., `meal_logs`, `user_id`)

**Cloud Database (Supabase/PostgreSQL):**
- **Schema:** Mirrors GRDB schema (snake_case)
- **Tables:** Same as local (synced via `sync_queue`)
- **Access Pattern:** All operations via `SupabaseService`
- **Row-Level Security (RLS):** Enforced on Supabase (users see only their data)

**JSON Mapping Boundary:**
```swift
// CodingKeys bridge Swift (camelCase) ↔ PostgreSQL (snake_case)
struct MealLog: Codable {
    let mealName: String
    let caloriesKcal: Int
    
    enum CodingKeys: String, CodingKey {
        case mealName = "meal_name"
        case caloriesKcal = "calories_kcal"
    }
}
```

### Requirements to Structure Mapping

#### Epic 1: MATADOR Cycling Automation

**Components:**
- `Core/CycleEngine/CycleEngine.swift` - Phase calculation logic
- `Core/CycleEngine/CyclePhase.swift` - Enum: diet (14 days) / maintenance (14 days)
- `Core/CycleEngine/CycleRecoveryProtocol.swift` - Fail-safe recovery on app launch + midnight
- `Core/Models/CycleState.swift` - Database model for cycle tracking
- `Features/Dashboard/Components/CycleTimerCard.swift` - UI for cycle countdown

**Database:**
- `Migrations/v1.0-POC/Migration_20260103_123000_CreateCycleStatesTable.swift`
- `Migrations/v1.0-POC/Migration_20260104_093000_AddCycleStateRecovery.swift`

**Tests:**
- `CycleEngine+Tests.swift` - Phase calculation, midnight transitions
- `CycleRecoveryProtocol+Tests.swift` - Recovery scenarios (crash, force-quit, timezone change)
- `Tests/E2ETests/PhaseTransitionTests.swift` - Day 14 → Day 15 integration test

#### Epic 2: Meal Logging

**Components:**
- `Features/MealLogging/MealLoggingView.swift` - Main meal entry form
- `Features/MealLogging/MealLoggingViewModel.swift` - Business logic
- `Features/MealLogging/Components/MacroPicker.swift` - iOS picker wheel for macros
- `Core/Models/MealLog.swift` - Database model

**Database:**
- `Migrations/v1.0-POC/Migration_20260103_120000_CreateMealLogsTable.swift`

**Tests:**
- `MealLoggingViewModel+Tests.swift` - Validation, save flow
- `Tests/E2ETests/MealLoggingFlowTests.swift` - Full logging flow

#### Epic 3: Weight Tracking

**Components:**
- `Features/WeightTracking/WeightEntryView.swift` - Weight input form
- `Features/WeightTracking/WeightEntryViewModel.swift` - 7-day rolling average calculation
- `Features/WeightTracking/Components/WeightPicker.swift` - iOS picker wheel (one-handed operation)
- `Features/WeightTracking/Components/WeightHistoryChart.swift` - Line chart with rolling average
- `Core/Models/WeightEntry.swift` - Database model

**Database:**
- `Migrations/v1.0-POC/Migration_20260103_121500_CreateWeightEntriesTable.swift`

**Tests:**
- `WeightEntryViewModel+Tests.swift` - Rolling average calculation
- `WeightPicker+Tests.swift` - Picker validation

#### Epic 4: Dashboard

**Components:**
- `Features/Dashboard/DashboardView.swift` - Main screen (TabView root)
- `Features/Dashboard/DashboardViewModel.swift` - Aggregates data from all sources, calculates fire variation
- `Features/Dashboard/Components/CycleTimerCard.swift` - Cycle countdown (top 40% visual zone)
- `Features/Dashboard/Components/WeightCard.swift` - Current weight + 7-day trend
- `Features/Dashboard/Components/MacroTrackerCard.swift` - Daily macro progress bars

**Database:**
- Reads from: `meal_logs`, `weight_entries`, `cycle_states`

**Tests:**
- `DashboardViewModel+Tests.swift` - Data aggregation, <50ms load target, fire variation logic

#### Epic 5: Onboarding

**Components:**
- `Features/Onboarding/OnboardingFlow.swift` - NavigationStack coordinator
- `Features/Onboarding/OnboardingViewModel.swift` - Collects user input
- `Features/Onboarding/Steps/WelcomeStep.swift` - Welcome screen with fire character
- `Features/Onboarding/Steps/GoalSelectionStep.swift` - Weight loss/gain goal
- `Features/Onboarding/Steps/MacroInputStep.swift` - Target macros (calories, protein, carbs, fats)
- `Features/Onboarding/Steps/CycleStartStep.swift` - Set cycle start date
- `Features/Onboarding/Steps/PermissionsStep.swift` - Request notification permission (midnight transitions)

**Database:**
- Writes to: `user_profiles`, `cycle_states`

**Tests:**
- `OnboardingViewModel+Tests.swift` - Validation logic
- `Tests/E2ETests/OnboardingFlowTests.swift` - Full onboarding flow

#### Cross-Cutting Concern: Authentication

**Components:**
- `Core/Services/AuthManager.swift` - Supabase Auth wrapper (singleton, EnvironmentObject)
- `Core/Errors/AuthError.swift` - Auth-specific errors

**Integration:**
- `App/w_dietApp.swift` - Initializes AuthManager on app launch
- All features access via: `@EnvironmentObject var authManager: AuthManager`

**Database:**
- `Migrations/v1.0-POC/Migration_20260103_130000_CreateUserProfilesTable.swift`

#### Cross-Cutting Concern: Analytics

**Components:**
- `Core/Services/AnalyticsManager.swift` - Event logging (singleton)
- `Core/Models/AnalyticsEvent.swift` - Event structure (Codable)

**Integration:**
- All ViewModels call: `AnalyticsManager.shared.logEvent(.mealLogged(...))`
- Events stored in SQLite, synced to Supabase

**Database:**
- `Migrations/v1.0-POC/Migration_20260103_124500_CreateAnalyticsEventsTable.swift`

#### Cross-Cutting Concern: Localization (German POC)

**Components:**
- `Core/Utilities/LocalizationManager.swift` - JSON-based i18n (singleton, ObservableObject)
- `Resources/Localizations/de.json` - German strings (POC)
- `Resources/Localizations/en.json` - English strings (Phase 2)

**Integration:**
- All Views access via: `@ObservedObject var localization = LocalizationManager.shared`
- Usage: `Text(localization.string(for: "dashboard.title"))`

### Integration Points

#### Internal Communication

**ViewModel → Database:**
```swift
// All database operations async via GRDBManager
let logs = try await GRDBManager.shared.fetchMealLogs()
try await GRDBManager.shared.saveMealLog(newLog)
```

**ViewModel → Cycle Engine:**
```swift
// Phase calculations via CycleEngine
let currentPhase = CycleEngine.shared.calculatePhase()  // Uses TimeProvider for testability
let daysRemaining = CycleEngine.shared.daysRemainingInPhase()
```

**Feature → Feature (Event-Driven):**
```swift
// When cycle phase changes, notify all listening features
NotificationCenter.default.post(name: .cyclePhaseDidChange, object: nil, userInfo: ["newPhase": newPhase])

// Dashboard observes and updates UI
NotificationCenter.default.addObserver(forName: .cyclePhaseDidChange, ...) { notification in
    viewModel.refreshPhase()
}
```

**App-Wide State (EnvironmentObject):**
```swift
// App/w_dietApp.swift
@main
struct w_dietApp: App {
    @StateObject var authManager = AuthManager.shared
    @StateObject var localization = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            TabNavigationView()
                .environmentObject(authManager)
                .environmentObject(localization)
        }
    }
}

// Features access via:
@EnvironmentObject var authManager: AuthManager
```

#### External Integrations

**Supabase (PostgreSQL + Auth):**
- **Endpoint:** `https://{project-id}.supabase.co`
- **Authentication:** JWT tokens via Supabase Auth SDK
- **Integration Point:** `Core/Services/SupabaseService.swift`
- **API Calls:** RESTful via `supabase-swift` SDK (installed via Swift Package Manager)
- **Security:** Row-Level Security (RLS) policies enforce user data isolation

**Sentry (Crash Monitoring):**
- **Endpoint:** Sentry DSN (configured in `Secrets.xcconfig`)
- **Integration Point:** `App/AppDelegate.swift` - `SentrySDK.start()`
- **Error Reporting:** All `AppError.report()` calls send to Sentry
- **Release Tracking:** Tied to TestFlight build numbers
- **dSYM Upload:** Automated via Xcode build phase

**Apple Push Notification Service (APNs):**
- **Use Case:** Midnight local notifications for MATADOR phase transitions
- **Integration Point:** `App/AppDelegate.swift` - Request permission in `Onboarding/PermissionsStep.swift`
- **Scheduling:** `CycleEngine` schedules daily midnight notification

#### Data Flow

**Meal Logging Flow (Offline-First):**
```
User enters meal in MealLoggingView
    ↓
MealLoggingViewModel.saveMealLog()
    ↓
GRDBManager.saveMealLog() (immediate local write to SQLite)
    ↓
SyncEngine.queueSyncOperation(type: .insert, model: mealLog)
    ↓
[If online] SupabaseService.insertMealLog() (async cloud sync)
    ↓
[If offline] Operation queued in sync_queue table, retried when online
    ↓
Dashboard observes database change via GRDB ValueObservation
    ↓
Dashboard UI updates automatically
```

**Authentication Flow:**
```
User taps "Sign in with Apple" in OnboardingView
    ↓
AuthManager.signInWithApple()
    ↓
Supabase Auth SDK handles OAuth flow
    ↓
Supabase returns JWT token
    ↓
AuthManager stores token in Keychain
    ↓
AuthManager.isAuthenticated = true (triggers @Published update)
    ↓
App navigates to Dashboard
```

**Phase Transition Flow (Midnight):**
```
Local notification fires at midnight (scheduled by CycleEngine)
    ↓
AppDelegate receives notification
    ↓
CycleRecoveryProtocol.validateCycleState() runs
    ↓
Compares stored cycle state vs calendar-based calculation
    ↓
[If mismatch] Auto-correct cycle state, log recovery event to analytics
    ↓
Post .cyclePhaseDidChange notification
    ↓
Dashboard observes and refreshes UI
```

**Offline Sync Recovery Flow (Critical E2E Test):**
```
User logs meal while offline
    ↓
MealLog saved to GRDB (success)
    ↓
SyncOperation queued in sync_queue table (status: pending)
    ↓
App crashes or force-quit
    ↓
User reopens app (now online)
    ↓
SyncEngine.processPendingOperations() runs on app launch
    ↓
Fetches all pending operations from sync_queue
    ↓
For each operation: execute SupabaseService call
    ↓
On success: mark operation as completed in sync_queue
    ↓
On failure: log error, operation remains pending for retry
```

### File Organization Patterns

#### Configuration Files

**Environment Configuration (.xcconfig):**
- `Config/Dev.xcconfig` - Development environment (local Supabase instance)
- `Config/Staging.xcconfig` - Staging environment (staging Supabase project)
- `Config/Production.xcconfig` - Production environment (production Supabase project)
- `Config/Secrets.xcconfig` - API keys, Sentry DSN (gitignored, template committed)

**Usage in Xcode:**
- Project → Info → Configurations
- Debug uses `Dev.xcconfig`
- Release uses `Production.xcconfig`
- Archive uses `Production.xcconfig`

#### Source Organization

**Feature-Based Structure:**
- All related code in `App/Features/{FeatureName}/`
- Each feature exports: View, ViewModel
- Components subfolder for feature-specific UI components
- Tests co-located: `{TypeName}+Tests.swift`

**Core Shared Code:**
- `Core/Database/` - GRDB layer with versioned migrations
- `Core/Models/` - Domain models
- `Core/Services/` - Business services (Auth, Sync, Analytics)
- `Core/CycleEngine/` - MATADOR logic
- `Core/Utilities/` - Helpers (TimeProvider, LocalizationManager, Extensions)

**Shared UI Components:**
- `Shared/Components/` - Reusable UI components (FireCharacter is presentational only)
- `Shared/ViewModifiers/` - Reusable SwiftUI modifiers (ThumbZoneLayout, ForgivingThreshold)

#### Test Organization

**Unit Tests (Co-Located):**
- `{TypeName}+Tests.swift` next to implementation file
- Example: `DashboardViewModel+Tests.swift` in `App/Features/Dashboard/`
- **Benefit:** Prevents test rot - tests are visible when refactoring implementation

**Integration Tests:**
- `Tests/IntegrationTests/` - Multi-component integration
- Examples: Database sync tests, offline queue tests, cycle recovery tests
- **CI Setup:** Uses Docker Compose to spin up PostgreSQL container matching Supabase schema

**E2E Tests:**
- `Tests/E2ETests/` - Full user flows
- Examples: 
  - `OnboardingFlowTests.swift` - First user experience
  - `MealLoggingFlowTests.swift` - Core value prop
  - `PhaseTransitionTests.swift` - Day 14 → Day 15 midnight transition
  - `OfflineSyncRecoveryTests.swift` - **Critical**: Offline → crash → online sync (prevents production sync failures)

**Test Fixtures:**
- `Tests/Fixtures/` - Mock data, test time providers

#### Asset Organization

**Xcode Asset Catalog:**
- `Resources/Assets.xcassets/AppIcon.appiconset/` - App icon variants (iPhone, iPad, App Store)
- `Resources/Assets.xcassets/Colors/` - Color sets (supports dark mode)
- `Resources/Assets.xcassets/Fires/` - Fire character image sets (4 variations)

**Localization Files:**
- `Resources/Localizations/de.json` - German strings (POC)
- `Resources/Localizations/en.json` - English strings (Phase 2)

#### Migration Organization

**Versioned Migration Folders:**
- `Core/Database/Migrations/v1.0-POC/` - POC phase (7 migration files)
- `Core/Database/Migrations/v1.1-Phase2/` - Phase 2 (badges, points, streaks)
- **Benefit:** Prevents migration folder bloat, clear version boundaries

**Migration Generation Script:**
```bash
# Scripts/generate-migration.sh
#!/bin/bash
# Auto-generates migration file with globally unique timestamp
# Usage: ./Scripts/generate-migration.sh "CreateMealLogsTable"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DESCRIPTION=$1
VERSION="v1.0-POC"  # Update for Phase 2

FILENAME="Migration_${TIMESTAMP}_${DESCRIPTION}.swift"
FILEPATH="Core/Database/Migrations/${VERSION}/${FILENAME}"

cat > "$FILEPATH" << EOF
import GRDB

extension DatabaseMigrator {
    static func migration_${TIMESTAMP}_${DESCRIPTION}() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("${VERSION}_${DESCRIPTION}") { db in
            // TODO: Write migration SQL
        }
        
        return migrator
    }
}
EOF

echo "Created migration: $FILEPATH"
```

**Benefit:** Prevents timestamp conflicts across team members, enforces naming convention.

### Development Workflow Integration

#### Development Server Structure

**Local Development:**
- Xcode scheme: "w-diet (Dev)"
- Uses `Dev.xcconfig` with local Supabase instance (via Docker Compose)
- Database: SQLite file at `~/Library/Developer/CoreSimulator/.../Documents/w-diet.db`
- Logs: OSLog visible in Console.app (filter by "com.w-diet")

**Simulator Testing:**
- iOS Simulator (iPhone 14 Pro recommended for safe area testing)
- Test thumb-zone layout (60/40 split)
- Test one-handed operation (iOS picker wheels)

#### Build Process Structure

**Swift Package Manager (SPM):**
- Dependencies declared in `Package.swift`:
  - `GRDB.swift` 7.9.0
  - `supabase-swift` (latest)
  - `sentry-cocoa` (latest)
- **No CocoaPods:** SPM is native to Xcode, no `.xcworkspace` ceremony needed

**Debug Build:**
- Fast incremental builds
- All logging enabled (OSLog)
- Sentry disabled (no crash reporting overhead)
- Supabase sync optional (toggle via AppConfiguration)

**Release Build:**
- Optimizations enabled
- Logging reduced (errors only)
- Sentry enabled
- Supabase sync required

**Archive for TestFlight:**
- Uses `Production.xcconfig`
- App thinning enabled
- Build number auto-incremented
- dSYM automatically uploaded to Sentry via Xcode build phase

#### Deployment Structure

**TestFlight Deployment:**
- Archive in Xcode (Product → Archive)
- Upload to App Store Connect
- Add build to TestFlight
- Submit for Beta App Review (1-2 day approval for first build)
- Invite testers via email

**Version Management:**
- Version format: `1.0.{build-number}` (e.g., 1.0.1, 1.0.2)
- Build numbers auto-incremented via Xcode
- Track versions in `CHANGELOG.md`

**Distribution Files:**
- `.ipa` file generated by Xcode Archive
- `dSYM` files uploaded to Sentry for crash symbolication
- No separate build artifacts (Xcode handles everything)

### CI/CD Integration

**Docker Compose for Local Development & CI:**
```yaml
# CI/docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: w_diet_test
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_password
    ports:
      - "5432:5432"
    volumes:
      - ./Scripts/init-test-db.sql:/docker-entrypoint-initdb.d/init.sql

  supabase:
    image: supabase/postgres:15
    environment:
      POSTGRES_DB: w_diet_supabase
      POSTGRES_USER: supabase_admin
      POSTGRES_PASSWORD: supabase_password
    ports:
      - "54322:5432"
```

**GitHub Actions CI Pipeline:**
```yaml
# CI/.github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Start PostgreSQL for integration tests
        run: |
          docker-compose -f CI/docker-compose.yml up -d
          sleep 10  # Wait for PostgreSQL to be ready
      
      - name: Run unit tests
        run: xcodebuild test -scheme w-diet -destination 'platform=iOS Simulator,name=iPhone 14 Pro'
      
      - name: Run integration tests
        run: xcodebuild test -scheme w-diet-IntegrationTests -destination 'platform=iOS Simulator,name=iPhone 14 Pro'
      
      - name: SwiftLint
        run: swiftlint lint --strict
      
      - name: Shutdown PostgreSQL
        run: docker-compose -f CI/docker-compose.yml down
```

**Integration Test Setup Script:**
```bash
# Scripts/setup-ci-database.sh
#!/bin/bash
# Sets up PostgreSQL container with Supabase schema for integration tests

echo "Starting PostgreSQL container..."
docker-compose -f CI/docker-compose.yml up -d postgres

echo "Waiting for PostgreSQL to be ready..."
sleep 10

echo "Running schema migrations..."
psql -h localhost -U test_user -d w_diet_test -f Core/Database/Migrations/v1.0-POC/schema.sql

echo "Database ready for integration tests!"
```

### Quality Gates

**Pre-Commit Checks:**
- SwiftLint (naming conventions, code style)
- Unit tests must pass (co-located tests)

**CI Checks (GitHub Actions):**
- All unit tests pass
- All integration tests pass (with PostgreSQL container)
- SwiftLint strict mode
- Build succeeds for Debug and Release configurations

**Pre-TestFlight Checks:**
- All E2E tests pass
- Manual smoke test on physical device
- Version number incremented
- CHANGELOG.md updated


---

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:**
All technology choices are fully compatible and modern:
- Swift 5.9+ with SwiftUI targets iOS 16+ (iPhone 12 and newer)
- GRDB.swift 7.9.0 integrates seamlessly with Swift Package Manager
- Supabase Swift SDK complements GRDB's offline-first approach (not competing)
- Sentry SDK natively supports SwiftUI error boundaries
- No dependency conflicts across the entire stack

**Pattern Consistency:**
All implementation patterns align with architectural decisions:
- Naming conventions bridge database (snake_case) to Swift (camelCase) via explicit CodingKeys
- State management uses SwiftUI native patterns (@Published, @StateObject, EnvironmentObject)
- Dependency injection via default parameters works with @StateObject lifecycle (no factory pattern conflicts)
- Error handling flow (catch → AppError.report() → alert) is consistent across all features
- TimeProvider protocol enables testable date-dependent logic (MATADOR midnight transitions)

**Structure Alignment:**
Project structure fully supports architectural patterns:
- Feature-based organization enforces MVVM boundaries (View + ViewModel co-located with Components)
- Core/ modules never import App/ features, ensuring proper dependency inversion
- Shared/ components maintain presentational contract (FireCharacterView takes enum, no business logic)
- Versioned migration folders (v1.0-POC/, v1.1-Phase2/) prevent bloat and support DatabaseMigrator pattern
- Co-located tests ({TypeName}+Tests.swift) prevent test rot and improve maintainability

### Requirements Coverage Validation ✅

**Epic/Feature Coverage:**
All 7 epics from PRD are architecturally supported:

1. **MATADOR Cycling Automation** → Core/CycleEngine/, CycleRecoveryProtocol (fail-safe), cycle_states table, midnight local notifications
2. **Meal Logging** → Features/MealLogging/, meal_logs table, MacroPicker (iOS picker wheel), macro validation
3. **Weight Tracking** → Features/WeightTracking/, weight_entries table, 7-day rolling average calculation, WeightHistoryChart
4. **Dashboard** → Features/Dashboard/, GRDB data aggregation (<50ms P95), thumb-zone layout (60/40 split), fire variation logic
5. **Fire Coach Character** → Shared/Components/FireCharacter/ (4 variations: happy, concerned, celebrating, sleeping)
6. **Onboarding** → Features/Onboarding/Steps/, user_profiles table, NavigationStack flow, permissions (notifications)
7. **Profile & Settings** → Features/Profile/, account management, data export capability

**Functional Requirements Coverage:**
All cross-cutting concerns addressed:
- **Authentication:** AuthManager wraps Supabase Auth (Apple Sign-In, Google, Email/Password), JWT tokens in Keychain
- **Analytics:** AnalyticsManager logs custom events (Codable structs) to SQLite → Supabase sync
- **Localization:** LocalizationManager loads JSON files (de.json POC, en.json Phase 2), no hardcoded strings
- **Offline-First:** GRDB primary source of truth, SyncEngine queues operations, processes on reconnect
- **Error Handling:** AppError hierarchy (DatabaseError, SyncError, ValidationError, AuthError) with Sentry reporting

**Non-Functional Requirements Coverage:**
Performance, security, and quality targets architecturally supported:
- **Performance:** <50ms dashboard load (GRDB indexing on user_id + logged_at), <5% battery (optimized background sync)
- **Reliability:** >99.5% crash-free rate (Sentry SDK monitoring, AppError.report() on all errors)
- **Security:** Supabase Row-Level Security (RLS), Keychain for sensitive tokens, Secrets.xcconfig gitignored
- **Privacy:** Local SQLite primary, cloud sync optional/toggleable, user owns data
- **Accessibility:** Thumb-zone architecture (60/40 split for one-handed use), iOS picker wheels, WCAG 2.1 AA + BITV 2.0 compliance

### Implementation Readiness Validation ✅

**Decision Completeness:**
All critical decisions documented with actionable specifications:
- All 10 core architectural decisions include specific versions (GRDB 7.9.0, Swift 5.9+, iOS 16+, Supabase latest)
- Dependency injection pattern fully specified (default parameters + @StateObject, no factory pattern)
- Error handling flow documented with code examples (catch → error.report() → alert)
- Database migration pattern uses DatabaseMigrator with registerMigration() in GRDBManager
- Localization uses JSON files (Resources/Localizations/de.json), not hardcoded dictionaries

**Structure Completeness:**
Project structure is comprehensive and implementation-ready:
- Complete file tree from root to leaf level (all folders and key files defined)
- All 7 feature modules structured identically (View, ViewModel, ViewModel+Tests, Components/)
- All Core/ modules specified (Database/Migrations/, Services/, CycleEngine/, Models/, Utilities/, Errors/)
- Clear test organization: unit tests co-located, integration tests with Docker Compose PostgreSQL, E2E tests for critical flows
- CI/CD infrastructure defined (docker-compose.yml, GitHub Actions workflows, TestFlight deployment)

**Pattern Completeness:**
Implementation patterns prevent AI agent conflicts:
- 15 potential conflict points identified and resolved (naming, structure, format, communication, process)
- Naming conventions cover all layers: DB (snake_case), Swift types (PascalCase), properties (camelCase), analytics (snake_case past tense)
- Good examples + anti-patterns provided for each pattern category (prevents ambiguity)
- Shared component contract enforced (FireCharacterView presentational only, business logic in ViewModels)
- Enforcement mechanisms: SwiftLint rules, test failures on wrong CodingKeys, PR template pattern checklist

### Gap Analysis Results

**Critical Gaps:** ✅ NONE FOUND
- All implementation-blocking decisions are fully documented
- All consistency-critical patterns are defined with examples
- All required structural elements are specified in detail

**Important Gaps (Non-Blocking, Can Be Addressed in Parallel):**

1. **SwiftLint Configuration File Missing**
   - **Impact:** Naming convention enforcement relies on manual code review without `.swiftlint.yml`
   - **Recommendation:** Create `.swiftlint.yml` with rules for naming (type_name, variable_name, identifier_name)
   - **Priority:** Address before first story implementation to prevent pattern drift

2. **Database Schema Reference Documentation Incomplete**
   - **Impact:** `Docs/DATABASE_SCHEMA.md` referenced in structure but content not written
   - **Recommendation:** Generate from GRDB migrations after first schema is implemented
   - **Priority:** Low (migrations themselves are source of truth)

3. **Sync Protocol Documentation Incomplete**
   - **Impact:** `Docs/SYNC_PROTOCOL.md` referenced but offline-first protocol only documented in code comments
   - **Recommendation:** Write dedicated doc for SyncEngine conflict resolution, retry logic, queue processing
   - **Priority:** Medium (helpful for debugging sync issues, not blocking initial implementation)

**Nice-to-Have Gaps (Optional, Low Priority):**

1. **Migration Code Generation Template** - Scripts/generate-migration.sh creates file but template boilerplate could be richer
2. **Xcode Project Configuration Specification** - Build settings, code signing, entitlements, capabilities not documented
3. **Pre-Commit Git Hooks** - No .git/hooks/pre-commit for automated SwiftLint + unit test runs

**Gap Resolution Plan:**
- Address **Important Gap #1** (SwiftLint config) immediately → prevents pattern drift
- Defer **Important Gaps #2-3** (documentation) → can be written after implementation proves patterns
- Defer **Nice-to-Have Gaps** → optimize later based on team velocity

### Validation Issues Addressed

**No Critical Issues Found** ✅

All validation checks passed:
- ✅ Decision compatibility: All technologies work together without conflicts
- ✅ Pattern consistency: All patterns support architectural decisions
- ✅ Requirements coverage: All epics and NFRs are architecturally supported
- ✅ Implementation readiness: AI agents have sufficient detail for consistent implementation

**Minor Improvements Made During Validation:**
1. Clarified shared component contract (FireCharacterView presentational only) → prevents business logic leakage
2. Added versioned migration folders (v1.0-POC/, v1.1-Phase2/) → prevents folder bloat
3. Added OfflineSyncRecoveryTests.swift E2E test → covers critical data integrity scenario
4. Added CI integration test setup (Docker Compose PostgreSQL) → catches schema drift early

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed (PRD + UX spec extracted, 8-10 components identified)
- [x] Scale and complexity assessed (medium complexity, 10-week POC timeline)
- [x] Technical constraints identified (iOS 16+, Swift 5.9+, TestFlight distribution, German-only POC)
- [x] Cross-cutting concerns mapped (9 identified: MATADOR recovery, thumb-zone UI, offline-first, etc.)

**✅ Architectural Decisions**
- [x] Critical decisions documented with versions (State: SwiftUI native, DB: GRDB 7.9.0, Backend: Supabase, etc.)
- [x] Technology stack fully specified (Swift, SwiftUI, GRDB, Supabase, Sentry via Swift Package Manager)
- [x] Integration patterns defined (offline-first, sync queue, conflict resolution last-write-wins)
- [x] Performance considerations addressed (<50ms dashboard, <5% battery, GRDB indexing strategy)

**✅ Implementation Patterns**
- [x] Naming conventions established (snake_case DB, camelCase Swift, PascalCase types, CodingKeys mapping)
- [x] Structure patterns defined (feature-based organization, co-located tests, versioned migrations)
- [x] Communication patterns specified (@Published, NotificationCenter, EnvironmentObject, TimeProvider protocol)
- [x] Process patterns documented (defer for loading states, error.report() flow, GRDB transactions)

**✅ Project Structure**
- [x] Complete directory structure defined (w-diet/ root to leaf files, all folders specified)
- [x] Component boundaries established (Features/ never import each other, Core/ never imports App/)
- [x] Integration points mapped (ViewModel → Service, Feature → NotificationCenter, EnvironmentObject app-wide state)
- [x] Requirements to structure mapping complete (all 7 epics mapped to specific files/folders)

### Architecture Readiness Assessment

**Overall Status:** ✅ **READY FOR IMPLEMENTATION**

**Confidence Level:** **HIGH**

Rationale:
- Zero critical gaps blocking implementation
- All 10 architectural decisions are specific and actionable (not generic placeholders)
- 15 AI agent conflict points identified and resolved with patterns
- Complete project structure from root to leaf level
- Comprehensive test strategy (unit co-located, integration with Docker, E2E for critical flows)
- Party Mode team review (Winston 9.5/10, Amelia 9.5/10, Murat 10/10) validates quality

**Key Strengths:**

1. **Offline-First Architecture** - GRDB primary source of truth with Supabase sync queue ensures data integrity even during crashes/network failures
2. **Feature-Based Organization** - Prevents "hunt across 5 folders" problem, co-located tests prevent test rot
3. **Testable Time Logic** - TimeProvider protocol enables reliable testing of MATADOR midnight transitions (Day 14 → Day 15)
4. **Shared Component Contracts** - FireCharacterView presentational only prevents business logic leakage, keeps components reusable
5. **Comprehensive Naming Patterns** - CodingKeys bridge snake_case (DB) ↔ camelCase (Swift) prevents serialization bugs
6. **CI Integration Testing** - Docker Compose PostgreSQL catches schema drift between GRDB (SQLite) and Supabase (PostgreSQL) early
7. **Migration Versioning** - v1.0-POC/ and v1.1-Phase2/ folders prevent migration file bloat, clear version boundaries

**Areas for Future Enhancement (Not Blocking):**

1. **SwiftLint Configuration** - Add `.swiftlint.yml` before first story to enforce naming conventions automatically
2. **Sync Protocol Documentation** - Write `Docs/SYNC_PROTOCOL.md` to formalize conflict resolution and retry logic
3. **Database Schema Reference** - Generate `Docs/DATABASE_SCHEMA.md` from migrations after initial implementation
4. **Performance Profiling** - Validate <50ms dashboard target with Instruments after MVP implementation
5. **Accessibility Testing** - User testing with VoiceOver to verify WCAG 2.1 AA compliance beyond BITV 2.0

### Implementation Handoff

**AI Agent Guidelines:**

1. **Follow architectural decisions exactly as documented** - Use GRDB 7.9.0 (not Core Data), SwiftUI native state (not Combine), NavigationStack (not NavigationView deprecated)
2. **Use implementation patterns consistently** - All DB tables snake_case, all Swift types PascalCase, all properties camelCase, define CodingKeys for every Codable model
3. **Respect project structure boundaries** - Features/ never import other features (use Shared/), Core/ never imports App/, tests co-located with {TypeName}+Tests.swift pattern
4. **Refer to this document for architectural questions** - When uncertain about patterns, search architecture.md before making assumptions

**First Implementation Priority:**

**Week 1: Foundation Setup (Before Epic Implementation)**

1. **Create Xcode Project**
   - Use Xcode: File → New → Project → iOS App
   - Name: w-diet
   - Bundle ID: com.w-diet.app (or chosen identifier)
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None (we're using GRDB, not Core Data)

2. **Add Swift Package Dependencies**
   - GRDB.swift 7.9.0: https://github.com/groue/GRDB.swift.git
   - supabase-swift (latest): https://github.com/supabase/supabase-swift.git
   - sentry-cocoa (latest): https://github.com/getsentry/sentry-cocoa.git

3. **Create Project Structure**
   - Scaffold all folders: App/Features/, Core/, Shared/, Resources/, Tests/, Config/, Scripts/, CI/, Docs/
   - Create .gitignore (ignore Secrets.xcconfig, DerivedData, .DS_Store)

4. **Implement Core Foundation (Week 1 Tasks)**
   - Core/Database/GRDBManager.swift - Database singleton with migrations
   - Core/Models/MealLog.swift - First domain model with CodingKeys
   - Core/Utilities/TimeProvider.swift - Protocol + SystemTimeProvider + MockTimeProvider
   - Core/Errors/AppError.swift - Error hierarchy with report() method
   - App/w_dietApp.swift - @main entry point with EnvironmentObject setup
   - Config/Dev.xcconfig - Development environment configuration

5. **First Validation Checkpoint**
   - Run app in Simulator → verify database initializes
   - Write first unit test → verify GRDBManager creates tables
   - Commit foundation → `git commit -m "chore: initialize w-diet project structure"`

**Next Steps After Foundation:**
- Begin Epic 6 (Onboarding) → first user-facing feature, establishes user_profiles
- Then Epic 4 (Dashboard) → validates data aggregation patterns
- Then Epic 2 (Meal Logging) → core value proposition
- Parallel: Epic 1 (MATADOR Cycling) → background service, doesn't block UI work


---

## Architecture Completion Summary

### Workflow Completion

**Architecture Decision Workflow:** COMPLETED ✅
**Total Steps Completed:** 8
**Date Completed:** 2026-01-04
**Document Location:** _bmad-output/planning-artifacts/architecture.md

### Final Architecture Deliverables

**📋 Complete Architecture Document**

- All architectural decisions documented with specific versions
- Implementation patterns ensuring AI agent consistency
- Complete project structure with all files and directories
- Requirements to architecture mapping
- Validation confirming coherence and completeness

**🏗️ Implementation Ready Foundation**

- 10 architectural decisions made
- 15 implementation pattern conflict points resolved
- 12 architectural components specified (7 features + 5 Core modules)
- 7 epics fully supported

**📚 AI Agent Implementation Guide**

- Technology stack with verified versions (GRDB 7.9.0, Swift 5.9+, iOS 16+, Supabase, Sentry)
- Consistency rules that prevent implementation conflicts (naming, structure, communication, process patterns)
- Project structure with clear boundaries (feature-based organization, Core/ isolation)
- Integration patterns and communication standards (offline-first, sync queue, TimeProvider)

### Implementation Handoff

**For AI Agents:**
This architecture document is your complete guide for implementing w-diet. Follow all decisions, patterns, and structures exactly as documented.

**First Implementation Priority:**

**Week 1: Foundation Setup**

1. Create Xcode Project (iOS App, SwiftUI, Swift, no Core Data)
2. Add Swift Package Manager dependencies (GRDB 7.9.0, supabase-swift, sentry-cocoa)
3. Scaffold project structure (App/Features/, Core/, Shared/, Resources/, Tests/, Config/, Scripts/)
4. Implement core foundation:
   - Core/Database/GRDBManager.swift
   - Core/Models/MealLog.swift
   - Core/Utilities/TimeProvider.swift
   - Core/Errors/AppError.swift
   - App/w_dietApp.swift
   - Config/Dev.xcconfig

**Development Sequence:**

1. Initialize project using documented starter template approach (custom Xcode project)
2. Set up development environment per architecture (Dev.xcconfig, Secrets.xcconfig template)
3. Implement core architectural foundations (GRDBManager, error hierarchy, TimeProvider)
4. Build features following established patterns (Epic 6 Onboarding → Epic 4 Dashboard → Epic 2 Meal Logging)
5. Maintain consistency with documented rules (naming conventions, CodingKeys, co-located tests)

### Quality Assurance Checklist

**✅ Architecture Coherence**

- [x] All decisions work together without conflicts
- [x] Technology choices are compatible (Swift 5.9+ + SwiftUI + GRDB + Supabase + Sentry)
- [x] Patterns support the architectural decisions (naming, DI, error handling, state management)
- [x] Structure aligns with all choices (feature-based, versioned migrations, co-located tests)

**✅ Requirements Coverage**

- [x] All functional requirements are supported (7 epics mapped to architecture)
- [x] All non-functional requirements are addressed (performance, security, privacy, accessibility, reliability)
- [x] Cross-cutting concerns are handled (auth, analytics, localization, offline-first, error handling)
- [x] Integration points are defined (ViewModel → Service, Feature → NotificationCenter, EnvironmentObject)

**✅ Implementation Readiness**

- [x] Decisions are specific and actionable (versions specified, code examples provided)
- [x] Patterns prevent agent conflicts (15 conflict points resolved with explicit rules)
- [x] Structure is complete and unambiguous (root to leaf file tree defined)
- [x] Examples are provided for clarity (good examples + anti-patterns for each pattern)

### Project Success Factors

**🎯 Clear Decision Framework**
Every technology choice was made collaboratively with clear rationale (Party Mode team review: Winston 9.5/10, Amelia 9.5/10, Murat 10/10), ensuring all stakeholders understand the architectural direction.

**🔧 Consistency Guarantee**
Implementation patterns and rules ensure that multiple AI agents will produce compatible, consistent code that works together seamlessly (CodingKeys mapping, naming conventions, shared component contracts).

**📋 Complete Coverage**
All project requirements are architecturally supported, with clear mapping from business needs to technical implementation (7 epics → specific files/folders/tables).

**🏗️ Solid Foundation**
The chosen custom Xcode project approach with borrowed patterns from SwiftUI Indie Stack provides a production-ready foundation following current best practices (offline-first, feature-based organization, testable time logic).

---

**Architecture Status:** READY FOR IMPLEMENTATION ✅

**Next Phase:** Begin implementation using the architectural decisions and patterns documented herein.

**Document Maintenance:** Update this architecture when major technical decisions are made during implementation.

