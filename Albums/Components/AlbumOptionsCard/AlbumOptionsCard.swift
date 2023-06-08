//
//  AlbumOptionsCard.swift
//  Albums
//
//  Created by Tyler Reckart on 6/8/23.
//

import Foundation
import SwiftUI

struct AlbumOptionsCard: View {
    @Binding var showOptionsCard: Bool
    @Binding var showAddToPlaylistSheet: Bool
    
    @State private var animateIn: Bool = false
    
    struct ListItem: View {
        var symbol: String
        var text: String
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(alignment: .center, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 36)
                        Image(systemName: symbol)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("PrimaryPurple"))
                    }
                    
                    Text(text)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(animateIn ? 0.2 : 0)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        animateIn.toggle()
                    }
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    ListItem(symbol: "square.stack.3d.up", text: "Add to playlist...", action: { showAddToPlaylistSheet.toggle() })

                    ListItem(symbol: "heart", text: "Add to favorites", action: { showAddToPlaylistSheet.toggle() })

                    ListItem(symbol: "square.and.arrow.up", text: "Share this album", action: { showAddToPlaylistSheet.toggle() })

                    ListItem(symbol: "exclamationmark.bubble", text: "Report a problem...", action: { showAddToPlaylistSheet.toggle() })

                    Spacer().frame(height: 10)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            .offset(y: animateIn ? 0 : UIScreen.main.bounds.height)
        }
        .onAppear {
            withAnimation {
                animateIn.toggle()
            }
        }
    }
}
