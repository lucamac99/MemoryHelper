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
    
    // Game parameters
    let gridSize = 3
    let positions = 9
    let letters = ["C", "H", "K", "L", "Q", "R", "S", "T"]
    let roundDuration = 2.5 // seconds per stimulus
    
    /* private var audioPlayers: [AVAudioPlayer] = [] */
    
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
            
            // Instructions
            if gameState == .ready {
                /* VStack(spacing: 16) {
                    Text("Instructions")
                        .font(.headline)
                    
                    Text("Watch for matches that occurred exactly \(currentLevel) step(s) ago:")
                        .font(.subheadline)
                    
                    HStack(spacing: 20) {
                        Button {
                            checkPositionMatch()
                        } label: {
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
                        }
                        
                        Button {
                            checkLetterMatch()
                        } label: {
                            VStack {
                                Image(systemName: "character")
                                    .font(.system(size: 24))
                                Text("Sound Match")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    Text("If you see a position or hear a letter that matches what appeared \(currentLevel) step(s) ago, tap the corresponding button.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal) */
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text("Watch for matches that occurred exactly \(currentLevel) step(s) ago:")
                            .font(.subheadline)
                        
                        HStack(spacing: 20) {
                            Button {
                                checkPositionMatch()
                            } label: {
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
                            }
                            
                            Button {
                                checkLetterMatch()
                            } label: {
                                VStack {
                                    Image(systemName: "ear")
                                    Text("Letter Match")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        Text("If you see a position or letter that matches what appeared \(currentLevel) step(s) ago, tap the corresponding button. For example, in a 1-back task, you'd tap 'Position Match' if the current blue square is in the same position as the previous one.")
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
                .frame(maxHeight: 250)
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
                    
                    Button {
                        checkLetterMatch()
                    } label: {
                        /* Image(systemName: "ear") */
                        Image(systemName: "character")
                            .font(.system(size: 24))
                            .frame(width: 60, height: 60)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .clipShape(Circle())
                    }
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
            timer?.invalidate()
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(score: score, totalRounds: totalRounds, level: currentLevel) {
                dismiss()
            }
        }
    }
    
    private func startGame() {
        // Set up audio
        /* prepareAudioPlayers() */
        
        // Generate sequence
        sequence = (0..<totalRounds).map { _ in
            (Int.random(in: 0..<positions), letters.randomElement()!)
        }
        
        gameState = .playing
        currentIndex = 0
        score = 0
        round = 1
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: roundDuration, repeats: true) { _ in
            nextRound()
        }
    }
    
    private func pauseGame() {
        gameState = .paused
        timer?.invalidate()
    }
    
    private func resumeGame() {
        gameState = .playing
        
        // Restart timer
        timer = Timer.scheduledTimer(withTimeInterval: roundDuration, repeats: true) { _ in
            nextRound()
        }
    }
    
    private func nextRound() {
        /* if currentIndex < sequence.count {
            // Play the sound for the current letter
            let letterIndex = letters.firstIndex(of: sequence[currentIndex].letter) ?? 0
            if letterIndex < audioPlayers.count {
                audioPlayers[letterIndex].play()
            }
        } */
        
        currentIndex += 1
        round += 1
        
        if currentIndex >= sequence.count {
            endGame()
            return
        }
    }
    
    private func checkPositionMatch() {
        if gameState != .playing || currentIndex < currentLevel {
            return
        }
        
        let currentPosition = sequence[currentIndex].position
        let nBackPosition = sequence[currentIndex - currentLevel].position
        
        if currentPosition == nBackPosition {
            score += 10
        } else {
            score = max(0, score - 5)
        }
    }
    
    private func checkLetterMatch() {
        if gameState != .playing || currentIndex < currentLevel {
            return
        }
        
        let currentLetter = sequence[currentIndex].letter
        let nBackLetter = sequence[currentIndex - currentLevel].letter
        
        if currentLetter == nBackLetter {
            score += 10
        } else {
            score = max(0, score - 5)
        }
    }
    
    private func endGame() {
        gameState = .finished
        timer?.invalidate()
        showingResults = true
    }
    
    /* private func prepareAudioPlayers() {
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
            }
        }
    } */
}

struct ResultsView: View {
    let score: Int
    let totalRounds: Int
    let level: Int
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var hasSubmitted = false
    
    var percentageScore: Int {
        return Int((Double(score) / Double(totalRounds * 20)) * 100)
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
    
    var body: some View {
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
                        maxScore: totalRounds * 20
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
            .padding(.top)
            
            Spacer()
        }
    }
} 