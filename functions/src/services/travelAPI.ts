import axios from "axios";

export interface FlightSearchParams {
  origin: string;
  destination: string;
  departureDate: string;
  returnDate?: string;
  adults?: number;
}

export interface HotelSearchParams {
  cityCode: string;
  checkInDate: string;
  checkOutDate: string;
  adults?: number;
}

export interface ActivitySearchParams {
  query: string;
  location?: string;
  type?: string;
}

export class TravelAPIService {
  private googlePlacesKey: string;
  private amadeusClientId?: string;
  private amadeusClientSecret?: string;
  private amadeusAccessToken: string | null = null;
  private tokenExpiry = 0;

  constructor() {
    // Get credentials from environment variables only (Firebase Functions v2)
    const amadeusClientId = process.env.AMADEUS_CLIENT_ID;
    const amadeusClientSecret = process.env.AMADEUS_CLIENT_SECRET;
    const googlePlacesKey = process.env.GOOGLE_PLACES_API_KEY;

    // Store credentials (will be undefined if not configured)
    this.amadeusClientId = amadeusClientId;
    this.amadeusClientSecret = amadeusClientSecret;
    this.googlePlacesKey = googlePlacesKey || "";

    if (!amadeusClientId || !amadeusClientSecret) {
      console.warn("Amadeus credentials not configured. Flight and hotel search will be disabled. " +
        "Set AMADEUS_CLIENT_ID and AMADEUS_CLIENT_SECRET as environment variables.");
    }

    if (!this.googlePlacesKey) {
      console.warn("Google Places API key not configured. Activity search will be disabled. " +
        "Set GOOGLE_PLACES_API_KEY as an environment variable.");
    }
  }

  /**
   * Get Amadeus access token (OAuth 2.0)
   */
  private async getAmadeusToken(): Promise<string> {
    const now = Date.now();

    // Return cached token if still valid
    if (this.amadeusAccessToken && now < this.tokenExpiry) {
      return this.amadeusAccessToken; // TypeScript knows this is string at this point
    }

    const clientId = this.amadeusClientId;
    const clientSecret = this.amadeusClientSecret;

    if (!clientId || !clientSecret) {
      throw new Error("Amadeus credentials not configured. Set them using: firebase functions:config:set amadeus.client_id=\"...\" amadeus.client_secret=\"...\"");
    }

    try {
      const response = await axios.post(
        "https://test.api.amadeus.com/v1/security/oauth2/token",
        new URLSearchParams({
          grant_type: "client_credentials",
          client_id: clientId,
          client_secret: clientSecret,
        }),
        {
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
        }
      );

      const accessToken = response.data.access_token;
      if (!accessToken || typeof accessToken !== "string") {
        throw new Error("No access token received from Amadeus");
      }

      // Store the token (guaranteed to be string at this point)
      this.amadeusAccessToken = accessToken;
      // Token expires in response.data.expires_in seconds, refresh 5 minutes early
      this.tokenExpiry = now + (response.data.expires_in - 300) * 1000;

      // Return the validated string token
      return accessToken;
    } catch (error: any) {
      console.error("Amadeus token error:", error);
      throw new Error("Failed to authenticate with Amadeus API");
    }
  }

