import SwiftUI
import Charts

enum TimeRange {
    case week, month, year
}

struct MemoryGraphView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \MemoryEntry.date, ascending: true)])
    private var memories: FetchedResults<MemoryEntry>
    
    @State private var selectedTimeRange: TimeRange = .week
    
    var body: some View {
        VStack {
            // Time range picker
            Picker("Time Range", selection: $selectedTimeRange) {
                Text("Week").tag(TimeRange.week)
                Text("Month").tag(TimeRange.month)
                Text("Year").tag(TimeRange.year)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Chart view
            Chart {
                ForEach(filteredData) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Rating", dataPoint.rating)
                    )
                    .foregroundStyle(lineColor)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Rating", dataPoint.rating)
                    )
                    .foregroundStyle(lineColor)
                }
            }
            .chartYScale(domain: 0...5)
            .frame(height: 250)
            .padding()
            
            // Stats summary
            statsView
                .padding()
        }
        .navigationTitle("Memory Trends")
    }
    
    // Filtered data based on time range
    private var filteredData: [MemoryDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return memories.compactMap { entry in
            guard let date = entry.date, date >= startDate else { return nil }
            return MemoryDataPoint(
                id: entry.objectID.uriRepresentation().absoluteString,
                date: date,
                rating: Int(entry.dayRating),
                type: entry.type ?? ""
            )
        }
    }
    
    // Different color based on time range
    private var lineColor: Color {
        switch selectedTimeRange {
        case .week:
            return .blue
        case .month:
            return .green
        case .year:
            return .orange
        }
    }
    
    // Stats summary view
    private var statsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Statistics")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItem(title: "Average", value: averageRating, color: lineColor)
                StatItem(title: "Highest", value: highestRating, color: lineColor)
                StatItem(title: "Total", value: "\(filteredData.count)", color: lineColor)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    // Calculate statistics
    private var averageRating: String {
        let ratings = filteredData.map { $0.rating }
        guard !ratings.isEmpty else { return "0" }
        let average = Double(ratings.reduce(0, +)) / Double(ratings.count)
        return String(format: "%.1f", average)
    }
    
    private var highestRating: String {
        let max = filteredData.map { $0.rating }.max() ?? 0
        return "\(max)"
    }
}

// Helper model for chart data
struct MemoryDataPoint: Identifiable {
    var id: String
    var date: Date
    var rating: Int
    var type: String
}

// Reusable stat component
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(minWidth: 70)
    }
} 