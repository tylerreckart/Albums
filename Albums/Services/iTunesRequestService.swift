//
//  iTunesRequestService.swift
//  Albums
//
//  Created by Tyler Reckart on 5/21/23.
//

import Foundation
import Alamofire

class iTunesRequestService: ObservableObject {
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
    
    public func lookupRelatedAlbums(_ id: Int) async -> [iTunesAlbum] {
        let me = "iTunesRequestService.lookupReleatedAlbums(): "
        let qs = "lookup?id=\(id)&entity=album&limit=5"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesAlbumsSearchResponse.self)
            .value
        let results = value?.results ?? [] as [iTunesAlbum]
        
        return results
    }
    
    public func lookupAlbumArtwork(_ album: LibraryAlbum) async -> Void {
        let me = "iTunesRequestService.lookupAlbumArtwork(): "
        let qs = "lookup?id=\(Int(album.appleId))&country=us&limit=25"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesAlbumsSearchResponse.self)
            .value
        
        let results = value?.results ?? [] as [iTunesAlbum]
        
        if (results.count > 0) {
            let target = results[0]
            
            let artworkBaseUrl = target.artworkUrl100
            let width: Int = 400
            let height: Int = 400
            let updatedArtworkUrl = artworkBaseUrl.replacingOccurrences(of: "100x100", with: "\(width)x\(height)")
            print(me + "artwork retrieved (\(updatedArtworkUrl))")
            album.artworkUrl = updatedArtworkUrl
        }
    }
}
