import SwiftUI

struct MessagingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var messages: [Message] = []
    @State private var newMessageContent = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Limited & Ephemeral Messaging")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
                Text("Messages expire after 24 hours")
                    .font(.caption2)
                    .foregroundColor(.orange)
                
                List(messages) { message in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(message.senderId == authViewModel.currentUser?.id ?? "" ? "You" : "Other User")
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(message.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(message.content)
                            .font(.body)
                        
                        Text("Expires: \(message.expiresAt, style: .relative)")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 5)
                }
                
                if messages.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No messages yet")
                            .foregroundColor(.secondary)
                        Text("Start a conversation!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                HStack {
                    TextField("Type a message...", text: $newMessageContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(newMessageContent.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !newMessageContent.isEmpty, let currentUser = authViewModel.currentUser else { return }
        
        let message = Message(
            senderId: currentUser.id ?? "",
            receiverId: "placeholder",
            content: newMessageContent
        )
        
        messages.append(message)
        newMessageContent = ""
    }
}

#Preview {
    MessagingView()
        .environmentObject(AuthViewModel())
}
