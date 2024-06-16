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
    private lazy var accountTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyAccountTableViewCell.self, forCellReuseIdentifier: MyAccountTableViewCell.cellId)
        tableView.separatorStyle = .none
        tableView.rowHeight = 58
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        return tableView
    }()
    
    private lazy var withdrawButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("회원탈퇴", for: .normal)
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
        self.title = "계정"
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
            make.bottom.equalToSuperview().inset(100)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
            make.width.equalTo(56)
        }
    }
    
    @objc private func withdrawButtonTapped() {
        let alert = UIAlertController(title: "회원 탈퇴", message: "정말로 회원 탈퇴하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in
            self.promptForPassword()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func promptForPassword() {
        let passwordPrompt = UIAlertController(title: "비밀번호 확인", message: "계속 진행하려면 비밀번호를 입력하세요.", preferredStyle: .alert)
        passwordPrompt.addTextField { textField in
            textField.placeholder = "비밀번호"
            textField.isSecureTextEntry = true
        }
        passwordPrompt.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        passwordPrompt.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            if let password = passwordPrompt.textFields?.first?.text {
                self?.reauthenticateUserAndDeleteAccount(withPassword: password)
            }
        }))
        present(passwordPrompt, animated: true, completion: nil)
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
    
    private func showResetPasswordAlert(forEmail email: String) {
        let alert = UIAlertController(title: "Error", message: "Error.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func sendPasswordReset(withEmail email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("비밀번호 재설정 이메일을 보내는 중에 오류가 발생했습니다.: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let alert = UIAlertController(title: "비밀번호 재설정", message: "비밀번호 재설정 이메일이 \(email)로 전송되었습니다. 받은 편지함을 확인하세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel , handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            print("비밀번호 재설정 이메일이 전송되었습니다.")
        }
    }
    
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
    
    private func showConfirmationAlert(forEmail email: String) {
        let alert = UIAlertController(title: "비밀번호 재설정", message: "비밀번호를 재설정 하시겠습니까?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.sendPasswordReset(withEmail: email)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension AccountInfoViewController: UITableViewDelegate, UITableViewDataSource, MyAccountTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyAccountTableViewCell.cellId, for: indexPath) as! MyAccountTableViewCell
        cell.delegate = self
        cell.titleLabel.text = "이메일"
        cell.descriptionLabel.text = userEmail ?? "정보 없음"
        cell.resetPasswordButton.setTitle("비밀번호 재설정", for: .normal)
        return cell
    }
    
    func didTapResetPasswordButton(withEmail email: String) {
        if email.isEmpty {
            showResetPasswordAlert(forEmail: email)
        } else {
            showConfirmationAlert(forEmail: email)
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
