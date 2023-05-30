//
//  SearchSheet.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit
import CodeScanner

struct SearchViewSearchBar: View {
    @Binding var searchText: String
    @Binding var albumsResults: [iTunesAlbum]
    @Binding var isPresentingScanner: Bool
    
    var search: () async -> Void
    
    @FocusState var focused: Bool
    
    var body: some View {
        HStack {
            SearchBar(searchText: $searchText, search: search, results: $albumsResults, focused: _focused)
            
            Button(action: { isPresentingScanner.toggle() }) {
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
        .onAppear {
            focused = true
        }
    }
}

enum FocusField {
    case search
}

struct SearchView: View {
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var itunes: iTunesAPI

    @Environment(\.managedObjectContext) var viewContext
    
    @State private var searchText: String = ""
    @State private var albumsResults: [iTunesAlbum] = []
    
    @State private var scrollOffset: CGPoint = CGPoint()
    
    @State private var isPresentingScanner: Bool = false

    private func search() async {
        let results = await itunes.search(searchText)
        if results.count != 0 {
            self.albumsResults = results
        }
    }
    
    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                if (albumsResults.count > 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(albumsResults.enumerated()), id: \.offset) { index, album in
                            let r = store.mapAlbumDataToLibraryModel(album)
                            Button(action: { store.setActiveAlbum(r) }) {
                                AlbumListItem(album: r)
                            }
                        }
                    }
                } else if store.recentSearches.count > 0 {
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
                            if album.album != nil {
                                Button(action: { store.setActiveAlbum(album.album!) }) {
                                    AlbumListItem(album: album.album!)
                                }
                            }
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .padding(.top, 75)
            .padding(.bottom, 43)
            .scrollDismissesKeyboard(.immediately)
            
            Header(
                content: {
                    VStack(spacing: 10) {
                        HStack {
                            Spacer()
                            Text("Search")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }

                        SearchViewSearchBar(
                            searchText: $searchText,
                            albumsResults: $albumsResults,
                            isPresentingScanner: $isPresentingScanner,
                            search: search
                        )
                    }
                },
                showDivider: false
            )
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isPresentingScanner) {
            BarcodeScannerView()
        }
        .transition(.identity)
    }
}
