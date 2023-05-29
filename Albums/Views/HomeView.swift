//
//  HomeView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI
import Combine
import CachedAsyncImage

struct AlbumCoverView: View {
    @EnvironmentObject var itunes: iTunesAPI
    
    @State private var topAlbums: [Int:[iTunesFeedAlbum]] = [:]
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<3) { column in
                VStack(spacing: 10) {
                    ForEach(Array(topAlbums.keys), id: \.self) { row in
                        let albums = topAlbums[column] ?? []
                        
                        ForEach(albums, id: \.self) { album in
                            CachedAsyncImage(url: URL(string: album.artworkUrl100)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .transition(.opacity)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .offset(y: -20)
        .onAppear {
            Task {
                let top15 = await itunes.fetchTopAlbums().shuffled()
                for i in 0..<3 {
                    let start = i == 0 ? 0 : i * 5
                    let end   = start + 5
                    
                    var results: [iTunesFeedAlbum] = []
                    
                    for a in top15[start...end] {
                        results.append(a)
                    }
                    
                    print(results.map { $0.id })
                    
                    topAlbums[i] = results
                }
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var itunes: iTunesAPI
    
    @State private var scrollOffset = CGPoint()
    
    var setView: (_ view: RootView) -> Void

    var body: some View {
        ZStack {
            if store.library.isEmpty && store.wantlist.isEmpty {
                ZStack {
                    VStack(spacing: 0) {
                        AlbumCoverView()
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height / 1.5)
                            .overlay(
                                LinearGradient(colors: [.clear, Color(.systemBackground)], startPoint: .top, endPoint: .bottom)
                            )
                        
                        Rectangle().fill(Color(.systemBackground))
                    }
                    
                    VStack(spacing: 20) {
                        Spacer()
                        
                        HStack {
                            Text("Organize, Collect, and Listen.")
                                .font(.system(size: 26, weight: .bold))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }

                        HStack {
                            Text("Albums puts your music collection at your fingertips. Create custom playlists, set reminders for new releases, and more.")
                                .font(.system(size: 18))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        
                        Button(action: {
                            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 1)) {
                                setView(.search)
                            }
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.systemGray6))
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                
                                Text("Search for your first album")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color("PrimaryPurple"))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                    VStack(spacing: 20) {
                        Greeting()
                        HomeViewLibrarySection(setView: setView)
                        HomeViewWantlistSection(setView: setView)
                    }
                    .padding(.bottom, 60)
                }
            }
            
            if !store.library.isEmpty || !store.wantlist.isEmpty {
                Header(
                    content: {
                        HStack {
                            Spacer()
                            Text("Albums")
                                .font(.system(size: 16, weight: .semibold))
                                .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                            Spacer()
                        }
                    },
                    showDivider: false
                )
            }
        }
        .background(Color(.systemBackground))
        .transition(.identity)
    }
}
