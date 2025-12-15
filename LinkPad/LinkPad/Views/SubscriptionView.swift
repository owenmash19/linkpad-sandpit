import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTier: SubscriptionTier = .free
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Choose Your Plan")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    VStack(spacing: 15) {
                        SubscriptionCard(
                            tier: .free,
                            price: "Free",
                            features: ["Basic access", "Limited messaging", "5 job posts/applications per month"],
                            isSelected: selectedTier == .free,
                            action: { selectedTier = .free }
                        )
                        
                        SubscriptionCard(
                            tier: .basic,
                            price: "$9.99/month",
                            features: ["Unlimited messaging", "20 job posts/applications per month", "Priority support"],
                            isSelected: selectedTier == .basic,
                            action: { selectedTier = .basic }
                        )
                        
                        SubscriptionCard(
                            tier: .premium,
                            price: "$29.99/month",
                            features: ["Everything in Basic", "Unlimited job posts/applications", "Featured listings", "Advanced analytics"],
                            isSelected: selectedTier == .premium,
                            action: { selectedTier = .premium }
                        )
                        
                        SubscriptionCard(
                            tier: .enterprise,
                            price: "$99.99/month",
                            features: ["Everything in Premium", "Dedicated account manager", "Custom integrations", "API access"],
                            isSelected: selectedTier == .enterprise,
                            action: { selectedTier = .enterprise }
                        )
                    }
                    .padding()
                    
                    Button(action: {
                        // Subscribe action
                        dismiss()
                    }) {
                        Text("Subscribe to \(selectedTier.rawValue.capitalized)")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Subscriptions")
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
}

struct SubscriptionCard: View {
    let tier: SubscriptionTier
    let price: String
    let features: [String]
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(tier.rawValue.capitalized)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(price)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(feature)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(AuthViewModel())
}
