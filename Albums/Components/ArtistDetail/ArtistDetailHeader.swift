//
//  ArtistDetailHeader.swift
//  Albums
//
//  Created by Tyler Reckart on 6/10/23.
//

import Foundation
import SwiftUI

struct ArtistDetailHeader: View {
    @Binding var artist: Artist?
    
    @Binding var scrollOffset: CGPoint
    @Binding var showOptionsCard: Bool
    @Binding var animateIn: Bool
    
    var body: some View {
        Header(content: {
            HStack {
                Button(action: {
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 1)) {
                        animateIn.toggle()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        artist = nil
                    }
                }) {
                    Image(systemName: "chevron.backward.circle.fill")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color("PrimaryPurple"))
                        .symbolRenderingMode(.hierarchical)
                }
                
                Spacer()
                Text(artist?.name?.trunc(length: 24) ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showOptionsCard.toggle()
                    }
                }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color("PrimaryPurple"))
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .frame(height: 50)
            .background(Color(.systemBackground))
        }, showDivider: false, showWideBackground: true)
    }
}
