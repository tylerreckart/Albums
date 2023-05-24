//
//  AlbumDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit
import CoreData

func mapAlbumsAlbumToLibraryStruct(_ target: AlbumsAlbum, wantlisted: Bool = false, owned: Bool = true, viewContext: NSManagedObjectContext) -> LibraryAlbum {
    let tmp = LibraryAlbum(context: viewContext)
    tmp.appleId = Double(target.appleId)
    tmp.artistAppleId = Double(target.artistId)
    tmp.artistName = target.artistName
    tmp.title = target.name
    tmp.genre = target.genre
    tmp.artworkUrl = target.artworkUrl
    tmp.playCount = Double(0)
    tmp.wantlisted = wantlisted
    tmp.owned = owned
    tmp.dateAdded = Date()
    return tmp
}

struct AlbumDetail: View {
    @EnvironmentObject var store: AlbumsViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var viewContext: NSManagedObjectContext?
    
    var album: LibraryAlbum

    
    func dateFromReleaseStr(_ str: String) -> String {
        let dateFormatter = DateFormatter()
        let date = dateFormatter.date(from: str)
        return (date ?? Date()).formatted(date: .long, time: .omitted)
    }
    
    private func addToWantlist(_ target: LibraryAlbum) {
        withAnimation {
            target.owned = false
            target.wantlisted = true
            do {
                try viewContext!.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
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
                        .padding([.bottom, .top], 10)
                        
                        Text((store.activeAlbum?.title!) ?? "")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text((store.activeAlbum?.artistName!) ?? "")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("PrimaryRed"))
                        
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

                    HStack(spacing: 10) {
                        Button(action: { store.addAlbumToLibrary((store.activeAlbum)!) }) {
                            Text("Add To Library")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("PrimaryRed"))
                                .cornerRadius(10)
                        }
                        
                        Button(action: { store.addAlbumToWantlist((store.activeAlbum)!) }) {
                            Text("Add To Wantlist")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray3))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
            .padding(.top, 55)
            
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
                await iTunesRequestService().lookupAlbumArtwork(store.activeAlbum!)
            }
        }
        .navigationBarHidden(true)
    }
}

