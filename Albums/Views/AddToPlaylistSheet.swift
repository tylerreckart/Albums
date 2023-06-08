//
//  AddToPlaylistSheet.swift
//  Albums
//
//  Created by Tyler Reckart on 6/8/23.
//

import Foundation
import SwiftUI

struct AddToPlaylistSheet: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            ScrollView {
                Text("Hello, World")
            }
        }
        .navigationTitle("Add to playlist...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Cancel")
                }
            }
        }
    }
}
