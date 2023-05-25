//
//  WantlistView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/24/23.
//

import SwiftUI
import CoreData

struct WantlistView: View {
    @EnvironmentObject var store: AlbumsViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var searchText: String = ""
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                SearchBar(placeholder: "Find in Your Wantlist", searchText: $searchText, search: {})
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .padding(.bottom, 8 )

                VStack(spacing: 5) {
                    let evens = store.wantlist.indices.filter { $0 % 2 == 0 }.map { return store.wantlist[$0] }
                    let odds = store.wantlist.indices.filter { $0 % 2 != 0 }.map { return store.wantlist[$0] }
                    let maxRows = max(evens.count, odds.count)
                    
                    ForEach(0..<maxRows, id: \.self) { row in
                        let even = row >= evens.count ? nil : evens[row]
                        let odd = row >= odds.count ? nil : odds[row]
                        
                        HStack(spacing: 20) {
                            VStack {
                                if even != nil {
                                    AlbumGridItem(album: even!)
                                } else {
                                    Rectangle().fill(.clear).aspectRatio(1.0, contentMode: .fit)
                                }
                                Spacer()
                            }
                            VStack {
                                if odd != nil {
                                    AlbumGridItem(album: odd!)
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
                    Text("Your Wantlist")
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
    }
}

