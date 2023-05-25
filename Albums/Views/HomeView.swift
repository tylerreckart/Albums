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
    @State private var scrollOffset = CGPoint()

    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                VStack(spacing: 20) {
                    Greeting()
                    HomeViewLibrarySection()
                    HomeViewWantlistSection()
                }
                .padding(.bottom, 60)
            }
            
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
        .background(Color(.white))
        .transition(.push(from: .trailing))
    }
}
