//
//  Biography.swift
//  Albums
//
//  Created by Tyler Reckart on 6/10/23.
//

import Foundation
import SwiftUI

struct Biography: View {
    @Binding var artist: Artist?
    
    @State private var collapsed: Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text("Artist Biography")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.collapsed.toggle()
                    }
                }) {
                    if !self.collapsed {
                        Text("Show More")
                    } else {
                        Text("Show Less")
                    }
                }
            }
            .padding(.horizontal)
            
            VStack {
                VStack {
                    HStack {
                        Text(artist?.bio?.trunc(length: collapsed ? artist?.bio?.count ?? 0 : 150) ?? "")
                            .padding()
                        
                        if !collapsed {
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(9.5)
                .padding(0.5)
            }
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.035), radius: 3, y: 3)
        }
    }
}
