//
//  AlbumsAlbum.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation

class AlbumsAlbum: ObservableObject, Identifiable, Hashable {
    static func == (lhs: AlbumsAlbum, rhs: AlbumsAlbum) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
    
    var uid: UUID = UUID()
    var appleId: Int = 0
    // iTunes-fetched properties.
    var mbid: String = ""
    var name: String = ""
    var artistName: String = ""
    var artistId: Int = 0
    @Published var artworkUrl: String = ""
    var genre: String = ""
    var releaseDate: String = ""
    // Local application properties.
    var playCount: Int = 0
    var favorite: Bool = false
}
