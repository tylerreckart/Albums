//
//  ContentView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/11/23.
//

import SwiftUI
import CoreData
import MusicKit

struct HomeViewLibrarySection: View {
    let columnWidth = (UIScreen.main.bounds.width / 2) - 26

    @FetchRequest var libraryItems: FetchedResults<LibraryAlbum>
    
    init() {
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "owned == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: true)]
        request.fetchLimit = 4
    
        _libraryItems = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack {
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
                        .frame(width: columnWidth, height: columnWidth)
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
                        .frame(width: columnWidth, height: columnWidth)
                        .cornerRadius(6)
                    }
                }
            }
        }
    }
}

struct HomeViewWantlistSection: View {
    let columnWidth = (UIScreen.main.bounds.width / 2) - 26

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
                    AsyncImage(url: URL(string: item.artworkUrl!)) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: columnWidth, height: columnWidth)
                    .cornerRadius(6)
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var albums: [Album] = []
    @State private var gridSize: Int = 2
    
    @State private var showSearchSheet: Bool = false
    
    let columnWidth = (UIScreen.main.bounds.width / 2) - 26
    
    @FetchRequest var libraryItems: FetchedResults<LibraryAlbum>
    
    init() {
        let request: NSFetchRequest<LibraryAlbum> = LibraryAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "owned == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LibraryAlbum.dateAdded, ascending: true)]
        request.fetchLimit = 4
    
        _libraryItems = FetchRequest(fetchRequest: request)
    }
    
    var greeting: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Good Evening, Tyler")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            HStack {
                Text("Your last listen was on Tuesday, May 8th.")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    var reccomendedCarousel: some View {
        VStack {
            SectionTitle(
                text: "Recommended Listens",
                buttonText: "See All",
                destination: { VStack { Text("Hello, World") } }
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    RecommendedAlbum(columnWidth: columnWidth)
                    RecommendedAlbum(columnWidth: columnWidth)
                    RecommendedAlbum(columnWidth: columnWidth)
                }
                .padding(.horizontal)
            }
        }
    }

    var body: some View {
        TabView {
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        greeting
                        reccomendedCarousel
                        HomeViewLibrarySection()
                        HomeViewWantlistSection()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { self.showSearchSheet.toggle() }) {
                            Image(systemName: "magnifyingglass")
                                .fontWeight(.medium)
                                .foregroundColor(Color("PrimaryRed"))
                        }
                    }
                }
            }
            .background(Color.init(hex: "F5F5F5"))
            .sheet(isPresented: $showSearchSheet) {
                SearchSheet()
            }
            .tabItem {
                Label("Home", systemImage: "music.note.house")
            }
            
            VStack { Text("Hello, World") }
                .tabItem {
                    Label("Your Library", systemImage: "bookmark.circle")
                }
            
            
            VStack { Text("Hello, World") }
                .tabItem {
                    Label("Wantlist", systemImage: "star.circle")
                }
            
            VStack { Text("Hello, World") }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
