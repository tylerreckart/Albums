//
//  AlbumDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit
import CoreData

struct AlbumDetail: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var iTunesAPI: iTunesAPI
    
    @StateObject private var mbAPI = MusicBrainzAPI()
    @State private var related: [Release] = []
    @State private var tracks: [iTunesTrack] = []
    @State private var scrollOffset: CGPoint = CGPoint()
    @State private var showOptionsCard = false
    @State private var showAddToPlaylistSheet = false
    @State private var selectedArtist: Artist?

    var album: Release?
    var searchResult: Bool = false

    var body: some View {
        ZStack {
            if let album = album {
                AlbumScrollView(
                    tracks: $tracks,
                    related: $related,
                    shouldScrollToTop: Binding.constant(false),
                    selectedArtist: $selectedArtist
                )
                .task {
                    do {
                        await loadAlbumMeta(album)
                    } catch {
                        print("Error loading album metadata: \(error.localizedDescription)")
                    }
                }
            } else {
                ProgressView()
            }

            AlbumDetailHeader(
                album: album,
                scrollOffset: $scrollOffset,
                showOptionsCard: $showOptionsCard
            )
            
            if showOptionsCard {
                AlbumOptionsCard(
                    showOptionsCard: $showOptionsCard,
                    showAddToPlaylistSheet: $showAddToPlaylistSheet
                )
            }
            
            if let selectedArtist = selectedArtist {
                ArtistDetail(artist: .constant(selectedArtist))
            }
        }
        .sheet(isPresented: $showAddToPlaylistSheet) {
            AddToPlaylistSheet()
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func loadAlbumMeta(_ album: Release) async {
        guard let albumTitle = album.title, let artistName = album.artistName else { return }

        do {
            // Fetch album artwork
            album.artworkUrl = await iTunesAPI.lookupAlbumArtwork(album)

            // Fetch related albums and tracks
            related = await iTunesAPI.lookupRelatedAlbums(Int(album.artistAppleId))
                .map { store.mapAlbumDataToLibraryModel($0) }
            tracks = await iTunesAPI.lookupTracksForAlbum(Int(album.appleId))

            // Fetch metadata from MusicBrainz
            if album.upc == nil {
                let metadata = try await mbAPI.requestMetadata(albumTitle, artistName)
                if let firstMetadata = metadata.first, let barcode = firstMetadata.barcode, !barcode.isEmpty {
                    album.upc = barcode
                    album.artistMbId = firstMetadata.artistcredit?.first?.artist?.id
                }
            }

            store.saveData()
        } catch {
            print("Error loading album metadata: \(error.localizedDescription)")
        }
    }
}

struct AlbumScrollView: View {
    @Binding var tracks: [iTunesTrack]
    @Binding var related: [Release]
    @Binding var shouldScrollToTop: Bool
    @Binding var selectedArtist: Artist?
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollOffsetObserver(showsIndicators: false, offset: .constant(.zero)) {
                VStack(spacing: 20) {
                    AlbumMeta(selectedArtist: $selectedArtist)
                    AlbumActions()
                    
                    if !tracks.isEmpty {
                        AlbumTracklist(tracks: $tracks)
                    }
                    
                    if !related.isEmpty {
                        RelatedAlbums(related: $related) {
                            shouldScrollToTop.toggle()
                        }
                    }
                    
                    Spacer().frame(height: 10)
                }
                .id("meta")
                .onChange(of: shouldScrollToTop) { _ in
                    withAnimation {
                        reader.scrollTo("meta", anchor: .top)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.top, 40)
            .background(Color(.systemBackground))
        }
    }
}

