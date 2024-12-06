//
//  CommentsView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/28/24.
//

import SwiftUI
import FirebaseAuth

/// Defines the layout for items in the comment section of each point.
///
/// - Parameters:
///  - postId: the id of the post in the database.
struct CommentsView: View {
    
    let postId: String
    
    @StateObject var viewModel = CommentsViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView {
                if viewModel.comments.isEmpty {
                    
                    VStack(alignment: .center) {
                        Spacer()
                        HStack(alignment: .center) {
                            Spacer()
                            Text("No Comments")
                            Spacer()
                        }
                        Spacer()
                    }
                }
                ForEach(viewModel.comments, id: \.id) { comment in
                    CommentCellView(comment: comment)
                }
            }
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .stroke(Color.gray.opacity(0.4))
            }
            
            TextField("Comment:", text: $viewModel.comment)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...5)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray.opacity(0.25))
                        .stroke(.gray.opacity(0.5))
                }
            
            HStack(alignment: .center) {
                Spacer()
                
                Button {
                    let comment: Comment = Comment(
                        id: UUID().uuidString,
                        postId: postId,
                        fromUserId: Auth.auth().currentUser?.uid ?? "COULDNT GET USER ID",
                        content: viewModel.comment,
                        dateCreated: Date())
                    
                    if !viewModel.comment.isEmpty {
                        Task {
                            try await viewModel.addComment(comment: comment)
                        }
                    
                        viewModel.comment = ""
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            viewModel.getComments(postId: postId)
                        }
                    }
                } label: {
                    Text("Add Comment")
                }
                .padding()
                .foregroundColor(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.green)
                }
                Spacer()
            }
            Spacer()
        }
        .onAppear {
            viewModel.getComments(postId: postId)
        }
    }
}
