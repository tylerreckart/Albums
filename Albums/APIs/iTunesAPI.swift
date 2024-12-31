//
//  iTunesAPI.swift
//  Albums
//
//  Created by Tyler Reckart on 5/21/23.
//  Refactored by ChatGPT to include album artwork caching on 01/01/2024
//

import Foundation
import Alamofire

/// Example model for top-albums feed. Adjust to your RSS feed structure as needed.
struct iTunesFeedAlbum: Codable, Hashable {
    var id: String
    var artworkUrl100: String
}

struct iTunesFeed: Codable {
    var results: [iTunesFeedAlbum]
}

struct iTunesFeedResponse: Decodable {
    var feed: iTunesFeed
}

// MARK: - Custom Errors

/// An enum describing potential errors from iTunesAPI.
enum iTunesAPIError: Error, LocalizedError {
    case networkError(String)
    case invalidURL
    case noResultsFound
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            // If the underlying error message is empty, provide a fallback.
            if message.isEmpty {
                return "A network error occurred, but no details were provided."
            } else {
                return "Network Error: \(message)"
            }
        case .invalidURL:
            return "The URL for the request was invalid."
        case .noResultsFound:
            return "No results were found for your request."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

// MARK: - Example Release Model

/// This `Release` struct is just an example to show how you might have
/// a local model with an `appleId`. Replace or adjust to match your actual codebase.
struct AlbumsRelease {
    var appleId: Int
    // Add other properties (e.g., album name, artist name, etc.)...
}

// MARK: - iTunesAPI

/// A class providing async methods to interact with the iTunes Search API.
/// Includes in-memory caching for various lookups to reduce repeated network calls.
class iTunesAPI: ObservableObject {
    
    // MARK: - Caching Durations
    
    /// Cache duration for generic searches (e.g., 5 minutes).
    private let searchCacheDuration: TimeInterval = 5 * 60
    
    /// Cache duration for artist lookups, UPC lookups, and album artwork (30 days).
    private let longCacheDuration: TimeInterval = 30 * 24 * 60 * 60
    
    // MARK: - In-memory Caches
    
    /// An in-memory cache for album searches keyed by "search-\(term)-\(country)".
    private var searchCache: [String: (results: [iTunesAlbum], expiry: Date)] = [:]
    
    /// An in-memory cache for artist lookups keyed by "artist-\(id)".
    private var artistCache: [String: (results: [iTunesArtist], expiry: Date)] = [:]
    
    /// An in-memory cache for UPC lookups keyed by "upc-\(upc)".
    private var upcCache: [String: (album: iTunesAlbum, expiry: Date)] = [:]
    
    /// An in-memory cache for album artwork keyed by "artwork-\(appleId)".
    /// Stores the resulting URL string and an expiry date.
    private var albumArtworkCache: [String: (url: String, expiry: Date)] = [:]
    
    // MARK: - Public API Methods
    
    // --------------------------------------------------------------------
    // 1) Fetch Top Albums
    // --------------------------------------------------------------------
    
    /// Fetches the top albums from Apple's RSS feed for a given country and limit.
    /// - Parameters:
    ///   - limit: The number of albums to retrieve (defaults to 20).
    ///   - countryCode: The two-letter country code (defaults to "us").
    /// - Returns: An array of `iTunesFeedAlbum`.
    public func fetchTopAlbums(limit: Int = 20, countryCode: String = "us") async throws -> [iTunesFeedAlbum] {
        let urlString = "https://rss.applemarketingtools.com/api/v2/\(countryCode.lowercased())/music/most-played/\(limit)/albums.json"
        
        // Make the request
        let response: iTunesFeedResponse = try await request(urlString)
        
        // Optionally transform artwork URL here if needed
        // For example, resize from "100x100" to "256x256"
        let updatedResults = response.feed.results.map { album -> iTunesFeedAlbum in
            var mutableAlbum = album
            mutableAlbum.artworkUrl100 = resizedArtworkURL(mutableAlbum.artworkUrl100, width: 256, height: 256)
            return mutableAlbum
        }
        
        return updatedResults
    }
    
    // --------------------------------------------------------------------
    // 2) Search for Albums (cached for 5 minutes)
    // --------------------------------------------------------------------
    
