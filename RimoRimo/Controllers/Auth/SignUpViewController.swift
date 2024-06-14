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

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    private var nicknameCheck: Bool = true
    private var emailCheck: Bool = false
    private var emailVerified = false
    private var passwordCheck: Bool = false
    private var passwordDoubleCheck: Bool = false
    
    // MARK: - HeaderView
    private let HeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let userNameTextFieldView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let emailTextFieldView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - BottomView
    private let BottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - alertTextLabel
    private func alertTextLabel(alertText: String, textColor: UIColor) -> UILabel {
        let text = UILabel()
        text.text = alertText
        text.textColor = textColor
        text.textAlignment = .left
        text.font = UIFont.pretendard(style: .regular, size: 10, isScaled: true)
        return text
    }
    
    let nameTextField = TextFieldUIFactory.textField(placeholder: "닉네임을 입력해 주세요.")
    let emailTextField = TextFieldUIFactory.textField(placeholder: "이메일을 입력해 주세요.")
    let passwordTextField = TextFieldUIFactory.textField(placeholder: "비밀번호를 입력해 주세요.")
    let passwordDoubleCheckTextField = TextFieldUIFactory.textField(placeholder: "비밀번호를 입력해 주세요.")
    
    let nameDoubleCheckButton = TabButtonUIFactory.doubleCheckButton(buttonTitle: "중복 확인", textColor: MySpecialColors.MainColor, cornerRadius: 12, backgroundColor: MySpecialColors.Gray1)
    let emailDoubleCheckButton = TabButtonUIFactory.doubleCheckButton(buttonTitle: "중복 확인", textColor: MySpecialColors.MainColor, cornerRadius: 12, backgroundColor: MySpecialColors.Gray1)

    let alertBack = AlertUIFactory.alertBackView()
    let alertView = AlertUIFactory.alertView()
    
    let alertTitle = AlertUIFactory.alertTitle(titleText: "차단 해제", textColor: MySpecialColors.Black, fontSize: 16)
    let alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: "차단을 해제하시겠습니까?", textColor: MySpecialColors.Gray4, fontSize: 14)
    
    let widthLine = AlertUIFactory.widthLine()

    let checkView = AlertUIFactory.checkView()
    let checkLabel = AlertUIFactory.checkLabel(cancleText: "확인", textColor: MySpecialColors.MainColor, fontSize: 14)
    
    let SignUpButton = TabButtonUIFactory.tapButton(
        buttonTitle: "회원가입",
        textColor: MySpecialColors.Gray1,
        cornerRadius: 24,
        backgroundColor: MySpecialColors.Gray2)
    
    lazy var nameAlertTextLabel: UILabel = alertTextLabel(alertText: nicknameCheck ? "사용할 수 있는 닉네임입니다." : "이미 사용 중인 닉네임입니다.", textColor: nicknameCheck ? MySpecialColors.MainColor : MySpecialColors.Red)
    
    lazy var emailAlertTextLabel: UILabel = alertTextLabel(alertText: emailCheck ? "사용할 수 있는 이메일입니다." : "이미 사용 중인 이메일입니다.", textColor: emailCheck ? MySpecialColors.MainColor : MySpecialColors.Red)
    
    lazy var passwordAlertTextLabel: UILabel = alertTextLabel(alertText: passwordCheck ? "✓대문자/소문자  ✓숫자  ✓특수문자" : "대문자/소문자, 숫자, 특수문자를 포함해 주세요.", textColor: passwordCheck ? MySpecialColors.MainColor : MySpecialColors.Red)

    lazy var passwordDoubleCheckAlertTextLabel: UILabel = alertTextLabel(alertText: passwordDoubleCheck ? "비밀번호가 일치합니다." : "비밀번호가 일치하지 않습니다.", textColor: passwordDoubleCheck ? MySpecialColors.MainColor : MySpecialColors.Red)
    
    let nameDeleteIcon = TextFieldUIFactory.deleteIcon(name: "close-circle")

    let emailDeleteIcon = TextFieldUIFactory.deleteIcon(name: "close-circle")
    
    let passwordDeleteIcon = TextFieldUIFactory.deleteIcon(name: "close-circle")
    let passwordHiddenIcon = TextFieldUIFactory.hiddenIcon(name: "show-block")
    
    let passwordDoubleCheckDeleteIcon = TextFieldUIFactory.deleteIcon(name: "close-circle")
    let passwordDoubleCheckHiddenIcon = TextFieldUIFactory.hiddenIcon(name: "show-block")

    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MySpecialColors.Gray1
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
             view.addGestureRecognizer(tapGesture)
        
        nameAlertTextLabel.isHidden = true
        emailAlertTextLabel.isHidden = true
        passwordAlertTextLabel.isHidden = true
        passwordDoubleCheckAlertTextLabel.isHidden = true
        
        setupNavigationBar()
        setupHeaderViews()
        setupBottomView()
        setupButtons()
        
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordDoubleCheckTextField.delegate = self
        
        // 텍스트 필드에 대한 이벤트 처리 설정
        nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: .editingChanged)
        passwordDoubleCheckTextField.addTarget(self, action: #selector(checkPasswordMatch), for: .editingChanged)
        
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        passwordTextField.keyboardType = UIKeyboardType.asciiCapable
        passwordDoubleCheckTextField.keyboardType = UIKeyboardType.asciiCapable
        
        passwordTextField.textContentType = .newPassword
        passwordDoubleCheckTextField.textContentType = .newPassword
        
        nameTextField.returnKeyType = .next
        emailTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .next
        passwordDoubleCheckTextField.returnKeyType = .done
        
        passwordTextField.isSecureTextEntry = true
        passwordDoubleCheckTextField.isSecureTextEntry = true
        
        setupNameDeleteIcon()
        setupEmailDeleteIcon()
        
        setupPasswordEyeToggle()
        setupPasswordCheckEyeToggle()
        
        updatePasswordHiddenIconImage()
        updatePasswordDoubleCheckHiddenIconImage()

        setupPasswordDeleteIcon()
        setupPasswordDoubleCheckDeleteIcon()

        // 처음 한 번 호출
        setupSignUpButton()
    }
    
    //MARK: - setupNavigationBar
    private func setupNavigationBar() {
        title = "회원가입"
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = MySpecialColors.MainColor
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordDoubleCheckTextField.becomeFirstResponder()
        case passwordDoubleCheckTextField:
            textField.resignFirstResponder()
            registerButtonTapped()
        default:
            break
        }
        return true
    }

 
    //MARK: - setupHeaderViews
    private func setupHeaderViews() {
        let nameFieldStackView = TextFieldUIFactory.stackBox()
        let nameTextFieldStackView = TextFieldUIFactory.textFieldStackView(spacing: 10)

        let nameFieldIcon = TextFieldUIFactory.fieldIcon(name: "user-02")

        let emailFieldStackView = TextFieldUIFactory.stackBox()
        let emailTextFieldStackView = TextFieldUIFactory.textFieldStackView(spacing: 10)

        let emailFieldIcon = TextFieldUIFactory.fieldIcon(name: "mail")
   
        let passwordFieldStackView = TextFieldUIFactory.stackBox()
        let passwordTextFieldStackView = TextFieldUIFactory.textFieldStackView(spacing: 10)
        
        let passwordFieldIcon = TextFieldUIFactory.fieldIcon(name: "lock")

        let passwordIconsStackView = UIStackView()
        passwordIconsStackView.axis = .horizontal
        passwordIconsStackView.alignment = .center
        passwordIconsStackView.spacing = 10
        passwordIconsStackView.addArrangedSubview(passwordHiddenIcon)
        passwordIconsStackView.addArrangedSubview(passwordDeleteIcon)
        
        let passwordDoubleCheckFieldStackView = TextFieldUIFactory.stackBox()
        let passwordDoubleCheckTextFieldStackView = TextFieldUIFactory.textFieldStackView(spacing: 10)
        
        let passwordDoubleCheckFieldIcon = TextFieldUIFactory.fieldIcon(name: "lock")
        

        
        let passwordDoubleCheckIconsStackView = UIStackView()
        passwordDoubleCheckIconsStackView.axis = .horizontal
        passwordDoubleCheckIconsStackView.alignment = .center
        passwordDoubleCheckIconsStackView.spacing = 10
        passwordDoubleCheckIconsStackView.addArrangedSubview(passwordDoubleCheckHiddenIcon)
        passwordDoubleCheckIconsStackView.addArrangedSubview(passwordDoubleCheckDeleteIcon)
        
        view.addSubview(HeaderView)
        HeaderView.addSubview(userNameTextFieldView)
        userNameTextFieldView.addSubview(nameFieldStackView)
        nameFieldStackView.addSubview(nameTextFieldStackView)
        nameTextFieldStackView.addArrangedSubview(nameFieldIcon)
        nameTextFieldStackView.addArrangedSubview(nameTextField)
        nameTextFieldStackView.addArrangedSubview(nameDeleteIcon)
        userNameTextFieldView.addSubview(nameDoubleCheckButton)
        
        HeaderView.addSubview(emailTextFieldView)
        emailTextFieldView.addSubview(emailFieldStackView)
        emailFieldStackView.addSubview(emailTextFieldStackView)
        emailTextFieldStackView.addArrangedSubview(emailFieldIcon)
        emailTextFieldStackView.addArrangedSubview(emailTextField)
        emailTextFieldStackView.addArrangedSubview(emailDeleteIcon)
        emailTextFieldView.addSubview(emailDoubleCheckButton)
        
        HeaderView.addSubview(passwordFieldStackView)
        passwordFieldStackView.addSubview(passwordTextFieldStackView)
        passwordTextFieldStackView.addArrangedSubview(passwordFieldIcon)
        passwordTextFieldStackView.addArrangedSubview(passwordTextField)
        passwordTextFieldStackView.addArrangedSubview(passwordIconsStackView)
        
        HeaderView.addSubview(passwordDoubleCheckFieldStackView)
        passwordDoubleCheckFieldStackView.addSubview(passwordDoubleCheckTextFieldStackView)
        passwordDoubleCheckTextFieldStackView.addArrangedSubview(passwordDoubleCheckFieldIcon)
        passwordDoubleCheckTextFieldStackView.addArrangedSubview(passwordDoubleCheckTextField)
        passwordDoubleCheckTextFieldStackView.addArrangedSubview(passwordDoubleCheckIconsStackView)
        
        HeaderView.addSubview(nameAlertTextLabel)
        HeaderView.addSubview(emailAlertTextLabel)
        HeaderView.addSubview(passwordAlertTextLabel)
        HeaderView.addSubview(passwordDoubleCheckAlertTextLabel)
        
        HeaderView.translatesAutoresizingMaskIntoConstraints = false
        userNameTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        emailTextFieldView.translatesAutoresizingMaskIntoConstraints = false

        nameFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        nameTextFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        nameFieldIcon.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameDeleteIcon.translatesAutoresizingMaskIntoConstraints = false
        nameDoubleCheckButton.translatesAutoresizingMaskIntoConstraints = false
        
        emailFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        emailTextFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        emailFieldIcon.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailDeleteIcon.translatesAutoresizingMaskIntoConstraints = false
        emailDoubleCheckButton.translatesAutoresizingMaskIntoConstraints = false
        
        passwordFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        passwordFieldIcon.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordDeleteIcon.translatesAutoresizingMaskIntoConstraints = false
        passwordHiddenIcon.translatesAutoresizingMaskIntoConstraints = false
        passwordIconsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        passwordDoubleCheckFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        passwordDoubleCheckTextFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        passwordDoubleCheckFieldIcon.translatesAutoresizingMaskIntoConstraints = false
        passwordDoubleCheckTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordDoubleCheckDeleteIcon.translatesAutoresizingMaskIntoConstraints = false
        passwordDoubleCheckHiddenIcon.translatesAutoresizingMaskIntoConstraints = false
        passwordDoubleCheckIconsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        nameAlertTextLabel.translatesAutoresizingMaskIntoConstraints = false
        emailAlertTextLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordAlertTextLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordDoubleCheckAlertTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // MARK: HeaderView
            HeaderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            HeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            HeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            HeaderView.heightAnchor.constraint(equalToConstant: 274),
            
            // MARK: userNameTextFieldView
            userNameTextFieldView.topAnchor.constraint(equalTo: HeaderView.topAnchor),
            userNameTextFieldView.leadingAnchor.constraint(equalTo: HeaderView.leadingAnchor),
            userNameTextFieldView.trailingAnchor.constraint(equalTo: HeaderView.trailingAnchor),
            userNameTextFieldView.heightAnchor.constraint(equalToConstant: 46),
            
            nameFieldStackView.centerYAnchor.constraint(equalTo: userNameTextFieldView.centerYAnchor),
            nameFieldStackView.leadingAnchor.constraint(equalTo: userNameTextFieldView.leadingAnchor),
            nameFieldStackView.heightAnchor.constraint(equalToConstant: 46),
            
            nameTextFieldStackView.leadingAnchor.constraint(equalTo: nameFieldStackView.leadingAnchor),
            nameTextFieldStackView.trailingAnchor.constraint(equalTo: nameFieldStackView.trailingAnchor),
            
            nameFieldIcon.widthAnchor.constraint(equalToConstant: 24),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 46),
            nameTextField.trailingAnchor.constraint(equalTo: nameDoubleCheckButton.leadingAnchor, constant: -44),

            nameDeleteIcon.widthAnchor.constraint(equalToConstant: 24),
            
            nameDoubleCheckButton.centerYAnchor.constraint(equalTo: userNameTextFieldView.centerYAnchor),
            nameDoubleCheckButton.trailingAnchor.constraint(equalTo: userNameTextFieldView.trailingAnchor),
            nameDoubleCheckButton.heightAnchor.constraint(equalToConstant: 46),
            nameDoubleCheckButton.widthAnchor.constraint(equalToConstant: 74),
            
            // MARK: emailTextFieldView
            emailTextFieldView.topAnchor.constraint(equalTo: userNameTextFieldView.bottomAnchor, constant: 30),
            emailTextFieldView.leadingAnchor.constraint(equalTo: HeaderView.leadingAnchor),
            emailTextFieldView.trailingAnchor.constraint(equalTo: HeaderView.trailingAnchor),
            emailTextFieldView.heightAnchor.constraint(equalToConstant: 46),
            
            emailFieldStackView.centerYAnchor.constraint(equalTo: emailTextFieldView.centerYAnchor),
            emailFieldStackView.leadingAnchor.constraint(equalTo: emailTextFieldView.leadingAnchor),
            emailFieldStackView.heightAnchor.constraint(equalToConstant: 46),
            
            emailTextFieldStackView.leadingAnchor.constraint(equalTo: emailFieldStackView.leadingAnchor),
            emailTextFieldStackView.trailingAnchor.constraint(equalTo: emailFieldStackView.trailingAnchor),
            
            emailFieldIcon.widthAnchor.constraint(equalToConstant: 24),
            
            emailTextField.heightAnchor.constraint(equalToConstant: 46),
            emailTextField.trailingAnchor.constraint(equalTo: emailDoubleCheckButton.leadingAnchor, constant: -44),
            
            emailDeleteIcon.widthAnchor.constraint(equalToConstant: 24),
            
            emailDoubleCheckButton.centerYAnchor.constraint(equalTo: emailTextFieldView.centerYAnchor),
            emailDoubleCheckButton.trailingAnchor.constraint(equalTo: emailTextFieldView.trailingAnchor),
            emailDoubleCheckButton.heightAnchor.constraint(equalToConstant: 46),
            emailDoubleCheckButton.widthAnchor.constraint(equalToConstant: 74),
            
            // MARK: passwordFieldStackView
            passwordFieldStackView.topAnchor.constraint(equalTo: emailTextFieldView.bottomAnchor, constant: 30),
            passwordFieldStackView.centerXAnchor.constraint(equalTo: HeaderView.centerXAnchor),
            passwordFieldStackView.leadingAnchor.constraint(equalTo: HeaderView.leadingAnchor),
            passwordFieldStackView.trailingAnchor.constraint(equalTo: HeaderView.trailingAnchor),
            passwordFieldStackView.heightAnchor.constraint(equalToConstant: 46),
            
            passwordTextFieldStackView.leadingAnchor.constraint(equalTo: passwordFieldStackView.leadingAnchor),
            passwordTextFieldStackView.trailingAnchor.constraint(equalTo: passwordFieldStackView.trailingAnchor),
            
            passwordFieldIcon.widthAnchor.constraint(equalToConstant: 24),
            
            passwordTextField.heightAnchor.constraint(equalToConstant: 46),
            passwordTextField.widthAnchor.constraint(equalToConstant: passwordTextFieldStackView.bounds.width - 48),
            
            passwordIconsStackView.widthAnchor.constraint(equalToConstant: 58),
            
            // MARK: passwordDoubleCheckFieldStackView
            passwordDoubleCheckFieldStackView.topAnchor.constraint(equalTo: passwordFieldStackView.bottomAnchor, constant: 30),
            passwordDoubleCheckFieldStackView.centerXAnchor.constraint(equalTo: HeaderView.centerXAnchor),
            passwordDoubleCheckFieldStackView.leadingAnchor.constraint(equalTo: HeaderView.leadingAnchor),
            passwordDoubleCheckFieldStackView.trailingAnchor.constraint(equalTo: HeaderView.trailingAnchor),
            passwordDoubleCheckFieldStackView.heightAnchor.constraint(equalToConstant: 46),
            
            passwordDoubleCheckTextFieldStackView.leadingAnchor.constraint(equalTo: passwordFieldStackView.leadingAnchor),
            passwordDoubleCheckTextFieldStackView.trailingAnchor.constraint(equalTo: passwordFieldStackView.trailingAnchor),
            
            passwordDoubleCheckFieldIcon.widthAnchor.constraint(equalToConstant: 24),
            
            passwordDoubleCheckTextField.heightAnchor.constraint(equalToConstant: 46),
            passwordDoubleCheckTextField.widthAnchor.constraint(equalToConstant: passwordTextFieldStackView.bounds.width - 48),
            
            passwordDoubleCheckIconsStackView.widthAnchor.constraint(equalToConstant: 58),
            
            // MARK: AlertTextLabel
            nameAlertTextLabel.topAnchor.constraint(equalTo: userNameTextFieldView.bottomAnchor, constant: 6),
            nameAlertTextLabel.leadingAnchor.constraint(equalTo: HeaderView.leadingAnchor),
            
            emailAlertTextLabel.topAnchor.constraint(equalTo: emailTextFieldView.bottomAnchor, constant: 6),
            emailAlertTextLabel.leadingAnchor.constraint(equalTo: HeaderView.leadingAnchor),
            
            passwordAlertTextLabel.topAnchor.constraint(equalTo: passwordFieldStackView.bottomAnchor, constant: 6),
            passwordAlertTextLabel.leadingAnchor.constraint(equalTo: HeaderView.leadingAnchor),
            
            passwordDoubleCheckAlertTextLabel.topAnchor.constraint(equalTo: passwordDoubleCheckFieldStackView.bottomAnchor, constant: 6),
            passwordDoubleCheckAlertTextLabel.leadingAnchor.constraint(equalTo: HeaderView.leadingAnchor),
        ])
    }
    
    
    //MARK: - setupBottomView
    private func setupBottomView() {
        view.addSubview(BottomView)
        BottomView.addSubview(SignUpButton)
        
        BottomView.translatesAutoresizingMaskIntoConstraints = false
        SignUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            BottomView.topAnchor.constraint(equalTo: HeaderView.bottomAnchor, constant: 104),
            BottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 38),
            BottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38),
            BottomView.heightAnchor.constraint(equalToConstant: 46),
            
            SignUpButton.topAnchor.constraint(equalTo: BottomView.topAnchor),
            SignUpButton.leadingAnchor.constraint(equalTo: BottomView.leadingAnchor),
            SignUpButton.trailingAnchor.constraint(equalTo: BottomView.trailingAnchor),
            SignUpButton.heightAnchor.constraint(equalToConstant: 46),
        ])
    }
    
    @objc private func setAlertView(title: String, subTitle: String) {
        let alertTitle = AlertUIFactory.alertTitle(titleText: title, textColor: MySpecialColors.Black, fontSize: 16)
        let alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: subTitle, textColor: MySpecialColors.Gray4, fontSize: 14)
        
        checkView.isUserInteractionEnabled = true
        
        view.addSubview(alertBack)
        alertBack.addSubview(alertView)
        alertView.addSubview(alertTitle)
        alertView.addSubview(alertSubTitle)
        alertView.addSubview(widthLine)
        alertView.addSubview(checkView)
        checkView.addSubview(checkLabel)
        
        alertBack.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false
        alertTitle.translatesAutoresizingMaskIntoConstraints = false
        alertSubTitle.translatesAutoresizingMaskIntoConstraints = false
        widthLine.translatesAutoresizingMaskIntoConstraints = false
        checkView.translatesAutoresizingMaskIntoConstraints = false
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            alertBack.topAnchor.constraint(equalTo: view.topAnchor),
            alertBack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alertBack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alertBack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 46),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -46),
            alertView.heightAnchor.constraint(equalToConstant: 140),
            
            alertTitle.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 24),
            alertTitle.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            
            alertSubTitle.topAnchor.constraint(equalTo: alertTitle.bottomAnchor, constant: 10),
            alertSubTitle.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            
            widthLine.topAnchor.constraint(equalTo: alertSubTitle.bottomAnchor, constant: 20),
            widthLine.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            widthLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 46),
            widthLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -46),
            widthLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            checkView.topAnchor.constraint(equalTo: widthLine.bottomAnchor),
            checkView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            checkView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            checkView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor),
            
            checkLabel.topAnchor.constraint(equalTo: checkView.topAnchor, constant: 14),
            checkLabel.centerXAnchor.constraint(equalTo: checkView.centerXAnchor),
        ])
                
        checkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkLabelTapped)))
    }
    
    private func setupButtons() {
        SignUpButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        nameDoubleCheckButton.addTarget(self, action: #selector(nicknameCheckButtonTapped), for: .touchUpInside)
        emailDoubleCheckButton.addTarget(self, action: #selector(checkEmailButtonTapped), for: .touchUpInside)
    }
    
    private func setupSignUpButton() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = passwordDoubleCheckTextField.text,
              let nickname = nameTextField.text,
              !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !nickname.isEmpty else {

            UIView.animate(withDuration: 0.3) {
                self.SignUpButton.isEnabled = false
                self.SignUpButton.backgroundColor = MySpecialColors.Gray3
            }
            return
        }
        
        UIView.transition(with: SignUpButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.SignUpButton.isEnabled = true
            self.SignUpButton.backgroundColor = MySpecialColors.MainColor
        }, completion: nil)
    }

    @objc private func checkLabelTapped() {
        print("완료")
        removeAlertView()
        let logVC = LoginViewController()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Actions
    @objc private func registerButtonTapped() {
        //이메일 , 페스워드 , 패스워드 확인 , 닉네임 공백 예외처리
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = passwordDoubleCheckTextField.text,
              let nickname = nameTextField.text,
              !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !nickname.isEmpty,
              passwordCheck else {
            return
        }
        
        // 패스워드 , 패스워드 확인 일치,불일치 예외처리
        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match")
            return
        }
        
        // 등록 처리
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
    
    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Nickname 유효성 검사
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
        nicknameCheck = false
        nameAlertTextLabel.isHidden = false
        nameAlertTextLabel.text = "중복확인을 진행해 주세요."
        nameAlertTextLabel.textColor = MySpecialColors.Red
        setupSignUpButton()
    }
    
    @objc private func nicknameCheckButtonTapped() {
        guard let nickname = nameTextField.text, !nickname.isEmpty else {
            nameAlertTextLabel.isHidden = false
            nameAlertTextLabel.text = "닉네임을 입력해주세요."
            nameAlertTextLabel.textColor = MySpecialColors.Red
            return
        }
        
        if !validateNickname(nickname) {
            nameAlertTextLabel.isHidden = false
            nameAlertTextLabel.text = "닉네임 형식이 올바르지 않습니다."
            nameAlertTextLabel.textColor = MySpecialColors.Red
            return
        }
        
        Firestore.firestore().collection("user-info").whereField("nickname", isEqualTo: nickname).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error checking nickname: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                self?.nameAlertTextLabel.isHidden = false
                self?.nameAlertTextLabel.text = "이미 사용중인 닉네임입니다."
                self?.nameAlertTextLabel.textColor = MySpecialColors.Red
                self?.nicknameCheck = false
            } else {
                self?.nameAlertTextLabel.isHidden = false
                self?.nameAlertTextLabel.text = "사용할 수 있는 닉네임입니다."
                self?.nameAlertTextLabel.textColor = MySpecialColors.MainColor
                self?.nicknameCheck = true
            }
            self?.setupSignUpButton()
        }
    }
    
    private func validateNickname(_ nickname: String) -> Bool {
        let nicknameRegex = "^[가-힣a-zA-Z0-9]{4,8}$"
        return NSPredicate(format: "SELF MATCHES %@", nicknameRegex).evaluate(with: nickname)
    }
    
    private func updateNicknameCheckStatus() {
        guard let nickname = nameTextField.text else {
            nicknameCheck = false
            return
        }
        
        nicknameCheck = validateNickname(nickname)
        
        if nicknameCheck {
            nameAlertTextLabel.isHidden = false
            nameAlertTextLabel.text = "사용할 수 있는 닉네임입니다."
            nameAlertTextLabel.textColor = MySpecialColors.MainColor
        } else {
            nameAlertTextLabel.isHidden = false
            nameAlertTextLabel.text = "닉네임 형식이 올바르지 않습니다."
            nameAlertTextLabel.textColor = MySpecialColors.Red
        }
        
        setupSignUpButton()
    }

    // MARK: - Name Delete Button
    private func setupNameDeleteIcon() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clearNameTextField))
        nameDeleteIcon.addGestureRecognizer(tapGestureRecognizer)
        nameDeleteIcon.isUserInteractionEnabled = true
    }

    @objc private func clearNameTextField() {
        nameTextField.text = ""
    }
    
    // MARK: - Email 유효성 검사
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        emailVerified = false
        guard let email = emailTextField.text else {
            emailCheck = false
            return
        }
        
        emailCheck = validateEmail(email)
        
        if emailCheck {
            emailAlertTextLabel.isHidden = false
            emailAlertTextLabel.text = "중복확인을 진행해 주세요."
            emailAlertTextLabel.textColor = MySpecialColors.Red
        } else {
            emailAlertTextLabel.isHidden = false
            emailAlertTextLabel.text = "이메일 형식이 올바르지 않습니다."
            emailAlertTextLabel.textColor = MySpecialColors.Red
        }
        
        setupSignUpButton()
    }
    
    @objc private func checkEmailButtonTapped() {
        // 이메일 공백 예외처리
        guard let email = emailTextField.text, !email.isEmpty else {
            emailAlertTextLabel.isHidden = false
            emailAlertTextLabel.text = "이메일을 입력해주세요."
            emailAlertTextLabel.textColor = MySpecialColors.Red
            return
        }
        
        Firestore.firestore().collection("user-info").whereField("email", isEqualTo: email).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error checking email: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                self?.emailAlertTextLabel.isHidden = false
                self?.emailAlertTextLabel.text = "이미 사용중인 이메일입니다."
                self?.emailAlertTextLabel.textColor = MySpecialColors.Red
                self?.emailVerified = false
            } else {
                self?.emailAlertTextLabel.isHidden = false
                self?.emailAlertTextLabel.text = "사용할 수 있는 이메일입니다."
                self?.emailAlertTextLabel.textColor = MySpecialColors.MainColor
                self?.emailVerified = true
            }
            self?.setupSignUpButton()
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
    
    // MARK: - Password 유효성 검사
    private func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,16}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }

    private func updatePasswordAlertLabel(_ isValid: Bool) {
        if isValid {
            passwordAlertTextLabel.isHidden = false
            passwordAlertTextLabel.text = "✓대문자/소문자  ✓숫자  ✓특수문자"
            passwordAlertTextLabel.textColor = MySpecialColors.MainColor
        } else {
            passwordAlertTextLabel.isHidden = false
            passwordAlertTextLabel.text = "대문자/소문자, 숫자, 특수문자를 포함해 주세요."
            passwordAlertTextLabel.textColor = MySpecialColors.Red
        }
    }

    @objc func passwordFieldDidChange(_ textField: UITextField) {
        if textField == passwordTextField {
            let isPasswordValid = isPasswordValid(textField.text ?? "")
            passwordCheck = isPasswordValid
            
            updatePasswordAlertLabel(isPasswordValid)
        }
        
        setupSignUpButton()
    }
    
    // MARK: - Password Hidden Button
    private func setupPasswordEyeToggle() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleEyeIcon))
        passwordHiddenIcon.addGestureRecognizer(tapGestureRecognizer)
        passwordHiddenIcon.isUserInteractionEnabled = true
    }

    @objc private func toggleEyeIcon() {
        passwordTextField.isSecureTextEntry.toggle()
        updatePasswordHiddenIconImage()
    }
    
    private func updatePasswordHiddenIconImage() {
        let imageName = passwordTextField.isSecureTextEntry ? "show-block" : "show"
        passwordHiddenIcon.image = UIImage(named: imageName)
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
    
    
    // MARK: - Password Double Check 유효성 검사
    @objc func checkPasswordMatch() {
        let password = passwordTextField.text ?? ""
        let passwordDoubleCheck = passwordDoubleCheckTextField.text ?? ""
        
        let passwordsMatch = password == passwordDoubleCheck && !password.isEmpty
                
        if passwordsMatch {
            // 정규식에 일치하는 경우
            passwordDoubleCheckAlertTextLabel.isHidden = false
            passwordDoubleCheckAlertTextLabel.text = "비밀번호가 일치합니다."
            passwordDoubleCheckAlertTextLabel.textColor = MySpecialColors.MainColor
        } else {
            // 정규식에 일치하지 않는 경우
            passwordDoubleCheckAlertTextLabel.isHidden = false
            passwordDoubleCheckAlertTextLabel.text = "비밀번호가 일치하지 않습니다."
            passwordDoubleCheckAlertTextLabel.textColor = MySpecialColors.Red
        }
        
        setupSignUpButton()
    }
    
    // MARK: - Password Double Check Hidden Button
    private func setupPasswordCheckEyeToggle() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(togglePasswordCheckEye))
        passwordDoubleCheckHiddenIcon.addGestureRecognizer(tapGestureRecognizer)
        passwordDoubleCheckHiddenIcon.isUserInteractionEnabled = true
    }

    @objc private func togglePasswordCheckEye() {
        passwordDoubleCheckTextField.isSecureTextEntry.toggle()
        updatePasswordDoubleCheckHiddenIconImage()
    }
    
    private func updatePasswordDoubleCheckHiddenIconImage() {
        let imageName = passwordDoubleCheckTextField.isSecureTextEntry ? "show-block" : "show"
        passwordDoubleCheckHiddenIcon.image = UIImage(named: imageName)
    }
    
    // MARK: - Password Delete Button
    private func setupPasswordDoubleCheckDeleteIcon() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clearPasswordDoubleCheckTextField))
        passwordDoubleCheckDeleteIcon.addGestureRecognizer(tapGestureRecognizer)
        passwordDoubleCheckDeleteIcon.isUserInteractionEnabled = true
    }

    @objc private func clearPasswordDoubleCheckTextField() {
        passwordDoubleCheckTextField.text = ""
    }
    
    // MARK: - Keyboard Dimiss
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Alert 삭제
    private func removeAlertView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alertBack.alpha = 0
        }) { _ in
            self.alertBack.removeFromSuperview()
        }
    }
}

