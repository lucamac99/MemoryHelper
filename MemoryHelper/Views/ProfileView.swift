import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingLogoutAlert = false
    @State private var showingEditProfile = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Header
                ProfileHeaderView()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.bottom)
                
                // Settings Sections
                Section {
                    NavigationLink(destination: NotificationSettingsView()) {
                        SettingsRowView(
                            title: "Notifications",
                            icon: "bell.fill",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        SettingsRowView(
                            title: "Privacy",
                            icon: "lock.fill",
                            color: .green
                        )
                    }
                    
                    NavigationLink(destination: AppearanceSettingsView()) {
                        SettingsRowView(
                            title: "Appearance",
                            icon: "paintbrush.fill",
                            color: .purple
                        )
                    }
                } header: {
                    Text("Settings")
                }
                .listRowBackground(Color(.systemBackground))
                
                Section {
                    Button(action: { showingLogoutAlert = true }) {
                        SettingsRowView(
                            title: "Sign Out",
                            icon: "arrow.right.circle.fill",
                            color: .red
                        )
                    }
                }
                .listRowBackground(Color(.systemBackground))
            }
            .navigationTitle("Profile")
            .listStyle(.insetGrouped)
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    try? authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct ProfileHeaderView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .opacity(isAnimating ? 1.0 : 0.8)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(authManager.user?.email?.components(separatedBy: "@").first ?? "User")
                    .font(.title2.bold())
                
                Text(authManager.user?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 10)
        )
        .padding()
    }
}

struct SettingsRowView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
    }
}

// Preview for SwiftUI canvas
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 