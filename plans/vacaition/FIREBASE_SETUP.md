# Firebase Setup Guide for Vaication App

This guide will help you set up Firebase Authentication and Firestore for your Vaication app.

## Prerequisites

1. A Firebase project (create one at [Firebase Console](https://console.firebase.google.com/))
2. Xcode with iOS development capabilities
3. CocoaPods installed (if not already installed)

## Step 1: Install Firebase Dependencies

1. Navigate to your project directory in Terminal
2. Initialize CocoaPods if not already done:
   ```bash
   pod init
   ```

3. Add Firebase dependencies to your `Podfile`:
   ```ruby
   # Uncomment the next line to define a global platform for your project
   platform :ios, '15.0'

   target 'vacaition' do
     # Comment the next line if you don't want to use dynamic frameworks
     use_frameworks!

     # Pods for vacaition
     pod 'Firebase/Auth'
     pod 'Firebase/Firestore'
     pod 'Firebase/Core'

   end
   ```

4. Install the dependencies:
   ```bash
   pod install
   ```

5. **Important**: From now on, always open the `.xcworkspace` file instead of `.xcodeproj`

## Step 2: Configure Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Add an iOS app to your project:
   - Click "Add app" and select iOS
   - Enter your bundle identifier (found in your Xcode project settings)
   - App nickname: "Vaication"
   - App Store ID: Leave blank for now

## Step 3: Download Configuration File

1. Download the `GoogleService-Info.plist` file from the Firebase Console
2. **Important**: Add this file to your Xcode project:
   - Drag the file into your Xcode project navigator
   - Make sure "Copy items if needed" is checked
   - Make sure your app target is selected
   - Click "Add"

## Step 4: Enable Authentication

1. In the Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication:
   - Click on "Email/Password"
   - Toggle "Enable" for the first option
   - Click "Save"

## Step 5: Set Up Firestore Database

1. In the Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database (choose one close to your users)
5. Click "Done"

## Step 6: Configure Firestore Security Rules

For development, you can use these permissive rules. **Remember to make them more restrictive for production!**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

To update these rules:
1. Go to Firestore Database in Firebase Console
2. Click on "Rules" tab
3. Replace the default rules with the above
4. Click "Publish"

## Step 7: Test the Setup

1. Build and run your app in Xcode
2. You should see the authentication screen
3. Try creating a new account with email/password
4. After successful signup, you should be taken to the main app

## Step 8: Production Considerations

Before releasing your app:

1. **Update Firestore Rules**: Make them more restrictive based on your needs
2. **Enable App Check**: For additional security
3. **Set up Analytics**: Optional but recommended
4. **Configure App Store Connect**: Add your App Store ID in Firebase Console

## Troubleshooting

### Common Issues:

1. **Build Errors**: Make sure you're opening the `.xcworkspace` file, not `.xcodeproj`
2. **Authentication Not Working**: Verify that Email/Password is enabled in Firebase Console
3. **Firestore Permission Denied**: Check your Firestore security rules
4. **Configuration File Missing**: Ensure `GoogleService-Info.plist` is properly added to your Xcode project

### Useful Firebase Console Sections:

- **Authentication > Users**: View registered users
- **Firestore Database > Data**: View stored user data
- **Authentication > Sign-in method**: Configure authentication providers
- **Project Settings**: Update app configuration

## Features Implemented

✅ Email/Password Authentication
✅ User Registration and Login
✅ Password Reset
✅ User Data Persistence in Firestore
✅ Sign Out Functionality
✅ UI Matching App Theme
✅ Error Handling and Loading States

## Next Steps

Consider adding these features:
- Social authentication (Google, Apple)
- Email verification
- Password strength requirements
- User profile pictures
- Offline support
- Push notifications

For more information, visit the [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup).
