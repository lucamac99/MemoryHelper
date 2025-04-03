import SwiftUI

struct MemoryPalaceExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MemoryPalaceViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with progress
            HStack {
                Text("Round \(viewModel.currentRound)/\(viewModel.totalRounds)")
                    .font(.headline)
                
                Spacer()
                
                Text("Score: \(viewModel.score)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            // Content based on game state
            Group {
                switch viewModel.gameState {
                case .intro:
                    introView
                case .tutorial:
                    tutorialView
                case .buildingPalace:
                    buildPalaceView
                case .memorizingItems:
                    memorizeItemsView
                case .recallingItems:
                    recallItemsView
                case .feedback:
                    feedbackView
                case .results:
                    resultsView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Improved action button with better visual feedback
            Button(viewModel.actionButtonTitle) {
                viewModel.handleActionButton()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(viewModel.isActionButtonDisabled ? Color.indigo.opacity(0.5) : Color.indigo)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .disabled(viewModel.isActionButtonDisabled)
        }
        .navigationTitle("Memory Palace")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var introView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "building.columns")
                    .font(.system(size: 60))
                    .foregroundColor(.indigo)
                    .padding(.top, 30)
                
                Text("The Memory Palace Technique")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("About this ancient technique:")
                        .font(.headline)
                    
                    MemoryPalacePointView(text: "The Memory Palace (or Method of Loci) has been used since ancient Greek and Roman times")
                    
                    MemoryPalacePointView(text: "It uses spatial memory and visualization to remember information")
                    
                    MemoryPalacePointView(text: "Memory champions use this method to memorize decks of cards, long numbers, and lists")
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.7))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Text("This exercise will guide you through creating a simple memory palace and using it to remember a list of items.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
    
    private var tutorialView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("How the Method Works")
                    .font(.title3)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Create Your Palace")
                        .font(.headline)
                    
                    Text("Imagine a familiar place (your home, a familiar route, etc). In this exercise, we'll use a simple 4-room house.")
                        .font(.subheadline)
                    
                    Text("2. Place Items in Specific Locations")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    Text("Visualize each item in a specific location. The more vivid and unusual the visualization, the better.")
                        .font(.subheadline)
                    
                    Text("3. Mentally Walk Through to Recall")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    Text("To recall the items, mentally walk through your palace and notice what items you placed in each location.")
                        .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.7))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Image("memory_palace_diagram", bundle: nil)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .shadow(radius: 2)
                    )
                    .padding(.horizontal)
                    .overlay(
                        Text("Visualize rooms in your palace")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(6)
                            .padding(10),
                        alignment: .bottom
                    )
            }
        }
    }
    
    private var buildPalaceView: some View {
        VStack(spacing: 20) {
            Text("Create Your Memory Palace")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Imagine a simple house with 4 rooms. Take a moment to visualize each room.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(viewModel.rooms) { room in
                    RoomView(room: room, isSelected: viewModel.selectedRoomId == room.id) {
                        viewModel.selectRoom(room.id)
                    }
                }
            }
            .padding()
            
            if let selectedRoom = viewModel.selectedRoom {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Room Details: \(selectedRoom.name)")
                        .font(.headline)
                    
                    Text(selectedRoom.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Visualize this room in detail. What does it look like? What features stand out?")
                        .font(.caption)
                        .padding(.top, 5)
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.7))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    private var memorizeItemsView: some View {
        VStack(spacing: 20) {
            Text("Memorize These Items")
                .font(.title3)
                .fontWeight(.bold)
            
            if let currentRoom = viewModel.currentMemorizingRoom,
               let itemToMemorize = viewModel.currentItemToMemorize {
                VStack(spacing: 15) {
                    Text("Place this item in the \(currentRoom.name):")
                        .font(.headline)
                    
                    Text(itemToMemorize.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.indigo)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.indigo.opacity(0.1))
                        )
                    
                    Image(systemName: itemToMemorize.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.indigo)
                        .padding()
                    
                    Text("Visualize this \(itemToMemorize.name) in the \(currentRoom.name)")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Memory Tip: Make it vivid, unusual, or bizarre!")
                        .font(.caption)
                        .italic()
                        .padding(.top, 5)
                }
                
                if viewModel.memorizeTimer > 0 {
                    Text("Next item in: \(viewModel.memorizeTimer)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
            }
        }
    }
    
    private var recallItemsView: some View {
        VStack(spacing: 20) {
            Text("Recall the Items")
                .font(.title3)
                .fontWeight(.bold)
            
            if let currentRoom = viewModel.currentRecallingRoom {
                VStack(spacing: 15) {
                    Text("What item did you place in the \(currentRoom.name)?")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                        ForEach(viewModel.itemOptions) { item in
                            Button(action: {
                                viewModel.selectRecallItem(item)
                            }) {
                                VStack(spacing: 10) {
                                    Image(systemName: item.icon)
                                        .font(.system(size: 30))
                                        .foregroundColor(.indigo)
                                    
                                    Text(item.name)
                                        .font(.headline)
                                }
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.selectedItemId == item.id ? 
                                              Color.indigo.opacity(0.2) : Color(.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(viewModel.selectedItemId == item.id ? 
                                                Color.indigo : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var feedbackView: some View {
        VStack(spacing: 20) {
            if viewModel.isLastSelectionCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Correct!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Wrong Answer")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
            
            if let correctItem = viewModel.correctItem, let room = viewModel.currentRecallingRoom {
                VStack(spacing: 10) {
                    Text("The correct item for the \(room.name) was:")
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        Image(systemName: correctItem.icon)
                            .font(.system(size: 30))
                            .foregroundColor(.indigo)
                        
                        Text(correctItem.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.7))
                    .cornerRadius(12)
                }
            }
            
            if viewModel.isLastSelectionCorrect {
                Text("+\(viewModel.lastPoints) points")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top, 10)
            } else {
                Text("No points awarded")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
            }
        }
    }
    
    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "trophy")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .padding(.top, 30)
                
                Text("Exercise Complete!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    Text("Your Score: \(viewModel.score)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Accuracy: \(viewModel.accuracyPercentage)%")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Items Correctly Recalled: \(viewModel.correctAnswers)/\(viewModel.totalItems)")
                            .font(.subheadline)
                        
                        Text("Memory Palace Effectiveness: \(viewModel.effectivenessRating)")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.7))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Text("The Memory Palace technique becomes more powerful with practice. Try using it for shopping lists, to-do items, or study material!")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }
        }
    }
}

