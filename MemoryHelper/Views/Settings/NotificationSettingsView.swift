import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var reminderTime = Date()
    
    var body: some View {
        Form {
            Section {
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
                
                if notificationManager.isDailyReminderEnabled {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: reminderTime) { _ in
                            // Update notification time
                            notificationManager.updateReminderTime(reminderTime)
                        }
                }
            } header: {
                Text("Daily Check-in")
            } footer: {
                Text("Receive daily reminders to record your memories and rate your day")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func requestNotifications() {
        Task {
            do {
                try await notificationManager.requestAuthorization()
            } catch {
                print("Error requesting notifications: \(error)")
            }
        }
    }
} 