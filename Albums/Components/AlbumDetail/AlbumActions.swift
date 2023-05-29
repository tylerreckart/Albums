//
//  AlbumActions.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import SwiftUI
import MusicKit

struct AlbumActions: View {
    @EnvironmentObject var store: AlbumsAPI
    
    let player = ApplicationMusicPlayer.shared
    
    @ObservedObject private var state = ApplicationMusicPlayer.shared.state

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
                    background: Color(.systemGray5)
                )
            }
            
            HStack {
                if state.playbackStatus != .playing {
                    UIButton(
                        text: "Play",
                        symbol: "play.fill",
                        action: { Task { try? await player.play() }},
                        foreground: Color("PrimaryPurple"),
                        background: Color(.systemGray5)
                    )
                } else {
                    UIButton(
                        text: "Pause",
                        symbol: "pause.fill",
                        action: { Task { player.pause() }},
                        foreground: Color("PrimaryPurple"),
                        background: Color(.systemGray5)
                    )
                }
                
                UIButton(
                    text: "Shuffle",
                    symbol: "shuffle",
                    action: {
                        Task {
                            player.pause()
                            state.shuffleMode = .songs
                            try? await player.skipToNextEntry()
                            try? await player.play()
                        }
                    },
                    foreground: Color("PrimaryPurple"),
                    background: Color(.systemGray5)
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
