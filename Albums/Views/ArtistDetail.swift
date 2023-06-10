//
//  ArtistDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 6/9/23.
//

import Foundation
import SwiftUI

struct ArtistDetail: View {
    @EnvironmentObject var store: AlbumsAPI
    
    @Binding var artist: Artist?

    @State private var scrollOffset: CGPoint = CGPoint()
    @State private var showOptionsCard: Bool = false
    
    @State private var animateIn: Bool = false
    
    @State private var related: [Release] = []
    @State private var inReleases: [Release] = []
    
    var body: some View {
        ZStack {
            ScrollViewReader { reader in
                ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                    VStack {
                        AsyncImage(url: URL(string: (artist?.thumbnail) ?? "")) { image in
                            ZStack {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .overlay(
                                        LinearGradient(colors: [.clear, .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                    )
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text(artist?.name ?? "")
                                            .font(.system(size: 34, weight: .bold))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                                .padding()
                            }
                        } placeholder: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color(.systemGray4))
                                    .aspectRatio(contentMode: .fit)
                                ProgressView()
                            }
                        }
                        .cornerRadius(20)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                        .shadow(color: .black.opacity(0.075), radius: 10, y: 6)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Formed in \(artist?.yearFormed ?? "")")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                HStack {
                                    Image(systemName: "music.mic")
                                        .font(.system(size: 16, weight: .bold))
                                    Text(artist?.genre ?? "")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                HStack {
                                    Image(systemName: "globe.americas.fill")
                                        .font(.system(size: 16, weight: .bold))
                                    Text(artist?.country ?? "")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .foregroundColor(Color("PrimaryGray"))
                            Spacer()
                        }
                        .padding([.bottom, .horizontal])
                        
                        
                        Biography(artist: $artist)
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        Discography(artist: $artist, inReleases: $inReleases, animateIn: $animateIn)
                        
                        Spacer().frame(height: 20)
                    }
                    .padding(.top)
                }
            }
            .padding(.top, 40)
            
            ArtistDetailHeader(artist: $artist, scrollOffset: $scrollOffset, showOptionsCard: $showOptionsCard, animateIn: $animateIn)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .offset(x: animateIn ? 0 : UIScreen.main.bounds.width)
        .onAppear {
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 1)) {
                animateIn.toggle()
            }
            
            let activeAlbum = store.activeAlbum
            let artist = activeAlbum?.artistAppleId
            
            inReleases  = store.library.filter {
                $0.artistAppleId == artist && $0.appleId != activeAlbum?.appleId
            }
        }
    }
}
