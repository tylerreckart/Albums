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
    var title: String = ""
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
        
        var type: TermType = .album
        
        if term.lowercased().contains("- ep") {
            type = .ep
        } else if term.lowercased().contains("- single") {
            type = .single
        }
    
        let sanatizedSearchTerm = term
            .replacingOccurrences(of: " - ", with: "")
            .replacingOccurrences(of: "EP", with: "")
            .replacingOccurrences(of: "\\s?\\([\\w\\s]*\\)", with: "", options: .regularExpression)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let sanatizedArtist = artist
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
    let qs = "release?query=release:\(sanatizedSearchTerm)%20AND%20artistName:\(sanatizedArtist)%20AND%20primarytype:\(type.rawValue)&fmt=json"
        print(me + qs)
        
        let value = try? await AF
            .request("https://musicbrainz.org/ws/2/\(qs)")
            .serializingDecodable(MusicBrainzMetadataResponse.self)
            .value
        let results = value?.releases ?? [] as [MusicBrainzMetadata]
        
        let resultsWithBarcode = results.filter { $0.barcode != nil }
        
        let resultsWithConfidence = resultsWithBarcode.filter {
            let termParts = term.split(separator: " ")
            let resultParts = $0.title.split(separator: " ")
            var partMatchCount: Int = 0
            
            resultParts.forEach { part in
                let index = resultParts.firstIndex(of: part) ?? nil
                
                if index != nil {
                    let match = termParts.firstIndex(of: part)
                    
                    if match != nil {
                        partMatchCount += 1
                    }
                }
            }
            
            let confidence = Double(partMatchCount) / Double(resultParts.count)
            
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
