import SwiftUI
import CoreData

struct RecentMemoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var recentEntries: FetchedResults<MemoryEntry>
    
    init() {
        let request: NSFetchRequest<MemoryEntry> = MemoryEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MemoryEntry.date, ascending: false)]
        request.fetchLimit = 5 // Only show last 5 entries
        
        if let userId = AuthenticationManager.shared.user?.uid {
            request.predicate = NSPredicate(format: "userId == %@", userId)
        }
        
        _recentEntries = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Memories")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: MemoryListView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if recentEntries.isEmpty {
                EmptyStateView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recentEntries) { entry in
                            MemoryCard(entry: entry)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
}

struct MemoryCard: View {
    let entry: MemoryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Type
            HStack {
                Image(systemName: iconForType(entry.type ?? ""))
                    .foregroundColor(colorForType(entry.type ?? ""))
                Text(entry.type?.capitalized ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Content Preview
            contentPreview
                .lineLimit(3)
                .font(.callout)
            
            Spacer()
            
            // Date
            if let date = entry.date {
                Text(date.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 200, height: 150)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 3)
    }
    
    private var contentPreview: Text {
        switch entry.type {
        case "note":
            return Text(entry.note ?? "")
        case "rating":
            return Text("Day Rating: \(entry.dayRating)/100")
        case "event":
            return Text(entry.eventTitle ?? "")
        default:
            return Text("")
        }
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "note": return "note.text"
        case "rating": return "star.fill"
        case "event": return "calendar"
        default: return "doc"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "note": return .blue
        case "rating": return .yellow
        case "event": return .green
        default: return .gray
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("No memories yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add your first memory to see it here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
} 