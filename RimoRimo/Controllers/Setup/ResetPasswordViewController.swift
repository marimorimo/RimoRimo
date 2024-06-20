//
//  ResetPasswordViewController.swift
//  RimoRimo
//
//  Created by 이유진 on 6/19/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    var emailCheck: Bool = false
    
    private var activityIndicator: UIActivityIndicatorView!

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
    
    let alertBack = AlertUIFactory.alertBackView()
    let alertView = AlertUIFactory.alertView()
    
    let alertTitle = AlertUIFactory.alertTitle(titleText: "차단 해제", textColor: MySpecialColors.Black, fontSize: 16)
    let alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: "차단을 해제하시겠습니까?", textColor: MySpecialColors.Gray4, fontSize: 14)
    
    let widthLine = AlertUIFactory.widthLine()

    let checkView = AlertUIFactory.checkView()
    let checkLabel = AlertUIFactory.checkLabel(cancleText: "확인", textColor: MySpecialColors.MainColor, fontSize: 14)
    
    // MARK: - Setup Views
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "비밀번호 변경"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
       
        setupUI()
        
        emailAlertTextLabel.isHidden = true
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        emailTextField.delegate = self
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.returnKeyType = .done
        
        setupActivityIndicator()
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
    
    //MARK: - setupNavigationBar
    private func setupNavigationBar() {
        title = "비밀번호 변경"
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
        
        alertBack.alpha = 0
        alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.3) {
            self.alertBack.alpha = 1
            self.alertView.transform = CGAffineTransform.identity
        }
                
        checkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkLabelTapped)))
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
        activityIndicator.startAnimating()
        
        // 이메일 공백 예외 처리
        guard let email = emailTextField.text, !email.isEmpty else {
            self.emailAlertTextLabel.isHidden = false
            self.emailAlertTextLabel.text = "이메일을 입력해 주세요."
            activityIndicator.stopAnimating() // 실패 시 로딩 인디케이터를 멈춤
            return
        }
        
        checkIfEmailExists(email: email) { [weak self] exists in
            guard let self = self else { return }
            
            if exists {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    self.activityIndicator.stopAnimating()
                    
                    if let error = error {
                        print("이메일 전송 실패: \(error.localizedDescription)")
                        self.emailAlertTextLabel.isHidden = false
                        self.emailAlertTextLabel.text = "등록되지 않은 이메일입니다. 다시 확인해 주세요."
                        return
                    }
                    
                    print("비밀번호 재설정 이메일을 보냈습니다.")
                    self.emailAlertTextLabel.isHidden = false
                    self.emailAlertTextLabel.text = "비밀번호 재설정 이메일이 \(email)로 전송되었습니다."
                    self.emailAlertTextLabel.textColor = MySpecialColors.MainColor
                    
                    self.setAlertView(title: "비밀번호 찾기", subTitle: "재설정 이메일이 전송되었습니다.")
                }
            } else {
                self.emailAlertTextLabel.isHidden = false
                self.emailAlertTextLabel.text = "등록되지 않은 이메일입니다. 다시 확인해 주세요."
                self.activityIndicator.stopAnimating()
            }
        }
    }

    private func checkIfEmailExists(email: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("user-info").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking email existence: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                completion(true) // Email 있음
            } else {
                completion(false) // Email 없음
            }
        }
    }
    
    func saveUserEmailToFirestore(uid: String, email: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData(["email": email]) { error in
            if let error = error {
                print("Error saving user email: \(error.localizedDescription)")
            } else {
                print("User email saved successfully")
            }
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
    
    // MARK: - Keyboard Dimiss
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helper Methods
    @objc private func checkLabelTapped() {
        print("완료")
        removeAlertView()
        let logVC = LoginViewController()
        navigationController?.popViewController(animated: true)
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
