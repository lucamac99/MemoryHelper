class MemoryPalaceViewModel: ObservableObject {
    @Published var itemOptions: [MemoryItem] = []
    
    let totalRounds: Int = 5
    
    private func generateItemOptions() -> [MemoryItem] {
        guard let correctItem = correctItem else { return [] }
        
        var options = [correctItem]
        
        let distractors = items.filter { $0.id != correctItem.id }.shuffled().prefix(5)
        options.append(contentsOf: distractors)
        
        return options.shuffled()
    }
    
    func selectRecallItem(_ item: MemoryItem) {
        selectedItemId = item.id
    }
    
    func advanceMemorization() {
        memorizationIndex += 1
        
        if memorizationIndex >= rooms.count {
            recallIndex = 0
            gameState = .recallingItems
            selectedItemId = nil
            itemOptions = generateItemOptions()
        } else {
            startMemorizationTimer()
        }
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
        
        if recallIndex < rooms.count {
            itemOptions = generateItemOptions()
        }
    }
    
    func startMemorizationTimer() {
        memorizeTimer = 5
        
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
    
    private func setupExercise() {
        rooms = [
            MemoryRoom(id: "living", name: "Living Room", icon: "sofa", description: "A comfortable space with a sofa, TV, and coffee table."),
            MemoryRoom(id: "kitchen", name: "Kitchen", icon: "refrigerator", description: "A kitchen with a stove, refrigerator, and countertops."),
            MemoryRoom(id: "bedroom", name: "Bedroom", icon: "bed.double", description: "A bedroom with a bed, dresser, and nightstand."),
            MemoryRoom(id: "bathroom", name: "Bathroom", icon: "shower", description: "A bathroom with a shower, sink, and toilet.")
        ]
        
        items = [
            MemoryItem(id: "elephant", name: "Elephant", icon: "elephant"),
            MemoryItem(id: "crown", name: "Crown", icon: "crown"),
            MemoryItem(id: "key", name: "Key", icon: "key"),
            MemoryItem(id: "apple", name: "Apple", icon: "apple.logo"),
            MemoryItem(id: "sun", name: "Sun", icon: "sun.max"),
            MemoryItem(id: "umbrella", name: "Umbrella", icon: "umbrella"),
            MemoryItem(id: "car", name: "Car", icon: "car"),
            MemoryItem(id: "book", name: "Book", icon: "book"),
            MemoryItem(id: "bell", name: "Bell", icon: "bell"),
            MemoryItem(id: "guitar", name: "Guitar", icon: "guitars"),
            MemoryItem(id: "camera", name: "Camera", icon: "camera"),
            MemoryItem(id: "globe", name: "Globe", icon: "globe")
        ].shuffled()
        
        gameState = .intro
        currentRound = 1
        score = 0
        correctAnswers = 0
        selectedRoomId = nil
        selectedItemId = nil
        roomItemAssignments.removeAll()
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
                        .id(item.id)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
} 