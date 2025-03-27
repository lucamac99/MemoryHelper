import SwiftUI

struct MemoryExercisesView: View {
    @State private var selectedCategory: ExerciseCategory = .all
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var progressManager = ExerciseProgressManager.shared
    
    enum ExerciseCategory: String, CaseIterable {
        case all = "All"
        case working = "Working Memory"
        case spatial = "Spatial Memory"
        case verbal = "Verbal Memory"
        case attention = "Attention"
        
        var icon: String {
            switch self {
            case .all: return "brain"
            case .working: return "cpu"
            case .spatial: return "map"
            case .verbal: return "text.book.closed"
            case .attention: return "eye"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Category selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ExerciseCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    withAnimation {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Stats overview (only if there are completed exercises)
                    if !progressManager.exerciseStats.isEmpty {
                        ExerciseStatsView()
                    }
                    
                    // Exercise list
                    VStack(alignment: .leading) {
                        Text("Available Exercises")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(filteredExercises) { exercise in
                                NavigationLink(destination: exerciseDestination(for: exercise)) {
                                    ExerciseCard(
                                        exercise: exercise,
                                        stats: progressManager.exerciseStats[exercise.id]
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Why Train Your Memory?")
                            .font(.headline)
                        
                        Text("Regular memory training has been shown to improve cognitive function, enhance focus, and may help reduce the risk of cognitive decline. These exercises are based on scientifically validated approaches.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding(.vertical)
            }
            .navigationTitle("Memory Training")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: MemoryProgressView()) {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
                }
            }
        }
    }
    
    private var filteredExercises: [MemoryExercise] {
        if selectedCategory == .all {
            return MemoryExercise.allExercises
        } else {
            return MemoryExercise.allExercises.filter { $0.category == selectedCategory }
        }
    }
    
    @ViewBuilder
    private func exerciseDestination(for exercise: MemoryExercise) -> some View {
        switch exercise.id {
        case "dualNBack":
            DualNBackExerciseView()
        case "memoryMatrix":
            MemoryMatrixExerciseView()
        case "wordRecall":
            WordRecallExerciseView()
        case "patternSequence":
            PatternSequenceExerciseView()
        case "attentionFocus":
            AttentionFocusExerciseView()
        case "memoryPalace":
            MemoryPalaceExerciseView()
        default:
            // Placeholder for exercises not yet implemented
            ComingSoonExerciseView(exercise: exercise)
        }
    }
}

struct CategoryButton: View {
    let category: MemoryExercisesView.ExerciseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray6).opacity(0.5))
            )
            .foregroundColor(isSelected ? .blue : .secondary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

struct ExerciseCard: View {
    let exercise: MemoryExercise
    let stats: ExerciseStat?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise icon
            HStack {
                Image(systemName: exercise.icon)
                    .font(.system(size: 24))
                    .foregroundColor(exercise.color)
                    .frame(width: 44, height: 44)
                    .background(exercise.color.opacity(0.1))
                    .clipShape(Circle())
                
                Spacer()
                
                if let stats = stats, stats.completedCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        
                        Text("\(Int(stats.highScore))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Exercise name
            Text(exercise.name)
                .font(.headline)
                .lineLimit(2)
            
            // Difficulty level
            HStack {
                ForEach(0..<5) { index in
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(index < exercise.difficulty ? exercise.color : Color.gray.opacity(0.3))
                }
                
                Spacer()
                
                Text(exercise.timeDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Last played (if applicable)
            if let stats = stats, let lastPlayed = stats.lastCompletedDate {
                Text("Last played: \(timeAgo(from: lastPlayed))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(height: 160)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct MemoryExercise: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: MemoryExercisesView.ExerciseCategory
    let difficulty: Int // 1-5
    let timeInMinutes: Int
    let color: Color
    
    var timeDescription: String {
        return "\(timeInMinutes) min"
    }
    
    static let allExercises: [MemoryExercise] = [
        MemoryExercise(
            id: "dualNBack",
            name: "Dual N-Back",
            description: "A scientifically-validated working memory exercise that trains your brain to hold and manipulate multiple pieces of information simultaneously.",
            icon: "brain.head.profile",
            category: .working,
            difficulty: 4,
            timeInMinutes: 5,
            color: .blue
        ),
        MemoryExercise(
            id: "memoryMatrix",
            name: "Memory Matrix",
            description: "Enhance your visual-spatial memory by remembering patterns on a grid.",
            icon: "square.grid.3x3.fill",
            category: .spatial,
            difficulty: 3,
            timeInMinutes: 3,
            color: .purple
        ),
        MemoryExercise(
            id: "wordRecall",
            name: "Word Recall",
            description: "Improve verbal memory by recalling lists of words using proven memory techniques.",
            icon: "text.book.closed",
            category: .verbal,
            difficulty: 2,
            timeInMinutes: 4,
            color: .green
        ),
        MemoryExercise(
            id: "patternSequence",
            name: "Pattern Sequence",
            description: "Remember and reproduce increasingly complex sequences to boost working memory capacity.",
            icon: "arrow.left.arrow.right",
            category: .working,
            difficulty: 3,
            timeInMinutes: 4,
            color: .orange
        ),
        MemoryExercise(
            id: "attentionFocus",
            name: "Attention Focus",
            description: "Train selective attention to improve memory encoding and retrieval.",
            icon: "eye",
            category: .attention,
            difficulty: 2,
            timeInMinutes: 3,
            color: .red
        ),
        MemoryExercise(
            id: "memoryPalace",
            name: "Memory Palace",
            description: "Learn the ancient 'Method of Loci' used by memory champions to remember large amounts of information.",
            icon: "building.columns",
            category: .spatial,
            difficulty: 4,
            timeInMinutes: 6,
            color: .indigo
        )
    ]
}

struct ComingSoonExerciseView: View {
    let exercise: MemoryExercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: exercise.icon)
                .font(.system(size: 70))
                .foregroundColor(exercise.color)
                .padding(.top, 60)
            
            Text(exercise.name)
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                Text("Coming Soon")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(exercise.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.7))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Button("Back") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(exercise.color)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
} 