    /// Searches iTunes for albums matching the given term.
    /// Uses a 5-minute cache to avoid repeated calls in a short time window.
    /// - Parameters:
    ///   - term: The search term, e.g., "Taylor Swift".
    ///   - countryCode: The two-letter country code (defaults to "US").
    /// - Returns: An array of `iTunesAlbum`.
    public func search(_ term: String, countryCode: String = "US") async throws -> [iTunesAlbum] {
        let cacheKey = "search-\(term.lowercased())-\(countryCode.lowercased())"
        
        // Check for valid cached results first
        if let cachedData = searchCache[cacheKey], Date() < cachedData.expiry {
            debugPrint("Returning cached search results for key: \(cacheKey)")
            return cachedData.results
        }
        
        // Build the query
        let query = "search?term=\(encode(term))&country=\(countryCode)&media=music&entity=album"
        let urlString = "https://itunes.apple.com/\(query)"
        
        // Fetch from the network
        let response: iTunesAlbumsSearchResponse = try await request(urlString)
        
        // Cache the new results with 5-min expiry
        let expiryDate = Date().addingTimeInterval(searchCacheDuration)
        searchCache[cacheKey] = (response.results, expiryDate)
        
        return response.results
    }
    
    // --------------------------------------------------------------------
    // 3) Artist Search (not cached by default, but you could add short-term caching)
    // --------------------------------------------------------------------
    
    /// Searches iTunes for artists matching the given term.
    /// This is a different endpoint (`musicArtist`) but works similarly to album searches.
    /// - Parameters:
    ///   - term: The search term, e.g., "Adele".
    ///   - countryCode: The two-letter country code (defaults to "US").
    /// - Returns: An array of `iTunesArtist`.
    public func artistSearch(_ term: String, countryCode: String = "US") async throws -> [iTunesArtist] {
        let query = "search?term=\(encode(term))&country=\(countryCode)&media=music&entity=musicArtist"
        let urlString = "https://itunes.apple.com/\(query)"
        
        let response: iTunesArtistLookupResponse = try await request(urlString)
        return response.results
    }
    
    // --------------------------------------------------------------------
    // 4) Lookup by UPC (Cached for 30 days)
    // --------------------------------------------------------------------
    
    /// Looks up an album on iTunes by UPC code. Caches the first album found for 30 days.
    /// - Parameter upc: The UPC code to lookup.
    /// - Returns: The first matching `iTunesAlbum`, or `nil` if none found.
    public func lookupUPC(_ upc: String) async throws -> iTunesAlbum? {
        let cacheKey = "upc-\(upc.lowercased())"
        
        // Check if the UPC is in cache and hasn't expired
        if let cachedEntry = upcCache[cacheKey], Date() < cachedEntry.expiry {
            debugPrint("Returning cached UPC data for key: \(cacheKey)")
            return cachedEntry.album
        }
        
        // Build the query
        let query = "lookup?upc=\(upc)"
        let urlString = "https://itunes.apple.com/\(query)"
        
        let response: iTunesAlbumsSearchResponse = try await request(urlString)
        
        guard let firstAlbum = response.results.first else {
            // If no results, return nil
            return nil
        }
        
        // Cache the album for 30 days
        let expiryDate = Date().addingTimeInterval(longCacheDuration)
        upcCache[cacheKey] = (firstAlbum, expiryDate)
        
        return firstAlbum
    }
    
    // --------------------------------------------------------------------
    // 5) Lookup Artist by AMG ID (Cached for 30 days)
    // --------------------------------------------------------------------
    
    /// Looks up an artist on iTunes by the AMG Artist ID. Caches the result for 30 days.
    /// - Parameter id: The AMG Artist ID (e.g., 468749 for Adele).
    /// - Returns: An array of `iTunesArtist`.
    public func lookupArtist(_ id: Double) async throws -> [iTunesArtist] {
        let cacheKey = "artist-\(Int(id))"
        
        // Check if the AMG Artist ID is in cache and hasn't expired
        if let cachedEntry = artistCache[cacheKey], Date() < cachedEntry.expiry {
            debugPrint("Returning cached artist data for key: \(cacheKey)")
            return cachedEntry.results
        }
        
        // Build the query
        let query = "lookup?amgArtistId=\(Int(id))"
        let urlString = "https://itunes.apple.com/\(query)"
        
        let response: iTunesArtistLookupResponse = try await request(urlString)
        
        // Cache the results for 30 days
        let expiryDate = Date().addingTimeInterval(longCacheDuration)
        artistCache[cacheKey] = (response.results, expiryDate)
        
        return response.results
    }
    
    // --------------------------------------------------------------------
    // 6) Lookup Related Albums (not cached, but you can replicate the pattern)
    // --------------------------------------------------------------------
    
