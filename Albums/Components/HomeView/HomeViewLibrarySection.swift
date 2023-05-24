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
    let columnWidth = (UIScreen.main.bounds.width / 2)

    @FetchRequest var libraryItems: FetchedResults<LibraryAlbum>
    
    init() {
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "owned == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: true)]
        request.fetchLimit = 4
    
        _libraryItems = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            SectionTitle(
                text: "Your Library",
                buttonText: "See All",
                destination: { VStack { Text("Hello, World") } }
            )
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    ForEach(libraryItems[0...1], id: \.self) { item in
                        AsyncImage(url: URL(string: item.artworkUrl!)) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: columnWidth)
                        .cornerRadius(6)
                    }
                }
                
                HStack(spacing: 20) {
                    ForEach(libraryItems[2...3], id: \.self) { item in
                        AsyncImage(url: URL(string: item.artworkUrl!)) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: columnWidth)
                        .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}
