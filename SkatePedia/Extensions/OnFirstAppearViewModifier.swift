//
//  OnFirstAppearViewModifier.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/29/24.
//

import Foundation
import SwiftUI

/// Creates a modifier for 'View' objects.
struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let perform: (() -> Void)?
    
    func body(content: Content) -> some View {
        content.onAppear {
            if !didAppear {
                perform?()
                didAppear = true
            }
        }
    }
}

extension View {
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: perform))
    }
}
