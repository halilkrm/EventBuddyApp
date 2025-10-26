//
//  LoginViewController.swift
//  EventBuddy
//
//  Created by Halil Keremoğlu on 20.10.2025.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "E-posta"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Şifre"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Giriş Yap", for: .normal)
        button.backgroundColor = .systemGreen // Rengi farklı olsun
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)//buttona tıklanınca handleLogin cagırılır
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Giriş Yap"
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func handleLogin() {
        print("Giriş yap butonuna tıklandı!")
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            
            print("Hata: E-posta veya şifre alanı boş.")
            // TODO: Kullanıcıya Alert göster
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            // Hata varsa:
            if let error = error {
                print("Kullanıcı giriş yapamadı: \(error.localizedDescription)")
                
                // TODO: Kullanıcıya Alert göster
                return
            }
            
            // Başarılı;
            print("Kullanıcı başarıyla giriş yaptı! UID: \(authResult!.user.uid)")
            
            // Giriş ekranını (kendisini) kapat
            self.dismiss(animated: true, completion: nil)
        }
    }
}
