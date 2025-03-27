import SwiftUI

struct WordListEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = 0
    @State private var wordToAdd = ""
    @State private var editedLists: [[String]] = [
        WordListsManager.basicWords,
        WordListsManager.intermediateWords,
        WordListsManager.advancedWords
    ]
    
    let categories = ["Basic", "Intermediate", "Advanced"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Category picker
                Picker("Word Category", selection: $selectedCategory) {
                    ForEach(0..<categories.count, id: \.self) { index in
                        Text(categories[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Add new word
                HStack {
                    TextField("Add new word", text: $wordToAdd)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .onSubmit {
                            addWord()
                        }
                    
                    Button(action: addWord) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Word list
                List {
                    ForEach(editedLists[selectedCategory], id: \.self) { word in
                        Text(word)
                    }
                    .onDelete { indexSet in
                        editedLists[selectedCategory].remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
                
                // Export button
                Button(action: exportWordList) {
                    Text("Export Word List")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding()
                }
            }
            .navigationTitle("Word List Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addWord() {
        let word = wordToAdd.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if !word.isEmpty && !editedLists[selectedCategory].contains(word) {
            editedLists[selectedCategory].append(word)
            editedLists[selectedCategory].sort()
            wordToAdd = ""
        }
    }
    
    private func exportWordList() {
        var output = "// \(categories[selectedCategory]) words\n[\n"
        
        for (index, word) in editedLists[selectedCategory].enumerated() {
            if index % 10 == 0 {
                output += "    "
            }
            
            output += "\"\(word)\""
            
            if index < editedLists[selectedCategory].count - 1 {
                output += ", "
            }
            
            if (index + 1) % 10 == 0 {
                output += "\n"
            }
        }
        
        output += "\n]"
        
        // Print to console for copy/paste
        print(output)
        
        // Create a share sheet if you want to export the list
        let activityViewController = UIActivityViewController(
            activityItems: [output],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
} 