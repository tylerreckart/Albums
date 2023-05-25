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
    
    private func search() async {
        let results = await itunes.search(searchText)
        if results.count != 0 {
            self.albumsResults = results
        }
    }
    
    var body: some View {
        ZStack {
            if (albumsResults.count > 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(albumsResults.enumerated()), id: \.offset) { index, album in
                            let remappedAlbum = store.mapAlbumDataToLibraryModel(album)
                            NavigationLink(destination: AlbumDetail(album: remappedAlbum, searchResult: true)) {
                                AlbumListItem(album: remappedAlbum)
                            }
                        }
                    }
                    .padding(.top, 63)
                    .padding(.bottom, 49)
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Recently Searched")
                                .bold()
                            Spacer()
                            Button("Clear", action: { store.clearRecentSearches() })
                                .padding(.trailing)
                        }
                        .padding(.leading)
                        
                        ForEach(store.recentSearches, id: \.self) { album in
                            NavigationLink(destination: AlbumDetail(album: album.album!)) {
                                AlbumListItem(album: album.album!)
                            }
                        }
                    }
                    .padding(.top, 80)
                }
            }
            
            Header(content: { SearchBar(searchText: $searchText, search: search, results: $albumsResults) })
        }
        .background(Color(.white))
        .transition(.push(from: .trailing))
    }
}
