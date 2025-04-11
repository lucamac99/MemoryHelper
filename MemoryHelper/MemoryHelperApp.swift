//
//  MemoryHelperApp.swift
//  MemoryHelper
//
//  Created by Luca Mac on 30/01/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct MemoryHelperApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authManager = AuthenticationManager.shared
    
    init() {
        FirebaseConfig.configure()
        
        #if DEBUG
        if let currentUser = Auth.auth().currentUser {
            print("DEBUG: User is signed in with email: \(currentUser.email ?? "unknown")")
        } else {
            print("DEBUG: No user is currently signed in")
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                LandingView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                SignInView()
            }
        }
    }
}
