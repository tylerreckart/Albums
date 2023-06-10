//
//  DynamicTargetSearchResult.swift
//  Albums
//
//  Created by Tyler Reckart on 5/31/23.
//

import Foundation
import SwiftUI

struct DynamicTargetSearchResult: View {
    @EnvironmentObject var store: AlbumsAPI
    
    var album: iTunesAlbum
    
    var body: some View {
        var target: Release = store.mapAlbumDataToLibraryModel(album)
    
        Button(action: {
            let libraryIndexMatch = store.library.firstIndex(where: { $0.appleId == Double(album.collectionId!) })
            let wantlistIndexMatch = store.wantlist.firstIndex(where: { $0.appleId == Double(album.collectionId!) })
            
            if libraryIndexMatch != nil {
                target = store.library[libraryIndexMatch!]
            }
            
            if wantlistIndexMatch != nil {
                target = store.library[wantlistIndexMatch!]
            }
            
            withAnimation(.easeOut(duration: 0.5)) {
                store.setActiveAlbum(target)
            }
        }) {
            AlbumListItem(album: target)
        }
    }
}
