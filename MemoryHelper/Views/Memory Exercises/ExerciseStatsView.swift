import SwiftUI

struct ExerciseStatsView: View {
    @ObservedObject private var progressManager = ExerciseProgressManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Progress")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(MemoryExercise.allExercises) { exercise in
                        NavigationLink(destination: exerciseDestination(for: exercise)) {
                            ExerciseStatCard(
                                exercise: exercise,
                                stats: progressManager.exerciseStats[exercise.id] ?? ExerciseStat()
                            )
                        }
                        .buttonStyle(PlainButtonStyle()) // This prevents the default button styling
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func exerciseDestination(for exercise: MemoryExercise) -> some View {
        switch exercise.id {
        case "dualNBack":
            DualNBackExerciseView()
                .navigationTitle("Dual N-Back")
                .navigationBarTitleDisplayMode(.inline)
        case "attentionFocus":
            AttentionFocusExerciseView()
                .navigationTitle("Attention Focus")
                .navigationBarTitleDisplayMode(.inline)
        default:
            Text("Exercise not available")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ExerciseStatCard: View {
    let exercise: MemoryExercise
    let stats: ExerciseStat
    
    var formattedDate: String {
        if let date = stats.lastCompletedDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return formatter.localizedString(for: date, relativeTo: Date())
        } else {
            return "Never"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: exercise.icon)
                    .foregroundColor(exercise.color)
                
                Text(exercise.name)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            // Stats
            VStack(alignment: .leading, spacing: 8) {
                ProgressRow(
                    title: "Exercises",
                    value: "\(stats.completedCount)",
                    icon: "checkmark.circle.fill",
                    color: exercise.color
                )
                
                ProgressRow(
                    title: "High Score",
                    value: stats.highScore > 0 ? "\(Int(stats.highScore))%" : "—",
                    icon: "trophy.fill",
                    color: exercise.color
                )
                
                ProgressRow(
                    title: "Last Played",
                    value: formattedDate,
                    icon: "clock.fill",
                    color: exercise.color
                )
            }
            
            // Progress bar
            if stats.completedCount > 0 {
                ProgressBar(value: stats.highScore / 100, color: exercise.color)
                    .frame(height: 8)
            } else {
                Text("Not started yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 240)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}

struct ProgressRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color.opacity(0.8)) // Match the exercise color
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color) // Use exercise color for the value
        }
    }
}

struct ProgressBar: View {
    var value: Double // 0.0 to 1.0
    var color: Color // Exercise-specific color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .cornerRadius(5)
                
                Rectangle()
                    .fill(color) // Use the exercise color instead of generic blue
                    .frame(width: geometry.size.width * CGFloat(value))
                    .cornerRadius(5)
            }
        }
    }
} 