//
//  HomeView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var itunes: iTunesAPI
    
    @State private var scrollOffset = CGPoint()
    
    var setView: (_ view: RootView) -> Void

    var body: some View {
        ZStack {
            if store.library.isEmpty && store.wantlist.isEmpty {
                OnboardingView(setView: setView)
            } else {
                ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                    VStack(spacing: 20) {
                        if !store.library.isEmpty {
                            HomeViewLibrarySection(setView: setView)
                        }
                        if !store.wantlist.isEmpty {
                            HomeViewWantlistSection(setView: setView)
                        }
                        HomeViewPlaylistSection()
                    }
                    .padding(.bottom, 60)
                    .padding(.top, 85)
                }
                
                DynamicOffsetHeader(content: {
                    HStack(alignment: .bottom) {
                        Text("Albums")
                            .font(.system(size: 34, weight: .bold))
                        Spacer()
                    }
                    .padding(.top, -40 + (scrollOffset.y > 0 ? -scrollOffset.y * 0.4 : 0))
                }, yOffset: scrollOffset.y, title: "Albums", useTitlePadding: true)
            }
        }
        .background(Color(.systemBackground))
        .transition(.identity)
    }
}
