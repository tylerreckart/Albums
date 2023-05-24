//
//  HomeViewWantlistSection.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI
import CoreData

struct HomeViewWantlistSection: View {
    @FetchRequest var libraryItems: FetchedResults<LibraryAlbum>
    
    init() {
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "wantlisted == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: true)]
        request.fetchLimit = 2
    
        _libraryItems = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack {
            SectionTitle(
                text: "Your Wantlist",
                buttonText: "See All",
                destination: { VStack { Text("Hello, World") } }
            )
            
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
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

