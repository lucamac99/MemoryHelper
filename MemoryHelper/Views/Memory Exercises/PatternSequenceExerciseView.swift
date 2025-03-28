import SwiftUI

// Add this structure definition before the PatternSequenceExerciseView
struct RoundScoreDetails {
    let correctAnswers: Int
    let baseScore: Int
    let bonusScore: Int
    let totalScore: Int
    let sequenceLength: Int
}

struct PatternSequenceExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameState: GameState = .ready
    @State private var round = 1
    @State private var score = 0
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var highlightedCell: Int? = nil
    @State private var showingResults = false
    @State private var timers: [Timer] = []
    @State private var isShowingSequence = false
    @State private var currentSequenceIndex: Int = 0
    @State private var pulsing: Bool = false
    
    // Visual feedback settings
    @State private var cellOpacity: Double = 1.0
    @State private var cellScale: CGFloat = 1.0
    
    let maxRounds = 10
    let baseSequenceLength = 3
    let cellCount = 9 // 3x3 grid
    let highlightDuration = 0.4 // seconds
    let pauseDuration = 0.3 // seconds between highlights
    let pulseInterval = 0.25 // seconds for each pulse
    
    @State private var lastRoundDetails: RoundScoreDetails?
    @State private var roundScores: [RoundScoreDetails] = []
    
    enum GameState {
        case ready, showingSequence, inputting, feedback, finished
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header info
            HStack {
                VStack(alignment: .leading) {
                    Text("Pattern Sequence")
                        .font(.headline)
                    Text("Round: \(round)/\(maxRounds)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Score: \(score)")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            // Status message
            if gameState == .showingSequence {
                Text("Watch the sequence")
                    .font(.headline)
                    .foregroundColor(.orange)
            } else if gameState == .inputting {
                Text("Repeat the sequence")
                    .font(.headline)
                    .foregroundColor(.orange)
            } else if gameState == .feedback {
                feedbackView
            }
            
            // Pattern grid
            VStack(spacing: 0) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(0..<cellCount, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(getCellColor(for: index))
                                .opacity(highlightedCell == index ? (pulsing ? 0.5 : 1.0) : 1.0)
                                .scaleEffect(highlightedCell == index ? (pulsing ? 0.9 : 1.1) : 1.0)
                                .frame(height: 80)
                                .onTapGesture {
                                    if gameState == .inputting {
                                        cellTapped(index)
                                    }
                                }
                            
                            // Show the sequence number during demonstration
                            if highlightedCell == index && gameState == .showingSequence {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text("\(currentSequenceIndex + 1)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.orange)
                                    )
                                    .offset(x: 25, y: -25)
                                    .opacity(pulsing ? 0.7 : 1.0)
                            }
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Instructions
            if gameState == .ready {
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text("Watch the sequence of highlighted cells, then tap the cells in the same order to repeat the pattern.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        
                        Text("Pay close attention! Some cells may appear multiple times in a row - these will flash multiple times in sequence. For each flash, you'll need to tap that cell once.")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                        
                        Text("The sequences will get longer as you progress. This exercise improves working memory and attention to sequences.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .frame(maxHeight: 200)
            }
            
            // Progress indicator for input
            if gameState == .inputting {
                VStack(spacing: 10) {
                    // Dots showing sequence length and progress
                    HStack(spacing: 6) {
                        ForEach(0..<sequence.count, id: \.self) { index in
                            Circle()
                                .fill(index < userSequence.count ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }
                    
                    // Show all numbers in scrollable view
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<userSequence.count, id: \.self) { index in
                                let isCorrect = index < sequence.count && userSequence[index] == sequence[index]
                                
                                Text("\(index + 1)")
                                    .font(.caption2)
                                    .foregroundColor(isCorrect ? .green : .red)
                                    .frame(width: 20, height: 20)
                                    .background(
                                        Circle()
                                            .stroke(isCorrect ? Color.green : .red, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.top, 8)
            }
            
            Spacer()
            
            // Start/Reset button
            if gameState == .ready {
                Button(action: startGame) {
                    Text("Start Exercise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            } else if gameState == .feedback {
                Button(action: nextRound) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .navigationTitle("Pattern Sequence")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            timers.forEach { $0.invalidate() }
        }
        .sheet(isPresented: $showingResults) {
            PatternSequenceResultsView(
                score: score, 
                maxScore: maxRounds * 100,
                roundScores: roundScores
            ) {
                dismiss()
            }
        }
    }
    
    private func startGame() {
        gameState = .ready
        round = 1
        score = 0
        roundScores = [] // Clear all previous round scores
        lastRoundDetails = nil // Reset last round details
        generateSequence()
        showSequence()
    }
    
    private func generateSequence() {
        let sequenceLength: Int
        switch round {
        case 1, 2: sequenceLength = 3
        case 3, 4: sequenceLength = 4
        case 5, 6: sequenceLength = 5
        case 7, 8: sequenceLength = 6
        case 9, 10: sequenceLength = 7
        default: sequenceLength = 3
        }
        
        sequence = []
        for _ in 0..<sequenceLength {
            sequence.append(Int.random(in: 0..<cellCount))
        }
        
        userSequence = []
    }
    
    private func showSequence() {
        isShowingSequence = true
        gameState = .showingSequence
        highlightedCell = nil
        pulsing = false
        
        // Cancel any existing timers
        timers.forEach { $0.invalidate() }
        timers = []
        
        // Prepare timing for each step in sequence
        var cumulativeTime: Double = 0.5 // Start with a small delay
        
        for (index, cell) in sequence.enumerated() {
            // Timer to show the cell
            let showTime = cumulativeTime
            let showTimer = Timer.scheduledTimer(withTimeInterval: showTime, repeats: false) { _ in
                highlightedCell = cell
                currentSequenceIndex = index
                pulsing = false
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
            timers.append(showTimer)
            
            // Add pulse effect if it's a repeat of the previous cell
            if index > 0 && sequence[index] == sequence[index-1] {
                // Add a pulse midway through the display duration
                let pulseTime = showTime + highlightDuration * 0.4
                let pulseTimer = Timer.scheduledTimer(withTimeInterval: pulseTime, repeats: false) { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        pulsing = true
                    }
                    
                    // Reset pulse after a moment
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            pulsing = false
                        }
                    }
                }
                timers.append(pulseTimer)
            }
            
            // Timer to hide the cell
            let hideTime = showTime + highlightDuration
            let hideTimer = Timer.scheduledTimer(withTimeInterval: hideTime, repeats: false) { _ in
                if index == sequence.count - 1 {
                    // Last cell in sequence
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        highlightedCell = nil
                        isShowingSequence = false
                        gameState = .inputting
                    }
                } else {
                    highlightedCell = nil
                }
            }
            timers.append(hideTimer)
            
            // Calculate time for next cell
            cumulativeTime = hideTime + pauseDuration
        }
    }
    
    private func cellTapped(_ index: Int) {
        userSequence.append(index)
        
        // Briefly highlight the tapped cell
        highlightedCell = index
        pulsing = false
        
        // Haptic feedback based on correctness
        let position = userSequence.count - 1
        let isCorrect = position < sequence.count && userSequence[position] == sequence[position]
        
        // Visual feedback
        withAnimation(.easeIn(duration: 0.1)) {
            pulsing = true
        }
        
        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .light : .heavy)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.1)) {
                pulsing = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                highlightedCell = nil
                
                // Check if the user has completed the sequence
                if userSequence.count == sequence.count {
                    checkSequence()
                }
            }
        }
    }
    
    private func checkSequence() {
        gameState = .feedback
        
        // Only calculate score if we haven't already done so for this round
        // This prevents double-counting if checkSequence is called multiple times
        if lastRoundDetails == nil || roundScores.count < round {
            let roundScore = calculateRoundScore()
            score += roundScore // Add this round's score to the total
        }
    }
    
    private func calculateRoundScore() -> Int {
        // Count correct answers
        var correctAnswers = 0
        for i in 0..<sequence.count {
            if i < userSequence.count && userSequence[i] == sequence[i] {
                correctAnswers += 1
            }
        }
        
        // Calculate percentage: (correct answers / total sequence length) * 100
        let percentage = Double(correctAnswers) / Double(sequence.count)
        let roundScore = Int(Darwin.round(percentage * 100))
        
        // Store round details (no bonus points)
        let details = RoundScoreDetails(
            correctAnswers: correctAnswers,
            baseScore: roundScore,
            bonusScore: 0,
            totalScore: roundScore,
            sequenceLength: sequence.count
        )
        
        lastRoundDetails = details
        roundScores.append(details)
        
        return roundScore
    }
    
    private func nextRound() {
        if round >= maxRounds {
            gameState = .finished
            showingResults = true
        } else {
            round += 1
            generateSequence()
            showSequence()
        }
    }
    
    private func getCellColor(for index: Int) -> Color {
        if highlightedCell == index {
            return .orange
        } else {
            return Color(.systemGray5)
        }
    }
    
    private var feedbackView: some View {
        VStack(spacing: 8) {
            if userSequence == sequence {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    
                    Text("Correct")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            } else {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                    
                    Text("Incorrect")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Add detailed score information
            if let details = lastRoundDetails {
                VStack(alignment: .center, spacing: 4) {
                    Text("Round \(round): \(details.totalScore) points")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(details.correctAnswers)/\(details.sequenceLength) correct")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Total score: \(score)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.top, 2)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private func finishExercise() {
        // Calculate maximum possible score (perfect score in all rounds)
        let maxPossibleScore = maxRounds * 100 // Base score for perfect performance
        
        ExerciseProgressManager.shared.recordExerciseCompletion(
            exerciseId: "patternSequence",
            score: score,
            maxScore: maxPossibleScore
        )
        
        showingResults = true
    }
    
    // Add this helper method
    private func runningTotal(upToRound round: Int) -> Int {
        guard round > 0 && round <= roundScores.count else { return 0 }
        return roundScores[0..<round].reduce(0) { $0 + $1.totalScore }
    }
    
    private func verifyRunningTotal() -> Int {
        // This should match the total score
        return roundScores.reduce(0) { $0 + $1.totalScore }
    }
}

// First, create a view for a single round's details
struct RoundScoreRow: View {
    let roundNumber: Int
    let details: RoundScoreDetails
    let runningTotal: Int
    let isFinalRound: Bool
    
    var body: some View {
        Text("Round \(roundNumber): \(details.correctAnswers)/\(details.sequenceLength) = \(details.totalScore) points \(isFinalRound ? "(Final: \(runningTotal))" : "(Total: \(runningTotal))")")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

// Now simplify the RoundBreakdownView to use this component
struct RoundBreakdownView: View {
    let roundScores: [RoundScoreDetails]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Round Breakdown:")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.top, 4)
            
            ForEach(0..<roundScores.count, id: \.self) { index in
                let details = roundScores[index]
                let roundNum = index + 1
                
                // Calculate running total up to and including this round
                let runningTotal = roundScores[0...index].reduce(0) { $0 + $1.totalScore }
                
                // Use the extracted component
                RoundScoreRow(
                    roundNumber: roundNum,
                    details: details,
                    runningTotal: runningTotal,
                    isFinalRound: index == roundScores.count - 1
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
    }
}

struct ResultsHeaderView: View {
    var body: some View {
        VStack {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .padding(.top, 30)
            
            Text("Exercise Complete!")
                .font(.title2)
                .fontWeight(.bold)
        }
    }
}

// Rename ScoreRow to avoid conflict with existing component
struct PatternScoreRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct ScoreSummaryView: View {
    let score: Int
    let maxScore: Int
    let percentageScore: Int
    let roundScores: [RoundScoreDetails]
    
    var body: some View {
        VStack(spacing: 15) {
            // Show raw score using our renamed component
            PatternScoreRow(title: "Total Score", value: "\(score) points")
            
            // Show percentage
            PatternScoreRow(title: "Performance", value: "\(percentageScore)%")
            
            // Round breakdown section
            if !roundScores.isEmpty {
                RoundBreakdownView(roundScores: roundScores)
            }
            
            // Maximum score text
            Text("Maximum possible: \(maxScore) points (100 points per round)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Now simplify the PatternSequenceResultsView to use these components
struct PatternSequenceResultsView: View {
    let score: Int
    let maxScore: Int
    let roundScores: [RoundScoreDetails]
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var hasSubmitted = false
    
    var percentageScore: Int {
        Int((Double(score) / Double(maxScore)) * 100)
    }
    
    // Add this computed property to validate the score
    private var calculatedTotal: Int {
        roundScores.reduce(0) { $0 + $1.totalScore }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            ResultsHeaderView()
            
            // Score summary
            ScoreSummaryView(
                score: calculatedTotal, // Use the recalculated score to be safe
                maxScore: maxScore,
                percentageScore: Int((Double(calculatedTotal) / Double(maxScore)) * 100),
                roundScores: roundScores
            )
            
            // Explanation text
            Text("Pattern sequence exercises strengthen working memory and attention to order, which is essential for following directions, learning procedures, and remembering PIN numbers or passwords.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Done button
            Button(action: {
                if !hasSubmitted {
                    ExerciseProgressManager.shared.recordExerciseCompletion(
                        exerciseId: "patternSequence",
                        score: score,
                        maxScore: maxScore
                    )
                    hasSubmitted = true
                }
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onDismiss()
                }
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(hasSubmitted)
            .padding(.top)
            
            Spacer()
        }
    }
} 