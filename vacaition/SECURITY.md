# Security Guide - API Keys

## ✅ Current Implementation (Secure)

All API keys are stored **only on the backend** (Firebase Functions):

- ✅ **OpenAI API Key**: Stored in Firebase Functions environment variables
- ✅ **Amadeus Client ID/Secret**: Stored in Firebase Functions environment variables  
- ✅ **Google Places API Key**: Stored in Firebase Functions environment variables

The client app **never** has access to these keys.

## 🔒 What's Safe in Client Code

These are **safe to include** in the client:

- ✅ **API Base URL**: The Firebase Functions endpoint URL
  - Example: `https://your-project-id.cloudfunctions.net`
  - This is public and safe to expose
  - Security comes from Firebase Auth token validation

- ✅ **Firebase Config**: `GoogleService-Info.plist`
  - This is public configuration
  - Used for Firebase Auth (client-side auth is safe)

## ❌ What's NOT Safe in Client Code

**Never** put these in client code:

- ❌ OpenAI API Keys
- ❌ Amadeus Client ID/Secret
- ❌ Google Places API Key
- ❌ Any other API keys or secrets
- ❌ Firebase Admin credentials

## 🔐 Security Flow

```
┌─────────────────┐
│   Swift App     │
│  (Client)       │
│                 │
│  ✅ No API Keys │
└────────┬────────┘
         │
         │ 1. Request with Firebase Auth Token
         │
         ▼
┌─────────────────┐
│ Firebase        │
│ Functions       │
│ (Backend)       │
│                 │
│ 🔑 API Keys     │
│ 🔑 Validation   │
│ 🔑 Rate Limits  │
└────────┬────────┘
         │
         │ 2. API Calls with Keys
         │
         ▼
┌─────────────────┐
│ External APIs   │
│ (OpenAI, etc.)  │
└─────────────────┘
```

## 📋 Checklist

Before deploying to production:

- [ ] All API keys removed from `Config.plist`
- [ ] `Config.plist` is in `.gitignore`
- [ ] API keys configured in Firebase Functions environment variables
- [ ] `OpenAIService.swift` is deprecated (not used)
- [ ] `AIChatService.swift` is used instead (makes backend calls)
- [ ] Firebase Auth tokens validated on backend
- [ ] Rate limiting implemented on backend
- [ ] `.env` files are in `.gitignore` (backend)

## 🛠️ Migrating from Old Implementation

If you were using the old `OpenAIService` with client-side API keys:

1. **Remove API key from Config.plist**
   ```xml
   <!-- Remove this: -->
   <key>OpenAI_API_Key</key>
   <string>sk-...</string>
   ```

2. **Add API Base URL to Config.plist**
   ```xml
   <key>API_Base_URL</key>
   <string>https://your-project-id.cloudfunctions.net</string>
   ```

3. **Deploy Firebase Functions with API keys**
   ```bash
   firebase functions:config:set \
     openai.api_key="your-key-here"
   ```

4. **Verify ChatViewModel uses AIChatService**
   - Should use `AIChatService.shared`
   - NOT `OpenAIService.shared`

## 🚨 If You See API Keys in Client Code

If you find API keys in client code:

1. **Immediately revoke the exposed key** in the API provider's dashboard
2. **Generate a new key**
3. **Add the new key to Firebase Functions** (not client)
4. **Remove the key from client code**
5. **Commit the removal** (the old key is already exposed, so this prevents further exposure)

## 📚 References

- [Firebase Functions Configuration](https://firebase.google.com/docs/functions/config-env)
- [API Key Security Best Practices](https://owasp.org/www-community/vulnerabilities/Use_of_hard-coded_cryptographic_key)

