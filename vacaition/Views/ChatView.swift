import SwiftUI

struct ChatView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @FocusState private var isTextFieldFocused: Bool
    @State private var isTripSaved = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat Messages Area
                chatMessagesArea
                
                // Quick Replies Section
                if shouldShowQuickReplies {
                    quickRepliesSection
                }
                
                // Input Area
                inputArea
            }
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Trip Planning")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkIfTripIsSaved()
            }
            .onChange(of: chatViewModel.currentTrip) {
                checkIfTripIsSaved()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if let _ = chatViewModel.currentTrip, !isTripSaved {
                            Button("Save Trip") {
                                saveTrip()
                            }
                            .accessibilityLabel("Save current trip")
                        }
                        
                        if let trip = chatViewModel.currentTrip {
                            NavigationLink(destination: TripDetailsView(trip: trip)) {
                                Button("View Trip Details") {
                                    // Navigate to trip details
                                }
                                .accessibilityLabel("View current trip details")
                            }
                            
                            Button("Clear Chat", role: .destructive) {
                                chatViewModel.clearChat()
                            }
                            .accessibilityLabel("Clear chat history")
                        }
                        
                        if chatViewModel.errorMessage != nil {
                            Button("Retry Last Message") {
                                chatViewModel.retryLastMessage()
                            }
                            .accessibilityLabel("Retry the last message")
                        }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "ellipsis.circle")
                            
                            if isTripSaved {
                                Image(systemName: "bookmark.fill")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.Colors.success)
                            }
                        }
                        .accessibilityLabel("Chat options menu")
                    }
                }
            }
        }
    }
    
    private var chatMessagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.md) {
                    ForEach(chatViewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }
                    
                    if chatViewModel.isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .onChange(of: chatViewModel.messages.count) {
                withAnimation(.easeOut(duration: 0.3)) {
                    if let lastMessage = chatViewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: chatViewModel.isTyping) { _, isTyping in
                if isTyping {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var shouldShowQuickReplies: Bool {
        guard let lastMessage = chatViewModel.messages.last,
              !lastMessage.isFromUser else { return false }
        
        // Show quick replies if the message has them and no trip suggestion
        return lastMessage.quickReplies != nil && chatViewModel.currentTrip == nil
    }
    
    private var quickRepliesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Quick Replies")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, AppTheme.Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    if let quickReplies = chatViewModel.messages.last?.quickReplies {
                        ForEach(quickReplies) { reply in
                            QuickReplyButton(reply: reply) {
                                chatViewModel.sendQuickReply(reply.action)
                            }
                        }
                    } else {
                        ForEach(SampleData.sampleQuickReplies.prefix(4)) { reply in
                            QuickReplyButton(reply: reply) {
                                chatViewModel.sendQuickReply(reply.action)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }
    
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
                .background(.secondary)
            
            HStack(spacing: AppTheme.Spacing.md) {
                TextField("Ask me about your trip...", text: $chatViewModel.currentInput)
                    .textFieldStyle(ChatTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        sendMessage()
                    }
                    .submitLabel(.go)
                    .accessibilityLabel("Message input field")
                    .accessibilityHint("Type your message about trip planning")
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glassProminent)
                .disabled(chatViewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Send message")
                .accessibilityHint("Tap to send your message")
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                .ultraThinMaterial
            )
        }
    }
    
    private func sendMessage() {
        guard !chatViewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        chatViewModel.sendMessage()
        isTextFieldFocused = false
    }
    
    private func checkIfTripIsSaved() {
        guard let trip = chatViewModel.currentTrip,
              let user = userManager.currentUser else { return }
        isTripSaved = user.savedTrips.contains { $0.id == trip.id }
    }
    
    private func saveTrip() {
        guard let trip = chatViewModel.currentTrip else { return }
        userManager.addTrip(trip)
        isTripSaved = true
    }
}

struct ChatBubble: View {
    let message: Message
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .fill(AppTheme.Colors.primary)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.primary.opacity(0.25),
                                        AppTheme.Colors.primary.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 1
                            )
                        ))
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("You: \(message.content)")
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                        // AI Avatar
                        Image("Ava")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 32, height: 32)
                            .accessibilityHidden(true)
                        
                        Text(message.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .background(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.Colors.secondary.opacity(0.22),
                                            AppTheme.Colors.secondary.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 1
                                )
                            ))
                    }
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 40)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Luna: \(message.content)")
                
                Spacer(minLength: 50)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                    // AI Avatar
                    Image("Ava")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 32, height: 32)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(.secondary)
                                .frame(width: 8, height: 8)
                                .scaleEffect(animating ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: animating
                                )
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: AppTheme.CornerRadius.lg,
                        bottomLeading: AppTheme.CornerRadius.lg,
                        bottomTrailing: AppTheme.CornerRadius.sm,
                        topTrailing: AppTheme.CornerRadius.lg
                    ), style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        UnevenRoundedRectangle(cornerRadii: .init(
                            topLeading: AppTheme.CornerRadius.lg,
                            bottomLeading: AppTheme.CornerRadius.lg,
                            bottomTrailing: AppTheme.CornerRadius.sm,
                            topTrailing: AppTheme.CornerRadius.lg
                        ), style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.secondary.opacity(0.22),
                                    AppTheme.Colors.secondary.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1
                        )
                    ))
                }
            }
            
            Spacer(minLength: 50)
        }
        .onAppear {
            animating = true
        }
        .accessibilityLabel("Luna is typing")
    }
}

struct QuickReplyButton: View {
    let reply: QuickReply
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(reply.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.Colors.primary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(AppTheme.Colors.primary.opacity(0.1))
                .cornerRadius(AppTheme.CornerRadius.lg)
        }
        .accessibilityLabel(reply.title)
        .accessibilityHint("Tap to send this quick reply")
    }
}

struct ChatTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .stroke(.secondary, lineWidth: 1)
            )
    }
}

// Extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ChatView()
        .environmentObject(ThemeManager())
        .environmentObject(UserManager())
}
