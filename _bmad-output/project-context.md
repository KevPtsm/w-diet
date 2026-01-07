---
project_name: 'w-diet'
user_name: 'Kevin'
date: '2026-01-04'
sections_completed: ['technology_stack', 'critical_rules', 'party_mode_review']
existing_patterns_found: 15
critical_rules_count: 11
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

**Core Technologies:**
- Swift 5.9+
- SwiftUI (iOS 16+ minimum, iPhone 12 and newer)
- GRDB.swift 7.9.0 (local SQLite database)
- Supabase Swift SDK (PostgreSQL sync + Auth)
- Sentry SDK (crash monitoring + error reporting)
- Swift Package Manager (dependency management)

**Architecture Patterns:**
- State Management: SwiftUI Native (@Published + @StateObject + EnvironmentObject)
- Navigation: NavigationStack (iOS 16+, NOT NavigationView)
- Dependency Injection: Hybrid (default parameters + EnvironmentObject for singletons)
- Database: GRDB DatabaseMigrator pattern (append-only migrations)
- Localization: JSON-based (German POC, English Phase 2)
- Error Handling: AppError hierarchy with .report() to analytics + Sentry

**Project Structure:**
- Feature-based organization (NOT type-based)
- Co-located tests: `{TypeName}+Tests.swift` next to implementation
- Versioned migrations: `Core/Database/Migrations/v1.0-POC/`
- Offline-first: GRDB primary source of truth, Supabase secondary sync

---

## 🚨 CRITICAL IMPLEMENTATION RULES (Non-Negotiable)

### 1. StateObject Initialization - RUNTIME CRASH RISK

**❌ NEVER DO THIS (crashes at runtime):**
```swift
struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel

    init() {
        self._viewModel = StateObject(wrappedValue: DashboardViewModel())  // CRASH!
    }
}
```

**✅ ALWAYS DO THIS:**
```swift
struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()  // No init needed
}
```

**Why:** `@StateObject` cannot be initialized inside a View's `init()`. SwiftUI manages the lifecycle. Initialize directly in the property declaration.

---

### 2. CodingKeys Are MANDATORY for All Codable Models

**❌ WRONG (silently fails PostgreSQL sync):**
```swift
struct MealLog: Codable {
    let mealName: String  // Won't match meal_name in database
    let caloriesKcal: Int
}
```

**✅ REQUIRED PATTERN:**
```swift
struct MealLog: Codable {
    let mealName: String
    let caloriesKcal: Int

    enum CodingKeys: String, CodingKey {
        case mealName = "meal_name"       // snake_case in DB
        case caloriesKcal = "calories_kcal"
    }
}
```

**Why:** Database uses `snake_case`, Swift uses `camelCase`. Without explicit CodingKeys, sync silently fails. EVERY Codable model that touches PostgreSQL MUST have CodingKeys.

---

### 3. TimeProvider Protocol - REQUIRED for ALL Date Logic

**❌ UNTESTABLE (breaks MATADOR midnight tests):**
```swift
func calculatePhase() -> CyclePhase {
    let now = Date()  // Hardcoded date - can't mock
    // ...
}
```

**✅ ALWAYS USE TimeProvider:**
```swift
func calculatePhase() -> CyclePhase {
    let now = timeProvider.now  // Injectable for tests
    // ...
}

// In class/struct
private let timeProvider: TimeProvider

init(timeProvider: TimeProvider = SystemTimeProvider()) {
    self.timeProvider = timeProvider
}
```

**Why:** MATADOR cycle transitions happen at midnight. Without TimeProvider, you cannot test Day 14 → Day 15 phase switches. This is critical for MATADOR fail-safe recovery logic.

---

### 4. Loading States MUST Use defer

**❌ WRONG (loading stuck if operation throws):**
```swift
func fetchData() async {
    isLoading = true
    try await operation()
    isLoading = false  // Never reached if throws!
}
```

