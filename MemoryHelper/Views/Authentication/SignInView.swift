import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit

struct SignInView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // For Apple Sign In
    @State private var currentNonce: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Logo
                    Image("MemoryHelperLogo_1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 40)
                        .padding(.bottom, 10)
                    
                    Text("Memory Helper")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Email & Password Fields
                    VStack(spacing: 20) {
                        AuthTextField(text: $email,
                                    placeholder: "Email",
                                    icon: "envelope.fill")
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        AuthSecureField(text: $password,
                                      placeholder: "Password",
                                      icon: "lock.fill")
                    }
                    .padding(.horizontal)
                    
                    // Sign In Button
                    Button {
                        signIn()
                    } label: {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Forgot Password
                    Button("Forgot Password?") {
                        showingForgotPassword = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    
                    // Divider
                    HStack {
                        VStack { Divider() }
                        Text("or")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        VStack { Divider() }
                    }
                    .padding(.horizontal)
                    
                    // Sign in with Apple
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            // Generate a nonce for the request
                            let nonce = randomNonceString()
                            currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = sha256(nonce)
                        },
                        onCompletion: { result in
                            handleAppleSignInResult(result)
                        }
                    )
                    .frame(height: 50)
                    .padding(.horizontal)
                    .cornerRadius(12)
                    
                    // Google Sign In
                    Button {
                        Task {
                            do {
                                try await authManager.signInWithGoogle()
                            } catch {
                                alertMessage = error.localizedDescription
                                showingAlert = true
                            }
                        }
                    } label: {
                        HStack {
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            
                            Text("Continue with Google")
                                .font(.headline)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .gray.opacity(0.2), radius: 3)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign Up") {
                            showingSignUp = true
                        }
                        .foregroundColor(.blue)
                    }
                    .font(.subheadline)
                    .padding(.top)
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func signIn() {
        authManager.signIn(email: email, password: password) { success, errorMessage in
            if success {
                // Sign in successful - ensure we navigate to Home
                TabSelectionManager.shared.navigateTo(viewName: "home")
            } else if let errorMessage = errorMessage {
                // Show alert with error message
                alertMessage = errorMessage
                showingAlert = true
            }
        }
    }
    
    private func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            // Process the authorization result directly
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8),
                  let nonce = currentNonce else {
                alertMessage = "Could not get Apple ID credentials"
                showingAlert = true
                return
            }
            
            // Use the credential to sign in
            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: tokenString,
                rawNonce: nonce
            )
            
            // Sign in to Firebase with the credential
            Task {
                do {
                    let authResult = try await Auth.auth().signIn(with: credential)
                    
                    // Update user's display name if this is a new user
                    if let fullName = appleIDCredential.fullName,
                       let givenName = fullName.givenName ?? fullName.nickname,
                       let familyName = fullName.familyName,
                       authResult.additionalUserInfo?.isNewUser == true {
                        
                        let displayName = [givenName, familyName].joined(separator: " ")
                        let changeRequest = authResult.user.createProfileChangeRequest()
                        changeRequest.displayName = displayName
                        try await changeRequest.commitChanges()
                    }
                    
                    // Update the auth manager's state
                    await MainActor.run {
                        authManager.user = authResult.user
                        authManager.isAuthenticated = true
                        authManager.initialView = "home" // Set initial view to home
                        TabSelectionManager.shared.navigateTo(viewName: "home")
                    }
                    
                } catch {
                    await MainActor.run {
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            }
            
        case .failure(let error):
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    // Generate a random nonce for Apple Sign In
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // Hash the nonce with SHA256 to use with Apple Sign In
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct AuthSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    @State private var isSecured = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if isSecured {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
            }
            
            Button {
                isSecured.toggle()
            } label: {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
} 