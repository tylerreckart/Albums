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
    
    var greeting: some View {
        VStack {
            HStack {
                Text("Hello, Tyler!")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color("PrimaryBlack"))
                Spacer()
            }
            .padding(.bottom, 1)
            HStack {
                Text("Your last listen was on Tuesday, May 8th.")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding([.horizontal, .bottom])
        .padding(.top, 20)
    }
    
    var favoritesCarousel: some View {
        VStack {
            HStack {
                Text("Your Favorites")
                    .fontWeight(.heavy)
                    .foregroundColor(Color("PrimaryBlack"))
                Spacer()
            }
            .padding([.horizontal])
        }
    }
    
    var reccomendedCarousel: some View {
        VStack {
            HStack(spacing: 5) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 16, weight: .black))
//                    .foregroundColor(Color("PrimaryRed"))
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
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Button(action: { self.showSearchSheet.toggle() }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(Color("PrimaryRed"))
                }
                .padding([.horizontal, .top])
                .background(.white)
                .zIndex(1)
                
                ScrollView {
                    VStack(spacing: 0) {
                        greeting
                            .padding(.bottom, 5)
                        reccomendedCarousel
                            .padding(.bottom, 5)
                        
                        let columnWidth = (UIScreen.main.bounds.width / 2) - 26
                        
                        VStack {
                            HStack(spacing: 5) {
                                Image(systemName: "square.stack.3d.down.right")
                                    .font(.system(size: 16, weight: .heavy))
//                                    .foregroundColor(Color("PrimaryRed"))
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
                                            .overlay(.ultraThinMaterial)
                                            .cornerRadius(6)
                                            .shadow(color: .black.opacity(0.1), radius: 10, y: 10)
                                        Rectangle()
                                            .fill(LinearGradient(
                                                colors: [.purple, .red],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ))
                                            .frame(width: columnWidth, height: columnWidth)
                                            .overlay(.ultraThinMaterial)
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
                    }
                }
                .frame(height: UIScreen.main.bounds.height - 200)
                
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Text("Bottom Bar")
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    //                    .padding()
                    .background(.white)
                    .shadow(color: Color.init(hex: "57061F").opacity(0.2), radius: 10, y: 8)
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { self.showSearchSheet.toggle() }) {
                        Label("Search", systemImage: "magnifyingglass")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
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
