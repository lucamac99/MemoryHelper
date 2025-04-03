import SwiftUI
import CoreData

struct MemoryListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var selectedFilter: MemoryType
    @State private var showingAddEntry = false
    
    enum MemoryType: String, CaseIterable {
        case all = "All"
        case note = "Notes"
        case rating = "Ratings"
        case event = "Events"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .note: return "note.text"
            case .rating: return "star.fill"
            case .event: return "calendar"
            }
        }
        
        static func fromString(_ string: String) -> MemoryType {
            switch string {
            case "note": return .note
            case "rating": return .rating
            case "event": return .event
            default: return .all
            }
        }
    }
    
    init(initialFilter: String = "all") {
        _selectedFilter = State(initialValue: MemoryType.fromString(initialFilter))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(MemoryType.allCases, id: \.self) { type in
                            FilterPill(type: type, isSelected: selectedFilter == type) {
                                selectedFilter = type
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Memory List
                MemoryListContent(filter: selectedFilter, searchText: searchText)
            }
            .navigationTitle("Memories")
            .searchable(text: $searchText, prompt: "Search memories...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
            }
        }
    }
}

struct MemoryListContent: View {
    @Environment(\.managedObjectContext) private var viewContext
    let filter: MemoryListView.MemoryType
    let searchText: String
    
    @FetchRequest private var entries: FetchedResults<MemoryEntry>
    
    init(filter: MemoryListView.MemoryType, searchText: String) {
        self.filter = filter
        self.searchText = searchText
        
        let request: NSFetchRequest<MemoryEntry> = MemoryEntry.fetchRequest()
        
        // Sorting
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MemoryEntry.date, ascending: false)]
        
        // Filtering
        var predicates: [NSPredicate] = []
        
        if filter != .all {
            // Match the type field in Core Data with the type we want to filter
            let typeString: String
            switch filter {
            case .note:
                typeString = "note"
            case .rating:
                typeString = "rating"
            case .event:
                typeString = "event"
            default:
                typeString = ""
            }
            if !typeString.isEmpty {
                predicates.append(NSPredicate(format: "type == %@", typeString))
            }
        }
        
        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "note CONTAINS[cd] %@ OR eventTitle CONTAINS[cd] %@", 
                                            searchText, searchText)
            predicates.append(searchPredicate)
        }
        
        if let userId = AuthenticationManager.shared.user?.uid {
            predicates.append(NSPredicate(format: "userId == %@", userId))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        _entries = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        List {
            ForEach(entries) { entry in
                NavigationLink {
                    MemoryDetailView(entry: entry)
                } label: {
                    MemoryRowView(entry: entry)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteEntry(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if entries.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label(
                            "No Memories",
                            systemImage: "doc.text.magnifyingglass"
                        )
                    },
                    description: {
                        Text("Add your first memory or try a different filter")
                    }
                )
            }
        }
    }
    
    private func deleteEntry(_ entry: MemoryEntry) {
        viewContext.delete(entry)
        try? viewContext.save()
    }
}

struct FilterPill: View {
    let type: MemoryListView.MemoryType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                Text(type.rawValue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .animation(.easeInOut, value: isSelected)
        }
    }
} 