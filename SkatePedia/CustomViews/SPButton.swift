//
//  SPButton.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI

/// Defines a custom button for use throughout the app.
///
/// - Parameters:
///  - title: The button's title.
///  - background: The button's background color.
///  - action: The tasks to execute when the button is clicked.
struct SPButton: View {
    let title: String
    let background: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            // Action
            action()
            
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)
                
                Text(title)
                    .foregroundColor(Color.white)
                    .bold()
            }
        }
        .padding()
    }
}
