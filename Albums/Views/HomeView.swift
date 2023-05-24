//
//  HomeView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @State private var scrollTrackingInitialized: Bool = false
    @State private var lastOffset: CGFloat = 0
    @State private var totalDistance: CGFloat = 0
    @State private var showHeader: Bool = false
    var body: some View {
        ZStack {
            ScrollViewReader { value in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Greeting()
                        HomeViewLibrarySection()
                        HomeViewWantlistSection()
                        GeometryReader { proxy in
                            let offset = proxy.frame(in: .named("scroll")).origin.y

                            if scrollTrackingInitialized {
                                Color.clear.onChange(of: offset) { newState in
                                    print(newState)
                                    withAnimation(.linear(duration: 0.1)) {
                                        if lastOffset == 0 {
                                            lastOffset = newState
                                        }
                                        
                                        if (newState < lastOffset) {
                                            let delta = abs(Double((totalDistance * 2) / 100))
                                            print(delta)
                                            if delta == 0 || delta > 0.02 {
                                                totalDistance = newState - lastOffset
                                            } else {
                                                totalDistance = 0
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
            
            Header(content: {
                HStack {
                    Spacer()
                    Text("Albums")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                }
            })
            .zIndex(1)
            .opacity(abs(totalDistance * 2.25) < 100 ? abs(Double((totalDistance * 2.25)) / Double(100)) : 1)
        }
        .background(Color(.white))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                scrollTrackingInitialized = true
            }
        }
        .transition(.push(from: .trailing))
    }
}
