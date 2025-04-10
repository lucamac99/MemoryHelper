import SwiftUI
import Combine

class NumberMnemonicsViewModel: ObservableObject {
    enum GameState {
        case intro
        case learning
        case practice
        case memorizing
        case recall
        case feedback
        case results
    }
    
    // Published properties
    @Published var gameState: GameState = .intro
    @Published var currentRound: Int = 1
    @Published var score: Int = 0
    @Published var memorizeTimer: Int = 0
    @Published var showPracticeAnswer: Bool = false
    @Published var userInput: [Int] = []
    @Published var isCurrentRecallCorrect: Bool = false
    @Published var lastPoints: Int = 0
    @Published var correctSequences: Int = 0
    @Published var shouldDismiss: Bool = false
    @Published var showAlert: Bool = false
    @Published var showMemoryTip: Bool = true
    
    // Number system
    @Published var numberShapeSystem: [NumberShapeAssociation] = [
        NumberShapeAssociation(number: 0, shape: "Wheel", icon: "circle"),
        NumberShapeAssociation(number: 1, shape: "Pencil", icon: "pencil"),
        NumberShapeAssociation(number: 2, shape: "Swan", icon: "swift"),
        NumberShapeAssociation(number: 3, shape: "Heart", icon: "heart"),
        NumberShapeAssociation(number: 4, shape: "Flag", icon: "flag"),
        NumberShapeAssociation(number: 5, shape: "Hook", icon: "curlybraces"),
        NumberShapeAssociation(number: 6, shape: "Cherry", icon: "leaf"),
        NumberShapeAssociation(number: 7, shape: "Boomerang", icon: "arrow.left.and.right.circle"),
        NumberShapeAssociation(number: 8, shape: "Hourglass", icon: "timer"),
        NumberShapeAssociation(number: 9, shape: "Balloon", icon: "bubble.right")
    ]
    
