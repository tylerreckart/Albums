//
//  UIButton.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import Foundation
import SwiftUI

struct UIButton: View {
    var text: String?
    var symbol: String?
    var action: () -> Void
    var foreground: Color = .white
    var background: Color
    var maxWidth: CGFloat = .infinity

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center) {
                if (symbol != nil) {
                    Image(systemName: symbol!)
                        .font(.system(size: 14, weight: .heavy))
                }
                
                if (text != nil) {
                    Text(text!)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundColor(foreground)
            .padding()
            .frame(maxWidth: maxWidth)
            .background(background)
            .cornerRadius(10)
        }
    }
}
