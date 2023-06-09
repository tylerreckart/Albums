//
//  CreatePlaylistSheet.swift
//  Albums
//
//  Created by Tyler Reckart on 6/9/23.
//

import Foundation
import SwiftUI

struct CreatePlaylistSheet: View {
    @State private var name: String = ""
    
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 26) {
            Text("Give your playlist a name")
                .font(.system(size: 16, weight: .semibold))
            
            TextField("My playlist...", text: $name)
                .font(.system(size: 24, weight: .regular))
                .focused($focused)
                .frame(maxWidth: 250)
                .padding()
                .border(width: 2, edges: [.bottom], color: Color(.systemGray5))
            
            Button(action: {
                // do something
                
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemGray5))
                        .frame(width: 125, height: 50)
                    Text("Create")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("PrimaryPurple"))
                }
            }
            .padding(.top, 10)
        }
        .padding(.horizontal)
        .onAppear {
            focused = true
        }
    }
}
