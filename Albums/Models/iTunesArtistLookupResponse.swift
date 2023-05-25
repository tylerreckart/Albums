//
//  iTunesArtistLookupResponse.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation

struct iTunesArtistLookupResponse: Decodable {
    var resultCount: Int
    var results: [iTunesArtist]
}
