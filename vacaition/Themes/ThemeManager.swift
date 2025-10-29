import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var dynamicTypeSize: UserPreferences.DynamicTypeSize = .medium
    @Published var reduceMotion: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let darkModeKey = "isDarkMode"
    private let dynamicTypeKey = "dynamicTypeSize"
    private let reduceMotionKey = "reduceMotion"
    
    init() {
        loadSettings()
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        saveSettings()
    }
    
    func setDynamicTypeSize(_ size: UserPreferences.DynamicTypeSize) {
        dynamicTypeSize = size
        saveSettings()
    }
    
    func toggleReduceMotion() {
        reduceMotion.toggle()
        saveSettings()
    }
    
    private func loadSettings() {
        isDarkMode = userDefaults.bool(forKey: darkModeKey)
        
        if let dynamicTypeRawValue = userDefaults.string(forKey: dynamicTypeKey),
           let dynamicType = UserPreferences.DynamicTypeSize(rawValue: dynamicTypeRawValue) {
            dynamicTypeSize = dynamicType
        }
        
        reduceMotion = userDefaults.bool(forKey: reduceMotionKey)
    }
    
    private func saveSettings() {
        userDefaults.set(isDarkMode, forKey: darkModeKey)
        userDefaults.set(dynamicTypeSize.rawValue, forKey: dynamicTypeKey)
        userDefaults.set(reduceMotion, forKey: reduceMotionKey)
    }
}
