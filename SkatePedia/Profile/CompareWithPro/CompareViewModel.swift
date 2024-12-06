//
//  CompareViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation

/// Defines a class that contains functions for the 'CompareView'.
@MainActor
final class CompareViewModel: ObservableObject {
    
    @Published var proList = ["Shane O'Neill"]
    @Published var selectedPro = "Shane O'Neill"
    @Published var newNotes: String = ""
    
    @Published var pro: Pro? = nil
    @Published var proVideo: ProVideo? = nil
    
    /// Fetches all the professional skateboarders stored in the database
    func getProList() {
        
    }
    
    /// Fetches information about a pro in the database in a 'Pro' object. Queries the database using the pro's name.
    ///
    /// - Parameters:
    ///  - proName: The name of the professional skateboarder.
    ///
    /// - Returns: A 'Pro' object containing information about a pro.
    func getPro(proName: String) async throws -> Pro {
        let pro = try await ProVideoManager.shared.getPro(proName: proName)
        
        return pro
    }
    
    /// Fetches data about a professional's video for a specified trick.
    ///
    /// - Parameters:
    ///  - pro: A 'Pro' object containing information about a pro.
    ///  - trickItem: A 'TrickItem' object containing information about the trick item.
    ///
    /// - Returns: A 'ProVideo' object that contains information about a pro's video. 
    func getProVideo(pro: Pro, trickItem: TrickItem) async throws -> ProVideo {
        let proVideo = try await ProVideoManager.shared.getProVideo(proId: pro.id, trickId: trickItem.trickId!)
        
        return proVideo
    }
    
    func updateNotes(userId: String, trickItem: TrickItem) {
        if !newNotes.trimmingCharacters(in: .whitespaces).isEmpty &&
            newNotes != trickItem.notes {
            Task {
                do {
                    try await UserManager.shared.updateTrickItemNotes(
                        userId: userId,
                        trickItemId: trickItem.id,
                        newNotes: newNotes
                    )
                } catch {
                    print("ERROR: COULDNT UPDATE NOTES, \(error.localizedDescription)")
                }
            }
        }
    }
}
