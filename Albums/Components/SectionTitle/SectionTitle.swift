//
//  SectionTitle.swift
//  Albums
//
//  Created by Tyler Reckart on 5/21/23.
//

import Foundation
import SwiftUI

struct SectionTitle<Destination: View>: View {
    var text: String
    var symbol: String?
    var buttonText: String?
    @ViewBuilder var destination: Destination
    var useAction: Bool = false
    var action: () -> Void = {}

    var body: some View {
        HStack(spacing: 5) {
            Text(text)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
            
            if buttonText != nil {
                if !useAction {
                    NavigationLink(destination: destination) {
                        Text(buttonText!)
                    }
                    .foregroundColor(Color("PrimaryPurple"))
                } else {
                    Button(action: {
                        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 1)) {
                            action()
                        }
                    }) {
                        Text(buttonText!)
                    }
                    .foregroundColor(Color("PrimaryPurple"))
                }
            }
        }
    }
}
