//
//  AlbumTracklist.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import SwiftUI

struct AlbumTracklist: View {
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var itunes: iTunesAPI
    
    @Binding var tracks: [iTunesTrack]
    
    @State private var collapsed: Bool = true
    @State private var isLoadingTracks: Bool = false
    
    func secondsToHoursMinutesSeconds(seconds: Double) -> (Double, Double, Double) {
      let (hr,  minf) = modf(seconds / 3600)
      let (min, secf) = modf(60 * minf)
      return (hr, min, 60 * secf)
    }

    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text("Tracklist")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                
                Button(action: {
                    withAnimation {
                        self.collapsed.toggle()
                    }
                }) {
                    if self.collapsed {
                        Text("Show More")
                    } else {
                        Text("Show Less")
                    }
                }
            }
            .padding(.horizontal)

            ZStack {
                VStack(spacing: 0) {
                    let range = tracks.count == 1 ? tracks[0..<1] : tracks[0...(collapsed ? 1 : tracks.count - 1)]
                    if !isLoadingTracks {
                        ForEach(range, id: \.self) { track in
                            let index = range.firstIndex(where: { $0.trackId == track.trackId })
                            Button(action: {}) {
                                VStack(spacing: 0) {
                                    HStack(alignment: .top, spacing: 10) {
                                        Text("\(track.trackNumber!).")
                                            .font(.system(size: 14, weight: .bold))
                                            .frame(width: 24)
                                            .padding(.leading)
                                        VStack(spacing: 0) {
                                            HStack {
                                                Text(track.trackCensoredName!.trunc(length: 30))
                                                    .font(.system(size: 14, weight: .regular))
                                                Spacer()
                                                let (h, m, s) = secondsToHoursMinutesSeconds(seconds: Double(track.trackTimeMillis!) * 0.001)
                                                Text("\(h != 0 ? "\(h < 10 ? "0" : "")\(Int(h)):" : "")\(m < 10 ? "0" : "")\(Int(m)):\(s < 10 ? "0" : "")\(Int(s))")
                                                    .font(.system(size: 12, weight: .regular))
                                                    .foregroundColor(Color("PrimaryGray"))
                                            }
                                            .padding(.trailing)
                                            .padding(.bottom, 16)
                                            
                                            if index != nil && index != range.count - 1 {
                                                Rectangle()
                                                    .fill(Color(.systemGray4))
                                                    .frame(height: 0.5)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 16)
                            }
                            .foregroundColor(.primary)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(9.5)
                .padding(0.5)
            }
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal)
            .shadow(color: .black.opacity(0.035), radius: 3, y: 3)
            .transition(.opacity)
            .onChange(of: store.activeAlbum) { _ in
                if store.activeAlbum != nil {
                    Task {
                        self.isLoadingTracks = true
                        self.tracks =
                            await itunes.lookupTracksForAlbum(
                                Int(store.activeAlbum!.appleId)
                            )
                        self.isLoadingTracks = false
                    }
                }
            }
        }
    }
}
