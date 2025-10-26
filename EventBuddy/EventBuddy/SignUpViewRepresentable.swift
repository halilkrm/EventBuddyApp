//
//  SignUpViewRepresentable.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 20.10.2025.
//

import SwiftUI
import UIKit

// Bu yapı, UIKit'teki ViewController'ımızı
// SwiftUI'da bir View gibi kullanılabilir hale getiren köprüdür.
struct SignUpViewRepresentable: UIViewControllerRepresentable {
    
    // Görevi: Bizim UIKit ViewController'ımızı oluşturup döndürmek.
    func makeUIViewController(context: Context) -> SignUpViewController {
        return SignUpViewController()
    }
    

    // UIKit tarafını güncellemek için kullanılır.
    func updateUIViewController(_ uiViewController: SignUpViewController, context: Context) {
        // Gerekirse güncelleme kodları buraya
    }
}
