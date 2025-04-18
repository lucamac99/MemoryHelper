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
        // Configure Firebase first
        FirebaseConfig.configure()
        
        #if DEBUG
        // Print OS version for debugging
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        print("DEBUG: Running on iOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)")
        
        // Check authentication state
        if let currentUser = Auth.auth().currentUser {
            print("DEBUG: User is signed in with email: \(currentUser.email ?? "unknown")")
            
            // Check user properties
            if currentUser.isEmailVerified {
                print("DEBUG: User email is verified")
            } else {
                print("DEBUG: User email is not verified")
            }
            
            if let creationDate = currentUser.metadata.creationDate {
                print("DEBUG: Account created: \(creationDate)")
            }
            
            if let lastSignInDate = currentUser.metadata.lastSignInDate {
                print("DEBUG: Last sign in: \(lastSignInDate)")
            }
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
                    .onAppear {
                        #if DEBUG
                        print("DEBUG: LandingView appeared with authenticated user")
                        #endif
                    }
            } else {
                SignInView()
                    .onAppear {
                        #if DEBUG
                        print("DEBUG: SignInView appeared")
                        #endif
                    }
            }
        }
    }
}
