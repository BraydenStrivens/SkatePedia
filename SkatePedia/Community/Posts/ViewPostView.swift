//
//  ViewPostView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI
import AVKit
import PhotosUI
import FirebaseAuth

/// Defines the layout of items in a post.
///
/// - Parameters:
///  - post: A 'Post' object containing information about the post.
struct ViewPostView: View {
    
    @StateObject var viewModel = ViewPostViewModel()
    
    @State private var showAddComment = false
    @State private var commentContent = ""
    
    let post: Post
    let currentUserId = Auth.auth().currentUser!.uid
    
    var body: some View {
        GeometryReader { outerProxy in
            VStack(alignment: .leading) {
                // Header: Contains username and date posts
                HStack(alignment: .center) {
                    Text("@\(viewModel.postUsername)")
                        .padding(1)
                        .font(.title3)
                    
                    Spacer()
                    
                    Text("\(DateFormat.dateFormatter.string(from: post.dateCreated))")
                }
                .padding()
                .frame(width: outerProxy.size.width, height: outerProxy.size.height * 0.1)
                .background {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .stroke(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                }
                
                // Body 1: Contains video player, like and comment buttons, and delete button only available to poster
                HStack(alignment: .center) {
                    HStack(alignment: .center) {
                        let player = AVPlayer(url: URL(string: post.videoUrl!)!)
                        
                        let size = CGSize(width: outerProxy.size.width * 0.75, height: outerProxy.size.height * 0.5)
                        
                        let fullScreenSize = CGSize(width: outerProxy.size.width, height: outerProxy.size.height)
                        
                        let safeArea = outerProxy.safeAreaInsets
                        
                        SPVideoPlayer(userPlayer: player, size: size, fullScreenSize: fullScreenSize, safeArea: safeArea, showButtons: true)
                    }
                    .frame(height: outerProxy.size.height * 0.5)
                    
                    VStack(alignment: .center) {
                        Spacer()
                        
                        Text("\(viewModel.numberOfLikes)")
                            .font(.footnote)
                            .ignoresSafeArea()
                        Button {
                            viewModel.addLike(postId: post.id)
                        } label: {
                            Image(systemName: "heart")
                                .foregroundColor(Color.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Spacer()
                        
                        Text("\(viewModel.numberOfComments)")
                            .font(.footnote)
                            .ignoresSafeArea()
                        
                        NavigationLink(destination: CommentsView(postId: post.id)) {
                            Image(systemName: "message")
                                .foregroundColor(Color.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Spacer()
                        
                        if (currentUserId == post.userId) {
                            Button {
                                PostManager.shared.deletePost(postId: post.id)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .foregroundColor(.red)
                            .buttonStyle(.borderless)
                            .font(Font.system(.body).weight(.bold))
                            .frame(width: 20, height: 20)
                        }
                        
                        Spacer()
                    }
                    .frame(width: outerProxy.size.width * 0.2)
                }
                .padding()
                .frame(width: outerProxy.size.width, height: outerProxy.size.height * 0.5)
                
                // Body 2: Contains trick name and the post's content
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(post.trick)
                            .padding(.vertical, 1)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(post.notes)
                            .padding(.vertical, 1)
                            .font(.body)
                    }
                    .padding()
                    .frame(width: outerProxy.size.width * 0.95, height: outerProxy.size.height * 0.35)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.gray.opacity(0.3))
                            .stroke(Color.gray.opacity(0.5))
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(width: outerProxy.size.width, height: outerProxy.size.height * 0.35)
                
            }
            .task {
                do {
                    try await viewModel.postUsername = viewModel.getUsername(userId: post.userId)
                    try await viewModel.getNumberOfLikes(postId: post.id)
                    try await viewModel.getNumberOfComments(postId: post.id)
                } catch {
                    print("\(error)")
                }
            }
        }
        .frame(height: 500)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.gray.opacity(0.15))
                .stroke(.white)
        }
    }
}
