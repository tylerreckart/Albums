//
//  LibraryView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @FetchRequest var libraryItems: FetchedResults<LibraryAlbum>
    @State private var searchText: String = ""
    
    init() {
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "owned == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: true)]
    
        _libraryItems = FetchRequest(fetchRequest: request)
    }

    var body: some View {
        ZStack {
            VStack {
                Text("Hello, World")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.white))
            .padding(.top, 40)
            .padding(.bottom, 50)
            
            Header(content: {
                HStack {
                    Spacer()
                    Menu("Sort") {
                        Button("Date Added", action: {})
                        Button("Title", action: {})
                        Button("Artist", action: {})
                    }
                }
            })
        }
    }
}
