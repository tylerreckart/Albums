//
//  AlbumListItem.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation
import SwiftUI

struct AlbumListItem: View {
    var album: LibraryAlbum

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                AsyncImage(url: URL(string: album.artworkUrl!)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 48, height: 48)
                .cornerRadius(6)
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text(album.title!)
                            .font(.system(size: 16, weight: .bold))
                            .multilineTextAlignment(.leading)
                        Text(album.artistName!)
                            .font(.system(size: 14, weight: .regular))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(.systemGray5))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            
            
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
                .padding(.leading, 75)
        }
        .background(.white)
        .foregroundColor(.primary)
    }
}
