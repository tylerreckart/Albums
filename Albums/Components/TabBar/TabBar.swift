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
    
    var body: some View {
        Button(action: { self.activeView = targetView }) {
            VStack(spacing: 5) {
                ZStack {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 24)
                    Color(activeView == targetView ? "PrimaryRed" : "PrimaryGray").blendMode(.plusLighter)
                }
                .frame(maxWidth: 24, maxHeight: 24)
                
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(activeView == targetView ? "PrimaryRed" : "PrimaryGray"))
            }
            .frame(width: frameWidth)
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
            .padding(.top, 10)
            .background(.white)
        }
    }
}
