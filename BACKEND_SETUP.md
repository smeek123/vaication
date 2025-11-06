# Backend Setup Guide

## API Base URL Configuration

### Security Note
**The API base URL is safe to expose in client code.** Here's why:

1. **Public Endpoint**: The Firebase Functions URL is a public endpoint - anyone can see it in network requests
2. **Security is Backend-Based**: 
   - Authentication happens via Firebase Auth tokens (validated on backend)
   - API keys (OpenAI, Amadeus, Google Places) are stored ONLY on the backend
   - Rate limiting and validation happen server-side
3. **No Sensitive Data**: The URL itself reveals nothing sensitive

### What IS Sensitive (Never in Client):
- ❌ OpenAI API Key
- ❌ Amadeus Client ID/Secret
- ❌ Google Places API Key
- ❌ Firebase Admin credentials

### What's Safe in Client:
- ✅ API Base URL (Firebase Functions endpoint)
- ✅ Public Firebase config (already in your app)

## Setting Up Your API Base URL

### Option 1: Config.plist (Recommended for Development)
1. Open `Config.plist`
2. Add the key `API_Base_URL` with your Firebase Functions URL:
   ```xml
   <key>API_Base_URL</key>
   <string>https://your-project-id.cloudfunctions.net</string>
   ```
3. Make sure `Config.plist` is in `.gitignore` (it should be)

### Option 2: Environment Variable (For CI/CD)
Set the environment variable `API_BASE_URL` before building:
```bash
export API_BASE_URL=https://your-project-id.cloudfunctions.net
```

### Finding Your Firebase Functions URL

After deploying your functions, you'll get a URL like:
```
https://us-central1-your-project-id.cloudfunctions.net/api
```

Or if using a specific region:
```
https://your-region-your-project-id.cloudfunctions.net/api
```

### Development vs Production

**Development (Local Emulator):**
```xml
<key>API_Base_URL</key>
<string>http://localhost:5001</string>
```

**Production (Deployed):**
```xml
<key>API_Base_URL</key>
<string>https://us-central1-your-project-id.cloudfunctions.net</string>
```

## Firebase Functions Deployment

1. Install dependencies:
   ```bash
   cd functions
   npm install
   ```

2. Set environment variables:
   ```bash
   firebase functions:config:set \
     openai.api_key="your-openai-key" \
     amadeus.client_id="your-amadeus-id" \
     amadeus.client_secret="your-amadeus-secret" \
     google.places_api_key="your-google-key"
   ```

3. Deploy:
   ```bash
   firebase deploy --only functions
   ```

4. After deployment, copy the function URL and add it to `Config.plist`

## Security Checklist

- ✅ API keys stored only in Firebase Functions config (not in client)
- ✅ Firebase Auth tokens validated on every request
- ✅ Rate limiting implemented on backend
- ✅ Input validation on backend
- ✅ CORS configured properly
- ✅ API base URL in Config.plist (safe to expose)

