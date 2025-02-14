import SwiftUI

class AppearanceSettings: ObservableObject {
    @AppStorage("preferredColorScheme") private var storedColorScheme: Int = 0
    @AppStorage("accentColorName") private var storedAccentColor: String = "blue"
    
    @Published var colorScheme: ColorScheme? {
        didSet {
            storedColorScheme = colorSchemeToInt(colorScheme)
        }
    }
    
    @Published var accentColor: Color {
        didSet {
            storedAccentColor = colorToString(accentColor)
        }
    }
    
    init() {
        // Load saved color scheme
        colorScheme = .light //intToColorScheme(storedColorScheme)
        accentColor = .blue //stringToColor(storedAccentColor)
    }
    
    private func colorSchemeToInt(_ scheme: ColorScheme?) -> Int {
        switch scheme {
        case .light: return 1
        case .dark: return 2
        case .none: return 0
        }
    }
    
    private func intToColorScheme(_ value: Int) -> ColorScheme? {
        switch value {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
    
    private func colorToString(_ color: Color) -> String {
        switch color {
        case .blue: return "blue"
        case .purple: return "purple"
        case .pink: return "pink"
        case .red: return "red"
        case .orange: return "orange"
        case .green: return "green"
        default: return "blue"
        }
    }
    
    private func stringToColor(_ string: String) -> Color {
        switch string {
        case "purple": return .purple
        case "pink": return .pink
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        default: return .blue
        }
    }
}

struct AppearanceSettingsView: View {
    @StateObject private var settings = AppearanceSettings()
    @Environment(\.colorScheme) var currentColorScheme
    
    let colorSchemeOptions: [(title: String, scheme: ColorScheme?)] = [
        ("System", nil),
        ("Light", .light),
        ("Dark", .dark)
    ]
    
    let accentColors: [(name: String, color: Color)] = [
        ("Blue", .blue),
        ("Purple", .purple),
        ("Pink", .pink),
        ("Red", .red),
        ("Orange", .orange),
        ("Green", .green)
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                Picker("Appearance", selection: $settings.colorScheme) {
                    ForEach(colorSchemeOptions, id: \.title) { option in
                        Text(option.title)
                            .tag(option.scheme)
                    }
                }
                .pickerStyle(.segmented)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Preview")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    PreviewCard()
                        .preferredColorScheme(settings.colorScheme)
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Accent Color")) {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 60))
                ], spacing: 12) {
                    ForEach(accentColors, id: \.name) { colorOption in
                        ColorButton(
                            color: colorOption.color,
                            isSelected: settings.accentColor == colorOption.color,
                            action: { settings.accentColor = colorOption.color }
                        )
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PreviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
            
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.yellow)
                Text("Sample Text")
                Spacer()
                Toggle("", isOn: .constant(true))
            }
            
            Button("Sample Button") {}
                .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .opacity(isSelected ? 1 : 0)
                )
        }
    }
} 