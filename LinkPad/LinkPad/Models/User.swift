import Foundation
import FirebaseFirestore

enum UserRole: String, Codable {
    case poster = "poster"
    case tasker = "tasker"
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var role: UserRole
    var displayName: String
    var subscriptionId: String?
    var createdAt: Date
    var isActive: Bool
    
    init(id: String? = nil, email: String, role: UserRole, displayName: String, subscriptionId: String? = nil, createdAt: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.email = email
        self.role = role
        self.displayName = displayName
        self.subscriptionId = subscriptionId
        self.createdAt = createdAt
        self.isActive = isActive
    }
}
