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
    
    func dateFromReleaseStr(_ str: String) -> String {
        let dateFormatter = DateFormatter()
        let date = dateFormatter.date(from: str)
        return (date ?? Date()).formatted(date: .long, time: .omitted)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            AsyncImage(url: URL(string: (store.activeAlbum?.artworkUrl!) ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 320, height: 320)
            .cornerRadius(6)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .padding(.top, 20)
            
            Text((store.activeAlbum?.title!) ?? "")
                .font(.system(size: 18, weight: .bold))
            
            Text((store.activeAlbum?.artistName!) ?? "")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color("PrimaryPurple"))
            
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
