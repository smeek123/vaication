import SwiftUI

struct TripDetailsView: View {
    let trip: Trip
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingItineraryDetail = false
    @State private var selectedItineraryItem: ItineraryItem?
    @State private var isTripSaved = false
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var showingDeleteError = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
					// Trip Header Card
					TripHeaderCard(trip: trip, isTripSaved: isTripSaved)
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Interests Section
                    interestsSection
                    
                    // Hotels Section
                    hotelsSection
                    
                    // Activity Ideas
                    itinerarySection
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    Spacer(minLength: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Trip Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if !isTripSaved {
                            Button("Save Trip") {
                                saveTrip()
                            }
                            .accessibilityLabel("Save this trip")
                        }
                        
                        Button("Edit Trip") {
                            showingEditSheet = true
                        }
                        .accessibilityLabel("Edit trip details")
                        
                        Button("Share Trip") {
                            // Share functionality
                        }
                        .accessibilityLabel("Share trip details")
                        
                        Button("Export Itinerary") {
                            // Export functionality
                        }
                        .accessibilityLabel("Export itinerary")
                        
                        if isTripSaved {
                            Divider()
                            
                            Button("Delete Trip", role: .destructive) {
                                showingDeleteConfirmation = true
                            }
                            .accessibilityLabel("Delete this trip")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel("Trip options menu")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTripSheet(trip: trip)
        }
        .sheet(isPresented: $showingItineraryDetail) {
            if let selectedItem = selectedItineraryItem {
                ItineraryDetailSheet(item: selectedItem)
            }
        }
        .onAppear {
            checkIfTripIsSaved()
        }
        .confirmationDialog("Delete Trip", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteTrip()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \"\(trip.destination)\"? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showingDeleteError) {
            Button("OK") {
                userManager.clearError()
                isDeleting = false
            }
        } message: {
            Text(userManager.errorMessage ?? "Unable to delete trip. Please try again.")
        }
    }
    
    private var quickStatsSection: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            StatCard(
                icon: "calendar",
                title: "Duration",
                value: "\(tripDuration) days",
                color: AppTheme.Colors.primary
            )
            
            StatCard(
                icon: "bed.double.fill",
                title: "Hotels",
                value: "\(trip.hotels.count)",
                color: AppTheme.Colors.secondary
            )
            
            StatCard(
                icon: "map.fill",
                title: "Activities",
                value: "\(trip.itinerary.count)",
                color: AppTheme.Colors.accent
            )
        }
    }
    
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(title: "Interests", icon: "heart.fill")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.sm) {
                ForEach(trip.interests) { interest in
                    InterestChip(interest: interest)
                }
            }
        }
    }
    
    private var hotelsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(title: "Recommended Hotels", icon: "bed.double.fill")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(trip.hotels) { hotel in
                        HotelCard(hotel: hotel)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
    }
    
    private var itinerarySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                SectionHeader(title: "Suggested Activities", icon: "sparkles")
                
                Spacer()
            }
            
            VStack(spacing: AppTheme.Spacing.sm) {
                ForEach(trip.itinerary.prefix(3)) { item in
                    ItineraryItemRow(item: item) {
                        selectedItineraryItem = item
                        showingItineraryDetail = true
                    }
                }
                
                if trip.itinerary.count > 3 {
                    Button(action: {
                        // Show more items
                    }) {
                        HStack {
                            Text("See \(trip.itinerary.count - 3) more ideas")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(AppTheme.CornerRadius.md)
                    }
                    .accessibilityLabel("See \(trip.itinerary.count - 3) more activity ideas")
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button(action: {
                // Start trip
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start My Trip")
                        .fontWeight(.semibold)
                }
                .font(.headline)
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
            .accessibilityLabel("Start my trip")
            .accessibilityHint("Begin your planned trip")
            
            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.md)
                }
                .accessibilityLabel("Edit trip")
                
                Button(action: {
                    // Regenerate trip
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Regenerate")
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppTheme.Colors.secondary.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.md)
                }
                .accessibilityLabel("Regenerate trip plan")
            }
        }
    }
    
    private var tripDuration: Int {
        Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 1
    }
    
    private func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    private func checkIfTripIsSaved() {
        guard let user = userManager.currentUser else { return }
        isTripSaved = user.savedTrips.contains { $0.id == trip.id }
    }
    
    private func saveTrip() {
        userManager.addTrip(trip)
        isTripSaved = true
    }
    
    private func deleteTrip() {
        guard isTripSaved else { return }
        
        isDeleting = true
        userManager.deleteTrip(trip)
        
        // Monitor for deletion completion
        Task {
            // Wait a moment for the deletion to complete
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            await MainActor.run {
                isDeleting = false
                
                // Check if there was an error
                if userManager.errorMessage != nil {
                    showingDeleteError = true
                } else {
                    // Verify trip was actually removed
                    let stillSaved = userManager.currentUser?.savedTrips.contains { $0.id == trip.id } ?? false
                    if !stillSaved {
                        // Success - dismiss the view
                        dismiss()
                    } else {
                        // Trip still exists, might be an error
                        showingDeleteError = true
                    }
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.primary)
                .font(.title3)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.md, borderTint: color)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct InterestChip: View {
    let interest: Interest
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: interest.icon)
                .font(.caption)
                .foregroundColor(AppTheme.Colors.primary)
            
            Text(interest.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.sm, borderTint: AppTheme.Colors.primary)
        .accessibilityLabel("Interest: \(interest.name)")
    }
}

