import SwiftUI

struct LandingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var tabManager = TabSelectionManager.shared
    
    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationView {
                MemoryListView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Memories", systemImage: "book.fill")
            }
            .tag(1)
            
            NavigationView {
                MemoryExercisesView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Training", systemImage: "brain.head.profile")
            }
            .tag(2)
            
            NavigationView {
                StatisticsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(3)
            
            NavigationView {
                ProfileView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(4)
        }
        .environmentObject(tabManager)
    }
} 