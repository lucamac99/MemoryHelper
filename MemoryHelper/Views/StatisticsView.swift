import SwiftUI
import CoreData
import Charts

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var timeRange: TimeRange = .week
    @State private var entries: [MemoryEntry] = []
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $timeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Mood Chart
                    ChartCard(title: "Mood Trends") {
                        MoodChart(entries: moodEntries)
                    }
                    
                    // Activity Summary
                    HStack {
                        StatCard(
                            title: "Total Entries",
                            value: "\(entries.count)",
                            icon: "doc.text.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Average Mood",
                            value: String(format: "%.1f", averageMood),
                            icon: "heart.fill",
                            color: .pink
                        )
                    }
                    .padding(.horizontal)
                    
                    // Entry Types Distribution
                    ChartCard(title: "Entry Types") {
                        EntryTypeChart(entries: entries)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .onAppear {
                loadEntries()
            }
            .onChange(of: timeRange) { _ in
                loadEntries()
            }
        }
    }
    
    private var moodEntries: [(date: Date, rating: Double)] {
        entries
            .filter { $0.type == "rating" }
            .map { (date: $0.date ?? Date(), rating: Double($0.dayRating)) }
            .sorted { $0.date < $1.date }
    }
    
    private var averageMood: Double {
        let ratings = entries
            .filter { $0.type == "rating" }
            .map { Double($0.dayRating) }
        return ratings.isEmpty ? 0 : ratings.reduce(0, +) / Double(ratings.count)
    }
    
    private func loadEntries() {
        let request: NSFetchRequest<MemoryEntry> = MemoryEntry.fetchRequest()
        let startDate = Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date()) ?? Date()
        request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        
        if let userId = AuthenticationManager.shared.user?.uid {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "date >= %@", startDate as NSDate),
                NSPredicate(format: "userId == %@", userId)
            ])
        }
        
        entries = (try? viewContext.fetch(request)) ?? []
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            Text(value)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

struct MoodChart: View {
    let entries: [(date: Date, rating: Double)]
    
    var body: some View {
        Chart {
            ForEach(entries, id: \.date) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Rating", entry.rating)
                )
                .foregroundStyle(.blue)
                
                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Rating", entry.rating)
                )
                .foregroundStyle(.blue)
            }
        }
        .frame(height: 200)
    }
}

struct EntryTypeChart: View {
    let entries: [MemoryEntry]
    
    var typeCounts: [(type: String, count: Int)] {
        Dictionary(grouping: entries, by: { $0.type ?? "unknown" })
            .map { (type: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
        Chart(typeCounts, id: \.type) { item in
            SectorMark(
                angle: .value("Count", item.count),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .cornerRadius(5)
            .foregroundStyle(by: .value("Type", item.type.capitalized))
        }
        .frame(height: 200)
    }
} 