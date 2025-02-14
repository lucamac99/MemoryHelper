import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showingNotificationAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                if let email = authManager.user?.email {
                    Text("Signed in as: \(email)")
                }
                Button("Sign Out", role: .destructive) {
                    try? authManager.signOut()
                }
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Daily Reminders", isOn: Binding(
                    get: { notificationManager.isDailyReminderEnabled },
                    set: { newValue in
                        if newValue && !notificationManager.isNotificationsAuthorized {
                            requestNotifications()
                        } else {
                            notificationManager.toggleDailyReminder(enabled: newValue)
                        }
                    }
                ))
                
                Text("Receive daily reminders at 8 PM to record your memories")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Settings")
        .alert("Enable Notifications", isPresented: $showingNotificationAlert) {
            Button("Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable notifications in Settings to receive daily reminders")
        }
    }
    
    private func requestNotifications() {
        Task {
            do {
                try await notificationManager.requestAuthorization()
            } catch {
                print("Error requesting notifications: \(error)")
                showingNotificationAlert = true
            }
        }
    }
} 