**✅ ALWAYS USE defer:**
```swift
func fetchData() async {
    isLoading = true
    defer { isLoading = false }  // Resets even on error

    do {
        try await operation()
    } catch {
        // Handle error
    }
}
```

**Why:** If async operation throws, loading state stays true forever. UI shows infinite spinner. defer guarantees loading state is reset.

---

### 5. Co-Located Tests Are Mandatory

**❌ FORBIDDEN (breaks feature cohesion):**
```
Tests/
  DashboardViewModelTests.swift  // Separate folder
```

**✅ REQUIRED PATTERN:**
```
App/Features/Dashboard/
  DashboardView.swift
  DashboardViewModel.swift
  DashboardViewModel+Tests.swift  // Co-located with implementation
```

**Why:** Prevents test rot. When refactoring `DashboardViewModel.swift`, the test file is right there, impossible to miss. Separate Tests/ folders lead to forgotten tests.

---

### 6. Feature Isolation Boundary - NO Cross-Feature Imports

**❌ FORBIDDEN (creates circular dependencies):**
```swift
// In DashboardView.swift
import MealLogging  // NEVER import another feature!
```

**✅ USE Shared/ Components or NotificationCenter:**
```swift
// Cross-feature communication via events
NotificationCenter.default.post(name: .mealLogged, object: nil, userInfo: ["mealId": id])

// Or use Shared/ components
import Shared  // OK - shared components are reusable
```

**Why:** Features must be isolated. `Core/` never imports `App/`, Features never import other Features. Use Shared/ for reusable UI, NotificationCenter for events.

---

### 7. Shared Components Are Presentational ONLY

**❌ FORBIDDEN (business logic in shared component):**
```swift
struct FireCharacterView: View {
    let macroProgress: Double

    var variation: FireVariation {
        macroProgress >= 0.7 ? .happy : .concerned  // NO! Business logic!
    }
}
```

**✅ REQUIRED PATTERN (presentational only):**
```swift
// Shared/Components/FireCharacter/FireCharacterView.swift
struct FireCharacterView: View {
    let variation: FireVariation  // Takes enum, no calculation
    let size: CGFloat

    var body: some View {
        Image(variation.imageName)
            .resizable()
            .frame(width: size, height: size)
    }
}

// Business logic stays in ViewModel
class DashboardViewModel: ObservableObject {
    @Published var fireVariation: FireVariation = .happy

    func updateFire() {
        fireVariation = macroProgress >= 0.7 ? .happy : .concerned
    }
}
```

**Why:** Shared components must stay "dumb" and reusable. Business logic in shared components creates coupling and prevents reuse.

---

### 8. GRDB Migrations - Registration Pattern Only

**❌ FORBIDDEN (direct table creation):**
```swift
try db.create(table: "meal_logs") { ... }  // Anywhere outside GRDBManager
```

**✅ REQUIRED PATTERN (register in GRDBManager):**
```swift
// Core/Database/GRDBManager.swift
private func setupMigrations() -> DatabaseMigrator {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("v1_create_meal_logs") { db in
        try db.create(table: "meal_logs") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("user_id", .text).notNull()
            t.column("meal_name", .text).notNull()
            // ...
        }
        try db.create(index: "idx_meal_logs_user_id", on: "meal_logs", columns: ["user_id"])
    }

    return migrator
}
```

**Why:** Migrations are append-only. All schema changes MUST be registered via `migrator.registerMigration()`. Never create tables directly. This ensures migrations run in correct order and are idempotent.

---

### 9. E2E Test for Offline Sync Recovery - NON-NEGOTIABLE

**✅ REQUIRED TEST (prevents production data loss):**
```swift
func testOfflineSyncRecovery() async throws {
    // 1. Log meal offline
    networkMonitor.isConnected = false
    try await viewModel.saveMealLog(mealLog)

    // Verify saved locally
    let localLogs = try await dbManager.fetchMealLogs()
    XCTAssertEqual(localLogs.count, 1)

    // 2. Simulate app crash
    app.terminate()

    // 3. Relaunch app online
    app.launch()
    networkMonitor.isConnected = true

    // 4. Verify sync queue processed
    try await Task.sleep(nanoseconds: 2_000_000_000)  // Wait for sync
    let syncedLogs = try await supabase.from("meal_logs").select().execute()
    XCTAssertEqual(syncedLogs.count, 1)
}
```