    /// Looks up related albums for the given AMG Artist ID.
    /// - Parameters:
    ///   - id: The AMG Artist ID.
    ///   - limit: The number of related albums to fetch (defaults to 5).
    /// - Returns: A list of `iTunesAlbum` objects where `wrapperType` == `"collection"`.
    public func lookupRelatedAlbums(_ id: Int, limit: Int = 5) async throws -> [iTunesAlbum] {
        let query = "lookup?amgArtistId=\(id)&entity=album&limit=\(limit)"
        let urlString = "https://itunes.apple.com/\(query)"
        
        let response: iTunesAlbumsSearchResponse = try await request(urlString)
        
        // Filter and optionally resize artwork
        let filtered = response.results.filter { $0.wrapperType == "collection" }
        let transformed = filtered.map { album -> iTunesAlbum in
            var mutableAlbum = album
            if let artworkUrl = album.artworkUrl100 {
                mutableAlbum.artworkUrl100 = resizedArtworkURL(artworkUrl, width: 1024, height: 1024)
            }
            return mutableAlbum
        }
        
        return transformed
    }
    
    // --------------------------------------------------------------------
    // 7) Lookup Tracks for an Album (not cached by default)
    // --------------------------------------------------------------------
    
    /// Looks up tracks for a given iTunes album ID.
    /// - Parameter id: The iTunes collection ID for the album.
    /// - Returns: A list of `iTunesTrack` objects where `wrapperType` == "track".
    public func lookupTracksForAlbum(_ id: Int) async throws -> [iTunesTrack] {
        let query = "lookup?id=\(id)&entity=song"
        let urlString = "https://itunes.apple.com/\(query)"
        
        let response: iTunesTrackLookupResponse = try await request(urlString)
        return response.results.filter { $0.wrapperType == "track" }
    }
    
    // --------------------------------------------------------------------
    // 8) Lookup Album Artwork (Cached for 30 days)
    // --------------------------------------------------------------------
    
    /// Retrieves a high-resolution album artwork from iTunes for a given local `Release`.
    /// Caches the retrieved artwork URL for 30 days so it doesn't get re-downloaded repeatedly.
    /// - Parameter album: A `Release` object that has an `appleId`.
    /// - Returns: A `String` with the updated artwork URL, or an empty string if not found.
    public func lookupAlbumArtwork(_ album: Release) async throws -> String {
        let cacheKey = "artwork-\(album.appleId)"
        
        // 1) Check if artwork is in cache and hasn't expired
        if let cachedArtwork = albumArtworkCache[cacheKey], Date() < cachedArtwork.expiry {
            debugPrint("Returning cached album artwork for key: \(cacheKey)")
            return cachedArtwork.url
        }
        
        // 2) Build the query
        let query = "lookup?id=\(album.appleId)&country=us&limit=25"
        let urlString = "https://itunes.apple.com/\(query)"
        
        // 3) Fetch data from the network
        let response: iTunesAlbumsSearchResponse = try await request(urlString)
        
        // 4) Parse the first album's artwork
        guard let firstAlbum = response.results.first,
              let baseArtworkUrl = firstAlbum.artworkUrl100 else {
            return ""
        }
        
        // 5) Resize to 1024x1024 (or any dimension you prefer)
        let updatedArtworkUrl = resizedArtworkURL(baseArtworkUrl, width: 1024, height: 1024)
        
        debugPrint("Album artwork retrieved from network: \(updatedArtworkUrl)")
        
        // 6) Cache the artwork URL for 30 days
        let expiryDate = Date().addingTimeInterval(longCacheDuration)
        albumArtworkCache[cacheKey] = (updatedArtworkUrl, expiryDate)
        
        // 7) Return the updated artwork URL
        return updatedArtworkUrl
    }
    
    // MARK: - Generic Network Helper
    
    /// A generic async function to perform a GET request and decode the response.
    /// - Parameter urlString: The URL string to request.
    /// - Throws: `iTunesAPIError` if there are networking or decoding problems.
    /// - Returns: A decoded object of type `T`.
    private func request<T: Decodable>(_ urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw iTunesAPIError.invalidURL
        }
        
        do {
            let decoded: T = try await AF
                .request(url)
                .serializingDecodable(T.self)
                .value
            return decoded
        } catch {
            throw iTunesAPIError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Utility Methods
    
    /// Replaces "100x100" in an artwork URL with a custom size (width x height).
    /// - Parameters:
    ///   - url: The original URL string, possibly nil.
    ///   - width: The desired width in pixels.
    ///   - height: The desired height in pixels.
    /// - Returns: A transformed URL string with the requested dimensions, or an empty string if `url` was nil.
    private func resizedArtworkURL(_ url: String?, width: Int, height: Int) -> String {
        guard let url = url else {
            return ""
        }
        return url.replacingOccurrences(of: "100x100", with: "\(width)x\(height)")
    }
    
    /// Percent-encodes a string for use in query parameters.
    private func encode(_ term: String) -> String {
        term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? term
    }
}
