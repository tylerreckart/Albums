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
                .fill(Color(.systemGray4))
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

struct AlbumOptionsCard: View {
    @Binding var showOptionsCard: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        showOptionsCard.toggle()
                    }
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 4)
                        .cornerRadius(.infinity)
                    
                    Button(action: {}) {
                        HStack(alignment: .center, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 36)
                                Image(systemName: "square.stack.3d.up")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("PrimaryPurple"))
                            }
                            
                            
                            Text("Add to a playlist...")
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                        }
                    }
                    
                    Button(action: {}) {
                        HStack(alignment: .center, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 36)
                                Image(systemName: "heart")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("PrimaryPurple"))
                            }
                            
                            Text("Add to favorites")
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                        }
                    }
                    
                    Button(action: {}) {
                        HStack(alignment: .center, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 36)
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("PrimaryPurple"))
                            }
                            
                            Text("Share this album")
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                        }
                    }
                    
                    Button(action: {}) {
                        HStack(alignment: .center, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 36)
                                Image(systemName: "exclamationmark.bubble")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("PrimaryPurple"))
                            }
                            
                            Text("Report a problem...")
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                        .frame(height: 10)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
        }
    }
}

struct AlbumDetailHeader: View {
    @EnvironmentObject var store: AlbumsAPI
    
    var album: LibraryAlbum?
    
    @Binding var scrollOffset: CGPoint
    @Binding var showOptionsCard: Bool
    
    var body: some View {
        Header(content: {
            HStack {
                Button(action: {
                    store.setActiveAlbum(nil)
                }) {
                    ZStack {
                        Circle()
                            .fill(Color("PrimaryPurple"))
                            .frame(width: 20)
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.system(size: 26, weight: .regular))
                            .foregroundColor(Color(.systemGray6))
                    }
                }
                
                Spacer()
                Text(album?.title?.trunc(length: 24) ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showOptionsCard.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color("PrimaryPurple"))
                            .frame(width: 20)
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 26, weight: .regular))
                            .foregroundColor(Color(.systemGray6))
                    }
                }
            }
            .frame(height: 50)
            
            .background(Color(.systemBackground))
        }, showDivider: false)
    }
}

struct AlbumDetail: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var iTunesAPI: iTunesAPI
    
    @StateObject var mbAPI: MusicBrainzAPI = MusicBrainzAPI()
    
    var album: LibraryAlbum?
    var searchResult: Bool = false
    
    @State private var viewContext: NSManagedObjectContext?
    @State private var related: [LibraryAlbum] = []
    @State private var tracks: [iTunesTrack] = []
    @State private var scrollOffset: CGPoint = CGPoint()
    
    @State private var showOptionsCard: Bool = false

    var body: some View {
        ZStack {
            if album != nil {
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
                        
                        Spacer().frame(height: 10)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.top, 40)
                .background(Color(.systemBackground))
            } else {
                ProgressView()
            }
                
            AlbumDetailHeader(album: album, scrollOffset: $scrollOffset, showOptionsCard: $showOptionsCard)
                
            if showOptionsCard {
                AlbumOptionsCard(showOptionsCard: $showOptionsCard)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: store.activeAlbum) { state in
            if state != nil {
                Task {
                    await loadAlbumMeta(state: state!)
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func loadAlbumMeta(state: LibraryAlbum) async -> Void {
        let artwork = await iTunesAPI.lookupAlbumArtwork(state)
        
        state.artworkUrl = artwork
        
        self.related = await iTunesAPI.lookupRelatedAlbums(Int(state.artistAppleId)).map { store.mapAlbumDataToLibraryModel($0) }
        self.tracks  = await iTunesAPI.lookupTracksForAlbum(Int(state.appleId))
        
        if state.upc == nil {
            let data = await mbAPI.requestMetadata(state.title!, state.artistName!)
            
            if !data.isEmpty && data[0].barcode != nil {
                state.upc = data[0].barcode
            }
        }
        
        store.saveData()
    }
}
