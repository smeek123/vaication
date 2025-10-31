import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @State private var showingSettings = false
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Profile Header
                    profileHeaderSection
                    
                    // Stats Section
                    statsSection
                    
                    // Saved Trips Section
                    savedTripsSection
                    
                    Spacer(minLength: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .accessibilityLabel("Settings")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
    
    private var profileHeaderSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Profile Picture
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.primary,
                                AppTheme.Colors.secondary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Text(userManager.currentUser?.name.prefix(1).uppercased() ?? "T")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            .accessibilityLabel("Profile picture for \(userManager.currentUser?.name ?? "User")")
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(userManager.currentUser?.name ?? "Traveler")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Text(userManager.currentUser?.email ?? "traveler@vacaition.com")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Button("Edit Profile") {
                    showingEditProfile = true
                }
                .font(.body)
                .foregroundColor(AppTheme.Colors.primary)
                .accessibilityLabel("Edit profile information")
            }
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.md, borderTint: AppTheme.Colors.secondary)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Your Travel Stats")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
            
            HStack(spacing: AppTheme.Spacing.md) {
                StatCard(
                    icon: "airplane",
                    title: "Trips",
                    value: "\(totalTrips)",
                    color: AppTheme.Colors.primary
                )
                
                StatCard(
                    icon: "globe",
                    title: "Countries",
                    value: "\(uniqueCountryCount)",
                    color: AppTheme.Colors.secondary
                )
                
                StatCard(
                    icon: "calendar",
                    title: "Days Traveled",
                    value: "\(totalDaysTraveled)",
                    color: AppTheme.Colors.accent
                )
            }
        }
    }

    // MARK: - Stats Computations
    private var totalTrips: Int {
        userManager.currentUser?.savedTrips.count ?? 0
    }

    private var uniqueCountryCount: Int {
        guard let trips = userManager.currentUser?.savedTrips else { return 0 }
        let countries: [String] = trips.map { trip in
            // Heuristic: if destination contains a comma, take the last token as country
            let parts = trip.destination.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if let last = parts.last, parts.count > 1 {
                return last
            } else {
                return trip.destination
            }
        }
        return Set(countries).count
    }

    private var totalDaysTraveled: Int {
        guard let trips = userManager.currentUser?.savedTrips else { return 0 }
        return trips.filter { $0.isCompleted }.reduce(0) { total, trip in
            let days = Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0
            return total + max(days, 0)
        }
    }
    
    private var savedTripsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Saved Trips")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                if !(userManager.currentUser?.savedTrips.isEmpty ?? true) {
                    NavigationLink(destination: SavedTripsView()) {
                        Text("View All")
                            .font(.body)
                            .foregroundColor(AppTheme.Colors
                                .primary)
                            .accessibilityLabel("View all trips")
                    }
                }
            }
            
            if let trips = userManager.currentUser?.savedTrips, !trips.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        ForEach(trips.prefix(3)) { trip in
                            NavigationLink(destination: TripDetailsView(trip: trip)) {
                                CompactTripCard(trip: trip)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                }
            } else {
                EmptyStateView(
                    icon: "airplane",
                    title: "No Trips Yet",
                    description: "Start planning your first trip to see it here!",
                    actionTitle: "Plan a Trip"
                ) {
                    // Navigate to chat
                }
            }
        }
    }
}

struct CompactTripCard: View {
    let trip: Trip
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(trip.destination)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
            
            Text(formatDateRange(trip.startDate, trip.endDate))
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("$\(Int(trip.budget))")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.primary)
                
                Spacer()
                
                Circle()
                    .fill(trip.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.primary)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 160, height: 100)
        .padding(AppTheme.Spacing.md)
        .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.md, borderTint: AppTheme.Colors.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Trip to \(trip.destination) from \(formatDateRange(trip.startDate, trip.endDate)) with budget of $\(Int(trip.budget))")
    }
    
    private func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: Content
    @EnvironmentObject var themeManager: ThemeManager
    
    init(icon: String, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            content
        }
        .padding(AppTheme.Spacing.md)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(AppTheme.CornerRadius.md)
            }
            .accessibilityLabel(actionTitle)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.xl)
        .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg)
    }
}

// MARK: - Sheet Views
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Settings Section
                    settingsSection
                    
                    // App Info Section
                    appInfoSection
                    
                    // Sign Out Section
                    signOutSection
                    
                    Spacer(minLength: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done with settings")
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Appearance")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: themeManager.isDarkMode ? "moon.fill" : "sun.max",
                    title: themeManager.isDarkMode ? "Dark Mode" : "Light Mode",
                    subtitle: "Switch between light and dark themes"
                ) {
                    Toggle("", isOn: Binding(
                        get: { themeManager.isDarkMode },
                        set: { _ in themeManager.toggleDarkMode() }
                    ))
                    .tint(AppTheme.Colors.primary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(themeManager.isDarkMode ? "Dark Mode On" : "Light Mode On")
                .accessibilityHint("Double tap to switch to \(themeManager.isDarkMode ? "Light Mode" : "Dark Mode")")

                
                Divider()
                    .padding(.leading, 56)
            }
            .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg)
        }
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("App Information")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    subtitle: "Current app version"
                ) {
                    Text("1.0.0")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("App version 1.0.0")
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    subtitle: "Get help with the app"
                ) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Help and support")
                .accessibilityHint("Tap to get help with the app")
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "star.fill",
                    title: "Rate App",
                    subtitle: "Share your feedback"
                ) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Rate this app")
                .accessibilityHint("Tap to rate and review the app")
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "doc.text.fill",
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy"
                ) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Privacy policy")
                .accessibilityHint("Tap to read the privacy policy")
            }
            .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg)
        }
    }
    
    private var signOutSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Account")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
            
            Button(action: {
                userManager.signOut()
            }) {
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.error)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sign Out")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.Colors.error)
                        
                        Text("Sign out of your account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(AppTheme.Spacing.md)
                .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg)
            }
            .accessibilityLabel("Sign out of your account")
            .accessibilityHint("Tap to sign out")
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Enter your name", text: $name)
                            .multilineTextAlignment(.trailing)
                            .accessibilityLabel("Name field")
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        TextField("Enter your email", text: $email)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                            .accessibilityLabel("Email field")
                    }
                } header: {
                    Text("Profile Information")
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel editing profile")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save profile changes
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .accessibilityLabel("Save profile changes")
                }
            }
            .onAppear {
                name = userManager.currentUser?.name ?? ""
                email = userManager.currentUser?.email ?? ""
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ThemeManager())
        .environmentObject(UserManager())
}
