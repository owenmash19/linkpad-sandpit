# LinkPad Architecture Documentation

## Overview

LinkPad follows the **MVVM (Model-View-ViewModel)** architecture pattern, which provides a clean separation of concerns and makes the codebase maintainable and testable.

## Architecture Layers

### 1. Models (Data Layer)

Models represent the data structures used throughout the app. They are simple, immutable data containers that conform to Swift's `Codable` protocol for easy serialization with Firebase Firestore.

#### User Model
```swift
struct User: Identifiable, Codable {
    var id: String?
    var email: String
    var role: UserRole  // .poster or .tasker
    var displayName: String
    var subscriptionId: String?
    var createdAt: Date
    var isActive: Bool
}

enum UserRole: String, Codable {
    case poster = "poster"  // Business users
    case tasker = "tasker"  // Worker users
}
```

**Purpose**: Represents a user in the system with role-based differentiation.

**Firestore Collection**: `users`

**Key Fields**:
- `role`: Determines which UI the user sees
- `subscriptionId`: Links to the user's subscription
- `isActive`: Enables soft-delete functionality

#### Message Model
```swift
struct Message: Identifiable, Codable {
    var id: String?
    var senderId: String
    var receiverId: String
    var content: String
    var timestamp: Date
    var expiresAt: Date  // Auto-set to 24 hours from creation
    var isRead: Bool
}
```

**Purpose**: Represents ephemeral messages that automatically expire.

**Firestore Collection**: `messages`

**Key Features**:
- Messages expire after 24 hours (ephemeral)
- Limited to prevent spam
- Tracks read status

#### Subscription Model
```swift
struct Subscription: Identifiable, Codable {
    var id: String?
    var userId: String
    var tier: SubscriptionTier
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var autoRenew: Bool
}

enum SubscriptionTier: String, Codable {
    case free = "free"
    case basic = "basic"
    case premium = "premium"
    case enterprise = "enterprise"
}
```

**Purpose**: Manages user subscription levels and access control.

**Firestore Collection**: `subscriptions`

**Tiers**:
- **Free**: Basic features, limited usage
- **Basic**: More features, reasonable limits
- **Premium**: Advanced features, unlimited usage
- **Enterprise**: All features, dedicated support

### 2. Services (Business Logic Layer)

Services handle communication with external systems (Firebase) and contain business logic that doesn't belong in ViewModels or Views.

#### AuthService
```swift
class AuthService {
    static let shared = AuthService()  // Singleton pattern
    
    func signUp(email: String, password: String, role: UserRole, displayName: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() throws
    func getCurrentUser() async throws -> User?
}
```

**Purpose**: Handles all Firebase Authentication operations and user management.

**Key Features**:
- Uses async/await for modern Swift concurrency
- Singleton pattern for shared access
- Integrates Firebase Auth with Firestore for user profiles

**Flow**:
1. Sign up creates Firebase Auth user
2. Creates corresponding Firestore user document
3. Sign in authenticates and retrieves user data
4. Sign out clears Firebase Auth session

### 3. ViewModels (Presentation Logic Layer)

ViewModels act as the bridge between Views and Models/Services. They contain presentation logic, state management, and coordinate data flow.

#### AuthViewModel
```swift
@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func signUp(email: String, password: String, role: UserRole, displayName: String) async
    func signIn(email: String, password: String) async
    func signOut()
    func checkAuthStatus() async
}
```

**Purpose**: Manages authentication state and provides UI-friendly methods.

**Key Features**:
- `@MainActor` ensures UI updates happen on main thread
- `@Published` properties automatically update SwiftUI views
- `ObservableObject` enables reactive programming
- Handles loading states and error messages

**State Management**:
- `currentUser`: The logged-in user's data
- `isAuthenticated`: Quick check for auth status
- `errorMessage`: User-friendly error messages
- `isLoading`: Shows loading indicators

### 4. Views (Presentation Layer)

