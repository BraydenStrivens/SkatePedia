//
//  TrickItemView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI
import PhotosUI
import AVKit

/// Defines the layout of a trick item view that is displayed to the user.
///
/// - Parameters:
///  - trickItem: The 'TrickItem' object to be displayed to the user.
///  - userId: The id of an account in the database.
struct TrickItemView: View {

    let trickItem: TrickItem
    let userId: String
    
    @StateObject var viewModel = TrickItemViewModel()
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading) {
                // Notes sections
                Section("Notes:") {
                    VStack {
                        TextField(trickItem.notes ?? "Notes:", text: $viewModel.newNotes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...5)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray.opacity(0.25))
                            .stroke(.gray.opacity(0.5))
                    }
                }
                .padding(3)
                
                // Update notes button
                HStack {
                    Spacer()
                    
                    SPButton(title: "Update", background: .green) {
                        viewModel.updateTrickItemNotes(userId: userId, trickItem: trickItem)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.5, height: 75)
                    
                    
                    Spacer()
                }
                
                Spacer()
                
                // Displays the trick item's video
                GeometryReader { proxy in
                    let player = AVPlayer(url: URL(string: trickItem.videoUrl!)!)
                    let size = CGSize(width: proxy.size.width, height: proxy.size.height)
                    let safeArea = proxy.safeAreaInsets
                    
                    SPVideoPlayer(userPlayer: player, size: size, fullScreenSize: size, safeArea: safeArea, showButtons: true)
                        .ignoresSafeArea()
                        .scaledToFit()
                }
                .frame(height: 400)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray.opacity(0.25))
                        .stroke(.gray.opacity(0.5))
                }
                
                Spacer()
                
                // Navigates to the CompareView on button click
                NavigationLink(destination: CompareView(trickItem: trickItem, userId: userId), label: {
                    ZStack {
                        Rectangle()
                            .fill(.green)
                            .frame(height: 60)
                            .cornerRadius(20)
                            .padding()
                        Text("Compare with Pro")
                            .tint(Color.white)
                            .font(.headline)
                    }
                })
            }
        }
        .padding()
//        .navigationTitle("\(trickItem.trickName!)")
    }
}
