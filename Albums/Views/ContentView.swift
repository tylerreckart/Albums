//
//  ContentView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/11/23.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    @StateObject var store = AlbumsAPI()
    @StateObject var itunes = iTunesAPI()
    
    @State private var activeView: RootView = .home
    
    func setView(_ view: RootView) -> Void {
        self.activeView = view
    }
    
    @State private var presentAlbumDetail: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                switch (activeView) {
                    case .home:
                        HomeView(setView: setView)
                    case .library:
                        LibraryView(showNavigation: false)
                    case .search:
                        SearchView()
                    case .settings:
                        SettingsView()
                }
                
                TabBar(activeView: $activeView)
            }
            .ignoresSafeArea(.keyboard)
            .sheet(isPresented: $presentAlbumDetail, onDismiss: { store.activeAlbum = nil }) {
                AlbumDetail(album: store.activeAlbum!)
            }
            .onChange(of: store.activeAlbum) { activeState in
                if activeState == nil {
                    presentAlbumDetail = false
                } else {
                    presentAlbumDetail = true
                }
            }
        }
        .environmentObject(store)
        .environmentObject(itunes)
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
