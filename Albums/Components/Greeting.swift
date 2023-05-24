//
//  Greeting.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI

struct Greeting: View {
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Albums")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding([.horizontal, .top])
        .padding(.top)
    }
}
