//
//  iTunesAlbum.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation

struct iTunesAlbum: Codable {
    var wrapperType: String? = ""
    var collectionType: String? = ""
    var artistId: Int? = 0
    var collectionId: Int? = 0
    var amgArtistId: Int? = 0
    var artistName: String? = ""
    var collectionName: String? = ""
    var collectionCensoredName: String? = ""
    var artistViewUrl: String? = ""
    var collectionViewUrl: String? = ""
    var artworkUrl60: String? = ""
    var artworkUrl100: String? = ""
    var collectionPrice: CGFloat? = 0
    var collectionExplicitness: String? = ""
    var trackCount: Int? = 0
    var copyright: String? = ""
    var country: String? = ""
    var releaseDate: String? = ""
    var primaryGenreName: String? = ""
}
