import Foundation

struct Activity: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var address: String?
    var rating: Double?
    var priceLevel: Int? // 0-4 scale, where 0 is free and 4 is very expensive
    var types: [String]? // e.g., ["tourist_attraction", "museum", "park"]
    var photoReference: String?
    var description: String?
    var latitude: Double?
    var longitude: Double?
    var openingHours: [String]? // Opening hours for each day
    var website: String?
    var phoneNumber: String?
    
    init(id: String = UUID().uuidString, name: String, address: String? = nil, rating: Double? = nil, priceLevel: Int? = nil, types: [String]? = nil, photoReference: String? = nil, description: String? = nil, latitude: Double? = nil, longitude: Double? = nil, openingHours: [String]? = nil, website: String? = nil, phoneNumber: String? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.rating = rating
        self.priceLevel = priceLevel
        self.types = types
        self.photoReference = photoReference
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.openingHours = openingHours
        self.website = website
        self.phoneNumber = phoneNumber
    }
}

// Extension for display purposes
extension Activity {
    var ratingDisplay: String? {
        guard let rating = rating else { return nil }
        return String(format: "%.1f", rating)
    }
    
    var priceLevelDisplay: String {
        guard let priceLevel = priceLevel else { return "Price TBD" }
        switch priceLevel {
        case 0:
            return "Free"
        case 1:
            return "$"
        case 2:
            return "$$"
        case 3:
            return "$$$"
        case 4:
            return "$$$$"
        default:
            return "Price TBD"
        }
    }
    
    var primaryType: String? {
        return types?.first?.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    var photoURL: String? {
        guard photoReference != nil else { return nil }
        // This would be constructed with Google Places Photo API
        // For now, return nil - will be implemented when backend is ready
        return nil
    }
}

