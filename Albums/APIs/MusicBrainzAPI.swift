//
//  MusicBrainzAPI.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import Alamofire

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

struct MusicBrainzMetadata: Codable {
    var barcode: String?
    var media: [MusicBrainzMediaMetadata]
    var packaging: String?
}

struct MusicBrainzMetadataResponse: Decodable {
    var created: String
    var count: Int
    var offset: Int
    var releases: [MusicBrainzMetadata]
}

class MusicBrainzAPI: ObservableObject {
    public func requestMetadata(_ term: String, _ artist: String) async -> [MusicBrainzMetadata] {
        let me = "MusicBrainzAPI.search(): "
        let qs = "release?query=release:\(term.replacingOccurrences(of: "- EP", with: "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)%20AND%20artist:\(artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&fmt=json"
        print(me + qs)
        
        let value = try? await AF
            .request("https://musicbrainz.org/ws/2/\(qs)")
            .serializingDecodable(MusicBrainzMetadataResponse.self)
            .value
        let results = value?.releases ?? [] as [MusicBrainzMetadata]

        return results.filter { $0.barcode != nil }
    }
    
}
