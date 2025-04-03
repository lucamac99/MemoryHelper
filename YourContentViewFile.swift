import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        if authManager.isAuthenticated {
            MainTabView(initialTab: 0) // 0 would be the Home tab index
        } else {
            SignInView()
        }
    }
}

// If you have a TabView, ensure Home is the first tab (index 0)
struct MainTabView: View {
    @State private var selectedTab: Int
    
    init(initialTab: Int) {
        _selectedTab = State(initialValue: initialTab)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Other tabs...
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3) // Assuming this is the last tab
        }
    }
} 