//
//  LibraryView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: AlbumsCommon
    
    @State private var results: [iTunesAlbum] = []

    @State private var searchText: String = ""
    var showNavigation: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                SearchBar(placeholder: "Find in Your Library", searchText: $searchText, search: {}, results: $results)
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .padding(.bottom, 8 )

                VStack(spacing: 5) {
                    let evens = store.library.indices.filter { $0 % 2 == 0 }.map { return store.library[$0] }
                    let odds = store.library.indices.filter { $0 % 2 != 0 }.map { return store.library[$0] }
                    let maxRows = max(evens.count, odds.count)
                    
                    ForEach(0..<maxRows, id: \.self) { row in
                        let even = row >= evens.count ? nil : evens[row]
                        let odd = row >= odds.count ? nil : odds[row]
                        
                        HStack(spacing: 20) {
                            VStack {
                                if even != nil {
                                    NavigationLink(destination: AlbumDetail(album: even!)) {
                                        AlbumGridItem(album: even!)
                                    }
                                } else {
                                    Rectangle().fill(.clear).aspectRatio(1.0, contentMode: .fit)
                                }
                                Spacer()
                            }
                            VStack {
                                if odd != nil {
                                    NavigationLink(destination: AlbumDetail(album: odd!)) {
                                        AlbumGridItem(album: odd!)
                                    }
                                } else {
                                    Rectangle().fill(.clear).aspectRatio(1.0, contentMode: .fit)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.top, 32)
            
            Header(content: {
                HStack {
                    if showNavigation {
                        HStack {
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "chevron.backward")
                                        .font(.system(size: 20, weight: .regular))
                                    Text("Home")
                                }
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Rectangle().fill(.clear).frame(maxWidth: .infinity, maxHeight: 0.5)
                    }
                    Text("Your Library")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    HStack {
                        Spacer()
                        Menu("Sort") {
                            Button("Date Added", action: {})
                            Button("Title", action: {})
                            Button("Artist", action: {})
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            })
        }
        .navigationBarHidden(true)
        .transition(.push(from: .trailing))
    }
}
