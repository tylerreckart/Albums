//
//  Header.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import SwiftUI

struct Header<Content: View>: View {
    @ViewBuilder var content: Content
    
    var showDivider: Bool = true
    var background: Color = Color(.systemBackground)
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    content
                }
                .padding(.horizontal)
                .padding(.top, 5)
                .padding(.bottom, 10)
                .background(background)
                
                if showDivider {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 0.5)
                }
            }
            
            Spacer()
        }
    }
}
