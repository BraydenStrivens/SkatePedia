//
//  CommunityView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI

/// Defines the layout of items in the 'CommunityView'.
struct CommunityView: View {
    
    @StateObject var viewModel = CommunityViewModel()
    
    @State private var selectedView: String = "Community Posts"
    @State private var filterUserOnly: Bool = false
    @State private var didAppear: Bool = false
    
    var body: some View {
        if viewModel.user != nil {
            
            ScrollView() {
                
                VStack(spacing: 20) {
                    ForEach(viewModel.posts, id: \.id) { post in
                        ViewPostView(post: post)
                        
//                        if post == viewModel.posts.last! {
//                            ProgressView()
//                                .onAppear {
//                                   viewModel.addListenerForPosts(userId: viewModel.user!.userId,
//                                                                  filterUserOnly: viewModel.filterUserOnly)
//                                    viewModel.getPosts()
//                                }
//                        }
                    }
                    
                    
                }
                .padding()
                .navigationTitle("Community")
                .onFirstAppear {
                    viewModel.addListenerForPosts(userId: viewModel.user!.userId,
                                                  filterUserOnly: filterUserOnly)
//                    viewModel.getPosts()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu("\(viewModel.selectedFilter)") {
                            ForEach(viewModel.filterOptions, id: \.self) { option in
                                Button(option) {
                                    viewModel.toggleFilterUserOnly()
                                }
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: AddPostView(userId: viewModel.user!.userId)) {
                            Text("Add Post")
                        }
                    }
                }
            }
        }
    }
}
