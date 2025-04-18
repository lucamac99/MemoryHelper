import SwiftUI
import CoreData

struct DailyStatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var todayEntries: FetchedResults<MemoryEntry>
    @State private var showingAddEntry = false
    @State private var selectedEntryType = "rating"
    
    init() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<MemoryEntry> = MemoryEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MemoryEntry.date, ascending: false)]
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        ]
        
        if let userId = AuthenticationManager.shared.user?.uid {
            predicates.append(NSPredicate(format: "userId == %@", userId))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        _todayEntries = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Overview")
                .font(.headline)
            
            HStack(spacing: 20) {
                // All Memories Link
                NavigationLink(destination: MemoryListView()) {
                    StatisticBox(
                        title: "Memories",
                        value: "\(todayEntries.count)",
                        icon: "doc.text.fill",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Rate Mood Link
                Button {
                    selectedEntryType = "rating"
                    showingAddEntry = true
                } label: {
                    StatisticBox(
                        title: "Average Mood",
                        value: averageMoodText,
                        icon: "heart.fill",
                        color: .pink
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Events Link
                NavigationLink(destination: FilteredMemoryListView(filter: "event")) {
                    StatisticBox(
                        title: "Events",
                        value: "\(todayEvents.count)",
                        icon: "calendar",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5)
        .sheet(isPresented: $showingAddEntry) {
            AddEntryView(initialType: selectedEntryType)
        }
    }
    
    private var averageMoodText: String {
        let moodEntries = todayEntries.filter { $0.type == "rating" }
        if moodEntries.isEmpty {
            return "N/A"
        }
        let average = Double(moodEntries.map { Int($0.dayRating) }.reduce(0, +)) / Double(moodEntries.count)
        return String(format: "%.0f", average)
    }
    
    private var todayEvents: [MemoryEntry] {
        todayEntries.filter { $0.type == "event" }
    }
}

struct StatisticBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// Create a new FilteredMemoryListView to be used for filtered navigation
struct FilteredMemoryListView: View {
    let filter: String
    
    var body: some View {
        MemoryListView(initialFilter: filter)
    }
} 