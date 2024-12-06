//
//  SettingsView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI
import FirebaseAuth

/// Defines the layout of items in the 'SettingsView'
struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @Binding var showSignInView: Bool
    
    @State private var toggleUpdatePassword: Bool = false
    @State private var toggleDeleteAccountVerifyer: Bool = false
    @State private var errorMessage: String = ""
    @State private var newPassword: String = ""
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            if let user = viewModel.user {
                // Displays information about the user
                VStack(alignment: .leading, spacing: 10) {
                    Section("Info") {
                        VStack {
                            Text("Email: \(String(describing: user.email!))")
                            Text("Username: \(String(describing: user.username!))")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.gray.opacity(0.25))
                                .stroke(.gray.opacity(0.5))
                        }
                    }
                    .padding(3)
                }
                .padding()
                
                List {
                    // Log out button
                    Section(header: Text("Log Out").fontWeight(.bold)) {
                        Button("Log out") {
                            Task {
                                do {
                                    try viewModel.signOut()
                                    showSignInView = true
                                } catch {
                                    print("DEBUG: COULDNT SIGN OUT, \(error)")
                                }
                            }
                        }
                    }
                    .padding(3)
                    
                    Section(header: Text("Manage Account").fontWeight(.bold)) {
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        
                        Button("Update Password") {
                            toggleUpdatePassword.toggle()
                        }
                        .alert("Update Password", isPresented: $toggleUpdatePassword) {
                            updatePasswordPopupView
                        } message: {
                            Text("Enter new password.")
                        }
                        
                        Button(role: .destructive) {
                            toggleDeleteAccountVerifyer.toggle()
                        } label: {
                            Text("Delete Account")
                        }
                        .alert("Delete Account", isPresented: $toggleDeleteAccountVerifyer) {
                            verifyDeleteAccountPopup
                        } message: {
                            Text("Are you SURE you want to delete your account? All data and videos will be permenantly deleted...")
                        }
                    }
                }
            }  else {
                Text("Loading...")
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Settings")
    }
    
    @ViewBuilder
    var updatePasswordPopupView: some View {
        TextField("New Password", text: $newPassword)
            .autocorrectionDisabled()
            .autocapitalization(.none)
        
        Button("Cancel") {
            toggleUpdatePassword.toggle()
        }
        
        Button("Update") {
            Task {
                do {
                    try await viewModel.updatePassword(password: newPassword)
                    errorMessage = ""
                } catch {
                    print("DEBUG: PASSWORD NOT CHANGED, \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    @ViewBuilder
    var verifyDeleteAccountPopup: some View {
        Button("Delete", role: .destructive) {
            Task {
                do {
                    try await viewModel.deleteUser(userId: viewModel.user!.userId)
                    showSignInView = true
                } catch {
                    errorMessage = error.localizedDescription
                    print("DEBUG: COULDNT DELETE USER \(error.localizedDescription)")
                }
            }
        }
    }
    
}
