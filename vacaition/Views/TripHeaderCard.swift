import SwiftUI

struct TripHeaderCard: View {
	let trip: Trip
	let isTripSaved: Bool
	@EnvironmentObject var themeManager: ThemeManager
    
	var body: some View {
		VStack(spacing: AppTheme.Spacing.md) {
			// Destination
            HStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(trip.destination)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                            .multilineTextAlignment(.leading)

                        Text(formatDateRange(trip.startDate, trip.endDate))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    HStack {
                        // Status Badge
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Circle()
                                .fill(trip.isCompleted ? AppTheme.Colors.success : AppTheme.Colors.primary)
                                .frame(width: 8, height: 8)

                            Text(trip.isCompleted ? "Completed" : "Planned")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.Colors.cardBackground)
                        .cornerRadius(AppTheme.CornerRadius.sm)
                        .accessibilityLabel("Trip status: \(trip.isCompleted ? "Completed" : "Planned")")

                        // Saved Badge
                        if isTripSaved {
                            HStack(spacing: AppTheme.Spacing.xs) {
                                Image(systemName: "bookmark.fill")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.Colors.success)

                                Text("Saved")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.Colors.success)
                            }
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(AppTheme.Colors.success.opacity(0.1))
                            .cornerRadius(AppTheme.CornerRadius.sm)
                            .accessibilityLabel("Trip is saved")
                        }
                    }
                }
                
                Spacer()
            }

			// Budget
			HStack {
				Image(systemName: "dollarsign.circle.fill")
					.foregroundColor(AppTheme.Colors.primary)
					.font(.title2)

				VStack(alignment: .leading, spacing: 2) {
					Text("Total Budget")
						.font(.caption)
						.foregroundColor(.secondary)

					Text("$\(Int(trip.budget))")
						.font(.title2)
						.fontWeight(.bold)
						.foregroundColor(.primary)
				}

				Spacer()

				VStack(alignment: .trailing, spacing: 2) {
					Text("Per Day")
						.font(.caption)
						.foregroundColor(.secondary)

					Text("$\(Int(trip.budget / Double(tripDuration)))")
						.font(.title3)
						.fontWeight(.semibold)
						.foregroundColor(.primary)
				}
			}
		}
		.padding(AppTheme.Spacing.lg)
		.liquidGlassCard(cornerRadius: AppTheme.CornerRadius.lg, borderTint: AppTheme.Colors.primary)
		.accessibilityElement(children: .combine)
	}
    
	private var tripDuration: Int {
		Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 1
	}

	private func formatDateRange(_ start: Date, _ end: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
	}
}

#Preview {
	TripHeaderCard(trip: SampleData.sampleTrips.first!, isTripSaved: true)
		.environmentObject(ThemeManager())
}


