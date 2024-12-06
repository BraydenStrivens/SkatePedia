//
//  ContentView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI

/// Defines the layout of items in the 'MainMenuView'.
struct MainView: View {
    @State private var showSignInView: Bool = false
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        
        // Verifies the user is signed in and has a valid userId
        if viewModel.isSignedIn && !viewModel.currentUserId.isEmpty {
            let _ = print("DEBUG: ID = \(viewModel.currentUserId)")
            // User is already signed in
            ZStack {
                // Shows the account view if logged in
                accountView
            }
            
        } else {
            // User is not signed in, shows the login view
            NavigationStack {
                LoginView(showSignInView: $showSignInView)
            }
        }
    }
    
    /// Defines the layout of items in the 'accountView'.
    @ViewBuilder
    var accountView: some View {
        // Creates a tab bar to navigate between 'Profile', 'Community', and 'Settings' views
        TabView {
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
            
            NavigationStack {
                CommunityView()
            }
            .tabItem {
                Label("Community", systemImage: "person.3.sequence.fill")
            }
            
            NavigationStack {
                SettingsView(showSignInView: $showSignInView)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}
