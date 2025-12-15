import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegistration = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("LinkPad")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Marketplace for Posters & Taskers")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Button(action: {
                Task {
                    await authViewModel.signIn(email: email, password: password)
                }
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(authViewModel.isLoading)
            
            Button(action: {
                showRegistration = true
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showRegistration) {
                RegistrationView()
            }
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
