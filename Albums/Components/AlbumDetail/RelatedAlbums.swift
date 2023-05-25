//
//  RelatedAlbums.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import SwiftUI

struct RelatedAlbums: View {
    @EnvironmentObject var store: AlbumsAPI
    
    @Binding var related: [LibraryAlbum]

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("More by \(store.activeAlbum?.artistName ?? "")")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(related, id: \.self) { a in
                        VStack {
                            Button(action: {
                                withAnimation { store.setActiveAlbum(a) }
                            }) {
                                AlbumGridItem(album: a)
                                    .frame(maxWidth: 200)
                            }
                            .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
                .padding([.horizontal, .top])
                .padding(.bottom, 10)
            }
            .frame(height: 300)
            .background(Color(.systemGray6))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
