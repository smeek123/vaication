//
//  SavedTripsView.swift
//  vacaition
//
//  Created by Sean Meek on 10/29/25.
//

import SwiftUI

struct SavedTripsView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            Group {
                if userManager.isLoading {
                    VStack(spacing: AppTheme.Spacing.md) {
                        ProgressView()
                            .tint(AppTheme.Colors.primary)
                        Text("Loading saved trips...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let trips = userManager.currentUser?.savedTrips, !trips.isEmpty {
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.md) {
                            ForEach(trips.sorted { $0.createdAt > $1.createdAt }) { trip in
                                NavigationLink(destination: TripDetailsView(trip: trip)) {
                                    TripHeaderCard(trip: trip, isTripSaved: true)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.top, AppTheme.Spacing.md)
                    }
                    .background(
                        LiquidGlassBackground()
                            .ignoresSafeArea()
                    )
                } else {
                    VStack {
                        EmptyStateView(
                            icon: "bookmark",
                            title: "No Saved Trips",
                            description: "Save trips to view them here.",
                            actionTitle: "Plan a Trip"
                        ) {
                            // Could navigate to chat or trip planner
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                    .background(
                        LiquidGlassBackground()
                            .ignoresSafeArea()
                    )
                }
            }
            .navigationTitle("Saved Trips")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SavedTripsView()
        .environmentObject(ThemeManager())
        .environmentObject(UserManager())
}
