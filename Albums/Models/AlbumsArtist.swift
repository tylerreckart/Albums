//
//  AlbumsArtist.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation

class AlbumsArtist: Identifiable, Hashable {
    static func == (lhs: AlbumsArtist, rhs: AlbumsArtist) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }

    var uid: UUID = UUID()
    var appleId: Int = 0
    var name: String  = ""
}
