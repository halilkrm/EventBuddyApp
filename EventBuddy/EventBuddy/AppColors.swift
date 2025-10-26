//
//  AppColors.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 21.10.2025.
//

import SwiftUI


extension Color{
    
    
    static let appPrimary = Color(red: 0/255, green: 122/255, blue: 255/255) //Parlak Mavi
    static let appSecondary = Color(red: 100/255, green: 100/255, blue: 100/255) // Koyu Gri
    static let appBackground = Color(red: 242/255, green: 242/255, blue: 247/255) // Çok Açık Gri (Sistem Rengi gibi)
    static let appText = Color(red: 20/255, green: 20/255, blue: 20/255) // Siyaha yakın
    
}

struct PrimaryButtonStyle: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(Color.appPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98: 1.0) // Basılma efekti
            .shadow(color: .appPrimary.opacity(0.3),radius: 5, x:0 ,y:5)
    }
}


struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(Color.appBackground)
            .foregroundColor(Color.appPrimary)
            .cornerRadius(10)
            .overlay(
            RoundedRectangle(cornerRadius: 10)
            .stroke(Color.appPrimary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
