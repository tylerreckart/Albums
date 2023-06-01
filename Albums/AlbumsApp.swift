//
//  AlbumsApp.swift
//  Albums
//
//  Created by Tyler Reckart on 5/11/23.
//

import SwiftUI

@main
struct AlbumsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                .preferredColorScheme(.light)
        }
    }
}
