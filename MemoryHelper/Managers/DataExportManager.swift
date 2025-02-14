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
    
    func exportData(entries: [MemoryEntry], format: ExportFormat) -> URL? {
        switch format {
        case .pdf:
            return exportToPDF(entries: entries)
        case .csv:
            return exportToCSV(entries: entries)
        case .json:
            return exportToJSON(entries: entries)
        }
    }
    
    private func exportToPDF(entries: [MemoryEntry]) -> URL? {
        // Create PDF document
        let pdfMetaData = [
            kCGPDFContextCreator: "Memory Helper",
            kCGPDFContextAuthor: "Memory Helper App"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Standard US Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw title
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let titleString = "Memory Helper Export"
            titleString.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            // Draw entries
            var yPosition: CGFloat = 100
            
            for entry in entries {
                let entryText = """
                Date: \(entry.date?.formatted() ?? "Unknown")
                Type: \(entry.type ?? "Unknown")
                \(formatEntryDetails(entry))
                ----------------------------------------
                
                """
                
                let attributes = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
                ]
                
                entryText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: attributes)
                yPosition += 100 // Adjust based on content height
                
                // Start new page if needed
                if yPosition > 700 {
                    context.beginPage()
                    yPosition = 50
                }
            }
        }
        
        // Save to temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("MemoryHelper-Export.pdf")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
    
    private func exportToCSV(entries: [MemoryEntry]) -> URL? {
        var csvString = "Date,Type,Details\n"
        
        for entry in entries {
            let date = entry.date?.formatted() ?? "Unknown"
            let type = entry.type ?? "Unknown"
            let details = formatEntryDetails(entry).replacingOccurrences(of: "\n", with: " ")
            
            csvString += "\(date),\(type),\"\(details)\"\n"
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("MemoryHelper-Export.csv")
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving CSV: \(error)")
            return nil
        }
    }
    
    private func exportToJSON(entries: [MemoryEntry]) -> URL? {
        let jsonEntries = entries.map { entry -> [String: Any] in
            [
                "date": entry.date?.formatted() ?? "Unknown",
                "type": entry.type ?? "Unknown",
                "details": formatEntryDetails(entry)
            ]
        }
        
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonEntries, options: .prettyPrinted)
        } catch {
            print("Error creating JSON: \(error)")
            return nil
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("MemoryHelper-Export.json")
        
        do {
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving JSON: \(error)")
            return nil
        }
    }
    
    private func formatEntryDetails(_ entry: MemoryEntry) -> String {
        switch entry.type {
        case "note":
            return "Note: \(entry.note ?? "")"
        case "rating":
            return "Day Rating: \(entry.dayRating)"
        case "event":
            return """
            Event: \(entry.eventTitle ?? "")
            Date: \(entry.eventDate?.formatted() ?? "Unknown")
            """
        default:
            return "No details available"
        }
    }
} 