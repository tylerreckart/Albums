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
    @FetchRequest var libraryItems: FetchedResults<LibraryAlbum>
    
    init() {
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "owned == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: true)]
        request.fetchLimit = 2
    
        _libraryItems = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(
                text: "Your Library",
                buttonText: "See All",
                destination: { LibraryView() }
            )
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    ForEach(libraryItems, id: \.self) { item in
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
                                Text(item.artistName!)
                                    .foregroundColor(Color("PrimaryGray"))
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}
