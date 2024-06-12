//
//  SignUpViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SignUpViewController: UIViewController {
    
    private let signupTitle: UILabel = {
        let text = UILabel()
        text.text = "Sign Up"
        text.textAlignment = .center
        text.font = UIFont.boldSystemFont(ofSize: 24)
        return text
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let emailCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Check Email", for: .normal)
        button.addTarget(self, action: #selector(emailCheckButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Nickname"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let nicknameCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Check Nickname", for: .normal)
        button.addTarget(self, action: #selector(nicknameCheckButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(signupTitle)
        view.addSubview(emailTextField)
        view.addSubview(emailCheckButton)
        view.addSubview(passwordTextField)
        view.addSubview(nicknameTextField)
        view.addSubview(nicknameCheckButton)
        view.addSubview(signUpButton)
        view.addSubview(backButton)
        
        signupTitle.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailCheckButton.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        nicknameCheckButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: signupTitle.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: 200),
            
            emailCheckButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailCheckButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailCheckButton.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 200),
            
            nicknameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            nicknameTextField.widthAnchor.constraint(equalToConstant: 200),
            
            nicknameCheckButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameCheckButton.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 10),
            
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: nicknameCheckButton.bottomAnchor, constant: 20),
            
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
        ])
    }
    
    @objc private func emailCheckButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            return
        }
        
        Firestore.firestore().collection("user-info").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                print("Email 사용 불가능")
            } else {
                print("Email 사용 가능")
            }
        }
    }
    
    @objc private func nicknameCheckButtonTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            return
        }
        
        Firestore.firestore().collection("user-info").whereField("nickname", isEqualTo: nickname).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking nickname: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                print("Nickname 사용 불가능")
            } else {
                print("Nickname 사용 가능")
            }
        }
    }
    
    @objc private func signUpButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let nickname = nicknameTextField.text, !nickname.isEmpty else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("회원가입 실패 \(error.localizedDescription)")
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            
            if let profileImage = UIImage(named: "Group 1"), let imageData = profileImage.jpegData(compressionQuality: 0.5) {
                let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("이미지 업로드 실패 \(error.localizedDescription)")
                        return
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            print("Error fetching download URL: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        let userData: [String: Any] = [
                            "email": email,
                            "nickname": nickname,
                            "profile-image": downloadURL.absoluteString,
                            "block-user-list": [],
                            "d-day-title": "",
                            "d-day": "",
                            "target-time": ""
                        ]
                        Firestore.firestore().collection("user-info").document(uid).setData(userData) { error in
                            if let error = error {
                                print("회원가입 정보 저장 실패 \(error.localizedDescription)")
                            } else {
                                print("회원가입 정보 저장 성공")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
