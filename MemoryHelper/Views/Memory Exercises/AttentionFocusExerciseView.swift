import SwiftUI

struct AttentionFocusExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AttentionFocusViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with score and time
            HStack {
                Text("Score: \(viewModel.score)")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.gameState != .finished {
                    Text(timeString(from: viewModel.timeRemaining))
                        .font(.headline)
                        .foregroundColor(viewModel.timeRemaining < 10 ? .red : .primary)
                }
            }
            .padding(.horizontal)
            
            // Game state specific content
            Group {
                switch viewModel.gameState {
                case .intro:
                    introView
                case .showTarget:
                    targetView
                case .showDistraction:
                    distractionView
                case .showSelection:
                    selectionView
                case .feedback:
                    feedbackView
                case .finished:
                    resultsView
                }
            }
            
            Spacer()
            
            // Action button
            Button(actionButtonTitle) {
                if viewModel.gameState == .finished {
                    // When in finished state, dismiss the view
                    dismiss()
                } else {
                    // Handle other button actions through the view model
                    viewModel.handleActionButton()
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(buttonBackgroundColor)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .disabled(isButtonDisabled)
        }
        .navigationTitle("Attention Focus")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setup()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }
    
    private var introView: some View {
        VStack(spacing: 20) {
            Image(systemName: "eye")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .padding(.top, 30)
            
            Text("Attention Focus")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("How to Play:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    InstructionRow(number: 1, text: "Remember the target symbols that appear on screen")
                    
                    InstructionRow(number: 2, text: "After a brief distraction, select all the symbols you saw")
                    
                    InstructionRow(number: 3, text: "Each correct answer earns points, incorrect selections lose points")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6).opacity(0.7))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var targetView: some View {
        VStack {
            Text("Remember these symbols:")
                .font(.headline)
                .padding(.bottom, 20)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                ForEach(viewModel.targetSymbols, id: \.self) { symbol in
                    SymbolView(symbol: symbol, isHighlighted: true)
                }
            }
            .padding()
        }
    }
    
    private var distractionView: some View {
        VStack {
            Text("Focus...")
                .font(.headline)
                .padding(.bottom, 20)
            
            // A simple distraction task
            HStack(spacing: 20) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(viewModel.distractionColors[safe: index] ?? .gray)
                        .frame(width: 60, height: 60)
                        .opacity(viewModel.distractionHighlight == index ? 1.0 : 0.5)
                }
            }
        }
    }
    
    private var selectionView: some View {
        VStack {
            Text("Select the symbols you saw:")
                .font(.headline)
                .padding(.bottom, 10)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                ForEach(viewModel.displaySymbols, id: \.self) { symbol in
                    SymbolView(
                        symbol: symbol,
                        isHighlighted: viewModel.selectedSymbols.contains(symbol)
                    )
                    .onTapGesture {
                        viewModel.toggleSymbolSelection(symbol)
                    }
                }
            }
            .padding()
        }
    }
    
    private var feedbackView: some View {
        VStack(spacing: 20) {
            Text(viewModel.isCorrect ? "Correct!" : "Try Again!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(viewModel.isCorrect ? .green : .red)
            
            Text(viewModel.feedbackMessage)
                .multilineTextAlignment(.center)
                .padding()
            
            // Show score impact
            if viewModel.isCorrect {
                Text("+\(viewModel.lastRoundScore) points")
                    .font(.headline)
                    .foregroundColor(.green)
            } else {
                // Show raw score change which can be negative
                let correctlySelected = viewModel.selectedSymbols.intersection(Set(viewModel.targetSymbols)).count
                let incorrectlySelected = viewModel.selectedSymbols.subtracting(Set(viewModel.targetSymbols)).count
                let missedTargets = Set(viewModel.targetSymbols).subtracting(viewModel.selectedSymbols).count
                
                let roundScore = (correctlySelected * 10) - (incorrectlySelected * 5) - (missedTargets * 2)
                
                Text("Round score: \(roundScore) points")
                    .font(.headline)
                    .foregroundColor(roundScore >= 0 ? .blue : .red)
            }
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .padding(.top, 30)
            
            Text("Exercise Complete!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                Text("Your Score: \(viewModel.score)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Rounds Completed: \(viewModel.roundsCompleted)")
                    .font(.headline)
                
                Text("Accuracy: \(Int(viewModel.accuracy * 100))%")
                    .font(.headline)
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.7))
            .cornerRadius(12)
            .padding(.horizontal)
            
            if viewModel.isHighScore {
                Text("New High Score! 🎉")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
            }
        }
    }
    
    private var actionButtonTitle: String {
        switch viewModel.gameState {
        case .intro:
            return "Start Exercise"
        case .showTarget, .showDistraction:
            return "Please Wait..."
        case .showSelection:
            return "Submit"
        case .feedback:
            return viewModel.roundsCompleted >= viewModel.totalRounds ? "See Results" : "Next Round"
        case .finished:
            return "Done"
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private var isButtonDisabled: Bool {
        switch viewModel.gameState {
        case .showTarget, .showDistraction:
            return true
        case .showSelection:
            return viewModel.selectedSymbols.isEmpty // Disable if no symbols selected
        default:
            return false
        }
    }
    
    private var buttonBackgroundColor: Color {
        isButtonDisabled ? Color.red.opacity(0.5) : Color.red
    }
}

struct SymbolView: View {
    let symbol: String
    let isHighlighted: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isHighlighted ? Color.red.opacity(0.2) : Color(.systemGray6))
                .frame(width: 60, height: 60)
            
            Image(systemName: symbol)
                .font(.system(size: 24))
                .foregroundColor(isHighlighted ? .red : .primary)
        }
        .overlay(
            Circle()
                .stroke(isHighlighted ? Color.red : Color.clear, lineWidth: 2)
        )
    }
}

