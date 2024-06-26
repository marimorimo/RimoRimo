//
//  SignUpViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import SnapKit
import FirebaseFirestore

protocol SignupViewControllerDelegate: AnyObject {
    func privacyPolicyStackViewDidTap()
}

class SignupViewController: UIViewController {
    
    private let signupView = SignupView()
    private let firebaseManager = FirebaseManager.shared
    private let userModel = UserModel.shared
    
    private let alertOnly = AlertOnly()
    
    private var isNicknameChecked = false
    private var isEmailChecked = false
    private var isPrivacyPolicyChecked = false

    override func loadView() {
        view = signupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCallbacks()
        setupTextFields()
        hideKeyboardWhenTappedAround()
    }
    
    private func setupTextFields() {
        setupTextFieldDelegates()
        setupReturnKeyTypes()
    }

    private func setupTextFieldDelegates() {
        signupView.nicknameFieldSetup.textField.delegate = self
        signupView.emailFieldSetup.textField.delegate = self
        signupView.passwordFieldSetup.textField.delegate = self
        signupView.checkPasswordFieldSetup.textField.delegate = self
    }

    private func setupReturnKeyTypes() {
        signupView.nicknameFieldSetup.textField.returnKeyType = .next
        signupView.emailFieldSetup.textField.returnKeyType = .next
        signupView.passwordFieldSetup.textField.returnKeyType = .next
        signupView.checkPasswordFieldSetup.textField.returnKeyType = .done
        
        signupView.checkPasswordFieldSetup.textField.isSecureTextEntry = true
        signupView.checkPasswordFieldSetup.textField.textContentType = .newPassword
    }
    
    private func setupNavigationBar() {
        title = "회원가입"
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = MySpecialColors.MainColor
    }
    