    // Constants
    let totalRounds: Int = 3
    let totalSequences: Int = 3
    let numberPadRows: [[Int]] = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [0, -1]]
    
    // Sequences to memorize (will be generated)
    private var sequences: [[Int]] = []
    private var currentSequenceIndex: Int = 0
    private var practiceIndex: Int = 0
    private var timer: Timer?
    private var longestSequence: Int = 4
    
    var currentSequence: [Int] {
        guard currentSequenceIndex < sequences.count else { return [] }
        return sequences[currentSequenceIndex]
    }
    
    var currentPracticeItem: NumberShapeAssociation? {
        guard practiceIndex < numberShapeSystem.count else { return nil }
        return numberShapeSystem[practiceIndex]
    }
    
    var longestCorrectSequence: Int {
        return min(longestSequence, currentSequenceIndex)
    }
    
    var isActionButtonDisabled: Bool {
        switch gameState {
        case .recall:
            return userInput.count != currentSequence.count
        case .memorizing:
            return memorizeTimer > 0
        default:
            return false
        }
    }
    
    var actionButtonTitle: String {
        switch gameState {
        case .intro:
            return "Learn the System"
        case .learning:
            return "Practice the System"
        case .practice:
            return showPracticeAnswer ? "Next Number" : "Skip"
        case .memorizing:
            return memorizeTimer > 0 ? "Memorizing..." : "Ready to Recall"
        case .recall:
            return "Submit"
        case .feedback:
            if currentSequenceIndex >= sequences.count - 1 {
                return "See Results"
            } else {
                return "Next Sequence"
            }
        case .results:
            return "Finish Exercise"
        }
    }
    
    var performanceRating: String {
        let percentage = Double(correctSequences) / Double(totalSequences)
        if percentage >= 0.9 {
            return "Excellent"
        } else if percentage >= 0.7 {
            return "Good"
        } else if percentage >= 0.5 {
            return "Adequate"
        } else {
            return "Needs Practice"
        }
    }
    
    var alertTitle: String = ""
    var alertMessage: String = ""
    
    init() {
        setupExercise()
    }
    
    deinit {
        stopTimer()
    }
    
    private func setupExercise() {
        gameState = .intro
        currentRound = 1
        score = 0
        correctSequences = 0
        longestSequence = 4
        
        generateSequences()
    }
    
    private func generateSequences() {
        sequences = []
        
        // Generate fewer sequences with more manageable lengths
        let roundBonus = currentRound - 1
        
        for i in 0..<totalSequences {
            // Start with shorter sequences and increase more gradually
            let length = 3 + i/2 + roundBonus // More gradual increase
            var sequence: [Int] = []
            
            for _ in 0..<length {
                sequence.append(Int.random(in: 0...9))
            }
            
            sequences.append(sequence)
        }
        
        currentSequenceIndex = 0
    }
    
    func handleActionButton() {
        switch gameState {
        case .intro:
            gameState = .learning
            
        case .learning:
            gameState = .practice
            practiceIndex = 0
            showPracticeAnswer = false
            
        case .practice:
            if showPracticeAnswer {
                // Move to next practice item
                practiceIndex += 1
                showPracticeAnswer = false
                
                if practiceIndex >= numberShapeSystem.count {
                    // Practice completed
                    gameState = .memorizing
                    startMemorizationTimer()
                }
            } else {
                // Skip to answer
                showPracticeAnswer = true
            }
            
        case .memorizing:
            // Remove the manual transition since it's now automatic
            // This button will now be disabled during memorization
            break
            
        case .recall:
            evaluateUserInput()
            
        case .feedback:
            if currentSequenceIndex >= sequences.count - 1 {
                // Move to next round if not the final round
                if currentRound < totalRounds {
                    currentRound += 1
                    resetForNextRound()
                } else {
                    gameState = .results
                }
            } else {
                // Next sequence in current round
                currentSequenceIndex += 1
                showMemoryTip = currentSequenceIndex < 2
                gameState = .memorizing
                userInput = []
                startMemorizationTimer()
            }
            
        case .results:
            finishExercise()
        }
    }
    
    func startMemorizationTimer() {
        // Adaptive difficulty: shorter time for advanced rounds
        let baseTime = max(7, 8 - currentSequenceIndex) // 12 seconds for first sequence, down to 7
        memorizeTimer = baseTime
        
        // Set showMemoryTip based on current sequence index
        showMemoryTip = currentSequenceIndex < 2
        
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.memorizeTimer > 0 {
                self.memorizeTimer -= 1
            } else {
                self.stopTimer()
                
                // Automatically transition to recall state when timer ends
                DispatchQueue.main.async {
                    self.gameState = .recall
                    self.userInput = []
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func inputDigit(_ digit: Int) {
        if digit == -1 {
            // Backspace
            if !userInput.isEmpty {
                userInput.removeLast()
            }
        } else if userInput.count < currentSequence.count {
            // Add digit
            userInput.append(digit)
        }
    }
    
    func evaluateUserInput() {
        isCurrentRecallCorrect = userInput == currentSequence
        
        if isCurrentRecallCorrect {
            let sequenceLength = currentSequence.count
            lastPoints = sequenceLength * 5 // 5 points per digit
            score += lastPoints
            correctSequences += 1
            
            if sequenceLength > longestSequence {
                longestSequence = sequenceLength
            }
        } else {
            lastPoints = 0
        }
        
        gameState = .feedback
    }
    
    func finishExercise() {
        // Record completion with ExerciseProgressManager
        ExerciseProgressManager.shared.recordExerciseCompletion(
            exerciseId: "numberMnemonics",
            score: score,
            maxScore: calculateMaxScore()
        )
        
        shouldDismiss = true
    }
    
    private func calculateMaxScore() -> Int {
        // Calculate max possible score (5 points per digit across all sequences)
        var maxScore = 0
        for sequence in sequences {
            maxScore += sequence.count * 5
        }
        return maxScore
    }
    
    func showErrorAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    // Add a new method to reset for the next round
    private func resetForNextRound() {
        // Generate new sequences with increasing difficulty for the next round
        generateSequences()
        gameState = .memorizing
        showMemoryTip = currentSequenceIndex < 2
        startMemorizationTimer()
        score = score // Keep the score from previous rounds
    }
    
    // Add this new function to skip the practice phase
    func skipPracticePhase() {
        gameState = .memorizing
        startMemorizationTimer()
    }
}

struct NumberShapeAssociation: Identifiable {
    let id = UUID()
    let number: Int
    let shape: String
    let icon: String
} 