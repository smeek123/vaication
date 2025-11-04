import Foundation

struct SampleData {
    static let sampleInterests: [Interest] = [
        Interest(name: "Beach & Relaxation", icon: "beach.umbrella"),
        Interest(name: "History & Culture", icon: "building.columns"),
        Interest(name: "Food & Dining", icon: "fork.knife"),
        Interest(name: "Outdoor Adventures", icon: "tree.fill"),
        Interest(name: "Art & Museums", icon: "paintbrush"),
        Interest(name: "Shopping", icon: "bag.fill"),
        Interest(name: "Nightlife", icon: "moon.stars"),
        Interest(name: "Photography", icon: "camera.fill")
    ]
    
    static let sampleHotels: [Hotel] = [
        Hotel(
            name: "Hotel Plaza Paris",
            address: "123 Champs-Élysées, 75008 Paris, France",
            pricePerNight: 280,
            rating: 4.5,
            amenities: ["WiFi", "Spa", "Restaurant", "Room Service", "Concierge"],
            imageURL: "hotel_plaza_paris"
        ),
        Hotel(
            name: "The Ritz Tokyo",
            address: "9-7-1 Akasaka, Minato-ku, Tokyo, Japan",
            pricePerNight: 450,
            rating: 4.8,
            amenities: ["WiFi", "Spa", "Pool", "Restaurant", "Business Center", "Concierge"],
            imageURL: "ritz_tokyo"
        ),
        Hotel(
            name: "Hotel Arts Barcelona",
            address: "Carrer de la Marina, 19-21, 08005 Barcelona, Spain",
            pricePerNight: 320,
            rating: 4.6,
            amenities: ["WiFi", "Pool", "Spa", "Beach Access", "Restaurant", "Fitness Center"],
            imageURL: "hotel_arts_barcelona"
        ),
        Hotel(
            name: "Boutique Hotel Montmartre",
            address: "15 Rue des Abbesses, 75018 Paris, France",
            pricePerNight: 180,
            rating: 4.3,
            amenities: ["WiFi", "Breakfast", "Concierge"],
            imageURL: "boutique_montmartre"
        ),
        Hotel(
            name: "Shibuya Sky Hotel",
            address: "2-1-1 Shibuya, Shibuya-ku, Tokyo, Japan",
            pricePerNight: 220,
            rating: 4.4,
            amenities: ["WiFi", "City View", "Restaurant", "Concierge"],
            imageURL: "shibuya_sky_hotel"
        ),
        Hotel(
            name: "Casa Batlló Hotel",
            address: "Passeig de Gràcia, 43, 08007 Barcelona, Spain",
            pricePerNight: 195,
            rating: 4.2,
            amenities: ["WiFi", "Historic Building", "Breakfast", "Concierge"],
            imageURL: "casa_batllo_hotel"
        )
    ]
    
    static let sampleItinerary: [ItineraryItem] = [
        ItineraryItem(
            title: "Arrival & City Orientation",
            description: "Check into hotel, get oriented with the city, and enjoy a welcome dinner at a local restaurant.",
            date: Date(),
            time: "2:00 PM - 8:00 PM",
            location: "City Center",
            cost: 120,
            category: .transportation
        ),
        ItineraryItem(
            title: "Historic District Walking Tour",
            description: "Explore the historic heart of the city with a guided walking tour covering major landmarks and hidden gems.",
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            time: "10:00 AM - 2:00 PM",
            location: "Historic District",
            cost: 45,
            category: .sightseeing
        ),
        ItineraryItem(
            title: "Local Market & Food Tour",
            description: "Experience local cuisine through a guided food tour of traditional markets and street food vendors.",
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            time: "3:00 PM - 7:00 PM",
            location: "Central Market",
            cost: 85,
            category: .dining
        ),
        ItineraryItem(
            title: "Museum & Cultural Sites",
            description: "Visit world-renowned museums and cultural sites with skip-the-line access and audio guide.",
            date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            time: "9:00 AM - 4:00 PM",
            location: "Museum District",
            cost: 65,
            category: .sightseeing
        ),
        ItineraryItem(
            title: "Outdoor Adventure Activity",
            description: "Enjoy a half-day outdoor activity such as hiking, biking, or water sports depending on location.",
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            time: "8:00 AM - 1:00 PM",
            location: "Natural Reserve",
            cost: 95,
            category: .outdoor
        ),
        ItineraryItem(
            title: "Traditional Cooking Class",
            description: "Learn to cook authentic local dishes with a professional chef in a hands-on cooking experience.",
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            time: "4:00 PM - 8:00 PM",
            location: "Cooking School",
            cost: 110,
            category: .dining
        ),
        ItineraryItem(
            title: "Free Day & Shopping",
            description: "Explore the city at your own pace, visit local shops, and pick up souvenirs for family and friends.",
            date: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
            time: "10:00 AM - 6:00 PM",
            location: "Shopping Districts",
            cost: nil,
            category: .shopping
        ),
        ItineraryItem(
            title: "Sunset Cruise & Farewell Dinner",
            description: "End your trip with a scenic sunset cruise followed by a special farewell dinner at a fine restaurant.",
            date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            time: "5:00 PM - 10:00 PM",
            location: "Waterfront",
            cost: 150,
            category: .entertainment
        )
    ]
    
    static let sampleTrips: [Trip] = [
        Trip(
            destination: "Paris, France",
            country: "France",
            startDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 37, to: Date()) ?? Date(),
            budget: 2500,
            interests: Array(sampleInterests.prefix(3)),
            hotels: Array(sampleHotels.prefix(2)),
            itinerary: Array(sampleItinerary.prefix(4))
        ),
        Trip(
            destination: "Tokyo, Japan",
            country: "Japan",
            startDate: Calendar.current.date(byAdding: .day, value: 45, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 52, to: Date()) ?? Date(),
            budget: 3200,
            interests: Array(sampleInterests.suffix(3)),
            hotels: Array(sampleHotels.suffix(2)),
            itinerary: Array(sampleItinerary.suffix(4))
        ),
        Trip(
            destination: "Barcelona, Spain",
            country: "Spain",
            startDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 67, to: Date()) ?? Date(),
            budget: 1800,
            interests: [sampleInterests[0], sampleInterests[1], sampleInterests[5]],
            hotels: [sampleHotels[2], sampleHotels[5]],
            itinerary: sampleItinerary
        )
    ]
    
    static let sampleQuickReplies: [QuickReply] = [
        QuickReply(title: "I want to go to Paris", action: "destination Paris France"),
        QuickReply(title: "I'm interested in beaches", action: "interests beach tropical"),
        QuickReply(title: "I need help with budget", action: "budget planning"),
        QuickReply(title: "Show me some options", action: "show options"),
        QuickReply(title: "I want luxury travel", action: "budget luxury"),
        QuickReply(title: "I prefer cultural experiences", action: "interests culture history")
    ]
}
