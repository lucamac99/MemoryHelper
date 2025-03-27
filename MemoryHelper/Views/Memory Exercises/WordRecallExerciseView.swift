import SwiftUI

struct WordRecallExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameState: GameState = .ready
    @State private var currentLevel = 1
    @State private var round = 1
    @State private var score = 0
    @State private var wordsToRecall: [String] = []
    @State private var userRecalledWords: [String] = []
    @State private var currentInput = ""
    @State private var showingWords = false
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    @State private var showingResults = false
    
    let wordListsManager = WordListsManager.shared
    let maxRounds = 5
    
    enum GameState {
        case ready, studying, recalling, finished
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header info
            HStack {
                VStack(alignment: .leading) {
                    Text("Word Recall")
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
            
            // Game area
            VStack(spacing: 16) {
                if gameState == .studying {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Memorize these words:")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(wordsToRecall, id: \.self) { word in
                                    Text(word)
                                        .font(.title3)
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        
                        Spacer()
                        
                        Text("Time remaining: \(timeRemaining) seconds")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                } else if gameState == .recalling {
                    VStack(spacing: 16) {
                        Text("Recall as many words as you can")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(userRecalledWords, id: \.self) { word in
                                    HStack {
                                        Text(word)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            removeWord(word)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red.opacity(0.7))
                                                .font(.system(size: 16))
                                        }
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color.green.opacity(0.1))
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        }
                        .frame(maxHeight: 200)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        HStack {
                            TextField("Type word", text: $currentInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .submitLabel(.done)
                                .onSubmit {
                                    addWord()
                                }
                            
                            Button(action: addWord) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Button("I'm Done") {
                            submitRecall()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(8)
                        .padding(.top, 12)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                } else if gameState == .ready {
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("Instructions")
                                .font(.headline)
                            
                            Text("You will be shown a list of words to memorize for a short period of time.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                            
                            Text("After the time is up, you'll need to recall as many words as possible without seeing the original list. Type each word you remember and tap '+' or press return to add it.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                            
                            Text("This exercise helps improve verbal memory and recall, which is essential for language processing and learning.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 250)
                }
            }
            .padding(.horizontal)
            
            // Current level indicator
            if gameState == .studying || gameState == .recalling {
                HStack {
                    Text("Level \(currentLevel):")
                        .font(.footnote)
                        .fontWeight(.medium)
                    
                    Text(getLevelDescription())
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
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
                        .background(Color.green)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .navigationTitle("Word Recall")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            timer?.invalidate()
        }
        .sheet(isPresented: $showingResults) {
            WordRecallResultsView(score: score, maxScore: maxRounds * 100, level: currentLevel) {
                dismiss()
            }
        }
    }
    
    private func getLevelDescription() -> String {
        switch currentLevel {
        case 1:
            return "Basic everyday words"
        case 2:
            return "Common but less familiar words"
        case 3:
            return "Abstract or specialized words"
        default:
            return ""
        }
    }
    
    private func startGame() {
        gameState = .ready
        round = 1
        score = 0
        currentLevel = 1
        startRound()
    }
    
    private func startRound() {
        // Determine number of words based on level
        let wordCount = 3 + (currentLevel - 1) * 2
        
        // Get words from the manager
        wordsToRecall = wordListsManager.getRandomWordsForLevel(level: currentLevel, count: wordCount)
        
        // Set studying time based on level and word count
        timeRemaining = wordCount * (4 - currentLevel/2)
        
        userRecalledWords = []
        currentInput = ""
        
        // Show words
        gameState = .studying
        showingWords = true
        
        // Start countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                showingWords = false
                gameState = .recalling
                timer?.invalidate()
            }
        }
    }
    
    private func addWord() {
        let word = currentInput.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !word.isEmpty && !userRecalledWords.contains(word) {
            userRecalledWords.append(word)
            currentInput = ""
            
            // Add subtle haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    private func removeWord(_ word: String) {
        if let index = userRecalledWords.firstIndex(of: word) {
            userRecalledWords.remove(at: index)
            
            // Add subtle haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    private func submitRecall() {
        // Calculate score based on correct recalls
        var correctRecalls = 0
        var incorrectRecalls = 0
        
        // Check which words were correctly recalled
        for word in userRecalledWords {
            if wordsToRecall.contains(word) {
                correctRecalls += 1
            } else {
                incorrectRecalls += 1
            }
        }
        
        // Score calculation: % of correct words recalled minus penalty for incorrect words
        let totalPossible = wordsToRecall.count
        let percentageRecalled = Double(correctRecalls) / Double(totalPossible)
        let penaltyFactor = min(Double(incorrectRecalls) * 0.1, 0.3) // Max 30% penalty
        
        let roundScore = max(0, Int((percentageRecalled - penaltyFactor) * 100))
        score += roundScore
        
        if round >= maxRounds {
            gameState = .finished
            showingResults = true
        } else {
            round += 1
            // Increase difficulty every 2 rounds
            if round % 2 == 0 && currentLevel < 3 {
                currentLevel += 1
            }
            startRound()
        }
    }
}

struct WordRecallResultsView: View {
    let score: Int
    let maxScore: Int
    let level: Int
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var hasSubmitted = false
    
    var percentageScore: Int {
        return Int((Double(score) / Double(maxScore)) * 100)
    }
    
    var feedbackMessage: String {
        if percentageScore > 80 {
            return "Excellent recall ability! Your verbal memory is impressive."
        } else if percentageScore > 60 {
            return "Good job! Your verbal memory is solid."
        } else {
            return "Regular practice will help improve your verbal memory."
        }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .padding(.top, 30)
            
            Text("Exercise Complete!")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                ScoreRow(title: "Final Score", value: "\(score) points")
                ScoreRow(title: "Level Reached", value: "\(level)")
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
            
            Text("Word recall exercises strengthen your verbal memory, which is essential for vocabulary development, language learning, and everyday communication.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                if !hasSubmitted {
                    // Record exercise completion only once
                    ExerciseProgressManager.shared.recordExerciseCompletion(
                        exerciseId: "wordRecall",
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
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(hasSubmitted)
            .padding(.top)
            
            Spacer()
        }
    }
} 