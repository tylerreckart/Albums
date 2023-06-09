//
//  PlayerView.swift
//  Albums
//
//  Created by Tyler Reckart on 6/8/23.
//

import Foundation
import SwiftUI
import MusicKit

struct PlayerView: View {
    let player = ApplicationMusicPlayer.shared
    
    @State private var visible: Bool = false
    @State private var collapsed: Bool = true
    
    @ObservedObject private var state = ApplicationMusicPlayer.shared.state
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 0.5)
            
            if visible {
                HStack {
                    let activeEntry = player.queue.currentEntry
                    
                    if activeEntry?.artwork != nil {
                        ArtworkImage((activeEntry?.artwork)!, width: 48)
                            .cornerRadius(6)
                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                            .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                    }
                    
                    Text(player.queue.currentEntry?.title ?? "")
                        .font(.system(size: 16, weight: .regular))
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        if state.playbackStatus == .playing {
                            Button(action: { player.pause() }) {
                                Image(systemName: "pause.fill")
                            }
                        } else {
                            Button(action: { Task { try? await player.play() }}) {
                                Image(systemName: "play.fill")
                            }
                        }
                        
                        Button(action: { Task {
                            player.pause()
                            try? await player.skipToNextEntry()
                            try? await player.play()
                        }}) {
                            Image(systemName: "forward.fill")
                        }
                    }
                    .font(.system(size: 24))
                    .foregroundColor(Color("PrimaryPurple"))
                }
                .padding(.top, 10)
                .padding(.horizontal)
                .padding(.bottom, 30)
                .background(.white)
                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
            }
        }
        .onChange(of: state.playbackStatus) { status in
            if status == .playing && !visible {
                withAnimation {
                    self.visible = true
                }
            }
        }
    }
}
