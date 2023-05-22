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
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                ZStack {
                    TextField("Search", text: $searchText)
                        .onChange(of: searchText) { _ in
                            Task {
                                await search()
                            }
                        }
                        .padding()
                        .padding(.leading, 22)
                        .background(.white)
                        .cornerRadius(10)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(.systemGray))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    
                    if (searchText.count > 0) {
                        HStack {
                            Spacer()
                            
                            Button(action: { self.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.systemGray3))
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Cancel")
                }
            }
            .padding()
            
            if (albumsResults.count > 0) {
                List {
                    Section(header: Text("Albums matching '\(searchText)'")) {
                        ForEach(albumsResults, id: \.self) { album in
                            Button(action: {
                                Task {
                                    let relatedAlbums = await iTunesRequestService().lookupRelatedAlbums(album.artistId)
                                    print(relatedAlbums)
                                }
                            }) {
                                HStack(alignment: .center, spacing: 10) {
                                    AsyncImage(url: URL(string: album.artworkUrl)) { image in
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom)
                                    )
                                    .cornerRadius(6)
                                    .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                        
                                    VStack(alignment: .leading) {
                                        Text(album.name)
                                            .font(.system(size: 16, weight: .bold))
                                        Text(album.artistName)
                                            .font(.system(size: 14, weight: .regular))
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            
            Spacer()
        }
        .background(Color(.systemGray6))
        .sheet(isPresented: $showAlbumView, onDismiss: { self.selectedAlbum = nil }) {
            AlbumDetailSheet(album: $selectedAlbum, artist: $selectedArtist)
        }
    }
}
