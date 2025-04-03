import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var onboardingManager = OnboardingManager.shared
    
    var body: some View {
        ZStack {
            // Background color
            Color.black
                .opacity(0.9)
                .ignoresSafeArea()
            
            // Main content area
            VStack {
                // Top navigation bar - FIXED at top of screen
                HStack {
                    Spacer()
                    
                    Button {
                        onboardingManager.completeOnboarding()
                    } label: {
                        Text("Skip")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Capsule().fill(Color.blue))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Main scrollable content
                ScrollView {
                    VStack(spacing: 40) {
                        Spacer(minLength: 30)
                        
                        // Icon
                        Circle()
                            .fill(stepColor)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: stepIcon)
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            )
                        
                        // Content
                        VStack(spacing: 20) {
                            Text(stepTitle)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(stepDescription)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            Image(systemName: stepSystemImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                                .foregroundColor(stepColor)
                                .padding(.vertical)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                    .frame(minHeight: UIScreen.main.bounds.height - 180) // Ensure enough scrollable space
                }
                
                // FIXED NAVIGATION CONTROLS at bottom of screen
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 10) {
                        ForEach(0..<onboardingManager.totalSteps, id: \.self) { step in
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(
                                    step == onboardingManager.currentOnboardingStep ? 
                                        stepColor : .gray.opacity(0.5)
                                )
                        }
                    }
                    
                    // Navigation buttons
                    HStack {
                        // Back button
                        Button {
                            onboardingManager.previousStep()
                        } label: {
                            Text("Back")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(
                                    Capsule()
                                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .opacity(onboardingManager.currentOnboardingStep > 0 ? 1 : 0)
                        .disabled(onboardingManager.currentOnboardingStep == 0)
                        
                        Spacer()
                        
                        // Next/Done button
                        Button {
                            onboardingManager.nextStep()
                        } label: {
                            Text(onboardingManager.currentOnboardingStep == onboardingManager.totalSteps - 1 ? 
                                 "Get Started" : "Next")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(Capsule().fill(stepColor))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .background(
                    Rectangle()
                        .fill(Color.black.opacity(0.7))
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            .foregroundColor(.white)
        }
    }
    
    // Tutorial content for each step
    private var stepTitle: String {
        switch onboardingManager.currentOnboardingStep {
        case 0:
            return "Track Your Daily Mood"
        case 1:
            return "Quick Actions"
        case 2:
            return "Memory Training"
        case 3:
            return "View Your Progress"
        default:
            return ""
        }
    }
    
    private var stepDescription: String {
        switch onboardingManager.currentOnboardingStep {
        case 0:
            return "Rate how you're feeling each day to build awareness of your emotional patterns. Tap the welcome card to quickly log your mood."
        case 1:
            return "Access common tasks with these shortcut buttons. Create notes to remember important details, log events, or view your progress statistics."
        case 2:
            return "Improve your memory with scientifically designed exercises. Each exercise targets different aspects of memory and cognitive function."
        case 3:
            return "Track your progress over time with detailed statistics. See how your memory performance improves as you complete more exercises."
        default:
            return ""
        }
    }
    
    private var stepIcon: String {
        switch onboardingManager.currentOnboardingStep {
        case 0:
            return "star.fill"
        case 1:
            return "square.grid.2x2"
        case 2:
            return "brain"
        case 3:
            return "chart.bar.fill"
        default:
            return ""
        }
    }
    
    private var stepSystemImage: String {
        switch onboardingManager.currentOnboardingStep {
        case 0:
            return "star.square.on.square.fill"
        case 1:
            return "rectangle.grid.2x2.fill"
        case 2:
            return "brain.head.profile"
        case 3:
            return "chart.xyaxis.line"
        default:
            return ""
        }
    }
    
    private var stepColor: Color {
        switch onboardingManager.currentOnboardingStep {
        case 0:
            return .yellow
        case 1:
            return .blue
        case 2:
            return .purple
        case 3:
            return .green
        default:
            return .gray
        }
    }
} 