Views are SwiftUI components that display UI and respond to user interactions. They are declarative and automatically update when observed data changes.

#### View Hierarchy

```
ContentView (Root)
├── LoginView
├── RegistrationView
├── PosterHomeView (for business users)
│   ├── Job Management
│   ├── MessagingView
│   └── SubscriptionView
└── TaskerHomeView (for workers)
    ├── Job Browser
    ├── MessagingView
    └── SubscriptionView
```

#### ContentView (Router)
```swift
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
            switch user.role {
            case .poster: PosterHomeView()
            case .tasker: TaskerHomeView()
            }
        } else {
            LoginView()
        }
    }
}
```

**Purpose**: Routes users to appropriate views based on authentication and role.

**Conditional Rendering**:
- Not authenticated → LoginView
- Authenticated + Poster → PosterHomeView
- Authenticated + Tasker → TaskerHomeView

#### LoginView & RegistrationView
**Purpose**: Handle user authentication and account creation.

**Features**:
- Email/password validation
- Role selection during registration
- Error display
- Loading states

#### PosterHomeView & TaskerHomeView
**Purpose**: Role-specific dashboards with tailored features.

**Poster Features**:
- Create job postings
- Manage listings
- Review applications
- Messaging
- Subscription management

**Tasker Features**:
- Browse jobs
- Submit applications
- Track status
- Messaging
- Subscription management

#### MessagingView
**Purpose**: Limited, ephemeral messaging system.

**Features**:
- 24-hour message expiration
- Visual expiration countdown
- Read receipts
- Simple chat interface

#### SubscriptionView
**Purpose**: Display and manage subscription plans.

**Features**:
- Tiered pricing display
- Feature comparison
- Subscription selection
- Upgrade/downgrade options

## Data Flow

### Authentication Flow

```
User Action (Login) 
    → LoginView 
    → AuthViewModel.signIn() 
    → AuthService.signIn() 
    → Firebase Auth 
    → Firestore User Data 
    → AuthViewModel.currentUser 
    → ContentView (automatic update) 
    → Role-based View
```

### Role-Based Rendering Flow

```
User Logs In 
    → AuthViewModel fetches User 
    → ContentView observes currentUser.role 
    → SwiftUI conditionally renders:
        • Poster → PosterHomeView
        • Tasker → TaskerHomeView
```

### Message Creation Flow

```
User Types Message 
    → MessagingView 
    → Create Message Model (with expiresAt = now + 24h) 
    → Save to Firestore 
    → Firestore TTL/Cloud Function deletes after expiration
```

## Design Patterns

### 1. Singleton Pattern
Used in `AuthService` to ensure a single shared instance:
```swift
class AuthService {
    static let shared = AuthService()
    private init() {}
}
```

### 2. Observer Pattern
SwiftUI's `@Published` and `ObservableObject` implement the Observer pattern:
```swift
@Published var currentUser: User?
```
Views automatically re-render when published properties change.

### 3. Dependency Injection
ViewModels are injected into views via `@EnvironmentObject`:
```swift
@EnvironmentObject var authViewModel: AuthViewModel
```

### 4. Repository Pattern
Services act as repositories, abstracting data source details:
```swift
AuthService handles both Firebase Auth and Firestore
```

## State Management

### Local State
Use `@State` for view-local state:
```swift
@State private var email = ""
@State private var showRegistration = false
```

### Shared State
Use `@EnvironmentObject` for app-wide state:
```swift
@EnvironmentObject var authViewModel: AuthViewModel
```

### Published State
Use `@Published` in ViewModels for reactive updates:
```swift
@Published var errorMessage: String?
```

## Error Handling

### Service Layer
Services throw errors that ViewModels catch:
```swift
func signIn() async throws -> User {
    // Throws error if authentication fails
}
```

### ViewModel Layer
ViewModels catch errors and convert to user-friendly messages:
```swift
do {
    currentUser = try await authService.signIn(...)
} catch {
    errorMessage = error.localizedDescription
}
```

