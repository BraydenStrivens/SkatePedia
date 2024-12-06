//
//  AddPostView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI
import PhotosUI

/// Defines the layout of the add post screen
///
/// - Parameters:
///     - userId: the id of the current user in the database
struct AddPostView: View {
    
    let userId: String
    
    @StateObject var viewModel = AddPostViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                
                Text("Add Post")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Section("Trick Name:") {
                TextField("Trick: ", text: $viewModel.trickName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray.opacity(0.25))
                            .stroke(.gray.opacity(0.5))
                    }
            }
            
            Section("Content:") {
                TextField("Content: ", text: $viewModel.content, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5, reservesSpace: true)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray.opacity(0.25))
                            .stroke(.gray.opacity(0.5))
                    }
            }
            
            Section("Video:") {
                HStack {
                    Spacer()
                    
                    if viewModel.selectedItem != nil {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.green)
                    } else {
                        PhotosPicker(selection: $viewModel.selectedItem,
                                     matching: .any(of: [.not(.images), .videos, .slomoVideos])) {
                            
                            Text("Add Video")
                            Image(systemName: "plus")
                        }
                                     .padding()
                                     .background {
                                         RoundedRectangle(cornerRadius: 10, style: .continuous)
                                             .fill(.gray.opacity(0.15))
                                             .stroke(.white)
                                     }
                    }
                    
                    Spacer()
                }
            }
            
            if !viewModel.errorMessage.isEmpty {
                HStack {
                    Spacer()
                    
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                    
                    Spacer()
                }
            }
            HStack {
                Spacer()
                
                SPButton(title: "Add Post", background: .green) {
                    
                    guard !viewModel.trickName.isEmpty else {
                        viewModel.errorMessage = "Empty Field: Trick name is required."
                        return
                    }
                    
                    guard !viewModel.content.isEmpty else {
                        viewModel.errorMessage = "Empty Field: Content is required."
                        return
                    }
                    
                    guard viewModel.selectedAVideo else {
                        viewModel.errorMessage = "No Video Added: Video is required."
                        return
                    }
                    
                    Task {
                        let postId = UUID().uuidString
                        
                        try await viewModel.addPost(userId: userId, postId: postId)
                    }
                    dismiss()
                }
                .frame(width: UIScreen.main.bounds.width * 0.5, height: 75)
                .padding()
                
                Spacer()
            }
        }
        Spacer()
    }
}
