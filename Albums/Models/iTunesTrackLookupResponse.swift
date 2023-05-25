//
//  iTunesTrackLookupResponse.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation

struct iTunesTrackLookupResponse: Decodable {
    var resultCount: Int
    var results: [iTunesTrack]
}
