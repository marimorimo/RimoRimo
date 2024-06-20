//
//  AccountInfoViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AccountInfoViewController: UIViewController {
    
    let titleLables = ["계정 정보", "비밀번호 변경"]
    let descriptionLabels = ["가입한 이메일 정보입니다.", "비밀번호를 변경합니다."]
    
    private lazy var accountTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.register(MyAccountTableViewCell.self, forCellReuseIdentifier: MyAccountTableViewCell.cellId)
        tableView.separatorStyle = .none
        tableView.rowHeight = 58
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var withdrawButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("회원 탈퇴", for: .normal)
        button.titleLabel?.font = .pretendard(style: .regular, size: 12)
        button.addTarget(self, action: #selector(withdrawButtonTapped), for: .touchUpInside)
        button.setTitleColor(MySpecialColors.Gray3, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViews()
        setupLayout()
        fetchUserEmail()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        self.title = "계정 관리"
    }
    
    private func setupViews() {
        view.addSubview(accountTableView)
        view.addSubview(withdrawButton)
    }
    
    private func setupLayout() {
        accountTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.edges.equalToSuperview()
        }
        
        withdrawButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
            make.width.equalTo(56)
        }
    }
    
    // MARK: - 비밀번호 재설정
    
    var userEmail: String?
    private func fetchUserEmail() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("user-info").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userEmail = data?["email"] as? String
                self.accountTableView.reloadData()
            } else {
                print("Document does not exist: \(error?.localizedDescription ?? "No error")")
            }
        }
    }
    

    // Reset Password Alert
    let alertBack = AlertUIFactory.alertBackView()
       let alertView = AlertUIFactory.alertView()
       
       let alertTitle = AlertUIFactory.alertTitle(titleText: "비밀번호 변경", textColor: MySpecialColors.Black, fontSize: 16)
       let alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: "비밀번호를 변경하시겠습니까?", textColor: MySpecialColors.Gray4, fontSize: 14)
       
       let widthLine = AlertUIFactory.widthLine()
       let heightLine = AlertUIFactory.heightLine()
       
       let cancelView = AlertUIFactory.cancleView()
       let cancelLabel = AlertUIFactory.checkLabel(cancleText: "취소", textColor: MySpecialColors.Red, fontSize: 14)

       let checkView = AlertUIFactory.checkView()
       let checkLabel = AlertUIFactory.checkLabel(cancleText: "확인", textColor: MySpecialColors.MainColor, fontSize: 14)
                         
    private func showResetPasswordAlert(title: String, subTitle: String) {
        let alertTitle = AlertUIFactory.alertTitle(titleText: title, textColor: MySpecialColors.Black, fontSize: 16)
        let alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: subTitle, textColor: MySpecialColors.Gray4, fontSize: 14)
        
        checkView.isUserInteractionEnabled = true

        view.addSubview(alertBack)
        alertBack.addSubview(alertView)
        [alertTitle, alertSubTitle, widthLine, heightLine, cancelView, checkView].forEach {
            alertView.addSubview($0)
        }
        cancelView.addSubview(cancelLabel)
        checkView.addSubview(checkLabel)
        
        alertBack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(46)
            make.trailing.equalToSuperview().inset(46)
            make.height.equalTo(140)
        }
        
        alertTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        alertSubTitle.snp.makeConstraints { make in
            make.top.equalTo(alertTitle.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        widthLine.snp.makeConstraints { make in
            make.top.equalTo(alertSubTitle.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        heightLine.snp.makeConstraints { make in
            make.top.equalTo(widthLine.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(80)
        }
        
        cancelView.snp.makeConstraints { make in
            make.top.equalTo(widthLine.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalTo(heightLine.snp.leading).offset(-4)
            make.bottom.equalToSuperview()
        }
        
        cancelLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }
        
        checkView.snp.makeConstraints { make in
            make.top.equalTo(widthLine.snp.bottom)
            make.leading.equalTo(heightLine.snp.trailing).offset(4)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        checkLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }
        
        alertBack.alpha = 0
        alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.3) {
            self.alertBack.alpha = 1
            self.alertView.transform = CGAffineTransform.identity
        }
        
        checkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToResetPasswordVC)))
        cancelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeAlertView)))
    }
    
    @objc private func removeAlertView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alertBack.alpha = 0
            self.alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            self.alertBack.removeFromSuperview()
            self.alertView.removeFromSuperview()
        }
    }
    
    @objc private func moveToResetPasswordVC() {
        let nextVC = ResetPasswordViewController()
        self.navigationController?.pushViewController(nextVC, animated: false)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alertBack.alpha = 0
            self.alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            self.alertBack.removeFromSuperview()
            self.alertView.removeFromSuperview()
        }
    }

    
    // MARK: - 회원 탈퇴
    @objc private func withdrawButtonTapped() {
        let alert = UIAlertController(title: "회원 탈퇴", message: "정말로 회원 탈퇴하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func reauthenticateUserAndDeleteAccount(withPassword password: String) {
        guard let user = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        
        guard let email = user.email else {
            print("User email is nil")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                print("Error reauthenticating user: \(error.localizedDescription)")
                // 재인증 실패 처리
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "인증 실패", message: "비밀번호가 올바르지 않습니다. 다시 시도하세요.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                return
            }
            
            // 재인증 성공 시 사용자 계정 삭제
            self.deleteUserFromFirebase()
            self.deleteUserDocumentFromFirestore()
        }
    }
    private func deleteUserFromFirebase() {
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                // 계정 삭제 오류 처리
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "계정 삭제 오류", message: "계정을 삭제하는 중 오류가 발생했습니다.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            } else {
                print("User deleted successfully from Firebase Authentication")
            }
        }
    }
    
    private func deleteUserDocumentFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        let userRef = Firestore.firestore().collection("user-info").document(uid)
        
        userRef.delete { error in
            if let error = error {
                print("Error removing document from Firestore: \(error.localizedDescription)")
                // Firestore 문서 삭제 오류 처리
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "문서 삭제 오류", message: "사용자 정보를 삭제하는 중 오류가 발생했습니다.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            } else {
                print("Document successfully removed from Firestore")
                self.navigateToLoginScreen()
            }
        }
    }
    
    private func navigateToLoginScreen() {
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
}

    // MARK: - Extension

