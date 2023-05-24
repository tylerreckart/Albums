//
//  HomeViewLibrarySection.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI
import CoreData

struct HomeViewLibrarySection: View {
    @EnvironmentObject var store: AlbumsViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(
                text: "Your Library",
                buttonText: "See All",
                destination: { LibraryView(showNavigation: true) }
            )
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    if store.library.count > 1 {
                        ForEach(store.library[0..<2], id: \.self) { item in
                            NavigationLink(destination: AlbumDetail(album: item)) {
                                VStack(alignment: .leading) {
                                    AsyncImage(url: URL(string: item.artworkUrl!)) { image in
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(6)
                                    
                                    Text(item.title!)
                                        .font(.system(size: 16, weight: .bold))
                                        .multilineTextAlignment(.leading)
                                    Text(item.artistName!)
                                        .foregroundColor(Color("PrimaryGray"))
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .foregroundColor(.primary)
    }
}
