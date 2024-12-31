//
//  AlbumsAPI.swift
//  Albums
//
//  Created by Tyler Reckart on 5/24/23.
//  Refactored by ChatGPT
//

import Foundation
import CoreData
import SwiftUI

class AlbumsAPI: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var container: NSPersistentContainer
    
    @Published var presentAlbum: Bool = false
    @Published var activeAlbum: Release?
    
    @Published var library: [Release] = []
    @Published var wantlist: [Release] = []
    @Published var recentSearches: [RecentView] = []
    
    @Published var filter: LibraryFilter = .library
    
    // MARK: - Nested Types
    
    enum LibraryFilter: String {
        case library
        case wantlist
        case playlists
    }
    
    // MARK: - Initialization
    
    init() {
        container = NSPersistentContainer(name: "Albums")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("AlbumsAPI: ERROR LOADING DATA – \(error.localizedDescription)")
            } else {
                print("AlbumsAPI: Successfully loaded Core Data.")
            }
        }
        
        // Pre-fetch data
        fetchLibraryAlbums()
        fetchWantlistAlbums()
        fetchRecentSearches()
    }
    
    // MARK: - Filtering
    
    /// Returns the array of `AlbumRelease` objects depending on the specified filter.
    public func albums(for filter: LibraryFilter) -> [Release] {
        switch filter {
        case .library:
            return library
        case .wantlist:
            return wantlist
        case .playlists:
            // If you have playlist logic, return that here. By default, return library.
            return library
        }
    }
    
    public func setFilter(_ newFilter: LibraryFilter) {
        filter = newFilter
    }
    
    // MARK: - Fetch Methods
    
    private func fetchLibraryAlbums() {
        let request: NSFetchRequest<Release> = Release.fetchRequest()
        request.predicate = NSPredicate(format: "owned == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Release.dateAdded, ascending: false)]
        
        do {
            library = try container.viewContext.fetch(request)
            print("AlbumsAPI: Library fetch successful. Total: \(library.count)")
        } catch {
            print("AlbumsAPI: ERROR fetching library – \(error.localizedDescription)")
        }
    }
    
    private func fetchWantlistAlbums() {
        let request: NSFetchRequest<Release> = Release.fetchRequest()
        request.predicate = NSPredicate(format: "wantlisted == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Release.dateAdded, ascending: false)]
        
        do {
            wantlist = try container.viewContext.fetch(request)
            print("AlbumsAPI: Wantlist fetch successful. Total: \(wantlist.count)")
        } catch {
            print("AlbumsAPI: ERROR fetching wantlist – \(error.localizedDescription)")
        }
    }
    
    public func fetchRecentSearches() {
        let request: NSFetchRequest<RecentView> = RecentView.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RecentView.timestamp, ascending: false)]
        request.fetchLimit = 10
        
        do {
            recentSearches = try container.viewContext.fetch(request)
            print("AlbumsAPI: Recent searches fetch successful. Total: \(recentSearches.count)")
        } catch {
            print("AlbumsAPI: ERROR fetching recent searches – \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Mapping
    
    /// Maps `iTunesAlbum` data to a new `AlbumRelease` managed object.
    /// - Parameter iTunesData: The album data from iTunes.
    /// - Parameter upc: Optional UPC code for the album.
    /// - Returns: A new `AlbumRelease` instance in the context of `container.viewContext`.
    public func mapAlbumDataToLibraryModel(_ iTunesData: iTunesAlbum, upc: String? = nil) -> Release {
        let album = Release(context: container.viewContext)
        
        // Safe optional unwrapping
        album.appleId = Double(iTunesData.collectionId ?? 0)
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
    
    // MARK: - Album State Changes
    
    public func addAlbumToLibrary(_ album: Release) {
        album.owned = true
        album.wantlisted = false
        print("AlbumsAPI: Adding album to library: \(album.debugDescription)")
        saveData()
    }
    
    public func addAlbumToWantlist(_ album: Release) {
        album.owned = false
        album.wantlisted = true
        print("AlbumsAPI: Adding album to wantlist: \(album.debugDescription)")
        saveData()
    }
    
    public func removeAlbum(_ album: Release) {
        album.owned = false
        album.wantlisted = false
        print("AlbumsAPI: Removing album: \(album.title ?? "Unknown")")
        saveData()
    }
    
    // MARK: - Recent Searches
    
    public func saveRecentSearch(_ album: Release) {
        let search = RecentView(context: container.viewContext)
        search.timestamp = Date()
        // If you want to relate the album, add logic below:
        // search.album = album
        saveData()
    }
    
    public func clearRecentSearches() {
        for searchRecord in recentSearches {
            container.viewContext.delete(searchRecord)
        }
        saveData()
    }
    
    // MARK: - Active Album Presentation
    
    public func setActiveAlbum(_ album: Release?) {
        if let nonNilAlbum = album {
            activeAlbum = nonNilAlbum
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 1)) {
                presentAlbum = true
            }
        } else {
            // Delay clearing `activeAlbum` for animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.activeAlbum = nil
            }
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 1)) {
                presentAlbum = false
            }
        }
    }
    
    // MARK: - Saving
    
    /// Persists any changes to the `container.viewContext` and refreshes local data arrays.
    public func saveData() {
        do {
            try container.viewContext.save()
            fetchLibraryAlbums()
            fetchWantlistAlbums()
            fetchRecentSearches()
        } catch {
            print("AlbumsAPI: ERROR saving data – \(error.localizedDescription)")
        }
    }
}