extension AccountInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyAccountTableViewCell.cellId, for: indexPath) as! MyAccountTableViewCell
        cell.titleLabel.text = titleLables[indexPath.row]
        cell.descriptionLabel.text = descriptionLabels[indexPath.row]
        cell.emailLabel.text = userEmail ?? "정보 없음"
        
        if indexPath.row == 1 {
            cell.emailLabel.isHidden = true
            cell.enterImageView.isHidden = false
        } else {
            cell.enterImageView.isHidden = true
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            print("taptap")
            showResetPasswordAlert(title: "비밀번호 변경", subTitle: "비밀번호를 변경하시겠습니까?")
        }
    }
}
    
    
//    private let accountInfoTitle: UILabel = {
//        let text = UILabel()
//        text.text = "accountInfo"
//        return text
//    }()
//    
//    private let emailTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Enter your email"
//        textField.borderStyle = .roundedRect
//        return textField
//    }()
//    
//    private let resetPasswordButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Reset Password", for: .normal)
//        button.addTarget(self, action: #selector(resetPasswordButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        view.addSubview(accountInfoTitle)
//        view.addSubview(emailTextField)
//        view.addSubview(resetPasswordButton)
//        
//        accountInfoTitle.translatesAutoresizingMaskIntoConstraints = false
//        emailTextField.translatesAutoresizingMaskIntoConstraints = false
//        resetPasswordButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            accountInfoTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            accountInfoTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            
//            emailTextField.topAnchor.constraint(equalTo: accountInfoTitle.bottomAnchor, constant: 20),
//            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            emailTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            resetPasswordButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
//            resetPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//    }
//    
//    @objc private func resetPasswordButtonTapped() {
//        guard let email = emailTextField.text, !email.isEmpty else {
//            let alert = UIAlertController(title: "Error", message: "이메일을 입력해주세요.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
//        
//        Auth.auth().sendPasswordReset(withEmail: email) { error in
//            if let error = error {
//                print("비밀번호 재설정 이메일을 보내는 중에 오류가 발생했습니다.: \(error.localizedDescription)")
//                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                return
//            }
//            
//            let alert = UIAlertController(title: "Password Reset", message: "비밀번호 재설정 이메일이 \(email)로 전송되었습니다. 받은 편지함을 확인하세요.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            
//            print("비밀번호 재설정 이메일이 전송되었습니다.")
//        }
//    }
//}
