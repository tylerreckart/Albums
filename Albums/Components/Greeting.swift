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

let helloPhrases: [String] = [
    "Hello",
    "你好",
    "Hola",
    "مرحبًا",
    "नमस्ते",
    "হ্যালো",
    "Olá",
    "Привіт",
    "こんにちは",
    "ਸਤ ਸ੍ਰੀ ਅਕਾਲ"
]

let morningPhrases: [String] = [
    "Good morning",
    "早上好",
    "Buenos días",
    "صباح الخير",
    "शुभ प्रभात",
    "সুপ্রভাত",
    "Bom dia",
    "Добрий ранок",
    "おはよう",
    "ਸ਼ੁਭ ਸਵੇਰ"
]

let afternoonPhrases: [String] = [
    "Good afternoon",
    "下午好",
    "Buenos días",
    "طاب مساؤك",
    "नमस्कार",
    "শুভ অপরাহ্ন",
    "Bom dia",
    "Добрий день",
    "こんにちは",
    "ਨਮਸਕਾਰ"
]

let eveningPhrases: [String] = [
    "Good evening",
    "晚上好",
    "Buenas noches",
    "مساء الخير",
    "नमस्ते",
    "শুভ সন্ধ্যা",
    "Boa noite",
    "Добрий вечір",
    "こんばんは",
    "ਸਤ ਸ੍ਰੀ ਅਕਾਲ"
]

let nightPhrases: [String] = [
    "Good night",
    "晚安",
    "Buenas noches",
    "تصبح على خير",
    "शुभ रात्रि",
    "শুভ রাত্রি",
    "Boa noite",
    "Надобраніч",
    "おやすみ",
    "ਸ਼ੁਭ ਰਾਤ"
]

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
            var targetPhrase: String = helloPhrases.randomElement()!
            var targetHour: Int = expirationHour
            
            print(phrase)
            print(currentHour)
            print(expirationHour)
            
            if phrase == nil || currentHour > expirationHour {
                if currentHour >= 0 && currentHour <= 12 {
                    targetPhrase = morningPhrases.randomElement()!
                    targetHour = 12
                }
                
                if currentHour >= 13 && currentHour <= 16 {
                    targetPhrase = afternoonPhrases.randomElement()!
                    targetHour = 16
                }
                
                if currentHour >= 17 && currentHour <= 20 {
                    targetPhrase = eveningPhrases.randomElement()!
                    targetHour = 20
                }
                
                if currentHour >= 21 && currentHour <= 24 {
                    targetPhrase = nightPhrases.randomElement()!
                    targetHour = 24
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
