//
//  ReccomendedAlbum.swift
//  Albums
//
//  Created by Tyler Reckart on 5/21/23.
//

import Foundation
import SwiftUI

struct RecommendedAlbum: View {
    var columnWidth: CGFloat

    var body: some View {
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
                .frame(width: 300, height: columnWidth)
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
            
            Image(systemName: "music.note")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(Color.init(hex: "9E9E9E"))
        }
    }
}
