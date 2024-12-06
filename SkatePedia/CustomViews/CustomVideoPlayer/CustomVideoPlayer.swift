//
//  CustomVideoPlayer.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/30/24.
//

import SwiftUI
import AVKit

/// Defines a custom video player for use throughout the app.
///
/// - Parameters:
///  - player: An 'AVPlayer' object that contains the video url of the video to be displayed.
struct CustomVideoPlayer: UIViewControllerRepresentable {
    
    var player: AVPlayer
    
    /// Creates a player view controller
    ///
    /// - Returns: The player controller object.
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.allowsVideoFrameAnalysis = true
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}
