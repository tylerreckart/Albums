//
//  Header.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import SwiftUI

struct Header<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    content
                        .padding(.horizontal)
                }
                .padding(.horizontal)
                .padding(.top, 5)
                .padding(.bottom, 15)
                .background(Color(.systemBackground))
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 1)
            }
            
            Spacer()
        }
    }
}