    private func setupCallbacks() {
        signupView.delegate = self
        
        signupView.onNicknameDeleteIconTapped = { [weak self] in
            self?.handleDeleteIconTap(for: self?.signupView.nicknameFieldSetup.textField)
        }
        
        signupView.onEmailDeleteIconTapped = { [weak self] in
            self?.handleDeleteIconTap(for: self?.signupView.emailFieldSetup.textField)
        }
        
        signupView.onPasswordHiddenIconTapped = { [weak self] in
            self?.handleHiddenIconTap(for: self?.signupView.passwordFieldSetup.textField, in: self?.signupView.passwordFieldSetup)
        }
        
        signupView.onPasswordDeleteIconTapped = { [weak self] in
            self?.handleDeleteIconTap(for: self?.signupView.passwordFieldSetup.textField)
        }
        
        signupView.onCheckPasswordHiddenIconTapped = { [weak self] in
            self?.handleHiddenIconTap(for: self?.signupView.checkPasswordFieldSetup.textField, in: self?.signupView.checkPasswordFieldSetup)
        }
        
        signupView.onCheckPasswordDeleteIconTapped = { [weak self] in
            self?.handleDeleteIconTap(for: self?.signupView.checkPasswordFieldSetup.textField)
        }
        
        signupView.setSignupButtonTarget(self, action: #selector(signButtonTapped), for: .touchUpInside)
        signupView.nameDoubleCheckButtonTarget(self, action: #selector(nameDoubleCheckButtonTapped), for: .touchUpInside)
        signupView.privacyPolicyButtonTarget(self, action: #selector(privacyPolicyButtonTapped), for: .touchUpInside)
        signupView.emailDoubleCheckButtonTarget(self, action: #selector(emailDoubleCheckButtonTapped), for: .touchUpInside)
    }

    private func handleDeleteIconTap(for textField: UITextField?) {
        textField?.text = ""
        if textField == signupView.nicknameFieldSetup.textField {
            isNicknameChecked = false
        }
        signupViewDidChangeTextFields()
    }

    private func handleHiddenIconTap(for textField: UITextField?, in setup: SecureFieldSetup?) {
        guard let textField = textField, let setup = setup else { return }
        
        textField.isSecureTextEntry.toggle()
        
        let iconName = textField.isSecureTextEntry ? "show-block" : "show"
        setup.hiddenIcon.image = UIImage(named: iconName)
    }

    @objc private func nameDoubleCheckButtonTapped() {
        guard let nickname = signupView.nicknameFieldSetup.textField.text, !nickname.isEmpty else {
            DispatchQueue.main.async {
                self.signupView.alertNicknameTextLabel.text = "닉네임을 입력해주세요."
                self.signupView.alertNicknameTextLabel.textColor = MySpecialColors.Red
            }
            return
        }
        
        guard validateNickname(nickname) else {
            DispatchQueue.main.async {
                self.signupView.alertNicknameTextLabel.text = "닉네임은 한글/숫자 2~8자 또는 영어/숫자 4~16자로 입력해주세요."
                self.signupView.alertNicknameTextLabel.textColor = MySpecialColors.Red
            }
            return
        }
        
        firebaseManager.checkNicknameExists(nickname: nickname) { [weak self] exists, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.signupView.alertNicknameTextLabel.text = "닉네임 확인 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self?.signupView.alertNicknameTextLabel.textColor = MySpecialColors.Red
                    return
                }
                
                if exists {
                    self?.signupView.alertNicknameTextLabel.text = "이미 사용 중인 닉네임입니다."
                    self?.signupView.alertNicknameTextLabel.textColor = MySpecialColors.Red
                    self?.isNicknameChecked = false
                } else {
                    self?.signupView.alertNicknameTextLabel.text = "사용할 수 있는 닉네임입니다."
                    self?.signupView.alertNicknameTextLabel.textColor = MySpecialColors.MainColor
                    self?.isNicknameChecked = true
                    self?.signupViewDidChangeTextFields()
                }
            }
        }
    }

    @objc private func emailDoubleCheckButtonTapped() {
        guard let email = signupView.emailFieldSetup.textField.text, !email.isEmpty else {
            DispatchQueue.main.async {
                self.signupView.alertEmailTextLabel.text = "이메일을 입력해주세요."
                self.signupView.alertEmailTextLabel.textColor = MySpecialColors.Red
            }
            return
        }
        
        guard validateEmail(email) else {
            DispatchQueue.main.async {
                self.signupView.alertEmailTextLabel.text = "이메일 형식을 확인해 주세요."
                self.signupView.alertEmailTextLabel.textColor = MySpecialColors.Red
            }
            return
        }
        
        firebaseManager.checkEmailExists(email) { [weak self] exists, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.signupView.alertEmailTextLabel.text = "이메일 확인 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self?.signupView.alertEmailTextLabel.textColor = MySpecialColors.Red
                    return
                }
                
                if exists {
                    self?.signupView.alertEmailTextLabel.text = "이미 사용 중인 이메일입니다."
                    self?.signupView.alertEmailTextLabel.textColor = MySpecialColors.Red
                    self?.isEmailChecked = false
                } else {
                    self?.signupView.alertEmailTextLabel.isHidden = false
                    self?.signupView.alertEmailTextLabel.text = "사용할 수 있는 이메일입니다."
                    self?.signupView.alertEmailTextLabel.textColor = MySpecialColors.MainColor
                    self?.isEmailChecked = true
                    self?.signupViewDidChangeTextFields()
                }
            }
        }
    }
    
    @objc private func privacyPolicyButtonTapped() {
        let isCircle = signupView.checkIconButton.currentImage == UIImage(systemName: "circle")
        let newImage = isCircle ? "checkmark.circle.fill" : "circle"
        isPrivacyPolicyChecked = true
        signupView.checkIconButton.setImage(UIImage(systemName: newImage), for: .normal)
        signupView.checkIconButton.tintColor = MySpecialColors.MainColor
        signupViewDidChangeTextFields()
    }
    
    @objc private func signButtonTapped() {
        signupView.activityIndicator.startAnimating()
        guard let email = signupView.emailFieldSetup.textField.text,
               let password = signupView.passwordFieldSetup.textField.text,
               let nickname = signupView.nicknameFieldSetup.textField.text else {
             return
         }
                  
        FirebaseManager.shared.registerUser(email: email, password: password, nickname: nickname, isPrivacyPolicyChecked: isPrivacyPolicyChecked) { success, error in
            self.signupView.activityIndicator.stopAnimating()
             if let error = error {
                 self.alertOnly.setAlertView(title: "회원가입 실패", subTitle: "다시 시도해 주세요.", in: self)
                 print("회원가입 실패 \(error.localizedDescription)")
                 self.signupView.activityIndicator.stopAnimating() // 실패 시 로딩 인디케이터를 멈춤
                 return
             }
            self.alertOnly.setAlertView(title: "회원가입 성공", subTitle: "로그인을 시도해 주세요.", in: self)
             self.alertOnly.completionHandler = {
                 self.navigationController?.popViewController(animated: true)
             }
         }
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case signupView.nicknameFieldSetup.textField:
            signupView.emailFieldSetup.textField.becomeFirstResponder()
            
        case signupView.emailFieldSetup.textField:
            signupView.passwordFieldSetup.textField.becomeFirstResponder()
            
        case signupView.passwordFieldSetup.textField:
            signupView.checkPasswordFieldSetup.textField.becomeFirstResponder()
            
        case signupView.checkPasswordFieldSetup.textField:
            textField.resignFirstResponder()
            if !isPrivacyPolicyChecked {
                self.alertOnly.setAlertView(title: "필수", subTitle: "필수 사항을 모두 확인해 주세요.", in: self)
            } else {
                signButtonTapped()
            }
            
        default:
            break
        }
        return true
    }
    
    private func validatePassword(_ password: String) -> Bool {
        // 비밀번호는 최소한 하나의 대문자, 소문자, 숫자를 포함해야 하며, 8~16자여야 함
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d@$!%*?&]{8,16}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // MARK: - Password Matching
    private func checkPasswordMatch() -> Bool {
        let password = signupView.passwordFieldSetup.textField.text ?? ""
        let checkPassword = signupView.checkPasswordFieldSetup.textField.text ?? ""
        return password == checkPassword
    }
}

