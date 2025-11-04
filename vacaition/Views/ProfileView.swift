import SwiftUI
import StoreKit
import UIKit

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
        let countries: [String] = trips.compactMap { trip in
            // Use country field if available, otherwise fall back to heuristic parsing
            if let country = trip.country, !country.isEmpty {
                return country
            }
            // Fallback: if destination contains a comma, take the last token as country
            let parts = trip.destination.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if let last = parts.last, parts.count > 1 {
                return String(last)
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
                Text("Your Trips")
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
                        ForEach(trips.sorted(by: { $0.createdAt > $1.createdAt }).prefix(3)) { trip in
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
    @State private var showingLogoutConfirmation = false
    @State private var showingRateAppAlert = false
    @State private var showingFeatureRequest = false
    
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
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done with settings")
                }
            }
            .alert("Unable to Rate App", isPresented: $showingRateAppAlert) {
                Button("Open App Store") {
                    openAppStore()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("The rating prompt is not available at this time. You can rate the app directly in the App Store.")
            }
            .sheet(isPresented: $showingFeatureRequest) {
                FeatureRequestView()
            }
        }
    }
    
    private func requestAppReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        } else {
            // If we can't get the window scene, show an alert
            showingRateAppAlert = true
        }
    }
    
    private func openAppStore() {
        // Try to get the app name for a better search
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String 
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String 
            ?? "Vacaition"
        
        // URL encode the app name for the search
        let encodedName = appName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? appName
        
        // Open App Store search for the app
        // Note: In production, replace this with your actual App Store ID URL:
        // https://apps.apple.com/app/id[YOUR_APP_STORE_ID]
        let appStoreURL = "https://apps.apple.com/search?term=\(encodedName)"
        
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "https://apps.apple.com") {
            UIApplication.shared.open(url)
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
                
                Button(action: {
                    requestAppReview()
                }) {
                    SettingsRow(
                        icon: "star.fill",
                        title: "Rate App",
                        subtitle: "Share your feedback"
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Rate this app")
                .accessibilityHint("Tap to rate and review the app")
                
                Divider()
                    .padding(.leading, 56)
                
                Button(action: {
                    showingFeatureRequest = true
                }) {
                    SettingsRow(
                        icon: "lightbulb.fill",
                        title: "Request Feature",
                        subtitle: "Suggest new features"
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Request feature")
                .accessibilityHint("Tap to suggest a new feature")
                
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
                showingLogoutConfirmation = true
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
            .confirmationDialog("Are you sure you want to log out?", isPresented: $showingLogoutConfirmation, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    userManager.signOut()
                }
                Button("Cancel", role: .cancel) {
                    // Cancel action - dialog will dismiss automatically
                }
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @State private var name = ""
    @State private var email = ""
    @State private var isSaving = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var hasChanges = false
    
    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        isSaving ||
        !hasChanges
    }
    
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
                            .onChange(of: name) { _, _ in
                                checkForChanges()
                            }
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        TextField("Enter your email", text: $email)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .accessibilityLabel("Email field")
                            .onChange(of: email) { _, _ in
                                checkForChanges()
                            }
                    }
                } header: {
                    Text("Profile Information")
                } footer: {
                    if isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding(.top, 8)
                            Spacer()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                    .accessibilityLabel("Cancel editing profile")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaveDisabled)
                    .accessibilityLabel("Save profile changes")
                }
            }
            .onAppear {
                name = userManager.currentUser?.name ?? ""
                email = userManager.currentUser?.email ?? ""
                checkForChanges()
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func checkForChanges() {
        let originalName = userManager.currentUser?.name ?? ""
        let originalEmail = userManager.currentUser?.email ?? ""
        hasChanges = name != originalName || email != originalEmail
    }
    
    private func saveProfile() {
        guard var currentUser = userManager.currentUser else {
            errorMessage = "Unable to save. Please try again."
            showingErrorAlert = true
            return
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate inputs
        guard !trimmedName.isEmpty else {
            errorMessage = "Name cannot be empty."
            showingErrorAlert = true
            return
        }
        
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Email cannot be empty."
            showingErrorAlert = true
            return
        }
        
        // Basic email validation
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else {
            errorMessage = "Please enter a valid email address."
            showingErrorAlert = true
            return
        }
        
        isSaving = true
        
        // Update user object
        currentUser.name = trimmedName
        currentUser.email = trimmedEmail
        
        // Save to Firestore
        userManager.updateUser(currentUser)
        
        isSaving = false
        
        // Check if there was an error
        if let error = userManager.errorMessage {
            errorMessage = error
            showingErrorAlert = true
        } else {
            // Success - dismiss the view
            // The UI will update automatically through the published currentUser property
            dismiss()
        }
    }
}

struct FeatureRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @State private var featureRequestText = ""
    @State private var isSubmitting = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("Share your ideas")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("We'd love to hear your suggestions for new features. Your feedback helps us make the app better!")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Feature Request")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $featureRequestText)
                            .frame(minHeight: 150)
                            .padding(AppTheme.Spacing.sm)
                            .background(Color(.systemBackground))
                            .cornerRadius(AppTheme.CornerRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .accessibilityLabel("Feature request text editor")
                            .accessibilityHint("Enter your feature request here")
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    
                    Button(action: {
                        submitFeatureRequest()
                    }) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Submit Request")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(featureRequestText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting ? Color.gray : AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.md)
                    }
                    .disabled(featureRequestText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .accessibilityLabel("Submit feature request")
                    .accessibilityHint("Submits your feature request")
                    
                    Spacer(minLength: AppTheme.Spacing.xl)
                }
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Request Feature")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel feature request")
                }
            }
            .alert("Request Submitted", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for your feedback! We'll review your feature request.")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitFeatureRequest() {
        let trimmedText = featureRequestText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        isSubmitting = true
        
        Task {
            do {
                try await userManager.authService.submitFeatureRequest(trimmedText)
                await MainActor.run {
                    isSubmitting = false
                    showingSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "Unable to submit your request. Please check your connection and try again."
                    showingErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ThemeManager())
        .environmentObject(UserManager())
}
