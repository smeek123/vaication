import {Response} from "express";
import {OpenAIService} from "../services/openai";
import {TravelAPIService} from "../services/travelAPI";
import {getUserPreferences, getSavedTrips} from "../services/firestore";
import {getUserId, AuthenticatedRequest} from "../utils/auth";

// Initialize services (singletons)
let openAIService: OpenAIService | null = null;
let travelAPIService: TravelAPIService | null = null;

function getOpenAIService(): OpenAIService {
  if (!openAIService) {
    try {
      openAIService = new OpenAIService();
    } catch (error: any) {
      console.error("Failed to initialize OpenAIService:", error.message);
      throw error;
    }
  }
  return openAIService;
}

function getTravelAPIService(): TravelAPIService {
  if (!travelAPIService) {
    travelAPIService = new TravelAPIService();
  }
  return travelAPIService;
}

export interface ChatRequestBody {
  message: string;
  conversationHistory: Array<{
    role: string;
    content: string;
    timestamp?: string;
  }>;
  userPreferences?: {
    savedTrips?: string[];
    preferences?: { [key: string]: string };
  };
}

export async function chatHandler(
  req: AuthenticatedRequest,
  res: Response
): Promise<void> {
  try {
    const userId = getUserId(req);
    const body: ChatRequestBody = req.body;

    if (!body.message || typeof body.message !== "string") {
      res.status(400).json({error: "Message is required"});
      return;
    }

    // Load user preferences from Firestore
    const userPrefs = await getUserPreferences(userId);
    const savedTrips = await getSavedTrips(userId);

    // Merge request preferences with Firestore preferences
    const mergedPreferences = {
      savedTrips: [
        ...(body.userPreferences?.savedTrips || []),
        ...(savedTrips.map((trip: any) => trip.destination || trip.name || "").filter(Boolean)),
      ],
      preferences: {
        ...(userPrefs?.preferences || {}),
        ...(body.userPreferences?.preferences || {}),
      },
    };

    // Get services
    const openAIService = getOpenAIService();
    const travelAPIService = getTravelAPIService();

    // Detect travel intent
    const intent = travelAPIService.detectTravelIntent(body.message);
    const travelData: any = {};

    // Fetch travel data if needed (in parallel)
    const promises: Promise<any>[] = [];

    if (intent.needsFlights) {
      // Extract flight search params from message (basic extraction)
      const flightParams = extractFlightParams(body.message);
      if (flightParams) {
        promises.push(
          travelAPIService.searchFlights(flightParams).then((flights) => {
            travelData.flights = flights;
          }).catch((err) => {
            console.error("Flight search error:", err);
          })
        );
      }
    }

    if (intent.needsHotels) {
      // Extract hotel search params from message
      const hotelParams = extractHotelParams(body.message);
      if (hotelParams) {
        promises.push(
          travelAPIService.searchHotels(hotelParams).then((hotels) => {
            travelData.hotels = hotels;
          }).catch((err) => {
            console.error("Hotel search error:", err);
          })
        );
      }
    }

    if (intent.needsActivities) {
      // Extract activity search params from message
      const activityParams = extractActivityParams(body.message);
      if (activityParams) {
        promises.push(
          travelAPIService.searchActivities(activityParams).then((activities) => {
            travelData.activities = activities;
          }).catch((err) => {
            console.error("Activity search error:", err);
          })
        );
      }
    }

    // Wait for all travel API calls to complete (with timeout)
    await Promise.allSettled(promises);

    // Generate AI response with context
    const response = await openAIService.generateResponse(
      body.message,
      body.conversationHistory || [],
      mergedPreferences,
      travelData
    );

    // Extract trip suggestion if present
    const tripSuggestion = openAIService.extractTripData(response);

    // Generate quick replies if trip suggestion exists
    const quickReplies = tripSuggestion ? [
      {title: "Show detailed itinerary", action: "show itinerary"},
      {title: "Adjust budget", action: "adjust budget"},
      {title: "Add more activities", action: "add activities"},
    ] : null;

    // Build response
    const responseData: any = {
      response: response,
      tripSuggestion: tripSuggestion ? formatTripSuggestion(tripSuggestion) : null,
      quickReplies: quickReplies,
      travelData: Object.keys(travelData).length > 0 ? travelData : null,
    };

    res.json(responseData);
  } catch (error: any) {
    console.error("Chat handler error:", error);
    res.status(500).json({
      error: "Internal server error",
      message: error.message,
    });
  }
}

/**
 * Extract flight search parameters from user message (basic implementation)
 */
function extractFlightParams(message: string): any | null {
  // This is a simplified extraction - in production, use NLP or structured prompts
  // For now, return null and let the AI handle it
  // In production, implement proper extraction or use AI to extract structured data
  return null;
}

/**
 * Extract hotel search parameters from user message
 */
function extractHotelParams(message: string): any | null {
  // Similar to flight params - simplified for now
  return null;
}

/**
 * Extract activity search parameters from user message
 */
function extractActivityParams(message: string): any {
  // Extract location from message
  const locationMatch = message.match(/\b(in|at|near)\s+([A-Za-z\s]+)\b/i);
  const location = locationMatch ? locationMatch[2] : undefined;

  return {
    query: message,
    location: location,
  };
}

/**
 * Format trip suggestion for response
 */
function formatTripSuggestion(tripData: any): any {
  // Parse dates if they're strings
  let startDate = tripData.startDate;
  let endDate = tripData.endDate;

  if (typeof startDate === "string") {
    startDate = new Date(startDate).toISOString().split("T")[0];
  }
  if (typeof endDate === "string") {
    endDate = new Date(endDate).toISOString().split("T")[0];
  }

  return {
    destination: tripData.destination,
    country: tripData.country || extractCountry(tripData.destination),
    startDate: startDate,
    endDate: endDate,
    budget: tripData.budget || 2000,
    interests: (tripData.interests || []).map((interest: string) => ({
      name: interest,
      icon: getIconForInterest(interest),
    })),
    hotels: (tripData.hotels || []).map((hotel: string) => ({
      name: hotel,
      address: "Address TBD",
      pricePerNight: 150,
      rating: 4.0,
      amenities: ["WiFi", "Breakfast"],
    })),
    itinerary: (tripData.activities || []).map((activity: string, index: number) => ({
      title: activity,
      description: "Enjoy this activity",
      date: startDate,
      time: "10:00 AM",
      location: tripData.destination,
      cost: 50,
      category: "sightseeing",
    })),
  };
}

function extractCountry(destination: string): string | null {
  const parts = destination.split(",").map((s) => s.trim());
  return parts.length > 1 ? parts[parts.length - 1] : null;
}

function getIconForInterest(interest: string): string {
  const lower = interest.toLowerCase();
  if (lower.includes("culture") || lower.includes("history")) return "building.columns";
  if (lower.includes("food") || lower.includes("dining")) return "fork.knife";
  if (lower.includes("beach") || lower.includes("relaxation")) return "beach.umbrella";
  if (lower.includes("adventure") || lower.includes("outdoor")) return "figure.hiking";
  if (lower.includes("art") || lower.includes("museum")) return "paintbrush";
  if (lower.includes("shopping")) return "bag";
  if (lower.includes("nightlife")) return "moon.stars";
  return "star";
}

