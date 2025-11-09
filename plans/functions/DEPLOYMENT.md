# Deployment Guide

## Prerequisites

1. Firebase CLI installed: `npm install -g firebase-tools`
2. Node.js 18+ installed
3. Firebase project created at https://console.firebase.google.com

## Initial Setup

### 1. Install Dependencies

```bash
cd functions
npm install
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Initialize Firebase (if not already done)

```bash
firebase init functions
```

Select:
- Use existing project or create new one
- TypeScript: Yes
- ESLint: Yes (optional)
- Install dependencies: Yes

### 4. Configure API Keys

Set all API keys in Firebase Functions config:

```bash
firebase functions:config:set \
  openai.api_key="sk-your-openai-api-key" \
  amadeus.client_id="your-amadeus-client-id" \
  amadeus.client_secret="your-amadeus-client-secret" \
  google.places_api_key="your-google-places-api-key"
```

**Important:** Never commit API keys to git. They're stored securely in Firebase.

### 5. Get Your API Keys

#### OpenAI API Key
1. Go to https://platform.openai.com/api-keys
2. Create new API key
3. Copy and use in step 4

#### Amadeus API Credentials
1. Go to https://developers.amadeus.com/get-started
2. Sign up for free account
3. Create new app
4. Copy Client ID and Client Secret
5. Use in step 4

#### Google Places API Key
1. Go to https://console.cloud.google.com/apis/credentials
2. Create new API key
3. Enable "Places API" for the key
4. Copy and use in step 4

## Deployment

### Build and Deploy

```bash
cd functions
npm run build
firebase deploy --only functions
```

### Deploy Specific Function

```bash
firebase deploy --only functions:api
```

## Get Your Function URL

After deployment, Firebase will show you the function URL:

```
✔  functions[api(us-central1)]: Successful create operation.
Function URL: https://us-central1-your-project-id.cloudfunctions.net/api
```

**Copy this URL** - you'll need it for the client app.

## Update Client Configuration

1. Open `vacaition/Config.plist`
2. Update the API Base URL:

```xml
<key>API_Base_URL</key>
<string>https://us-central1-your-project-id.cloudfunctions.net</string>
```

## Testing

### Test Health Endpoint

```bash
curl https://us-central1-your-project-id.cloudfunctions.net/api/health
```

Should return:
```json
{"status":"ok","timestamp":"2024-01-01T00:00:00.000Z"}
```

### Test Chat Endpoint (with Auth)

You'll need a Firebase Auth token. In your Swift app, test the chat functionality.

## Local Development

### Run Emulator

```bash
cd functions
npm run serve
```

This starts the Firebase emulator on `http://localhost:5001`

### Update Client for Local Testing

In `Config.plist`, set:
```xml
<key>API_Base_URL</key>
<string>http://localhost:5001</string>
```

## Troubleshooting

### "Function failed to deploy"

- Check that all dependencies are installed: `npm install`
- Verify TypeScript compiles: `npm run build`
- Check Firebase Functions logs: `firebase functions:log`

### "OPENAI_API_KEY not configured"

- Verify config is set: `firebase functions:config:get`
- Redeploy after setting config

### "Permission denied"

- Make sure you're logged in: `firebase login`
- Verify you have permissions on the Firebase project

## Environment Variables (Alternative)

For local development, you can use `.env` file:

```bash
# .env (in functions directory)
OPENAI_API_KEY=your-key
AMADEUS_CLIENT_ID=your-id
AMADEUS_CLIENT_SECRET=your-secret
GOOGLE_PLACES_API_KEY=your-key
```

Then load with: `source .env` before running emulator.

**Note:** `.env` files are gitignored and should never be committed.

## Monitoring

View function logs:
```bash
firebase functions:log
```

View in Firebase Console:
https://console.firebase.google.com/project/your-project/functions

## Cost Management

- **Firebase Functions**: Free tier includes 2M invocations/month
- **OpenAI**: Pay per token usage
- **Amadeus**: Free tier includes 2000 calls/month
- **Google Places**: $0.017 per request after free tier

Monitor usage in Firebase Console and set up billing alerts.

