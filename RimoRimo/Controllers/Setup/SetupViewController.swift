//
//  SetupViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseAuth

class SetupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let options = ["프로필 수정", "계정 관리", "비밀번호 변경하기"]
    private let tableView = UITableView()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("LogOut", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "설정"
        
        view.addSubview(tableView)
        view.addSubview(logoutButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            logoutButton.heightAnchor.constraint(equalToConstant: 40),
            logoutButton.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 38
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc private func logoutButtonTapped() {
        // 로그아웃 확인 알림 표시
        let alert = UIAlertController(title: "Log Out", message: "로그아웃", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func performLogout() {
        do {
            try Auth.auth().signOut()
            // 로그아웃 후 처리 (예: 로그인 화면으로 이동)
            let loginViewController = LoginViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            
            // 오류 알림 표시
            let errorAlert = UIAlertController(title: "Error", message: "로그아웃하는 중에 오류가 발생했습니다. 다시 시도해 주세요.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(errorAlert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var detailVC: UIViewController
        
        switch indexPath.row {
        case 0:
            detailVC = EditMyPageViewController()
        case 1:
            detailVC = AccountInfoViewController()
        case 2:
            detailVC = FindPasswordViewController()
        default:
            return
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
