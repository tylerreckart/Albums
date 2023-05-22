//
//  iTunesRequestService.swift
//  Albums
//
//  Created by Tyler Reckart on 5/21/23.
//

import Foundation
import Alamofire

class iTunesRequestService {
    public func search(_ term: String, countryCode: String = "US") async -> [AlbumsAlbum] {
        let me = "iTunesRequestService.search(): "
        let qs = "search?term=\(term)&country=\(countryCode)&media=music&entity=album"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesAlbumsSearchResponse.self)
            .value
        let results = value?.results ?? [] as [iTunesAlbum]
        
        return mapiTunesResponseToAlbum(results)
    }
    
    public func lookupRelatedAlbums(_ id: Int) async -> [AlbumsAlbum] {
        let me = "iTunesRequestService.lookupReleatedAlbums(): "
        let qs = "lookup?id=\(id)&entity=album&limit=5"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesAlbumsSearchResponse.self)
            .value
        let results = value?.results ?? [] as [iTunesAlbum]
        
        return mapiTunesResponseToAlbum(results)
    }
    
    func mapiTunesResponseToAlbum(_ data: [iTunesAlbum]) -> [AlbumsAlbum] {
        var results: [AlbumsAlbum] = []
    
        for album in data {
            let tmp = AlbumsAlbum()
            tmp.name = album.collectionName
            tmp.artistName = album.artistName
            tmp.artistId = album.artistId
            tmp.artworkUrl = album.artworkUrl100
            tmp.genre = album.primaryGenreName
            tmp.releaseDate = album.releaseDate
            
            results.append(tmp)
        }
        
        return results
    }
}