### View Layer
Views display errors from ViewModels:
```swift
if let error = authViewModel.errorMessage {
    Text(error).foregroundColor(.red)
}
```

## Concurrency

### Async/Await
Modern Swift concurrency for asynchronous operations:
```swift
func signIn() async {
    currentUser = try await authService.signIn(...)
}
```

### MainActor
Ensures UI updates on main thread:
```swift
@MainActor
class AuthViewModel: ObservableObject { ... }
```

### Task
Launch async work from synchronous context:
```swift
Button("Sign In") {
    Task {
        await authViewModel.signIn(...)
    }
}
```

## Security Architecture

### Firebase Security Rules
Protect data at the database level:
```javascript
match /users/{userId} {
    allow read, write: if request.auth.uid == userId;
}
```

### Client-Side Validation
Validate inputs before sending to server:
```swift
guard password.count >= 6 else {
    errorMessage = "Password too short"
    return
}
```

### Role-Based Access
UI conditionally rendered based on verified user role:
```swift
switch user.role {
case .poster: // Show poster UI
case .tasker: // Show tasker UI
}
```

## Scalability Considerations

### Current Architecture
- Single ViewModels for auth and user state
- Direct Firebase integration
- Client-side business logic

### Future Enhancements

1. **Additional ViewModels**
   - JobViewModel (for job postings)
   - MessageViewModel (for message management)
   - SubscriptionViewModel (for subscription logic)

2. **Service Expansion**
   - FirestoreService (generic database operations)
   - StorageService (file uploads)
   - AnalyticsService (usage tracking)

3. **Offline Support**
   - Firestore persistence enabled
   - Local cache for offline viewing
   - Sync when connectivity restored

4. **Testing**
   - Unit tests for ViewModels
   - Mock services for testing
   - UI tests for critical flows

## Code Organization Best Practices

### File Structure
```
LinkPad/
├── App/           # App entry point
├── Models/        # Data structures
├── Views/         # UI components
├── ViewModels/    # Presentation logic
├── Services/      # Business logic & API
└── Utilities/     # Helper functions (future)
```

### Naming Conventions
- Models: Nouns (User, Message, Subscription)
- Views: Descriptive + View suffix (LoginView, PosterHomeView)
- ViewModels: Descriptive + ViewModel suffix (AuthViewModel)
- Services: Descriptive + Service suffix (AuthService)

### Code Style
- Use SwiftUI previews for rapid development
- Keep views small and focused (single responsibility)
- Extract reusable components (SubscriptionCard)
- Use meaningful variable names
- Add comments for complex logic

## Firebase Integration

### Collections Structure
```
Firestore
├── users/
│   └── {userId}
│       ├── email
│       ├── role
│       ├── displayName
│       └── ...
├── messages/
│   └── {messageId}
│       ├── senderId
│       ├── receiverId
│       ├── content
│       ├── expiresAt
│       └── ...
└── subscriptions/
    └── {subscriptionId}
        ├── userId
        ├── tier
        ├── startDate
        └── ...
```

### Authentication Flow
1. Firebase Auth creates user account
2. UID used as Firestore document ID
3. User profile stored in Firestore
4. Authentication state synced automatically

## Performance Optimization

### Current Optimizations
- Lazy loading of views
- Efficient SwiftUI body updates
- Minimal data fetching
- Firestore indexing ready

### Future Optimizations
- Pagination for large lists
- Image caching
- Background data refresh
- Firestore query optimization

## Conclusion

The LinkPad architecture is designed to be:
- **Scalable**: Easy to add new features
- **Maintainable**: Clear separation of concerns
- **Testable**: Mockable services and ViewModels
- **Secure**: Firebase security rules and validation
- **Modern**: Uses latest Swift and SwiftUI features

This architecture provides a solid foundation for a production-ready marketplace application while remaining simple enough for rapid development and iteration.
