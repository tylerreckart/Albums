//
//  AlbumDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit
import CoreData

struct PlayerView: View {
    let player = ApplicationMusicPlayer.shared
    
    @State private var visible: Bool = false
    @State private var collapsed: Bool = true
    
    @ObservedObject private var state = ApplicationMusicPlayer.shared.state
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5)
            
            if visible {
                HStack {
                    let activeEntry = player.queue.currentEntry
                    
                    if activeEntry?.artwork != nil {
                        ArtworkImage((activeEntry?.artwork)!, width: 48)
                            .cornerRadius(6)
                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                            .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                    }
                    
                    Text(player.queue.currentEntry?.title ?? "")
                        .font(.system(size: 16, weight: .regular))
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        if state.playbackStatus == .playing {
                            Button(action: { player.pause() }) {
                                Image(systemName: "pause.fill")
                            }
                        } else {
                            Button(action: { Task { try? await player.play() }}) {
                                Image(systemName: "play.fill")
                            }
                        }
                        
                        Button(action: { Task {
                            player.pause()
                            try? await player.skipToNextEntry()
                            try? await player.play()
                        }}) {
                            Image(systemName: "forward.fill")
                        }
                    }
                    .font(.system(size: 24))
                    .foregroundColor(Color("PrimaryPurple"))
                }
                .padding(.top, 10)
                .padding(.horizontal)
                .padding(.bottom, 30)
                .background(.white)
                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
            }
        }
        .onChange(of: state.playbackStatus) { status in
            if status == .playing && !visible {
                withAnimation {
                    self.visible = true
                }
            }
        }
    }
}

struct AlbumDetail: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var iTunesAPI: iTunesAPI
    
    @StateObject var mbAPI: MusicBrainzAPI = MusicBrainzAPI()
    
    var album: LibraryAlbum
    var searchResult: Bool = false
    
    @State private var viewContext: NSManagedObjectContext?
    @State private var related: [LibraryAlbum] = []
    @State private var tracks: [iTunesTrack] = []
    @State private var scrollOffset: CGPoint = CGPoint()

    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                VStack(spacing: 20) {
                    AlbumMeta()
                    AlbumActions()

                    if self.tracks.count > 0 {
                        AlbumTracklist(tracks: $tracks)
                    }
                    
                    if self.related.count > 0 {
                        RelatedAlbums(related: $related)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.top, 35)
            
            Header(content: {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20, weight: .regular))
                    }
                    Spacer()
                    
                    Text(album.title ?? "")
                        .font(.system(size: 16, weight: .semibold))
                        .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 24, height: 24)
                            Image(systemName: "ellipsis")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                }
                .padding(.top, 10)
            })
            
            PlayerView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            store.setActiveAlbum(album)

            Task {
                let artwork = await iTunesAPI.lookupAlbumArtwork(store.activeAlbum!)
                store.activeAlbum?.artworkUrl = artwork
                store.saveData()
                
                self.related =
                    await iTunesAPI.lookupRelatedAlbums(
                        Int(store.activeAlbum!.artistAppleId)
                    ).map { store.mapAlbumDataToLibraryModel($0) }
                self.tracks =
                    await iTunesAPI.lookupTracksForAlbum(
                        Int(store.activeAlbum!.appleId)
                    )

                guard await MusicAuthorization.request() != .denied else { return }

                let request = MusicCatalogResourceRequest<Album>(matching: \.upc, equalTo: store.activeAlbum!.upc ?? "")
                let response = try await request.response()

                guard let album = response.items.first else { return }

                let globalPlayer = ApplicationMusicPlayer.shared
                globalPlayer.queue = []
                globalPlayer.stop()
                globalPlayer.queue = [album]

                try await globalPlayer.prepareToPlay()
            }
            
            if searchResult == true {
                store.saveRecentSearch(album)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}

