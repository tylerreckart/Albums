//
//  ArtistDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 6/9/23.
//

import Foundation
import SwiftUI

struct ArtistDetailHeader: View {
    @Binding var artist: Artist?
    
    @Binding var scrollOffset: CGPoint
    @Binding var showOptionsCard: Bool
    @Binding var animateIn: Bool
    
    var body: some View {
        Header(content: {
            HStack {
                Button(action: {
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 1)) {
                        animateIn.toggle()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        artist = nil
                    }
                }) {
                    Image(systemName: "chevron.backward.circle.fill")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color("PrimaryPurple"))
                        .symbolRenderingMode(.hierarchical)
                }
                
                Spacer()
                Text(artist?.name?.trunc(length: 24) ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showOptionsCard.toggle()
                    }
                }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color("PrimaryPurple"))
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .frame(height: 50)
            .background(Color(.systemBackground))
        }, showDivider: false, showWideBackground: true)
    }
}


struct ArtistDetail: View {
    @EnvironmentObject var store: AlbumsAPI
    
    @Binding var artist: Artist?

    @State private var scrollOffset: CGPoint = CGPoint()
    @State private var showOptionsCard: Bool = false
    
    @State private var animateIn: Bool = false
    
    @State private var related: [LibraryAlbum] = []
    @State private var inLibraryAlbums: [LibraryAlbum] = []
    
    struct Biography: View {
        @Binding var artist: Artist?
        
        @State private var collapsed: Bool = false
        
        var body: some View {
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Text("Artist Biography")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.collapsed.toggle()
                        }
                    }) {
                        if !self.collapsed {
                            Text("Show More")
                        } else {
                            Text("Show Less")
                        }
                    }
                }
                
                VStack {
                    VStack {
                        HStack {
                            Text(artist?.bio?.trunc(length: collapsed ? artist?.bio?.count ?? 0 : 150) ?? "")
                                .padding()
                            
                            if !collapsed {
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(9.5)
                    .padding(0.5)
                }
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.035), radius: 3, y: 3)
            }
        }
    }
    
    struct Discography: View {
        @Binding var artist: Artist?
        @Binding var inLibraryAlbums: [LibraryAlbum]
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Discography")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(Array(artist?.albums as? Set<LibraryAlbum> ?? []), id: \.self) { album in
                            Button(action: {}) {
                                AlbumGridItem(album: album)
                                    .frame(maxWidth: 200)
                            }
                        }
                    }
                    .padding([.horizontal])
                    .padding(.bottom, 10)
                }
                .frame(height: 280)
                .edgesIgnoringSafeArea(.bottom)
                .foregroundColor(.primary)
                
                if inLibraryAlbums.count > 0 {
                    HStack(alignment: .firstTextBaseline) {
                        Text("In Your Library")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 16) {
                            ForEach(inLibraryAlbums, id: \.self) { album in
                                Button(action: {}) {
                                    AlbumGridItem(album: album)
                                        .frame(maxWidth: 200)
                                }
                            }
                        }
                        .padding([.horizontal])
                        .padding(.bottom, 10)
                    }
                    .frame(height: 280)
                    .edgesIgnoringSafeArea(.bottom)
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
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
                        
                        
                        Biography(artist: $artist)
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        Discography(artist: $artist, inLibraryAlbums: $inLibraryAlbums)
                        
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
            
            inLibraryAlbums  = store.library.filter {
                $0.artistAppleId == artist && $0.appleId != activeAlbum?.appleId
            }
        }
    }
}
