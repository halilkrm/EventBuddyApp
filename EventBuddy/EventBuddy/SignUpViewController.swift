//
//  SignUpViewController.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 20.10.2025.
//

// Cocoa Touch Class", UIKit'e özel sınıflar oluşturmak için kullanılan,  zaman kazandıran ve "hazır kalıp" (boilerplate) kodları otomatik yazan bir dosya şablonudur.
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController { // -> view kısmı buradan geliyor
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "E-posta"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress // klavyede @ isaretini cıkarır
        tf.translatesAutoresizingMaskIntoConstraints = false // elemanın nerede duracagına kendim manuel olarak karar vereceğim
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder =  "Şifre (en az 6 karakter)"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true // sifreyi gizleme
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let signUpButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kayıt Ol", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Kayıt Ol"
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo:emailTextField.bottomAnchor,constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            signUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor,constant: 30),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
    }
    
    @objc func handleSignUp() {
            print("Kayıt ol butonuna tıklandı!")
        
        guard let email = emailTextField.text, !email.isEmpty, // guard let ile alanların boş olmadığını ve nil olmadığını kontrol ederiz.
              let password = passwordTextField.text, !password.isEmpty else{
            
            print("Hata! E-posta veya şifre alanı boş.")
           //  TODO: Kullanıcıya bir uyarı (Alert) göstermek daha iyi olur.
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult,error in
             // Hata varsa:
            if let error = error {
                print("Kullanıcı olusturulamadı: \(error.localizedDescription)")
                // TODO: Kullanıcıya hatayı göster (Alert).
                // Örn: "Şifre çok kısa", "E-posta formatı yanlış", "E-posta zaten kullanılıyor"
                return
            }
            
            guard let user = authResult?.user else{
                print("Kullanıcı olusturuldu ama kullanıcı verisi alınamadı")
                return
            }
            let userUID = user.uid
            
            let db = Firestore.firestore()
            
            let newUserDocument: [String: Any] = [
                "uid" : userUID,
                "email" : email // Kullanıcının kayıt oldugu e-posta
            ]
            
            db.collection("users").document(userUID).setData(newUserDocument) { error in
                
                if let error = error {
                    print("HATA: Kullanıcı Firestore 'users' koleksiyonuna kaydedilemedi: \(error.localizedDescription)")
                } else {
                    print("Kullanıcı Auth'a ve Firestore'a başarıyla kaydedildi.")
                }
            }
            
            print("KUllanıcı başarıyla oluşturuldu! UID:\(user.uid)")
             self.dismiss(animated: true, completion: nil)//view controllerı kapatır
            
            
        }
        
        }
    
    
}
