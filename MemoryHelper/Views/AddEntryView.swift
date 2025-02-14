import SwiftUI

struct AddEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType = "note"
    @State private var note = ""
    @State private var dayRating: Double = 50
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    
    let entryTypes = ["note", "rating", "event"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entry Type")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(entryTypes, id: \.self) { type in
                            Text(type.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                switch selectedType {
                case "note":
                    Section(header: Text("Note Details")) {
                        TextEditor(text: $note)
                            .frame(height: 100)
                    }
                    
                case "rating":
                    Section(header: Text("Day Rating")) {
                        VStack {
                            Slider(value: $dayRating, in: 1...100, step: 1)
                            Text("Rating: \(Int(dayRating))")
                        }
                    }
                    
                case "event":
                    Section(header: Text("Event Details")) {
                        TextField("Event Title", text: $eventTitle)
                        DatePicker("Event Date", selection: $eventDate, displayedComponents: [.date])
                    }
                    
                default:
                    EmptyView()
                }
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                }
            }
        }
    }
    
    private func saveEntry() {
        let newEntry = MemoryEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.date = Date()
        newEntry.type = selectedType
        newEntry.userId = AuthenticationManager.shared.user?.uid
        
        switch selectedType {
        case "note":
            newEntry.note = note
        case "rating":
            newEntry.dayRating = Int16(dayRating)
        case "event":
            newEntry.eventTitle = eventTitle
            newEntry.eventDate = eventDate
        default:
            break
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
} 