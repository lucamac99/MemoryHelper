import SwiftUI

struct LandingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var tabManager = TabSelectionManager.shared
    
    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            // Use if/else flow control for NavigationView vs NavigationStack based on iOS version
            if #available(iOS 16.0, *) {
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            } else {
                NavigationView {
                    HomeView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            }
            
            if #available(iOS 16.0, *) {
                NavigationStack {
                    MemoryListView()
                }
                .tabItem {
                    Label("Memories", systemImage: "book.fill")
                }
                .tag(1)
            } else {
                NavigationView {
                    MemoryListView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Memories", systemImage: "book.fill")
                }
                .tag(1)
            }
            
            if #available(iOS 16.0, *) {
                NavigationStack {
                    MemoryExercisesView()
                }
                .tabItem {
                    Label("Training", systemImage: "brain.head.profile")
                }
                .tag(2)
            } else {
                NavigationView {
                    MemoryExercisesView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Training", systemImage: "brain.head.profile")
                }
                .tag(2)
            }
            
            if #available(iOS 16.0, *) {
                NavigationStack {
                    StatisticsView()
                }
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(3)
            } else {
                NavigationView {
                    StatisticsView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(3)
            }
            
            if #available(iOS 16.0, *) {
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
            } else {
                NavigationView {
                    ProfileView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
            }
        }
        .environmentObject(tabManager)
        .onAppear {
            // Set the tab selection based on the initialView set in AuthenticationManager
            tabManager.navigateTo(viewName: authManager.initialView)
            
            #if DEBUG
            print("DEBUG: LandingView appeared with initialView: \(authManager.initialView)")
            #endif
        }
    }
} 