//
//  SettingsView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @State private var scrollOffset: CGPoint = CGPoint()

    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding([.horizontal])
                .padding(.bottom, -1)
            }
            .padding(.top, 32)
            
            Header(
                content: {
                    HStack {
                        Spacer()
                        Text("Settings")
                            .font(.system(size: 16, weight: .semibold))
                            .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                        Spacer()
                    }
                },
                showDivider: false
            )
        }
        .transition(.identity)
    }
}

