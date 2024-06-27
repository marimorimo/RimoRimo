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
                self.signupView.alertNicknameTextLabel.text = "닉네임은 한글/영어/숫자 2~8자로 입력해 주세요."
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
        isPrivacyPolicyChecked.toggle()
        
        let newImage = isPrivacyPolicyChecked ? "checkmark.circle.fill" : "circle"
        signupView.checkIconButton.setImage(UIImage(systemName: newImage), for: .normal)
        signupView.checkIconButton.tintColor = isPrivacyPolicyChecked ? MySpecialColors.MainColor : MySpecialColors.Gray3
        
        signupViewDidChangeTextFields()
    }
    
    @objc private func signButtonTapped() {
        signupView.activityIndicator.startAnimating()
        
        guard let email = signupView.emailFieldSetup.textField.text,
              let password = signupView.passwordFieldSetup.textField.text,
              let nickname = signupView.nicknameFieldSetup.textField.text else {
            return
        }
        
        let isNicknameValid = validateNickname(nickname)
        let isEmailValid = validateEmail(email)
        let isPasswordValid = validatePassword(password)
        let isCheckPasswordValid = checkPasswordMatch()
        
        let isEnabled = isNicknameValid && isEmailValid && isPasswordValid && isCheckPasswordValid && isPrivacyPolicyChecked && isNicknameChecked && isEmailChecked

        if isEnabled {
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
        } else {
            self.signupView.activityIndicator.stopAnimating()
            self.alertOnly.setAlertView(title: "필수", subTitle: "필수 사항을 모두 확인해 주세요.", in: self)
            signupViewDidChangeNicknameField()
            signupViewDidChangeEmailField()
            signupViewDidChangePasswordField()
            signupViewDidChangeCheckPasswordField()
            signupViewDidChangeCheckPasswordField()
            print("회원가입 조건이 충족되지 않음")
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
    func signupViewDidChangeNicknameField() {
        guard let nickname = signupView.nicknameFieldSetup.textField.text else {
            return
        }
        
        if nickname.isEmpty {
            // 닉네임 입력 필드가 비어있을 때
            signupView.alertNicknameTextLabel.text = "닉네임은 한글/영어/숫자 2~8자로 입력해 주세요."
            signupView.alertNicknameTextLabel.textColor = MySpecialColors.Gray3
        } else if !isNicknameChecked {
            signupView.alertNicknameTextLabel.text = "닉네임 중복 확인을 진행해 주세요."
            signupView.alertNicknameTextLabel.textColor = MySpecialColors.Gray3
        } else if !validateNickname(nickname) {
            // 닉네임이 유효하지 않을 때
            signupView.alertNicknameTextLabel.text = "닉네임은 한글/영어/숫자 2~8자로 입력해 주세요."
            signupView.alertNicknameTextLabel.textColor = MySpecialColors.Red
        }
        signupViewDidChangeTextFields()
    }
 
    func signupViewDidChangeEmailField() {
        guard let email = signupView.emailFieldSetup.textField.text else {
            return
        }
        
        if email.isEmpty {
            // 이메일 입력 필드가 비어있을 때
            signupView.alertEmailTextLabel.text = "예시) email@gmail.com"
            signupView.alertEmailTextLabel.textColor = MySpecialColors.Gray3
        } else if !isEmailChecked {
            signupView.alertEmailTextLabel.text = "이메일 중복 확인을 진행해 주세요."
            signupView.alertEmailTextLabel.textColor = MySpecialColors.Gray3
        } else if !validateEmail(email) {
            // 이메일 형식이 유효하지 않을 때
            signupView.alertEmailTextLabel.text = "이메일 형식을 확인해 주세요."
            signupView.alertEmailTextLabel.textColor = MySpecialColors.Red
        }
        signupViewDidChangeTextFields()
    }
    
    func signupViewDidChangePasswordField() {
        guard let password = signupView.passwordFieldSetup.textField.text else {
            return
        }
        
        if password.isEmpty {
            // 비밀번호 입력 필드가 비어있을 때
            signupView.alertPasswordTextLabel.text = "비밀번호는 대소문자와 숫자를 포함하여 8~16자여야 합니다."
            signupView.alertPasswordTextLabel.textColor = MySpecialColors.Gray3
        } else if !validatePassword(password) {
            // 비밀번호 형식이 유효하지 않을 때
            signupView.alertPasswordTextLabel.text = "비밀번호는 대소문자와 숫자를 포함하여 8~16자여야 합니다."
            signupView.alertPasswordTextLabel.textColor = MySpecialColors.Red
        } else {
            // 유효한 비밀번호인 경우
            signupView.alertPasswordTextLabel.text = "사용할 수 있는 비밀번호입니다."
            signupView.alertPasswordTextLabel.textColor = MySpecialColors.MainColor
        }
        signupViewDidChangeTextFields()
    }
    
    func signupViewDidChangeCheckPasswordField() {
        guard let password = signupView.passwordFieldSetup.textField.text else {
            return
        }
        
        guard let checkPassword = signupView.checkPasswordFieldSetup.textField.text else {
            return
        }
        
        if !password.isEmpty && validatePassword(password) {
            if checkPassword.isEmpty {
                // 비밀번호 확인 입력 필드가 비어있을 때
                signupView.alertCheckPasswordTextLabel.text = "비밀번호를 확인해 주세요."
                signupView.alertCheckPasswordTextLabel.textColor = MySpecialColors.Gray3
            } else if !checkPasswordMatch() {
                // 비밀번호 확인이 일치하지 않을 때
                signupView.alertCheckPasswordTextLabel.text = "비밀번호가 일치하지 않습니다."
                signupView.alertCheckPasswordTextLabel.textColor = MySpecialColors.Red
            } else {
                // 비밀번호 확인이 일치할 때
                signupView.alertCheckPasswordTextLabel.text = "비밀번호가 일치합니다."
                signupView.alertCheckPasswordTextLabel.textColor = MySpecialColors.MainColor
            }
        } else {
            signupView.checkPasswordFieldSetup.textField.text = ""
            signupView.alertCheckPasswordTextLabel.text = "비밀번호 입력 후 진행해 주세요."
            signupView.alertCheckPasswordTextLabel.textColor = MySpecialColors.Red
        }
        signupViewDidChangeTextFields()
    }
       
    func signupViewDidChangeTextFields() {
        guard let nickname = signupView.nicknameFieldSetup.textField.text, !nickname.isEmpty else {
            updateSignupButton(enabled: false)
            return
        }
        
        guard let email = signupView.emailFieldSetup.textField.text, !email.isEmpty else {
            updateSignupButton(enabled: false)
            return
        }
        
        guard let password = signupView.passwordFieldSetup.textField.text, !password.isEmpty else {
            updateSignupButton(enabled: false)
            return
        }
        
        guard let checkPassword = signupView.checkPasswordFieldSetup.textField.text, !checkPassword.isEmpty else {
            updateSignupButton(enabled: false)
            return
        }
        guard let checkPassword = signupView.checkPasswordFieldSetup.textField.text, !checkPassword.isEmpty else {
            updateSignupButton(enabled: false)
            return
        }

        let isNicknameValid = validateNickname(nickname)
        let isEmailValid = validateEmail(email)
        let isPasswordValid = validatePassword(password)
        let isCheckPasswordValid = checkPasswordMatch()
        
        let isEnabled = isNicknameValid && isEmailValid && isPasswordValid && isCheckPasswordValid && isPrivacyPolicyChecked && isNicknameChecked && isEmailChecked
        
        updateSignupButton(enabled: isEnabled)
    }

    private func updateSignupButton(enabled: Bool) {
        DispatchQueue.main.async {
            self.signupView.signupButton.isEnabled = enabled
            self.signupView.signupButton.backgroundColor = enabled ? MySpecialColors.MainColor : MySpecialColors.Gray3
        }
    }

    func privacyPolicyStackViewDidTap() {
        let privacyPolicyVC = PrivacyPolicyViewController()
        navigationController?.pushViewController(privacyPolicyVC, animated: true)
    }

    // MARK: - Validation Methods
    private func validateNickname(_ nickname: String) -> Bool {
        let forbiddenCharacters = "[!@#$%^&*()_+|}{\\[\\]\\\\;'\":.,/?><]"
        let nicknameRegex = "^[가-힣a-zA-Z0-9]{2,8}$"
        let noForbiddenCharacters = NSPredicate(format: "SELF MATCHES %@", forbiddenCharacters).evaluate(with: nickname) == false
        let isValidFormat = NSPredicate(format: "SELF MATCHES %@", nicknameRegex).evaluate(with: nickname)
        return isValidFormat && noForbiddenCharacters
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
