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
                            let offset = proxy.frame(in: .named("scroll")).minY

                            if scrollTrackingInitialized {
                                Color.clear.onChange(of: offset) { newState in
                                    print(newState)
                                    withAnimation(.linear(duration: 0.1)) {
                                        if (newState < 850 && showHeader == false) {
                                            self.showHeader = true
                                        } else if (newState > 850 && showHeader == true) {
                                            self.showHeader = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
            
            if showHeader && scrollTrackingInitialized {
                Header(content: {
                    HStack {
                        Spacer()
                        Text("Albums")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                })
                .zIndex(1)
            }
        }
        .background(Color(.white))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                scrollTrackingInitialized = true
            }
        }
    }
}
