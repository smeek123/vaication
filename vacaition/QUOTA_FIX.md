# OpenAI API Quota Issue - Quick Fix Guide

## Current Architecture (Backend API)

**Note:** The app now uses a backend API for OpenAI calls. If you're seeing quota errors, the issue is with the backend configuration.

## If You See Quota Errors

### Option 1: Add Credits to OpenAI Account (Recommended)

1. Go to [OpenAI Billing](https://platform.openai.com/account/billing)
2. Log in with your OpenAI account
3. Add payment method and credits
4. The backend will automatically use the updated account

### Option 2: Update Backend API Key

If you have another OpenAI account with credits:

1. **Update Firebase Functions environment variable:**
   ```bash
   firebase functions:config:set openai.api_key="sk-your-new-api-key-here"
   ```

2. **Redeploy functions:**
   ```bash
   firebase deploy --only functions
   ```

### Option 3: Check Backend Logs

Check Firebase Functions logs for detailed error messages:
```bash
firebase functions:log
```

## Important Notes

- ⚠️ **Never** put API keys in client code (`Config.plist`)
- ✅ All API keys should be in Firebase Functions environment variables
- ✅ The client app doesn't need direct access to OpenAI API keys

## Troubleshooting

1. **Verify backend is deployed:**
   - Check Firebase Console → Functions
   - Ensure the `api` function is deployed

2. **Check API key is set:**
   ```bash
   firebase functions:config:get
   ```

3. **Verify OpenAI account:**
   - Check billing at https://platform.openai.com/account/billing
   - Ensure account has credits/quota available

## Getting Help

- Firebase Functions Docs: https://firebase.google.com/docs/functions
- OpenAI Support: https://help.openai.com/
- See `SECURITY.md` for security best practices
