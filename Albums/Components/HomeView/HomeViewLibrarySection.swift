//
//  HomeViewLibrarySection.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI
import CoreData

struct AlbumGridItem: View {
    var album: Release

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: album.artworkUrl!)) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(contentMode: .fit)
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.075), radius: 6, y: 6)
            
            Text(album.title!)
                .font(.system(size: 14, weight: .bold))
                .multilineTextAlignment(.leading)
            Text(album.artistName!)
                .foregroundColor(Color("PrimaryGray"))
                .font(.system(size: 14, weight: .semibold))
        }
    }
}

struct HomeViewLibrarySection: View {
    @EnvironmentObject var store: AlbumsAPI
    
    var setView: (_ view: RootView) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(
                text: "Your Library",
                buttonText: "See All",
                destination: {},
                useAction: true,
                action: {
                    store.setFilter(.library)
                    setView(.library)
                }
            )
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    if store.library.count > 1 {
                        ForEach(store.library[0..<2], id: \.self) { album in
                            VStack {
                                Button(action: {
                                    withAnimation(.linear(duration: 0.25)) {
                                        store.setActiveAlbum(album)
                                    }
                                }) {
                                    AlbumGridItem(album: album)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .foregroundColor(.primary)
    }
}
