import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentInput = ""
    @Published var isTyping = false
    @Published var currentTrip: Trip?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let aiChatService = AIChatService.shared
    
    // User context for personalization
    var userPreferences: UserPreferences?
    var savedTrips: [Trip] = []
    
    init() {
        loadInitialMessages()
    }
    
    func sendMessage() {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(content: currentInput, isFromUser: true)
        messages.append(userMessage)
        
        let inputText = currentInput
        currentInput = ""
        
        // Simulate AI typing
        simulateAITyping()
        
        // Generate AI response using backend API (AIChatService)
        Task {
            await generateAIResponse(for: inputText)
        }
    }
    
    func sendQuickReply(_ reply: String) {
        currentInput = reply
        sendMessage()
    }
    
    private func loadInitialMessages() {
        let welcomeMessage = Message(
            content: "Hi! I'm Luna, how can I help you? 🦉",
            isFromUser: false
        )
        messages.append(welcomeMessage)
    }
    
    private func simulateAITyping() {
        DispatchQueue.main.async {
            self.isTyping = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let lastIndex = self.messages.indices.last,
               self.messages[lastIndex].messageType == .typing {
                self.messages.remove(at: lastIndex)
            }
            self.isTyping = false
        }
    }
    
    private func generateAIResponse(for userInput: String) async {
        do {
            // Limit conversation history to last 20 messages for context
            let recentHistory = Array(messages.suffix(20))
            
            let response = try await aiChatService.sendMessage(
                userInput,
                conversationHistory: recentHistory,
                userPreferences: userPreferences,
                savedTrips: savedTrips
            )
            
            DispatchQueue.main.async {
                // Remove typing indicator if it exists
                if let lastIndex = self.messages.indices.last,
                   self.messages[lastIndex].messageType == .typing {
                    self.messages.remove(at: lastIndex)
                }
                
                // Create AI message with response
                let aiMessage = Message(
                    content: response.text,
                    isFromUser: false,
                    tripSuggestion: response.tripSuggestion,
                    quickReplies: response.quickReplies
                )
                
                self.messages.append(aiMessage)
                
                // Update current trip if there's a suggestion
                if let tripSuggestion = response.tripSuggestion {
                    self.currentTrip = tripSuggestion
                }
                
                self.isTyping = false
                self.errorMessage = nil
            }
            
        } catch {
            DispatchQueue.main.async {
                // Remove typing indicator
                if let lastIndex = self.messages.indices.last,
                   self.messages[lastIndex].messageType == .typing {
                    self.messages.remove(at: lastIndex)
                }
                
                // Show specific error message based on error type
                let errorContent: String
                if let apiError = error as? APIError {
                    switch apiError {
                    case .unauthorized:
                        errorContent = "🔑 Authentication failed. Please sign in again."
                    case .rateLimitExceeded:
                        errorContent = "⏰ I'm getting too many requests right now. Please wait a moment and try again!"
                    case .networkError:
                        errorContent = "🌐 I'm having trouble connecting to the internet. Please check your connection and try again."
                    case .serverError:
                        errorContent = "🦉 The server is having issues right now. Please try again in a moment!"
                    default:
                        errorContent = "🤔 Something went wrong on my end. Please try again in a moment!"
                    }
                } else {
                    errorContent = "Sorry, I'm having trouble connecting right now. Please check your internet connection and try again."
                }
                
                let errorMessage = Message(
                    content: errorContent,
                    isFromUser: false
                )
                self.messages.append(errorMessage)
                
                self.isTyping = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func clearChat() {
        messages.removeAll()
        currentTrip = nil
        errorMessage = nil
        loadInitialMessages()
    }
    
    func retryLastMessage() {
        guard let lastUserMessage = messages.last(where: { $0.isFromUser }) else { return }
        
        // Remove any error messages that might have been added
        messages.removeAll { $0.content.contains("trouble connecting") }
        
        // Retry the last user message
        Task {
            await generateAIResponse(for: lastUserMessage.content)
        }
    }
}
