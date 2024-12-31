//
//  LibraryView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//  Refactored by ChatGPT
//

import SwiftUI
import CoreData

/// Determines how the library is sorted.
enum LibrarySortFilter {
    case date
    case albumName
    case artistName
}

struct LibraryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: AlbumsAPI
    
    @State private var searchText: String = ""
    @State private var results: [iTunesAlbum] = []
    @State private var scrollOffset: CGPoint = .zero
    
    @State private var presentSortMenu: Bool = false
    @State private var sortFilter: LibrarySortFilter = .date
    
    var showNavigation: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            ScrollOffsetObserver(showsIndicators: false, offset: $scrollOffset) {
                // Spacer for dynamic header
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 120)
                
                VStack(spacing: 5) {
                    // The filter bar (Owned / Wantlist / Playlists + sort)
                    LibraryFilterBar(
                        currentFilter: store.filter,
                        onFilterChange: { newFilter in
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                                store.setFilter(newFilter)
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        },
                        onSortTapped: {
                            presentSortMenu.toggle()
                        }
                    )
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                    
                    // Two-column layout for filtered + sorted results
                    let arrangedRows = twoColumnRows(for: filteredResults)
                    
                    ForEach(arrangedRows.indices, id: \.self) { rowIndex in
                        AlbumRow(
                            even: arrangedRows[rowIndex].0,
                            odd: arrangedRows[rowIndex].1,
                            onSelectAlbum: { album in
                                store.setActiveAlbum(album)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .foregroundColor(.primary)
                
                Spacer()
            }
            .scrollDismissesKeyboard(.immediately)
            
            // Dynamic header
            DynamicOffsetHeader(content: {
                VStack(spacing: 10) {
                    HStack {
                        Text("Your Library")
                            .font(.system(size: 34, weight: .bold))
                        Spacer()
                    }
                    
                    SearchBar(
                        placeholder: "Find in Your Library",
                        searchText: $searchText,
                        search: {},
                        results: $results
                    )
                    .padding(.bottom, 10)
                }
            },
            yOffset: scrollOffset.y,
            title: "Your Library")
        }
        .confirmationDialog("Sort your Library", isPresented: $presentSortMenu, titleVisibility: .visible) {
            Button("Date Added") { sortFilter = .date }
            Button("Artist Name") { sortFilter = .artistName }
            Button("Album Name") { sortFilter = .albumName }
        }
        .navigationBarHidden(true)
        .transition(.identity)
        .onTapGesture {
            endTextEditing()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns the list of `Release` objects filtered by the store's active filter, the search text, and then sorted.
    private var filteredResults: [Release] {
        // 1) Base data by filter
        let baseData: [Release] = {
            switch store.filter {
            case .library:
                return store.library
            case .wantlist:
                return store.wantlist
            case .playlists:
                // Adjust if you have a real playlists array
                return store.library
            }
        }()
        
        // 2) Apply search filtering
        let searched = baseData.filter { release in
            guard !searchText.isEmpty else { return true }
            let titleMatch = release.title?.lowercased().contains(searchText.lowercased()) ?? false
            let artistMatch = release.artistName?.lowercased().contains(searchText.lowercased()) ?? false
            return titleMatch || artistMatch
        }
        
        // 3) Sort the results
        switch sortFilter {
        case .date:
            // Most recent first
            return searched.sorted {
                ($0.dateAdded ?? .distantPast) > ($1.dateAdded ?? .distantPast)
            }
        case .artistName:
            return searched.sorted {
                ($0.artistName ?? "").localizedCaseInsensitiveCompare($1.artistName ?? "") == .orderedAscending
            }
        case .albumName:
            return searched.sorted {
                ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedAscending
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Breaks the array of `Release` objects into pairs for a two-column layout.
    private func twoColumnRows(for items: [Release]) -> [(Release?, Release?)] {
        let evens = items.indices.filter { $0 % 2 == 0 }.map { items[$0] }
        let odds  = items.indices.filter { $0 % 2 == 1 }.map { items[$0] }
        
        let maxRows = max(evens.count, odds.count)
        
        var rows: [(Release?, Release?)] = []
        rows.reserveCapacity(maxRows)
        
        for i in 0..<maxRows {
            let evenItem = i < evens.count ? evens[i] : nil
            let oddItem = i < odds.count ? odds[i] : nil
            rows.append((evenItem, oddItem))
        }
        
        return rows
    }
    
    /// Dismisses the keyboard
    private func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - LibraryFilterBar

/// A subview that displays the filter buttons (Owned, Wantlist, Playlists) and the sort button.
private struct LibraryFilterBar: View {
    let currentFilter: AlbumsAPI.LibraryFilter
    let onFilterChange: (AlbumsAPI.LibraryFilter) -> Void
    let onSortTapped: () -> Void
    
    var body: some View {
        ZStack {
            // Purple highlight behind the selected filter
            HStack {
                Spacer().frame(width: highlightWidth())
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("PrimaryPurple"))
                    .frame(width: 90, height: 36)
                Spacer()
            }
            
            HStack(spacing: 0) {
                // Owned
                Button(action: {
                    onFilterChange(.library)
                }) {
                    Text("Owned")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(currentFilter == .library ? .white : .primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                }
                .frame(width: 90)
                
                // Wantlist
                Button(action: {
                    onFilterChange(.wantlist)
                }) {
                    Text("Wantlist")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(currentFilter == .wantlist ? .white : .primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                }
                .frame(width: 90)
                
                // Playlists
                Button(action: {
                    onFilterChange(.playlists)
                }) {
                    Text("Playlists")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(currentFilter == .playlists ? .white : .primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                }
                .frame(width: 90)
                
                Spacer()
                
                // Sort button
                Button(action: onSortTapped) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18, weight: .regular))
                }
                .foregroundColor(Color("PrimaryPurple"))
            }
        }
    }
    
    /// Determines how far to shift the purple highlight background.
    private func highlightWidth() -> CGFloat {
        switch currentFilter {
        case .library:
            return 0
        case .wantlist:
            return 90
        case .playlists:
            return 180
        }
    }
}

// MARK: - AlbumRow

/// Displays two albums side-by-side in a row. If an album is nil, shows a clear placeholder to maintain spacing.
private struct AlbumRow: View {
    let even: Release?
    let odd: Release?
    let onSelectAlbum: (Release) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            albumCell(even)
            albumCell(odd)
        }
    }
    
    @ViewBuilder
    private func albumCell(_ album: Release?) -> some View {
        if let album = album {
            Button { onSelectAlbum(album) } label: {
                AlbumGridItem(album: album)
            }
        } else {
            Rectangle().fill(Color.clear).aspectRatio(1.0, contentMode: .fit)
        }
        Spacer()
    }
}