**Why:** This is the #1 failure mode for offline-first apps. Without this test, offline → crash → online sync WILL break in production, causing data loss. Test MUST exist in `Tests/E2ETests/OfflineSyncRecoveryTests.swift`.

---

### 10. TimeProvider Injection in ALL Tests

**❌ FLAKY TEST (depends on real time):**
```swift
func testPhaseSwitch() {
    cycleEngine.startCycle(startDate: Date())
    // Fails if run at different times
}
```

**✅ REQUIRED PATTERN:**
```swift
func testPhaseSwitch() {
    let timeProvider = MockTimeProvider(fixedDate: "2026-01-01T00:00:00Z")
    let cycleEngine = CycleEngine(timeProvider: timeProvider)

    cycleEngine.startCycle(startDate: timeProvider.now)

    // Simulate Day 14 → Day 15 transition
    timeProvider.advance(days: 14)
    XCTAssertEqual(cycleEngine.currentPhase, .maintenance)

    // Test midnight transition
    timeProvider.setTime(hour: 23, minute: 59, second: 59)
    XCTAssertEqual(cycleEngine.daysRemainingInPhase, 0)

    timeProvider.advance(seconds: 1)  // Midnight
    XCTAssertEqual(cycleEngine.currentPhase, .diet)
}
```

**Why:** MATADOR logic is date-dependent. Real Date() makes tests flaky. MockTimeProvider allows testing midnight transitions, Day 14 → Day 15 switches, timezone changes.

---

### 11. Integration Tests MUST Use Docker Compose PostgreSQL

**❌ FORBIDDEN (mocking hides schema drift):**
```swift
let mockSupabase = MockSupabaseService()  // Don't mock!
```

**✅ REQUIRED SETUP:**
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
```

```swift
// Tests/IntegrationTests/DatabaseSyncTests.swift
func testGRDBToSupabaseSync() async throws {
    // Uses REAL PostgreSQL container, not mocks
    let mealLog = MealLog(...)
    try await dbManager.saveMealLog(mealLog)  // GRDB SQLite
    try await syncEngine.sync()  // Supabase PostgreSQL

    let synced = try await supabase.from("meal_logs").select().execute()
    XCTAssertEqual(synced.count, 1)
}
```

**Why:** Schema drift between GRDB (SQLite) and Supabase (PostgreSQL) is a common failure mode. Mocking hides this. Real PostgreSQL container catches issues early (e.g., GRDB uses `.datetime`, PostgreSQL uses `TIMESTAMPTZ`).

---

## 📋 Additional Critical Patterns

### Naming Conventions Summary

- **Database:** `snake_case` (tables: `meal_logs`, columns: `user_id`, indexes: `idx_meal_logs_user_id`)
- **Swift Types:** `PascalCase` (classes, structs, enums, protocols)
- **Swift Properties/Functions:** `camelCase`
- **Analytics Events:** `snake_case` past tense (`meal_logged`, `phase_switched`)
- **Files:** Match type name exactly (`DashboardViewModel.swift`)
- **Extensions:** `{TypeName}+{Functionality}.swift` (`Date+MATADOR.swift`)
- **Tests:** `{TypeName}+Tests.swift` (co-located with implementation)

### Error Handling Pattern

```swift
do {
    try await operation()
} catch let error as AppError {
    error.report()  // Logs to both analytics + Sentry
    self.errorMessage = error.userMessage
}
```

**EVERY error must call `.report()`** - this ensures >99.5% crash-free rate target.

### Migration File Naming

```
Core/Database/Migrations/v1.0-POC/
  Migration_20260103_120000_CreateMealLogsTable.swift
  Migration_20260104_093000_AddCycleStateRecovery.swift
