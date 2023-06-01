//
//  HomeViewPlaylistSection.swift
//  Albums
//
//  Created by Tyler Reckart on 6/1/23.
//

import SwiftUI

struct PlaylistItem: View {
    var symbol: String
    var fill: String
    var label: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemGray6))
                .frame(height: 60)
                .shadow(color: Color(.black).opacity(0.02), radius: 4, y: 4)
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(fill))
                        .frame(width: 40)
                    Image(systemName: symbol)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                }
                .padding(.leading, 10)
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct HomeViewPlaylistSection: View {
    var body: some View {
        VStack {
            SectionTitle(text: "Your Playlists", destination: {})
                .padding(.horizontal)
            PlaylistItem(symbol: "square.stack.3d.up.fill", fill: "PrimaryRed", label: "All Music")
            PlaylistItem(symbol: "star.fill", fill: "PrimaryPurple", label: "Favorites")
            PlaylistItem(symbol: "bookmark.fill", fill: "PrimaryYellow", label: "Saved for Later")
        }
    }
}
