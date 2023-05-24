//
//  ContentView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/11/23.
//

import SwiftUI

struct ContentView: View {
    @State private var activeView: RootView = .home

    var body: some View {
        ZStack {
            NavigationView {
                switch (activeView) {
                    case .home:
                        HomeView()
                    case .library:
                        LibraryView()
                    case .search:
                        SearchView()
                    case .settings:
                        SettingsView()
                }
                
            }
            .background(Color.init(hex: "F5F5F5"))
            
            TabBar(activeView: $activeView)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
