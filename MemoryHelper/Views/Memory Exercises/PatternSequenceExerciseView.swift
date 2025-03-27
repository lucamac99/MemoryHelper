import SwiftUI

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
                if userSequence == sequence {
                    Text("Correct!")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Text("Incorrect")
                        .font(.headline)
                        .foregroundColor(.red)
                }
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
                    
                    // Show the current expected input vs user's actual input
                    if !userSequence.isEmpty && userSequence.count <= sequence.count {
                        HStack(spacing: 8) {
                            ForEach(0..<min(5, userSequence.count), id: \.self) { index in
                                let isCorrect = index < sequence.count && userSequence[index] == sequence[index]
                                
                                Text("\(index + 1)")
                                    .font(.caption2)
                                    .foregroundColor(isCorrect ? .green : .red)
                                    .frame(width: 20, height: 20)
                                    .background(
                                        Circle()
                                            .stroke(isCorrect ? Color.green : Color.red, lineWidth: 1)
                                    )
                            }
                            
                            if userSequence.count > 5 {
                                Text("...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
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
            PatternSequenceResultsView(score: score, maxScore: maxRounds * 100) {
                dismiss()
            }
        }
    }
    
    private func startGame() {
        gameState = .ready
        round = 1
        score = 0
        generateSequence()
        showSequence()
    }
    
    private func generateSequence() {
        let sequenceLength = baseSequenceLength + (round - 1) / 2 // Increase length every 2 rounds
        
        // Create a sequence that might include repeating cells
        sequence = []
        for _ in 0..<sequenceLength {
            // Intentionally add some repetition (25% chance to repeat if there's a previous cell)
            if !sequence.isEmpty && Int.random(in: 0...3) == 0 {
                sequence.append(sequence.last!) // Repeat the last cell
            } else {
                sequence.append(Int.random(in: 0..<cellCount))
            }
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
        
        // Calculate score
        let correct = userSequence == sequence
        
        // Base score calculation
        let baseScore = correct ? 100 : 0
        
        // Add bonus points for longer sequences when correct
        let sequenceBonus = correct ? min(sequence.count * 5, 50) : 0
        
        // Partial credit for partially correct sequences
        var partialCredit = 0
        if !correct {
            // Count correct positions
            var correctPositions = 0
            for i in 0..<min(userSequence.count, sequence.count) {
                if userSequence[i] == sequence[i] {
                    correctPositions += 1
                }
            }
            
            // Award partial credit based on how many positions were correct
            partialCredit = Int(Double(correctPositions) / Double(sequence.count) * 50)
        }
        
        let roundScore = baseScore + sequenceBonus + partialCredit
        score += roundScore
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
}

struct PatternSequenceResultsView: View {
    let score: Int
    let maxScore: Int
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var hasSubmitted = false
    
    var percentageScore: Int {
        return Int((Double(score) / Double(maxScore)) * 100)
    }
    
    var feedbackMessage: String {
        if percentageScore > 80 {
            return "Excellent sequencing ability! Your working memory is impressive."
        } else if percentageScore > 60 {
            return "Good job! You show solid sequence memory skills."
        } else {
            return "Regular practice will help improve your sequence memory."
        }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .padding(.top, 30)
            
            Text("Exercise Complete!")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                ScoreRow(title: "Final Score", value: "\(score) points")
                ScoreRow(title: "Performance", value: "\(percentageScore)%")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Text(feedbackMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Pattern sequence exercises strengthen working memory and attention to order, which is essential for following directions, learning procedures, and remembering PIN numbers or passwords.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                if !hasSubmitted {
                    // Record exercise completion only once
                    ExerciseProgressManager.shared.recordExerciseCompletion(
                        exerciseId: "patternSequence",
                        score: score,
                        maxScore: maxScore
                    )
                    hasSubmitted = true
                }
                // Dismiss the sheet first
                dismiss()
                // Then dismiss the exercise view
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