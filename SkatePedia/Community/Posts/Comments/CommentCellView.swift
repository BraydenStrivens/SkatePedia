//
//  CommentCellView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 12/2/24.
//

import SwiftUI

///  Defines the layout of a comment
///
///  - Parameters:
///    - comment: a comment object created from information from the database
struct CommentCellView: View {
    
    let comment: Comment
    
    @State private(set) var username: String = "n/a"
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    
                    HStack(alignment: .center) {
                        Text("@\(username)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text("\(DateFormat.dateFormatter.string(from: comment.dateCreated))")
                            .font(.title3)
                    }
                    
                    Text("\(comment.content)")
                        .font(.body)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                }
                .onAppear {
                    Task {
                        self.username = try await UserManager.shared.getUser(userId: comment.fromUserId).username!
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.gray.opacity(0.25))
                .stroke(Color.white)
        }
        .padding()
    }
}
