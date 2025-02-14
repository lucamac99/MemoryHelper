import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 70))
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    Text("Reset Password")
                        .font(.title2.bold())
                    
                    Text("Enter your email address and we'll send you a link to reset your password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    AuthTextField(text: $email,
                                placeholder: "Email",
                                icon: "envelope.fill")
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    Button {
                        Task {
                            await resetPassword()
                        }
                    } label: {
                        Text("Send Reset Link")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(email.isEmpty)
                    .opacity(email.isEmpty ? 0.6 : 1.0)
                }
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
        .alert(isSuccess ? "Success" : "Error", isPresented: $showingAlert) {
            Button("OK") {
                if isSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func resetPassword() async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isSuccess = true
            alertMessage = "Password reset email has been sent to \(email)"
            showingAlert = true
        } catch {
            isSuccess = false
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
} 