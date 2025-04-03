import SwiftUI

struct NumberMnemonicsExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NumberMnemonicsViewModel()
    
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
                case .learning:
                    learningView
                case .practice:
                    practiceView
                case .memorizing:
                    memorizingView
                case .recall:
                    recallView
                case .feedback:
                    feedbackView
                case .results:
                    resultsView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Action button with visual feedback
            Button {
                viewModel.handleActionButton()
            } label: {
                Text(viewModel.actionButtonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.isActionButtonDisabled ? Color.blue.opacity(0.5) : Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            .disabled(viewModel.isActionButtonDisabled)
        }
        .navigationTitle("Number Mnemonics")
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
                Image(systemName: "123.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                
                Text("Number-Shape Association")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("About this memory technique:")
                        .font(.headline)
                    
                    NumberMnemonicPointView(text: "Number-Shape associations help you remember numbers by converting them to memorable images")
                    
                    NumberMnemonicPointView(text: "This technique is used by memory champions to memorize long number sequences")
                    
                    NumberMnemonicPointView(text: "Once mastered, you can use it to remember phone numbers, PINs, and dates")
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.7))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Text("This exercise will teach you a simple number-shape system and help you practice memorizing digit sequences.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
    
    private var learningView: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("The Number-Shape System")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("First, learn these number-shape associations:")
                    .font(.headline)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                    ForEach(viewModel.numberShapeSystem) { association in
                        VStack(spacing: 8) {
                            HStack(spacing: 16) {
                                Text("\(association.number)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.blue)
                                
                                Image(systemName: association.icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                            }
                            
                            Text(association.shape)
                                .font(.headline)
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6).opacity(0.7))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Text("Take a moment to visualize each number as its corresponding shape")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Add a skip practice button
                Button("Skip Practice - Start Memorizing") {
                    viewModel.skipPracticePhase()
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1.5)
                )
                .padding(.top, 15)
            }
        }
    }
    
    private var practiceView: some View {
        VStack(spacing: 20) {
            Text("Practice Associations")
                .font(.title3)
                .fontWeight(.bold)
            
            if let currentAssociation = viewModel.currentPracticeItem {
                VStack(spacing: 15) {
                    if viewModel.showPracticeAnswer {
                        VStack(spacing: 10) {
                            HStack(spacing: 20) {
                                Text("\(currentAssociation.number)")
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundColor(.blue)
                                
                                Image(systemName: currentAssociation.icon)
                                    .font(.system(size: 42))
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                            )
                            
                            Text(currentAssociation.shape)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.top, 5)
                        }
                    } else {
                        VStack(spacing: 15) {
                            Text("What shape represents:")
                                .font(.headline)
                            
                            Text("\(currentAssociation.number)")
                                .font(.system(size: 64, weight: .bold))
                                .foregroundColor(.blue)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                )
                            
                            Button("Show Answer") {
                                viewModel.showPracticeAnswer = true
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1.5)
                            )
                            .padding(.top, 10)
                        }
                    }
                }
            }
        }
    }
    
    private var memorizingView: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Memorize This Sequence")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Remember each digit as its shape:")
                    .font(.headline)
                
                // Better centering approach
                Spacer()
                    .frame(height: 40)
                
                // Center the layout itself by setting alignment
                VStack(alignment: .center) {
                    FlowLayout(spacing: 12, alignment: .center) {
                        ForEach(viewModel.currentSequence.map { String($0) }, id: \.self) { digit in
                            Text(digit)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 55, height: 55)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 40)
                
                // Use the published property instead of checking currentSequenceIndex directly
                if viewModel.showMemoryTip {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Memory Tip:")
                            .font(.headline)
                        
                        Text("Create a mental story with these shapes. For example, if the sequence is 1-5-9, imagine a pencil (1) hanging from a hook (5) next to a balloon (9).")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.7))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                
                if viewModel.memorizeTimer > 0 {
                    Text("Time remaining: \(viewModel.memorizeTimer)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
            }
            .padding(.vertical)
        }
    }
    
    private var recallView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Recall the Sequence")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Enter the digits in order:")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                // User input display with centered wrapping for longer sequences
                FlowLayout(spacing: 10, alignment: .center) {
                    ForEach(0..<viewModel.currentSequence.count, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(index < viewModel.userInput.count ? Color.blue.opacity(0.2) : Color(.systemGray6))
                                .frame(width: 45, height: 45)
                            
                            if index < viewModel.userInput.count {
                                Text("\(viewModel.userInput[index])")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Number pad
                VStack(spacing: 12) {
                    ForEach(viewModel.numberPadRows, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.self) { number in
                                Button(action: {
                                    viewModel.inputDigit(number)
                                }) {
                                    if number == -1 {
                                        // Backspace
                                        Image(systemName: "delete.left")
                                            .font(.system(size: 22))
                                            .foregroundColor(.blue)
                                            .frame(width: 55, height: 55)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    } else {
                                        Text("\(number)")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.blue)
                                            .frame(width: 55, height: 55)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                }
                                .disabled(viewModel.userInput.count >= viewModel.currentSequence.count && number != -1)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private var feedbackView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isCurrentRecallCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Correct Sequence!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Not Quite Right")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                VStack(spacing: 15) {
                    Text("The sequence was:")
                        .font(.headline)
                    
                    // Center the sequence by setting alignment to center
                    FlowLayout(spacing: 10, alignment: .center) {
                        ForEach(viewModel.currentSequence.map { String($0) }, id: \.self) { digit in
                            Text(digit)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 45, height: 45)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity) // Ensure the layout takes full width
                    
                    if viewModel.isCurrentRecallCorrect {
                        Text("+\(viewModel.lastPoints) points")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    } else {
                        Text("Your answer:")
                            .font(.headline)
                            .padding(.top, 10)
                        
                        // Center user's answer as well
                        FlowLayout(spacing: 10, alignment: .center) {
                            ForEach(viewModel.userInput.map { String($0) }, id: \.self) { digit in
                                Text(digit)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, height: 40)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity) // Ensure the layout takes full width
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.7))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
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
                    
                    Text("Sequences Memorized: \(viewModel.correctSequences)/\(viewModel.totalSequences)")
                        .font(.headline)
                    
                    Text("Longest Sequence: \(viewModel.longestCorrectSequence) digits")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Text("Performance: \(viewModel.performanceRating)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.7))
                .cornerRadius(12)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("How to use this technique:")
                        .font(.headline)
                    
                    Text("• For longer numbers, group digits in pairs or triplets")
                        .font(.subheadline)
                    
                    Text("• Create vivid mental images or stories with the shapes")
                        .font(.subheadline)
                    
                    Text("• Practice daily with phone numbers or other sequences")
                        .font(.subheadline)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

// Supporting view
struct NumberMnemonicPointView: View {
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

// Add this improved FlowLayout with center alignment option
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    var alignment: HorizontalAlignment = .leading
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        let rows = arrangeSubviews(containerWidth: containerWidth, subviews: subviews)
        
        for (index, row) in rows.enumerated() {
            height += row.maxHeight
            if index < rows.count - 1 {
                height += spacing
            }
        }
        
        return CGSize(width: containerWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = arrangeSubviews(containerWidth: bounds.width, subviews: subviews)
        
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            
            // Calculate row width
            let rowWidth = row.items.reduce(0) { $0 + $1.size.width } + (CGFloat(row.items.count - 1) * spacing)
            
            // Determine starting x position based on alignment
            if alignment == .center {
                x += (bounds.width - rowWidth) / 2
            } else if alignment == .trailing {
                x += bounds.width - rowWidth
            }
            
            for item in row.items {
                let subview = subviews[item.index]
                let width = item.size.width
                let height = item.size.height
                
                let point = CGPoint(
                    x: x,
                    y: y + (row.maxHeight - height) / 2 // Center vertically in row
                )
                
                subview.place(at: point, proposal: ProposedViewSize(width: width, height: height))
                x += width + spacing
            }
            
            y += row.maxHeight + spacing
        }
    }
    
    private func arrangeSubviews(containerWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > containerWidth && !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                x = 0
            }
            
            currentRow.items.append(Item(index: index, size: size))
            x += size.width + spacing
        }
        
        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    struct Item: Equatable {
        let index: Int
        let size: CGSize
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.index == rhs.index && 
            lhs.size.width == rhs.size.width &&
            lhs.size.height == rhs.size.height
        }
    }
    
    struct Row: Equatable {
        var items: [Item] = []
        
        var maxHeight: CGFloat {
            items.map { $0.size.height }.max() ?? 0
        }
        
        static func == (lhs: Row, rhs: Row) -> Bool {
            lhs.items == rhs.items
        }
    }
}

// Define HorizontalAlignment that works with the FlowLayout
extension HorizontalAlignment {
    static let leading = HorizontalAlignment.leading
    static let center = HorizontalAlignment.center
    static let trailing = HorizontalAlignment.trailing
}

// Preview
struct NumberMnemonicsExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NumberMnemonicsExerciseView()
    }
} 