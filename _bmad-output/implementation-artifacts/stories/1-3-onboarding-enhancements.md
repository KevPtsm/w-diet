# Story 1.3: Onboarding Flow Enhancements

**Story ID:** 1.3
**Epic:** Epic 1 - Initial Onboarding
**Status:** ready-for-dev
**Created:** 2026-01-06

## User Story

As a new user, I want an enhanced onboarding experience with accurate MATADOR cycle information and personalized calorie calculations, so that I can properly configure my diet plan with the correct expectations.

## Context

Story 1.2 implemented the basic 5-step onboarding flow, which is functional and working. This story enhances the onboarding with:
- More accurate user profile data collection (gender, height, weight, activity level)
- Proper MATADOR cycle visualization (2-week cycles instead of incorrect 5-day/2-day)
- Better goal state management ("Coming Soon" for unsupported goals)
- Improved intermittent fasting window selection
- Calorie calculation based on user metrics

## Acceptance Criteria

### Step 1: Goal Selection (Enhanced)
- [ ] "Maintain Weight" goal card shows "Coming Soon" badge and is disabled
- [ ] "Gain Muscle" goal card shows "Coming Soon" badge and is disabled
- [ ] "Lose Weight" is the only selectable/functional goal
- [ ] Cards are visually greyed out when disabled
- [ ] Continue button only enables when "Lose Weight" is selected

### Step 2: Gender Selection (NEW)
- [ ] New step asks for user gender (Male/Female/Other)
- [ ] Include explanation text: "Gender helps us calculate accurate calorie recommendations"
- [ ] Visual card selection interface (similar to goal cards)
- [ ] Continue button only enables when gender selected

### Step 3: Height Input (NEW)
- [ ] TextField for height input with unit selector (cm/feet+inches)
- [ ] Validation: Height must be between 120-250 cm (or equivalent in feet)
- [ ] Clear label: "What's your height?"
- [ ] Input keyboard shows numeric keypad

### Step 4: Weight Input (NEW)
- [ ] TextField for weight input with unit selector (kg/lbs)
- [ ] Validation: Weight must be between 40-200 kg (or equivalent in lbs)
- [ ] Clear label: "What's your current weight?"
- [ ] Input keyboard shows numeric keypad

### Step 5: Activity Level (NEW)
- [ ] Card selection for activity level:
  - Sedentary (little to no exercise)
  - Lightly Active (1-3 days/week)
  - Moderately Active (3-5 days/week)
  - Very Active (6-7 days/week)
  - Extremely Active (athlete/physical job)
- [ ] Each card shows description of activity level
- [ ] Continue button only enables when activity level selected

### Step 6: Calorie Target (Modified from old Step 2)
- [ ] Calculate recommended calories using Mifflin-St Jeor equation based on:
  - Gender
  - Height
  - Weight
  - Activity level
  - Goal (deficit for weight loss)
- [ ] Show calculated recommendation prominently
- [ ] Allow user to adjust the value
- [ ] Validation: 1000-4000 kcal range
- [ ] Show explanation of calculation

### Step 7: MATADOR Explainer (Modified from old Step 4)
- [ ] **CRITICAL FIX:** Change cycle explanation from "5 days + 2 days" to "2 weeks + 2 weeks"
- [ ] Visualization shows 1 MONTH (4 weeks) timeline
- [ ] First 2 weeks shown in GREEN (maintenance/refeed)
- [ ] Last 2 weeks shown in BLUE (calorie deficit)
- [ ] Key benefits prominently displayed:
  - "Lose more weight overall"
  - "Maintain weight loss long-term"
