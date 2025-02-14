import SwiftUI

struct MemoryRowView: View {
    let entry: MemoryEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.type ?? "Unknown")
                .font(.caption)
                .foregroundColor(.secondary)
            
            switch entry.type {
            case "note":
                Text(entry.note ?? "")
                    .lineLimit(1)
            case "rating":
                Text("Day Rating: \(entry.dayRating)")
            case "event":
                Text(entry.eventTitle ?? "")
            default:
                Text("Unknown entry type")
            }
            
            if let date = entry.date {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
} 