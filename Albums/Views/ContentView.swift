//
//  ContentView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/11/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var store: AlbumsViewModel = AlbumsViewModel()
    @StateObject var iTunesAPI: iTunesRequestService = iTunesRequestService()
    
    @State private var activeView: RootView = .home

    var body: some View {
        ZStack {
            NavigationView {
                switch (activeView) {
                    case .home:
                        HomeView()
                    case .library:
                        LibraryView(showNavigation: false)
                    case .search:
                        SearchView()
                    case .settings:
                        SettingsView()
                }
            }
            .environmentObject(store)
            .environmentObject(iTunesAPI)
            
            TabBar(activeView: $activeView)
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
