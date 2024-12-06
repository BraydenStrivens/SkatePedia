//
//  ProfileView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI

/// Defines the layout of the profile view. Contains the list of tricks to add trick items to.
struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    // Decodes the Json file into JsonTrick objects
    private let trickSection = Bundle.main.decode([JsonMenuItem].self, from: "TrickList.json")

    var body: some View {
        
        VStack {
            List {
                if let user = viewModel.user {
                    ForEach(trickSection) { section in
                        
                        Section(section.name) {
                            ForEach(section.items) { trick in
                                
                                NavigationLink(destination:
                                                TrickView(userId: user.userId, trick: trick), label: {
                                    TrickCell(trick: trick)
                                })
                            }
                        }
                    }
                } else {
                    Text("Loading...")
                }
            }
        }
        .navigationTitle("Trick List")
    }
}

struct TrickCell: View {
    var trick: JsonTrick
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(trick.name)
                    .font(.headline)
                
                Text("Learn First: \(trick.tricksToLearnFirst)")
                    .font(.footnote)
            }
        }
    }
}
