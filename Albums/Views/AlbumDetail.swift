//
//  AlbumDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit

struct AlbumDetail: View {
    var album: Album
    
    var body: some View {
        VStack(spacing: 0) {
            ArtworkImage(album.artwork!, height: UIScreen.main.bounds.width - 80)
                .padding(.vertical, 40)
                
            Spacer()
        }
    }
}

struct AlbumDetailSheet: View {
    @Binding var album: Album?
    @Binding var artist: Artist?
    @State private var artists: [Artist] = []
    
    var body: some View {
        if (album != nil) {
            ZStack {
                ScrollView {
                    AlbumDetail(album: album!)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
    }
}

