//
//  iTunesTrack.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation

struct iTunesTrack: Codable, Hashable {
    var wrapperType: String? = ""
    var kind: String? = ""
    var artistId: Int? = 0
    var collectionId: Int? = 0
    var trackId: Int? = 0
    var artistName: String? = ""
    var collectionName: String? = ""
    var collectionCensoredName: String? = ""
    var trackCensoredName: String? = ""
    var discCount: Int? = 0
    var discNumber: Int? = 0
    var trackCount: Int? = 0
    var trackNumber: Int? = 0
    var trackTimeMillis: Int? = 0
    var primaryGenreName: String? = ""
    var isStreamable: Bool? = false
    var releaseDate: String? = ""
}
