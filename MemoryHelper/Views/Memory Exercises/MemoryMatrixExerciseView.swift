import SwiftUI

struct MemoryMatrixExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameState: GameState = .ready
    @State private var gridSize = 4
    @State private var round = 1
    @State private var score = 0
    @State private var pattern: [Bool] = []
    @State private var userSelection: [Bool] = []
    @State private var showPattern = false
    @State private var showingResults = false
    @State private var patternTimer: Timer?
    
    let maxRounds = 10
    let patternDisplayTime = 1.5 // seconds
    
    enum GameState {
        case ready, showingPattern, inputting, finished
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header info
            HStack {
                VStack(alignment: .leading) {
                    Text("Memory Matrix")
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
            
            // Game grid
            VStack(spacing: 0) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: gridSize), spacing: 4) {
                    ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                        let isPattern = showPattern && pattern.count > index && pattern[index]
                        let isSelected = userSelection.count > index && userSelection[index]
                        
                        Rectangle()
                            .fill(getCellColor(pattern: isPattern, selected: isSelected))
                            .frame(height: 300 / CGFloat(gridSize))
                            .cornerRadius(4)
                            .onTapGesture {
                                if gameState == .inputting {
                                    toggleSelection(at: index)
                                }
                            }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Instructions or controls
            if gameState == .ready {
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text("Memorize the pattern shown on the grid, then recreate it by tapping the correct cells.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        
                        Text("The patterns will become more complex as you progress. Try to focus on the overall shape rather than individual cells for better results.")
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
            } else if gameState == .showingPattern {
                Text("Memorize this pattern!")
                    .font(.headline)
                    .foregroundColor(.purple)
            } else if gameState == .inputting {
                Text("Recreate the pattern")
                    .font(.headline)
                
                Button("Submit") {
                    submitPattern()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.purple)
                .cornerRadius(8)
                .padding(.top, 8)
            }
            
            Spacer()
            
            // Start button
            if gameState == .ready {
                Button(action: startGame) {
                    Text("Start Exercise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.purple)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .navigationTitle("Memory Matrix")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            patternTimer?.invalidate()
        }
        .sheet(isPresented: $showingResults) {
            MatrixResultsView(score: score, maxScore: maxRounds * 100) {
                dismiss()
            }
        }
    }
    
    private func startGame() {
        gameState = .ready
        round = 1
        score = 0
        generatePattern()
        startRound()
    }
    
    private func startRound() {
        showPattern = true
        gameState = .showingPattern
        userSelection = Array(repeating: false, count: gridSize * gridSize)
        
        // Show pattern for a limited time
        patternTimer = Timer.scheduledTimer(withTimeInterval: patternDisplayTime, repeats: false) { _ in
            showPattern = false
            gameState = .inputting
        }
    }
    
    private func generatePattern() {
        let cellCount = gridSize * gridSize
        let patternCount = min(round + 2, cellCount / 2) // Increases with rounds
        
        // Create an empty pattern
        pattern = Array(repeating: false, count: cellCount)
        
        // Randomly set `patternCount` cells to true
        var remainingCells = patternCount
        while remainingCells > 0 {
            let randomIndex = Int.random(in: 0..<cellCount)
            if !pattern[randomIndex] {
                pattern[randomIndex] = true
                remainingCells -= 1
            }
        }
    }
    
    private func toggleSelection(at index: Int) {
        if index < userSelection.count {
            userSelection[index].toggle()
        }
    }
    
    private func submitPattern() {
        // Calculate correctness
        var correctCells = 0
        for i in 0..<pattern.count {
            if pattern[i] == userSelection[i] {
                correctCells += 1
            }
        }
        
        let totalCells = pattern.count
        let percentage = Double(correctCells) / Double(totalCells)
        let roundScore = Int(percentage * 100)
        score += roundScore
        
        if round >= maxRounds {
            gameState = .finished
            showingResults = true
        } else {
            round += 1
            // Increase difficulty every few rounds
            if round % 3 == 0 && gridSize < 6 {
                gridSize += 1
            }
            generatePattern()
            startRound()
        }
    }
    
    private func getCellColor(pattern: Bool, selected: Bool) -> Color {
        if pattern {
            return .purple
        } else if selected {
            return .purple.opacity(0.5)
        } else {
            return Color(.systemGray5)
        }
    }
}

struct MatrixResultsView: View {
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
            return "Outstanding spatial memory! Your visual-spatial recall is excellent."
        } else if percentageScore > 60 {
            return "Good job! You have solid visual-spatial memory skills."
        } else {
            return "Regular practice will help improve your visual-spatial memory."
        }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)
                .padding(.top, 30)
            
            Text("Exercise Complete!")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                ScoreRow(title: "Final Score", value: "\(score) points")
                ScoreRow(title: "Accuracy", value: "\(percentageScore)%")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Text(feedbackMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("The Memory Matrix exercise improves visual-spatial memory, which helps with navigation, object recognition, and mental imagery.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                if !hasSubmitted {
                    // Record exercise completion only once
                    ExerciseProgressManager.shared.recordExerciseCompletion(
                        exerciseId: "memoryMatrix",
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
                    .background(Color.purple)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(hasSubmitted)
            .padding(.top)
            
            Spacer()
        }
    }
} 