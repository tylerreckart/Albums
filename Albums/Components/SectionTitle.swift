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
    var symbol: String
    var buttonText: String?
    @ViewBuilder var destination: Destination

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .black))
            Text(text)
                .fontWeight(.heavy)
                .foregroundColor(Color("PrimaryBlack"))
            Spacer()
            
            if (buttonText != nil) {
                NavigationLink(destination: destination) {
                    Text(buttonText!)
                }
                .foregroundColor(Color("PrimaryRed"))
            }
        }
        .padding([.horizontal])
    }
}