// Supporting Views

struct MemoryPalacePointView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct RoomView: View {
    let room: MemoryRoom
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: room.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .indigo)
                
                Text(room.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.indigo : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.indigo : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// View Model and Data Models

class MemoryPalaceViewModel: ObservableObject {
    enum GameState {
        case intro
        case tutorial
        case buildingPalace
        case memorizingItems
        case recallingItems
        case feedback
        case results
    }
    
    @Published var gameState: GameState = .intro
    @Published var rooms: [MemoryRoom] = []
    @Published var items: [MemoryItem] = []
    @Published var selectedRoomId: String? = nil
    @Published var currentRound: Int = 1
    @Published var score: Int = 0
    @Published var memorizeTimer: Int = 0
    @Published var selectedItemId: String? = nil
    @Published var isLastSelectionCorrect: Bool = false
    @Published var lastPoints: Int = 0
    @Published var correctAnswers: Int = 0
    @Published var shouldDismiss: Bool = false
    @Published var roomItemAssignments: [String: String] = [:] // roomId: itemId
    
    let totalRounds: Int = 3
    let totalItems: Int = 4 // One item per room
    
    private var memorizationIndex: Int = 0
    private var recallIndex: Int = 0
    private var timer: Timer?
    
    var currentMemorizingRoom: MemoryRoom? {
        guard memorizationIndex < rooms.count else { return nil }
        return rooms[memorizationIndex]
    }
    
    var currentItemToMemorize: MemoryItem? {
        guard memorizationIndex < items.count else { return nil }
        return items[memorizationIndex]
    }
    
    var currentRecallingRoom: MemoryRoom? {
        guard recallIndex < rooms.count else { return nil }
        return rooms[recallIndex]
    }
    
    var correctItem: MemoryItem? {
        guard let currentRoom = currentRecallingRoom,
              let itemId = roomItemAssignments[currentRoom.id],
              let item = items.first(where: { $0.id == itemId }) else { return nil }
        return item
    }
    
    var itemOptions: [MemoryItem] {
        // Return a subset of items including the correct one
        var options = [correctItem].compactMap { $0 }
        
        // Add random distractors
        let distractors = items.filter { $0.id != correctItem?.id }.shuffled().prefix(3)
        options.append(contentsOf: distractors)
        
        return options.shuffled()
    }
    
    var selectedRoom: MemoryRoom? {
        rooms.first { $0.id == selectedRoomId }
    }
    
    var isActionButtonDisabled: Bool {
        switch gameState {
        case .recallingItems:
            return selectedItemId == nil
        case .memorizingItems:
            return memorizeTimer > 0
        case .buildingPalace:
            return selectedRoomId == nil
        default:
            return false
        }
    }
    
    var actionButtonTitle: String {
        switch gameState {
        case .intro:
            return "Continue to Tutorial"
        case .tutorial:
            return "Create My Palace"
        case .buildingPalace:
            return "Start Memorization"
        case .memorizingItems:
            return memorizeTimer > 0 ? "Visualizing..." : "Continue"
        case .recallingItems:
            return "Submit"
        case .feedback:
            return recallIndex >= rooms.count - 1 ? "See Results" : "Next Item"
        case .results:
            return "Finish Exercise"
        }
    }
    
    var accuracyPercentage: Int {
        return Int((Double(correctAnswers) / Double(totalItems)) * 100)
    }
    
    var effectivenessRating: String {
        let percentage = accuracyPercentage
        if percentage >= 90 {
            return "Excellent"
        } else if percentage >= 75 {
            return "Good"
        } else if percentage >= 50 {
            return "Adequate"
        } else {
            return "Needs Practice"
        }
    }
    
    @Published var showAlert: Bool = false
    var alertTitle: String = ""
    var alertMessage: String = ""
    
    init() {
        setupExercise()
    }
    
    deinit {
        stopTimer()
    }
    
    private func setupExercise() {
        // Create rooms
        rooms = [
            MemoryRoom(id: "living", name: "Living Room", icon: "sofa", description: "A comfortable space with a sofa, TV, and coffee table."),
            MemoryRoom(id: "kitchen", name: "Kitchen", icon: "refrigerator", description: "A kitchen with a stove, refrigerator, and countertops."),
            MemoryRoom(id: "bedroom", name: "Bedroom", icon: "bed.double", description: "A bedroom with a bed, dresser, and nightstand."),
            MemoryRoom(id: "bathroom", name: "Bathroom", icon: "shower", description: "A bathroom with a shower, sink, and toilet.")
        ]
        
        // Create items to memorize
        items = [
            MemoryItem(id: "elephant", name: "Elephant", icon: "rhinoceros"),
            MemoryItem(id: "crown", name: "Crown", icon: "crown"),
            MemoryItem(id: "key", name: "Key", icon: "key"),
            MemoryItem(id: "apple", name: "Apple", icon: "applelogo"),
            MemoryItem(id: "sun", name: "Sun", icon: "sun.max"),
            MemoryItem(id: "umbrella", name: "Umbrella", icon: "umbrella"),
            MemoryItem(id: "car", name: "Car", icon: "car"),
            MemoryItem(id: "book", name: "Book", icon: "book"),
            MemoryItem(id: "bell", name: "Bell", icon: "bell"),
            MemoryItem(id: "guitar", name: "Guitar", icon: "pianokeys"),
            MemoryItem(id: "camera", name: "Camera", icon: "camera"),
            MemoryItem(id: "globe", name: "Globe", icon: "globe")
        ].shuffled().prefix(8).map { $0 } // Take 8 random items
        
        gameState = .intro
        currentRound = 1
        score = 0
        correctAnswers = 0
        selectedRoomId = nil
        selectedItemId = nil
        roomItemAssignments.removeAll()
    }
    
    func handleActionButton() {
        switch gameState {
        case .intro:
            gameState = .tutorial
            
        case .tutorial:
            gameState = .buildingPalace
            selectedRoomId = rooms.first?.id
            
        case .buildingPalace:
            guard selectedRoomId != nil else { return }
            startMemorization()
            
        case .memorizingItems:
            if memorizeTimer <= 0 {
                advanceMemorization()
            }
            
        case .recallingItems:
            guard selectedItemId != nil else { return }
            evaluateSelection()
            
        case .feedback:
            if recallIndex >= rooms.count {
                gameState = .results
            } else {
                gameState = .recallingItems
                selectedItemId = nil
            }
            
        case .results:
            finishExercise()
        }
    }
    
    func selectRoom(_ roomId: String) {
        selectedRoomId = roomId
    }
    
    func startMemorization() {
        roomItemAssignments.removeAll()
        
        for (index, room) in rooms.enumerated() {
            if index < items.count {
                let item = items[index]
                roomItemAssignments[room.id] = item.id
                print("DEBUG: Assigned \(item.name) to \(room.name)")
            }
        }
        
        memorizationIndex = 0
        gameState = .memorizingItems
        startMemorizationTimer()
    }
    
    func advanceMemorization() {
        memorizationIndex += 1
        
        if memorizationIndex >= rooms.count {
            // All items memorized, start recall phase
            recallIndex = 0
            gameState = .recallingItems
            selectedItemId = nil
        } else {
            // Continue to next item
            startMemorizationTimer()
        }
    }
    
    func startMemorizationTimer() {
        memorizeTimer = 8 // Seconds to memorize each item
        
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.memorizeTimer > 0 {
                self.memorizeTimer -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func selectRecallItem(_ item: MemoryItem) {
        selectedItemId = item.id
    }
    
    func evaluateSelection() {
        guard let currentRoom = currentRecallingRoom,
              let correctItemId = roomItemAssignments[currentRoom.id] else {
            return
        }
        
        isLastSelectionCorrect = selectedItemId == correctItemId
        
        if isLastSelectionCorrect {
            lastPoints = 25
            score += lastPoints
            correctAnswers += 1
        } else {
            lastPoints = 0
        }
        
        gameState = .feedback
        recallIndex += 1
    }
    
    func finishExercise() {
        // Record completion with ExerciseProgressManager
        ExerciseProgressManager.shared.recordExerciseCompletion(
            exerciseId: "memoryPalace",
            score: score,
            maxScore: totalItems * 25 // Maximum possible score
        )
        
        shouldDismiss = true
    }
    
    func showErrorAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct MemoryRoom: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
}

struct MemoryItem: Identifiable {
    let id: String
    let name: String
    let icon: String
}

// Preview

struct MemoryPalaceExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryPalaceExerciseView()
    }
}
