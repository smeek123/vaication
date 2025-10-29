import Foundation
import FirebaseCore

class FirebaseConfig {
    static func configure() {
        // Firebase configuration will be handled by GoogleService-Info.plist
        // Make sure to add your GoogleService-Info.plist file to your Xcode project
        
        FirebaseApp.configure()
    }
}
