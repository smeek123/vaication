# Next Steps - Getting Your AI Travel Agent Running

## Overview

All the code is complete! Now you need to:
1. Set up Firebase SDK in your Swift app (via Swift Package Manager)
2. Deploy the backend (Firebase Functions)
3. Configure API keys
4. Update the client app configuration
5. Test everything

**Important Note:** Firebase Functions (backend) run on Node.js/TypeScript, not Swift. You'll need Node.js and the Firebase CLI for deploying the backend, but you can manage most configuration via the Firebase Console (browser).

This guide will walk you through each step.

---

## Step 1: Add Firebase SDK to Your Swift App (If Not Already Done)

### Option A: Via Xcode (Recommended)

1. Open your project in Xcode
2. Go to **File** → **Add Package Dependencies...**
3. Enter this URL: `https://github.com/firebase/firebase-ios-sdk`
4. Click **Add Package**
5. Select these products (you may already have some):
   - ✅ **FirebaseAuth** (for authentication)
   - ✅ **FirebaseFirestore** (for database)
   - ✅ **FirebaseCore** (required)
6. Click **Add Package**
7. Make sure your target is selected, then click **Add Package**

### Option B: Verify Existing Installation

If you already have Firebase imports working (like `import FirebaseAuth`), you're all set! The Firebase SDK is already installed.

---

## Step 2: Create/Configure Firebase Project (Browser-Based)

### A. Create Firebase Project (If New)

1. Go to https://console.firebase.google.com
2. Click **Add project** (or select existing)
3. Enter project name: **vacaition** (or your preferred name)
4. Follow the setup wizard
5. **Enable Google Analytics** (optional, but recommended)

### B. Add iOS App to Firebase

1. In Firebase Console, click the **iOS** icon (or **Add app**)
2. Enter your iOS bundle ID (find it in Xcode: Project → Target → General → Bundle Identifier)
3. Enter app nickname: **Vaication**
4. Click **Register app**
5. Download `GoogleService-Info.plist`
6. **Drag and drop** `GoogleService-Info.plist` into your Xcode project (in the `vacaition` folder)
7. Make sure "Copy items if needed" is checked
8. Make sure your app target is selected

### C. Enable Required Services

In Firebase Console, go to your project:

1. **Authentication:**
   - Go to **Build** → **Authentication**
   - Click **Get started**
   - Enable **Email/Password** sign-in method
   - Click **Save**

2. **Firestore Database:**
   - Go to **Build** → **Firestore Database**
   - Click **Create database**
   - Start in **test mode** (for development)
   - Choose a location (closest to your users)
   - Click **Enable**

---

## Step 3: Install Firebase CLI (For Backend Deployment)

**Note:** You still need the CLI to deploy Firebase Functions (the backend), but you can manage most config via the browser.

```bash
npm install -g firebase-tools
```

Verify installation:
```bash
firebase --version
```

## Step 4: Login to Firebase (CLI)

```bash
firebase login
```

This will open a browser window for authentication. Click **Allow** when prompted.

## Step 5: Link Your Project to Firebase (CLI)

```bash
cd /Users/seanmeek/Desktop/vacaition
firebase use --add
```

Select your Firebase project from the list (the one you created in Step 2).

## Step 6: Initialize Firebase Functions (If Not Done)

```bash
cd /Users/seanmeek/Desktop/vacaition
firebase init functions
```

When prompted:
- **Select existing project** or create a new one
- **Language**: TypeScript
- **ESLint**: Yes (optional, but recommended)
- **Install dependencies**: Yes

## Step 7: Install Backend Dependencies

```bash
cd functions
npm install
```

This installs all the required packages (OpenAI, axios, etc.)

## Step 8: Get Your API Keys

You'll need API keys for three services:

### A. OpenAI API Key
1. Go to https://platform.openai.com/api-keys
2. Sign in or create an account
3. Click "Create new secret key"
4. **Copy the key immediately** (you won't see it again)
5. Save it somewhere secure

### B. Amadeus API Credentials (For Flights & Hotels)
1. Go to https://developers.amadeus.com/get-started
2. Sign up for a free account
3. Create a new app
4. Copy your **Client ID** and **Client Secret**
5. Note: Free tier includes 2000 calls/month

### C. Google Places API Key (For Activities)
1. Go to https://console.cloud.google.com/
2. Create a new project or select existing
3. Enable "Places API":
   - Go to "APIs & Services" → "Library"
   - Search for "Places API"
   - Click "Enable"
4. Create credentials:
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "API Key"
   - Copy the key
   - (Optional) Restrict the key to Places API only

## Step 9: Configure API Keys in Firebase (Browser or CLI)

### Option A: Via Firebase Console (Browser - Recommended for First Setup)

1. Go to https://console.firebase.google.com
2. Select your project
3. Go to **Functions** → **Configuration** (or **Settings** → **Functions**)
4. Click **Edit** or **Add Environment Variable**
5. Add these environment variables:
   - `OPENAI_API_KEY` = your OpenAI API key
   - `AMADEUS_CLIENT_ID` = your Amadeus Client ID
   - `AMADEUS_CLIENT_SECRET` = your Amadeus Client Secret
   - `GOOGLE_PLACES_API_KEY` = your Google Places API key
6. Click **Save**

**Note:** If you don't see Functions config in the console, use Option B (CLI) instead.

### Option B: Via Firebase CLI (Alternative)

```bash
cd /Users/seanmeek/Desktop/vacaition/functions

firebase functions:config:set \
  openai.api_key="sk-your-openai-api-key-here" \
  amadeus.client_id="your-amadeus-client-id" \
  amadeus.client_secret="your-amadeus-client-secret" \
  google.places_api_key="your-google-places-api-key"
```

**Important:** Replace the placeholder values with your actual keys!

Verify the configuration was set:
```bash
firebase functions:config:get
```

You should see your config (keys will be partially hidden for security).

## Step 10: Build and Deploy Backend

```bash
cd /Users/seanmeek/Desktop/vacaition/functions

# Build TypeScript
npm run build

# Deploy to Firebase
firebase deploy --only functions
```

This will take a few minutes. When it completes, you'll see output like:

```
✔  functions[api(us-central1)]: Successful create operation.
Function URL: https://us-central1-your-project-id.cloudfunctions.net/api
```

**Copy this URL** - you'll need it in the next step!

### Alternative: Get Function URL from Browser

After deployment, you can also find the URL in Firebase Console:
1. Go to https://console.firebase.google.com
2. Select your project
3. Go to **Functions**
4. Click on the **api** function
5. Copy the **Trigger URL**

## Step 11: Update Client App Configuration

### A. Verify GoogleService-Info.plist is Added

Make sure `GoogleService-Info.plist` is in your Xcode project:
1. Check that it appears in the Project Navigator
2. Verify it's included in your app target (check Target Membership in File Inspector)

### B. Update API Base URL

1. Open `vacaition/Config.plist` in Xcode
2. Find the `API_Base_URL` key
3. Replace the placeholder with your actual Firebase Functions URL:

```xml
<key>API_Base_URL</key>
<string>https://us-central1-your-project-id.cloudfunctions.net</string>
```

**Important:** 
- Use the URL from Step 10 (without `/api` at the end)
- The URL format is: `https://REGION-PROJECT-ID.cloudfunctions.net`
- You can also find this URL in Firebase Console → Functions → api function

## Step 12: Test the Backend

### Test Health Endpoint

Open a browser or use curl:
```bash
curl https://us-central1-your-project-id.cloudfunctions.net/api/health
```

You should see:
```json
{"status":"ok","timestamp":"2024-..."}
```

### Test in Your App

1. Open the app in Xcode
2. Build and run
3. Navigate to the Chat view
4. Send a message like "I want to plan a trip to Paris"
5. You should see Luna respond!

## Step 13: Troubleshooting

### Issue: "OPENAI_API_KEY not configured"

**Solution:**
- Make sure you ran `firebase functions:config:set` in Step 6
- Verify config: `firebase functions:config:get`
- Redeploy: `firebase deploy --only functions`

### Issue: "Unauthorized" error in app

**Solution:**
- Make sure you're signed in to the app (Firebase Auth)
- Check that Firebase Auth is properly configured
- Verify the API Base URL in `Config.plist` is correct

### Issue: Backend returns 500 error

**Solution:**
- Check Firebase Functions logs:
  ```bash
  firebase functions:log
  ```
- Look for specific error messages
- Verify all API keys are set correctly

### Issue: Travel APIs not working

**Solution:**
- Amadeus: Verify Client ID and Secret are correct
- Google Places: Make sure Places API is enabled in Google Cloud Console
- Check logs: `firebase functions:log`

### Issue: Can't connect to backend

**Solution:**
- Verify the API Base URL in `Config.plist` matches your deployed function URL
- Check your internet connection
- Make sure the backend is deployed: `firebase functions:list`

## Step 14: Monitor Usage

### View Function Logs (Browser - Recommended)

1. Go to https://console.firebase.google.com
2. Select your project
3. Go to **Functions** → **Logs**
4. View real-time logs and filter by function

### View Function Logs (CLI Alternative)
```bash
firebase functions:log
```

### Monitor Costs
- OpenAI: https://platform.openai.com/usage
- Amadeus: Check your Amadeus dashboard
- Google Cloud: https://console.cloud.google.com/billing

## Optional: Local Development

If you want to test locally before deploying:

### 1. Start Firebase Emulator

```bash
cd functions
npm run serve
```

This starts the emulator on `http://localhost:5001`

### 2. Update Client for Local Testing

In `Config.plist`, temporarily set:
```xml
<key>API_Base_URL</key>
<string>http://localhost:5001</string>
```

### 3. Set Local Environment Variables

Create a `.env` file in `functions/` directory:
```
OPENAI_API_KEY=your-key
AMADEUS_CLIENT_ID=your-id
AMADEUS_CLIENT_SECRET=your-secret
GOOGLE_PLACES_API_KEY=your-key
```

Then run:
```bash
source .env
npm run serve
```

**Remember:** `.env` files should never be committed to git!

## Summary: What Can Be Done in Browser vs CLI

### ✅ Browser (Firebase Console) - Can Do:
- Create/manage Firebase project
- Add iOS app and download GoogleService-Info.plist
- Enable Authentication and Firestore
- View function URLs after deployment
- View function logs
- Monitor usage and billing
- (Some projects) Set environment variables for Functions

### 🔧 CLI Required - Must Do:
- Deploy Firebase Functions (backend code)
- Initialize Functions project
- Install npm dependencies
- Build TypeScript code
- Link local project to Firebase project

**Bottom Line:** Use the browser for configuration and monitoring, CLI for deployment.

## Security Reminders

✅ **DO:**
- Keep API keys in Firebase Functions config only
- Use Firebase Auth tokens for authentication
- Monitor API usage regularly
- Set up billing alerts

❌ **DON'T:**
- Put API keys in `Config.plist` or client code
- Commit API keys to git
- Share API keys publicly
- Use production keys in development

## What's Next After Setup?

Once everything is working:

1. **Test the full flow:**
   - Ask for trip suggestions
   - Request flights/hotels/activities
   - Save trips to your profile

2. **Customize Luna's personality:**
   - Edit `functions/src/services/openai.ts`
   - Modify the `LUNA_PROMPT` constant

3. **Improve travel API integration:**
   - Enhance parameter extraction in `functions/src/api/chat.ts`
   - Add more sophisticated intent detection

4. **Add features:**
   - Response caching
   - Rate limiting per user
   - Conversation analytics

## Getting Help

- **Firebase Functions Docs:** https://firebase.google.com/docs/functions
- **OpenAI API Docs:** https://platform.openai.com/docs
- **Amadeus API Docs:** https://developers.amadeus.com/
- **Google Places API Docs:** https://developers.google.com/maps/documentation/places

## Summary Checklist

### Swift App Setup (Xcode)
- [ ] Firebase SDK added via Swift Package Manager
- [ ] Firebase project created in browser console
- [ ] iOS app added to Firebase project
- [ ] `GoogleService-Info.plist` downloaded and added to Xcode
- [ ] Authentication enabled in Firebase Console
- [ ] Firestore enabled in Firebase Console

### Backend Setup (CLI)
- [ ] Firebase CLI installed
- [ ] Logged in to Firebase (`firebase login`)
- [ ] Project linked (`firebase use --add`)
- [ ] Functions initialized (`firebase init functions`)
- [ ] Dependencies installed (`npm install` in functions/)

### API Keys
- [ ] OpenAI API key obtained
- [ ] Amadeus credentials obtained
- [ ] Google Places API key obtained
- [ ] API keys configured (browser or CLI)

### Deployment
- [ ] Backend deployed (`firebase deploy --only functions`)
- [ ] Function URL copied (from CLI output or browser console)
- [ ] `Config.plist` updated with API Base URL

### Testing
- [ ] Health endpoint tested
- [ ] App tested end-to-end

---

**You're all set!** Once you complete these steps, your AI travel agent will be fully functional. 🚀

