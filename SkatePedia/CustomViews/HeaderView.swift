//
//  HeaderView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI

/// Defines the layout of a view to be used throughout the app.
///
/// - Parameters:
///  - title: The title of the view.
///  - subtitle: The subtitle of the view.
///  - angle: The angle of the background rectangle.
///  - background: The color of the background rectangle.
struct HeaderView: View {
    let title: String
    let subtitle: String
    let angle: Double
    let background: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(background)
                .rotationEffect(Angle(degrees: angle))
                
            VStack {
                Text(title)
                    .foregroundColor(Color.white)
                    .bold()
                    .font(.system(size: 50))
                Text(subtitle)
                    .font(.system(size: 30))
                    .foregroundColor(Color.white)
            }
            .padding(.top, 80)
        }
        .frame(width: UIScreen.main.bounds.width * 3, height: 350)
        .offset(y: -150)
    }
}
