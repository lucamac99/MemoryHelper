import SwiftUI
import Charts

struct MemoryProgressView: View {
    @ObservedObject private var progressManager = ExerciseProgressManager.shared
    @State private var selectedChartType: ChartType = .byExercise
    @Environment(\.presentationMode) private var presentationMode
    
    // Add environment object to access tab selection from LandingView
    @EnvironmentObject private var tabSelection: TabSelectionManager
    
    enum ChartType: String, CaseIterable {
        case byExercise = "By Exercise"
        case byCategory = "By Category"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Chart Type Selector
                Picker("Display Type", selection: $selectedChartType) {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Overall Stats
                VStack(alignment: .leading, spacing: 10) {
                    Text("Overall Progress")
                        .font(.headline)
                        .padding(.leading)
                    
                    HStack {
                        ProgressStatCard(
                            title: "Exercises Completed",
                            value: "\(totalExercisesCompleted)",
                            icon: "checkmark.circle.fill",
                            color: .blue
                        )
                        
                        ProgressStatCard(
                            title: "Average Score",
                            value: "\(Int(averageOverallScore))%",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Exercise Breakdown
                VStack(alignment: .leading, spacing: 10) {
                    Text("Exercise Breakdown")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Use the chart type to determine which visualization to show
                    if selectedChartType == .byExercise {
                        ExerciseBreakdownChart()
                            .frame(height: 200)
                            .padding()
                    } else {
                        CategoryBreakdownView()
                            .frame(height: 200)
                            .padding()
                    }
                }
                
                // Exercise List with Progress
                VStack(alignment: .leading, spacing: 10) {
                    Text("Exercise Details")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, selectedChartType == .byCategory ? 20 : 0)
                    
                    ForEach(MemoryExercise.allExercises) { exercise in
                        let stats = progressManager.exerciseStats[exercise.id] ?? ExerciseStat()
                        ExerciseProgressRow(exercise: exercise, stats: stats)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Progress")
        .onChange(of: tabSelection.selectedTab) { newValue in
            // When the user taps the "Training" tab (index 2), dismiss this view to go back
            if newValue == 2 {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var totalExercisesCompleted: Int {
        progressManager.exerciseStats.values.reduce(0) { $0 + $1.completedCount }
    }
    
    private var averageOverallScore: Double {
        let stats = progressManager.exerciseStats.values
        guard !stats.isEmpty else { return 0 }
        
        let totalScores = stats.reduce(0.0) { $0 + $1.averageScore * Double($1.completedCount) }
        let totalCompletions = stats.reduce(0) { $0 + $1.completedCount }
        
        return totalCompletions > 0 ? totalScores / Double(totalCompletions) : 0
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 3)
    }
}

struct ExerciseBreakdownChart: View {
    @ObservedObject private var progressManager = ExerciseProgressManager.shared
    
    var chartData: [ChartData] {
        MemoryExercise.allExercises.compactMap { exercise in
            guard let stats = progressManager.exerciseStats[exercise.id], stats.completedCount > 0 else {
                return nil
            }
            
            return ChartData(
                name: exercise.name,
                count: stats.completedCount,
                score: stats.averageScore,
                color: exercise.color
            )
        }
    }
    
    var body: some View {
        if chartData.isEmpty {
            EmptyChartView()
        } else if chartData.count < 3 {
            // Use a simpler visualization for limited data
            CompactChartView(data: chartData)
        } else if #available(iOS 16.0, *) {
            Chart {
                ForEach(chartData) { item in
                    BarMark(
                        x: .value("Exercise", item.name),
                        y: .value("Score", item.score)
                    )
                    .foregroundStyle(by: .value("Exercise", item.name))
                }
            }
        } else {
            // Fallback for earlier iOS versions
            AlternativeChartView(data: chartData)
        }
    }
    
    struct ChartData: Identifiable {
        var id: String { name }
        let name: String
        let count: Int
        let score: Double
        let color: Color
    }
}

struct EmptyChartView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No exercise data yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Complete exercises to see your progress visualized here")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

struct CompactChartView: View {
    let data: [ExerciseBreakdownChart.ChartData]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(data) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(item.score))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(item.color)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 12)
                                .cornerRadius(6)
                            
                            Rectangle()
                                .fill(item.color)
                                .frame(width: geometry.size.width * CGFloat(item.score / 100), height: 12)
                                .cornerRadius(6)
                        }
                    }
                    .frame(height: 12)
                    
                    Text("Completed \(item.count) time\(item.count != 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            if data.count == 1 {
                Text("Complete more exercises to see comparisons")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AlternativeChartView: View {
    let data: [ExerciseBreakdownChart.ChartData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance by Exercise")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            ForEach(data) { item in
                HStack(spacing: 12) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 10, height: 10)
                    
                    Text(item.name)
                        .font(.caption)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 16)
                                .cornerRadius(8)
                            
                            Rectangle()
                                .fill(item.color)
                                .frame(width: geometry.size.width * CGFloat(item.score / 100), height: 16)
                                .cornerRadius(8)
                            
                            Text("\(Int(item.score))%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.leading, 6)
                        }
                    }
                    .frame(width: 120)
                }
                .frame(height: 25)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ExerciseProgressRow: View {
    let exercise: MemoryExercise
    let stats: ExerciseStat
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: exercise.icon)
                .foregroundColor(exercise.color)
                .frame(width: 36, height: 36)
                .background(exercise.color.opacity(0.1))
                .clipShape(Circle())
            
