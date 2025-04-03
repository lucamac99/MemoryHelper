import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Terms of Service")
                        .font(.title3.bold())
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TermsSection(title: "Acceptance of Terms", content: """
                        By accessing and using Memory Helper, you accept and agree to be bound by these terms and conditions.
                        """)
                    
                    TermsSection(title: "User Account", content: """
                        • You are responsible for maintaining your account security
                        • You agree to accept responsibility for activities under your account
                        • You must provide accurate information when creating an account
                        """)
                    
                    TermsSection(title: "Your Content", content: """
                        • You retain ownership of your memory entries
                        • You grant us license to store and process your data to provide the service
                        • You are responsible for the content you save in the app
                        """)
                }
                
                Group {
                    TermsSection(title: "Prohibited Activities", content: """
                        You agree not to:
                        • Use the app for illegal purposes
                        • Attempt to access other users' data
                        • Share harmful content
                        • Attempt to breach app security
                        """)
                    
                    TermsSection(title: "Termination", content: """
                        We reserve the right to suspend accounts that violate these terms.
                        """)
                    
                    TermsSection(title: "Changes to Terms", content: """
                        We may update these terms periodically. Significant changes will be notified through the app.
                        """)
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
            
            Text(content)
                .font(.footnote)
        }
    }
} 