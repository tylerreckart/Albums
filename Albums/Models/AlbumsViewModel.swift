//
//  AlbumViewModel.swift
//  Albums
//
//  Created by Tyler Reckart on 5/24/23.
//

import Foundation
import CoreData

class AlbumsViewModel: ObservableObject {
    let container: NSPersistentContainer
    
    @Published var activeAlbum: LibraryAlbum?
    @Published var library: [LibraryAlbum] = []
    @Published var wantlist: [LibraryAlbum] = []
    @Published var recentSearches: [RecentSearch] = []
    
    init() {
        let me = "AlbumViewModel.init(): "
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
    
    private func fetchAlbumsForLibrary() -> Void {
        let me = "AlbumViewModel.fetchAlbumsForLibrary(): "
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "owned == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: true)]

        do {
            self.library = try container.viewContext.fetch(request)
            print(me + "success")
        } catch let error {
            print(me + "error \(error)")
        }
    }
    
    private func fetchAlbumsForWantlist() -> Void {
        let me = "AlbumViewModel.fetchAlbumsForWantlist(): "
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "wantlisted == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: true)]

        do {
            self.wantlist = try container.viewContext.fetch(request)
            print(me + "success")
        } catch let error {
            print(me + "error \(error)")
        }
    }
    
    public func fetchRecentSearches() -> Void {
        let me = "AlbumViewModel.fetchRecentSearches(): "
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
    
    public func mapAlbumDataToLibraryModel(_ iTunesData: iTunesAlbum) -> LibraryAlbum {
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
        
        return album
    }

    public func addAlbumToLibrary(_ album: LibraryAlbum) -> Void {
        let me = "AlbumViewModel.addAlbumToLibrary(): "
        activeAlbum?.owned = true
        activeAlbum?.wantlisted = false
        print(me + activeAlbum.debugDescription)
        
        saveData()
    }
    
    public func addAlbumToWantlist(_ album: LibraryAlbum) -> Void {
        let me = "AlbumViewModel.addAlbumToLibrary(): "
        activeAlbum?.owned = false
        activeAlbum?.wantlisted = true
        print(me + activeAlbum.debugDescription)
        
        saveData()
    }
    
    public func removeAlbum(_ album: LibraryAlbum) -> Void {
        let me = "AlbumViewModel.removeAlbum(): "
        print(me + album.title!)
        container.viewContext.delete(album)
        saveData()
    }
    
    public func saveRecentSearch(_ album: LibraryAlbum) -> Void {
        let search = RecentSearch(context: container.viewContext)
        search.timestamp = Date()
        search.album = album
        saveData()
    }
    
    public func setActiveAlbum(_ album: LibraryAlbum) -> Void {
        self.activeAlbum = album
    }

    private func saveData() {
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
