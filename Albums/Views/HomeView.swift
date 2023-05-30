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
                        Greeting()
                        HomeViewLibrarySection(setView: setView)
                        HomeViewWantlistSection(setView: setView)
                    }
                    .padding(.bottom, 60)
                }
            }
            
            if !store.library.isEmpty || !store.wantlist.isEmpty {
                Header(
                    content: {
                        HStack {
                            Spacer()
                            Text("Albums")
                                .font(.system(size: 16, weight: .semibold))
                                .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                            Spacer()
                        }
                    },
                    showDivider: false
                )
            }
        }
        .background(Color(.systemBackground))
        .transition(.identity)
    }
}
