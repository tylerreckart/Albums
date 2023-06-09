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

struct MusicBrainzArtist: Codable {
    var id: String?
    var name: String?
}

struct MusicBrainzArtistCredit: Codable {
    var name: String?
    var artist: MusicBrainzArtist?
}

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

struct MusicBrainzMetadataResponse: Decodable {
    var created: String
    var count: Int
    var offset: Int
    var releases: [MusicBrainzMetadata]
}

enum TermType: String {
    case album
    case ep
    case single
}

class MusicBrainzAPI: ObservableObject {
    public func requestMetadata(_ term: String, _ artist: String) async -> [MusicBrainzMetadata] {
        let me = "MusicBrainzAPI.search(): "
    
        let sanatizedSearchTerm = term
            .replacingOccurrences(of: " - Single", with: "")
            .replacingOccurrences(of: " - EP", with: "")
            .replacingOccurrences(of: "\\s?\\([\\w\\s]*\\)", with: "", options: .regularExpression)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let sanatizedArtist = artist
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let qs = "release?query=release:\(sanatizedSearchTerm)%20AND%20artistName:\(sanatizedArtist)&fmt=json"
        print(me + qs)
        
        let value = try? await AF
            .request("https://musicbrainz.org/ws/2/\(qs)")
            .serializingDecodable(MusicBrainzMetadataResponse.self)
            .value
        
//        AF.request("https://musicbrainz.org/ws/2/\(qs)").responseDecodable(of: MusicBrainzMetadata.self) { response in
//            debugPrint(response)
//        }
    
        let results = value?.releases ?? [] as [MusicBrainzMetadata]

        let resultsWithBarcode = results.filter { $0.barcode?.count ?? 0 > 0 }

        let resultsWithConfidence = resultsWithBarcode.filter {
            let termParts = term.split(separator: " ")
            let resultParts = $0.title?.split(separator: " ")
            var partMatchCount: Int = 0

            resultParts?.forEach { part in
                let index = resultParts!.firstIndex(of: part) ?? nil

                if index != nil {
                    let match = termParts.firstIndex(of: part)

                    if match != nil {
                        partMatchCount += 1
                    }
                }
            }

            let confidence = Double(partMatchCount) / Double(resultParts?.count ?? 1)

            if confidence > 0.75 {
                return true
            }

            return false
        }

        if resultsWithConfidence.count > 0 {
            return [resultsWithConfidence[0]]
        }

        return []
    }
    
}
