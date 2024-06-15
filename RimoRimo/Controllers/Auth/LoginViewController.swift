//
//  LoginViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let saveAutoLoginInfo: String = "userEmail"

    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - HeaderView
    private let HeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let LogoImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "logo-image")
        return image
    }()
    
    // MARK: - MiddleView
    private let MiddleView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let EmailTextFieldView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let PasswordTextFieldView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let MiddleLabelView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let alertTextLabel: UILabel = {
        let text = UILabel()
        text.text = "이메일 또는 비밀번호가 일치하지 않습니다."
        text.textAlignment = .left
        text.textColor = MySpecialColors.Red
        text.font = UIFont.pretendard(style: .regular, size: 10, isScaled: true)
        return text
    }()
    
    private let findPasswordLabel: UILabel = {
        let text = UILabel()
        text.text = "비밀번호 찾기"
        text.textAlignment = .right
        text.font = UIFont.systemFont(ofSize: 12)
        text.textColor = MySpecialColors.Gray3
        text.isUserInteractionEnabled = true
        return text
    }()
    
    // MARK: - BottomView
    private let BottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let BottomLabelView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let signUpLabel: UIView = {
        let text = UILabel()
        text.text = "리모리모가 처음이신가요?"
        text.textColor = MySpecialColors.Gray3
        text.font = UIFont.systemFont(ofSize: 12)
        return text
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(MySpecialColors.MainColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.addTarget(self, action: #selector(presentSignUpViewController), for: .touchUpInside)
        return button
    }()

    let emailFieldStackView = TextFieldUIFactory.stackBox()
    let emailTextFieldStackView = TextFieldUIFactory.textFieldStackView(spacing: 10)

    let emailFieldIcon = TextFieldUIFactory.fieldIcon(name: "mail")
    
    let emailDeleteIcon = TextFieldUIFactory.deleteIcon(name: "close-circle")

    let emailTextField = TextFieldUIFactory.textField(placeholder: "이메일을 입력해 주세요.")
    
    let passwordTextField = TextFieldUIFactory.textField(placeholder: "비밀번호를 입력해 주세요.")
    
    let passwordFieldStackView = TextFieldUIFactory.stackBox()
    let passwordTextFieldStackView = TextFieldUIFactory.textFieldStackView(spacing: 10)
    
    let passwordFieldIcon = TextFieldUIFactory.fieldIcon(name: "lock")
    
    let passwordDeleteIcon = TextFieldUIFactory.deleteIcon(name: "close-circle")
    let hiddenIcon = TextFieldUIFactory.hiddenIcon(name: "show-block")
    
    let LoginButton = TabButtonUIFactory.tapButton(buttonTitle: "로그인", textColor: MySpecialColors.Gray1, cornerRadius: 24, backgroundColor: MySpecialColors.Gray2)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MySpecialColors.Gray1
        alertTextLabel.isHidden = true
        
        setupActivityIndicator()
        setupHeaderView()
        setupMiddleView()
        setupBottomView()
        
        setupButtons()
        
        // 탭 제스처 생성
        let findTapGesture = UITapGestureRecognizer(target: self, action: #selector(findPasswordTapped))
        // 제스처를 레이블에 추가
        findPasswordLabel.addGestureRecognizer(findTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // 텍스트 필드에 대한 이벤트 처리 설정
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        emailTextField.keyboardType = UIKeyboardType.emailAddress
        passwordTextField.keyboardType = UIKeyboardType.asciiCapable
        
        passwordTextField.textContentType = .newPassword
        
        emailTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .done
        
        passwordTextField.isSecureTextEntry = true

        setupEmailDeleteIcon()
        setupPasswordEyeToggle()
        updatePasswordHiddenIconImage()
        setupPasswordDeleteIcon()
        
        // 처음 한 번 호출
        setupLoginButton()
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
            loginButtonTapped()
        default:
            break
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        setupLoginButton()
    }
    
    //MARK: - setupActivityIndicator
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    //MARK: - setupHeaderView
    private func setupHeaderView() {
        // MARK: - HeaderView Layout
        view.addSubview(HeaderView)
        HeaderView.addSubview(LogoImageView)
        
        HeaderView.translatesAutoresizingMaskIntoConstraints = false
        LogoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            HeaderView.topAnchor.constraint(equalTo: view.topAnchor),
            HeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            HeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            HeaderView.heightAnchor.constraint(equalToConstant: 234),
            
            LogoImageView.bottomAnchor.constraint(equalTo: HeaderView.bottomAnchor),
            LogoImageView.centerXAnchor.constraint(equalTo: HeaderView.centerXAnchor),
            LogoImageView.widthAnchor.constraint(equalToConstant: 224),
            LogoImageView.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    //MARK: - setupMiddleView
    private func setupMiddleView() {
        // MARK: - MiddleView Layout
        let passwordIconsStackView = UIStackView()
        passwordIconsStackView.axis = .horizontal
        passwordIconsStackView.alignment = .center
        passwordIconsStackView.spacing = 10
        passwordIconsStackView.addArrangedSubview(hiddenIcon)
        passwordIconsStackView.addArrangedSubview(passwordDeleteIcon)
        
        view.addSubview(MiddleView)
        MiddleView.addSubview(EmailTextFieldView)
        EmailTextFieldView.addSubview(emailFieldStackView)
        emailFieldStackView.addSubview(emailTextFieldStackView)
        emailTextFieldStackView.addArrangedSubview(emailFieldIcon)
        emailTextFieldStackView.addArrangedSubview(emailTextField)
        emailTextFieldStackView.addArrangedSubview(emailDeleteIcon)
        
        MiddleView.addSubview(PasswordTextFieldView)
        PasswordTextFieldView.addSubview(passwordFieldStackView)
        passwordFieldStackView.addSubview(passwordTextFieldStackView)
        passwordTextFieldStackView.addArrangedSubview(passwordFieldIcon)
        passwordTextFieldStackView.addArrangedSubview(passwordTextField)
        passwordTextFieldStackView.addArrangedSubview(passwordIconsStackView)

        MiddleView.addSubview(MiddleLabelView)
        MiddleLabelView.addSubview(alertTextLabel)
        MiddleLabelView.addSubview(findPasswordLabel)
        
        MiddleView.translatesAutoresizingMaskIntoConstraints = false
        EmailTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        PasswordTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        MiddleLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        emailFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        emailTextFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        emailFieldIcon.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailDeleteIcon.translatesAutoresizingMaskIntoConstraints = false
        
        passwordFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        passwordFieldIcon.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordIconsStackView.translatesAutoresizingMaskIntoConstraints = false

        alertTextLabel.translatesAutoresizingMaskIntoConstraints = false
        findPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //MARK: - MiddleView
            MiddleView.topAnchor.constraint(equalTo: HeaderView.bottomAnchor, constant: 60),
            MiddleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            MiddleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            MiddleView.heightAnchor.constraint(equalToConstant: 148),
            
            //MARK: - EmailTextFieldView
            EmailTextFieldView.topAnchor.constraint(equalTo: MiddleView.topAnchor),
            EmailTextFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            EmailTextFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            EmailTextFieldView.heightAnchor.constraint(equalToConstant: 46),
            
            emailFieldStackView.centerXAnchor.constraint(equalTo: EmailTextFieldView.centerXAnchor),
            emailFieldStackView.centerYAnchor.constraint(equalTo: EmailTextFieldView.centerYAnchor),
            emailFieldStackView.leadingAnchor.constraint(equalTo: EmailTextFieldView.leadingAnchor, constant: 24),
            emailFieldStackView.trailingAnchor.constraint(equalTo: EmailTextFieldView.trailingAnchor, constant: -24),
            emailFieldStackView.heightAnchor.constraint(equalToConstant: 46),
            
            emailTextFieldStackView.leadingAnchor.constraint(equalTo: emailFieldStackView.leadingAnchor),
            emailTextFieldStackView.trailingAnchor.constraint(equalTo: emailFieldStackView.trailingAnchor),
            
            emailFieldIcon.widthAnchor.constraint(equalToConstant: 24),
            
            emailTextField.heightAnchor.constraint(equalToConstant: 46),
            emailTextField.widthAnchor.constraint(equalToConstant: emailTextFieldStackView.bounds.width - 48),
            
            emailDeleteIcon.widthAnchor.constraint(equalToConstant: 24),
            
            //MARK: - PasswordTextFieldView
            PasswordTextFieldView.topAnchor.constraint(equalTo: EmailTextFieldView.bottomAnchor, constant: 20),
            PasswordTextFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            PasswordTextFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            PasswordTextFieldView.heightAnchor.constraint(equalToConstant: 46),

            passwordFieldStackView.centerXAnchor.constraint(equalTo: PasswordTextFieldView.centerXAnchor),
            passwordFieldStackView.centerYAnchor.constraint(equalTo: PasswordTextFieldView.centerYAnchor),
            passwordFieldStackView.leadingAnchor.constraint(equalTo: PasswordTextFieldView.leadingAnchor, constant: 24),
            passwordFieldStackView.trailingAnchor.constraint(equalTo: PasswordTextFieldView.trailingAnchor, constant: -24),
            passwordFieldStackView.heightAnchor.constraint(equalToConstant: 46),
            
            passwordTextFieldStackView.leadingAnchor.constraint(equalTo: passwordFieldStackView.leadingAnchor),
            passwordTextFieldStackView.trailingAnchor.constraint(equalTo: passwordFieldStackView.trailingAnchor),
            
            passwordFieldIcon.widthAnchor.constraint(equalToConstant: 24),
            
            passwordTextField.heightAnchor.constraint(equalToConstant: 46),
            passwordTextField.widthAnchor.constraint(equalToConstant: passwordTextFieldStackView.bounds.width - 48),
            
            passwordIconsStackView.widthAnchor.constraint(equalToConstant: 58),
            
            //MARK: - MiddleLabelView
            MiddleLabelView.topAnchor.constraint(equalTo: PasswordTextFieldView.bottomAnchor, constant: 6),
            MiddleLabelView.leadingAnchor.constraint(equalTo:  view.leadingAnchor, constant: 24),
            MiddleLabelView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            MiddleLabelView.heightAnchor.constraint(equalToConstant: 22),
            
            alertTextLabel.centerYAnchor.constraint(equalTo: MiddleLabelView.centerYAnchor),
            alertTextLabel.leadingAnchor.constraint(equalTo: MiddleLabelView.leadingAnchor),
            alertTextLabel.widthAnchor.constraint(equalToConstant: 220),
            
            findPasswordLabel.centerYAnchor.constraint(equalTo: MiddleLabelView.centerYAnchor),
            findPasswordLabel.trailingAnchor.constraint(equalTo: MiddleLabelView.trailingAnchor),
            findPasswordLabel.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    //MARK: - setupBottomView
    private func setupBottomView() {
        view.addSubview(BottomView)
        BottomView.addSubview(LoginButton)
        BottomView.addSubview(BottomLabelView)
        BottomView.addSubview(signUpLabel)
        BottomView.addSubview(signUpButton)
        
        BottomView.translatesAutoresizingMaskIntoConstraints = false
        LoginButton.translatesAutoresizingMaskIntoConstraints = false
        BottomLabelView.translatesAutoresizingMaskIntoConstraints = false
        signUpLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            BottomView.topAnchor.constraint(equalTo: MiddleView.bottomAnchor, constant: 86),
            BottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            BottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            BottomView.heightAnchor.constraint(equalToConstant: 78),
            
            LoginButton.topAnchor.constraint(equalTo: BottomView.topAnchor),
            LoginButton.leadingAnchor.constraint(equalTo: BottomView.leadingAnchor, constant: 38),
            LoginButton.trailingAnchor.constraint(equalTo: BottomView.trailingAnchor, constant: -38),
            LoginButton.heightAnchor.constraint(equalToConstant: 46),
            
            BottomLabelView.topAnchor.constraint(equalTo: LoginButton.bottomAnchor, constant: 16),
            BottomLabelView.centerXAnchor.constraint(equalTo: BottomView.centerXAnchor),
            BottomLabelView.widthAnchor.constraint(equalToConstant: 187),
            BottomLabelView.heightAnchor.constraint(equalToConstant: 16),
            
            
            signUpLabel.centerYAnchor.constraint(equalTo: BottomLabelView.centerYAnchor),
            signUpLabel.leadingAnchor.constraint(equalTo: BottomLabelView.leadingAnchor),
            
            signUpButton.centerYAnchor.constraint(equalTo: BottomLabelView.centerYAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: BottomLabelView.trailingAnchor)
        ])
    }
    
    private func setupButtons() {
        LoginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    private func setupLoginButton() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty, !password.isEmpty else {

            UIView.animate(withDuration: 0.3) {
                self.LoginButton.isEnabled = false
                self.LoginButton.backgroundColor = MySpecialColors.Gray3
            }
            return
        }
        
        UIView.transition(with: LoginButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.LoginButton.isEnabled = true
            self.LoginButton.backgroundColor = MySpecialColors.MainColor
        }, completion: nil)
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
        activityIndicator.startAnimating()  
        // 로그인, 비밀번호 공백 예외처리
        guard let email = emailTextField.text, let password = passwordTextField.text,
              !email.isEmpty, !password.isEmpty else {
            alertTextLabel.isHidden = false
            alertTextLabel.text = "이메일과 비밀번호를 모두 입력해주세요."
            activityIndicator.stopAnimating() // 실패 시 로딩 인디케이터를 멈춤
            return
        }
        
        // 예외처리 이후 로그인 진행
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.activityIndicator.stopAnimating() // 완료 시 로딩 인디케이터를 멈춤
            if let error = error {
                // 로그인 실패 시 에러 메시지를 alertTextLabel에 표시
                self?.alertTextLabel.isHidden = false
                self?.alertTextLabel.text = "이메일 또는 비밀번호가 일치하지 않습니다."
                print("Login error: \(error.localizedDescription)")
                return
            }
            
            // 로그인 성공
            if let user = authResult?.user {
                print("User logged in successfully: \(user.email ?? "")")
                // 로그인 후 필요한 작업 수행
                self?.saveUserEmail(email)
                self?.navigateToMainScreen()
            }
        } 
    }
    
    // MARK: - UserDefaults에 로그인 정보 저장
    private func saveUserEmail(_ email: String) {
        UserDefaults.standard.set(email, forKey: saveAutoLoginInfo)
    }
    
    // MARK: - Email Delete Button
    private func setupEmailDeleteIcon() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clearEmailTextField))
        emailDeleteIcon.addGestureRecognizer(tapGestureRecognizer)
        emailDeleteIcon.isUserInteractionEnabled = true
    }

    @objc private func clearEmailTextField() {
        emailTextField.text = ""
    }
    // MARK: - Password Hidden Button
    private func setupPasswordEyeToggle() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleEyeIcon))
        hiddenIcon.addGestureRecognizer(tapGestureRecognizer)
        hiddenIcon.isUserInteractionEnabled = true
    }

    @objc private func toggleEyeIcon() {
        passwordTextField.isSecureTextEntry.toggle()
        updatePasswordHiddenIconImage()
    }
    
    private func updatePasswordHiddenIconImage() {
        let imageName = passwordTextField.isSecureTextEntry ? "show-block" : "show"
        hiddenIcon.image = UIImage(named: imageName)
    }
    
    // MARK: - Password Delete Button
    private func setupPasswordDeleteIcon() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clearPasswordTextField))
        passwordDeleteIcon.addGestureRecognizer(tapGestureRecognizer)
        passwordDeleteIcon.isUserInteractionEnabled = true
    }

    @objc private func clearPasswordTextField() {
        passwordTextField.text = ""
    }
    
    @objc private func presentSignUpViewController() {
        let signVC = SignUpViewController()
        navigationController?.pushViewController(signVC, animated: true)
    }
    
    // 비밀번호 찾기 레이블 클릭 처리 메서드
    @objc private func findPasswordTapped() {
        let findVC = FindPasswordViewController()
        navigationController?.pushViewController(findVC, animated: true)
    }
    
    // MARK: - Keyboard Dimiss
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func navigateToMainScreen() {
        let vc = TabBarViewController()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
}
