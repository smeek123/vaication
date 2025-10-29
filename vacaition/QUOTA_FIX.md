# OpenAI API Quota Issue - Quick Fix Guide

## The Problem
Your app is showing "error connecting to the ChatGPT API" because your OpenAI account has exceeded its quota/credits.

## The Solution
You need to add credits to your OpenAI account:

### Step 1: Go to OpenAI Billing
1. Visit: https://platform.openai.com/account/billing
2. Log in with your OpenAI account

### Step 2: Add Credits
1. Click "Add to credit balance" or "Add payment method"
2. Add a payment method (credit card)
3. Add at least $5-10 in credits to get started

### Step 3: Verify Usage Limits
1. Check your usage limits in the billing section
2. Make sure you have sufficient credits for API calls

## Cost Information
- **GPT-3.5-turbo**: ~$0.002 per 1K tokens (very cheap)
- **GPT-4**: ~$0.03 per 1K tokens (more expensive)
- A typical conversation costs only a few cents

## Alternative Solutions

### Option 1: Use a Different API Key
If you have another OpenAI account with credits, update the API key in `Config.plist`:

```xml
<key>OpenAI_API_Key</key>
<string>sk-your-new-api-key-here</string>
```

### Option 2: Use Environment Variable
Set the API key as an environment variable:

```bash
export OPENAI_API_KEY="sk-your-new-api-key-here"
```

### Option 3: Test with Mock Responses
For development/testing, you can temporarily disable the API calls and use mock responses.

## What I Fixed
1. ✅ Added better error handling for quota exceeded errors
2. ✅ Improved error messages to be more user-friendly
3. ✅ Added specific guidance for quota issues

## Next Steps
1. Add credits to your OpenAI account
2. Test the chat functionality
3. The app will now show a helpful error message if quota is exceeded again

## Need Help?
- OpenAI Support: https://help.openai.com/
- OpenAI Community: https://community.openai.com/
