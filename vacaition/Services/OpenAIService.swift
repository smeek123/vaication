import Foundation
import Combine

// MARK: - AI Response Model
struct AIResponse {
    let text: String
    let tripSuggestion: Trip?
    let quickReplies: [QuickReply]?
}

// MARK: - OpenAI API Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Trip Parsing Models
struct ParsedTripData: Codable {
    let destination: String?
    let startDate: String?
    let endDate: String?
    let duration: Int?
    let budget: Double?
    let interests: [String]?
    let activities: [String]?
    let hotels: [String]?
    let restaurants: [String]?
    let attractions: [String]?
}

// MARK: - OpenAI Service
// ⚠️ DEPRECATED: This service is no longer used.
// All OpenAI API calls now go through the backend (AIChatService -> Firebase Functions).
// This file is kept for reference but should not be used in production.
// API keys are now stored securely on the backend only.
@available(*, deprecated, message: "Use AIChatService instead. API keys should never be in client code.")
class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let session = URLSession.shared
    
    // Luna's personality prompt
    private let lunaPrompt = """
    You are Luna — a smart, friendly AI travel companion shaped like a curious owl. 
    You help users plan trips, discover cool destinations, and find local gems — all while keeping things fun, relaxed, and easy to understand.

    Your personality:
    - You're upbeat, curious, and love helping people explore the world.
    - Talk like a friendly, well-traveled friend — natural, warm, and a little playful.
    - You're wise but never stiff or robotic. Think "cool older sister who knows all the travel hacks."
    - Occasionally make light, charming nods to being an owl (like "I've seen that city from above — gorgeous at sunset!"), but don't overuse it.

    How you respond:
    - Keep your answers focused on travel, exploration, or culture.
    - Be helpful and specific — include ideas, tips, or short lists when needed.
    - Write clearly and casually; use contractions and natural language.
    - If a user asks something off-topic, give a quick friendly answer, then steer back to travel.
    - Ask small follow-up questions when it makes sense ("Are you more into beaches or city adventures?") to personalize your help.

    Example style:
    User: "Where should I go for a weekend trip from Paris?"
    Luna: "Ooo, weekend getaway time! If you want cozy charm, head to Strasbourg — it's like stepping into a fairytale. 
    Or if you're craving sea breeze and crepes, Normandy's perfect. Wanna keep it chill or pack in sightseeing?"

    User: "What's fun to do in Tokyo?"
    Luna: "Tokyo's got a little bit of everything! You could hit up Shibuya for the chaos, chill in Ueno Park, or eat your way through tiny ramen shops in Golden Gai. 
    Are you more into food, shopping, or nightlife?"

    Your goal:
    Make travel feel exciting, stress-free, and personal — like chatting with a friend who always knows where to go next.
    
    IMPORTANT: When you provide trip suggestions or details, format them in a structured way that can be parsed. Use this format for trip information:
    
    TRIP_DATA_START
    {
        "destination": "City, Country",
        "startDate": "YYYY-MM-DD",
        "endDate": "YYYY-MM-DD", 
        "duration": 7,
        "budget": 2500.0,
        "interests": ["culture", "food", "history"],
        "activities": ["Visit museums", "Food tour", "Walking tour"],
        "hotels": ["Hotel Name 1", "Hotel Name 2"],
        "restaurants": ["Restaurant 1", "Restaurant 2"],
        "attractions": ["Attraction 1", "Attraction 2"]
    }
    TRIP_DATA_END
    
    Only include this structured data when you're actually suggesting a complete trip plan.
    """
    
    private init() {
        // Get API key from configuration or environment
        self.apiKey = OpenAIService.getAPIKey()
    }
    
    private static func getAPIKey() -> String {
        // ⚠️ SECURITY WARNING: This method is deprecated.
        // API keys should NEVER be in client code.
        // All API calls should go through the backend (AIChatService).
        
        // Try to get from environment variable first (for development only)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            print("⚠️ WARNING: Using OpenAI API key from environment. This should only be for development.")
            return envKey
        }
        
        // Try to get from configuration file (DEPRECATED - should not be used)
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let apiKey = config["OpenAI_API_Key"] as? String {
            print("⚠️ WARNING: OpenAI API key found in Config.plist. This is a security risk!")
            print("⚠️ Please remove the API key from Config.plist and use AIChatService instead.")
            return apiKey
        }
        
        // Fallback - this service should not be used
        print("⚠️ ERROR: OpenAIService is deprecated. Use AIChatService instead.")
        return "DEPRECATED_USE_AICHATSERVICE"
    }
    
    func sendMessage(_ userMessage: String, conversationHistory: [Message] = []) async throws -> AIResponse {
        // Build conversation context
        var messages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: lunaPrompt)
        ]
        
        // Add conversation history (last 10 messages to keep context manageable)
        let recentHistory = conversationHistory.suffix(10)
        for message in recentHistory {
            let role = message.isFromUser ? "user" : "assistant"
            messages.append(OpenAIMessage(role: role, content: message.content))
        }
        
        // Add current user message
        messages.append(OpenAIMessage(role: "user", content: userMessage))
        
        // Create request
        let request = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: messages,
            temperature: 0.7,
            maxTokens: 1000
        )
        
        // Make API call
        let response = try await makeAPICall(request: request)
        
        // Parse response
        return try parseResponse(response)
    }
    
    private func makeAPICall(request: OpenAIRequest) async throws -> OpenAIResponse {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                throw OpenAIError.invalidAPIKey
            } else if httpResponse.statusCode == 429 {
                throw OpenAIError.rateLimitExceeded
            } else if httpResponse.statusCode == 402 {
                throw OpenAIError.quotaExceeded
            } else if httpResponse.statusCode != 200 {
                throw OpenAIError.serverError(httpResponse.statusCode)
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            return openAIResponse
            
        } catch let error as OpenAIError {
            throw error
        } catch {
            throw OpenAIError.networkError(error.localizedDescription)
        }
    }
    
    private func parseResponse(_ response: OpenAIResponse) throws -> AIResponse {
        guard let choice = response.choices.first else {
            throw OpenAIError.noResponse
        }
        
        let content = choice.message.content
        
        // Try to extract trip data from the response
        let tripSuggestion = extractTripData(from: content)
        
        // Generate quick replies based on the response
        let quickReplies = generateQuickReplies(for: content, hasTripSuggestion: tripSuggestion != nil)
        
        return AIResponse(
            text: content,
            tripSuggestion: tripSuggestion,
            quickReplies: quickReplies
        )
    }
    
    private func extractTripData(from content: String) -> Trip? {
        // Look for structured trip data in the response
        let tripDataPattern = #"TRIP_DATA_START\s*(\{[\s\S]*?\})\s*TRIP_DATA_END"#
        
        guard let regex = try? NSRegularExpression(pattern: tripDataPattern),
              let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
              let range = Range(match.range(at: 1), in: content) else {
            return nil
        }
        
        let jsonString = String(content[range])
        
        do {
            let data = jsonString.data(using: .utf8)!
            let parsedData = try JSONDecoder().decode(ParsedTripData.self, from: data)
            
            return createTripFromParsedData(parsedData)
        } catch {
            print("Failed to parse trip data: \(error)")
            return nil
        }
    }
    
    private func createTripFromParsedData(_ data: ParsedTripData) -> Trip? {
        guard let destination = data.destination else { return nil }
        
        // Parse dates
        let startDate: Date
        let endDate: Date
        
        if let startDateString = data.startDate,
           let parsedStartDate = ISO8601DateFormatter().date(from: startDateString) {
            startDate = parsedStartDate
        } else {
            startDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        }
        
        if let endDateString = data.endDate,
           let parsedEndDate = ISO8601DateFormatter().date(from: endDateString) {
            endDate = parsedEndDate
        } else if let duration = data.duration {
            endDate = Calendar.current.date(byAdding: .day, value: duration, to: startDate) ?? startDate
        } else {
            endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        }
        
        // Create interests
        let interests = (data.interests ?? []).map { interestName in
            Interest(name: interestName, icon: getIconForInterest(interestName))
        }
        
        // Create hotels
        let hotels = (data.hotels ?? []).map { hotelName in
            Hotel(
                name: hotelName,
                address: "Address TBD",
                pricePerNight: Double.random(in: 80...300),
                rating: Double.random(in: 3.5...5.0),
                amenities: ["WiFi", "Breakfast", "Pool"]
            )
        }
        
        // Create itinerary
        let itinerary = createItineraryFromData(data, startDate: startDate)
        
        // Extract country from destination
        let country = extractCountryFromDestination(destination)
        
        return Trip(
            destination: destination,
            country: country,
            startDate: startDate,
            endDate: endDate,
            budget: data.budget ?? 2000.0,
            interests: interests,
            hotels: hotels,
            itinerary: itinerary
        )
    }
    
    private func createItineraryFromData(_ data: ParsedTripData, startDate: Date) -> [ItineraryItem] {
        var itinerary: [ItineraryItem] = []
        let calendar = Calendar.current
        
        // Add activities
        if let activities = data.activities {
            for (index, activity) in activities.enumerated() {
                let date = calendar.date(byAdding: .day, value: index, to: startDate) ?? startDate
                let item = ItineraryItem(
                    title: activity,
                    description: "Enjoy this amazing activity",
                    date: date,
                    time: "10:00 AM",
                    location: data.destination ?? "Location TBD",
                    cost: Double.random(in: 20...150),
                    costDetails: "Estimate includes admission and any required gear.",
                    category: .entertainment
                )
                itinerary.append(item)
            }
        }
        
        // Add attractions
        if let attractions = data.attractions {
            for (index, attraction) in attractions.enumerated() {
                let date = calendar.date(byAdding: .day, value: index, to: startDate) ?? startDate
                let item = ItineraryItem(
                    title: attraction,
                    description: "Must-see attraction",
                    date: date,
                    time: "2:00 PM",
                    location: data.destination ?? "Location TBD",
                    cost: Double.random(in: 10...50),
                    costDetails: "Estimate covers entry fees and basic transportation.",
                    category: .sightseeing
                )
                itinerary.append(item)
            }
        }
        
        return itinerary
    }
    
    private func extractCountryFromDestination(_ destination: String) -> String? {
        // Try to extract country from destination string
        // Common formats: "City, Country", "City, State, Country", etc.
        let parts = destination.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // If there's a comma, take the last part as country
        if parts.count > 1, let country = parts.last, !country.isEmpty {
            return country
        }
        
        // If no comma, try to match against common country names
        // This is a fallback for destinations like "Iceland" or "New Zealand"
        let commonCountries = ["France", "Japan", "Spain", "Italy", "Germany", "United Kingdom", "United States", "Canada", "Australia", "New Zealand", "Iceland", "Norway", "Sweden", "Denmark", "Netherlands", "Belgium", "Switzerland", "Austria", "Portugal", "Greece", "Turkey", "Thailand", "India", "China", "South Korea", "Brazil", "Mexico", "Argentina", "Chile", "Peru", "Egypt", "Morocco", "South Africa"]
        
        let destinationLower = destination.lowercased()
        for country in commonCountries {
            if destinationLower.contains(country.lowercased()) {
                return country
            }
        }
        
        return nil
    }
    
    private func getIconForInterest(_ interest: String) -> String {
        let lowercased = interest.lowercased()
        
        if lowercased.contains("culture") || lowercased.contains("history") {
            return "building.columns"
        } else if lowercased.contains("food") || lowercased.contains("dining") {
            return "fork.knife"
        } else if lowercased.contains("beach") || lowercased.contains("relaxation") {
            return "beach.umbrella"
        } else if lowercased.contains("adventure") || lowercased.contains("outdoor") {
            return "figure.hiking"
        } else if lowercased.contains("art") || lowercased.contains("museum") {
            return "paintbrush"
        } else if lowercased.contains("shopping") {
            return "bag"
        } else if lowercased.contains("nightlife") {
            return "moon.stars"
        } else {
            return "star"
        }
    }
    
    private func generateQuickReplies(for content: String, hasTripSuggestion: Bool) -> [QuickReply]? {
        if hasTripSuggestion {
            return [
                QuickReply(title: "Show detailed itinerary", action: "show itinerary"),
                QuickReply(title: "Adjust budget", action: "adjust budget"),
                QuickReply(title: "Add more activities", action: "add activities")
            ]
        }
        
        // Generate contextual quick replies based on content
        let lowercasedContent = content.lowercased()
        
        if lowercasedContent.contains("budget") {
            return [
                QuickReply(title: "Under $100/day", action: "budget budget-friendly"),
                QuickReply(title: "$100-300/day", action: "budget mid-range"),
                QuickReply(title: "$300+/day", action: "budget luxury")
            ]
        } else if lowercasedContent.contains("destination") || lowercasedContent.contains("where") {
            return [
                QuickReply(title: "I want to go to Paris", action: "destination Paris France"),
                QuickReply(title: "I'm interested in beaches", action: "interests beach tropical"),
                QuickReply(title: "I need help with budget", action: "budget planning")
            ]
        } else if lowercasedContent.contains("activity") || lowercasedContent.contains("interest") {
            return [
                QuickReply(title: "Beach & relaxation", action: "interests beach relaxation"),
                QuickReply(title: "History & culture", action: "interests history culture"),
                QuickReply(title: "Outdoor adventures", action: "interests outdoor hiking")
            ]
        }
        
        return nil
    }
}

// MARK: - Error Types
enum OpenAIError: LocalizedError {
    case invalidAPIKey
    case invalidURL
    case invalidResponse
    case noResponse
    case rateLimitExceeded
    case quotaExceeded
    case serverError(Int)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid OpenAI API key. Please check your configuration."
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "Invalid response from OpenAI API."
        case .noResponse:
            return "No response received from OpenAI API."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .quotaExceeded:
            return "API quota exceeded. Please check your OpenAI account billing and add credits to continue using the service."
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
