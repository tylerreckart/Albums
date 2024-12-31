//
//  MusicBrainzAPI.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import Alamofire

// MARK: - Models

/// Represents additional media metadata from MusicBrainz for a release.
struct MusicBrainzMediaMetadata: Codable {
    var format: String
    var disccount: Int
    var trackcount: Int
     
    enum CodingKeys: String, CodingKey {
        case format
        case disccount = "disc-count"
        case trackcount = "track-count"
    }
}

/// Represents a basic Artist object in the MusicBrainz API.
struct MusicBrainzArtist: Codable {
    var id: String?
    var name: String?
}

/// A container for artist name and a nested `MusicBrainzArtist`.
struct MusicBrainzArtistCredit: Codable {
    var name: String?
    var artist: MusicBrainzArtist?
}

/// Represents the core metadata of a MusicBrainz release.
struct MusicBrainzMetadata: Codable {
    var barcode: String? = ""
    var title: String? = ""
    var artistcredit: [MusicBrainzArtistCredit]? = []
    
    enum CodingKeys: String, CodingKey {
        case barcode
        case title
        case artistcredit = "artist-credit"
    }
}

/// Represents the structure of a MusicBrainz metadata response.
struct MusicBrainzMetadataResponse: Decodable {
    var created: String
    var count: Int
    var offset: Int
    var releases: [MusicBrainzMetadata]
}

// MARK: - Enums

/// The type of term to search within MusicBrainz (album, ep, single).
enum TermType: String {
    case album
    case ep
    case single
}

/// An error type covering possible MusicBrainz API failures.
enum MusicBrainzAPIError: Error {
    case invalidResponse
    case decodingError
    case networkError(String)
}

// MARK: - MusicBrainzAPI Class

/// A class responsible for querying the MusicBrainz API and parsing release metadata.
class MusicBrainzAPI: ObservableObject {
    
    // MARK: - Private Helpers
    
    /// Sanitizes an input string for use in a MusicBrainz request.
    /// Removes substrings like " - Single", " - EP", and bracketed text `(...)`.
    /// - Parameters:
    ///   - input: The original string to be sanitized (e.g., album title or artist name).
    ///   - isArtist: A flag (default: `false`) indicating if the input is an artist name.
    /// - Returns: A sanitized, percent-encoded string safe for query usage.
    private func sanitizeInput(_ input: String, isArtist: Bool = false) -> String {
        let sanitized = input
            .replacingOccurrences(of: " - Single", with: "")
            .replacingOccurrences(of: " - EP", with: "")
            .replacingOccurrences(of: "\\s?\\([\\w\\s]*\\)", with: "", options: .regularExpression)
        
        // Safely encode for URLs
        return sanitized.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    /// Calculates a "confidence score" (0.0 to 1.0) between a search term and a release title.
    /// - Parameters:
    ///   - term: The original search term (e.g., "Lover").
    ///   - title: The release title from MusicBrainz.
    /// - Returns: A fractional match (0.0 to 1.0) measuring how many words overlap.
    private func calculateConfidence(for term: String, title: String?) -> Double {
        guard let title = title else { return 0.0 }
        
        let termParts = Set(term.split(separator: " "))
        let titleParts = Set(title.split(separator: " "))
        let commonWords = termParts.intersection(titleParts).count
        
        // Avoid divide-by-zero if the titleParts set is empty
        guard !titleParts.isEmpty else { return 0.0 }
        
        return Double(commonWords) / Double(titleParts.count)
    }
    
    // MARK: - Public Method
    
    /// Requests release metadata from MusicBrainz that best matches a given album title and artist.
    /// Filters out releases that lack a barcode, then returns only those with > 0.75 confidence.
    /// - Parameters:
    ///   - term: The album name or release title (e.g., "Lover").
    ///   - artist: The artist name (e.g., "Taylor Swift").
    /// - Throws: `MusicBrainzAPIError` if a network or decoding error occurs.
    /// - Returns: Up to one-element array of `MusicBrainzMetadata` if a match is found, or an empty array.
    public func requestMetadata(_ term: String, _ artist: String) async throws -> [MusicBrainzMetadata] {
        let sanitizedTerm = sanitizeInput(term)
        let sanitizedArtist = sanitizeInput(artist, isArtist: true)
        
        let query = "release?query=release:\(sanitizedTerm)%20AND%20artistName:\(sanitizedArtist)&fmt=json"
        let urlString = "https://musicbrainz.org/ws/2/\(query)"
        
        do {
            // Request and decode
            let response = try await AF
                .request(urlString)
                .serializingDecodable(MusicBrainzMetadataResponse.self)
                .value
            
            // Filter out releases without a barcode
            let releasesWithBarcode = response.releases.filter { metadata in
                guard let barcode = metadata.barcode else { return false }
                return !barcode.isEmpty
            }
            
            // Further filter by matching confidence
            let confidentMatches = releasesWithBarcode.filter { metadata in
                calculateConfidence(for: term, title: metadata.title) > 0.75
            }
            
            // If no confident matches, return empty array. Otherwise return the first match.
            return confidentMatches.isEmpty ? [] : [confidentMatches[0]]
            
        } catch {
            // Wrap Alamofire or decoding errors in a custom MusicBrainzAPIError
            throw MusicBrainzAPIError.networkError("Failed to fetch metadata: \(error.localizedDescription)")
        }
    }
}

