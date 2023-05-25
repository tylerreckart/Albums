//
//  AlbumDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit
import CoreData

struct UIButton: View {
    var text: String
    var action: () -> Void
    var foreground: Color = .white
    var background: Color

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(foreground)
                .padding()
                .frame(maxWidth: .infinity)
                .background(background)
                .cornerRadius(10)
        }
    }
}

struct AlbumDetail: View {
    @EnvironmentObject var store: AlbumsCommon
    @EnvironmentObject var iTunesAPI: iTunesAPI
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var viewContext: NSManagedObjectContext?
    @State private var related: [LibraryAlbum] = []
    @State private var tracks: [iTunesTrack] = []
    
    var album: LibraryAlbum
    var searchResult: Bool = false

    
    func dateFromReleaseStr(_ str: String) -> String {
        let dateFormatter = DateFormatter()
        let date = dateFormatter.date(from: str)
        return (date ?? Date()).formatted(date: .long, time: .omitted)
    }
    
    @State private var scrollOffset = CGPoint()

    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                VStack(spacing: 20) {
                    VStack(spacing: 5) {
                        AsyncImage(url: URL(string: (store.activeAlbum?.artworkUrl!) ?? "")) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 320, height: 320)
                        .cornerRadius(6)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                        
                        Text((store.activeAlbum?.title!) ?? "")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text((store.activeAlbum?.artistName!) ?? "")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("PrimaryPurple"))
                        
                        HStack(alignment: .center, spacing: 5) {
                            Text(store.activeAlbum?.genre ?? "")
                            Circle()
                                .fill(Color(.gray))
                                .frame(width: 3, height: 3)
                            Text(dateFromReleaseStr(store.activeAlbum?.releaseDate ?? ""))
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("PrimaryGray"))
                    }
                    .padding(.horizontal)

                    VStack(spacing: 10) {
                        UIButton(
                            text: store.activeAlbum?.owned != true ? "Add to Library" : "Remove from Library",
                            action: {
                                if store.activeAlbum?.owned != true {
                                    store.addAlbumToLibrary(store.activeAlbum!)
                                } else {
                                    store.removeAlbum(store.activeAlbum!)
                                }
                            },
                            foreground: store.activeAlbum?.owned != true ? .white : Color("PrimaryPurple"),
                            background: store.activeAlbum?.owned != true ? Color("PrimaryPurple") : Color(.systemGray6)
                        )
                        
                        if store.activeAlbum?.owned != true {
                            UIButton(
                                text: store.activeAlbum?.wantlisted != true ? "Add to Wantlist" : "Remove from Wantlist",
                                action: {
                                    if store.activeAlbum?.wantlisted != true {
                                        store.addAlbumToWantlist(store.activeAlbum!)
                                    } else {
                                        store.removeAlbum(store.activeAlbum!)
                                    }
                                },
                                foreground: Color("PrimaryPurple"),
                                background: Color(.systemGray6)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    if self.tracks.count > 0 {
                        VStack {
                            HStack {
                                Text("Tracks")
                                    .font(.system(size: 18, weight: .bold))
                                Spacer()
                            }
                            .padding(.horizontal)
                            VStack(spacing: 0) {
                                ForEach(tracks, id: \.self) { track in
                                    VStack(spacing: 0) {
                                        HStack(alignment: .top, spacing: 10) {
                                            Text("\(track.trackNumber!).")
                                                .font(.system(size: 14, weight: .bold))
                                                .padding(.leading)
                                            VStack(spacing: 0) {
                                                HStack {
                                                    Text(track.trackCensoredName!.trunc(length: 30))
                                                        .font(.system(size: 14, weight: .regular))
                                                    Spacer()
                                                    Text(track.primaryGenreName!)
                                                        .font(.system(size: 12, weight: .regular))
                                                        .foregroundColor(Color("PrimaryGray"))
                                                }
                                                .padding(.trailing)
                                                
                                                HStack {
                                                    Text("\(track.trackTimeMillis!)")
                                                        .font(.system(size: 12, weight: .regular))
                                                        .foregroundColor(Color("PrimaryGray"))
                                                    Spacer()
                                                }
                                                .padding(.bottom, 12)
                                                
                                                Rectangle()
                                                    .fill(Color(.systemGray5))
                                                    .frame(height: 0.5)
                                            }
                                        }
                                        .padding(.top, 12)
                                    }
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    
                    if self.related.count > 0 {
                        VStack(spacing: 10) {
                            HStack {
                                Text("More by \(store.activeAlbum?.artistName ?? "")")
                                    .font(.system(size: 18, weight: .bold))
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                VStack(spacing: 0) {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 1)
                                
                                    HStack(alignment: .top, spacing: 16) {
                                        ForEach(related, id: \.self) { a in
                                            VStack {
                                                Button(action: {
                                                    withAnimation { store.setActiveAlbum(a) }
                                                }) {
                                                    AlbumGridItem(album: a)
                                                        .frame(maxWidth: 200)
                                                }
                                                .foregroundColor(.primary)
                                                
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding([.horizontal, .top])
                                    .padding(.bottom, 10)
                                }
                            }
                            .frame(height: 300)
                            .background(Color(.systemGray6))
                            .edgesIgnoringSafeArea(.bottom)
                        }
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
                                .font(.system(size: 15, weight: .black))
                        }
                    }
                }
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.white))
        .onAppear {
            store.setActiveAlbum(album)

            Task {
                await iTunesAPI.lookupAlbumArtwork(store.activeAlbum!)
                let relatedAlbums = await iTunesAPI.lookupRelatedAlbums(Int(store.activeAlbum!.artistAppleId))
                self.related = relatedAlbums.map { store.mapAlbumDataToLibraryModel($0) }
                self.tracks = await iTunesAPI.lookupTracksForAlbum(Int(store.activeAlbum!.appleId))
                print(tracks)
            }
            
            if searchResult == true {
                store.saveRecentSearch(album)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}

