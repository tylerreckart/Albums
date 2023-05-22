//
//  SearchBar.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String

    var search: () async -> Void

    var body: some View {
        ZStack {
            TextField("Search", text: $searchText)
                .onChange(of: searchText) { _ in
                    Task {
                        await search()
                    }
                }
                .padding()
                .padding(.leading, 22)
                .background(.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 5)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(.systemGray))
                
                Spacer()
            }
            .padding(.horizontal, 12)
            
            if (searchText.count > 0) {
                HStack {
                    Spacer()
                    
                    Button(action: { self.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(.systemGray4))
                    }
                }
                .padding(.horizontal, 12)
            }
        }
    }
}
