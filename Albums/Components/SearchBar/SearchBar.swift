//
//  SearchBar.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation
import SwiftUI
import Combine

class SearchFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] t in
                self?.debouncedText = t
            } )
            .store(in: &subscriptions)
    }
}

struct SearchBar: View {
    @StateObject var observer = SearchFieldObserver()
    
    var placeholder: String?
    
    @Binding var searchText: String
    
    var search: () async -> Void
    
    @Binding var results: [iTunesAlbum]
    @FocusState var focused: Bool

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemGray6))
                    .frame(height: 40)
                
                TextField(placeholder != nil ? placeholder! : "Search", text: $observer.searchText)
                    .focused($focused)
                    .padding(.leading, 32)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("LighterGray"))
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                if (searchText.count > 0) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            observer.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("LighterGray"))
                        }
                    }
                    .padding(.horizontal, 10)
                    .transition(.push(from: .trailing))
                }
            }
        }
        .onReceive(observer.$debouncedText) { (val) in
            searchText = val
        }
        .onChange(of: searchText) { _ in
            Task {
                await search()
            }
        }
    }
}
