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
    @EnvironmentObject var store: AlbumsViewModel

    var body: some View {
        VStack {
            SectionTitle(
                text: "Your Wantlist",
                buttonText: "See All",
                destination: { WantlistView().environmentObject(store) }
            )
            
            HStack(spacing: 20) {
                if store.wantlist.count > 0 {
                    AlbumGridItem(album: store.wantlist[0])
                }
            }
        }
        .padding(.horizontal)
        .foregroundColor(.primary)
    }
}

