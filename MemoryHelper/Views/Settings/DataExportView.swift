import SwiftUI
import CoreData

struct DataExportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var exportManager = DataExportManager.shared
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        List {
            Section {
                ForEach([
                    ("Export as PDF", "doc.fill", ExportFormat.pdf),
                    ("Export as CSV", "table", ExportFormat.csv),
                    ("Export as JSON", "curlybraces", ExportFormat.json)
                ], id: \.0) { title, icon, format in
                    Button {
                        exportData(format: format)
                    } label: {
                        Label {
                            Text(title)
                        } icon: {
                            Image(systemName: icon)
                                .foregroundColor(.blue)
                        }
                    }
                }
            } header: {
                Text("Choose Format")
            } footer: {
                Text("Your data will be exported in the selected format.")
            }
        }
        .navigationTitle("Export Data")
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .alert("Export Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func exportData(format: ExportFormat) {
        let fetchRequest: NSFetchRequest<MemoryEntry> = MemoryEntry.fetchRequest()
        
        do {
            let entries = try viewContext.fetch(fetchRequest)
            if let url = exportManager.exportData(entries: entries, format: format) {
                exportURL = url
                showingShareSheet = true
            } else {
                errorMessage = "Failed to export data"
                showingError = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

/* struct ExportOptionRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(.blue)
            }
        }
    }
} */

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 