struct HotelCard: View {
    let hotel: Hotel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Hotel Image Placeholder
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                .fill(AppTheme.Colors.primary.opacity(0.1))
                .frame(height: 120)
                .overlay(
                    Image(systemName: "bed.double.fill")
                        .font(.title)
                        .foregroundColor(AppTheme.Colors.primary)
                )
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(hotel.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack {
                    ForEach(0..<Int(hotel.rating), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Text(String(format: "%.1f", hotel.rating))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("$\(Int(hotel.pricePerNight))/night")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
        }
        .frame(width: 200)
        .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.md, borderTint: AppTheme.Colors.primary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hotel \(hotel.name), \(String(format: "%.1f", hotel.rating)) stars, $\(Int(hotel.pricePerNight)) per night")
    }
}

struct ItineraryItemRow: View {
    let item: ItineraryItem
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(Color(item.category.color).opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.category.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(item.category.color))
                }
                .accessibilityHidden(true)
                
                // Content
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(item.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    
                    if !item.location.isEmpty {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.primary)
                            Text(item.location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    if let cost = item.cost {
                        Text("Approx. $\(Int(cost)) per person")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.Colors.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let costDetails = item.costDetails, !costDetails.isEmpty {
                        Text(costDetails)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.md, borderTint: Color(item.category.color))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title). \(item.description)")
        .accessibilityHint("Tap to view activity details")
    }
}

// MARK: - Sheet Views
struct EditTripSheet: View {
    let trip: Trip
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            Text("Edit Trip - Coming Soon")
                .font(.title2)
                .foregroundColor(.primary)
                .navigationTitle("Edit Trip")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .accessibilityLabel("Done editing")
                    }
                }
        }
    }
}

struct ItineraryDetailSheet: View {
    let item: ItineraryItem
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text(item.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(item.category.rawValue)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let cost = item.cost {
                                    HStack(spacing: AppTheme.Spacing.xs) {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .foregroundColor(AppTheme.Colors.primary)
                                        
                                        Text("$\(Int(cost))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(AppTheme.Colors.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        
                        if let costDetails = item.costDetails, !costDetails.isEmpty {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text("What the cost covers")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(costDetails)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg, borderTint: AppTheme.Colors.primary)
                    
                    // Details
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        if !item.location.isEmpty {
                            DetailRow(icon: "mappin.and.ellipse", title: "Suggested Area", value: item.location)
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg, borderTint: AppTheme.Colors.primary)
                    
                    // Description
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("Description")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(item.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(AppTheme.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg, borderTint: AppTheme.Colors.primary)
                }
                .padding(AppTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationTitle("Activity Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done viewing details")
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    TripDetailsView(trip: SampleData.sampleTrips.first!)
        .environmentObject(ThemeManager())
        .environmentObject(UserManager())
}
