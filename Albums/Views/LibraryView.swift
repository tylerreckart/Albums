//
//  LibraryView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//s

import SwiftUI
import CoreData

enum LibraryFilter: String {
    case library
    case wantlist
}

struct LibraryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject var store: AlbumsAPI
    
    @State private var searchText: String = ""
    @State private var results: [iTunesAlbum] = []
    @State private var scrollOffset: CGPoint = CGPoint()

    var showNavigation: Bool = false
    
    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                VStack(spacing: 0) {
                    HStack {
                        Text("Your Library")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .transition(.opacity)
                }
                .padding([.horizontal])
                .padding(.bottom, -1)
                
                SearchBar(placeholder: "Find in Your Library", searchText: $searchText, search: {}, results: $results)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    .padding(.top, 5)

                VStack(spacing: 5) {
                    ZStack {
                        HStack {
                            Spacer()
                                .frame(width: store.filter == .wantlist ? 90 : 0)
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("PrimaryPurple"))
                                .frame(width: 90, height: 36)
                            Spacer()
                        }
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 1)) {
                                    store.setFilter(.library)
                                }
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                            }) {
                                Text("Owned")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(store.filter == .library ? .white : .primary)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                            }
                            .frame(width: 90)
                            
                            Button(action: {
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 1)) {
                                    store.setFilter(.wantlist)
                                }
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                            }) {
                                Text("Wantlist")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(store.filter == .wantlist ? .white : .primary)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                            }
                            .frame(width: 90)
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 16))
                            }
                            .foregroundColor(Color("PrimaryPurple"))
                        }
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                    
                    let filter = store.filter.rawValue
                    let evens = store[filter].indices.filter { $0 % 2 == 0 }.map { return store[filter][$0] }
                    let odds = store[filter].indices.filter { $0 % 2 != 0 }.map { return store[filter][$0] }
                    let maxRows = max(evens.count, odds.count)
                    
                    ForEach(0..<maxRows, id: \.self) { row in
                        let even = row >= evens.count ? nil : evens[row]
                        let odd = row >= odds.count ? nil : odds[row]
                        
                        HStack(spacing: 20) {
                            VStack {
                                if even != nil {
                                    Button(action: { store.setActiveAlbum(even!) }) {
                                        AlbumGridItem(album: even!)
                                    }
                                } else {
                                    Rectangle().fill(.clear).aspectRatio(1.0, contentMode: .fit)
                                }
                                Spacer()
                            }
                            VStack {
                                if odd != nil {
                                    Button(action: { store.setActiveAlbum(odd!) }) {
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
            
            Header(
                content: {
                    HStack {
                        Spacer()
                        Text("Your Library")
                            .font(.system(size: 16, weight: .semibold))
                            .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                        Spacer()
                    }
                },
                showDivider: false
            )
        }
        .navigationBarHidden(true)
        .transition(.identity)
    }
}
