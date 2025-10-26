//
//  LoginViewRepresentable.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 20.10.2025.
//

import SwiftUI
import UIKit

// Bu yapı, UIKit'teki LoginViewController'ımızı
// SwiftUI'da bir View gibi kullanılabilir hale getiren köprüdür.
struct LoginViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> LoginViewController {
        return LoginViewController()
    }
    
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {
        // Gerekirse güncelleme kodları buraya
    }
}
