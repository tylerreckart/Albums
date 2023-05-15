//
//  AlbumDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 5/14/23.
//

import SwiftUI
import MusicKit

struct AlbumDetail: View {
    var album: Album
    
    var body: some View {
        VStack(spacing: 0) {
            ArtworkImage(album.artwork!, height: UIScreen.main.bounds.width - 80)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.25), radius: 10, y: 5)
                .padding(.vertical, 40)
    
            VStack(alignment: .center, spacing: 20) {
                VStack(alignment: .center, spacing: 8) {
                    Text(album.title)
                        .font(.system(size: 24, weight: .bold))
                    
                    VStack(spacing: 5) {
                        Text(album.artistName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(.systemPink))
                        HStack(spacing: 4) {
                            Text(album.genreNames[0])
                            Circle().frame(width: 4, height: 4)
                            Text(album.releaseDate?.formatted(date: .long, time: .omitted) ?? "")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundColor(Color(.systemGray2))
                    }
                }
                .padding(.vertical, 10)

                VStack(alignment: .center, spacing: 10) {
                    Button(action: {}) {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .black))
                            Text("Add To Library")
                                .font(.system(size: 14, weight: .bold))
                            Spacer()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(.systemPink))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .black))
                            Text("Add To Wantlist")
                                .font(.system(size: 14, weight: .bold))
                            Spacer()
                        }
                        .padding()
                        .foregroundColor(Color(.systemPink))
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }
                }
                
                VStack {
                    Text("Top Tracks")
                        .font(.system(size: 12, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundColor(Color(.systemGray2))
                    HStack {
                        ZStack {
                            Rectangle()
                                .fill(.background)
                                .frame(width: 100, height: 100)
                                .border(.black, width: 1)
                            
                            Circle()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color(.systemPink))
                            
                            Image(systemName: "play.fill")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct AlbumDetailSheet: View {
    @Binding var album: Album?
    @Binding var artist: Artist?
    @State private var artists: [Artist] = []
    
    var body: some View {
        if (album != nil) {
            ZStack {
                NowPlayingBackgroundView(artwork: album?.artwork)
                
                ScrollView {
                    AlbumDetail(album: album!)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
    }
}

