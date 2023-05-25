//
//  iTunesArtist.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation

struct iTunesArtist: Codable {
    var wrapperType: String?
    var artistType: String
    var artistName: String
    var artistId: Int
    var amgArtistId: Int
    var primaryGenreName: String
}
