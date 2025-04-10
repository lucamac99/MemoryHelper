import Foundation
import CoreData
import PDFKit
import SwiftUI

enum ExportFormat {
    case pdf
    case csv
    case json
}

class DataExportManager: ObservableObject {
    static let shared = DataExportManager()
    private init() {}
    
    func exportData(entries: [MemoryEntry], format: ExportFormat) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        switch format {
        case .pdf:
            return exportToPDF(entries: entries, documentsPath: documentsPath)
        case .csv:
            return exportToCSV(entries: entries, documentsPath: documentsPath)
        case .json:
            return exportToJSON(entries: entries, documentsPath: documentsPath)
        }
    }
    
    private func exportToPDF(entries: [MemoryEntry], documentsPath: URL) -> URL? {
        // Create a formatted string of all entries
        let content = entries.map { entry in
            """
            Date: \(formatDate(entry.date))
            Type: \(entry.type ?? "Unknown")
            \(formatEntryDetails(entry))
            """
        }.joined(separator: "\n---\n")
        
        let pdfPath = documentsPath.appendingPathComponent("memories.pdf")
        
        // Basic PDF creation
        guard let data = content.data(using: String.Encoding.utf8) else { return nil }
        try? data.write(to: pdfPath)
        
        return pdfPath
    }
    
    private func exportToCSV(entries: [MemoryEntry], documentsPath: URL) -> URL? {
        var csvString = "Date,Type,Details\n"
        
        for entry in entries {
            let date = formatDate(entry.date)
            let type = entry.type ?? "Unknown"
            let details = formatEntryDetails(entry).replacingOccurrences(of: ",", with: ";")
            
            csvString += "\(date),\(type),\(details)\n"
        }
        
        let csvPath = documentsPath.appendingPathComponent("memories.csv")
        
        guard let data = csvString.data(using: String.Encoding.utf8) else { return nil }
        try? data.write(to: csvPath)
        
        return csvPath
    }
    
    private func exportToJSON(entries: [MemoryEntry], documentsPath: URL) -> URL? {
        let jsonEntries = entries.map { entry -> [String: Any] in
            return [
                "date": formatDate(entry.date),
                "type": entry.type ?? "Unknown",
                "details": formatEntryDetails(entry)
            ]
        }
        
        let jsonPath = documentsPath.appendingPathComponent("memories.json")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonEntries, options: .prettyPrinted)
            try data.write(to: jsonPath)
            return jsonPath
        } catch {
            return nil
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatEntryDetails(_ entry: MemoryEntry) -> String {
        guard let type = entry.type else { return "No details available" }
        
        switch type {
        case "note":
            return "Note: \(entry.note ?? "")"
        case "rating":
            return "Day Rating: \(entry.dayRating)"
        case "event":
            return """
            Event: \(entry.eventTitle ?? "")
            Date: \(formatDate(entry.eventDate))
            """
        default:
            return "No details available"
        }
    }
} 