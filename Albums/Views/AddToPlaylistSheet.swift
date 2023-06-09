//
//  AddToPlaylistSheet.swift
//  Albums
//
//  Created by Tyler Reckart on 6/8/23.
//

import Foundation
import SwiftUI

struct AddToPlaylistSheet: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var text: String = ""
    @State private var results: [iTunesAlbum] = []
    
    @State private var showCreatePlaylistSheet: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Add to playlist...").font(.system(size: 16, weight: .semibold))
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 15)
                
                SearchBar(placeholder: "Find in your playlists", searchText: $text, search: {}, results: $results)
                    .padding(.bottom, 10)
                    .padding(.horizontal)
            }
            
            
            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        Text("All Playlists")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    
                    Button(action: { showCreatePlaylistSheet.toggle() }) {
                        HStack(spacing: 20) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color(.systemGray6))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(.systemGray2))
                            }
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Text("Create a new playlist...")
                                        .foregroundColor(Color("PrimaryPurple"))
                                    Spacer()
                                }
                                Spacer()
                            }
                            .border(width: 0.5, edges: [.bottom, .top], color: Color(.systemGray5))
                        }
                        .frame(maxHeight: 80)
                    }
                }
            }
            .padding(.leading)
        }
        .sheet(isPresented: $showCreatePlaylistSheet) {
            CreatePlaylistSheet()
        }
    }
}
