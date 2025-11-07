import Foundation
import FirebaseAuth

// MARK: - Request Models
struct ChatRequest: Codable {
    let message: String
    let conversationHistory: [ChatMessage]
    let userPreferences: UserPreferencesRequest?
}

struct ChatMessage: Codable {
    let role: String // "user" or "assistant"
    let content: String
    let timestamp: Date?
}

struct UserPreferencesRequest: Codable {
    let savedTrips: [String] // Trip destinations for context
    let preferences: [String: String]?
}

// MARK: - Response Models
struct ChatResponse: Codable {
    let response: String
    let tripSuggestion: TripSuggestionResponse?
    let quickReplies: [QuickReplyResponse]?
    let travelData: TravelDataResponse?
}

struct TripSuggestionResponse: Codable {
    let destination: String
    let country: String?
    let startDate: String // ISO8601 date string
    let endDate: String // ISO8601 date string
    let budget: Double
    let interests: [InterestResponse]
    let hotels: [HotelResponse]
    let itinerary: [ItineraryItemResponse]
}

struct InterestResponse: Codable {
    let name: String
    let icon: String
}

struct HotelResponse: Codable {
    let name: String
    let address: String
    let pricePerNight: Double
    let rating: Double
    let amenities: [String]
    let imageURL: String?
}

struct ItineraryItemResponse: Codable {
    let title: String
    let description: String
    let date: String // ISO8601 date string
    let time: String
    let location: String
    let cost: Double?
    let category: String
}

struct QuickReplyResponse: Codable {
    let title: String
    let action: String
}

struct TravelDataResponse: Codable {
    let flights: [FlightResponse]?
    let hotels: [HotelSearchResponse]?
    let activities: [ActivityResponse]?
}

struct FlightResponse: Codable {
    let id: String
    let origin: String
    let destination: String
    let departureDate: String
    let returnDate: String?
    let price: Double
    let airline: String?
    let duration: String?
}

struct HotelSearchResponse: Codable {
    let id: String
    let name: String
    let address: String
    let pricePerNight: Double
    let rating: Double
    let amenities: [String]
    let imageURL: String?
    let availability: Bool?
}

struct ActivityResponse: Codable {
    let id: String
    let name: String
    let address: String?
    let rating: Double?
    let priceLevel: Int?
    let types: [String]?
    let photoReference: String?
}

// MARK: - AIChatService
class AIChatService {
    static let shared = AIChatService()
    
    private init() {}
    
    func sendMessage(
        _ message: String,
        conversationHistory: [Message],
        userPreferences: UserPreferences? = nil,
        savedTrips: [Trip] = []
    ) async throws -> AIResponse {
        // Convert Message array to ChatMessage array
        let chatHistory = conversationHistory.map { message in
            ChatMessage(
                role: message.isFromUser ? "user" : "assistant",
                content: message.content,
                timestamp: message.timestamp
            )
        }
        
        // Build user preferences request
        let userPrefsRequest: UserPreferencesRequest?
        if let preferences = userPreferences {
            let savedTripDestinations = savedTrips.map { $0.destination }
            userPrefsRequest = UserPreferencesRequest(
                savedTrips: savedTripDestinations,
                preferences: [
                    "preferredLanguage": preferences.preferredLanguage
                ]
            )
        } else {
            userPrefsRequest = nil
        }
        
        // Build request body - encode as JSON properly
        var requestBodyDict: [String: Any] = [
            "message": message,
            "conversationHistory": chatHistory.map { chatMsg -> [String: Any] in
                return [
                    "role": chatMsg.role,
                    "content": chatMsg.content,
                    "timestamp": chatMsg.timestamp?.ISO8601Format() ?? ""
                ]
            }
        ]
        
        // Add user preferences if available
        if let userPrefsRequest = userPrefsRequest {
            requestBodyDict["userPreferences"] = [
                "savedTrips": userPrefsRequest.savedTrips,
                "preferences": userPrefsRequest.preferences ?? [:]
            ]
        }
        
        // Make API call
        let response: ChatResponse = try await APIRequest.perform(
            endpoint: .chat,
            body: requestBodyDict,
            responseType: ChatResponse.self
        )
        
        // Convert response to AIResponse
        return try convertToAIResponse(response)
    }
    
    private func convertToAIResponse(_ response: ChatResponse) throws -> AIResponse {
        // Convert trip suggestion if present
        var tripSuggestion: Trip?
        if let tripData = response.tripSuggestion {
            tripSuggestion = try convertToTrip(tripData)
        }
        
        // Convert quick replies
        let quickReplies = response.quickReplies?.map { reply in
            QuickReply(title: reply.title, action: reply.action)
        }
        
        let cleanedText = cleanAIResponseText(response.response)
        let summarizedText: String
        if let _ = tripSuggestion, cleanedText.count > 400 {
            summarizedText = "I've mapped out a full itinerary for you. View the trip details page for the complete plan!"
        } else {
            summarizedText = cleanedText
        }
        let finalText: String
        if summarizedText.isEmpty, tripSuggestion != nil {
            finalText = "I put together a tailored trip plan for you. View the trip details page for the full itinerary!"
        } else {
            finalText = summarizedText
        }
        
        return AIResponse(
            text: finalText,
            tripSuggestion: tripSuggestion,
            quickReplies: quickReplies
        )
    }

    private func cleanAIResponseText(_ text: String) -> String {
        let pattern = #"TRIP_DATA_START[\s\S]*?TRIP_DATA_END"#
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let stripped: String
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            stripped = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
        } else {
            stripped = text
        }
        let collapsedWhitespace = stripped.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        return collapsedWhitespace.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func convertToTrip(_ tripData: TripSuggestionResponse) throws -> Trip {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.calendar = Calendar(identifier: .iso8601)
        fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
        fallbackFormatter.dateFormat = "yyyy-MM-dd"
        
        func parseDate(_ value: String) -> Date? {
            isoFormatter.date(from: value) ?? fallbackFormatter.date(from: value)
        }
        
        guard let startDate = parseDate(tripData.startDate),
              let endDate = parseDate(tripData.endDate) else {
            throw APIError.decodingError(NSError(domain: "AIChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"]))
        }
        
        let interests = tripData.interests.map { interest in
            Interest(name: interest.name, icon: interest.icon)
        }
        
        let hotels = tripData.hotels.map { hotel in
            Hotel(
                name: hotel.name,
                address: hotel.address,
                pricePerNight: hotel.pricePerNight,
                rating: hotel.rating,
                amenities: hotel.amenities,
                imageURL: hotel.imageURL
            )
        }
        
        let itinerary = tripData.itinerary.map { item in
            let itemDate = parseDate(item.date) ?? startDate
            let category = ActivityCategory(rawValue: item.category) ?? .sightseeing
            
            return ItineraryItem(
                title: item.title,
                description: item.description,
                date: itemDate,
                time: item.time,
                location: item.location,
                cost: item.cost,
                category: category
            )
        }
        
        return Trip(
            destination: tripData.destination,
            country: tripData.country,
            startDate: startDate,
            endDate: endDate,
            budget: tripData.budget,
            interests: interests,
            hotels: hotels,
            itinerary: itinerary
        )
    }
}

// MARK: - Date Extension
extension Date {
    func ISO8601Format() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

