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
    
    @StateObject var mbAPI: MusicBrainzAPI = MusicBrainzAPI()
    
    var album: LibraryAlbum?
    var searchResult: Bool = false
    
    @State private var viewContext: NSManagedObjectContext?
    @State private var related: [LibraryAlbum] = []
    @State private var tracks: [iTunesTrack] = []
    @State private var scrollOffset: CGPoint = CGPoint()
    
    @State private var showOptionsCard: Bool = false
    
    @State private var showAddToPlaylistSheet: Bool = false
    
    @State private var shouldScrollToTop: Bool = false
    
    @State private var showArtistDetail: Bool = false
    
    @State private var selectedArtist: Artist?
    
    var body: some View {
        ZStack {
            if album != nil {
                ScrollViewReader { reader in
                    ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                        VStack(spacing: 20) {
                            AlbumMeta(selectedArtist: $selectedArtist)
                            AlbumActions()
                            
                            if self.tracks.count > 0 {
                                AlbumTracklist(tracks: $tracks)
                            }
                            
                            if self.related.count > 0 {
                                RelatedAlbums(related: $related, scrollToTop: { shouldScrollToTop.toggle() })
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
            } else {
                ProgressView()
            }
                
            AlbumDetailHeader(album: album, scrollOffset: $scrollOffset, showOptionsCard: $showOptionsCard)
                
            if showOptionsCard {
                AlbumOptionsCard(showOptionsCard: $showOptionsCard, showAddToPlaylistSheet: $showAddToPlaylistSheet)
            }
            
            if selectedArtist != nil {
                ArtistDetail(artist: $selectedArtist)
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
        .sheet(isPresented: $showAddToPlaylistSheet, content: { AddToPlaylistSheet() })
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func loadAlbumMeta(state: LibraryAlbum) async -> Void {
        let audioDB = AudioDB(cont: store.container)
        
        let artwork = await iTunesAPI.lookupAlbumArtwork(state)
        
        state.artworkUrl = artwork
        
        self.related = await iTunesAPI.lookupRelatedAlbums(Int(state.artistAppleId)).map { store.mapAlbumDataToLibraryModel($0) }
        self.tracks  = await iTunesAPI.lookupTracksForAlbum(Int(state.appleId))
        
        print("Stored MBID: \(state.artistMbId ?? "")")
        
        if state.upc == nil {
            let data = await mbAPI.requestMetadata(state.title!, state.artistName!)
            print(data)
            
            if !data.isEmpty && data[0].barcode?.count ?? 0 > 0 {
                state.upc = data[0].barcode
                state.artistMbId = data[0].artistcredit![0].artist?.id
                print("Retrived MBID: \(state.artistMbId ?? "")")
            }
        }
        
        if !(state.artistMbId?.isEmpty ?? true && state.artists == nil) {
            let artist = await audioDB.lookupArtist(state.artistMbId!)
            
            if artist != nil {
                artist!.albums = Set(related) as NSSet
                state.artists = [artist!]
            }
        }
        
        store.saveData()
    }
}
