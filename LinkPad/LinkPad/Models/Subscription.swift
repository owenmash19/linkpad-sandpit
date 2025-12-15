import Foundation
import FirebaseFirestore

enum SubscriptionTier: String, Codable {
    case free = "free"
    case basic = "basic"
    case premium = "premium"
    case enterprise = "enterprise"
}

struct Subscription: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var tier: SubscriptionTier
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var autoRenew: Bool
    
    init(id: String? = nil, userId: String, tier: SubscriptionTier, startDate: Date = Date(), endDate: Date? = nil, isActive: Bool = true, autoRenew: Bool = false) {
        self.id = id
        self.userId = userId
        self.tier = tier
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.autoRenew = autoRenew
    }
}
