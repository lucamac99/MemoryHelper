import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Terms of Service")
                        .font(.title.bold())
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .foregroundColor(.secondary)
                    
                    TermsSection(title: "Acceptance of Terms", content: """
                        By accessing and using Memory Helper, you accept and agree to be bound by the terms and conditions of this agreement.
                        """)
                    
                    TermsSection(title: "User Account", content: """
                        • You are responsible for maintaining the confidentiality of your account
                        • You agree to accept responsibility for all activities that occur under your account
                        • You must provide accurate and complete information
                        """)
                    
                    TermsSection(title: "User Content", content: """
                        • You retain ownership of your content
                        • You grant us license to use your content to provide the service
                        • You are responsible for your content
                        """)
                }
                
                Group {
                    TermsSection(title: "Prohibited Activities", content: """
                        You agree not to:
                        • Violate any laws
                        • Impersonate others
                        • Share harmful content
                        • Attempt to breach security
                        """)
                    
                    TermsSection(title: "Termination", content: """
                        We reserve the right to terminate or suspend your account at any time for any reason without notice.
                        """)
                    
                    TermsSection(title: "Changes to Terms", content: """
                        We reserve the right to modify these terms at any time. We will notify you of any changes by posting the new terms on the app.
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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
        }
    }
} 