- [ ] Add link at bottom: "Read the research study" → [MATADOR Study Link]
- [ ] Clear title: "How MATADOR Works"
- [ ] Remove eating window references (that's next step)

### Step 8: Eating Window (Modified from old Step 3)
- [ ] Reframe as "Intermittent Fasting Window"
- [ ] Time picker allows 6-hour window selection
- [ ] **Recommended window: 12:00 - 18:00 (6 hours)**
- [ ] Show benefits of 18-hour fasting
- [ ] Visual indicator showing fasting/eating periods
- [ ] Update text: "Choose your 6-hour eating window" (not "when do you usually eat")
- [ ] Info tooltip explaining intermittent fasting benefits

### Step 9: Completion (Same as old Step 5)
- [ ] Summary shows:
  - Goal
  - Daily calorie target
  - Eating window
- [ ] "Start Tracking" button
- [ ] Transitions to dashboard after completion

## Technical Requirements

### Database Schema Updates
```swift
// Add to UserProfile model
let gender: String?                    // "male", "female", "other"
let heightCm: Double?                  // Height in centimeters
let weightKg: Double?                  // Weight in kilograms
let activityLevel: String?             // "sedentary", "lightly_active", etc.
let calculatedCalories: Int?           // Calculated recommendation
```

### Migration
- Create v3 migration to add new columns to `user_profiles` table
- All columns nullable for backwards compatibility

### Calorie Calculation
- Implement Mifflin-St Jeor equation:
  - Men: (10 × weight in kg) + (6.25 × height in cm) - (5 × age) + 5
  - Women: (10 × weight in kg) + (6.25 × height in cm) - (5 × age) - 161
- Apply activity multiplier:
  - Sedentary: BMR × 1.2
  - Lightly Active: BMR × 1.375
  - Moderately Active: BMR × 1.55
  - Very Active: BMR × 1.725
  - Extremely Active: BMR × 1.9
- For weight loss: Subtract 500 kcal from TDEE (default)

### New View Files
- `Step2GenderSelectionView.swift`
- `Step3HeightInputView.swift`
- `Step4WeightInputView.swift`
- `Step5ActivityLevelView.swift`

### Modified View Files
- `Step1GoalSelectionView.swift` - Add "Coming Soon" badges and disable non-losewait cards
- `Step4MatadorExplainerView.swift` - Fix cycle visualization (2 weeks + 2 weeks)
- `Step3EatingWindowView.swift` → rename to `Step8EatingWindowView.swift` - Reframe as IF window
- `Step2CalorieTargetView.swift` → rename to `Step6CalorieTargetView.swift` - Add calculation display

### ViewModel Updates
- Add properties: gender, heightCm, weightKg, activityLevel
- Add calorie calculation method
- Update step count from 5 to 9
- Update validation logic

### Container Updates
- Update `OnboardingContainerView` progress indicator (9 dots instead of 5)
- Update step routing logic

## Files to Modify

### Core Models
- `/Users/kevin/w-diet/Core/Database/GRDBManager.swift` - Add v3 migration
- `/Users/kevin/w-diet/Core/Models/UserProfile.swift` - Add new properties

### ViewModels
- `/Users/kevin/w-diet/App/Features/Onboarding/OnboardingViewModel.swift` - Add properties, calculation logic, update steps

### Views
- `/Users/kevin/w-diet/App/Features/Onboarding/OnboardingContainerView.swift` - Update step count and routing
- `/Users/kevin/w-diet/App/Features/Onboarding/Views/Step1GoalSelectionView.swift` - Add "Coming Soon" badges
- `/Users/kevin/w-diet/App/Features/Onboarding/Views/Step4MatadorExplainerView.swift` - Fix MATADOR visualization
- Rename `Step2CalorieTargetView.swift` to `Step6CalorieTargetView.swift`
- Rename `Step3EatingWindowView.swift` to `Step8EatingWindowView.swift`
- Create new views for Steps 2-5

### Tests
- Update `OnboardingViewModel+Tests.swift` with new fields and calculation tests

## Definition of Done

- [ ] All 9 steps implemented and functional
- [ ] "Coming Soon" goals properly disabled
- [ ] Gender, height, weight, activity level collected
- [ ] Calorie calculation working correctly
- [ ] MATADOR visualization shows correct 2-week cycles
- [ ] Database schema updated with migration
- [ ] All views follow existing design patterns
- [ ] Navigation between steps works correctly
- [ ] Data persists to database
- [ ] Unit tests pass
- [ ] App transitions to dashboard after completion
- [ ] Story marked as complete in sprint-status.yaml

## Notes

- This builds on the working Story 1.2 implementation
- Focus on accuracy of MATADOR information (most critical feedback)
- Keep design consistent with existing onboarding steps
- Consider adding age input in future for more accurate calorie calculation
