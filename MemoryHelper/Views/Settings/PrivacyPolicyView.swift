import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Privacy Policy")
                        .font(.title3.bold())
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    PolicySection(title: "Information We Collect", content: """
                        We collect the following types of information:
                        • Personal data you provide (email for account creation)
                        • Memory entries, tags, and ratings you create
                        • App preferences and settings
                        """)
                    
                    PolicySection(title: "How We Use Your Information", content: """
                        Your information is used to:
                        • Provide and maintain the app functionality
                        • Store and sync your memory entries
                        • Improve the app experience
                        • Send optional reminders (only with permission)
                        """)
                    
                    PolicySection(title: "Data Storage", content: """
                        Your data is stored:
                        • Locally on your device
                        • In your personal cloud account (Firebase)
                        • Using industry-standard encryption
                        """)
                }
                
                Group {
                    PolicySection(title: "Your Rights", content: """
                        You have the right to:
                        • Access your stored memories
                        • Export your data at any time
                        • Delete your account and data
                        • Manage notification preferences
                        """)
                    
                    PolicySection(title: "Contact Us", content: """
                        If you have any questions about this Privacy Policy, please contact us at:
                        support@memoryhelper.app
                        """)
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PolicySection: View {
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