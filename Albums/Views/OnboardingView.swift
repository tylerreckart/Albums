//
//  OnboardingView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/29/23.
//

import Foundation
import SwiftUI

struct AlbumCoverView: View {
    @EnvironmentObject var itunes: iTunesAPI
    
    @State private var topAlbums: [Int:[iTunesFeedAlbum]] = [:]
    
    var body: some View {
        HStack(spacing: 10) {
            let colums: [Int] = [0, 1, 2]
            ForEach(colums, id: \.self) { column in
                VStack(spacing: 10) {
                    ForEach(Array(topAlbums.keys), id: \.self) { row in
                        let albums = topAlbums[column] ?? []
                        let delay = Double(column + 1) * 0.5
                        
                        ForEach(albums, id: \.self) { album in
                            AsyncImage(
                                url: URL(string: album.artworkUrl100),
                                transaction: Transaction(animation: .easeInOut(duration: 2).delay(delay))
                            ) { phase in
                                switch phase {
                                case .empty:
                                    Color.clear
                                case let .success(image):
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .scaledToFill()
                                case .failure:
                                    Color.red
                                @unknown default:
                                    EmptyView()
                                }
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
                    
                    topAlbums[i] = results
                }
            }
        }
    }
}


struct OnboardingView: View {
    var setView: (_ view: RootView) -> Void
    
    var body: some View {
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
    }
}
