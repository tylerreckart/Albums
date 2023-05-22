//
//  MusicBrainzAPI.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation
import Alamofire

//{
//  "id": "5ef906ae-d2b2-4a07-90b3-d5ea8dfb7dfd",
//  "score": 100,
//  "status-id": "518ffc83-5cde-34df-8627-81bff5093d92",
//  "count": 1,
//  "title": "Polyphia on Audiotree Live - EP",
//  "status": "Promotion",
//  "text-representation": {
//    "language": "eng"
//  },
//  "artist-credit": [
//    {
//      "name": "Polyphia",
//      "artist": {
//        "id": "344bfb00-27f0-4ff2-b96b-048ed1c6a968",
//        "name": "Polyphia",
//        "sort-name": "Polyphia"
//      }
//    }
//  ],
//  "release-group": {
//    "id": "51c003d2-dcb7-4cc2-b4e9-1093fc08675c",
//    "type-id": "6fd474e2-6b58-3102-9d17-d6f7eb7da0a0",
//    "primary-type-id": "f529b476-6e62-324f-b0aa-1f3e33d313fc",
//    "title": "Polyphia on Audiotree Live - EP",
//    "primary-type": "Album",
//    "secondary-types": [
//      "Live"
//    ],
//    "secondary-type-ids": [
//      "6fd474e2-6b58-3102-9d17-d6f7eb7da0a0"
//    ]
//  },
//  "date": "2015",
//  "country": "US",
//  "release-events": [
//    {
//      "date": "2015",
//      "area": {
//        "id": "489ce91b-6658-3307-9877-795b68554c98",
//        "name": "United States",
//        "sort-name": "United States",
//        "iso-3166-1-codes": [
//          "US"
//        ]
//      }
//    }
//  ],
//  "label-info": [
//    {
//      "label": {
//        "id": "c591322a-d4c0-4bd9-a96b-cab970693a6d",
//        "name": "Audiotree Music"
//      }
//    }
//  ],
//  "track-count": 5,
//  "media": [
//    {
//      "format": "Digital Media",
//      "disc-count": 0,
//      "track-count": 5
//    }
//  ]
//}

struct MusicBrainzRelease: Decodable {
    var id: String = ""
    var title: String = ""
}

struct MusicBrainzReleasesResponse: Decodable {
    var created: String
    var count: Int
    var offset: Int
    var releases: [MusicBrainzRelease]
}

struct MusicBrainzCoverArt: Decodable {
    var image: String
}

struct MusicBrainzCoverArtResponse: Decodable { var images: [MusicBrainzCoverArt] }

class MusicBrainzAPI {
    let baseUrl: String = "https://musicbrainz.org/ws/2/"
    
    public func lookupRelease(_ search: String) async -> [AlbumsAlbum] {
        let me = "MusicBrainzAPI.lookupRelease(): "
        let encodedSearchString = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let qs = "release?query=\(encodedSearchString)&fmt=json&limit=10"
        print(me + qs)
        
        var results: [AlbumsAlbum] = []
    
        let response = try? await AF
            .request(
                "\(baseUrl)\(qs)",
                headers: [
                    .accept("application/json"),
                    .userAgent("Albums/0.0.1 ( info@haptic.software )")
                ]
            )
            .serializingDecodable(MusicBrainzReleasesResponse.self)
            .value
        
        print(response)
        
        if (response != nil && response?.releases.count ?? 0 > 0) {
            for album in response!.releases {
                let tmp = AlbumsAlbum()
                tmp.mbid = album.id
                tmp.name = album.title

//                let covers = try? await AF.request("\(baseUrl)release/\(album.id)&fmt=json").responseData { response in
//                    debugPrint(response)
//                }

//                if (covers != nil && covers!.count > 0) {
//                    let cover = covers![0]
//                    print(cover.image)
//                }

                results.append(tmp)
            }
        }
        
        
        return results;
    }
}