extension SignupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == signupView.nicknameFieldSetup.textField {
            isNicknameChecked = false
        }
        if textField == signupView.emailFieldSetup.textField {
            isEmailChecked = false
        }
 
        signupViewDidChangeTextFields()
        return true
    }
}

extension SignupViewController: SignupViewDelegate {
    // 교체 해야 함
    func privacyPolicyStackViewDidTap() {
        let privacyPolicyVC = PrivacyPolicyViewController()
        navigationController?.pushViewController(privacyPolicyVC, animated: true)
    }
    
    func signupViewDidChangeTextFields() {
        let nicknameValid = !signupView.nicknameFieldSetup.textField.text!.isEmpty
        let emailValid = !signupView.emailFieldSetup.textField.text!.isEmpty
        let passwordValid = !signupView.passwordFieldSetup.textField.text!.isEmpty
        let checkPasswordValid = !signupView.checkPasswordFieldSetup.textField.text!.isEmpty
        let isNicknameChecked = self.isNicknameChecked
        let isEmailChecked = self.isEmailChecked
        let isPrivacyPolicyChecked = self.isPrivacyPolicyChecked
        let isPasswordValid = validatePassword(signupView.passwordFieldSetup.textField.text ?? "")
        let doPasswordsMatch = checkPasswordMatch()
        
        var isEnabled = nicknameValid && emailValid && passwordValid && checkPasswordValid && isNicknameChecked && isEmailChecked && isPasswordValid && doPasswordsMatch && isPrivacyPolicyChecked
        
        if !isPasswordValid {
            signupView.configureAlert(for: signupView.alertPasswordTextLabel, text: "비밀번호는 최소 하나의 대문자, 소문자, 숫자를 포함해야 하며 8~16자여야 합니다.", textColor: MySpecialColors.Red)
            isEnabled = false
        } else {
            signupView.configureAlert(for: signupView.alertPasswordTextLabel, text: "사용할 수 있는 비밀번호 입니다.", textColor: MySpecialColors.MainColor)
            
            if !doPasswordsMatch {
                signupView.configureAlert(for: signupView.alertCheckPasswordTextLabel, text: "비밀번호가 일치하지 않습니다.", textColor: MySpecialColors.Red)
                isEnabled = false
            } else {
                signupView.configureAlert(for: signupView.alertCheckPasswordTextLabel, text: "비밀번호가 일치합니다.", textColor: MySpecialColors.MainColor)
            }
        }
        
        DispatchQueue.main.async {
            self.signupView.signupButton.isEnabled = isEnabled
            if isEnabled {
                self.signupView.signupButton.backgroundColor = MySpecialColors.MainColor
            } else {
                self.signupView.signupButton.backgroundColor = MySpecialColors.Gray3
            }
        }
    }
    
    // MARK: - Validation Methods
    private func validateNickname(_ nickname: String) -> Bool {
        // - 2 to 8 Korean characters (가-힣)
        // - 4 to 16 English characters (a-zA-Z) or numbers (0-9)
        let nicknameRegex = "^(?:[가-힣a-zA-Z0-9]{2,8}|(?=.*[a-zA-Z0-9]{4,16}$)[a-zA-Z0-9가-힣&&[^@#$%^&*()!{}\\[\\]\'./;,+=]]{4,16})$"
        return NSPredicate(format: "SELF MATCHES %@", nicknameRegex).evaluate(with: nickname)
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