class AttentionFocusViewModel: ObservableObject {
    enum GameState {
        case intro
        case showTarget
        case showDistraction
        case showSelection
        case feedback
        case finished
    }
    
    @Published var gameState: GameState = .intro
    @Published var score: Int = 0
    @Published var roundsCompleted: Int = 0
    @Published var timeRemaining: Int = 180 // 3 minutes
    @Published var targetSymbols: [String] = []
    @Published var displaySymbols: [String] = []
    @Published var selectedSymbols: Set<String> = []
    @Published var isCorrect: Bool = false
    @Published var feedbackMessage: String = ""
    @Published var lastRoundScore: Int = 0
    @Published var isHighScore: Bool = false
    @Published var distractionColors: [Color] = [.red, .blue, .green]
    @Published var distractionHighlight: Int = 0
    
    let totalRounds = 10
    let allSymbols = ["star.fill", "heart.fill", "circle.fill", "square.fill", "triangle.fill", 
                      "diamond.fill", "suit.club.fill", "suit.spade.fill", "suit.heart.fill", 
                      "suit.diamond.fill", "sun.max.fill", "moon.fill", "cloud.fill", "bolt.fill", 
                      "house.fill", "car.fill", "airplane", "leaf.fill", "flame.fill", "bell.fill"]
    
    private var timer: Timer?
    private var targetCount = 3 // Starting with 3 targets
    private var correctSelections: Int = 0
    private var incorrectSelections: Int = 0
    private var distractionTimer: Timer?
    
    var accuracy: Double {
        guard correctSelections > 0 || incorrectSelections > 0 else {
            return 0
        }
        return Double(correctSelections) / Double(correctSelections + incorrectSelections)
    }
    
    func setup() {
        gameState = .intro
        score = 0
        roundsCompleted = 0
        timeRemaining = 180
        targetCount = 3
        correctSelections = 0
        incorrectSelections = 0
        isHighScore = false
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.finishExercise()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        distractionTimer?.invalidate()
        distractionTimer = nil
    }
    
    func handleActionButton() {
        switch gameState {
        case .intro:
            startTimer()
            startRound()
        case .showTarget, .showDistraction:
            // Button is disabled during these states
            break
        case .showSelection:
            evaluateSelection()
        case .feedback:
            if roundsCompleted >= totalRounds || timeRemaining <= 0 {
                finishExercise()
            } else {
                startRound()
            }
        case .finished:
            saveProgress()
        }
    }
    
