//
//  iTunesRequestService.swift
//  Albums
//
//  Created by Tyler Reckart on 5/21/23.
//

import Foundation
import Alamofire

class AlbumsArtist {
    var uid: UUID = UUID()
    var appleId: Int = 0
    var name: String  = ""
}

class AlbumsAlbum: Identifiable, Hashable {
    static func == (lhs: AlbumsAlbum, rhs: AlbumsAlbum) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(uid)
        }
    
    var uid: UUID = UUID()
    var appleId: Int = 0
    var name: String = ""
    var artistName: String = ""
    var artworkUrl: String = ""
}

struct iTunesAlbum: Codable {
    var wrapperType: String = ""
    var collectionType: String = ""
    var artistId: Int = 0
    var collectionId: Int = 0
    var amgArtistId: Int? = 0
    var artistName: String = ""
    var collectionName: String = ""
    var collectionCensoredName: String = ""
    var artistViewUrl: String = ""
    var collectionViewUrl: String = ""
    var artworkUrl60: String = ""
    var artworkUrl100: String = ""
    var collectionPrice: CGFloat? = 0
    var collectionExplicitness: String = ""
    var trackCount: Int = 0
    var copyright: String = ""
    var country: String = ""
    var releaseDate: String = ""
    var primaryGenreName: String = ""
}

struct iTunesAlbumResponse: Decodable {
    var resultCount: Int
    var results: [iTunesAlbum]
}

//{
//  "wrapperType": "collection",
//  "collectionType": "Album",
//  "artistId": 640294344,
//  "collectionId": 1078457179,
//  "amgArtistId": 3015593,
//  "artistName": "Polyphia",
//  "collectionName": "Renaissance",
//  "collectionCensoredName": "Renaissance",
//  "artistViewUrl": "https://music.apple.com/us/artist/polyphia/640294344?uo=4",
//  "collectionViewUrl": "https://music.apple.com/us/album/renaissance/1078457179?uo=4",
//  "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Music49/v4/6d/a9/0d/6da90d64-7aa6-7fc4-26f1-f2b4dcf452c2/886445701180.jpg/60x60bb.jpg",
//  "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music49/v4/6d/a9/0d/6da90d64-7aa6-7fc4-26f1-f2b4dcf452c2/886445701180.jpg/100x100bb.jpg",
//  "collectionPrice": 9.99,
//  "collectionExplicitness": "notExplicit",
//  "trackCount": 12,
//  "copyright": "℗ 2016 Equal Vision Records, Inc.",
//  "country": "USA",
//  "currency": "USD",
//  "releaseDate": "2016-03-11T08:00:00Z",
//  "primaryGenreName": "Alternative"
//}

class iTunesRequestService {
    public func search(_ term: String, countryCode: String = "US") async -> [AlbumsAlbum] {
        let qs = "search?term=\(term)&country=\(countryCode)&media=music&entity=album"
        print(qs)
        
        var result: [AlbumsAlbum] = []
        
        
        let value = try? await AF.request("https://itunes.apple.com/\(qs)").serializingDecodable(iTunesAlbumResponse.self).value
        let results = value?.results ?? [] as [iTunesAlbum]
        
        for album in results {
            let tmp = AlbumsAlbum()
            tmp.appleId = album.collectionId
            tmp.name = album.collectionName
            tmp.artistName = album.artistName
            tmp.artworkUrl = album.artworkUrl100
            
            result.append(tmp)
        }
        
        return result
    }
}
