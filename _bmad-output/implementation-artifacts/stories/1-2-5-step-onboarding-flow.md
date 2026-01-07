# Story 1.2: 5-Step Onboarding Flow

**Story ID:** 1-2-5-step-onboarding-flow
**Epic:** Epic 1 - Get Started - Onboarding & First Login
**Status:** ready-for-dev
**Created:** 2026-01-06

---

## Summary

Create an interactive 5-step onboarding flow that collects user preferences (goal, calorie target, eating window) and educates them about the MATADOR cycle. The flow should feel conversational, use tooltips to explain concepts, and end with a reveal transition to the main dashboard.

---

## User Story

**As a** new user who just authenticated
**I want to** complete a simple onboarding flow that asks about my goals and explains MATADOR
**So that** I understand how the app works and have my preferences configured for personalized tracking

---

## Acceptance Criteria

### 1. Step 1: Goal Selection
- [ ] Show screen with headline "What's your main goal?"
- [ ] Display 3 options as large, tappable cards:
  - "Lose Weight" (with icon)
  - "Maintain Weight" (with icon)
  - "Gain Muscle" (with icon)
- [ ] Show tooltip button that explains MATADOR works for all goals
- [ ] Selection highlights the card and enables "Continue" button
- [ ] Selected goal is stored in user preferences

### 2. Step 2: Calorie Target Input
- [ ] Show headline "How many calories per day?"
- [ ] Display subtitle "We'll calculate your macros automatically"
- [ ] Show numeric text field with keyboard optimized for numbers
- [ ] Pre-fill with reasonable default based on goal (2000 kcal for maintain/muscle, 1800 for weight loss)
- [ ] Show tooltip explaining why calories matter during feeding days
- [ ] Input is validated (must be > 0, reasonable range 1000-4000)
- [ ] Calorie target is stored in user preferences

### 3. Step 3: Eating Window Selection
- [ ] Show headline "When do you usually eat?"
- [ ] Display subtitle "Choose your typical eating hours"
- [ ] Show time range picker (e.g., iOS dual wheel picker)
- [ ] Pre-fill with 12:00 PM - 8:00 PM (8-hour window)
- [ ] Calculate and display eating window duration (e.g., "8 hours")
- [ ] Show tooltip explaining eating windows help track feeding days
- [ ] Eating window is stored in user preferences

### 4. Step 4: MATADOR Explainer
- [ ] Show headline "What is MATADOR?"
- [ ] Display simple visual diagram showing the cycle pattern:
  - 5 days feeding (green)
  - 2 days fasting (blue)
  - Repeat
- [ ] Show 2-3 bullet points explaining benefits
- [ ] Include tooltip for "Why does this work?"
- [ ] "Continue" button always enabled (no input required)

### 5. Step 5: Dashboard Reveal
- [ ] Show headline "You're all set!"
- [ ] Display confirmation message with personalized summary:
  - "Goal: [selected goal]"
  - "Daily target: [calories] kcal"
  - "Eating window: [start] - [end]"
- [ ] Show animated fire character giving thumbs up or roar animation
- [ ] "Start Tracking" button triggers transition to dashboard
- [ ] On button press, mark onboarding as complete in UserProfile
- [ ] Animate transition to DashboardView (slide or fade)

### 6. Navigation & Progress
- [ ] Show progress indicator at top (e.g., "Step 2 of 5" or dots)
- [ ] Back button on steps 2-5 to return to previous step
- [ ] No way to skip or dismiss onboarding until complete
- [ ] State is preserved if app is backgrounded

### 7. Tooltips
- [ ] All tooltips use consistent design (info icon → popover/sheet)
- [ ] Tooltips can be dismissed by tapping outside or close button
- [ ] Tooltip content is educational, not technical
- [ ] Examples:
  - "MATADOR works by cycling between feeding and fasting days, helping maintain metabolism"
  - "During feeding days, hit your calorie target to preserve muscle"
  - "Eating windows help you track when you're in feeding mode"

### 8. Data Persistence
- [ ] All inputs saved to local SQLite (user_profiles table)
- [ ] New columns added if needed: goal, calorie_target, eating_window_start, eating_window_end
- [ ] Onboarding completion flag stored: onboarding_completed (BOOLEAN)
- [ ] Data is queued for cloud sync but onboarding doesn't wait for it

