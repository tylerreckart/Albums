//
//  AlbumTracklist.swift
//  Albums
//
//  Created by Tyler Reckart on 5/25/23.
//

import SwiftUI

struct AlbumTracklist: View {
    @EnvironmentObject var store: AlbumsAPI
    @EnvironmentObject var itunes: iTunesAPI
    
    @Binding var tracks: [iTunesTrack]
    
    @State private var collapsed: Bool = true
    @State private var isLoadingTracks: Bool = false
    
    var body: some View {
        VStack {
            headerSection
            
            ZStack {
                VStack(spacing: 0) {
                    // Decide how many tracks to show
                    let trackSlice = sliceOfTracks()
                    
                    if !isLoadingTracks {
                        ForEach(Array(trackSlice.enumerated()), id: \.element) { index, track in
                            TrackRow(
                                track: track,
                                isLastInSlice: index == trackSlice.count - 1,
                                formattedDuration: formattedDuration(track.trackTimeMillis)
                            )
                        }
                    } else {
                        ProgressView()
                            .padding(.vertical, 30)
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(9.5)
                .padding(0.5)
            }
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal)
            .shadow(color: .black.opacity(0.035), radius: 3, y: 3)
            .transition(.opacity)
            .onChange(of: store.activeAlbum) { _ in
                loadTracks()
            }
        }
    }
}

// MARK: - Subviews / Helpers

extension AlbumTracklist {
    
    /// The "Tracklist" header row with a Show More / Show Less toggle.
    private var headerSection: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Tracklist")
                .font(.system(size: 18, weight: .bold))
            Spacer()
            
            Button {
                withAnimation {
                    collapsed.toggle()
                }
            } label: {
                Text(collapsed ? "Show More" : "Show Less")
            }
        }
        .padding(.horizontal)
    }
    
    /// Returns a slice of the tracks array depending on collapsed state.
    private func sliceOfTracks() -> ArraySlice<iTunesTrack> {
        guard !tracks.isEmpty else { return [] }
        
        // If there's only 1 track, return the first element. Otherwise,
        // return either the first 2 tracks (index 0..1) or all tracks,
        // depending on `collapsed`.
        if tracks.count == 1 {
            return tracks[0..<1]
        } else {
            return tracks.prefix(collapsed ? 2 : tracks.count)
        }
    }
    
    /// Loads the tracks for the currently active album, if any.
    private func loadTracks() {
        guard let activeAlbum = store.activeAlbum else { return }
        
        Task {
            isLoadingTracks = true
            do {
                let albumTracks = try await itunes.lookupTracksForAlbum(Int(activeAlbum.appleId))
                tracks = albumTracks
            } catch {
                print("Error loading tracks: \(error.localizedDescription)")
                tracks = []
            }
            isLoadingTracks = false
        }
    }
    
    /// Formats a track's duration (in milliseconds) as "hh:mm:ss".
    private func formattedDuration(_ millis: Int?) -> String {
        guard let millis = millis else { return "0:00" }
        
        let totalSeconds = Double(millis) / 1000
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - TrackRow

/// A single row displaying track number, title, and formatted duration.
/// Draws a divider unless it's the last track in the slice.
private struct TrackRow: View {
    let track: iTunesTrack
    let isLastInSlice: Bool
    let formattedDuration: String
    
    var body: some View {
        Button(action: {
            // TODO: Handle track tap action if needed
        }) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    trackNumberView
                        .padding(.leading)
                    
                    VStack(spacing: 0) {
                        trackTitleAndDuration
                        if !isLastInSlice {
                            Divider()
                                .padding(.top, 16)
                        }
                    }
                }
            }
            .padding(.top, 16)
            .foregroundColor(.primary)
        }
    }
    
    // MARK: - Subviews
    
    /// Shows the track number if available.
    @ViewBuilder
    private var trackNumberView: some View {
        if let number = track.trackNumber {
            Text("\(number).")
                .font(.system(size: 14, weight: .bold))
                .frame(width: 24)
        } else {
            Text("--.")
                .font(.system(size: 14, weight: .bold))
                .frame(width: 24)
        }
    }
    
    /// Displays the track title and its duration on the right side.
    private var trackTitleAndDuration: some View {
        HStack {
            Text((track.trackCensoredName ?? "Unknown Track").trunc(length: 30))
                .font(.system(size: 14, weight: .regular))
            Spacer()
            Text(formattedDuration)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color("PrimaryGray"))
        }
        .padding(.trailing)
        .padding(.bottom, 16)
    }
}

// MARK: - String Extension

fileprivate extension String {
    /// Truncates the string to `length` characters, adding ellipsis if needed.
    func trunc(length: Int) -> String {
        guard count > length else { return self }
        return prefix(length) + "…"
    }
}
