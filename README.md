# LinkPad - iOS Marketplace App

LinkPad is a subscription-based marketplace iOS app built with SwiftUI. It connects Posters (businesses) with Taskers (workers) through a streamlined platform.

## Features

- **User Roles**: Users can register as either a Poster (business) or Tasker (worker)
- **Role-Based UI**: The interface is conditionally rendered based on the user's role
- **Firebase Integration**: 
  - Firebase Authentication for secure user management
  - Cloud Firestore for data storage
- **Subscription System**: Multiple tier subscription plans (Free, Basic, Premium, Enterprise)
- **Messaging**: Limited and ephemeral messaging system (messages expire after 24 hours)
- **MVVM Architecture**: Clean separation of concerns following the Model-View-ViewModel pattern

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

### Models
- `User.swift` - User data model with role (Poster/Tasker)
- `Message.swift` - Message model with expiration support
- `Subscription.swift` - Subscription tier and management

### Views
- `ContentView.swift` - Main entry point, routes to role-specific views
- `LoginView.swift` - User authentication
- `RegistrationView.swift` - New user registration with role selection
- `PosterHomeView.swift` - Dashboard for business users
- `TaskerHomeView.swift` - Dashboard for worker users
- `MessagingView.swift` - Ephemeral messaging interface
- `SubscriptionView.swift` - Subscription plan management

### ViewModels
- `AuthViewModel.swift` - Manages authentication state and user session

### Services
- `AuthService.swift` - Firebase Authentication integration

## Project Structure

```
LinkPad/
├── LinkPad.xcodeproj/
└── LinkPad/
    ├── App/
    │   └── LinkPadApp.swift
    ├── Models/
    │   ├── User.swift
    │   ├── Message.swift
    │   └── Subscription.swift
    ├── Views/
    │   ├── ContentView.swift
    │   ├── LoginView.swift
    │   ├── RegistrationView.swift
    │   ├── PosterHomeView.swift
    │   ├── TaskerHomeView.swift
    │   ├── MessagingView.swift
    │   └── SubscriptionView.swift
    ├── ViewModels/
    │   └── AuthViewModel.swift
    ├── Services/
    │   └── AuthService.swift
    ├── Assets.xcassets/
    └── GoogleService-Info.plist
```

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Firebase account

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an iOS app to your Firebase project
3. Download the `GoogleService-Info.plist` file
4. Replace the placeholder `GoogleService-Info.plist` in the project with your actual file

### Firebase Configuration

Enable the following Firebase services in your console:
- **Authentication**: Enable Email/Password sign-in method
- **Cloud Firestore**: Create a database with the following collections:
  - `users` - User profiles
  - `messages` - Messages (with TTL for auto-deletion)
  - `subscriptions` - User subscriptions

### Running the App

1. Open `LinkPad.xcodeproj` in Xcode
2. Replace the placeholder `GoogleService-Info.plist` with your actual Firebase configuration
3. Select a target device or simulator
4. Build and run (⌘R)

## User Roles

### Poster (Business)
- Create job postings
- Manage job listings
- Review applications from Taskers
- Access to messaging and subscription features

### Tasker (Worker)
- Browse available jobs
- Submit applications
- Track application status
- Access to messaging and subscription features

## Subscription Tiers

- **Free**: Basic access, limited messaging, 5 posts/applications per month
- **Basic**: $9.99/month - Unlimited messaging, 20 posts/applications per month
- **Premium**: $29.99/month - Unlimited posts/applications, featured listings, analytics
- **Enterprise**: $99.99/month - Custom integrations, dedicated support, API access

## Security Features

- Secure authentication with Firebase Auth
- Password validation (minimum 6 characters)
- Email verification support
- Role-based access control

## Messaging System

The messaging system is designed to be limited and ephemeral:
- Messages automatically expire after 24 hours
- Stored in Firestore with expiration timestamps
- Visual indicators for message expiration time

## Dependencies

- Firebase iOS SDK (10.0.0+)
  - FirebaseAuth
  - FirebaseFirestore

## Development

### Building the Project
```bash
# Open in Xcode
open LinkPad/LinkPad.xcodeproj
```

### Testing
The app follows SwiftUI best practices with previews for each view component.

## Future Enhancements

- Push notifications for new messages and job updates
- In-app payment processing for subscriptions
- Advanced job filtering and search
- User ratings and reviews
- Photo uploads for job postings
- Real-time chat functionality

## License

This project is for demonstration purposes.

## Contact

For questions or support, please open an issue in the repository.