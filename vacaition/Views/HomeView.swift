import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Header Section
                    headerSection
                    
                    // Welcome Message Section
                    welcomeSection
                    
                    // Quick Actions Section
//                    quickActionsSection
                    
                    // Recent Trips Section
                    if userManager.currentUser?.savedTrips.isEmpty == false {
                        recentTripsSection
                    }
                    
                    // Features Section
                    featuresSection
                    
                    Spacer(minLength: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Vaication")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // App Icon/Logo
            Image("Ava")
                .resizable()
                .clipShape(Circle())
                .scaledToFit()
                .frame(width: 120, height: 120)
                .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                .accessibilityLabel("Luna's avatar")
             
            Text("Hi, I'm Luna!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
            
            Text("Your personal AI travel planner")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Text("Ready to plan your next trip?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text("Where to? Tell me what you’re into, and I’ll handle the rest.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Quick Actions")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.md) {
                QuickActionCard(
                    icon: "airplane",
                    title: "Browse Destinations",
                    subtitle: "Explore popular places",
                    action: {
                        // Navigate to destinations
                    }
                )
                
                QuickActionCard(
                    icon: "calendar",
                    title: "Check Dates",
                    subtitle: "Find best travel times",
                    action: {
                        // Navigate to calendar
                    }
                )
                
                QuickActionCard(
                    icon: "dollarsign.circle",
                    title: "Budget Planner",
                    subtitle: "Plan your expenses",
                    action: {
                        // Navigate to budget
                    }
                )
                
                QuickActionCard(
                    icon: "heart.fill",
                    title: "Saved Trips",
                    subtitle: "View your plans",
                    action: {
                        // Navigate to saved trips
                    }
                )
            }
        }
    }
    
    private var recentTripsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Trips")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                if let savedCount =  userManager.currentUser?.savedTrips.count {
                    if savedCount > 3 {
                        NavigationLink(destination: SavedTripsView()) {
                            Text("View All")
                                .font(.body)
                                .foregroundColor(AppTheme.Colors
                                    .primary)
                                .accessibilityLabel("View all trips")
                        }
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach((userManager.currentUser?.savedTrips.sorted(by: { $0.createdAt > $1.createdAt }) ?? []).prefix(3)) { trip in
                        NavigationLink(destination: TripDetailsView(trip: trip)) {
                            CompactTripCard(trip: trip)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Why Travelers Love Vaication")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
            
            VStack(spacing: AppTheme.Spacing.md) {
                FeatureRow(
                    icon: "brain.head.profile",
                    title: "AI-Powered Planning",
                    description: "Smart recommendations tailored to your preferences"
                )
                
                FeatureRow(
                    icon: "globe",
                    title: "Global Destinations",
                    description: "Explore amazing places around the world"
                )
                
                FeatureRow(
                    icon: "dollarsign.circle",
                    title: "Budget-Friendly",
                    description: "Find the best deals and value for your money"
                )
                
                FeatureRow(
                    icon: "clock",
                    title: "Save Time",
                    description: "Plan your entire trip in minutes, not hours"
                )
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(height: 32)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg)
        }
        .accessibilityLabel("\(title): \(subtitle)")
        .accessibilityHint("Tap to \(subtitle.lowercased())")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 32, height: 32)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.md, borderTint: AppTheme.Colors.secondary)
        .shadow(color: AppTheme.Shadows.light, radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HomeView()
        .environmentObject(UserManager())
}
