import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                switch user.role {
                case .poster:
                    PosterHomeView()
                case .tasker:
                    TaskerHomeView()
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
