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
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
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
                print(relatedAlbums)
            }
            
            if searchResult == true {
                store.saveRecentSearch(album)
            }
        }
        .navigationBarHidden(true)
    }
}

