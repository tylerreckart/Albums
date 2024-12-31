//
//  iTunesAPI.swift
//  Albums
//
//  Created by Tyler Reckart on 5/21/23.
//

import Foundation
import Alamofire

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

class iTunesAPI: ObservableObject {
    
    public func fetchTopAlbums() async -> [iTunesFeedAlbum] {
        let value = try? await AF
            .request("https://rss.applemarketingtools.com/api/v2/us/music/most-played/20/albums.json")
            .serializingDecodable(iTunesFeedResponse.self)
            .value
        
        let results = value?.feed.results ?? [] as [iTunesFeedAlbum]
        
        return results.map {
            var album = $0
            let width: Int = 256
            let height: Int = 256
            let updatedArtworkUrl = album.artworkUrl100.replacingOccurrences(of: "100x100", with: "\(width)x\(height)")
            album.artworkUrl100 = updatedArtworkUrl
            return album
        }
    }
    
    public func search(_ term: String, countryCode: String = "US") async -> [iTunesAlbum] {
        let me = "iTunesRequestService.search(): "
        let qs = "search?term=\(term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&country=\(countryCode)&media=music&entity=album"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesAlbumsSearchResponse.self)
            .value
        let results = value?.results ?? [] as [iTunesAlbum]

        return results
    }
    
    public func artistSearch(_ term: String, countryCode: String = "US") async -> [iTunesArtist] {
        let me = "iTunesRequestService.artistSearch(): "
        let qs = "search?term=\(term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&country=\(countryCode)&media=music&entity=musicArtist"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesArtistLookupResponse.self)
            .value
        let results = value?.results ?? [] as [iTunesArtist]
        
        return results
    }
    
    public func lookupUPC(_ upc: String) async -> iTunesAlbum? {
        let me = "iTunesRequestService.lookupUPC(): "
        let qs = "lookup?upc=\(upc)"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesAlbumsSearchResponse.self)
            .value
        let results = value?.results ?? [] as [iTunesAlbum]
        
        var res: iTunesAlbum? = nil
        
        if results.count > 0 {
            res = results[0]
        }
        
        return res
    }
    
    
    public func lookupArtist(_ id: Double) async -> [iTunesArtist] {
        let me = "iTunesRequestService.lookupArtist(): "
        let qs = "lookup?amgArtistId=\(Int(id))"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesArtistLookupResponse.self)
            .value
        let results = value?.results ?? [] as [iTunesArtist]
        print(results)
        
        return results
    }
    
    public func lookupRelatedAlbums(_ id: Int, limit: Int = 5) async -> [iTunesAlbum] {
        let me = "iTunesRequestService.lookupReleatedAlbums(): "
        let qs = "lookup?amgArtistId=\(id)&entity=album&limit=\(limit)"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesAlbumsSearchResponse.self)
            .value
        let results = value?.results ?? [] as [iTunesAlbum]
        
        return results.filter { $0.wrapperType == "collection" }.map {
            var album = $0
            let width: Int = 1024
            let height: Int = 1024
            let updatedArtworkUrl = album.artworkUrl100!.replacingOccurrences(of: "100x100", with: "\(width)x\(height)")
            album.artworkUrl100 = updatedArtworkUrl
            return album
        }
    }
    
    public func lookupTracksForAlbum(_ id: Int) async -> [iTunesTrack] {
        let me = "iTunesRequestService.lookupReleatedAlbums(): "
        let qs = "lookup?id=\(id)&entity=song"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesTrackLookupResponse.self)
            .value
        let results = value?.results ?? [] as [iTunesTrack]
        
        return results.filter { $0.wrapperType == "track" }
    }
    
    public func lookupAlbumArtwork(_ album: Release) async -> String {
        let me = "iTunesRequestService.lookupAlbumArtwork(): "
        let qs = "lookup?id=\(Int(album.appleId))&country=us&limit=25"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesAlbumsSearchResponse.self)
            .value
        
        let results = value?.results ?? [] as [iTunesAlbum]
        
        var str: String = ""
        
        if (results.count > 0) {
            let target = results[0]
            
            let artworkBaseUrl = target.artworkUrl100
            let width: Int = 1024
            let height: Int = 1024
            let updatedArtworkUrl = artworkBaseUrl!.replacingOccurrences(of: "100x100", with: "\(width)x\(height)")
            print(me + "artwork retrieved (\(updatedArtworkUrl))")
            str = updatedArtworkUrl
        }
        
        return str
    }
}
