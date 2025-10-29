import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                .accessibilityLabel("Home tab")
            
            ChatView()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text("Plan")
                }
                .tag(1)
                .accessibilityLabel("Plan your trip tab")
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
                .accessibilityLabel("Profile tab")
        }
        .accentColor(AppTheme.Colors.primary)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
        .environmentObject(UserManager())
}
