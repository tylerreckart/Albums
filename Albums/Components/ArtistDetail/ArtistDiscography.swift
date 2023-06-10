//
//  ArtistDiscography.swift
//  Albums
//
//  Created by Tyler Reckart on 6/10/23.
//

import Foundation
import SwiftUI

struct Discography: View {
    @EnvironmentObject var store: AlbumsAPI
    
    @Binding var artist: Artist?
    @Binding var inReleases: [Release]
    @Binding var animateIn: Bool
    
    @State private var latestRelease: Release?
    @State private var discographyForDisplay: [Release] = []
    
    func convertToEpochTime(_ dateStr: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return Int(formatter.date(from: dateStr)?.timeIntervalSince1970 ?? 0)
    }
    
    func buildDiscography(_ albums: [Release]) -> [Release] {
        var result = albums
        
        let crossReference = Dictionary(grouping: result, by: \.appleId)
        let duplicates = crossReference.filter { $1.count > 1 }
        
        if duplicates.count > 0 {
            for (_, duplicate) in duplicates {
                let index = albums.firstIndex(where: { $0.appleId == duplicate[0].appleId })!
                result.remove(at: index)
                
                let nextCrossReference = Dictionary(grouping: result, by: \.appleId)
                let remainingDuplicates = nextCrossReference.filter { $1.count > 1 }
                
                if remainingDuplicates.isEmpty {
                    break;
                }
            }
        }
        
        return result.sorted {
            convertToEpochTime($0.releaseDate!) > convertToEpochTime($1.releaseDate!)
        }
    }
    
    func dateFromReleaseStr(_ str: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: str) ?? Date()
        return date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Text("Latest Release")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                }
                
                HStack(spacing: 10) {
                    AsyncImage(url: URL(string: latestRelease?.artworkUrl ?? "")) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ZStack {
                            Rectangle()
                                .fill(Color(.systemGray6))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(contentMode: .fit)
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: 160)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.075), radius: 3, y: 3)
                    
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(dateFromReleaseStr(latestRelease?.releaseDate ?? ""))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color("PrimaryGray"))
                            Text(latestRelease?.title ?? "")
                                .font(.system(size: 18, weight: .bold))
                                .multilineTextAlignment(.leading)
                            Text("12 Tracks")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color("PrimaryGray"))
                            Spacer()
                            Button(action: {
                                store.setActiveAlbum(latestRelease!)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 1)) {
                                        animateIn.toggle()
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        artist = nil
                                    }
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color("PrimaryGray").opacity(0.15))
                                        .frame(maxWidth: 125, maxHeight: 50)
                                    Text("View Album")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color("PrimaryPurple"))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        
                        Spacer()
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .padding(.bottom)
            
            HStack(alignment: .firstTextBaseline) {
                Text("Discography")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button(action: {}) {
                    Text("View All")
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(discographyForDisplay, id: \.self) { album in
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
            
            if inReleases.count > 0 {
                HStack(alignment: .firstTextBaseline) {
                    Text("In Your Library")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(inReleases, id: \.self) { album in
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
        .onAppear {
            if discographyForDisplay.count == 0 {
                let albums = Array(artist?.albums as? Set<Release> ?? [])
                var discography = buildDiscography(albums)
                latestRelease = discography[0]
                discography.remove(at: 0)
                discographyForDisplay = discography
            }
        }
    }
}
