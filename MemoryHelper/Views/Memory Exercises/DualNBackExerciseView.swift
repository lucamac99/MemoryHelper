import SwiftUI
import AVFoundation

struct DualNBackExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameState: GameState = .ready
    @State private var currentLevel = 1 // n-back level
    @State private var score = 0
    @State private var round = 0
    @State private var totalRounds = 20
    @State private var sequence: [(position: Int, letter: String)] = []
    @State private var currentIndex = 0
    @State private var timer: Timer?
    @State private var showingResults = false
    @State private var audioPlayers: [AVAudioPlayer] = []
    @State private var positionMatches: [Bool] = []
    @State private var letterMatches: [Bool] = []
    @State private var userResponses: [(positionResponse: Bool?, letterResponse: Bool?)] = []
    @State private var feedbackMessage: String = ""
    @State private var showFeedback: Bool = false
    @State private var timeRemaining: Double = 2.5
    @State private var canRespondInThisRound = true
    
    // Performance tracking
    @State private var correctPositionClicks = 0
    @State private var incorrectPositionClicks = 0
    @State private var missedPositionClicks = 0
    @State private var correctLetterClicks = 0
    @State private var incorrectLetterClicks = 0
    @State private var missedLetterClicks = 0
    
    // Game parameters
    let gridSize = 3
    let positions = 9
    let letters = ["A", "B", "C", "D", "E", "F", "G"]
    let roundDuration = 2.5 // seconds per stimulus
    
    enum GameState {
        case ready, playing, paused, finished
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header info
            HStack {
                VStack(alignment: .leading) {
                    Text("Dual \(currentLevel)-Back")
                        .font(.headline)
                    Text("Round: \(round)/\(totalRounds)")
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
            VStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridSize), spacing: 8) {
                    ForEach(0..<positions, id: \.self) { position in
                        let isActive = gameState == .playing && currentIndex < sequence.count && sequence[currentIndex].position == position
                        
                        Rectangle()
                            .fill(isActive ? Color.blue : Color(.systemGray5))
                            .frame(height: 80)
                            .cornerRadius(8)
                            .overlay(
                                isActive ?
                                Text(sequence[currentIndex].letter)
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                : nil
                            )
                    }
                }
            }
            .padding()
            
            // Timer bar (only visible during play)
            if gameState == .playing {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: geometry.size.width, height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(timeRemaining / roundDuration), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal)
            }
            
            // Feedback message when playing
            if gameState == .playing && showFeedback {
                Text(feedbackMessage)
                    .font(.callout)
                    .foregroundColor(feedbackMessage.contains("Correct") ? .green : .red)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            // Instructions
            if gameState == .ready {
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text("Watch for matches that occurred exactly \(currentLevel) step(s) ago:")
                            .font(.subheadline)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Image(systemName: "square.grid.3x3.fill")
                                    .font(.system(size: 24))
                                Text("Position Match")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            
                            VStack {
                                Image(systemName: "ear")
                                    .font(.system(size: 24))
                                Text("Letter Match")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Text("How to play:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("1. You'll see a blue square with a letter that will also be spoken.")
                                .font(.caption)
                            
                            Text("2. Only tap when you detect a match with \(currentLevel) step(s) ago:")
                                .font(.caption)
                                .padding(.top, 2)
                            
                            Text("• Tap 'Position Match' if the position matches")
                                .font(.caption)
                                .padding(.leading, 10)
                            
                            Text("• Tap 'Letter Match' if the letter matches")
                                .font(.caption)
                                .padding(.leading, 10)
                            
                            Text("3. Do NOT tap if there is no match.")
                                .font(.caption)
                                .padding(.top, 2)
                            
                            Text("4. Scoring: +10 for correct responses (including not tapping when there's no match), -5 for incorrect.")
                                .font(.caption)
                                .padding(.top, 2)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .frame(maxHeight: 300)
            } else {
                // Game controls
                HStack(spacing: 40) {
                    Button {
                        checkPositionMatch()
                    } label: {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 24))
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Circle())
                    }
                    .disabled(gameState != .playing || currentIndex < currentLevel || !canRespondInThisRound)
                    
                    Button {
                        checkLetterMatch()
                    } label: {
                        Image(systemName: "ear")
                            .font(.system(size: 24))
                            .frame(width: 60, height: 60)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .clipShape(Circle())
                    }
                    .disabled(gameState != .playing || currentIndex < currentLevel || !canRespondInThisRound)
                }
                .padding(.top)
            }
            
            Spacer()
            
            // Start/finish button
            if gameState == .ready {
                Button(action: startGame) {
                    Text("Start Exercise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            } else if gameState == .paused {
                Button(action: resumeGame) {
                    Text("Resume")
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
        .navigationTitle("Dual N-Back")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if gameState == .playing {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Pause") {
                        pauseGame()
                    }
                }
            }
        }
        .onDisappear {
            stopAllAudio()
            timer?.invalidate()
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(
                score: score,
                totalRounds: totalRounds,
                level: currentLevel,
                correctPosition: correctPositionClicks,
                missedPosition: missedPositionClicks,
                incorrectPosition: incorrectPositionClicks,
                correctLetter: correctLetterClicks,
                missedLetter: missedLetterClicks,
                incorrectLetter: incorrectLetterClicks,
                onDismiss: {
                    dismiss()
                }
            )
        }
    }
    
    private func startGame() {
        // Set up audio
        prepareAudioPlayers()
        
        // Reset performance metrics
        correctPositionClicks = 0
        incorrectPositionClicks = 0
        missedPositionClicks = 0
        correctLetterClicks = 0
        incorrectLetterClicks = 0
        missedLetterClicks = 0
        
        // Generate sequence with controlled matches
        generateSequence()
        
        gameState = .playing
        currentIndex = 0
        score = 0
        round = 1
        userResponses = Array(repeating: (nil, nil), count: totalRounds)
        showFeedback = false
        timeRemaining = roundDuration
        canRespondInThisRound = true
        
        // Start the first stimulus
        displayCurrentStimulus()
        
        // Create a timer that fires more frequently to update the progress bar
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0.1 {
                timeRemaining -= 0.1
            } else {
                // Time's up for this round
                evaluateRound()
                nextRound()
            }
        }
    }
    
    private func generateSequence() {
        sequence = []
        positionMatches = []
        letterMatches = []
        
        // First n stimuli (where n is level) are completely random
        for _ in 0..<currentLevel {
            sequence.append((Int.random(in: 0..<positions), letters.randomElement()!))
            positionMatches.append(false)  // No matches possible for first n stimuli
            letterMatches.append(false)
        }
        
        // Generate the rest with controlled matches
        for i in currentLevel..<totalRounds {
            let shouldMatchPosition = Double.random(in: 0...1) < 0.3  // 30% chance of position match
            let shouldMatchLetter = Double.random(in: 0...1) < 0.3    // 30% chance of letter match
            
            let nBackPosition = sequence[i - currentLevel].position
            let nBackLetter = sequence[i - currentLevel].letter
            
            // Determine position
            let position: Int
            if shouldMatchPosition {
                position = nBackPosition
            } else {
                // Ensure we get a different position than n-back
                var newPosition: Int
                repeat {
                    newPosition = Int.random(in: 0..<positions)
                } while newPosition == nBackPosition
                position = newPosition
            }
            
            // Determine letter
            let letter: String
            if shouldMatchLetter {
                letter = nBackLetter
            } else {
                // Ensure we get a different letter than n-back
                var newLetter: String
                repeat {
                    newLetter = letters.randomElement()!
                } while newLetter == nBackLetter
                letter = newLetter
            }
            
            sequence.append((position, letter))
            positionMatches.append(shouldMatchPosition)
            letterMatches.append(shouldMatchLetter)
        }
    }
    
    private func displayCurrentStimulus() {
        // Play the sound for the current letter
        if currentIndex < sequence.count {
            let letterIndex = letters.firstIndex(of: sequence[currentIndex].letter) ?? 0
            if letterIndex < audioPlayers.count {
                audioPlayers[letterIndex].play()
            }
        }
    }
    
    private func pauseGame() {
        gameState = .paused
        timer?.invalidate()
        stopAllAudio()
    }
    
    private func resumeGame() {
        gameState = .playing
        
        // Restart timer with current time remaining
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0.1 {
                timeRemaining -= 0.1
            } else {
                evaluateRound()
                nextRound()
            }
        }
    }
    
    private func evaluateRound() {
        // Only evaluate rounds after we have enough history (n-back level)
        if currentIndex >= currentLevel {
            // Position match evaluation
            if positionMatches[currentIndex] {
                if userResponses[currentIndex].positionResponse == true {
                    // Already awarded points in checkPositionMatch
                } else {
                    // Missed a match
                    missedPositionClicks += 1
                }
            } else {
                if userResponses[currentIndex].positionResponse != true {
                    // Correctly didn't click for non-match
                    score += 5
                }
                // Incorrect clicks already handled in checkPositionMatch
            }
            
            // Letter match evaluation
            if letterMatches[currentIndex] {
                if userResponses[currentIndex].letterResponse == true {
                    // Already awarded points in checkLetterMatch
                } else {
                    // Missed a match
                    missedLetterClicks += 1
                }
            } else {
                if userResponses[currentIndex].letterResponse != true {
                    // Correctly didn't click for non-match
                    score += 5
                }
                // Incorrect clicks already handled in checkLetterMatch
            }
        }
    }
    
    private func nextRound() {
        // Reset for next round
        timeRemaining = roundDuration
        canRespondInThisRound = true
        showFeedback = false
        
        // Move to next item
        currentIndex += 1
        round += 1
        
        if currentIndex >= sequence.count {
            endGame()
            return
        }
        
        // Display and play the new stimulus
        displayCurrentStimulus()
    }
    
    private func checkPositionMatch() {
        if gameState != .playing || currentIndex < currentLevel || !canRespondInThisRound {
            return
        }
        
        let isMatch = positionMatches[currentIndex]
        userResponses[currentIndex].positionResponse = true
        
        if isMatch {
            score += 10
            correctPositionClicks += 1
            feedbackMessage = "Correct position match! +10 points"
        } else {
            score = max(0, score - 5)
            incorrectPositionClicks += 1
            feedbackMessage = "Incorrect! There was no position match. -5 points"
        }
        
        showFeedback = true
        // Prevent multiple responses in the same round
        canRespondInThisRound = false
    }
    
    private func checkLetterMatch() {
        if gameState != .playing || currentIndex < currentLevel || !canRespondInThisRound {
            return
        }
        
        let isMatch = letterMatches[currentIndex]
        userResponses[currentIndex].letterResponse = true
        
        if isMatch {
            score += 10
            correctLetterClicks += 1
            feedbackMessage = "Correct letter match! +10 points"
        } else {
            score = max(0, score - 5)
            incorrectLetterClicks += 1
            feedbackMessage = "Incorrect! There was no letter match. -5 points"
        }
        
        showFeedback = true
        // Prevent multiple responses in the same round
        canRespondInThisRound = false
    }
    
    private func endGame() {
        gameState = .finished
        timer?.invalidate()
        stopAllAudio()
        showingResults = true
    }
    
    private func prepareAudioPlayers() {
        // Clear any existing players
        audioPlayers = []
        
        // Create audio players for each letter
        for letter in letters {
            if let soundURL = Bundle.main.url(forResource: letter.lowercased(), withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: soundURL)
                    player.prepareToPlay()
                    audioPlayers.append(player)
                } catch {
                    print("Could not create audio player for \(letter): \(error)")
                }
            } else {
                print("Could not find audio file for \(letter)")
            }
        }
    }
    
    private func stopAllAudio() {
        for player in audioPlayers {
            if player.isPlaying {
                player.stop()
            }
        }
    }
}

