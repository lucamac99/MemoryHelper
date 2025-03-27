import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddEntry = false
    @State private var selectedEntryType = "note"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HeaderView()
                    
                    // Quick Actions
                    QuickActionsView(
                        showingAddEntry: $showingAddEntry,
                        selectedEntryType: $selectedEntryType
                    )
                    
                    // Daily Stats
                    DailyStatsView()
                    
                    // Recent Memories
                    RecentMemoriesView()
                }
                .padding()
            }
            .navigationTitle("Memory Helper")
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView(initialType: selectedEntryType)
            }
        }
    }
}

struct HeaderView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Welcome back,")
                    .font(.title2)
                Text(authManager.user?.email?.components(separatedBy: "@").first ?? "User")
                    .font(.title2.bold())
                Spacer()
            }
            
            Text("How's your day going?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemBackground))
            .shadow(color: .gray.opacity(0.2), radius: 5))
    }
}

struct QuickActionsView: View {
    @Binding var showingAddEntry: Bool
    @Binding var selectedEntryType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickActionButton(
                    title: "New Note",
                    systemImage: "note.text",
                    color: .blue
                ) {
                    selectedEntryType = "note"
                    showingAddEntry = true
                }
                
                QuickActionButton(
                    title: "Rate Day",
                    systemImage: "star.fill",
                    color: .yellow
                ) {
                    selectedEntryType = "rating"
                    showingAddEntry = true
                }
                
                QuickActionButton(
                    title: "Add Event",
                    systemImage: "calendar",
                    color: .green
                ) {
                    selectedEntryType = "event"
                    showingAddEntry = true
                }
                
                NavigationLink(destination: StatisticsView()) {
                    QuickActionButtonContent(
                        title: "Statistics",
                        systemImage: "chart.bar.fill",
                        color: .purple
                    )
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemBackground))
            .shadow(color: .gray.opacity(0.2), radius: 5))
    }
}

struct QuickActionButtonContent: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(color.opacity(0.1)))
    }
}

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            QuickActionButtonContent(
                title: title,
                systemImage: systemImage,
                color: color
            )
        }
    }
} 