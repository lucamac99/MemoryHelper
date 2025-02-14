import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationsAuthorized = false
    @Published var isDailyReminderEnabled = true
    
    init() {
        checkAuthorizationStatus()
        isDailyReminderEnabled = UserDefaults.standard.bool(forKey: "isDailyReminderEnabled")
    }
    
    func requestAuthorization() async throws {
        let options: UNAuthorizationOptions = [.alert, .sound]
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        
        await MainActor.run {
            self.isNotificationsAuthorized = granted
        }
        
        if granted && isDailyReminderEnabled {
            scheduleDailyNotification()
        }
    }
    
    func toggleDailyReminder(enabled: Bool) {
        isDailyReminderEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "isDailyReminderEnabled")
        
        if enabled {
            scheduleDailyNotification()
        } else {
            cancelAllNotifications()
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "How was your day?"
        content.body = "Take a moment to record your memories and rate your day."
        content.sound = .default
        
        // Create a time-based trigger for 8 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func updateReminderTime(_ time: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        if isDailyReminderEnabled {
            cancelAllNotifications()
            scheduleDailyNotification(at: components)
        }
        
        UserDefaults.standard.set(components.hour, forKey: "reminderHour")
        UserDefaults.standard.set(components.minute, forKey: "reminderMinute")
    }
    
    private func scheduleDailyNotification(at components: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())) {
        let content = UNMutableNotificationContent()
        content.title = "How was your day?"
        content.body = "Take a moment to record your memories and rate your day."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
} 