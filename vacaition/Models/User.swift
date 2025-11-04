import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var profileImageURL: String?
    var savedTrips: [Trip] = []
    var preferences: UserPreferences
    var createdAt: Date
    var lastLoginAt: Date?
    
    init(id: UUID = UUID(), name: String, email: String, profileImageURL: String? = nil, preferences: UserPreferences = UserPreferences(), createdAt: Date = Date(), lastLoginAt: Date? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
        self.preferences = preferences
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
}

// MARK: - Firestore Extensions
extension User {
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id.uuidString,
            "name": name,
            "email": email,
            "createdAt": Timestamp(date: createdAt),
            "savedTrips": savedTrips.map { trip in
                var tripData: [String: Any] = [
                    "id": trip.id.uuidString,
                    "destination": trip.destination,
                    "startDate": Timestamp(date: trip.startDate),
                    "endDate": Timestamp(date: trip.endDate),
                    "budget": trip.budget,
                    "interests": trip.interests.map { interest in
                        [
                            "id": interest.id.uuidString,
                            "name": interest.name,
                            "icon": interest.icon
                        ]
                    },
                    "hotels": trip.hotels.map { hotel in
                        [
                            "id": hotel.id.uuidString,
                            "name": hotel.name,
                            "address": hotel.address,
                            "pricePerNight": hotel.pricePerNight,
                            "rating": hotel.rating,
                            "amenities": hotel.amenities,
                            "imageURL": hotel.imageURL ?? ""
                        ]
                    },
                    "itinerary": trip.itinerary.map { item in
                        [
                            "id": item.id.uuidString,
                            "title": item.title,
                            "description": item.description,
                            "date": Timestamp(date: item.date),
                            "time": item.time,
                            "location": item.location,
                            "cost": item.cost ?? 0.0,
                            "category": item.category.rawValue
                        ]
                    },
                    "createdAt": Timestamp(date: trip.createdAt),
                    "isCompleted": trip.isCompleted
                ]
                
                if let country = trip.country {
                    tripData["country"] = country
                }
                
                return tripData
            },
            "preferences": [
                "isDarkMode": preferences.isDarkMode,
                "dynamicTypeSize": preferences.dynamicTypeSize.rawValue,
                "reduceMotion": preferences.reduceMotion,
                "notificationsEnabled": preferences.notificationsEnabled,
                "preferredLanguage": preferences.preferredLanguage
            ]
        ]
        
        if let profileImageURL = profileImageURL {
            data["profileImageURL"] = profileImageURL
        }
        
        if let lastLoginAt = lastLoginAt {
            data["lastLoginAt"] = Timestamp(date: lastLoginAt)
        }
        
        return data
    }
    
    static func fromFirestoreData(_ data: [String: Any]) -> User? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = data["name"] as? String,
              let email = data["email"] as? String,
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            return nil
        }
        
        let profileImageURL = data["profileImageURL"] as? String
        
        // Parse saved trips
        var savedTrips: [Trip] = []
        if let tripsData = data["savedTrips"] as? [[String: Any]] {
            for tripData in tripsData {
                if let trip = Trip.fromFirestoreData(tripData) {
                    savedTrips.append(trip)
                }
            }
        }
        
        // Parse preferences
        let preferences = UserPreferences.fromFirestoreData(data["preferences"] as? [String: Any] ?? [:])
        
        // Parse last login
        let lastLoginAt = (data["lastLoginAt"] as? Timestamp)?.dateValue()
        
        return User(
            id: id,
            name: name,
            email: email,
            profileImageURL: profileImageURL,
            preferences: preferences,
            createdAt: createdAtTimestamp.dateValue(),
            lastLoginAt: lastLoginAt
        )
    }
}

struct UserPreferences: Codable {
    var isDarkMode: Bool = false
    var dynamicTypeSize: DynamicTypeSize = .medium
    var reduceMotion: Bool = false
    var notificationsEnabled: Bool = true
    var preferredLanguage: String = "en"
    
    enum DynamicTypeSize: String, CaseIterable, Codable {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
        case extraLarge = "Extra Large"
        case xxLarge = "XX Large"
        case xxxLarge = "XXX Large"
        
        var accessibilityLabel: String {
            switch self {
            case .small: return "Small text size"
            case .medium: return "Medium text size"
            case .large: return "Large text size"
            case .extraLarge: return "Extra large text size"
            case .xxLarge: return "Double extra large text size"
            case .xxxLarge: return "Triple extra large text size"
            }
        }
    }
}

// MARK: - UserPreferences Firestore Extensions
extension UserPreferences {
    static func fromFirestoreData(_ data: [String: Any]) -> UserPreferences {
        var preferences = UserPreferences()
        
        preferences.isDarkMode = data["isDarkMode"] as? Bool ?? false
        preferences.reduceMotion = data["reduceMotion"] as? Bool ?? false
        preferences.notificationsEnabled = data["notificationsEnabled"] as? Bool ?? true
        preferences.preferredLanguage = data["preferredLanguage"] as? String ?? "en"
        
        if let dynamicTypeSizeString = data["dynamicTypeSize"] as? String,
           let dynamicTypeSize = DynamicTypeSize(rawValue: dynamicTypeSizeString) {
            preferences.dynamicTypeSize = dynamicTypeSize
        }
        
        return preferences
    }
}
