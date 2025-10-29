//
//  SavedTripsView.swift
//  vacaition
//
//  Created by Sean Meek on 10/29/25.
//

import SwiftUI

struct SavedTripsView: View {
    @EnvironmentObject var userManager: UserManager
    
    let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16)  {
                    ForEach(userManager.currentUser?.savedTrips ?? []) { trip in
                        NavigationLink(destination: TripDetailsView(trip: trip)) {
                            CompactTripCard(trip: trip)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(
                LinearGradient(
                    colors: [
                        AppTheme.Colors.background,
                        AppTheme.Colors.background.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Saved Trips")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SavedTripsView()
}
