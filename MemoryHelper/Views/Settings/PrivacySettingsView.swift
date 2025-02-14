import SwiftUI
import LocalAuthentication

class PrivacySettings: ObservableObject {
    @Published var useBiometrics: Bool {
        didSet {
            UserDefaults.standard.set(useBiometrics, forKey: "useBiometrics")
            if useBiometrics {
                checkBiometricAvailability()
            }
        }
    }
    
    @Published var autoLockTimeout: Int {
        didSet {
            UserDefaults.standard.set(autoLockTimeout, forKey: "autoLockTimeout")
        }
    }
    
    @Published var isBiometricsAvailable = false
    
    init() {
        useBiometrics = UserDefaults.standard.bool(forKey: "useBiometrics")
        autoLockTimeout = UserDefaults.standard.integer(forKey: "autoLockTimeout")
        checkBiometricAvailability()
    }
    
    func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        isBiometricsAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}

struct PrivacySettingsView: View {
    @StateObject private var settings = PrivacySettings()
    @State private var showingDataDeletionConfirmation = false
    
    let autoLockOptions = [
        (0, "Never"),
        (1, "After 1 minute"),
        (5, "After 5 minutes"),
        (15, "After 15 minutes"),
        (30, "After 30 minutes")
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Security")) {
                if settings.isBiometricsAvailable {
                    Toggle("Use Face ID / Touch ID", isOn: $settings.useBiometrics)
                }
                
                Picker("Auto-Lock", selection: $settings.autoLockTimeout) {
                    ForEach(autoLockOptions, id: \.0) { option in
                        Text(option.1).tag(option.0)
                    }
                }
            }
            
            Section(header: Text("Data & Privacy")) {
                NavigationLink(destination: MemoryExportView()) {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
                
                Button(role: .destructive) {
                    showingDataDeletionConfirmation = true
                } label: {
                    Label("Delete All Data", systemImage: "trash")
                }
            }
            
            Section(header: Text("About"), footer: Text("Your data is stored securely on your device and in your iCloud account.")) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                }
                
                NavigationLink(destination: TermsOfServiceView()) {
                    Text("Terms of Service")
                }
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete All Data", isPresented: $showingDataDeletionConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("Are you sure you want to delete all your data? This action cannot be undone.")
        }
    }
    
    private func deleteAllData() {
        // Implement data deletion logic
    }
}

struct MemoryExportView: View {
    var body: some View {
        List {
            Section {
                ExportOptionRow(title: "Export as PDF", icon: "doc.fill")
                ExportOptionRow(title: "Export as CSV", icon: "table")
                ExportOptionRow(title: "Export as JSON", icon: "curlybraces")
            } header: {
                Text("Choose Format")
            } footer: {
                Text("Your data will be exported in the selected format.")
            }
        }
        .navigationTitle("Export Data")
    }
}

struct ExportOptionRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        Button(action: {}) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(.blue)
            }
        }
    }
} 