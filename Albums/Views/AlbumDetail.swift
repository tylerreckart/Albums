//
//  AlbumDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit
import CoreData

struct AlbumDetail: View {
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var iTunesAPI: iTunesAPI
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var album: LibraryAlbum
    var searchResult: Bool = false
    
    @State private var viewContext: NSManagedObjectContext?
    @State private var related: [LibraryAlbum] = []
    @State private var tracks: [iTunesTrack] = []
    @State private var scrollOffset: CGPoint = CGPoint()

    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                VStack(spacing: 20) {
                    AlbumMeta()
                    AlbumActions()

                    if self.tracks.count > 0 {
                        AlbumTracklist(tracks: $tracks)
                    }
                    
                    if self.related.count > 0 {
                        RelatedAlbums(related: $related)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.top, 35)
            
            Header(content: {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20, weight: .regular))
                    }
                    Spacer()
                    
                    Text(album.title ?? "")
                        .font(.system(size: 16, weight: .semibold))
                        .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 24, height: 24)
                            Image(systemName: "ellipsis")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                }
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.white))
        .onAppear {
            store.setActiveAlbum(album)

            Task {
                await iTunesAPI.lookupAlbumArtwork(store.activeAlbum!)
                
                self.related =
                    await iTunesAPI.lookupRelatedAlbums(
                        Int(store.activeAlbum!.artistAppleId)
                    ).map { store.mapAlbumDataToLibraryModel($0) }
                self.tracks =
                    await iTunesAPI.lookupTracksForAlbum(
                        Int(store.activeAlbum!.appleId)
                    )
            }
            
            if searchResult == true {
                store.saveRecentSearch(album)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}

