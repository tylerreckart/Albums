//
//  AlbumListItem.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation
import SwiftUI

struct AlbumListItem: View {
    var album: AlbumsAlbum

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                AsyncImage(url: URL(string: album.artworkUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 48, height: 48)
                .overlay(
                    LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text(album.name)
                            .font(.system(size: 16, weight: .bold))
                        Text(album.artistName)
                            .font(.system(size: 14, weight: .regular))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(.systemGray4))
                }
            }
            .padding(12)
            
            
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5)
        }
        .background(.white)
        .foregroundColor(.primary)
    }
}
