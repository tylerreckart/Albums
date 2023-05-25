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
    @EnvironmentObject var store: AlbumsViewModel
    @EnvironmentObject var iTunesAPI: iTunesRequestService
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var viewContext: NSManagedObjectContext?
    @State private var related: [LibraryAlbum] = []
    
    var album: LibraryAlbum
    var searchResult: Bool = false

    
    func dateFromReleaseStr(_ str: String) -> String {
        let dateFormatter = DateFormatter()
        let date = dateFormatter.date(from: str)
        return (date ?? Date()).formatted(date: .long, time: .omitted)
    }

    var body: some View {
        ZStack {
            ScrollView {
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
                                .frame(width: 4, height: 4)
                            Text(dateFromReleaseStr(store.activeAlbum?.releaseDate ?? ""))
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
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
                            background: Color("PrimaryPurple")
                        )
                        
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
                            background: Color(.systemGray5)
                        )
                    }
                    .padding(.horizontal)
                    
                    if self.related.count > 0 {
                        VStack(spacing: 10) {
                            HStack {
                                Text("More by \(store.activeAlbum?.artistName ?? "")")
                                    .font(.system(size: 18, weight: .bold))
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 20) {
                                    ForEach(related, id: \.self) { a in
                                        VStack {
                                            Button(action: {
                                                withAnimation { store.setActiveAlbum(a) }
                                            }) {
                                                AlbumGridItem(album: a)
                                                    .frame(maxWidth: 175)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                                .padding([.horizontal, .top])
                                .padding(.bottom, 10)
                            }
                            .frame(height: 300)
                            .background(Color(.systemGray5))
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
            }
            
            if searchResult == true {
                store.saveRecentSearch(album)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}

