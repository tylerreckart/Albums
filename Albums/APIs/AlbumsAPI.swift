//
//  AlbumsAPI.swift
//  Albums
//
//  Created by Tyler Reckart on 5/24/23.
//

import Foundation
import CoreData

class AlbumsAPI: ObservableObject {
    let container: NSPersistentContainer
    
    // Data Stores.
    @Published var activeAlbum: LibraryAlbum?
    @Published var library: [LibraryAlbum] = []
    @Published var wantlist: [LibraryAlbum] = []
    @Published var recentSearches: [RecentSearch] = []
    // Filters
    @Published var filter: LibraryFilter = .library
    
    enum LibraryFilter: String {
        case library
        case wantlist
    }

    subscript(filter: String) -> [LibraryAlbum] {
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
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "owned == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: false)]

        do {
            self.library = try container.viewContext.fetch(request)
            print(me + "success")
        } catch let error {
            print(me + "error \(error)")
        }
    }
    
    private func fetchAlbumsForWantlist() -> Void {
        let me = "AlbumsAPI.fetchAlbumsForWantlist(): "
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "wantlisted == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: false)]

        do {
            self.wantlist = try container.viewContext.fetch(request)
            print(me + "success")
        } catch let error {
            print(me + "error \(error)")
        }
    }
    
    public func fetchRecentSearches() -> Void {
        let me = "AlbumsAPI.fetchRecentSearches(): "
        let request: NSFetchRequest<RecentSearch> = RecentSearch.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RecentSearch.timestamp, ascending: false)]
        request.fetchLimit = 10
        
        do {
            self.recentSearches = try container.viewContext.fetch(request)
            print(me + "success")
        } catch let error {
            print(me + "error \(error)")
        }
    }
    
    public func mapAlbumDataToLibraryModel(_ iTunesData: iTunesAlbum, upc: String? = nil) -> LibraryAlbum {
        let album = LibraryAlbum(context: container.viewContext)
    
        album.appleId = Double(iTunesData.collectionId!)
        album.artistAppleId = Double(iTunesData.amgArtistId ?? 0)
        album.artistName = iTunesData.artistName
        album.artworkUrl = iTunesData.artworkUrl100
        album.dateAdded = Date()
        album.favorite = false
        album.genre = iTunesData.primaryGenreName
        album.owned = false
        album.playCount = 0
        album.releaseDate = iTunesData.releaseDate
        album.title = iTunesData.collectionName
        album.wantlisted = false
        album.upc = upc
        
        return album
    }

    public func addAlbumToLibrary(_ album: LibraryAlbum) -> Void {
        let me = "AlbumsAPI.addAlbumToLibrary(): "
        activeAlbum?.owned = true
        activeAlbum?.wantlisted = false
        print(me + activeAlbum.debugDescription)
        
        saveData()
    }
    
    public func addAlbumToWantlist(_ album: LibraryAlbum) -> Void {
        let me = "AlbumsAPI.addAlbumToLibrary(): "
        activeAlbum?.owned = false
        activeAlbum?.wantlisted = true
        print(me + activeAlbum.debugDescription)
        
        saveData()
    }
    
    public func removeAlbum(_ album: LibraryAlbum) -> Void {
        let me = "AlbumsAPI.removeAlbum(): "
        activeAlbum?.owned = false
        activeAlbum?.wantlisted = false
        print(me + album.title!)
        saveData()
    }
    
    public func saveRecentSearch(_ album: LibraryAlbum) -> Void {
        let search = RecentSearch(context: container.viewContext)
        search.timestamp = Date()
        search.album = album
        saveData()
    }
    
    public func clearRecentSearches() -> Void {
        for search in recentSearches {
            container.viewContext.delete(search)
        }
        saveData()
    }
    
    public func setActiveAlbum(_ album: LibraryAlbum?) -> Void {
        self.activeAlbum = album
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
