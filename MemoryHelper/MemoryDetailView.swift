import SwiftUI
import CoreData

struct MemoryDetailView: View {
    let entry: MemoryEntry
    @State private var editedNote: String
    @State private var editedDayRating: Int16
    @State private var editedEventTitle: String
    @State private var editedEventDate: Date
    @State private var isEditing: Bool = false
    
    // Add environment access to manage object context
    @Environment(\.managedObjectContext) private var viewContext
    
    init(entry: MemoryEntry) {
        self.entry = entry
        _editedNote = State(initialValue: entry.note ?? "")
        _editedDayRating = State(initialValue: entry.dayRating)
        _editedEventTitle = State(initialValue: entry.eventTitle ?? "")
        _editedEventDate = State(initialValue: entry.eventDate ?? Date())
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Details Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text("Type: \(entry.type ?? "")")
                        .padding(.vertical, 2)
                    
                    switch entry.type {
                    case "note":
                        if isEditing {
                            Text("Note:").fontWeight(.medium)
                            TextEditor(text: $editedNote)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        } else {
                            Text("Note:").fontWeight(.medium)
                            Text(entry.note ?? "")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                    case "rating":
                        if isEditing {
                            Stepper("Day Rating: \(editedDayRating)", value: $editedDayRating, in: 1...5)
                        } else {
                            Text("Day Rating: \(entry.dayRating)")
                        }
                    case "event":
                        if isEditing {
                            TextField("Event Title", text: $editedEventTitle)
                            DatePicker("Event Date", selection: $editedEventDate, displayedComponents: .date)
                        } else {
                            Text("Event: \(entry.eventTitle ?? "")")
                            if let eventDate = entry.eventDate {
                                Text("Event Date: \(eventDate, style: .date)")
                            }
                        }
                    default:
                        Text("Unknown entry type")
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                // Created Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Created")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    if let date = entry.date {
                        Text(date, style: .date)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                // Save Button
                if isEditing {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .navigationTitle("Memory Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
        }
    }
    
    private func saveChanges() {
        // Update the entry with edited values
        entry.note = editedNote
        entry.dayRating = editedDayRating
        
        if entry.type == "event" {
            entry.eventTitle = editedEventTitle
            entry.eventDate = editedEventDate
        }
        
        // Save changes to Core Data
        do {
            try viewContext.save()
            print("Changes saved successfully")
        } catch {
            print("Error saving changes: \(error)")
        }
        
        // Exit edit mode
        isEditing = false
    }
} 