import SwiftUI

struct LandingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            MemoryListView()
                .tabItem {
                    Label("Memories", systemImage: "book.fill")
                }
                .tag(1)
            
            MemoryExercisesView()
                .tabItem {
                    Label("Training", systemImage: "brain.head.profile")
                }
                .tag(2)
            
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
    }
} 