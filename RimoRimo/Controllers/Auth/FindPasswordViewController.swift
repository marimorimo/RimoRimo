//
//  FindPasswordViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseAuth

class FindPasswordViewController: UIViewController, UITextFieldDelegate {
    
    var emailCheck: Bool = false

    // MARK: - Email View
    private let EmailView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let emailLabel: UILabel = {
        let text = UILabel()
        text.text = "회원 정보에 등록된 이메일을 입력해 주세요."
        text.textColor = MySpecialColors.Black
        text.textAlignment = .left
        text.font = UIFont.pretendard(style: .regular, size: 14, isScaled: true)
        return text
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
    
    let emailFieldStackView = TextFieldUIFactory.stackBox()
    let emailTextFieldStackView = TextFieldUIFactory.textFieldStackView(spacing: 10)

    let emailTextField = TextFieldUIFactory.textField(placeholder: "이메일을 입력해 주세요.")

    let emailFieldIcon = TextFieldUIFactory.fieldIcon(name: "mail")
    
    let emailDeleteIcon = TextFieldUIFactory.deleteIcon(name: "close-circle")
    
    lazy var emailAlertTextLabel: UILabel = alertTextLabel(alertText: emailCheck ? "사용할 수 있는 이메일입니다." : "이미 사용 중인 이메일입니다.", textColor: emailCheck ? MySpecialColors.MainColor : MySpecialColors.Red)

    let CheckButton = TabButtonUIFactory.tapButton(
        buttonTitle: "확인",
        textColor: MySpecialColors.Gray1,
        cornerRadius: 24,
        backgroundColor: MySpecialColors.Gray2)
    
    // MARK: - Setup Views
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        emailAlertTextLabel.isHidden = true
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        emailTextField.delegate = self
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.returnKeyType = .done
        
        setupNavigationBar()
        setupButtons()
        setupEmailDeleteIcon()
        
        setupCheckButton()
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            textField.resignFirstResponder()
            sendPasswordResetEmail()
        default:
            break
        }
        return true
    }

    
    //MARK: - setupNavigationBar
    private func setupNavigationBar() {
        title = "비밀번호 찾기"
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = MySpecialColors.MainColor
    }
    
    private func setupUI() {
        view.backgroundColor = MySpecialColors.Gray1
    
        view.addSubview(EmailView)
        view.addSubview(CheckButton)
        EmailView.addSubview(emailFieldStackView)
        EmailView.addSubview(emailAlertTextLabel)
        EmailView.addSubview(emailLabel)

        emailFieldStackView.addSubview(emailTextFieldStackView)
        emailTextFieldStackView.addArrangedSubview(emailFieldIcon)
        emailTextFieldStackView.addArrangedSubview(emailTextField)
        emailTextFieldStackView.addArrangedSubview(emailDeleteIcon)
        
        EmailView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailAlertTextLabel.translatesAutoresizingMaskIntoConstraints = false
        emailFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        emailTextFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        emailFieldIcon.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailDeleteIcon.translatesAutoresizingMaskIntoConstraints = false
        CheckButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //MARK: - MiddleView
            EmailView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            EmailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            EmailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            EmailView.heightAnchor.constraint(equalToConstant: 88),
            
            emailLabel.topAnchor.constraint(equalTo: EmailView.topAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            //MARK: - EmailTextFieldView
            emailFieldStackView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            emailFieldStackView.leadingAnchor.constraint(equalTo: EmailView.leadingAnchor),
            emailFieldStackView.trailingAnchor.constraint(equalTo: EmailView.trailingAnchor),
            emailFieldStackView.heightAnchor.constraint(equalToConstant: 46),
            
            emailTextFieldStackView.leadingAnchor.constraint(equalTo: emailFieldStackView.leadingAnchor),
            emailTextFieldStackView.trailingAnchor.constraint(equalTo: emailFieldStackView.trailingAnchor),
            
            emailAlertTextLabel.topAnchor.constraint(equalTo: emailTextFieldStackView.bottomAnchor, constant: 6),
            emailAlertTextLabel.leadingAnchor.constraint(equalTo: emailTextFieldStackView.leadingAnchor),
            
            emailFieldIcon.widthAnchor.constraint(equalToConstant: 24),
            
            emailTextField.heightAnchor.constraint(equalToConstant: 46),
            emailTextField.widthAnchor.constraint(equalToConstant: emailTextFieldStackView.bounds.width - 48),
            
            emailDeleteIcon.widthAnchor.constraint(equalToConstant: 24),
            
            CheckButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -320),
            CheckButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 38),
            CheckButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38),
            CheckButton.heightAnchor.constraint(equalToConstant: 46)
        ])

    }
    
    private func setupButtons() {
        CheckButton.addTarget(self, action: #selector(sendPasswordResetEmail), for: .touchUpInside)
    }
    
    private func setupCheckButton() {
        guard let email = emailTextField.text,
              !email.isEmpty else {

            UIView.animate(withDuration: 0.3) {
                self.CheckButton.isEnabled = false
                self.CheckButton.backgroundColor = MySpecialColors.Gray3
            }
            return
        }
        
        UIView.transition(with: CheckButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.CheckButton.isEnabled = true
            self.CheckButton.backgroundColor = MySpecialColors.MainColor
        }, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        setupCheckButton()
    }

    // MARK: - Actions
    @objc private func sendPasswordResetEmail() {
        // 이메일 공백 예외 처리
        guard let email = emailTextField.text, !email.isEmpty else {
            self.emailAlertTextLabel.isHidden = false
            self.emailAlertTextLabel.text = "이메일을 입력해 주세요."
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("이메일 전송 실패: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                self.emailAlertTextLabel.isHidden = false
                self.emailAlertTextLabel.text = "등록되지 않은 이메일입니다. 다시 확인해 주세요."
                return
            }
            
            let alert = UIAlertController(title: "Password Reset", message: "비밀번호 재설정 이메일이 \(email)로 전송되었습니다. 받은편지함을 확인하세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            print("비밀번호 재설정 이메일을 보냈습니다.")
            self.emailAlertTextLabel.isHidden = false
            self.emailAlertTextLabel.text = "비밀번호 재설정 이메일을 보냈습니다."
            self.emailAlertTextLabel.textColor = MySpecialColors.MainColor
        }
 
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

    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
