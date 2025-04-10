import SwiftUI
import LocalAuthentication
import CoreData
import FirebaseAuth

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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    
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
                Button(role: .destructive) {
                    showingDataDeletionConfirmation = true
                } label: {
                    Label("Delete Account & Data", systemImage: "trash")
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
        .alert("Delete Account & Data", isPresented: $showingDataDeletionConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await deleteAccountAndData()
                }
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
    }
    
    private func deleteAccountAndData() async {
        guard let userId = AuthenticationManager.shared.user?.uid else {
            return
        }
        
        // 1. Delete CoreData entries
        await deleteCoreData(for: userId)
        
        // 2. Delete UserDefaults data
        clearUserDefaults()
        
        // 3. Delete Firebase account and sign out
        do {
            try await Auth.auth().currentUser?.delete()
            try Auth.auth().signOut()
            try await authManager.signOut()
            
            // 4. Dismiss the current view and return to authentication
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print("Error during account deletion: \(error)")
            // You might want to show an alert to the user here
        }
    }
    
    private func deleteCoreData(for userId: String) async {
        let context = PersistenceController.shared.container.viewContext
        
        // Create batch delete request for all user's data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MemoryEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            // Execute batch delete
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [
                NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []
            ]
            
            // Merge changes to view context
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            try context.save()
        } catch {
            print("Error batch deleting data: \(error)")
        }
    }
    
    private func clearUserDefaults() {
        // Clear only user-specific data
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "useBiometrics")
        defaults.removeObject(forKey: "autoLockTimeout")
        // Add any other user-specific UserDefaults keys here
        defaults.synchronize()
    }
} 
