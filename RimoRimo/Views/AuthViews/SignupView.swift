//
//  SignupView.swift
//  RimoRimo-Refactoring
//
//  Created by wxxd-fxrest on 6/24/24.
//

import UIKit
import SnapKit
import Then

protocol SignupViewDelegate: AnyObject {
    func privacyPolicyStackViewDidTap()
    func signupViewDidChangeNicknameField()
    func signupViewDidChangeEmailField()
    func signupViewDidChangePasswordField()
    func signupViewDidChangeCheckPasswordField()
}

class SignupView: UIView {
    
    weak var delegate: SignupViewDelegate?
    var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private var textFieldView = UIFactory_.makeView(backgroundColor: .clear)
    private lazy var bottomView = UIFactory_.makeView(backgroundColor: .clear)
    
    lazy var nicknameFieldSetup = FieldSetup()
    lazy var emailFieldSetup = FieldSetup()
    lazy var passwordFieldSetup = SecureFieldSetup()
    lazy var checkPasswordFieldSetup = SecureFieldSetup()
    
    lazy var nameDoubleCheckButton: UIButton = createDoubleCheckButton(title: "중복 확인")

    lazy var emailDoubleCheckButton: UIButton = createDoubleCheckButton(title: "중복 확인")
    
    private func createDoubleCheckButton(title: String) -> UIButton {
        let button = TabButtonUIFactory.doubleCheckButton(
            buttonTitle: title,
            textColor: MySpecialColors.MainColor,
            cornerRadius: 12,
            backgroundColor: MySpecialColors.Gray1
        )
        return button
    }
    
    private lazy var nicknameFieldStack: UIStackView = UIFactory_.makeStackView(
        arrangedSubviews: [nicknameFieldSetup, nameDoubleCheckButton],
        axis: .horizontal,
        spacing: 12
    )
    
    private lazy var emailFieldStack: UIStackView = UIFactory_.makeStackView(
        arrangedSubviews: [emailFieldSetup, emailDoubleCheckButton],
        axis: .horizontal,
        spacing: 12
    )
    
    private func makeAlertLabel(text: String, textColor: UIColor) -> UILabel {
        return UIFactory_.makeLabel(
            text: text,
            textColor: textColor,
            font: UIFont.pretendard(style: .regular, size: 10, isScaled: true),
            textAlignment: .left
        )
    }

    lazy var alertNicknameTextLabel: UILabel = makeAlertLabel(text: "닉네임은 한글/숫자 2~8자 또는 영어/숫자 4~16자로 입력해주세요.", textColor: MySpecialColors.Gray3)
    lazy var alertEmailTextLabel: UILabel = makeAlertLabel(text: "예시) email@gmail.com", textColor: MySpecialColors.Gray3)
    lazy var alertPasswordTextLabel: UILabel = makeAlertLabel(text: "비밀번호는 최소 하나의 대문자, 소문자, 숫자를 포함해야 하며 8~16자여야 합니다.", textColor: MySpecialColors.Gray3)
    lazy var alertCheckPasswordTextLabel: UILabel = makeAlertLabel(text: "비밀번호를 다시 한번 확인해 주세요.", textColor: MySpecialColors.Gray3)
    
    lazy var checkIconButton = UIFactory_.makeImageButton(image: "circle", tintColor: MySpecialColors.Gray3)
    private lazy var privacyPolicyLabel = UIFactory_.makeLabel(text: "[필수] 개인정보 처리 방침 확인하기", textColor: MySpecialColors.Black, font: UIFont.pretendard(style: .regular, size: 14, isScaled: true), textAlignment: .center)
    private lazy var arrowIcon = UIFactory_.makeImageButton(image: "chevron.right", tintColor: MySpecialColors.MainColor)
    
    private lazy var privacyPolicyStack: UIStackView = UIFactory_.makeStackView(
        arrangedSubviews: [checkIconButton, privacyPolicyLabel, arrowIcon],
        axis: .horizontal,
        spacing: 12
    )
    
    lazy var signupButton = TabButtonUIFactory.tapButton(
        buttonTitle: "회원가입",
        textColor: MySpecialColors.Gray1,
        cornerRadius: 24,
        backgroundColor: MySpecialColors.Gray3
    )
    
    var onNicknameDeleteIconTapped: (() -> Void)?
    var onEmailDeleteIconTapped: (() -> Void)?
    
    var onPasswordDeleteIconTapped: (() -> Void)?
    var onPasswordHiddenIconTapped: (() -> Void)? {
        get { passwordFieldSetup.onHiddenIconTapped }
        set { passwordFieldSetup.onHiddenIconTapped = newValue }
    }
    
    var onCheckPasswordDeleteIconTapped: (() -> Void)?
    var onCheckPasswordHiddenIconTapped: (() -> Void)? {
        get { checkPasswordFieldSetup.onHiddenIconTapped }
        set { checkPasswordFieldSetup.onHiddenIconTapped = newValue }
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
        
        addSubviews(activityIndicator, textFieldView, privacyPolicyStack, bottomView)
        textFieldView.addSubviews(
            nicknameFieldStack, emailFieldStack, passwordFieldSetup, checkPasswordFieldSetup,
            alertNicknameTextLabel, alertEmailTextLabel,
            alertPasswordTextLabel, alertCheckPasswordTextLabel
        )
        bottomView.addSubviews(signupButton)
        
        setupTextFieldUI()
        setupPrivacyPolicyViewUI()
        setupBottomViewUI()
        setupActivityIndicator()
    }
    
