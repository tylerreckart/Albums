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
    
    var body: some View {
        HStack {
            SearchBar(searchText: $searchText, search: search, results: $albumsResults)
            
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
    }
}

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
    
    @State private var isPresentingScanner: Bool = false
    @State private var scannedCode: String?
    @State private var isPresentingScannerResult: Bool = false
    @State private var scannerResult: LibraryAlbum?
    
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
                
                SearchViewSearchBar(
                    searchText: $searchText,
                    albumsResults: $albumsResults,
                    isPresentingScanner: $isPresentingScanner,
                    search: search
                )
                .padding(.horizontal)
                .padding(.top, 5)
                .padding(.bottom, 10)
                
                Text(scannedCode ?? "")
                
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
                    VStack(spacing: 10) {
                        HStack {
                            Spacer()
                            Text("Search")
                                .font(.system(size: 16, weight: .semibold))
                                .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                            Spacer()
                        }
                        
                        if scrollOffset.y >= 50 {
                            SearchViewSearchBar(
                                searchText: $searchText,
                                albumsResults: $albumsResults,
                                isPresentingScanner: $isPresentingScanner,
                                search: search
                            )
                        }
                    }
                },
                showDivider: false
            )
        }
        .navigationBarHidden(true)
        .transition(.push(from: .trailing))
        .sheet(isPresented: $isPresentingScanner) {
            ZStack {
                CodeScannerView(
                    codeTypes: [.code39, .code93, .code128, .code39Mod43, .ean8, .ean13, .upce],
                    scanMode: .once
                ) { response in
                    if case let .success(result) = response {
                        isPresentingScanner = false

                        Task {
                            let res = await itunes.lookupUPC(result.string)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if res != nil {
                                    store.setActiveAlbum(nil)
                                    scannerResult = store.mapAlbumDataToLibraryModel(res!, upc: result.string)
                                    isPresentingScannerResult = true
                                }
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
                
                Image("BarcodeContainer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 190)
                
                Header(
                    content: {
                        HStack {
                            Spacer()
                            
                            Button(action: { isPresentingScanner = false }) {
                                Text("Cancel")
                            }
                            .padding(.top, 10)
                        }
                    },
                    showDivider: false,
                    background: .black
                )
            }
        }
        .sheet(isPresented: $isPresentingScannerResult) {
            AlbumDetail(album: scannerResult!)
        }
    }
}
