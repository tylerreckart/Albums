//
//  SearchSheet.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit

struct SearchView: View {
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var itunes: iTunesAPI

    @Environment(\.managedObjectContext) var viewContext
    
    @State private var isDebounced: Bool = false
    
    @State private var searchText: String = ""
    @State private var artistsResults: [Artist] = []
    @State private var albumsResults: [iTunesAlbum] = []
    
    @State private var showAlbumView: Bool = false
    @State private var selectedAlbum: Album?
    @State private var selectedArtist: Artist?
    
    @State private var scrollOffset: CGPoint = CGPoint()
    
    private func search() async {
        let results = await itunes.search(searchText)
        if results.count != 0 {
            self.albumsResults = results
        }
    }
    
    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                HStack {
                    Text("Search")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding([.horizontal])
                .padding(.bottom, -1)
                
                HStack {
                    SearchBar(searchText: $searchText, search: search, results: $albumsResults)
                    
                    Button(action: {}) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(.systemGray6))
                                .frame(width: 90, height: 40)
                            HStack(spacing: 5) {
                                Image(systemName: "viewfinder")
                                    .font(.system(size: 12, weight: .heavy))
                                Text("Scan")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Color("PrimaryPurple"))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                        }
                    }
                    .frame(width: 90)
                }
                .padding(.horizontal)
                .padding(.top, 5)
                .padding(.bottom, 10)
                if (albumsResults.count > 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(albumsResults.enumerated()), id: \.offset) { index, album in
                            let remappedAlbum = store.mapAlbumDataToLibraryModel(album)
                            NavigationLink(destination: AlbumDetail(album: remappedAlbum, searchResult: true)) {
                                AlbumListItem(album: remappedAlbum)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        VStack(spacing: 5) {
                            HStack {
                                Text("Recently Searched")
                                    .bold()
                                Spacer()
                                Button("Clear", action: { store.clearRecentSearches() })
                                    .padding(.trailing)
                            }
                            
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 0.5)
                        }
                        .padding(.leading)
                        
                        ForEach(store.recentSearches, id: \.self) { album in
                            NavigationLink(destination: AlbumDetail(album: album.album!)) {
                                AlbumListItem(album: album.album!)
                            }
                        }
                    }
                }
            }
            .background(Color(.white))
            .padding(.top, 32)
            .padding(.bottom, 43)
            
            
            Header(
                content: {
                    HStack {
                        Spacer()
                        Text("Search")
                            .font(.system(size: 16, weight: .semibold))
                            .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                        Spacer()
                    }
                },
                showDivider: false
            )
        }
        .navigationBarHidden(true)
        .transition(.push(from: .trailing))
    }
}
