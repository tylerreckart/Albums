//
//  AlbumTracklist.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import SwiftUI

struct AlbumTracklist: View {
    @Binding var tracks: [iTunesTrack]
    
    func secondsToHoursMinutesSeconds(seconds: Double) -> (Double, Double, Double) {
      let (hr,  minf) = modf(seconds / 3600)
      let (min, secf) = modf(60 * minf)
      return (hr, min, 60 * secf)
    }

    var body: some View {
        VStack {
            HStack {
                Text("Tracklist")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(tracks, id: \.self) { track in
                    let index = tracks.firstIndex(where: { $0.trackId == track.trackId })
                    
                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(track.trackNumber!).")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 24)
                                .padding(.leading)
                            VStack(spacing: 5) {
                                HStack {
                                    Text(track.trackCensoredName!.trunc(length: 30))
                                        .font(.system(size: 14, weight: .regular))
                                    Spacer()
                                    Text(track.primaryGenreName!)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color("PrimaryGray"))
                                }
                                .padding(.trailing)
                                
                                HStack {
                                    let (h, m, s) = secondsToHoursMinutesSeconds(seconds: Double(track.trackTimeMillis!) * 0.001)
                                    Text("\(h != 0 ? "\(h < 10 ? "0" : "")\(Int(h)):" : "")\(m < 10 ? "0" : "")\(Int(m)):\(s < 10 ? "0" : "")\(Int(s))")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color("PrimaryGray"))
                                    Spacer()
                                }
                                .padding(.bottom, 7)
                                
                                if index != nil && index != tracks.count - 1 {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 0.5)
                                }
                            }
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .padding(.vertical, 5)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}