    private func setupTextFieldUI() {
        nicknameFieldSetup.configureField(placeholder: "닉네임을 입력해 주세요.", iconName: "user-02", keyboardType: .default)
        emailFieldSetup.configureField(placeholder: "이메일을 입력해 주세요.", iconName: "mail", keyboardType: .emailAddress)
        passwordFieldSetup.configureField(placeholder: "비밀번호를 입력해 주세요.", iconName: "lock")
        checkPasswordFieldSetup.configureField(placeholder: "비밀번호를 다시 확인해 주세요.", iconName: "lock")
        
        textFieldView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(50)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(300)
        }
        
        nicknameFieldStack.snp.makeConstraints {
            $0.top.equalTo(textFieldView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        nameDoubleCheckButton.snp.makeConstraints {
            $0.width.equalTo(74)
            $0.height.equalTo(44)
        }
        
        setAlertLabelConstraints(label: alertNicknameTextLabel, topView: nicknameFieldStack, topOffset: 6)

        emailFieldStack.snp.makeConstraints {
            $0.top.equalTo(nicknameFieldSetup.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        emailDoubleCheckButton.snp.makeConstraints {
            $0.width.equalTo(74)
            $0.height.equalTo(44)
        }
        
        setAlertLabelConstraints(label: alertEmailTextLabel, topView: emailFieldStack, topOffset: 6)
        
        passwordFieldSetup.snp.makeConstraints {
            $0.top.equalTo(emailFieldSetup.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        setAlertLabelConstraints(label: alertPasswordTextLabel, topView: passwordFieldSetup, topOffset: 6)
        
        checkPasswordFieldSetup.snp.makeConstraints {
            $0.top.equalTo(passwordFieldSetup.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        setAlertLabelConstraints(label: alertCheckPasswordTextLabel, topView: checkPasswordFieldSetup, topOffset: 6)
        
        nicknameFieldSetup.textField.addTarget(self, action: #selector(nicknameFieldDidChange), for: .editingChanged)
        emailFieldSetup.textField.addTarget(self, action: #selector(emailFieldDidChange), for: .editingChanged)
        passwordFieldSetup.textField.addTarget(self, action: #selector(passwordFieldDidChange), for: .editingChanged)
        checkPasswordFieldSetup.textField.addTarget(self, action: #selector(checkPasswordFieldDidChange), for: .editingChanged)
    }
    
    private func setupPrivacyPolicyViewUI() {
        privacyPolicyStack.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(38)
            $0.height.equalTo(30)
        }
        
        checkIconButton.snp.makeConstraints {
            $0.width.equalTo(28)
        }
        
        arrowIcon.snp.makeConstraints {
            $0.width.equalTo(24)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePrivacyPolicyStackTapped))
        privacyPolicyStack.addGestureRecognizer(tapGesture)
        privacyPolicyStack.isUserInteractionEnabled = true
    }
    
    private func setupBottomViewUI() {
        bottomView.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.leading.trailing.equalToSuperview().inset(38)
            $0.height.equalTo(80)
        }
        
        signupButton.snp.makeConstraints {
            $0.top.equalTo(bottomView.snp.top)
            $0.leading.equalTo(bottomView.snp.leading)
            $0.trailing.equalTo(bottomView.snp.trailing)
            $0.height.equalTo(46)
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.color = MySpecialColors.MainColor
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setAlertLabelConstraints(label: UILabel, topView: UIView, topOffset: CGFloat) {
        label.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(topOffset)
            $0.leading.equalTo(topView.snp.leading)
        }
    }
    
    func configureAlert(for label: UILabel, text: String, textColor: UIColor) {
        label.text = text
        label.textColor = textColor
    }
    
    func setSignupButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        signupButton.addTarget(target, action: action, for: event)
    }
    
    func nameDoubleCheckButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        nameDoubleCheckButton.addTarget(target, action: action, for: event)
    }
    
    func emailDoubleCheckButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        emailDoubleCheckButton.addTarget(target, action: action, for: event)
    }
    
    func privacyPolicyButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        checkIconButton.addTarget(target, action: action, for: event)
    }

    @objc private func nicknameFieldDidChange() {
        delegate?.signupViewDidChangeNicknameField()
    }

    @objc private func emailFieldDidChange() {
        delegate?.signupViewDidChangeEmailField()
    }

    @objc private func passwordFieldDidChange() {
        delegate?.signupViewDidChangePasswordField()
    }

    @objc private func checkPasswordFieldDidChange() {
        delegate?.signupViewDidChangeCheckPasswordField()
    }
    
    @objc private func handlePrivacyPolicyStackTapped() {
        delegate?.privacyPolicyStackViewDidTap()
    }
}
