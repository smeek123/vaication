# ⚠️ DEPRECATED: OpenAI Setup (Backend Only)

**This document is outdated.** The app now uses a backend API (Firebase Functions) for all OpenAI calls.

## Current Architecture

All OpenAI API calls now go through the backend:
- ✅ **Client**: Swift app calls `AIChatService` → Backend API
- ✅ **Backend**: Firebase Functions handles OpenAI API calls
- ✅ **Security**: API keys stored only on backend

## Setting Up OpenAI (Backend)

1. **Deploy Firebase Functions** (see `BACKEND_SETUP.md`)
2. **Configure OpenAI API key in Firebase Functions:**
   ```bash
   firebase functions:config:set openai.api_key="your-openai-api-key"
   ```
3. **Deploy functions:**
   ```bash
   firebase deploy --only functions
   ```

## Client Configuration

The client app only needs the API base URL (safe to expose):

1. Open `Config.plist`
2. Add your Firebase Functions URL:
   ```xml
   <key>API_Base_URL</key>
   <string>https://your-project-id.cloudfunctions.net</string>
   ```

## Security

- ❌ **Never** put OpenAI API keys in `Config.plist` or client code
- ✅ API keys belong only in Firebase Functions environment variables
- ✅ The API base URL is safe to expose (security comes from Firebase Auth tokens)

See `SECURITY.md` for more details.
