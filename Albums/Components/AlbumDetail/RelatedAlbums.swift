//
//  RelatedAlbums.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import SwiftUI

struct RelatedAlbums: View {
    @EnvironmentObject var store: AlbumsAPI
    
    @Binding var related: [LibraryAlbum]
    
    var scrollToTop: () -> Void
    
    @State private var inLibraryAlbums: [LibraryAlbum] = []
    
    struct Carousel: View {
        @EnvironmentObject var store: AlbumsAPI
        
        var data: [LibraryAlbum]
        
        var scrollToTop: () -> Void
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(data, id: \.self) { a in
                        Button(action: { store.setActiveAlbum(a); scrollToTop(); }) {
                            AlbumGridItem(album: a)
                                .frame(maxWidth: 200)
                        }
                    }
                }
                .padding([.horizontal])
                .padding(.bottom, 10)
            }
            .frame(height: 280)
            .edgesIgnoringSafeArea(.bottom)
            .foregroundColor(.primary)
        }
    }
    
    struct SectionHeader: View {
        var text: String
        
        var body: some View {
            HStack {
                Text(text).font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .padding(.horizontal)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                SectionHeader(text: "More by \(store.activeAlbum?.artistName ?? "")")
                Carousel(data: related, scrollToTop: scrollToTop)
            }
            
            if inLibraryAlbums.count > 0 {
                VStack(spacing: 0) {
                    SectionHeader(text: "In your Library")
                    Carousel(data: inLibraryAlbums, scrollToTop: scrollToTop)
                }
            }
        }
        .onAppear {
            let activeAlbum = store.activeAlbum
            let artist = activeAlbum?.artistAppleId
            
            inLibraryAlbums  = store.library.filter {
                $0.artistAppleId == artist && $0.appleId != activeAlbum?.appleId
            }
        }
    }
}
