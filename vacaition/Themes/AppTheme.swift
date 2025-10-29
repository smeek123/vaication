import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        static let accent = Color("AccentColor")
        
        // Background Colors
        static let background = Color("BackgroundColor")
        static let surface = Color("SurfaceColor")
        static let cardBackground = Color("CardBackgroundColor")
        
        // Status Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Chat Colors
        static let userMessageBackground = Color("UserMessageBackground")
        static let aiMessageBackground = Color("AIMessageBackground")
        static let chatBackground = Color("ChatBackground")
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let light = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.2)
        static let heavy = Color.black.opacity(0.3)
    }
}

// MARK: - Color Extension for Dynamic Colors
extension Color {
    init(_ colorName: String) {
        self.init(colorName, bundle: .main)
    }
}
