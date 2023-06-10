//
//  AlbumsAPI.swift
//  Albums
//
//  Created by Tyler Reckart on 5/24/23.
//

import Foundation
import CoreData
import SwiftUI

class AlbumsAPI: ObservableObject {
    @Published var container: NSPersistentContainer
    
    // Data Stores.
    @Published var presentAlbum: Bool = false
    @Published var activeAlbum: Release?
    @Published var library: [Release] = []
    @Published var wantlist: [Release] = []
    @Published var recentSearches: [RecentView] = []
    // Filters
    @Published var filter: LibraryFilter = .library
    
    enum LibraryFilter: String {
        case library
        case wantlist
        case playlists
    }

    subscript(filter: String) -> [Release] {
        get {
            if filter == "library" { return library }
            if filter == "wantlist" { return wantlist }
            return library
        }
    }
    
    init() {
        let me = "AlbumsAPI.init(): "
        container = NSPersistentContainer(name:"Albums")
        container.loadPersistentStores {( description, error) in
            if let error = error {
                print(me + "ERROR LOADING DATA: \(error)")
            } else {
                print(me + "Sucessfully loaded Core Data")
            }
        }
        fetchAlbumsForLibrary()
        fetchAlbumsForWantlist()
        fetchRecentSearches()
    }
    
    public func setFilter(_ filter: LibraryFilter) -> Void {
        self.filter = filter
    }
    
    private func fetchAlbumsForLibrary() -> Void {
        let me = "AlbumsAPI.fetchAlbumsForLibrary(): "
        let request: NSFetchRequest<Release> = Release.fetchRequest()
        request.predicate = NSPredicate(format: "owned == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Release.dateAdded, ascending: false)]

        do {
            self.library = try container.viewContext.fetch(request)
            print(me + "success")
        } catch let error {
            print(me + "error \(error)")
        }
    }
    
    private func fetchAlbumsForWantlist() -> Void {
        let me = "AlbumsAPI.fetchAlbumsForWantlist(): "
        let request: NSFetchRequest<Release> = Release.fetchRequest()
        request.predicate = NSPredicate(format: "wantlisted == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Release.dateAdded, ascending: false)]

        do {
            self.wantlist = try container.viewContext.fetch(request)
            print(me + "success")
        } catch let error {
            print(me + "error \(error)")
        }
    }
    
    public func fetchRecentSearches() -> Void {
        let me = "AlbumsAPI.fetchRecentSearches(): "
        let request: NSFetchRequest<RecentView> = RecentView.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RecentView.timestamp, ascending: false)]
        request.fetchLimit = 10
        
        do {
            self.recentSearches = try container.viewContext.fetch(request)
            print(me + "success")
        } catch let error {
            print(me + "error \(error)")
        }
    }
    
    public func mapAlbumDataToLibraryModel(_ iTunesData: iTunesAlbum, upc: String? = nil) -> Release {
        let album = Release(context: container.viewContext)
    
        album.appleId = Double(iTunesData.collectionId!)
        album.artistAppleId = Double(iTunesData.amgArtistId ?? 0)
        album.artistName = iTunesData.artistName
        album.artworkUrl = iTunesData.artworkUrl100
        album.dateAdded = Date()
        album.favorite = false
        album.genre = iTunesData.primaryGenreName
        album.owned = false
        album.plays = 0
        album.releaseDate = iTunesData.releaseDate
        album.title = iTunesData.collectionName
        album.wantlisted = false
        album.upc = upc
        
        return album
    }

    public func addAlbumToLibrary(_ album: Release) -> Void {
        let me = "AlbumsAPI.addAlbumToLibrary(): "
        activeAlbum?.owned = true
        activeAlbum?.wantlisted = false
        print(me + activeAlbum.debugDescription)
        
        saveData()
    }
    
    public func addAlbumToWantlist(_ album: Release) -> Void {
        let me = "AlbumsAPI.addAlbumToLibrary(): "
        activeAlbum?.owned = false
        activeAlbum?.wantlisted = true
        print(me + activeAlbum.debugDescription)
        
        saveData()
    }
    
    public func removeAlbum(_ album: Release) -> Void {
        let me = "AlbumsAPI.removeAlbum(): "
        activeAlbum?.owned = false
        activeAlbum?.wantlisted = false
        print(me + album.title!)
        saveData()
    }
    
    public func saveRecentSearch(_ album: Release) -> Void {
        let search = RecentView(context: container.viewContext)
        search.timestamp = Date()
//        search.album = album
        saveData()
    }
    
    public func clearRecentSearches() -> Void {
        for search in recentSearches {
            container.viewContext.delete(search)
        }
        saveData()
    }
    
    public func setActiveAlbum(_ album: Release?) -> Void {
        if album != nil {
            self.activeAlbum = album
            
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 1)) {
                self.presentAlbum = true
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.activeAlbum = album
            }
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 1)) {
                self.presentAlbum = false
            }
        }
    }

    public func saveData() {
        do {
          try container.viewContext.save()
            fetchAlbumsForLibrary()
            fetchAlbumsForWantlist()
            fetchRecentSearches()
        } catch let error {
            print("Error saving... \(error)")
        }
    }
}