    func startRound() {
        // Create a random set of target symbols
        let shuffledSymbols = allSymbols.shuffled()
        
        // Adjust difficulty as rounds progress
        targetCount = min(3 + (roundsCompleted / 2), 7)
        
        // Select target symbols
        targetSymbols = Array(shuffledSymbols.prefix(targetCount))
        
        // Clear selection
        selectedSymbols.removeAll()
        
        // Show targets
        gameState = .showTarget
        
        // After a delay, show distraction
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self, self.gameState == .showTarget else { return }
            self.showDistraction()
        }
    }
    
    func showDistraction() {
        gameState = .showDistraction
        distractionHighlight = 0
        
        // Animate the distraction for a few seconds
        var counter = 0
        distractionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            counter += 1
            self.distractionHighlight = counter % 3
            
            if counter >= 5 {
                timer.invalidate()
                self.prepareSelectionView()
            }
        }
    }
    
    func prepareSelectionView() {
        // Create the display set with targets and some distractors
        var displaySet = Set(targetSymbols)
        
        // Add distractors
        let distractors = allSymbols.filter { !targetSymbols.contains($0) }.shuffled()
        displaySet.formUnion(distractors.prefix(12 - targetCount))
        
        // Convert to array and shuffle
        displaySymbols = Array(displaySet).shuffled()
        
        // Show selection view
        gameState = .showSelection
    }
    
    func toggleSymbolSelection(_ symbol: String) {
        if selectedSymbols.contains(symbol) {
            selectedSymbols.remove(symbol)
        } else {
            selectedSymbols.insert(symbol)
        }
    }
    
    func evaluateSelection() {
        let correctTargets = Set(targetSymbols)
        
        // Count correct and incorrect selections
        let correctlySelected = selectedSymbols.intersection(correctTargets).count
        let incorrectlySelected = selectedSymbols.subtracting(correctTargets).count
        let missedTargets = correctTargets.subtracting(selectedSymbols).count
        
        // Update stats
        correctSelections += correctlySelected
        incorrectSelections += incorrectlySelected
        
        // Calculate raw score for the round
        let pointsForCorrect = correctlySelected * 10
        let penaltyForIncorrect = incorrectlySelected * 5
        let penaltyForMissed = missedTargets * 2
        
        // Calculate the round score (can be negative now)
        let roundScore = pointsForCorrect - penaltyForIncorrect - penaltyForMissed
        
        // Store for display purposes - keep this non-negative for UI feedback
        lastRoundScore = max(0, roundScore)
        
        // For the actual score, apply the full calculation, including negative points
        score += roundScore
        
        // Ensure total score doesn't go below zero
        score = max(0, score)
        
        // Determine if response was correct (all targets identified, no incorrect selections)
        isCorrect = correctlySelected == targetSymbols.count && incorrectlySelected == 0
        
        // Generate feedback message
        if isCorrect {
            feedbackMessage = "Perfect! You identified all target symbols correctly."
        } else {
            // Enhanced feedback to clearly show penalties
            feedbackMessage = "You got \(correctlySelected) out of \(targetSymbols.count) correct (+\(pointsForCorrect)pts)\n" +
                             "\(incorrectlySelected) incorrect selections (-\(penaltyForIncorrect)pts)\n" +
                             "\(missedTargets) missed targets (-\(penaltyForMissed)pts)"
        }
        
        roundsCompleted += 1
        gameState = .feedback
    }
    
    func finishExercise() {
        stopTimer()
        
        // Check if this is a high score
        let currentHighScore = UserDefaults.standard.integer(forKey: "attentionFocusHighScore")
        if score > currentHighScore {
            isHighScore = true
        }
        
        gameState = .finished
    }
    
    func saveProgress() {
        // Save high score if needed
        if isHighScore {
            UserDefaults.standard.set(score, forKey: "attentionFocusHighScore")
        }
        
        // Update exercise stats
        let statsManager = ExerciseProgressManager.shared
        statsManager.recordExerciseCompletion(
            exerciseId: "attentionFocus",
            score: Int(accuracy * 100),
            maxScore: 100 // Maximum achievable score is 100%
        )
    }
}

// Safe array access extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Add this helper view for consistent instruction formatting
struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .leading)
            
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
