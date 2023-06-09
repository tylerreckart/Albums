//
//  ArtistDetail.swift
//  Albums
//
//  Created by Tyler Reckart on 6/9/23.
//

import Foundation
import SwiftUI

struct ArtistDetailHeader: View {
    @Binding var artist: Artist?
    
    @Binding var scrollOffset: CGPoint
    @Binding var showOptionsCard: Bool
    @Binding var animateIn: Bool
    
    var body: some View {
        Header(content: {
            HStack {
                Button(action: {
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 1)) {
                        animateIn.toggle()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        artist = nil
                    }
                }) {
                    Image(systemName: "chevron.backward.circle.fill")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color("PrimaryPurple"))
                        .symbolRenderingMode(.hierarchical)
                }
                
                Spacer()
                Text(artist?.name?.trunc(length: 24) ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .opacity(scrollOffset.y * 1.5 < 100 ? (scrollOffset.y * 1.5) / CGFloat(100) : 1)
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showOptionsCard.toggle()
                    }
                }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color("PrimaryPurple"))
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .frame(height: 50)
            .background(Color(.systemBackground))
        }, showDivider: false)
    }
}


struct ArtistDetail: View {
    @Binding var artist: Artist?

    @State private var scrollOffset: CGPoint = CGPoint()
    @State private var showOptionsCard: Bool = false
    
    @State private var animateIn: Bool = false
    
    var body: some View {
        ZStack {
            ScrollViewReader { reader in
                ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                    VStack {
                        AsyncImage(url: URL(string: (artist?.thumbnail) ?? "")) { image in
                            ZStack {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .overlay(
                                        LinearGradient(colors: [.clear, .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                    )
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text(artist?.name ?? "")
                                            .font(.system(size: 34, weight: .bold))
                                        Spacer()
                                    }
                                }
                                .padding()
                            }
                        } placeholder: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color(.systemGray4))
                                ProgressView()
                            }
                        }
                        .cornerRadius(20)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                        .shadow(color: .black.opacity(0.075), radius: 10, y: 6)
                        
                        Text(artist?.bio ?? "")
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 40)
            
            ArtistDetailHeader(artist: $artist, scrollOffset: $scrollOffset, showOptionsCard: $showOptionsCard, animateIn: $animateIn)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .offset(x: animateIn ? 0 : UIScreen.main.bounds.width)
        .onAppear {
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 1)) {
                animateIn.toggle()
            }
        }
    }
}
