//
//  SearchBar.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    var placeholder: String?
    @Binding var searchText: String
    var search: () async -> Void
    @Binding var results: [iTunesAlbum]

    var body: some View {
        ZStack {
            TextField(placeholder != nil ? placeholder! : "Search", text: $searchText)
                .onChange(of: searchText) { _ in
                    Task {
                        await search()
                    }
                }
                .padding(10)
                .padding(.leading, 22)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("PrimaryGray"))
                
                Spacer()
            }
            .padding(.horizontal, 8)
            
            if (searchText.count > 0) {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.searchText = ""
                        self.results = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("PrimaryGray"))
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
}
