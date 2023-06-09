//
//  AlbumMeta.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import SwiftUI

struct AlbumMeta: View {
    @EnvironmentObject var store: AlbumsAPI
    
    @Binding var selectedArtist: Artist?
    
    func dateFromReleaseStr(_ str: String) -> String {
        print(str)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: str) ?? Date()
        return date.formatted(date: .long, time: .omitted)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            AsyncImage(url: URL(string: (store.activeAlbum?.artworkUrl!) ?? "")) { image in
                withAnimation {
                    image.resizable().aspectRatio(contentMode: .fit)
                }
            } placeholder: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemGray4))
                        .frame(width: 320, height: 320)
                    ProgressView()
                }
            }
            .frame(width: 320, height: 320)
            .cornerRadius(20)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .padding(.top, 20)
            .shadow(color: .black.opacity(0.075), radius: 10, y: 6)
            
            Text((store.activeAlbum?.title!) ?? "")
                .font(.system(size: 18, weight: .bold))
            
            Button(action: {
                let album = store.activeAlbum
                
                if album != nil {
                    let arr = Array(album!.artists!)
                    let index = arr.firstIndex(where: { ($0 as! Artist).name == store.activeAlbum?.artistName })
                    if index != nil {
                        selectedArtist = arr[index!] as? Artist
                    }
                }
            }) {
                Text((store.activeAlbum?.artistName!) ?? "")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color("PrimaryPurple"))
            }
            
            HStack(alignment: .center, spacing: 5) {
                Text(store.activeAlbum?.genre ?? "")
                Circle()
                    .fill(Color(.gray))
                    .frame(width: 3, height: 3)
                Text(dateFromReleaseStr(store.activeAlbum?.releaseDate ?? ""))
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color("PrimaryGray"))
        }
        .padding(.horizontal)
    }
}
