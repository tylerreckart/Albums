//
//  AlbumDetailItem.swift
//  Albums
//
//  Created by Tyler Reckart on 5/21/23.
//

import Foundation
import SwiftUI
import MusicKit

struct AlbumGridItem: View {
    var artwork: Artwork?
    var columnWidth: CGFloat

    var albumCover: some View {
        Button(action: {}) {
            if (artwork != nil) {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.purple, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: columnWidth, height: columnWidth)
                    .cornerRadius(6)
                    .padding(.leading)
                    .overlay(
                        LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 4)
            } else {
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.init(hex: "E2E2E2"),
                                    Color.init(hex: "CCCCCC")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: columnWidth, height: columnWidth)
                        .cornerRadius(6)
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
                    
                    Image(systemName: "music.note")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(Color.init(hex: "9E9E9E"))
                }
            }
        }
    }

    var body: some View {
        VStack {
            albumCover
            
            Text("Album Name")
                .font(.system(size: 16, weight: .medium))
            Text("Artist")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
        }
    }
}