```

Use `Scripts/generate-migration.sh` to create migrations with unique timestamps.

---

## 🎯 Architecture Quick Reference

**Offline-First Priority:**
1. GRDB (SQLite) is ALWAYS the primary source of truth
2. Supabase (PostgreSQL) is secondary sync, optional
3. App MUST work 100% offline (no internet dependency)

**Dependency Flow:**
- `App/` imports `Core/` and `Shared/`
- `Core/` NEVER imports `App/`
- Features NEVER import other Features
- Shared components are presentational only (no business logic)

**State Management:**
- `@StateObject` for feature ViewModels (created by View)
- `@EnvironmentObject` for app-wide singletons (GRDBManager, CycleEngine, SupabaseClient)
- `@Published` for ViewModel state that triggers View updates
- Default parameters for DI (production uses singletons, tests inject mocks)

**Testing Strategy:**
- Unit tests co-located: `{TypeName}+Tests.swift`
- Integration tests with Docker PostgreSQL: `Tests/IntegrationTests/`
- E2E tests for critical flows: `Tests/E2ETests/` (MUST include OfflineSyncRecoveryTests)
- TimeProvider injection for all date-dependent logic

---

## ⚠️ Common AI Agent Mistakes

1. **Forgetting CodingKeys** - sync silently fails
2. **Initializing @StateObject in init** - runtime crash
3. **Using Date() instead of TimeProvider** - untestable MATADOR logic
4. **Missing defer for loading states** - infinite spinners
5. **Putting tests in Tests/ folder** - test rot
6. **Cross-importing Features** - circular dependencies
7. **Business logic in Shared/ components** - coupling
8. **Direct table creation outside migrations** - schema corruption
9. **Mocking Supabase in integration tests** - schema drift undetected
10. **No offline sync recovery E2E test** - production data loss

---

---

## 🎨 UI/UX Design System

### CRITICAL RULE: Always Reference UX Documentation

**❌ NEVER hardcode UI colors or styles without checking UX doc:**
```swift
Button("Continue") {
    // ...
}
.foregroundColor(.blue)  // WRONG! Use Theme constants
```

**✅ ALWAYS use Theme.swift constants and reference UX document:**
```swift
Button("Continue") {
    // ...
}
.foregroundColor(Theme.fireGold)  // Correct! From Theme.swift
```

**Rule:** Before implementing ANY UI element (button, card, text, icon, etc.):
1. Check `_bmad-output/planning-artifacts/ux-design-specification.md` for design guidance
2. Use color constants from `Core/Theme/Theme.swift` (NEVER use Color.blue, Color.red, etc.)
3. Follow spacing, typography, and component patterns defined in UX doc

**Why:** Consistent design system across the app. The UX document defines the fire-inspired Fire Gold (#F4A460) color palette, typography scales, component patterns, and spacing system. Using hardcoded colors or ignoring the UX doc creates visual inconsistency.

**Theme Constants Available:**
- Primary: `Theme.fireGold` (#F4A460), `Theme.energyOrange` (#FF6B35)
- Text: `Theme.textPrimary`, `Theme.textSecondary`, `Theme.textTertiary`
- Background: `Theme.backgroundPrimary`, `Theme.backgroundSecondary`
- Semantic: `Theme.success`, `Theme.warning`, `Theme.error`, `Theme.info`
- Grays: `Theme.gray100` through `Theme.gray500`
- MATADOR: `Theme.maintenancePhase` (green), `Theme.deficitPhase` (blue)

---

**Last Updated:** 2026-01-06
**Architecture Document:** `_bmad-output/planning-artifacts/architecture.md`
**UX Design Document:** `_bmad-output/planning-artifacts/ux-design-specification.md`
**Party Mode Review:** Amelia (Developer), Winston (Architect), Murat (Test Architect)