struct ResultsView: View {
    let score: Int
    let totalRounds: Int
    let level: Int
    let correctPosition: Int
    let missedPosition: Int
    let incorrectPosition: Int
    let correctLetter: Int
    let missedLetter: Int
    let incorrectLetter: Int
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var hasSubmitted = false
    
    var maxPossibleScore: Int {
        // We need to calculate the actual maximum possible score based on the actual matches
        let positionMatchCount = correctPosition + missedPosition
        let letterMatchCount = correctLetter + missedLetter
        
        // Count rounds after the n-back level (when matches become possible)
        let activeRounds = totalRounds - level
        
        // Calculate maximum possible points:
        // - 10 points for each correct match identification
        // - 5 points for each correct non-match (not clicking when there's no match)
        let maxPositionPoints = (positionMatchCount * 10) + ((activeRounds - positionMatchCount) * 5)
        let maxLetterPoints = (letterMatchCount * 10) + ((activeRounds - letterMatchCount) * 5)
        
        return maxPositionPoints + maxLetterPoints
    }
    
    var percentageScore: Int {
        guard maxPossibleScore > 0 else { return 0 }
        // Calculate percentage based on actual score vs maximum possible
        return min(100, Int((Double(score) / Double(maxPossibleScore)) * 100))
    }
    
