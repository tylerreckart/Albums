//
//  HomeView.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Greeting()
                HomeViewLibrarySection()
                HomeViewWantlistSection()
            }
        }
        .background(Color(.systemBackground))
    }
}
