import Foundation
import SwiftUI

class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var currentOnboardingStep: Int = 0
    let totalSteps = 4
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func nextStep() {
        withAnimation {
            if currentOnboardingStep < totalSteps - 1 {
                currentOnboardingStep += 1
            } else {
                completeOnboarding()
            }
        }
    }
    
    func previousStep() {
        withAnimation {
            if currentOnboardingStep > 0 {
                currentOnboardingStep -= 1
            }
        }
    }
    
    func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
            currentOnboardingStep = 0
        }
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        currentOnboardingStep = 0
    }
} 