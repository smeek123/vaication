import Foundation

struct HotelSearchResult: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var address: String
    var pricePerNight: Double
    var rating: Double
    var amenities: [String]
    var imageURL: String?
    var availability: Bool
    var latitude: Double?
    var longitude: Double?
    var description: String?
    var checkInDate: Date?
    var checkOutDate: Date?
    var totalPrice: Double? // Total price for the stay
    
    init(id: String = UUID().uuidString, name: String, address: String, pricePerNight: Double, rating: Double, amenities: [String] = [], imageURL: String? = nil, availability: Bool = true, latitude: Double? = nil, longitude: Double? = nil, description: String? = nil, checkInDate: Date? = nil, checkOutDate: Date? = nil, totalPrice: Double? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.pricePerNight = pricePerNight
        self.rating = rating
        self.amenities = amenities
        self.imageURL = imageURL
        self.availability = availability
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.totalPrice = totalPrice
    }
}

// Extension for display purposes
extension HotelSearchResult {
    var formattedPricePerNight: String {
        return String(format: "$%.2f/night", pricePerNight)
    }
    
    var formattedTotalPrice: String? {
        guard let totalPrice = totalPrice else { return nil }
        return String(format: "$%.2f", totalPrice)
    }
    
    var ratingDisplay: String {
        return String(format: "%.1f", rating)
    }
    
    var amenitiesDisplay: String {
        return amenities.joined(separator: " • ")
    }
}

