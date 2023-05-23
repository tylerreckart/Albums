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
        let qs = "search?term=\(term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&country=\(countryCode)&media=music&entity=album"
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
    
    public func lookupAlbumArtwork(_ album: AlbumsAlbum) async -> String {
        let me = "iTunesRequestService.lookupAlbumArtwork(): "
        let qs = "lookup?id=\(album.appleId)&country=us&limit=25"
        print(me + qs)
        
        let value = try? await AF
            .request("https://itunes.apple.com/\(qs)")
            .serializingDecodable(iTunesAlbumsSearchResponse.self)
            .value
        
        let results = value?.results ?? [] as [iTunesAlbum]
        var url = ""
        
        if (results.count > 0) {
            let target = results[0]
            
            let artworkBaseUrl = target.artworkUrl100
            let width: Int = 400
            let height: Int = 400
            let updatedArtworkUrl = artworkBaseUrl.replacingOccurrences(of: "100x100", with: "\(width)x\(height)")
            print(me + "artwork retrieved (\(updatedArtworkUrl))")
            album.artworkUrl = updatedArtworkUrl
        }
        
        return url
    }

    func mapiTunesResponseToAlbum(_ data: [iTunesAlbum]) -> [AlbumsAlbum] {
        var results: [AlbumsAlbum] = []
    
        for album in data {
            let tmp = AlbumsAlbum()
            tmp.appleId = album.collectionId
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
