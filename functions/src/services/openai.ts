import OpenAI from "openai";

// Luna's personality prompt
const LUNA_PROMPT = `You are Luna — a smart, friendly AI travel companion shaped like a curious owl. 
You help users plan trips, discover cool destinations, and find local gems — all while keeping things fun, relaxed, and easy to understand.

Your personality:
- You're upbeat, curious, and love helping people explore the world.
- Talk like a friendly, well-traveled friend — natural, warm, and a little playful.
- You're wise but never stiff or robotic. Think "cool older sister who knows all the travel hacks."
- Occasionally make light, charming nods to being an owl (like "I've seen that city from above — gorgeous at sunset!"), but don't overuse it.

How you respond:
- Keep your answers focused on travel, exploration, or culture.
- Be helpful and specific — include ideas, tips, or short lists when needed.
- Write clearly and casually; use contractions and natural language.
- If a user asks something off-topic, give a quick friendly answer, then steer back to travel.
- Ask small follow-up questions when it makes sense ("Are you more into beaches or city adventures?") to personalize your help.

Your goal:
Make travel feel exciting, stress-free, and personal — like chatting with a friend who always knows where to go next.

IMPORTANT: When you provide trip suggestions or details, format them in a structured way that can be parsed. Use this exact JSON structure for trip information:

TRIP_DATA_START
{
    "destination": "City, Country",
    "startDate": "YYYY-MM-DD",
    "endDate": "YYYY-MM-DD", 
    "duration": 7,
    "budget": 2500.0,
    "interests": ["culture", "food", "history"],
    "activities": [
        {
            "name": "Activity title",
            "summary": "1-2 sentence overview of why this is great for the traveler.",
            "estimatedCost": 85.0,
            "costDetails": "Up to two sentences clarifying what the cost covers."
        }
    ],
    "hotels": ["Hotel Name 1", "Hotel Name 2"],
    "restaurants": ["Restaurant 1", "Restaurant 2"],
    "attractions": ["Attraction 1", "Attraction 2"]
}
TRIP_DATA_END

Only include this structured data when you're actually suggesting a complete trip plan.

Activity guidance:
- Suggest activities the traveler could enjoy during the trip — do not assign specific dates or times.
- Every activity must include: name, summary (max two sentences), estimatedCost (numeric), and costDetails (max two sentences explaining what the price covers).
- If pricing is uncertain, provide a reasonable estimate and clarify the assumptions in costDetails.
`;

export interface ChatMessage {
  role: "system" | "user" | "assistant";
  content: string;
}

export interface ConversationMessage {
  role: string;
  content: string;
  timestamp?: string;
}

export interface UserPreferences {
  savedTrips?: string[];
  preferences?: {
    [key: string]: string;
  };
}

export interface TravelData {
  flights?: any[];
  hotels?: any[];
  activities?: any[];
}

export class OpenAIService {
  private client: OpenAI;
  private model: string;

  constructor() {
    // Get API key from environment variable only (Firebase Functions v2)
    const apiKey = process.env.OPENAI_API_KEY;

    if (!apiKey) {
      throw new Error(
        "OPENAI_API_KEY not configured. " +
        "Set it as an environment variable in Firebase Functions v2. " +
        "Go to Firebase Console > Functions > api > Configuration > Environment Variables, " +
        "or set it during deployment: gcloud functions deploy api --set-env-vars OPENAI_API_KEY=your-key"
      );
    }

    this.client = new OpenAI({apiKey});
    this.model = process.env.OPENAI_MODEL || "gpt-3.5-turbo";
  }

  async generateResponse(
    userMessage: string,
    conversationHistory: ConversationMessage[],
    userPreferences?: UserPreferences,
    travelData?: TravelData
  ): Promise<string> {
    // Build messages array
    const messages: ChatMessage[] = [
      {role: "system", content: this.buildSystemPrompt(userPreferences, travelData)},
    ];

    // Add conversation history (convert to OpenAI format)
    conversationHistory.forEach((msg) => {
      const role = msg.role === "user" ? "user" : "assistant";
      messages.push({
        role: role as "user" | "assistant",
        content: msg.content,
      });
    });

    // Add current user message
    messages.push({role: "user", content: userMessage});

    try {
      const completion = await this.client.chat.completions.create({
        model: this.model,
        messages: messages,
        temperature: 0.7,
        max_tokens: 1000,
      });

      const response = completion.choices[0]?.message?.content;
      if (!response) {
        throw new Error("No response from OpenAI");
      }

      return response;
    } catch (error: any) {
      console.error("OpenAI API error:", error);
      throw new Error(`OpenAI API error: ${error.message}`);
    }
  }

  private buildSystemPrompt(
    userPreferences?: UserPreferences,
    travelData?: TravelData
  ): string {
    let prompt = LUNA_PROMPT;

    // Add user context if available
    if (userPreferences?.savedTrips && userPreferences.savedTrips.length > 0) {
      prompt += `\n\nUser's previous trips: ${userPreferences.savedTrips.join(", ")}. Use this to personalize suggestions.`;
    }

    // Add travel data context if available
    if (travelData) {
      if (travelData.flights && travelData.flights.length > 0) {
        prompt += "\n\nAvailable flights data has been provided. Reference specific flight options when relevant.";
      }
      if (travelData.hotels && travelData.hotels.length > 0) {
        prompt += "\n\nAvailable hotels data has been provided. Reference specific hotel options when relevant.";
      }
      if (travelData.activities && travelData.activities.length > 0) {
        prompt += "\n\nAvailable activities/attractions data has been provided. Reference specific activities when relevant.";
      }
    }

    return prompt;
  }

  /**
   * Extract trip data from AI response if present
   */
  extractTripData(response: string): any | null {
    const tripDataPattern = /TRIP_DATA_START\s*(\{[\s\S]*?\})\s*TRIP_DATA_END/;
    const match = response.match(tripDataPattern);

    if (!match) {
      return null;
    }

    try {
      return JSON.parse(match[1]);
    } catch (error) {
      console.error("Failed to parse trip data:", error);
      return null;
    }
  }
}

