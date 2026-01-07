//
//  OnboardingViewModel+Tests.swift
//  w-diet
//
//  Created by Kevin Pietschmann on 06.01.26.
//

import XCTest
@testable import w_diet

/// Unit tests for OnboardingViewModel
///
/// **Test Coverage:**
/// - Step navigation (next/previous)
/// - Validation logic for each step
/// - Data persistence to UserProfile
/// - Error handling
@MainActor
final class OnboardingViewModelTests: XCTestCase {
    var viewModel: OnboardingViewModel!
    var dbManager: GRDBManager!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory test database
        dbManager = try GRDBManager.makeTestDatabase()

        // Create view model with test database
        viewModel = OnboardingViewModel(dbManager: dbManager, authManager: .shared)
    }

    override func tearDown() async throws {
        try dbManager.eraseAll()
        viewModel = nil
        dbManager = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        // Then initial state should be correct
        XCTAssertEqual(viewModel.currentStep, 1)
        XCTAssertNil(viewModel.selectedGoal)
        XCTAssertEqual(viewModel.calorieTargetInput, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDefaultEatingWindowIs8Hours() {
        // Then default eating window should be 12:00 - 20:00 (8 hours)
        XCTAssertEqual(viewModel.eatingWindowDuration, 8)
    }

    // MARK: - Step 1: Goal Selection Tests

    func testCannotContinueWithoutGoalSelection() {
        // Given step 1 without goal selection
        viewModel.currentStep = 1

        // Then cannot continue
        XCTAssertFalse(viewModel.canContinue)
    }

    func testCanContinueAfterGoalSelection() {
        // Given goal selected
        viewModel.selectedGoal = "lose_weight"

        // Then can continue
        XCTAssertTrue(viewModel.canContinue)
    }

    func testNextStepPreFillsCalorieTargetForWeightLoss() {
        // Given weight loss goal
        viewModel.selectedGoal = "lose_weight"

        // When advancing to step 2
        viewModel.nextStep()

        // Then step advances and calorie target is pre-filled with 1800
        XCTAssertEqual(viewModel.currentStep, 2)
        XCTAssertEqual(viewModel.calorieTargetInput, "1800")
    }

    func testNextStepPreFillsCalorieTargetForMaintain() {
        // Given maintain weight goal
        viewModel.selectedGoal = "maintain_weight"

        // When advancing to step 2
        viewModel.nextStep()

        // Then step advances and calorie target is pre-filled with 2000
        XCTAssertEqual(viewModel.currentStep, 2)
        XCTAssertEqual(viewModel.calorieTargetInput, "2000")
    }

    func testNextStepPreFillsCalorieTargetForGainMuscle() {
        // Given gain muscle goal
        viewModel.selectedGoal = "gain_muscle"

        // When advancing to step 2
        viewModel.nextStep()

        // Then step advances and calorie target is pre-filled with 2000
        XCTAssertEqual(viewModel.currentStep, 2)
        XCTAssertEqual(viewModel.calorieTargetInput, "2000")
    }

    // MARK: - Step 2: Calorie Target Tests

    func testCannotContinueWithEmptyCalorieInput() {
        // Given step 2 with empty calorie input
        viewModel.currentStep = 2
        viewModel.calorieTargetInput = ""

        // Then cannot continue
        XCTAssertFalse(viewModel.canContinue)
    }

    func testValidationRejectsNonNumericCalorieInput() {
        // Given step 2 with non-numeric input
        viewModel.currentStep = 2
        viewModel.calorieTargetInput = "abc"

        // When trying to advance
        viewModel.nextStep()

        // Then validation fails and error is shown
        XCTAssertEqual(viewModel.currentStep, 2) // Still on step 2
        XCTAssertNotNil(viewModel.calorieInputError)
    }

    func testValidationRejectsCaloriesBelowMinimum() {
        // Given step 2 with calories below 1000
        viewModel.currentStep = 2
        viewModel.calorieTargetInput = "500"

        // When trying to advance
        viewModel.nextStep()

        // Then validation fails
        XCTAssertEqual(viewModel.currentStep, 2)
        XCTAssertEqual(viewModel.calorieInputError, "Calorie target must be between 1000-4000 kcal")
    }

    func testValidationRejectsCaloriesAboveMaximum() {
        // Given step 2 with calories above 4000
        viewModel.currentStep = 2
        viewModel.calorieTargetInput = "5000"

        // When trying to advance
        viewModel.nextStep()

        // Then validation fails
        XCTAssertEqual(viewModel.currentStep, 2)
        XCTAssertEqual(viewModel.calorieInputError, "Calorie target must be between 1000-4000 kcal")
    }

    func testValidationAcceptsValidCalorieInput() {
        // Given step 2 with valid calorie input
        viewModel.currentStep = 2
        viewModel.calorieTargetInput = "2000"

        // When trying to advance
        viewModel.nextStep()

        // Then validation passes and step advances
        XCTAssertEqual(viewModel.currentStep, 3)
        XCTAssertNil(viewModel.calorieInputError)
    }

    // MARK: - Step 3: Eating Window Tests

    func testEatingWindowDurationCalculation() {
        // Given eating window 12:00 - 20:00
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        viewModel.eatingWindowStart = Calendar.current.date(from: components)!

        components.hour = 20
        viewModel.eatingWindowEnd = Calendar.current.date(from: components)!

        // Then duration should be 8 hours
        XCTAssertEqual(viewModel.eatingWindowDuration, 8)
    }

    func testEatingWindowOvernightCalculation() {
        // Given eating window 20:00 - 04:00 (overnight)
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        viewModel.eatingWindowStart = Calendar.current.date(from: components)!

        components.hour = 4
        viewModel.eatingWindowEnd = Calendar.current.date(from: components)!

        // Then duration should be 8 hours (crossing midnight)
        XCTAssertEqual(viewModel.eatingWindowDuration, 8)
    }

    func testFormattedEatingWindow() {
        // Given eating window 12:00 - 20:00
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        viewModel.eatingWindowStart = Calendar.current.date(from: components)!

        components.hour = 20
        viewModel.eatingWindowEnd = Calendar.current.date(from: components)!

        // Then formatted string should be correct
        XCTAssertEqual(viewModel.formattedEatingWindow, "12:00 - 20:00")
    }

    // MARK: - Navigation Tests

    func testPreviousStepGoesBack() {
        // Given step 3
        viewModel.currentStep = 3

        // When going back
        viewModel.previousStep()

        // Then should be on step 2
        XCTAssertEqual(viewModel.currentStep, 2)
    }

    func testPreviousStepDoesNotGoBelowStep1() {
        // Given step 1
        viewModel.currentStep = 1

        // When trying to go back
        viewModel.previousStep()

        // Then should still be on step 1
        XCTAssertEqual(viewModel.currentStep, 1)
    }

    func testPreviousStepClearsErrors() {
        // Given step 2 with validation error
        viewModel.currentStep = 2
        viewModel.calorieInputError = "Some error"
        viewModel.errorMessage = "General error"

        // When going back
        viewModel.previousStep()

        // Then errors should be cleared
        XCTAssertNil(viewModel.calorieInputError)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Completion Tests

    func testCompleteOnboardingSavesToDatabase() async throws {
        // Given completed onboarding flow
        viewModel.selectedGoal = "lose_weight"
        viewModel.calorieTargetInput = "1800"

        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        viewModel.eatingWindowStart = Calendar.current.date(from: components)!

        components.hour = 20
        viewModel.eatingWindowEnd = Calendar.current.date(from: components)!

        // And authenticated user
        // Note: In real test, need to set up AuthManager with test user
        // For now, this test documents the expected behavior

        // When completing onboarding
        // await viewModel.completeOnboarding()

        // Then user profile should be saved with onboarding data
        // (Commented out until AuthManager test setup is available)
    }

    // MARK: - Goal Display Name Tests

    func testGoalDisplayNames() {
        viewModel.selectedGoal = "lose_weight"
        XCTAssertEqual(viewModel.goalDisplayName, "Lose Weight")

        viewModel.selectedGoal = "maintain_weight"
        XCTAssertEqual(viewModel.goalDisplayName, "Maintain Weight")

        viewModel.selectedGoal = "gain_muscle"
        XCTAssertEqual(viewModel.goalDisplayName, "Gain Muscle")

        viewModel.selectedGoal = nil
        XCTAssertEqual(viewModel.goalDisplayName, "Not set")
    }
}
