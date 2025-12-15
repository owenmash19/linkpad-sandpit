import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func signUp(email: String, password: String, role: UserRole, displayName: String) async throws -> User {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let user = User(
            id: authResult.user.uid,
            email: email,
            role: role,
            displayName: displayName
        )
        
        do {
            try db.collection("users").document(authResult.user.uid).setData(from: user)
        } catch {
            // Rollback: delete the auth user if Firestore write fails
            try? await authResult.user.delete()
            throw error
        }
        
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        
        let userDoc = try await db.collection("users").document(authResult.user.uid).getDocument()
        guard let user = try? userDoc.data(as: User.self) else {
            throw NSError(domain: "AuthService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        return user
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() async throws -> User? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        let userDoc = try await db.collection("users").document(currentUser.uid).getDocument()
        return try? userDoc.data(as: User.self)
    }
}
