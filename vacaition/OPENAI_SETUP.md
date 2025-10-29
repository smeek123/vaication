# OpenAI API Setup Guide for Vacaition App

This guide will help you set up the OpenAI API integration for your Vacaition travel planning app.

## Prerequisites

1. An OpenAI API account (sign up at [OpenAI](https://platform.openai.com/))
2. An OpenAI API key with access to GPT models
3. Xcode with iOS development capabilities

## Step 1: Get Your OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in to your account
3. Navigate to the API section
4. Create a new API key:
   - Click on "API Keys" in the left sidebar
   - Click "Create new secret key"
   - Give it a name (e.g., "Vacaition App")
   - Copy the generated key (you won't be able to see it again!)

## Step 2: Configure Your API Key

You have several options for configuring your API key:

### Option A: Environment Variable (Recommended for Development)
1. Open Terminal
2. Add the following to your shell profile (`.zshrc`, `.bash_profile`, etc.):
   ```bash
   export OPENAI_API_KEY="your-actual-api-key-here"
   ```
3. Restart your terminal or run `source ~/.zshrc`

### Option B: Configuration File (Recommended for Production)
1. Open the `Config.plist` file in your Xcode project
2. Replace `your-openai-api-key-here` with your actual API key:
   ```xml
   <key>OpenAI_API_Key</key>
   <string>sk-your-actual-api-key-here</string>
   ```

### Option C: Direct Code Configuration (Not Recommended)
If you need to hardcode the key temporarily, you can modify the `OpenAIService.swift` file:
```swift
private static func getAPIKey() -> String {
    return "sk-your-actual-api-key-here"
}
```

## Step 3: Test the Integration

1. Build and run your app in Xcode
2. Navigate to the Chat screen
3. Send a message like "I want to plan a trip to Paris"
4. You should see Luna respond with travel suggestions

## Step 4: Configure API Settings (Optional)

You can customize the OpenAI API settings in `Config.plist`:

```xml
<key>OpenAI_Model</key>
<string>gpt-3.5-turbo</string>

<key>OpenAI_Max_Tokens</key>
<integer>1000</integer>

<key>OpenAI_Temperature</key>
<real>0.7</real>

<key>API_Timeout</key>
<integer>30</integer>

<key>Max_Retry_Attempts</key>
<integer>3</integer>
```

### Available Models:
- `gpt-3.5-turbo` (recommended, cost-effective)
- `gpt-4` (more capable but more expensive)
- `gpt-4-turbo` (latest GPT-4 model)

### Temperature Settings:
- `0.0` - Very focused and deterministic
- `0.7` - Balanced creativity and consistency (recommended)
- `1.0` - Very creative and varied responses

## Step 5: Understanding Luna's Personality

Luna is designed to be:
- **Friendly and conversational**: Uses contractions and natural language
- **Travel-focused**: Always steers conversations back to travel topics
- **Helpful and specific**: Provides actionable advice and suggestions
- **Playful**: Occasionally references being an owl
- **Contextual**: Remembers conversation history for better responses

## Step 6: Trip Data Parsing

When Luna suggests a complete trip, she formats the data in a special structure:

```
TRIP_DATA_START
{
    "destination": "Paris, France",
    "startDate": "2024-06-01",
    "endDate": "2024-06-08",
    "duration": 7,
    "budget": 2500.0,
    "interests": ["culture", "food", "history"],
    "activities": ["Visit Eiffel Tower", "Louvre Museum", "Seine River cruise"],
    "hotels": ["Hotel Plaza Athénée", "Le Meurice"],
    "restaurants": ["L'Astrance", "Le Comptoir du Relais"],
    "attractions": ["Eiffel Tower", "Louvre", "Notre-Dame"]
}
TRIP_DATA_END
```

This structured data is automatically parsed and converted into a `Trip` object that appears in the trip details screen.

## Step 7: Error Handling

The app includes comprehensive error handling for:

- **Invalid API Key**: Check your API key configuration
- **Rate Limiting**: Wait before making more requests
- **Network Issues**: Check your internet connection
- **Server Errors**: OpenAI service may be temporarily unavailable

Users can retry failed messages using the "Retry Last Message" option in the chat menu.

## Step 8: Cost Management

### Understanding OpenAI Pricing:
- **GPT-3.5-turbo**: ~$0.002 per 1K tokens
- **GPT-4**: ~$0.03 per 1K tokens
- **GPT-4-turbo**: ~$0.01 per 1K tokens

### Cost Optimization Tips:
1. Use `gpt-3.5-turbo` for most conversations
2. Set appropriate `max_tokens` limits
3. Monitor usage in your OpenAI dashboard
4. Consider implementing conversation limits for users

## Step 9: Production Considerations

Before releasing your app:

1. **API Key Security**: Never commit API keys to version control
2. **Rate Limiting**: Implement user-level rate limiting
3. **Error Monitoring**: Set up error tracking for API failures
4. **Usage Analytics**: Track API usage and costs
5. **Backup Responses**: Consider fallback responses for API failures

## Troubleshooting

### Common Issues:

1. **"Invalid API Key" Error**:
   - Verify your API key is correct
   - Check that the key has the necessary permissions
   - Ensure the key is properly configured

2. **"Rate Limit Exceeded" Error**:
   - Wait before making more requests
   - Consider upgrading your OpenAI plan
   - Implement request queuing

3. **"Network Error"**:
   - Check your internet connection
   - Verify the OpenAI API is operational
   - Check for firewall restrictions

4. **No Trip Suggestions**:
   - Ensure Luna's prompt includes trip formatting instructions
   - Check that the parsing logic is working correctly
   - Verify the conversation context is being maintained

### Debug Mode:
To enable debug logging, you can add print statements in `OpenAIService.swift`:

```swift
print("API Request: \(request)")
print("API Response: \(response)")
```

## Support

For additional help:
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [OpenAI Community Forum](https://community.openai.com/)
- [iOS Networking Best Practices](https://developer.apple.com/documentation/foundation/url_loading_system)

## Security Notes

- Never expose your API key in client-side code for production apps
- Consider using a backend proxy for API calls in production
- Monitor your API usage regularly
- Set up billing alerts in your OpenAI account

---

**Happy Travel Planning with Luna! 🦉✈️**
