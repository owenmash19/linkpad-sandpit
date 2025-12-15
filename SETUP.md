# LinkPad Setup Guide

This guide will help you set up the LinkPad iOS app for development.

## Prerequisites

- macOS with Xcode 15.0 or later installed
- An Apple Developer account (for running on physical devices)
- A Firebase account

## Step 1: Clone the Repository

```bash
git clone https://github.com/owenmash19/linkpad-sandpit.git
cd linkpad-sandpit
```

## Step 2: Firebase Project Setup

### 2.1 Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "LinkPad" (or your preferred name)
4. Follow the setup wizard to create your project

### 2.2 Add iOS App to Firebase

1. In your Firebase project, click the iOS icon to add an iOS app
2. Enter the bundle ID: `com.linkpad.LinkPad`
3. Enter app nickname: "LinkPad"
4. Download the `GoogleService-Info.plist` file

### 2.3 Replace Configuration File

1. Navigate to `LinkPad/LinkPad/` in your project directory
2. Replace the placeholder `GoogleService-Info.plist` with your downloaded file

**Important**: The placeholder file contains dummy values. You must replace it with your actual Firebase configuration.

### 2.4 Enable Firebase Services

In the Firebase Console, enable the following services:

#### Authentication
1. Go to Authentication → Sign-in method
2. Enable "Email/Password" provider
3. Save changes

#### Cloud Firestore
1. Go to Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location closest to your users
5. Click "Enable"

#### Firestore Security Rules (For Production)

Replace the test mode rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Messages - users can read messages they sent or received
    match /messages/{messageId} {
      allow read: if request.auth != null && 
                  (resource.data.senderId == request.auth.uid || 
                   resource.data.receiverId == request.auth.uid);
      allow create: if request.auth != null && 
                    request.resource.data.senderId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                           resource.data.senderId == request.auth.uid;
    }
    
    // Subscriptions - users can only read their own subscriptions
    match /subscriptions/{subscriptionId} {
      allow read: if request.auth != null && 
                  resource.data.userId == request.auth.uid;
      allow write: if request.auth != null && 
                   request.resource.data.userId == request.auth.uid;
    }
  }
}
```

#### Configure Message TTL (Time To Live)

To automatically delete messages after 24 hours:

1. Go to Firestore Database
2. Click on the `messages` collection
3. Click "Indexes" tab
4. Create a TTL policy on the `expiresAt` field

Alternatively, set up a Cloud Function to delete expired messages:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.deleteExpiredMessages = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const expiredMessages = await admin.firestore()
      .collection('messages')
      .where('expiresAt', '<=', now)
      .get();
    
    const batch = admin.firestore().batch();
    expiredMessages.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log(`Deleted ${expiredMessages.size} expired messages`);
  });
```

## Step 3: Open the Project in Xcode

```bash
cd LinkPad
open LinkPad.xcodeproj
```

## Step 4: Configure Signing

1. In Xcode, select the project in the navigator
2. Select the "LinkPad" target
3. Go to "Signing & Capabilities" tab
4. Select your development team
5. Xcode will automatically create a provisioning profile

## Step 5: Build and Run

1. Select a simulator or connected device from the scheme menu
2. Press ⌘R or click the "Run" button
3. The app should build and launch

## Initial Testing

### Test User Registration

1. Launch the app
2. Tap "Don't have an account? Sign Up"
3. Fill in the registration form
4. Select either "Poster" or "Tasker" role
5. Tap "Create Account"

### Test Login

1. Use the credentials you just created
2. Enter email and password
3. Tap "Sign In"
4. You should see the role-appropriate dashboard

## Troubleshooting

### Build Errors

**Error: "No such module 'FirebaseAuth'"**
- Solution: Wait for Swift Package Manager to finish downloading dependencies
- Try: Product → Clean Build Folder (⇧⌘K), then rebuild

**Error: "GoogleService-Info.plist not found"**
- Solution: Ensure you've added the Firebase configuration file to the project

### Runtime Errors

**Error: "Firebase configuration failed"**
- Check that GoogleService-Info.plist contains valid values
- Verify the bundle ID matches your Firebase project
- Check that all required Firebase services are enabled

**Error: "Authentication failed"**
- Verify Email/Password authentication is enabled in Firebase Console
- Check Firebase Console logs for detailed error messages

### Firestore Permission Errors

**Error: "Missing or insufficient permissions"**
- Verify Firestore security rules are correctly configured
- In development, ensure you're in "test mode"
- Check that the user is properly authenticated

## Development Workflow

### Running Tests

Currently, the project uses SwiftUI previews for component testing:
- Open any View file
- Click "Resume" on the preview canvas
- Use Xcode's interactive preview features

### Adding New Features

1. Create models in `Models/` directory
2. Add services in `Services/` directory
3. Create ViewModels in `ViewModels/` directory
4. Build Views in `Views/` directory
5. Update navigation in `ContentView.swift`

### Code Style

The project follows standard Swift/SwiftUI conventions:
- Use meaningful variable and function names
- Keep views small and focused
- Separate business logic into ViewModels
- Use Swift's built-in async/await for asynchronous operations

## Additional Configuration

### App Icons

1. Create app icons using an icon generator (1024x1024px)
2. Add them to `Assets.xcassets/AppIcon.appiconset/`

### Custom Colors

Add custom colors to `Assets.xcassets/AccentColor.colorset/`

### Localization

For multi-language support:
1. Add localization in project settings
2. Create `.strings` files for each language
3. Use `NSLocalizedString` in code

## Deployment

### TestFlight

1. Archive the app (Product → Archive)
2. Upload to App Store Connect
3. Distribute to TestFlight testers

### App Store

1. Complete app metadata in App Store Connect
2. Submit for review
3. Follow Apple's review guidelines

## Support

For issues or questions:
- Check the main [README.md](README.md)
- Open an issue in the GitHub repository
- Review Firebase documentation at [firebase.google.com](https://firebase.google.com)

## Security Notes

⚠️ **Important Security Considerations**:

1. **Never commit real Firebase credentials** to public repositories
2. **Use environment variables** for sensitive data in production
3. **Enable App Check** to prevent unauthorized API usage
4. **Implement proper Firestore security rules** before going to production
5. **Use HTTPS** for all API communications
6. **Validate all user inputs** on both client and server side
7. **Implement rate limiting** to prevent abuse
8. **Regular security audits** of Firebase rules and user permissions

## Next Steps

Once the app is running:

1. Test all authentication flows
2. Verify role-based UI rendering
3. Test messaging functionality
4. Review subscription plans
5. Customize UI to match your brand
6. Add additional features as needed

Happy coding! 🚀
