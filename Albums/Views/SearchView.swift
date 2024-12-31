//
//  SearchSheet.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//  Refactored by ChatGPT
//

import SwiftUI
import MusicKit
import CodeScanner

// MARK: - SearchViewSearchBar

struct SearchViewSearchBar: View {
    @Binding var searchText: String
    @Binding var albumsResults: [iTunesAlbum]
    @Binding var isPresentingScanner: Bool
    
    let search: () async -> Void
    
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack {
            SearchBar(
                searchText: $searchText,
                search: search,
                results: $albumsResults,
                focused: _isSearchFocused
            )
            
            ScanButton {
                isPresentingScanner.toggle()
            }
        }
        .onAppear {
            // Automatically focus the search bar when this view appears
            isSearchFocused = true
        }
    }
}

// MARK: - ScanButton

private struct ScanButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
}

// MARK: - SearchView

struct SearchView: View {
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var itunes: iTunesAPI
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var searchText: String = ""
    @State private var albumsResults: [iTunesAlbum] = []
    
    @State private var scrollOffset: CGPoint = .zero
    @State private var isPresentingScanner: Bool = false
    
    @State private var expandHeader: Bool = false
    
    var body: some View {
        ZStack {
            // Background if no data
            if albumsResults.isEmpty && store.recentSearches.isEmpty {
                Color(.systemBackground)
            }
            
            // Main Scroll Content
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                // Spacer for the header
                Rectangle().fill(.clear).frame(height: 112)
                
                // Show search results if available
                if !albumsResults.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(albumsResults.indices, id: \.self) { index in
                            DynamicTargetSearchResult(album: albumsResults[index])
                        }
                    }
                }
                // Show recent searches if no search results
                else if !store.recentSearches.isEmpty {
                    recentlySearchedSection
                        .padding(.top, 20)
                }
            }
            .background(Color(.systemBackground))
            .padding(.bottom, 40)
            .scrollDismissesKeyboard(.immediately)
            
            // Header
            DynamicOffsetHeader(
                content: {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Search")
                                .font(.system(size: 34, weight: .bold))
                            Spacer()
                        }
                        .padding(.top, 5)
                        
                        SearchViewSearchBar(
                            searchText: $searchText,
                            albumsResults: $albumsResults,
                            isPresentingScanner: $isPresentingScanner,
                            search: search
                        )
                        .padding(.bottom, 13)
                    }
                },
                yOffset: scrollOffset.y,
                title: "Search"
            )
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isPresentingScanner) {
            BarcodeScannerView()
        }
        .transition(.identity)
        .onTapGesture {
            endTextEditing()
        }
    }
    
    // MARK: - Subviews
    
    private var recentlySearchedSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: 5) {
                HStack {
                    Text("Recently Searched")
                        .bold()
                    Spacer()
                    Button("Clear") {
                        store.clearRecentSearches()
                    }
                    .padding(.trailing)
                }
                
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 0.5)
            }
            .padding(.leading)
            
            // Example usage: If you have a relationship between `RecentView` and an `album`:
            // ForEach(store.recentSearches, id: \.self) { item in
            //     if let recentAlbum = item.album {
            //         Button {
            //             store.setActiveAlbum(recentAlbum)
            //         } label: {
            //             AlbumListItem(album: recentAlbum)
            //         }
            //     }
            // }
        }
    }
    
    // MARK: - Methods
    
    /// Triggers the iTunes Search API call.
    private func search() async {
        do {
            let results = try await itunes.search(searchText)
            guard !results.isEmpty else { return }
            albumsResults = results
        } catch {
            // Handle or log the error here
            print("Error searching iTunes: \(error.localizedDescription)")
        }
    }

    /// Ends the keyboard focus by resigning first responder status.
    private func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
