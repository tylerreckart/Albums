//
//  DynamicOffsetHeader.swift
//  Albums
//
//  Created by Tyler Reckart on 5/31/23.
//

import SwiftUI

struct DynamicOffsetHeader<Content: View>: View {
    @ViewBuilder var content: Content
    
    var yOffset: CGFloat
    var title: String
    var useTitlePadding: Bool = false
    
    @State private var expandHeader: Bool = false
    
    var body: some View {
        Header(
            content: {
                ZStack {
                    content
                        .background(Color(.systemBackground))
                        .offset(y: yOffset >= 50 ? -20 : 0 - yOffset * 0.3)
                        .padding(.top, yOffset >= 50 ? 0 : 24 - yOffset * 0.7)
                        .onChange(of: yOffset) { newOffset in
                            if (yOffset >= 50 && expandHeader == false) || (yOffset <= 50 && expandHeader == true) {
                                withAnimation { expandHeader.toggle() }
                            }
                        }
                    
                    VStack {
                        Color(.systemBackground)
                        Spacer()
                    }
                    .frame(maxHeight: 103)
                    .offset(y: -76)
                    .edgesIgnoringSafeArea(.top)
                    
                    VStack {
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .opacity(expandHeader ? 1 : 0)
                        Spacer()
                    }
                    .frame(maxHeight: 100)
                    .padding(.bottom, useTitlePadding ? 15 : 0)
                }
            },
            showDivider: false
        )
    }
}