### 9. Error Handling
- [ ] If database write fails, show error alert and allow retry
- [ ] If app crashes mid-onboarding, resume from last completed step on relaunch
- [ ] Validation errors show inline (e.g., "Calorie target must be at least 1000")

### 10. Testing Requirements
- [ ] Unit tests for onboarding state machine (step transitions)
- [ ] Unit tests for input validation
- [ ] Unit tests for data persistence to UserProfile
- [ ] UI tests for complete happy path (all 5 steps → dashboard)
- [ ] UI tests for back navigation
- [ ] UI tests for tooltip interactions

---

## Technical Requirements

### Architecture

1. **View Structure:**
   ```
   OnboardingContainerView (NavigationStack)
   ├── OnboardingViewModel (@StateObject)
   ├── ProgressIndicator
   └── Content (based on currentStep):
       ├── Step1GoalSelectionView
       ├── Step2CalorieTargetView
       ├── Step3EatingWindowView
       ├── Step4MatadorExplainerView
       └── Step5CompletionView
   ```

2. **ViewModel Pattern:**
   - `OnboardingViewModel: ObservableObject`
   - `@MainActor` for all UI updates
   - Published properties: `currentStep`, `selectedGoal`, `calorieTarget`, `eatingWindowStart`, `eatingWindowEnd`
   - Methods: `nextStep()`, `previousStep()`, `completeOnboarding()`

3. **Database Schema Changes:**
   Add to `user_profiles` table:
   ```sql
   goal TEXT,
   calorie_target INTEGER,
   eating_window_start TEXT, -- HH:mm format
   eating_window_end TEXT,   -- HH:mm format
   onboarding_completed BOOLEAN DEFAULT 0
   ```

4. **Navigation Logic:**
   - In `w_dietApp.swift`, check `AuthManager.shared.isAuthenticated` AND `onboardingCompleted`
   - If authenticated but not onboarded → show `OnboardingContainerView`
   - If authenticated and onboarded → show `DashboardView`
   - If not authenticated → show auth screen (defer to future story)

---

## Developer Context & Guardrails

### From Story 1.1 Learnings

1. **Xcode Project Configuration:**
   - ✅ Test files MUST go in `w-dietTests` target (NOT `w-diet`)
   - ✅ Use `project.pbxproj` to verify correct target membership
   - ✅ Run build after adding files to catch target errors early

2. **GRDB Patterns:**
   - ✅ Use `CodingKeys` enum to map Swift camelCase ↔ DB snake_case
   - ✅ Always implement `FetchableRecord` and `PersistableRecord`
   - ✅ Use `GRDBManager.shared` for database access
   - ✅ Wrap all DB operations in `try await dbManager.write { }` or `dbManager.read { }`

3. **Test Patterns:**
   - ✅ Use `GRDBManager.makeTestDatabase()` in test `setUp()`
   - ✅ Always call `try dbManager.eraseAll()` in test `tearDown()`
   - ✅ Force unwrap GRDB subscripts: `row?["column"] as! Type`
   - ✅ Test both CRUD operations AND constraint violations

4. **SwiftUI Architecture:**
   - ✅ ViewModels must be `@MainActor`
   - ✅ Use `@StateObject` for ViewModel in View (NOT in `init()`)
   - ✅ Published properties for reactive UI updates
   - ✅ Use `.task { }` modifier for async loading

5. **Error Handling:**
   - ✅ All errors wrapped in `AppError.auth()` or `AppError.database()`
   - ✅ Call `.report()` to send to Sentry
   - ✅ Display user-friendly messages via `.alert()` modifier

### Critical Rules from Existing Codebase

1. **Supabase Integration:**
   - Configuration: `AppConfiguration.supabaseURL` and `.supabaseAnonKey`
   - Client singleton pattern (see `AuthManager.shared`)
   - Session storage in Keychain (NEVER UserDefaults)

2. **Database Migration Pattern:**
   - Add migration in `GRDBManager.swift` under `migrator.registerMigration("v2")`
   - Use `ALTER TABLE` for new columns
   - Always provide `DEFAULT` values for non-null columns
   - Test migrations with in-memory database first

