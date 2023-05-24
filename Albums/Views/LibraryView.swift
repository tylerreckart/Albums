//
//  LibraryView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: AlbumsViewModel

    @State private var searchText: String = ""
    var showNavigation: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                SearchBar(placeholder: "Find in Your Library", searchText: $searchText, search: {})
                    .padding(.top, 20)
                    .padding(.horizontal)
                ForEach(store.library, id: \.self) { album in
                    Text(album.title ?? "")
                }
                
                Spacer()
            }
            .padding(.top, 40)
            
            Header(content: {
                HStack {
                    if showNavigation {
                        HStack {
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "chevron.backward")
                                        .font(.system(size: 20, weight: .regular))
                                    Text("Home")
                                }
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Rectangle().fill(.clear).frame(maxWidth: .infinity, maxHeight: 0.5)
                    }
                    Text("Your Library")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    HStack {
                        Spacer()
                        Menu("Sort") {
                            Button("Date Added", action: {})
                            Button("Title", action: {})
                            Button("Artist", action: {})
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            })
        }
        .navigationBarHidden(true)
        .transition(.push(from: .trailing))
    }
}
