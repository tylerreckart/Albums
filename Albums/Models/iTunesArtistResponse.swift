//
//  iTunesArtistResponse.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation

struct iTunesArtistResponse: Decodable {
    var resultCount: Int
    var results: iTunesArtist
}
