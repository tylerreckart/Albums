//
//  ContentView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/11/23.
//

import SwiftUI
import CoreData
import MusicKit

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @State private var albums: [Album] = []
    @State private var gridSize: Int = 2
    
    @State private var showSearchSheet: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            Text("Hello, Tyler!")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(Color("PrimaryBlack"))
                            Spacer()
                        }
                        HStack {
                            Text("Your last listen was on Tuesday, May 8th.")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    .padding([.horizontal, .bottom])
                    
                    VStack {
                        HStack {
                            Text("Reccomended Listens")
                                .fontWeight(.heavy)
                                .foregroundColor(Color("PrimaryBlack"))
                            Spacer()
                        }
                        .padding([.horizontal])
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                Rectangle()
                                    .fill(LinearGradient(
                                        colors: [.purple, .red],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                    .frame(width: 300, height: 120)
                                    .cornerRadius(6)
                                    .padding(.leading)
                                
                                Rectangle()
                                    .fill(LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                    .frame(width: 300, height: 120)
                                    .cornerRadius(6)
                                
                                Rectangle()
                                    .fill(LinearGradient(
                                        colors: [.red, .yellow],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                    .frame(width: 300, height: 120)
                                    .cornerRadius(6)
                                    .padding(.trailing)
                            }
                        }
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 10)
                        .padding(.bottom)
                    }

                    let columnWidth = (UIScreen.main.bounds.width / 2) - 26
                    
                    VStack {
                        HStack {
                            Text("Your Library")
                                .fontWeight(.heavy)
                                .foregroundColor(Color("PrimaryBlack"))
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 20) {
                            ZStack {
                                HStack(spacing: 20) {
                                    Rectangle()
                                        .fill(LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ))
                                        .frame(width: columnWidth, height: columnWidth)
                                        .cornerRadius(6)
                                        .shadow(color: .black.opacity(0.1), radius: 10, y: 10)
                                    Rectangle()
                                        .fill(LinearGradient(
                                            colors: [.purple, .red],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ))
                                        .frame(width: columnWidth, height: columnWidth)
                                        .cornerRadius(6)
                                        .shadow(color: .black.opacity(0.1), radius: 10, y: 10)
                                }
                                
                                Text("Add albums to your library to get started...")
                                    .font(.system(size: 16))
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(8)
                                    .shadow(color: .black.opacity(0.2), radius: 10, y: 10)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.bottom)

                    ZStack {
                        VStack(spacing: 0) {
                            let rowCount = Int((CGFloat(albums.count) / CGFloat(gridSize)).rounded())
                            if (rowCount > 0) {
                                ForEach(0..<rowCount, id: \.self) { row in
                                    let startIndex = row * gridSize
                                    let stopIndex = startIndex + gridSize
                                    
                                    HStack(spacing: 0) {
                                        ForEach(startIndex..<stopIndex, id: \.self) { index in
                                            if (index < albums.count) {
                                                let art = albums[index].artwork
                                                
                                                ArtworkImage(art!, width: (UIScreen.main.bounds.width / CGFloat(gridSize)))
                                            } else {
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { self.showSearchSheet.toggle() }) {
                        Label("Search", systemImage: "person.crop.circle")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(Color("PrimaryRed"))
                }
            }
            .background(
                LinearGradient(
                    colors: [.white, Color.init(hex: "FFECF3")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .sheet(isPresented: $showSearchSheet) {
                SearchSheet()
            }
        }
        .background(
            LinearGradient(colors: [.red, .white], startPoint: .top, endPoint: .bottom)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
