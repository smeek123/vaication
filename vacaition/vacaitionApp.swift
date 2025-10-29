import SwiftUI
import FirebaseCore

@main
struct VacaitionApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var userManager = UserManager()
    
    init() {
        FirebaseConfig.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if userManager.isAuthenticated {
                ContentView()
                    .environmentObject(themeManager)
                    .environmentObject(userManager)
            } else {
                AuthView()
                    .environmentObject(themeManager)
                    .environmentObject(userManager)
            }
        }
    }
}
