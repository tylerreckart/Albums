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
                Text("Good Evening, Tyler")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            HStack {
                Text("Your last listen was on Tuesday, May 8th.")
                    .foregroundColor(Color("PrimaryGray"))
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding([.horizontal, .top])
    }
}
