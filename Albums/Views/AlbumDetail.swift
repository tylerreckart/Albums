//
//  AlbumDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit


struct AlbumDetail: View {
    var album: AlbumsAlbum

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Text(album.name)
                        .font(.system(size: 20, weight: .heavy))
                    Text(album.artistName)
                    HStack {
                        Text("Genre")
                            .bold()
                        Text(album.genre)
                    }
                    
                    Button(action: {}) {
                        Text("Add To Library")
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}

