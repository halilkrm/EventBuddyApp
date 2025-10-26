//
//  MainView.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 20.10.2025.
//
import SwiftUI
import FirebaseAuth

//Trafik polisi gibidir. Aldıgı bilgiye göre veriye dogru view'a yönlendirir
struct MainView: View {
    
    //Oluşturduğumuz "Auth Beynini" dinlemeye al.
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        
        if let userSession = viewModel.userSession { //usersession giris kartı demektir
                    // "userSession" objesini doğrudan ContentView'e baglıyoruz
                    ContentView(userSession: userSession)
                } else {
                    AuthenticationView()
                }
    }
}

#Preview {
    MainView()
}
