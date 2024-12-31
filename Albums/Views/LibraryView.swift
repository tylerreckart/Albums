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
enum LibrarySortFilter: String, CaseIterable, Identifiable {
    case date
    case albumName
    case artistName
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .date:
            return "Date Added"
        case .albumName:
            return "Album Name"
        case .artistName:
            return "Artist Name"
        }
    }
}

struct LibraryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: AlbumsAPI
    
    @State private var searchText: String = ""
    @State private var results: [iTunesAlbum] = []
    @State private var scrollOffset: CGPoint = .zero
    
    @State private var presentSortMenu: Bool = false
    @State private var sortFilter: LibrarySortFilter = LibrarySortFilter.savedSort()
    
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
                        currentSort: sortFilter,
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
                    .padding(.top, 10)
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
                        .transition(.opacity.combined(with: .slide))
                    }
                }
                .foregroundColor(.primary)
                
                Spacer()
            }
            .scrollDismissesKeyboard(.immediately)
            .padding(.horizontal)
            
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
                        search: performSearch,
                        results: $results
                    )
                    .padding(.bottom, 10)
                }
            },
            yOffset: scrollOffset.y,
            title: "Your Library")
        }
        .confirmationDialog("Sort your Library", isPresented: $presentSortMenu, titleVisibility: .visible) {
            ForEach(LibrarySortFilter.allCases) { sortOption in
                Button(sortOption.displayName) {
                    withAnimation {
                        sortFilter = sortOption
                        sortFilter.saveSort()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationBarHidden(true)
        .transition(.identity)
        .onTapGesture {
            endTextEditing()
        }
        .onAppear {
            // Ensure the sortFilter is loaded when the view appears
            sortFilter = LibrarySortFilter.savedSort()
        }
        .onChange(of: sortFilter) { newValue in
            // Persist the sort preference when it changes
            sortFilter.saveSort()
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
        var rows: [(Release?, Release?)] = []
        
        for index in stride(from: 0, to: items.count, by: 2) {
            let first = items[index]
            let second = index + 1 < items.count ? items[index + 1] : nil
            rows.append((first, second))
        }
        
        return rows
    }
    
    /// Dismisses the keyboard
    private func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    
    /// Performs the search action. Placeholder for actual search implementation.
    private func performSearch() {
        // Implement search logic if needed
    }
}

// MARK: - LibrarySortFilter Persistence

extension LibrarySortFilter {
    /// Saves the current sort filter to UserDefaults.
    func saveSort() {
        UserDefaults.standard.set(self.rawValue, forKey: "sortFilter")
    }
    
    /// Retrieves the saved sort filter from UserDefaults, or defaults to `.date`.
    static func savedSort() -> LibrarySortFilter {
        if let savedValue = UserDefaults.standard.string(forKey: "sortFilter"),
           let filter = LibrarySortFilter(rawValue: savedValue) {
            return filter
        }
        return .date
    }
}

// MARK: - LibraryFilterBar

/// A subview that displays the filter buttons (Owned, Wantlist, Playlists) and the sort button.
private struct LibraryFilterBar: View {
    let currentFilter: AlbumsAPI.LibraryFilter
    let currentSort: LibrarySortFilter
    let onFilterChange: (AlbumsAPI.LibraryFilter) -> Void
    let onSortTapped: () -> Void
    
    var body: some View {
        HStack {
            ZStack {
                // Purple highlight behind the selected filter
                HStack(spacing: 0) {
                    Spacer().frame(width: highlightPosition())
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("PrimaryPurple"))
                        .frame(width: 90, height: 36)
                    Spacer()
                }
                
                HStack(spacing: 0) {
                    FilterButton(title: "Owned", isSelected: currentFilter == .library) {
                        onFilterChange(.library)
                    }
                    .frame(width: 90)
                    
                    FilterButton(title: "Wantlist", isSelected: currentFilter == .wantlist) {
                        onFilterChange(.wantlist)
                    }
                    .frame(width: 90)
                    
                    FilterButton(title: "Playlists", isSelected: currentFilter == .playlists) {
                        onFilterChange(.playlists)
                    }
                    .frame(width: 90)
                    
                    Spacer()
                }
                .animation(.easeInOut, value: currentFilter)
            }
            
            Spacer()
            
            SortButton(action: onSortTapped, currentSort: currentSort)
        }
    }
    
    /// Determines the X-axis position for the highlight based on the current filter.
    private func highlightPosition() -> CGFloat {
        switch currentFilter {
        case .library:
            return 0
        case .wantlist:
            return 90
        case .playlists:
            return 180
        }
    }
    
    /// A reusable filter button component.
    private struct FilterButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
            }
        }
    }
    
    /// A reusable sort button component that displays the current sort option.
    private struct SortButton: View {
        let action: () -> Void
        let currentSort: LibrarySortFilter
        
        var body: some View {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemGray6))
                        .frame(width: 90, height: 36)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 12, weight: .heavy))
                        Text("Sort")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color("PrimaryPurple"))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                }
            }
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
        HStack {
            albumCell(even)
                .padding(.trailing)
            albumCell(odd)
        }
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func albumCell(_ album: Release?) -> some View {
        if let album = album {
            Button { onSelectAlbum(album) } label: {
                AlbumGridItem(album: album)
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            Rectangle()
                .fill(Color.clear)
                .aspectRatio(1.0, contentMode: .fit)
        }
    }
}
