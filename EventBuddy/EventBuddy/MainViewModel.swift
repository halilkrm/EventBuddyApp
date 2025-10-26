//
//  MainViewModel.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 20.10.2025.
//

import Foundation
import FirebaseAuth
import Combine // ObservableObject için gerekli

class MainViewModel: ObservableObject {
    
    //@Published değişken: Arayüz (MainView) bu değişkeni dinleyecek.
    // Değeri değiştiğinde arayüz kendini güncelleyecek.
    @Published var userSession: User? // Firebase'in 'User' objesi
    
    // Auth state listener'ını tutmak için bir referans
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        print("MainViewModel başlatıldı (Auth dinleyicisi kuruluyor).")
        // ViewModel başlatıldığında hemen dinlemeye başla
        self.listenToAuthState()
    }
    
    deinit {
        //ViewModel hafızadan silinirken dinleyiciyi kaldır (Temizlik)
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
            print("Auth dinleyicisi kaldırıldı.")
        }
    }
    
    func listenToAuthState() {
        //Firebase Auth'un durum değişikliği dinleyicisini ekle
        // Bu dinleyici, birisi giriş yaptığında VEYA çıkış yaptığında otomatik olarak tetiklenir.
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            
            // 'user' objesi, giriş yapmış kullanıcıdır.
            // Eğer kimse giriş yapmamışsa 'user' nil olur.
            // Bu 'user' objesini @Published değişkenine atıyoruz.
            self?.userSession = user
            
            if user != nil {
                print("Durum Değişikliği: Kullanıcı giriş yaptı.")
            } else {
                print("Durum Değişikliği: Kullanıcı çıkış yaptı veya giriş yapmamış.")
            }
        }
    }
}