3. **SwiftUI Patterns:**
   - Navigation: `NavigationStack` (NOT deprecated NavigationView)
   - Dependency injection: Pass `GRDBManager` and `TimeProvider` in ViewModel init
   - Loading states: Use `.overlay { if isLoading { ProgressView() } }`
   - Error alerts: Bind to `errorMessage != nil`

4. **File Organization:**
   ```
   w-diet/
   ├── App/
   │   └── Features/
   │       └── Onboarding/
   │           ├── OnboardingContainerView.swift
   │           ├── OnboardingViewModel.swift
   │           ├── Views/
   │           │   ├── Step1GoalSelectionView.swift
   │           │   ├── Step2CalorieTargetView.swift
   │           │   ├── Step3EatingWindowView.swift
   │           │   ├── Step4MatadorExplainerView.swift
   │           │   └── Step5CompletionView.swift
   │           └── OnboardingViewModel+Tests.swift (in w-dietTests)
   ├── Core/
   │   └── Models/
   │       └── UserProfile.swift (extend with new properties)
   ```

5. **Testing Strategy:**
   - One test file per ViewModel: `OnboardingViewModel+Tests.swift`
   - UI test file: `OnboardingUITests.swift` in w-dietUITests
   - Test database schema changes separately

---

## Implementation Checklist

### Phase 1: Database Schema & Model
- [ ] Add migration `v2` to `GRDBManager.swift` with new columns
- [ ] Extend `UserProfile` model with new properties:
  - `goal: String?`
  - `calorieTarget: Int?`
  - `eatingWindowStart: String?`
  - `eatingWindowEnd: String?`
  - `onboardingCompleted: Bool`
- [ ] Add `CodingKeys` mappings for new fields
- [ ] Write unit tests for new UserProfile fields

### Phase 2: ViewModel & State Management
- [ ] Create `OnboardingViewModel.swift`
- [ ] Implement state properties (currentStep, inputs)
- [ ] Implement step navigation methods
- [ ] Implement validation logic
- [ ] Implement `completeOnboarding()` method (save to DB)
- [ ] Write unit tests for OnboardingViewModel

### Phase 3: UI Views
- [ ] Create `OnboardingContainerView.swift` with progress indicator
- [ ] Create `Step1GoalSelectionView.swift`
- [ ] Create `Step2CalorieTargetView.swift`
- [ ] Create `Step3EatingWindowView.swift`
- [ ] Create `Step4MatadorExplainerView.swift`
- [ ] Create `Step5CompletionView.swift`
- [ ] Implement tooltip component (reusable)

### Phase 4: Integration
- [ ] Update `w_dietApp.swift` to show onboarding for new users
- [ ] Test navigation flow: onboarding → dashboard
- [ ] Test back navigation between steps
- [ ] Test state persistence on app backgrounding

### Phase 5: Testing
- [ ] Run unit tests (ViewModel + Model)
- [ ] Write UI tests for happy path
- [ ] Write UI tests for edge cases (back nav, validation)
- [ ] Manual testing on simulator

### Phase 6: Polish
- [ ] Add animations for step transitions
- [ ] Add fire character animation on Step 5
- [ ] Test on different screen sizes (iPhone SE, Pro Max)
- [ ] Verify accessibility (VoiceOver labels)

---

## Definition of Done

- [ ] All acceptance criteria met and verified
- [ ] All unit tests passing
- [ ] All UI tests passing
- [ ] Code builds without warnings
- [ ] Manual testing completed on simulator
- [ ] Database migration tested (fresh install + upgrade path)
- [ ] Error scenarios handled gracefully
- [ ] Code follows existing patterns from Story 1.1
- [ ] No crashes or memory leaks detected
- [ ] Ready for code review

---

## Dependencies

- **Requires:** Story 1.1 (User Authentication) - complete ✅
- **Blocks:** Story 1.3 (Dashboard Shell) - onboarding must complete before dashboard

---

## Open Questions

None - all requirements clear from PRD and Epic definition.

---

## Notes

- Fire character can be a simple SF Symbol initially (e.g., `flame.fill`), placeholder for future custom asset
- Tooltip design can reuse SwiftUI `.popover()` or `.sheet()` for simplicity
- Time picker should use iOS native `DatePicker` with `.hourAndMinute` mode
- Consider adding "Skip for now" option in future iteration (not MVP)
