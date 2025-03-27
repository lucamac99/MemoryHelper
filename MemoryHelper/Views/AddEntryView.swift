import SwiftUI

struct AddEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedType: String
    @State private var note = ""
    @State private var dayRating: Double = 50
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var isShowingSaveAnimation = false
    
    let entryTypes = ["note", "rating", "event"]
    
    init(initialType: String = "note") {
        _selectedType = State(initialValue: initialType)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Type Selector
                HStack(spacing: 8) {
                    ForEach(entryTypes, id: \.self) { type in
                        EntryTypeTab(
                            type: type,
                            isSelected: selectedType == type,
                            action: { selectedType = type }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 4)
                
                // Content Area
                ScrollView {
                    VStack(spacing: 25) {
                        switch selectedType {
                        case "note":
                            NoteEntryView(note: $note)
                        case "rating":
                            RatingEntryView(rating: $dayRating)
                        case "event":
                            EventEntryView(
                                eventTitle: $eventTitle,
                                eventDate: $eventDate
                            )
                        default:
                            EmptyView()
                        }
                        
                        // Save Button
                        Button {
                            withAnimation {
                                isShowingSaveAnimation = true
                                saveEntry()
                            }
                        } label: {
                            HStack {
                                if isShowingSaveAnimation {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .tint(.white)
                                } else {
                                    Text("Save")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(saveButtonColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .disabled(!isValidEntry || isShowingSaveAnimation)
                        .opacity(isValidEntry ? 1.0 : 0.6)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isValidEntry: Bool {
        switch selectedType {
        case "note":
            return !note.isEmpty
        case "rating":
            return true
        case "event":
            return !eventTitle.isEmpty
        default:
            return false
        }
    }
    
    private var saveButtonColor: Color {
        switch selectedType {
        case "note": return .blue
        case "rating": return .yellow
        case "event": return .green
        default: return .blue
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
            // Short delay for animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                dismiss()
            }
        } catch {
            let nsError = error as NSError
            print("Error saving entry: \(nsError), \(nsError.userInfo)")
            isShowingSaveAnimation = false
        }
    }
}

struct EntryTypeTab: View {
    let type: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconForType(type))
                    .font(.system(size: 16))
                
                Text(type.capitalized)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(isSelected ? colorForType(type).opacity(0.15) : Color(.systemGray6).opacity(0.5))
            )
            .foregroundColor(isSelected ? colorForType(type) : .secondary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? colorForType(type) : Color.clear, lineWidth: 1.5)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.2), value: isSelected)
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
        default: return .primary
        }
    }
}

struct NoteEntryView: View {
    @Binding var note: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's on your mind?")
                .font(.headline)
                .padding(.leading)
            
            TextEditor(text: $note)
                .frame(minHeight: 200)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
        }
    }
}

struct RatingEntryView: View {
    @Binding var rating: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("How was your day?")
                .font(.headline)
                .padding(.leading)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(rating/100))
                    .stroke(ratingColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: rating)
                
                VStack {
                    Text("\(Int(rating))")
                        .font(.system(size: 42, weight: .bold))
                    
                    Text(ratingDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            Slider(value: $rating, in: 1...100, step: 1)
                .tint(ratingColor)
                .padding(.horizontal)
            
            HStack {
                Text("Poor")
                    .foregroundColor(.secondary)
                Spacer()
                Text("Excellent")
                    .foregroundColor(.secondary)
            }
            .font(.caption)
            .padding(.horizontal)
        }
    }
    
    private var ratingColor: Color {
        if rating < 30 {
            return .red
        } else if rating < 70 {
            return .yellow
        } else {
            return .green
        }
    }
    
    private var ratingDescription: String {
        if rating < 30 {
            return "Not so good"
        } else if rating < 70 {
            return "Average"
        } else {
            return "Great!"
        }
    }
}

struct EventEntryView: View {
    @Binding var eventTitle: String
    @Binding var eventDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Event Details")
                .font(.headline)
                .padding(.leading)
            
            VStack(spacing: 15) {
                TextField("Event Title", text: $eventTitle)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                VStack(alignment: .leading) {
                    Text("Date")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $eventDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
} 