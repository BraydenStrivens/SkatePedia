//
//  CompareView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI
import AVKit

/// Defines the layout of items in the 'CompareView'.
struct CompareView: View {
    
    let trickItem: TrickItem
    let userId: String
    
    @StateObject var viewModel = CompareViewModel()
    
    var body: some View {
        
        VStack {
            Text("Compare To A Pro")
                .font(.title)
            
            Form {
                // The user selects the pro
                Picker("Select a Pro", selection: $viewModel.selectedPro) {
                    ForEach(viewModel.proList, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                
                // The user can update their notes for the trick item
                Section("Change Notes") {
                    TextField(trickItem.notes ?? "Notes:", text: $viewModel.newNotes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...5)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
                
                // Update notes button
                HStack {
                    Spacer()
                    
                    SPButton(title: "Update", background: .green) {
                        viewModel.updateNotes(userId: userId, trickItem: trickItem)
                    }
                    
                    Spacer()
                }
                
                // Side by side video comparison
                Section("Compare") {
                    GeometryReader { proxy in
                        let userVideoPlayer = AVPlayer(url: URL(string: trickItem.videoUrl!)!)
                        
                        let size = CGSize(width: proxy.size.width * 0.45, height: proxy.size.height)
                        let safeArea = proxy.safeAreaInsets
                        
                        VStack(alignment: .center) {
                            HStack(alignment: .center) {
                                // User's video
                                SPVideoPlayer(userPlayer: userVideoPlayer, size: size, fullScreenSize: size, safeArea: safeArea, showButtons: true)
                                    .buttonStyle(.borderless)
                                Spacer()
                                
                                if viewModel.proVideo != nil {
                                    if viewModel.proVideo!.videoUrl != "N/A" {
                                        let proVideoPlayer = AVPlayer(url: URL(string: viewModel.proVideo!.videoUrl)!)
                                        
                                        // Pro's video
                                        SPVideoPlayer(userPlayer: proVideoPlayer, size: size, fullScreenSize: size, safeArea: safeArea, showButtons: true)
                                            .buttonStyle(.borderless)
                                    } else {
                                        Text("Video for this trick is not available for pro: \(viewModel.selectedPro)")
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                }
            }
        }
        .onAppear {
            Task {
                // Fetches data about the selected pro and the video for the specified trick
                do {
                    let pro = try await viewModel.getPro(proName: viewModel.selectedPro)

                    viewModel.proVideo = try await viewModel.getProVideo(pro: pro, trickItem: trickItem)
                    
//                    let videoUrl = try await StorageManager.shared.getProVideoUrl(proId: pro.id, trickId:      trickItem.trickId ?? "n/a")
//
//                    let proVideo: ProVideo = ProVideo(
//                        id: "",
//                        proName: pro.proName,
//                        proId: pro.id,
//                        trickName: trickItem.trickName ?? "no name",
//                        trickId: trickItem.trickId ?? "no trickId",
//                        videoUrl: videoUrl)
                    
//                    try await ProVideoManager.shared.uploadProVideoToDatabase(proVideo: proVideo)
                } catch {
                    print("DEBUG: COULDNT GET PRO VIDEO, \(error)")
                }
            }
        }
    }
}
