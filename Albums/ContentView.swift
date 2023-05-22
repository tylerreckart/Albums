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
    
    let columnWidth = (UIScreen.main.bounds.width / 2) - 26
    
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
    
    var favoritesCarousel: some View {
        VStack {
            SectionTitle(
                text: "Your Favorites",
                symbol: "star",
                buttonText: "View All",
                destination: { VStack { Text("Hello, World") } }
            )
        }
    }
    
    var reccomendedCarousel: some View {
        VStack {
            SectionTitle(
                text: "Recommended Listens",
                symbol: "wand.and.stars",
                buttonText: "View All",
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
    
    var library: some View {
        VStack {
            SectionTitle(
                text: "Your Library",
                symbol: "square.stack.3d.down.right.fill",
                buttonText: "View All",
                destination: { VStack { Text("Hello, World") } }
            )

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    AlbumGridItem(columnWidth: columnWidth)
                    AlbumGridItem(columnWidth: columnWidth)
                }
                
                HStack(spacing: 20) {
                    AlbumGridItem(columnWidth: columnWidth)
                    AlbumGridItem(columnWidth: columnWidth)
                }
            }
        }
    }

    var body: some View {
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        greeting
                        reccomendedCarousel
                        library
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
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
