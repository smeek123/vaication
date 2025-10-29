import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var messageType: MessageType
    var tripSuggestion: Trip?
    var quickReplies: [QuickReply]?
    
    init(content: String, isFromUser: Bool, messageType: MessageType = .text, tripSuggestion: Trip? = nil, quickReplies: [QuickReply]? = nil) {
        self.id = UUID()
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.messageType = messageType
        self.tripSuggestion = tripSuggestion
        self.quickReplies = quickReplies
    }
}

enum MessageType: String, Codable {
    case text = "text"
    case typing = "typing"
    case tripSuggestion = "trip_suggestion"
    case quickReply = "quick_reply"
}

struct QuickReply: Identifiable, Codable {
    let id: UUID
    var title: String
    var action: String
    
    init(title: String, action: String) {
        self.id = UUID()
        self.title = title
        self.action = action
    }
}
