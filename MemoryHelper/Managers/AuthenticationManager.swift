import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

enum AuthError: LocalizedError {
    case signInError(String)
    case signUpError(String)
    case signOutError
    case userNotFound
    case googleSignInError(String)
    
    var errorDescription: String? {
        switch self {
        case .signInError(let message),
             .signUpError(let message),
             .googleSignInError(let message):
            return message
        case .signOutError:
            return "Failed to sign out. Please try again."
        case .userNotFound:
            return "User not found."
        }
    }
}

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var initialView: String = "home" // Default view after authentication
    
    init() {
        user = Auth.auth().currentUser
        isAuthenticated = user != nil
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error as NSError? {
                let errorMessage = self?.handleFirebaseError(error) ?? error.localizedDescription
                completion(false, errorMessage)
                return
            }
            
            guard let self = self, let user = authResult?.user else {
                completion(false, "Failed to retrieve user information")
                return
            }
            
            self.user = user
            self.isAuthenticated = true
            
            // Check if this is a new user (by creation date)
            let creationDate = user.metadata.creationDate
            let lastSignInDate = user.metadata.lastSignInDate
            let isNewUser = creationDate?.timeIntervalSince1970 == lastSignInDate?.timeIntervalSince1970
            
            // If this is a new user account, reset onboarding
            //if isNewUser {
            //OnboardingManager.shared.resetOnboarding()
            //}
            
            self.initialView = "home" // Ensure home is the destination after sign-in
            
            completion(true, nil)
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            await MainActor.run {
                self.user = result.user
                self.isAuthenticated = true
            }
        } catch let error as NSError {
            let errorMessage = self.handleFirebaseError(error)
            throw AuthError.signUpError(errorMessage)
        }
    }
    
    @MainActor
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.googleSignInError("Firebase configuration error")
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.googleSignInError("No root view controller found")
        }
        
        // Configure Google Sign In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.googleSignInError("Could not get ID token")
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            self.user = authResult.user
            self.isAuthenticated = true
            
        } catch {
            throw AuthError.googleSignInError(error.localizedDescription)
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut() // Sign out from Google as well
            self.user = nil
            self.isAuthenticated = false
        } catch {
            throw AuthError.signOutError
        }
    }
    
    private func handleFirebaseError(_ error: NSError) -> String {
        if let errorCode = AuthErrorCode(_bridgedNSError: error) {
            switch errorCode.code {
            case .invalidEmail:
                return "Invalid email address."
            case .emailAlreadyInUse:
                return "This email is already registered."
            case .weakPassword:
                return "Password is too weak. Please use at least 6 characters."
            case .wrongPassword:
                return "Incorrect password."
            case .userNotFound:
                return "Account not found for this email."
            case .networkError:
                return "Network error. Please check your connection."
            default:
                return error.localizedDescription
            }
        } else {
            return error.localizedDescription
        }
    }
    
    func signIn(email: String, password: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            signIn(email: email, password: password) { success, errorMessage in
                if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: AuthError.signInError(errorMessage ?? "Unknown error"))
                }
            }
        }
    }
}

// Extension for nil check on empty strings
extension String {
    func nilIfEmpty() -> String? {
        return self.isEmpty ? nil : self
    }
} 
