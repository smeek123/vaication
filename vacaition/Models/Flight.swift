import Foundation

struct Flight: Identifiable, Codable, Equatable {
    let id: String
    var origin: String
    var destination: String
    var departureDate: Date
    var returnDate: Date?
    var price: Double
    var airline: String?
    var duration: String?
    var numberOfStops: Int?
    var departureTime: String?
    var arrivalTime: String?
    
    init(id: String = UUID().uuidString, origin: String, destination: String, departureDate: Date, returnDate: Date? = nil, price: Double, airline: String? = nil, duration: String? = nil, numberOfStops: Int? = nil, departureTime: String? = nil, arrivalTime: String? = nil) {
        self.id = id
        self.origin = origin
        self.destination = destination
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.price = price
        self.airline = airline
        self.duration = duration
        self.numberOfStops = numberOfStops
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
    }
}

// Extension for display purposes
extension Flight {
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var isRoundTrip: Bool {
        return returnDate != nil
    }
    
    var durationDisplay: String {
        if let duration = duration {
            return duration
        }
        return "Duration TBD"
    }
}

