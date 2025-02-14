import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Privacy Policy")
                        .font(.title.bold())
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .foregroundColor(.secondary)
                    
                    PolicySection(title: "Information We Collect", content: """
                        We collect the following types of information:
                        • Personal data you provide (email address)
                        • Memory entries and ratings you create
                        • Usage data and app preferences
                        """)
                    
                    PolicySection(title: "How We Use Your Information", content: """
                        Your information is used to:
                        • Provide and maintain the app's functionality
                        • Save and sync your memory entries
                        • Improve the app experience
                        • Send notifications (only with your permission)
                        """)
                    
                    PolicySection(title: "Data Storage", content: """
                        Your data is stored:
                        • Locally on your device
                        • In your personal Firebase account
                        • Using secure encryption methods
                        """)
                }
                
                Group {
                    PolicySection(title: "Your Rights", content: """
                        You have the right to:
                        • Access your data
                        • Export your data
                        • Delete your data
                        • Opt out of notifications
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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
        }
    }
} 