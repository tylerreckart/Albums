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
                        .frame(width: 90, height: 42)
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
    
    @State private var expandHeader: Bool = false
    
    var body: some View {
        ZStack {
            if albumsResults.count == 0 && store.recentSearches.count == 0 {
                Color(.systemBackground)
            }
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                Rectangle().fill(.clear).frame(height: 110)
                
                if (albumsResults.count > 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(albumsResults.enumerated()), id: \.offset) { index, album in
                            DynamicTargetSearchResult(album: album)
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
                    .padding(.top, 20)
                }
            }
            .background(Color(.systemBackground))
            .padding(.bottom, 42)
            .scrollDismissesKeyboard(.immediately)
            
            DynamicOffsetHeader(content: {
                VStack(spacing: 10) {
                    HStack {
                        HStack {
                            Text("Search")
                                .font(.system(size: 34, weight: .bold))
                            Spacer()
                        }
                    }
                    
                    SearchViewSearchBar(
                        searchText: $searchText,
                        albumsResults: $albumsResults,
                        isPresentingScanner: $isPresentingScanner,
                        search: search
                    )
                    .padding(.bottom, 10)
                }
            }, yOffset: scrollOffset.y, title: "Search")
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isPresentingScanner) {
            BarcodeScannerView()
        }
        .transition(.identity)
        .onTapGesture {
              self.endTextEditing()
        }
    }
}
