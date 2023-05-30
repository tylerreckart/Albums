//
//  BarcodeScannerView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/29/23.
//

import SwiftUI
import CodeScanner

struct BarcodeScannerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var itunes: iTunesAPI
    @EnvironmentObject var store: AlbumsAPI

    var body: some View {
        ZStack {
            CodeScannerView(
                codeTypes: [.code39, .code93, .code128, .code39Mod43, .ean8, .ean13, .upce],
                scanMode: .once
            ) { response in
                if case let .success(result) = response {
                    Task {
                        let res = await itunes.lookupUPC(result.string)
                        let r = store.mapAlbumDataToLibraryModel(res!)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            store.setActiveAlbum(r)
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width)
                    
                    LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
                }
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.height / 4)
                    Spacer()
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.height / 4)
                }
                ZStack {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width)
                    
                    VStack {
                        Text("Center the barcode for optimal scanning")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 20, weight: .regular))
                            Text("Search")
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 20, weight: .regular))
                    }
                    .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
