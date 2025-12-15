import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var receiverId: String
    var content: String
    var timestamp: Date
    var expiresAt: Date
    var isRead: Bool
    
    init(id: String? = nil, senderId: String, receiverId: String, content: String, timestamp: Date = Date(), expiresAt: Date? = nil, isRead: Bool = false) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
        self.timestamp = timestamp
        self.expiresAt = expiresAt ?? Calendar.current.date(byAdding: .hour, value: 24, to: timestamp) ?? timestamp
        self.isRead = isRead
    }
}
