//
//  LoginViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    private let firebaseManager = FirebaseManager.shared
    private let userModel = UserModel.shared
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallbacks()
        setupTextFields()
        hideKeyboardWhenTappedAround()
    }
    
    private func setupTextFields() {
        setupTextFieldDelegates()
        setupReturnKeyTypes()
    }

    private func setupTextFieldDelegates() {
        loginView.emailFieldSetup.textField.delegate = self
        loginView.passwordFieldSetup.textField.delegate = self
    }

    private func setupReturnKeyTypes() {
        loginView.emailFieldSetup.textField.returnKeyType = .next
        loginView.passwordFieldSetup.textField.returnKeyType = .done
    }

    private func setupCallbacks() {
        loginView.delegate = self

        loginView.onEmailDeleteIconTapped = { [weak self] in
            self?.handleDeleteIconTap(for: self?.loginView.emailFieldSetup.textField)
        }
        
        loginView.onHiddenIconTapped = { [weak self] in
            self?.handleHiddenIconTap(for: self?.loginView.passwordFieldSetup.textField, in: self?.loginView.passwordFieldSetup)
        }
        
        loginView.onDeleteIconTapped = { [weak self] in
            self?.handleDeleteIconTap(for: self?.loginView.passwordFieldSetup.textField)
        }
        
        loginView.setFindPasswordButtonTarget(self, action: #selector(findPasswordButtonTapped), for: .touchUpInside)
        loginView.setLgoinButtonTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginView.setSignupButtonTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
    }

    private func handleDeleteIconTap(for textField: UITextField?) {
        textField?.text = ""
    }

    private func handleHiddenIconTap(for textField: UITextField?, in setup: SecureFieldSetup?) {
        guard let textField = textField, let setup = setup else { return }
        
        textField.isSecureTextEntry.toggle()
        
        let iconName = textField.isSecureTextEntry ? "show-block" : "show"
        setup.hiddenIcon.image = UIImage(named: iconName)
    }
    
    @objc private func findPasswordButtonTapped() {
        let findVC = FindPasswordViewController()
        navigationController?.pushViewController(findVC, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        loginView.activityIndicator.startAnimating()
        
        guard let email = loginView.emailFieldSetup.textField.text,
              let password = loginView.passwordFieldSetup.textField.text,
              !email.isEmpty, !password.isEmpty else {
            
            loginView.alertTextLabel.textColor = MySpecialColors.Red
            loginView.alertTextLabel.text = "이메일과 비밀번호를 모두 입력해주세요."
            loginView.activityIndicator.stopAnimating()
            return
        }
        
        firebaseManager.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.loginView.activityIndicator.stopAnimating()
            }
            if let error = error {
                self?.loginView.alertTextLabel.textColor = MySpecialColors.Red
                self?.loginView.alertTextLabel.text = "이메일 또는 비밀번호가 일치하지 않습니다."
                print("Login error: \(error.localizedDescription)")
                return
            }
            
            if let user = authResult?.user {
                print("Login successfully: \(user.email ?? "")")
                self?.userModel.saveUserEmail(email)
                self?.loginView.passwordFieldSetup.textField.text = ""
                self?.loginView.emailFieldSetup.textField.text = ""
                self?.loginView.alertTextLabel.textColor = .clear
                self?.navigateToTabBar()
            }
        }
    }
    
    @objc private func signupButtonTapped() {
        let signVC = SignupViewController()
        navigationController?.pushViewController(signVC, animated: true)
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case loginView.emailFieldSetup.textField:
            loginView.passwordFieldSetup.textField.becomeFirstResponder()
            
        case loginView.passwordFieldSetup.textField:
            textField.resignFirstResponder()
            loginButtonTapped()
            
        default:
            break
        }
        return true
    }

    private func navigateToTabBar() {
        let vc = TabBarViewController()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == loginView.emailFieldSetup.textField || textField == loginView.passwordFieldSetup.textField {
            loginViewDidChangeTextFields()
        }
        return true
    }
}

extension LoginViewController: LoginViewDelegate {
    func loginViewDidChangeTextFields() {
        let emailValid = !loginView.emailFieldSetup.textField.text!.isEmpty
        let passwordValid = !loginView.passwordFieldSetup.textField.text!.isEmpty
        
        let isEnabled = emailValid && passwordValid
        loginView.loginButton.isEnabled = isEnabled

        if isEnabled {
            loginView.loginButton.backgroundColor = MySpecialColors.MainColor
        } else {
            loginView.loginButton.backgroundColor = MySpecialColors.Gray3
            loginView.alertTextLabel.textColor = .clear
        }
    }
}
