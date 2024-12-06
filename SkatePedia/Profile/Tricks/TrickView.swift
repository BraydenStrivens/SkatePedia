//
//  TrickView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI

/// Defines the layout for the trick item view. Contains a description of the trick and a list of the user's trick items.
///
/// - Parameters:
///  - userId: The id of an account in the database.
///  - trick: A 'JsonTrick' object containing information about a trick.
struct TrickView: View {
    
    var userId: String
    var trick: JsonTrick
    
    @StateObject var viewModel = TrickViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Trick description
            Section(header: Text("Description:").fontWeight(.bold)) {
                Text("\(trick.description)")
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray.opacity(0.25))
                            .stroke(.gray.opacity(0.5))
                    }
            }
            .padding(3)
            
            Spacer()
            
            // Displays a list of the user's trick items
            Section(header: Text("Trick Items:").fontWeight(.bold)) {
                List {
                    if viewModel.trickItems.isEmpty {
                        Text("No Items")
                            .font(.headline)
                    } else {
                        ForEach(viewModel.trickItems) { trickItem in
                            TrickItemCellView(userId: userId, trickItem: trickItem)
                        }
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray.opacity(0.25))
                        .stroke(.gray.opacity(0.5))
                }
            }
            .padding(3)
            
            Spacer()
        }
        .navigationTitle(trick.name)
        .padding()
        .onFirstAppear {
            viewModel.addListenerForTrickItems(userId: userId, trickId: trick.id)
        }
        .toolbar {
            NavigationLink(destination:
                            AddTrickItemView(userId: userId, trick: trick), label: {
                Text("Add")
                Image(systemName: "plus")
            })
        }
    }
}
