import SwiftUI

class AppearanceSettings: ObservableObject {
    @AppStorage("preferredColorScheme") private var storedColorScheme: Int = 0
    
    // Initialize with default value
    @Published var colorScheme: ColorScheme = .light 
    
    init() {
        // Update using stored value after initialization
        self.updateFromStorage()
    }
    
    private func updateFromStorage() {
        // Now it's safe to use 'self'
        colorScheme = storedColorScheme == 1 ? .light : .dark
    }
}

struct AppearanceSettingsView: View {
    @StateObject private var settings = AppearanceSettings()
    
    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                Picker("Choose Theme", selection: $settings.colorScheme) {
                    Text("Light Mode").tag(ColorScheme.light)
                    Text("Dark Mode").tag(ColorScheme.dark)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 5)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Theme Preview")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    ThemePreviewCard(colorScheme: settings.colorScheme)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(settings.colorScheme) // Apply the selected theme
    }
}

struct ThemePreviewCard: View {
    var colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header section showing theme name
            HStack {
                Image(systemName: colorScheme == .light ? "sun.max.fill" : "moon.stars.fill")
                    .foregroundColor(colorScheme == .light ? .yellow : .indigo)
                Text(colorScheme == .light ? "Light Mode" : "Dark Mode")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(colorScheme == .light ? Color.white : Color.black)
            .foregroundColor(colorScheme == .light ? .black : .white)
            
            Divider()
            
            // Content preview
            VStack(alignment: .leading, spacing: 16) {
                // Memory card preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sample Memory")
                        .font(.headline)
                    
                    Text("This is how your memories will look with this theme.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ForEach(["Tag 1", "Tag 2"], id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(colorScheme == .light ? Color(.systemBackground) : Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
            .background(colorScheme == .light ? Color(.secondarySystemBackground) : Color(.systemBackground))
            .foregroundColor(colorScheme == .light ? .black : .white)
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .environment(\.colorScheme, colorScheme)
    }
} 