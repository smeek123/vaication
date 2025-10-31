import SwiftUI

struct TripDetailsContainerView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingChatView = false
    
    var body: some View {
        Group {
            if let currentTrip = userManager.currentUser?.savedTrips.last {
                TripDetailsView(trip: currentTrip)
            } else {
                EmptyTripStateView(showingChatView: $showingChatView)
            }
        }
        .sheet(isPresented: $showingChatView) {
            ChatView()
        }
    }
}

struct EmptyTripStateView: View {
    @Binding var showingChatView: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()
                
                // Empty State Illustration
                VStack(spacing: AppTheme.Spacing.lg) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primary.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    VStack(spacing: AppTheme.Spacing.md) {
                        Text("No Trip Planned Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Start planning your next adventure with Luna! She'll help you create the perfect itinerary tailored to your interests and budget.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                }
                
                // CTA Button
                Button(action: {
                    showingChatView = true
                }) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                        
                        Text("Start Planning with Luna")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(AppTheme.CornerRadius.lg)
                }
                .accessibilityLabel("Start planning trip with Luna")
                .accessibilityHint("Opens chat to plan your trip")
                
                // Quick Tips
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("Quick Tips")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: AppTheme.Spacing.sm) {
                        TipRow(icon: "location.fill", text: "Tell Luna where you want to go")
                        TipRow(icon: "calendar", text: "Share your travel dates")
                        TipRow(icon: "dollarsign.circle", text: "Set your budget range")
                        TipRow(icon: "heart.fill", text: "Describe your interests")
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg, borderTint: AppTheme.Colors.primary)
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Trip Planning")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tip: \(text)")
    }
}

#Preview {
    EmptyTripStateView(showingChatView: .constant(false))
        .environmentObject(ThemeManager())
}
