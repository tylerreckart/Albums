//
//  AlbumActions.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import SwiftUI

struct AlbumActions: View {
    @EnvironmentObject var store: AlbumsAPI

    var body: some View {
        VStack(spacing: 10) {
            if store.activeAlbum?.owned != true {
                UIButton(
                    text: "Add to Library",
                    action: { withAnimation { store.addAlbumToLibrary(store.activeAlbum!) } },
                    foreground: .white,
                    background: Color("PrimaryPurple")
                )
            
                UIButton(
                    text: store.activeAlbum?.wantlisted != true ? "Add to Wantlist" : "Remove from Wantlist",
                    action: {
                        if store.activeAlbum?.wantlisted != true {
                            store.addAlbumToWantlist(store.activeAlbum!)
                        } else {
                            store.removeAlbum(store.activeAlbum!)
                        }
                    },
                    foreground: Color("PrimaryPurple"),
                    background: Color(.systemGray6)
                )
            }
            
            HStack {
                UIButton(
                    text: "Play",
                    symbol: "play.fill",
                    action: {},
                    foreground: Color("PrimaryPurple"),
                    background: Color(.systemGray6)
                )
                
                UIButton(
                    text: "Shuffle",
                    symbol: "shuffle",
                    action: {},
                    foreground: Color("PrimaryPurple"),
                    background: Color(.systemGray6)
                )
                
                if store.activeAlbum?.owned == true {
                    UIButton(
                        symbol: "trash.fill",
                        action: { store.removeAlbum(store.activeAlbum!) },
                        foreground: Color("PrimaryRed"),
                        background: Color(.systemGray6),
                        maxWidth: 60
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}
