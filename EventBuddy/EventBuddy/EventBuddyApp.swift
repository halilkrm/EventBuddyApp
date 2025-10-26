//
//  EventBuddyApp.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 14.10.2025.
//

import SwiftUI
import Firebase

@main
struct EventBuddyApp: App {
    
    // Firebase başlatma
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
