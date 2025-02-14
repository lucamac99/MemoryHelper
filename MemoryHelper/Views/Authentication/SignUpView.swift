import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthenticationManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    Text("Create Account")
                        .font(.title2.bold())
                        .padding(.top)
                    
                    Text("Sign up to start tracking your memories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
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
                            .textContentType(.newPassword)
                        
                        AuthSecureField(text: $confirmPassword,
                                      placeholder: "Confirm Password",
                                      icon: "lock.fill")
                            .textContentType(.newPassword)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            await signUp()
                        }
                    } label: {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(!isValidInput)
                    .opacity(isValidInput ? 1.0 : 0.6)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isValidInput: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func signUp() async {
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showingAlert = true
            return
        }
        
        do {
            try await authManager.signUp(email: email, password: password)
            dismiss()
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
} 