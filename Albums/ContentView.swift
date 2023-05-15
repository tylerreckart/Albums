//
//  ContentView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/11/23.
//

import SwiftUI
import CoreData
import MusicKit

struct ContentView: View {
    @State private var albums: [Album] = []
    @State private var gridSize: Int = 2
    
    @State private var showSearchSheet: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    let rowCount = Int((CGFloat(albums.count) / CGFloat(gridSize)).rounded())
                    
                    ForEach(0..<rowCount, id: \.self) { row in
                        let startIndex = row * gridSize
                        let stopIndex = startIndex + gridSize
                        
                        HStack(spacing: 0) {
                            ForEach(startIndex..<stopIndex, id: \.self) { index in
                                if (index < albums.count) {
                                    let art = albums[index].artwork
                            
                                    ArtworkImage(art!, width: (UIScreen.main.bounds.width / CGFloat(gridSize)))
                                } else {
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { self.showSearchSheet.toggle() }) {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .navigationTitle("Albums")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSearchSheet) {
                SearchSheet()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
