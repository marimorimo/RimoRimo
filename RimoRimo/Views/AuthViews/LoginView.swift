//
//  LoginView.swift
//  RimoRimo-Refactoring
//
//  Created by wxxd-fxrest on 6/24/24.
//

import UIKit
import SnapKit
import Then

protocol LoginViewDelegate: AnyObject {
    func loginViewDidChangeTextFields()
}

class LoginView: UIView {
    
    weak var delegate: LoginViewDelegate?
    var activityIndicator = UIActivityIndicatorView(style: .medium)

    private lazy var logoView = UIFactory_.makeView(backgroundColor: .clear)
    private lazy var imageView = UIFactory_.makeImageView(image: UIImage(named: "logo-image"))
    private lazy var textFieldView = UIFactory_.makeView(backgroundColor: .clear)
    private lazy var bottomView = UIFactory_.makeView(backgroundColor: .clear)
    
    lazy var emailFieldSetup = FieldSetup()
    lazy var passwordFieldSetup = SecureFieldSetup()
    
    lazy var alertTextLabel = UIFactory_.makeLabel(
        text: "이메일 또는 비밀번호가 일치하지 않습니다.", 
        textColor: .clear,
        font: UIFont.pretendard(style: .regular, size: 10, isScaled: true), 
        textAlignment: .left
    )
    
    private lazy var findPasswordButton = UIFactory_.makeButton(
        title: "비밀번호 찾기", 
        titleColor: MySpecialColors.Gray3,
        font: UIFont.pretendard(style: .regular, size: 12, isScaled: true), 
        backgroundColor: .clear
    )
    
    private lazy var passwordBottomStack: UIStackView = UIFactory_.makeStackView(
        arrangedSubviews: [alertTextLabel, findPasswordButton],
        axis: .horizontal, 
        spacing: 10
    )
    
    lazy var loginButton = TabButtonUIFactory.tapButton(
        buttonTitle: "로그인",
        textColor: MySpecialColors.Gray1,
        cornerRadius: 24,
        backgroundColor: MySpecialColors.Gray3
    )
    
    private lazy var signupLabel = UIFactory_.makeLabel(
        text: "리모리모가 처음이신가요?",
        textColor: MySpecialColors.Gray3,
        font: UIFont.pretendard(style: .regular, size: 12, isScaled: true), 
        textAlignment: .left
    )
    
    private lazy var signupButton = UIFactory_.makeButton(
        title: "회원가입",
        titleColor: MySpecialColors.MainColor,
        font: UIFont.pretendard(style: .medium, size: 12, isScaled: true), 
        backgroundColor: .clear
    )
    
    private lazy var signupStack: UIStackView = UIFactory_.makeStackView(
        arrangedSubviews: [signupLabel, signupButton],
        axis: .horizontal,
        spacing: 10
    )

    var onEmailDeleteIconTapped: (() -> Void)? {
        get { emailFieldSetup.onDeleteIconTapped }
        set { emailFieldSetup.onDeleteIconTapped = newValue }
    }
    
    var onHiddenIconTapped: (() -> Void)? {
        get { passwordFieldSetup.onHiddenIconTapped }
        set { passwordFieldSetup.onHiddenIconTapped = newValue }
    }
    
    var onDeleteIconTapped: (() -> Void)? {
        get { passwordFieldSetup.onDeleteIconTapped }
        set { passwordFieldSetup.onDeleteIconTapped = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = MySpecialColors.Gray1

        addSubviews(activityIndicator, logoView, textFieldView, bottomView)
        logoView.addSubviews(imageView)
        textFieldView.addSubviews(emailFieldSetup, passwordFieldSetup, passwordBottomStack)
        bottomView.addSubviews(loginButton, signupStack)
        
        setupConstraints()
        setupTextFieldUI()
        setupBottomViewUI()
        setupActivityIndicator()
    }
    
    private func setupConstraints() {
        logoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        imageView.snp.makeConstraints {
            $0.bottom.equalTo(logoView.snp.bottom)
            $0.leading.equalTo(logoView.snp.leading)
            $0.trailing.equalTo(logoView.snp.trailing)
            $0.height.equalTo(34)
        }
    }
    
    private func setupTextFieldUI() {
        emailFieldSetup.configureField(placeholder: "이메일을 입력해 주세요.", iconName: "mail", keyboardType: .emailAddress)
        passwordFieldSetup.configureField(placeholder: "비밀번호를 입력해 주세요.", iconName: "lock")

        textFieldView.snp.makeConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(60)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(150)
        }
        
        emailFieldSetup.snp.makeConstraints {
            $0.top.equalTo(textFieldView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        passwordFieldSetup.snp.makeConstraints {
            $0.top.equalTo(emailFieldSetup.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        passwordBottomStack.snp.makeConstraints {
            $0.top.equalTo(passwordFieldSetup.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
        }
        
        emailFieldSetup.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordFieldSetup.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupBottomViewUI() {
        bottomView.snp.makeConstraints {
            $0.top.equalTo(passwordBottomStack.snp.bottom).offset(86)
            $0.leading.trailing.equalToSuperview().inset(38)
            $0.height.equalTo(80)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(bottomView.snp.top)
            $0.leading.equalTo(bottomView.snp.leading)
            $0.trailing.equalTo(bottomView.snp.trailing)
            $0.height.equalTo(46)
        }
        
        signupStack.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(4)
            $0.centerX.equalTo(loginButton.snp.centerX)
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.color = MySpecialColors.MainColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    func setFindPasswordButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        findPasswordButton.addTarget(target, action: action, for: event)
    }
    
    func setLgoinButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        loginButton.addTarget(target, action: action, for: event)
    }
    
    func setSignupButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        signupButton.addTarget(target, action: action, for: event)
    }
    
    @objc private func textFieldDidChange() {
        delegate?.loginViewDidChangeTextFields()
    }
}
