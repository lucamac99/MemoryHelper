import SwiftUI

struct MemoryDetailView: View {
    let entry: MemoryEntry
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                Text("Type: \(entry.type ?? "")")
                
                switch entry.type {
                case "note":
                    Text("Note: \(entry.note ?? "")")
                case "rating":
                    Text("Day Rating: \(entry.dayRating)")
                case "event":
                    Text("Event: \(entry.eventTitle ?? "")")
                    if let eventDate = entry.eventDate {
                        Text("Event Date: \(eventDate, style: .date)")
                    }
                default:
                    Text("Unknown entry type")
                }
            }
            
            Section(header: Text("Created")) {
                if let date = entry.date {
                    Text(date, style: .date)
                }
            }
        }
        .navigationTitle("Memory Details")
    }
} 