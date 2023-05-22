//
//  iTunesAlbumResponse.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation

struct iTunesAlbumResponse: Decodable {
    var resultCount: Int
    var results: iTunesAlbum
}
