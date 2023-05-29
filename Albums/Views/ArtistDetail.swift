//
//  ArtistDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 5/26/23.
//

import SwiftUI

struct ArtistDetail: View {
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var itunes: iTunesAPI
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var scrollOffset: CGPoint = CGPoint()
    @State private var artist: iTunesArtist?
    @State private var related: [iTunesAlbum] = []
    
    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                VStack(spacing: 20) {
                    VStack {
                        Text((artist?.artistName) ?? "")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .padding(.top, 20)
                
                    if related.count > 1 {
                        VStack(spacing: 10) {
                            SectionTitle(text: "Albums by \(artist!.artistName)", destination: {})
                                .padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(related[1..<related.count], id: \.self) { album in
                                        let r = store.mapAlbumDataToLibraryModel(album)
                                        
                                        Button(action: { store.setActiveAlbum(r) }) {
                                            AlbumGridItem(album: r)
                                                .frame(maxWidth: 250)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 275)
                        }
                    }
                    
                    if related.count > 1 {
                        VStack(spacing: 10) {
                            SectionTitle(text: "Featured On", destination: {})
                                .padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(related[1..<related.count], id: \.self) { album in
                                        let r = store.mapAlbumDataToLibraryModel(album)
                                        
                                        Button(action: { store.setActiveAlbum(r) }) {
                                            AlbumGridItem(album: r)
                                                .frame(maxWidth: 250)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 275)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.top, 40)
            
            Header(content: {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20, weight: .regular))
                    }
                    Spacer()
                    
                    Text(store.activeAlbum?.artistName ?? "")
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
        .onAppear {
            Task {
                let artistId = store.activeAlbum!.artistAppleId
                let response = await itunes.lookupArtist(store.activeAlbum!.artistAppleId)
                
                if response.count > 0 {
                    self.artist = response[0]
                }
                
                let related = await itunes.lookupRelatedAlbums(Int(artistId))
                self.related = related
            }
        }
        .navigationBarHidden(true)
    }
}
