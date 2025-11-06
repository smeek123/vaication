import Foundation

enum APIEndpoint {
    case chat
    case travelFlights
    case travelHotels
    case travelActivities
    
    var path: String {
        switch self {
        case .chat:
            return "/chat"
        case .travelFlights:
            return "/travel/flights"
        case .travelHotels:
            return "/travel/hotels"
        case .travelActivities:
            return "/travel/activities"
        }
    }
    
    var method: String {
        switch self {
        case .chat, .travelFlights, .travelHotels, .travelActivities:
            return "POST"
        }
    }
    
    static var baseURL: String {
        // This will be configured based on your Firebase Functions URL
        // For development, you can use the Firebase emulator or your deployed function URL
        if let baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] {
            return baseURL
        }
        
        // Try to get from Config.plist
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let apiBaseURL = config["API_Base_URL"] as? String {
            return apiBaseURL
        }
        
        // Default fallback - should be replaced with actual Firebase Functions URL
        return "https://your-project.cloudfunctions.net"
    }
    
    func url() -> URL? {
        return URL(string: "\(Self.baseURL)\(path)")
    }
}

