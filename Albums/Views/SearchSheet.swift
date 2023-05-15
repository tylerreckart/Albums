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
    
    @State private var searchText: String = ""
    @State private var artistsResults: [Artist] = []
    @State private var albumsResults: [Album] = []
    
    @State private var showAlbumView: Bool = false
    @State private var selectedAlbum: Album?
    @State private var selectedArtist: Artist?
    
    private func search() async {
        let status = await MusicAuthorization.request()
        guard status == .authorized else { return }
    
        let encodedStr = searchText.split(separator: " ").joined(separator: "+")
        var request = MusicCatalogSearchRequest(term: encodedStr, types: [Album.self, Artist.self])
        request.includeTopResults = true
        request.limit = 6
        let response = try? await request.response()

        self.albumsResults = []
        self.artistsResults = []
        
        if (response != nil) {
            let albums: MusicItemCollection<Album>? = response?.albums
            albums?.forEach({ album in albumsResults.append(album) })
            
            let artists: MusicItemCollection<Artist>? = response?.artists
            artists?.forEach({ artist in artistsResults.append(artist) })
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
                                self.selectedAlbum = album
                                
                                let albumArtist = album.artistName
                                
                                let searchMatch = artistsResults.firstIndex(where: { $0.name == albumArtist })
                                
                                if (searchMatch != nil) {
                                    self.selectedArtist = self.artistsResults[searchMatch!]
                                }
                                
                                self.showAlbumView.toggle()
                            }) {
                                HStack(alignment: .center, spacing: 10) {
                                    ArtworkImage(album.artwork!, height: 48)
                                        .cornerRadius(4)
                                        .padding(.top, 2)
                                    
                                    VStack(alignment: .leading) {
                                        Text(album.title)
                                            .font(.system(size: 16, weight: .bold))
                                        Text(album.artistName)
                                            .font(.system(size: 14, weight: .regular))
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    
                    Section(header: Text("Artists matching '\(searchText)'")) {
                        ForEach(artistsResults, id: \.self) { artist in
                            HStack(alignment: .center, spacing: 10) {
                                if (artist.artwork != nil) {
                                    ArtworkImage(artist.artwork!, height: 48)
                                        .cornerRadius(.infinity)
                                        .padding(.top, 2)
                                } else {
                                    Circle().fill(.clear).frame(width: 48)
                                }

                                VStack(alignment: .leading) {
                                    Text(artist.name)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                            }
                        }
                    }
                }
                .transition(.opacity)
            }
            
            Spacer()
        }
        .background(Color(.systemGray6))
        .sheet(isPresented: $showAlbumView, onDismiss: { self.selectedAlbum = nil }) {
            AlbumDetailSheet(album: $selectedAlbum, artist: $selectedArtist)
        }
    }
}
