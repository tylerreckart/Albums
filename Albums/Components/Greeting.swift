//
//  Greeting.swift
//  Albums
//
//  Created by Tyler Reckart on 5/23/23.
//

import Foundation
import SwiftUI

enum TimeOfDay: Int {
    case morning = 0
    case afternoon = 1
    case evening = 2
    case night = 3
}

struct Greeting: View {
    @State private var phrase = UserDefaults.standard.string(forKey: "currentPhrase")
    @State private var expirationHour = UserDefaults.standard.integer(forKey: "curentPhraseExpiringHour")
    @State private var showGreeting: Bool = false

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("\(phrase ?? "Hello"), Tyler")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .transition(.opacity)
        }
        .padding([.horizontal, .top])
        .padding(.top)
        .onAppear {
            let me = "Greeting.body<View>.onAppear{ } "
        
            let currentHour: Int = Calendar.current.component(.hour, from: Date())
            var targetPhrase: String = "Hello"
            var targetHour: Int = expirationHour
            
            if phrase == nil || currentHour > expirationHour {
                if currentHour >= 0 && currentHour <= 12 {
                    targetPhrase = "Good Morning"
                    targetHour = 12
                }
                
                if currentHour >= 13 && currentHour <= 16 {
                    targetPhrase = "Good Afternoon"
                    targetHour = 16
                }
                
                if currentHour >= 17 && currentHour <= 24 {
                    targetPhrase = "Good Evening"
                    targetHour = 20
                }
                
                phrase = targetPhrase
                print(me + "next phrase=\(targetPhrase)")
                print(me + "next expirationHour=\(targetHour)")
                
                UserDefaults.standard.set(targetPhrase, forKey: "currentPhrase")
                UserDefaults.standard.set(targetHour, forKey: "currentSetPhraseExpiringHour")
            }
        }
    }
}
