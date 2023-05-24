//
//  SettingsView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            VStack {
                Text("Hello, World")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.white))
            .padding(.top, 40)
            .padding(.bottom, 50)
            
            Header(content: {
                HStack {
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                }
            })
        }
    }
}

