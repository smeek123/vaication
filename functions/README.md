# Firebase Functions - Vaication Backend

This directory contains the Firebase Functions backend for the Vaication travel planning app.

## Architecture

- **Chat Endpoint**: `/api/chat` - Main AI chat handler with OpenAI integration
- **Travel APIs**: Integrated with Amadeus (flights/hotels) and Google Places (activities)
- **Authentication**: Firebase Auth token validation
- **Database**: Firestore for user preferences (no conversation storage)

## Setup

### Prerequisites

1. Node.js 18+ installed
2. Firebase CLI installed: `npm install -g firebase-tools`
3. Firebase project initialized

### Installation

```bash
cd functions
npm install
```

### Configuration

Set environment variables for API keys:

```bash
firebase functions:config:set \
  openai.api_key="your-openai-api-key" \
  amadeus.client_id="your-amadeus-client-id" \
  amadeus.client_secret="your-amadeus-client-secret" \
  google.places_api_key="your-google-places-api-key"
```

### Development

Run locally with emulator:

```bash
npm run serve
```

This will start the Firebase emulator on `http://localhost:5001`

### Build

```bash
npm run build
```

### Deploy

```bash
npm run deploy
```

Or deploy specific function:

```bash
firebase deploy --only functions:api
```

## API Endpoints

### POST /api/chat

Main chat endpoint for AI travel assistant.

**Request:**
```json
{
  "message": "I want to plan a trip to Paris",
  "conversationHistory": [
    {
      "role": "user",
      "content": "Hello",
      "timestamp": "2024-01-01T00:00:00Z"
    },
    {
      "role": "assistant",
      "content": "Hi! I'm Luna...",
      "timestamp": "2024-01-01T00:00:01Z"
    }
  ],
  "userPreferences": {
    "savedTrips": ["Paris", "Tokyo"],
    "preferences": {
      "preferredLanguage": "en"
    }
  }
}
```

**Response:**
```json
{
  "response": "Great choice! Paris is...",
  "tripSuggestion": {
    "destination": "Paris, France",
    "startDate": "2024-06-01",
    "endDate": "2024-06-08",
    "budget": 2500.0,
    "interests": [...],
    "hotels": [...],
    "itinerary": [...]
  },
  "travelData": {
    "flights": [...],
    "hotels": [...],
    "activities": [...]
  }
}
```

## Travel API Integration

### Amadeus API

- **Flights**: Flight Offers Search API
- **Hotels**: Hotel Offers Search API
- **Free Tier**: 2000 calls/month

### Google Places API

- **Activities**: Text Search, Nearby Search
- **Pricing**: $0.017 per request (after free tier)

## Security

- ✅ All API keys stored in Firebase Functions config (not in client)
- ✅ Firebase Auth token validation on every request
- ✅ Rate limiting (implement per your needs)
- ✅ Input validation

## Project Structure

```
functions/
├── src/
│   ├── index.ts              # Main entry point
│   ├── api/
│   │   └── chat.ts          # Chat endpoint handler
│   ├── services/
│   │   ├── openai.ts         # OpenAI integration
│   │   ├── travelAPI.ts      # Amadeus + Google Places
│   │   └── firestore.ts      # Firestore helpers
│   └── utils/
│       ├── auth.ts           # Auth validation
│       ├── errors.ts         # Error handling
│       └── cors.ts           # CORS middleware
├── package.json
├── tsconfig.json
└── README.md
```

## Troubleshooting

### "OPENAI_API_KEY not configured"

Make sure you've set the config:
```bash
firebase functions:config:set openai.api_key="your-key"
```

### "Amadeus credentials not configured"

Set Amadeus credentials:
```bash
firebase functions:config:set \
  amadeus.client_id="your-id" \
  amadeus.client_secret="your-secret"
```

### Check logs

```bash
firebase functions:log
```

## Environment Variables

After setting config, view them:
```bash
firebase functions:config:get
```

## Notes

- Conversations are NOT persisted (in-memory only during session)
- User preferences are loaded from Firestore for personalization
- Travel API calls are made when intent is detected from user messages

