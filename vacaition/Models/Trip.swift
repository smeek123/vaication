import Foundation
import FirebaseFirestore

struct Trip: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var destination: String
    var country: String?
    var startDate: Date
    var endDate: Date
    var budget: Double
    var interests: [Interest]
    var hotels: [Hotel]
    var itinerary: [ItineraryItem]
    var createdAt: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), destination: String, country: String? = nil, startDate: Date, endDate: Date, budget: Double, interests: [Interest] = [], hotels: [Hotel] = [], itinerary: [ItineraryItem] = []) {
        self.id = id
        self.destination = destination
        self.country = country
        self.startDate = startDate
        self.endDate = endDate
        self.budget = budget
        self.interests = interests
        self.hotels = hotels
        self.itinerary = itinerary
        self.createdAt = Date()
        self.isCompleted = false
    }
}

struct Interest: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    
    init(id: UUID = UUID(), name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

struct Hotel: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var address: String
    var pricePerNight: Double
    var rating: Double
    var amenities: [String]
    var imageURL: String?
    
    init(id: UUID = UUID(), name: String, address: String, pricePerNight: Double, rating: Double, amenities: [String] = [], imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.pricePerNight = pricePerNight
        self.rating = rating
        self.amenities = amenities
        self.imageURL = imageURL
    }
}

struct ItineraryItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var date: Date
    var time: String
    var location: String
    var cost: Double?
    var costDetails: String?
    var category: ActivityCategory
    
    init(id: UUID = UUID(), title: String, description: String, date: Date, time: String, location: String, cost: Double? = nil, costDetails: String? = nil, category: ActivityCategory) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.time = time
        self.location = location
        self.cost = cost
        self.costDetails = costDetails
        self.category = category
    }
}

enum ActivityCategory: String, CaseIterable, Codable {
    case sightseeing = "Sightseeing"
    case dining = "Dining"
    case entertainment = "Entertainment"
    case outdoor = "Outdoor"
    case shopping = "Shopping"
    case relaxation = "Relaxation"
    case transportation = "Transportation"
    
    var icon: String {
        switch self {
        case .sightseeing: return "camera.fill"
        case .dining: return "fork.knife"
        case .entertainment: return "tv.fill"
        case .outdoor: return "tree.fill"
        case .shopping: return "bag.fill"
        case .relaxation: return "leaf.fill"
        case .transportation: return "car.fill"
        }
    }
    
    var color: String {
        switch self {
        case .sightseeing: return "purple"
        case .dining: return "orange"
        case .entertainment: return "pink"
        case .outdoor: return "green"
        case .shopping: return "blue"
        case .relaxation: return "mint"
        case .transportation: return "gray"
        }
    }
}

// MARK: - Trip Firestore Extensions
extension Trip {
    static func fromFirestoreData(_ data: [String: Any]) -> Trip? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let destination = data["destination"] as? String,
              let startDateTimestamp = data["startDate"] as? Timestamp,
              let endDateTimestamp = data["endDate"] as? Timestamp,
              let budget = data["budget"] as? Double,
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            return nil
        }
        
        let country = data["country"] as? String
        let isCompleted = data["isCompleted"] as? Bool ?? false
        
        // Parse interests
        var interests: [Interest] = []
        if let interestsData = data["interests"] as? [[String: Any]] {
            for interestData in interestsData {
                if let interestIdString = interestData["id"] as? String,
                   let interestId = UUID(uuidString: interestIdString),
                   let name = interestData["name"] as? String,
                   let icon = interestData["icon"] as? String {
                    interests.append(Interest(id: interestId, name: name, icon: icon))
                }
            }
        }
        
        // Parse hotels
        var hotels: [Hotel] = []
        if let hotelsData = data["hotels"] as? [[String: Any]] {
            for hotelData in hotelsData {
                if let hotelIdString = hotelData["id"] as? String,
                   let hotelId = UUID(uuidString: hotelIdString),
                   let name = hotelData["name"] as? String,
                   let address = hotelData["address"] as? String,
                   let pricePerNight = hotelData["pricePerNight"] as? Double,
                   let rating = hotelData["rating"] as? Double {
                    let amenities = hotelData["amenities"] as? [String] ?? []
                    let imageURL = hotelData["imageURL"] as? String
                    hotels.append(Hotel(
                        id: hotelId,
                        name: name,
                        address: address,
                        pricePerNight: pricePerNight,
                        rating: rating,
                        amenities: amenities,
                        imageURL: imageURL?.isEmpty == false ? imageURL : nil
                    ))
                }
            }
        }
        
        // Parse itinerary
        var itinerary: [ItineraryItem] = []
        if let itineraryData = data["itinerary"] as? [[String: Any]] {
            for itemData in itineraryData {
                if let itemIdString = itemData["id"] as? String,
                   let itemId = UUID(uuidString: itemIdString),
                   let title = itemData["title"] as? String,
                   let description = itemData["description"] as? String,
                   let dateTimestamp = itemData["date"] as? Timestamp,
                   let time = itemData["time"] as? String,
                   let location = itemData["location"] as? String,
                   let categoryString = itemData["category"] as? String,
                   let category = ActivityCategory(rawValue: categoryString) {
                    let cost = itemData["cost"] as? Double
                    let costDetails = itemData["costDetails"] as? String
                    itinerary.append(ItineraryItem(
                        id: itemId,
                        title: title,
                        description: description,
                        date: dateTimestamp.dateValue(),
                        time: time,
                        location: location,
                        cost: cost,
                        costDetails: costDetails,
                        category: category
                    ))
                }
            }
        }
        
        var trip = Trip(
            id: id,
            destination: destination,
            country: country,
            startDate: startDateTimestamp.dateValue(),
            endDate: endDateTimestamp.dateValue(),
            budget: budget,
            interests: interests,
            hotels: hotels,
            itinerary: itinerary
        )
        trip.createdAt = createdAtTimestamp.dateValue()
        trip.isCompleted = isCompleted
        
        return trip
    }
}