            // Name and score
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if stats.completedCount > 0 {
                    Text("Completed \(stats.completedCount) time\(stats.completedCount != 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Not started yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Progress
            if stats.completedCount > 0 {
                Text("\(Int(stats.highScore))%")
                    .font(.headline)
                    .foregroundColor(exercise.color)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
}

struct CategoryBreakdownView: View {
    @ObservedObject private var progressManager = ExerciseProgressManager.shared
    
    var categoryData: [CategoryStats] {
        var statsByCategory: [MemoryExercisesView.ExerciseCategory: CategoryStats] = [:]
        
        // Initialize with all categories
        for category in MemoryExercisesView.ExerciseCategory.allCases {
            if category != .all {
                statsByCategory[category] = CategoryStats(category: category, exerciseCount: 0, totalCompletions: 0, averageScore: 0)
            }
        }
        
        // Populate with exercise data
        for exercise in MemoryExercise.allExercises {
            if let stats = progressManager.exerciseStats[exercise.id], stats.completedCount > 0 {
                var categoryStats = statsByCategory[exercise.category]!
                categoryStats.exerciseCount += 1
                categoryStats.totalCompletions += stats.completedCount
                categoryStats.averageScore += (stats.averageScore * Double(stats.completedCount))
                statsByCategory[exercise.category] = categoryStats
            }
        }
        
        // Calculate averages and return as array
        return statsByCategory.values.compactMap { stats in
            var result = stats
            if result.totalCompletions > 0 {
                result.averageScore /= Double(result.totalCompletions)
                return result
            }
            return result.exerciseCount > 0 ? result : nil
        }.sorted { $0.totalCompletions > $1.totalCompletions }
    }
    
    var body: some View {
        if categoryData.isEmpty {
            EmptyChartView()
        } else {
            VStack(spacing: 16) {
                ForEach(categoryData) { stats in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: stats.category.icon)
                                .foregroundColor(categoryColor(stats.category))
                                .font(.system(size: 14))
                            
                            Text(stats.category.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(Int(stats.averageScore))%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(categoryColor(stats.category))
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 10)
                                    .cornerRadius(5)
                                
                                Rectangle()
                                    .fill(categoryColor(stats.category))
                                    .frame(width: geometry.size.width * CGFloat(stats.averageScore / 100), height: 10)
                                    .cornerRadius(5)
                            }
                        }
                        .frame(height: 10)
                        
                        Text("\(stats.totalCompletions) completion\(stats.totalCompletions != 1 ? "s" : "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    func categoryColor(_ category: MemoryExercisesView.ExerciseCategory) -> Color {
        switch category {
        case .working: return .blue
        case .spatial: return .purple
        case .verbal: return .green
        case .attention: return .red
        case .all: return .gray
        }
    }
    
    struct CategoryStats: Identifiable {
        let category: MemoryExercisesView.ExerciseCategory
        var exerciseCount: Int
        var totalCompletions: Int
        var averageScore: Double
        
        var id: String { category.rawValue }
    }
}

// Add this class to manage tab selection
class TabSelectionManager: ObservableObject {
    @Published var selectedTab: Int = 0
    
    static let shared = TabSelectionManager()
    
    init() {
        // Initialize based on AuthenticationManager's initialView
        if AuthenticationManager.shared.initialView == "home" {
            selectedTab = 0
        }
    }
    
    // Method to set tab based on view name
    func navigateTo(viewName: String) {
        switch viewName {
        case "home":
            selectedTab = 0
        case "memories":
            selectedTab = 1
        case "training":
            selectedTab = 2
        case "stats":
            selectedTab = 3
        case "profile":
            selectedTab = 4
        default:
            selectedTab = 0
        }
    }
} 