//
//  TabBar.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI

struct TabBarGroupItem: View {
    @EnvironmentObject var store: AlbumsAPI
    
    @Binding var activeView: RootView
    
    var targetView: RootView
    var image: String
    var label: String

    var frameWidth = UIScreen.main.bounds.width / 4
    
    @State private var showBaseIcon: Bool = true
    
    var body: some View {
        Button(action: {
            withAnimation(.linear(duration: 0)) {
                self.showBaseIcon = false
            }
            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 1)) {
                self.activeView = targetView
                
                if targetView == .library {
                    store.setFilter(.library)
                }
            }
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }) {
            VStack(spacing: 5) {
                ZStack {
                    if (showBaseIcon) {
                        Image("\(image)Gray")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    
                    if activeView == targetView {
                        Image("\(image)Red")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 1.2),
                                    removal: .identity
                                )
                            )
                    }
                }
                .frame(maxWidth: 24, maxHeight: 24)
                
                Circle()
                    .fill(showBaseIcon ? .clear : Color("PrimaryPurple"))
                    .frame(width: 4, height: 4)
            }
            .frame(width: frameWidth)
        }
        .onAppear {
            if activeView == targetView {
                self.showBaseIcon = false
            }
        }
        .onChange(of: activeView) { newState in
            if activeView == targetView {
                self.showBaseIcon = false
            }
            
            if newState != targetView {
                self.showBaseIcon = true
            }
        }
    }
}

struct TabBar: View {
    @Binding var activeView: RootView

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5)
            HStack(spacing: 0) {
                TabBarGroupItem(
                    activeView: $activeView,
                    targetView: .home,
                    image: "Home",
                    label: "Home"
                )
                TabBarGroupItem(
                    activeView: $activeView,
                    targetView: .library,
                    image: "Library",
                    label: "Library"
                )
                TabBarGroupItem(
                    activeView: $activeView,
                    targetView: .search,
                    image: "Search",
                    label: "Search"
                )
                TabBarGroupItem(
                    activeView: $activeView,
                    targetView: .settings,
                    image: "Settings",
                    label: "Settings"
                )
            }
            .padding(.top, 15)
            .padding(.bottom, 30)
            .background(Color(.systemBackground))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