  /**
   * Search for flights using Amadeus API
   */
  async searchFlights(params: FlightSearchParams): Promise<any[]> {
    try {
      const token = await this.getAmadeusToken();

      const response = await axios.get(
        "https://test.api.amadeus.com/v2/shopping/flight-offers",
        {
          params: {
            originLocationCode: params.origin,
            destinationLocationCode: params.destination,
            departureDate: params.departureDate,
            returnDate: params.returnDate,
            adults: params.adults || 1,
            max: 5, // Limit to 5 results
          },
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      return this.formatFlightResults(response.data.data || []);
    } catch (error: any) {
      console.error("Flight search error:", error);
      // Return empty array on error rather than throwing
      return [];
    }
  }

  /**
   * Search for hotels using Amadeus API
   */
  async searchHotels(params: HotelSearchParams): Promise<any[]> {
    try {
      const token = await this.getAmadeusToken();

      // First, get hotel IDs by city
      const cityResponse = await axios.get(
        "https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-city",
        {
          params: {
            cityCode: params.cityCode,
            radius: 50,
            radiusUnit: "KM",
          },
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      const hotelIds = cityResponse.data.data?.slice(0, 10).map((h: any) => h.hotelId) || [];

      if (hotelIds.length === 0) {
        return [];
      }

      // Get hotel offers
      const offersResponse = await axios.get(
        "https://test.api.amadeus.com/v3/shopping/hotel-offers",
        {
          params: {
            hotelIds: hotelIds.join(","),
            checkInDate: params.checkInDate,
            checkOutDate: params.checkOutDate,
            adults: params.adults || 1,
          },
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      return this.formatHotelResults(offersResponse.data.data || []);
    } catch (error: any) {
      console.error("Hotel search error:", error);
      return [];
    }
  }

  /**
   * Search for activities using Google Places API
   */
  async searchActivities(params: ActivitySearchParams): Promise<any[]> {
    if (!this.googlePlacesKey) {
      console.warn("Google Places API key not configured");
      return [];
    }

    try {
      // Use Text Search API
      const response = await axios.get(
        "https://maps.googleapis.com/maps/api/place/textsearch/json",
        {
          params: {
            query: params.query,
            key: this.googlePlacesKey,
            type: params.type || "tourist_attraction",
            language: "en",
          },
        }
      );

      if (response.data.status !== "OK") {
        console.error("Google Places API error:", response.data.status);
        return [];
      }

      return this.formatActivityResults(response.data.results || []);
    } catch (error: any) {
      console.error("Activity search error:", error);
      return [];
    }
  }

  /**
   * Detect travel intent from user message
   */
  detectTravelIntent(message: string): {
    needsFlights: boolean;
    needsHotels: boolean;
    needsActivities: boolean;
  } {
    return {
      needsFlights: /\b(flight|fly|airplane|airline|departure|arrival|ticket)\b/i.test(message),
      needsHotels: /\b(hotel|accommodation|stay|lodging|room|book a place)\b/i.test(message),
      needsActivities: /\b(activity|attraction|things to do|what to see|sightseeing|tour|museum|park|restaurant)\b/i.test(message),
    };
  }

  private formatFlightResults(flights: any[]): any[] {
    return flights.map((flight) => ({
      id: flight.id,
      origin: flight.itineraries[0]?.segments[0]?.departure?.iataCode,
      destination: flight.itineraries[0]?.segments[flight.itineraries[0].segments.length - 1]?.arrival?.iataCode,
      departureDate: flight.itineraries[0]?.segments[0]?.departure?.at,
      returnDate: flight.itineraries[1]?.segments[0]?.departure?.at,
      price: parseFloat(flight.price?.total || "0"),
      airline: flight.itineraries[0]?.segments[0]?.carrierCode,
      duration: flight.itineraries[0]?.duration,
    }));
  }

  private formatHotelResults(hotels: any[]): any[] {
    return hotels.map((hotel) => ({
      id: hotel.hotel?.hotelId,
      name: hotel.hotel?.name,
      address: hotel.hotel?.address?.lines?.join(", "),
      pricePerNight: parseFloat(hotel.offers[0]?.price?.total || "0"),
      rating: hotel.hotel?.rating || 0,
      amenities: hotel.hotel?.amenities || [],
      availability: hotel.offers?.length > 0,
    }));
  }

  private formatActivityResults(activities: any[]): any[] {
    return activities.map((activity) => ({
      id: activity.place_id,
      name: activity.name,
      address: activity.formatted_address,
      rating: activity.rating,
      priceLevel: activity.price_level,
      types: activity.types,
      photoReference: activity.photos?.[0]?.photo_reference,
    }));
  }
}

