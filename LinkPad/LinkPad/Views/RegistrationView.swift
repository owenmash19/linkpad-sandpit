import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var selectedRole: UserRole = .tasker
    @State private var showError = false
    @State private var localError = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Display Name", text: $displayName)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                
                Section(header: Text("Password")) {
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                Section(header: Text("Select Your Role")) {
                    Picker("Role", selection: $selectedRole) {
                        Text("Tasker (Worker)").tag(UserRole.tasker)
                        Text("Poster (Business)").tag(UserRole.poster)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if selectedRole == .poster {
                        Text("As a Poster, you can create job listings and hire Taskers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("As a Tasker, you can browse and apply for jobs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if showError {
                    Section {
                        Text(localError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if let error = authViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: {
                        registerUser()
                    }) {
                        if authViewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(authViewModel.isLoading)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func registerUser() {
        showError = false
        localError = ""
        
        guard !displayName.isEmpty else {
            localError = "Please enter a display name"
            showError = true
            return
        }
        
        guard !email.isEmpty else {
            localError = "Please enter an email"
            showError = true
            return
        }
        
        guard !password.isEmpty else {
            localError = "Please enter a password"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            localError = "Passwords do not match"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            localError = "Password must be at least 6 characters"
            showError = true
            return
        }
        
        Task {
            await authViewModel.signUp(email: email, password: password, role: selectedRole, displayName: displayName)
            if authViewModel.isAuthenticated {
                dismiss()
            }
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}
