//
//  SearchSheet.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit

struct SearchSheet: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
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
    
    var header: some View {
        HStack(spacing: 12) {
            SearchBar(searchText: $searchText, search: search)
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("Cancel")
            }
        }
        .padding()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header
                
                if (albumsResults.count > 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(albumsResults.enumerated()), id: \.offset) { index, album in
                                NavigationLink(destination: AlbumDetail(album: album)) {
                                    AlbumListItem(album: album)
                                        .cornerRadius(10, corners: index == 0 ? [.topLeft, .topRight] : index == albumsResults.count - 1 ? [.bottomLeft, .bottomRight] : [])
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 5)
                    }
                }
                
                Spacer()
            }
            .background(Color(.systemGray6))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
