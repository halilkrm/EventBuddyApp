//
//  AuthenticationView.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 20.10.2025.
//
import SwiftUI

struct AuthenticationView: View {
    
    // Sheet'leri açıp kapatmak için state'ler
    @State private var isShowingSignUpSheet = false
    @State private var isShowingLoginSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Image("WelcomeImage") 
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 200)
            .padding(.bottom, 20)
            
            Text("EventBuddy'e Hoş Geldin!")
                .font(.largeTitle).bold()
                .padding(.bottom, 40)
            
            // Kayıt Ol Butonu
            Button("Kayıt Ol") {
                isShowingSignUpSheet = true
            }
            .buttonStyle(PrimaryButtonStyle())
            
            
            // Giriş Yap Butonu
            Button("Giriş Yap") {
                isShowingLoginSheet = true
            }
            .buttonStyle(SecondaryButtonStyle())

            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) 
        .background(Color.appBackground.ignoresSafeArea())
        
        // Sheet'ler
        .sheet(isPresented: $isShowingSignUpSheet) {
            SignUpViewRepresentable()
        }
        .sheet(isPresented: $isShowingLoginSheet) {
            LoginViewRepresentable()
        }
    }
}

#Preview {
    AuthenticationView()
}
