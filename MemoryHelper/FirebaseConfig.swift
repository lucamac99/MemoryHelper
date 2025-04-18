import FirebaseCore

class FirebaseConfig {
    static func configure() {
        // Check if the app is already configured to avoid duplicate configurations
        if FirebaseApp.app() == nil {
            // Use the GoogleService-Info.plist file
            FirebaseApp.configure()
            
            #if DEBUG
            print("Firebase successfully configured")
            #endif
        } else {
            #if DEBUG
            print("Firebase already configured, skipping initialization")
            #endif
        }
    }
} 