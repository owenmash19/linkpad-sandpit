import SwiftUI

struct PosterHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSubscription = false
    @State private var showMessaging = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = authViewModel.currentUser {
                    Text("Welcome, \(user.displayName)!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Poster Dashboard")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 15) {
                        NavigationLink(destination: Text("Create Job Posting")) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Create New Job")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: Text("My Job Postings")) {
                            HStack {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.title2)
                                Text("My Job Postings")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showMessaging = true
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                    .font(.title2)
                                Text("Messages")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .sheet(isPresented: $showMessaging) {
                            MessagingView()
                        }
                        
                        Button(action: {
                            showSubscription = true
                        }) {
                            HStack {
                                Image(systemName: "star.circle.fill")
                                    .font(.title2)
                                Text("Subscription")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .sheet(isPresented: $showSubscription) {
                            SubscriptionView()
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Poster Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PosterHomeView()
        .environmentObject(AuthViewModel())
}
