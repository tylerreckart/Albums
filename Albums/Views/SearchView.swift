//
//  SearchSheet.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit

struct SearchView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var isDebounced: Bool = false
    
    @State private var searchText: String = ""
    @State private var artistsResults: [Artist] = []
    @State private var albumsResults: [AlbumsAlbum] = []
    
    @State private var showAlbumView: Bool = false
    @State private var selectedAlbum: Album?
    @State private var selectedArtist: Artist?
    
    private func search() async {
        if !isDebounced {
            self.isDebounced = true
            
            let results = await iTunesRequestService().search(searchText)
            if results.count != 0 {
                self.albumsResults = results
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.isDebounced = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            if (albumsResults.count > 0) {
                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 0) {
//                        ForEach(Array(albumsResults.enumerated()), id: \.offset) { index, album in
//                            NavigationLink(destination: AlbumDetail(album: mapAlbumsAlbumToLibraryStruct(album, viewContext: viewContext))) {
//                                AlbumListItem(album: album)
//                                    .cornerRadius(10, corners: index == 0 ? [.topLeft, .topRight] : index == albumsResults.count - 1 ? [.bottomLeft, .bottomRight] : [])
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 90)
//                    .padding(.bottom, 70)
//                    .cornerRadius(16)
                }
                .padding(.horizontal)
            } else {
                ScrollView {
                    VStack {
                        HStack {
                            Text("Recently Searched")
                                .bold()
                            Spacer()
                            Button("Clear", action: {})
                                .bold()
                                .padding(.trailing)
                        }
                        .padding(.leading)
                        
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 1)
                            .padding(.leading)
                    }
                    .padding(.top, 80)
                }
            }
            
            Header(content: { SearchBar(searchText: $searchText, search: search) })
        }
        .background(Color(.systemBackground))
        .padding(.horizontal)
    }
}
