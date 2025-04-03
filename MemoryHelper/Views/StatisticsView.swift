import SwiftUI
import CoreData
import Charts

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var timeRange: TimeRange = .week
    @State private var entries: [MemoryEntry] = []
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case twoWeeks = "2 Weeks"
        case month = "Month"
        case threeMonths = "3 Months"
        case sixMonths = "6 Months"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .twoWeeks: return 14
            case .month: return 30
            case .threeMonths: return 90
            case .sixMonths: return 180
            case .year: return 365
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Time Range", selection: $timeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Updated Mood Chart
                    ChartCard(title: "Mood Trends") {
                        MoodChart(entries: moodEntries, timeRange: timeRange)
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
    let timeRange: StatisticsView.TimeRange
    @State private var selectedDate: Date?
    @State private var showingDetailPopover = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch timeRange {
        case .week, .twoWeeks:
            formatter.dateFormat = "EEE, MMM d"
        case .month:
            formatter.dateFormat = "MMM d"
        case .threeMonths, .sixMonths:
            formatter.dateFormat = "MMM d"
        case .year:
            formatter.dateFormat = "MMM yyyy"
        }
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Statistics Summary
            HStack(spacing: 20) {
                StatisticItem(title: "Average", value: String(format: "%.1f", averageMood()))
                StatisticItem(title: "Highest", value: String(format: "%.0f", processedEntries.map { $0.rating }.max() ?? 0))
                StatisticItem(title: "Lowest", value: String(format: "%.0f", processedEntries.filter { $0.rating > 0 }.map { $0.rating }.min() ?? 0))
            }
            .padding(.horizontal)
            
            // Main Chart
            Chart {
                ForEach(processedEntries, id: \.date) { entry in
                    BarMark(
                        x: .value("Date", entry.date),
                        y: .value("Rating", entry.rating)
                    )
                    .foregroundStyle(colorForRating(entry.rating))
                    .opacity(entry.rating == 0 ? 0.2 : 0.7)
                }
                
                // Average line
                RuleMark(y: .value("Average", averageMood()))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                    .foregroundStyle(.secondary)
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Avg: \(String(format: "%.1f", averageMood()))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 5)
                            .background(Color(.systemBackground).opacity(0.8))
                    }
            }
            .chartXAxis {
                AxisMarks(values: chartXAxisValues()) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(dateFormatter.string(from: date))
                                .font(.caption)
                        }
                        AxisTick()
                        AxisGridLine()
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: 20)) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption)
                        }
                    }
                    AxisGridLine()
                }
            }
            .chartYScale(domain: 0...100)
            .frame(height: 250)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                    guard let date: Date = proxy.value(atX: x) else { return }
                                    selectedDate = date
                                    showingDetailPopover = true
                                }
                                .onEnded { _ in
                                    selectedDate = nil
                                    showingDetailPopover = false
                                }
                        )
                }
            }
            
            // Mood Legend
            HStack(spacing: 16) {
                ForEach([(Color.red, "Low"), (Color.yellow, "Medium"), (Color.green, "High")], id: \.1) { color, label in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 8)
        }
        .overlay {
            if showingDetailPopover, let date = selectedDate,
               let entry = processedEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateFormatter.string(from: date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Mood: \(Int(entry.rating))")
                        .font(.headline)
                }
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
                .transition(.opacity)
            }
        }
    }
    
    private func chartXAxisValues() -> [Date] {
        let calendar = Calendar.current
        let startDate = processedEntries.first?.date ?? Date()
        let endDate = processedEntries.last?.date ?? Date()
        
        let strideBy: Calendar.Component
        let strideCount: Int
        
        switch timeRange {
        case .week:
            strideBy = .day
            strideCount = 1
        case .twoWeeks:
            strideBy = .day
            strideCount = 2
        case .month:
            strideBy = .day
            strideCount = 5
        case .threeMonths:
            strideBy = .weekOfMonth
            strideCount = 2
        case .sixMonths:
            strideBy = .month
            strideCount = 1
        case .year:
            strideBy = .month
            strideCount = 2
        }
        
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: strideBy, value: strideCount, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return dates
    }
    
    private struct StatisticItem: View {
        let title: String
        let value: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
        }
    }
    
    private var processedEntries: [(date: Date, rating: Double)] {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -timeRange.days + 1, to: calendar.startOfDay(for: today)) ?? today
        
        // Create array of all dates in range
        var allDates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= today {
            allDates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Create dictionary of existing entries
        let entriesDict = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        // Map all dates to entries, using 0 for missing dates
        return allDates.map { date in
            if let dayEntries = entriesDict[date] {
                let avgRating = dayEntries.map { $0.rating }.reduce(0, +) / Double(dayEntries.count)
                return (date: date, rating: avgRating)
            } else {
                return (date: date, rating: 0)
            }
        }
    }
    
    private func colorForRating(_ rating: Double) -> Color {
        switch rating {
        case 0..<30: return .red
        case 30..<70: return .yellow
        default: return .green
        }
    }
    
    private func averageMood() -> Double {
        let ratings = processedEntries.map { $0.rating }
        return ratings.isEmpty ? 0 : ratings.reduce(0, +) / Double(ratings.count)
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