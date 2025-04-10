import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddEntry = false
    @State private var selectedEntryType = "note"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HeaderView(
                        showingAddEntry: $showingAddEntry,
                        selectedEntryType: $selectedEntryType
                    )
                    
                    // Quick Actions
                    QuickActionsView(
                        showingAddEntry: $showingAddEntry,
                        selectedEntryType: $selectedEntryType
                    )
                    
                    // Memory Exercises Preview
                    MemoryExercisesPreviewView()
                    
                    // Daily Stats
                    DailyStatsView()
                    
                    // Recent Memories
                    RecentMemoriesView()
                }
                .padding()
            }
            .navigationTitle("Memory Helper")
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView(initialType: selectedEntryType)
            }
        }
    }
}

struct HeaderView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Binding var showingAddEntry: Bool
    @Binding var selectedEntryType: String
    
    var body: some View {
        Button {
            selectedEntryType = "rating"
            showingAddEntry = true
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Welcome back,")
                        .font(.headline)
                    Text(authManager.user?.email?.components(separatedBy: "@").first ?? "User")
                        .font(.headline.bold())
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.subheadline)
                }
                
                Text("How's your day going? Tap to rate")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionsView: View {
    @Binding var showingAddEntry: Bool
    @Binding var selectedEntryType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickActionButton(
                    title: "New Note",
                    systemImage: "note.text",
                    color: .blue
                ) {
                    selectedEntryType = "note"
                    showingAddEntry = true
                }
                
                QuickActionButton(
                    title: "Rate Day",
                    systemImage: "star.fill",
                    color: .yellow
                ) {
                    selectedEntryType = "rating"
                    showingAddEntry = true
                }
                
                QuickActionButton(
                    title: "Add Event",
                    systemImage: "calendar",
                    color: .green
                ) {
                    selectedEntryType = "event"
                    showingAddEntry = true
                }
                
                NavigationLink(destination: StatisticsView()) {
                    QuickActionButtonContent(
                        title: "Statistics",
                        systemImage: "chart.bar.fill",
                        color: .purple
                    )
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemBackground))
            .shadow(color: .gray.opacity(0.2), radius: 5))
    }
}

struct QuickActionButtonContent: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(color.opacity(0.1)))
    }
}

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            QuickActionButtonContent(
                title: title,
                systemImage: systemImage,
                color: color
            )
        }
    }
}

// Add this new view component for Memory Exercises
struct MemoryExercisesPreviewView: View {
    @ObservedObject private var progressManager = ExerciseProgressManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Memory Training")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: MemoryExercisesView()) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(spacing: 15) {
                // Recent activity summary
                if !progressManager.exerciseStats.isEmpty {
                    NavigationLink(destination: MemoryProgressView()) {
                        HStack(spacing: 10) {
                            Image(systemName: "brain")
                                .font(.title2)
                                .foregroundColor(.purple)
                                .frame(width: 44, height: 44)
                                .background(Color.purple.opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recent Progress")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("\(completedExercisesCount) exercises completed")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Exercise preview cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(featuredExercises) { exercise in
                            NavigationLink(destination: exerciseDestination(for: exercise)) {
                                FeaturedExerciseCard(
                                    exercise: exercise,
                                    stats: progressManager.exerciseStats[exercise.id]
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemBackground))
            .shadow(color: .gray.opacity(0.2), radius: 5))
    }
    
    // Show 3 featured exercises
    private var featuredExercises: [MemoryExercise] {
        Array(MemoryExercise.allExercises.prefix(3))
    }
    
    private var completedExercisesCount: Int {
        progressManager.exerciseStats.reduce(0) { count, stat in
            count + stat.value.completedCount
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
        case "numberMnemonics":
            NumberMnemonicsExerciseView()
        default:
            ComingSoonExerciseView(exercise: exercise)
        }
    }
}

struct FeaturedExerciseCard: View {
    let exercise: MemoryExercise
    let stats: ExerciseStat?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise icon
            HStack {
                Image(systemName: exercise.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(exercise.color)
                    .clipShape(Circle())
                
                Spacer()
                
                if let stats = stats, stats.completedCount > 0 {
                    Text("\(Int(stats.highScore))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            
            // Exercise name
            Text(exercise.name)
                .font(.callout)
                .fontWeight(.medium)
                .lineLimit(1)
            
            // Time
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    
                Text(exercise.timeDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 150, height: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(exercise.color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }
} 