    var feedbackMessage: String {
        if percentageScore > 80 {
            return "Excellent! Try increasing the difficulty level."
        } else if percentageScore > 60 {
            return "Good job! Regular practice will improve your results."
        } else {
            return "Keep practicing to improve your working memory."
        }
    }
    
    var totalCorrectDecisions: Int {
        return correctPosition + correctLetter + 
               ((totalRounds - level - (correctPosition + missedPosition)) - incorrectPosition) +
               ((totalRounds - level - (correctLetter + missedLetter)) - incorrectLetter)
    }
    
    var totalPossibleDecisions: Int {
        return (totalRounds - level) * 2 // Position and letter decisions for each active round
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Image(systemName: "brain")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                
                Text("Exercise Complete!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    ScoreRow(title: "Final Score", value: "\(score) points")
                    ScoreRow(title: "Level", value: "\(level)-Back")
                    ScoreRow(title: "Performance", value: "\(percentageScore)%")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Performance breakdown
                VStack(alignment: .leading, spacing: 15) {
                    Text("Performance Details")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Position Matches:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("✓ Correct clicks:")
                                .font(.caption)
                            Spacer()
                            Text("\(correctPosition)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("✗ Incorrect clicks:")
                                .font(.caption)
                            Spacer()
                            Text("\(incorrectPosition)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("⦸ Missed matches:")
                                .font(.caption)
                            Spacer()
                            Text("\(missedPosition)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Letter Matches:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("✓ Correct clicks:")
                                .font(.caption)
                            Spacer()
                            Text("\(correctLetter)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("✗ Incorrect clicks:")
                                .font(.caption)
                            Spacer()
                            Text("\(incorrectLetter)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("⦸ Missed matches:")
                                .font(.caption)
                            Spacer()
                            Text("\(missedLetter)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Text("Decision Accuracy: \(Int((Double(totalCorrectDecisions) / Double(totalPossibleDecisions)) * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                
                Text(feedbackMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("The Dual N-Back exercise has been shown to improve working memory, which is essential for reasoning and problem-solving ability.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    if !hasSubmitted {
                        // Record exercise completion only once
                        ExerciseProgressManager.shared.recordExerciseCompletion(
                            exerciseId: "dualNBack",
                            score: score,
                            maxScore: maxPossibleScore
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
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(hasSubmitted)
                .padding(.bottom, 40)
            }
        }
    }
}

/* struct ScoreRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(.blue)
        }
    }
}  */