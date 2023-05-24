//
//  TabBar.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI

struct TabBarGroupItem: View {
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
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.4, blendDuration: 1)) {
                self.activeView = targetView
            }
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        }) {
            VStack(spacing: 5) {
                ZStack {
                    if (showBaseIcon) {
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Color("PrimaryGray").blendMode(.plusLighter)
                    }
                    
                    if activeView == targetView {
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.8),
                                    removal: .identity
                                )
                            )
                        Color("PrimaryRed").blendMode(.plusLighter)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.8),
                                    removal: .identity
                                )
                            )
                    }
                }
                .frame(maxWidth: 24, maxHeight: 24)
                
                Circle()
                    .fill(showBaseIcon ? .clear : Color("PrimaryRed"))
                    .frame(width: 5, height: 5)
            }
            .frame(width: frameWidth)
        }
        .onAppear {
            if activeView == targetView {
                self.showBaseIcon = false
            }
        }
        .onChange(of: activeView) { newState in
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
                .frame(height: 1)
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
            .padding([.horizontal])
            .padding(.top, 15)
            .background(.white)
        }
    }
}
