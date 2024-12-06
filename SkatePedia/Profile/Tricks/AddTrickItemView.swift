//
//  AddTrickItemView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI
import PhotosUI
import AVKit

/// Defines the layout of items in the 'AddTrickItem' view.
///
/// - Parameters:
///  - userId: The id of an account in the database.
///  - trick: A 'JsonTrick' object containing data about the trick the trick item is for.
struct AddTrickItemView: View {
    
    let userId: String
    let trick: JsonTrick
    
    @StateObject var viewModel = AddTrickItemViewModel()
    
    @State var fillStars = [false, false, false]
    @State private var videoThumbnail: UIImage?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            // Notes section
            Section(header: Text("Notes").fontWeight(.bold)) {
                TextField("", text: $viewModel.notes, axis: .vertical)
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
            }
            
            Spacer()
            
            // Rate Progress Section
            Section(header: Text("Progress").fontWeight(.bold)) {
                HStack() {
                    Spacer()
                    
                    Button {
                        fillStars[0] = !fillStars[0]
                        fillStars[1] = false
                        fillStars[2] = false
                    } label: {
                        Image(systemName: fillStars[0]  ? "star.fill" : "star")
                            .foregroundColor(fillStars[0] ? .yellow : .white)
                    }
                    
                    Button {
                        fillStars[0] = true
                        fillStars[1] = !fillStars[1]
                        fillStars[2] = false
                    } label: {
                        Image(systemName: fillStars[1]  ? "star.fill" : "star")
                            .foregroundColor(fillStars[1] ? .yellow : .white)
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    
                    Button {
                        fillStars[0] = true
                        fillStars[1] = true
                        fillStars[2] = !fillStars[2]
                    } label: {
                        Image(systemName: fillStars[2]  ? "star.fill" : "star")
                            .foregroundColor(fillStars[2] ? .yellow : .white)
                    }
                    
                    Spacer()
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray.opacity(0.25))
                        .stroke(.gray.opacity(0.5))
                }
                
            }
            
            Spacer()
            
            // Add user video
            Section(header: Text("Add Video").fontWeight(.bold)) {
                VStack(alignment: .center) {
                    if viewModel.selectedItem != nil {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.green)
                    } else {
                        PhotosPicker(selection: $viewModel.selectedItem,
                                     matching: .any(of: [.not(.images), .videos, .slomoVideos])) {
                            Text("Add")
                                .foregroundColor(.white)
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.green.opacity(0.5))
                        .stroke(.green.opacity(1))
                }
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(Color.red)
            }
            
            Spacer()
            
            // Add trick item button
            SPButton(title: "Add Item", background: .green) {
                // Validates the user input
                guard !viewModel.notes.isEmpty else {
                    viewModel.errorMessage = "Empty Field: Notes are required."
                    return
                }
                
                guard viewModel.selectedItem != nil else {
                    viewModel.errorMessage = "No Video Added: Please select a video."
                    return
                }
                
                for value in fillStars {
                    if value { viewModel.progress += 1 }
                }
                
                Task {
                    try await viewModel.addTrickItem(userId: userId, data: trick)
                }
                
                // Closes the view when the trick item is added
                dismiss()
            }
            .frame(height: 90)
            
            Spacer()
        }
        .navigationTitle("Add Trick Item")
    }
}
