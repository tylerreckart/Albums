//
//  AlbumDetailHeader.swift
//  Albums
//
//  Created by Tyler Reckart on 6/8/23.
//

import Foundation
import SwiftUI

struct AlbumDetailHeader: View {
    @EnvironmentObject var store: AlbumsAPI
    
    var album: LibraryAlbum?
    
    @Binding var scrollOffset: CGPoint
    @Binding var showOptionsCard: Bool
    
    var body: some View {
        Header(content: {
            HStack {
                Button(action: {
                    store.setActiveAlbum(nil)
                }) {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color("PrimaryPurple"))
                        .symbolRenderingMode(.hierarchical)
                }
                
                Spacer()
                Text(album?.title?.trunc(length: 24) ?? "")
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
        }, showDivider: false)
    }
}
