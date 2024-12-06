//
//  TrickItemCellView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/13/24.
//

import SwiftUI

/// Defines the layout of a trick item cell in the TrickItemView
///
/// - Parameters:
///  - userId: The id of an account in the database
///  - trickItem: A 'TrickItem' object containing information about the trick item being displayed.
struct TrickItemCellView: View {
    
    let userId: String
    let trickItem: TrickItem
    
    var body: some View {
        NavigationLink(destination: TrickItemView(trickItem: trickItem, userId: userId)) {
            HStack(alignment: .center, spacing: 12) {
                VStack(spacing: 5) {
                    Text("Rating:")
                        .font(.footnote)
                        .fontWeight(.bold)
                    HStack {
                        ForEach(1...3, id: \.self) { number in
                            let isFilled = trickItem.progress! >= number
                            Image(systemName: isFilled ? "star.fill" : "star")
                                .foregroundColor(isFilled ? .yellow : .white)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 5) {
                    Text("Added:")
                        .font(.footnote)
                        .fontWeight(.bold)
                    Text("\(DateFormat.dateFormatter.string(from: trickItem.dateCreated!))")
                }
            }
            .contextMenu {
                Button(role: .destructive) {
                    Task {
                        try await UserManager.shared.deleteTrickItem(userId: userId, trickItemId: trickItem.id)
                    }
                } label: {
                    Text("Delete")
                    Image(systemName: "trash")
                }
            }
        }
        .padding()
        .cornerRadius(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.gray.opacity(0.25))
                .stroke(Color.gray.opacity(0.5))
        }
    }
}
