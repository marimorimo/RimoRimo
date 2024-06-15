//
//  SetupViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseAuth

class SetupViewController: UIViewController {
    let settingDescriptionString = [("프로필 수정", "내 프로필을 수정합니다."),
                                    ("계정 관리", "내 계정 정보를 관리합니다."),
                                    ("비밀번호 변경하기", "비밀번호를 변경합니다.")]
    
    private lazy var settingTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.cellId)
        
        tableView.isScrollEnabled = false
        
        tableView.separatorStyle = .none
        
        tableView.rowHeight = 58
        tableView.rowHeight = UITableView.automaticDimension
        
        return tableView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = TabButtonUIFactory.tapButton(buttonTitle: "로그아웃",
                                                  textColor: .white,
                                                  cornerRadius: 24,
                                                  backgroundColor: MySpecialColors.Gray3)
        button.addTarget(nil, action: #selector(logoutButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    @objc private func logoutButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log Out", message: "로그아웃", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private lazy var loginButton: UIButton = {
        let button = TabButtonUIFactory.tapButton(buttonTitle: "로그인",
                                                  textColor: .white,
                                                  cornerRadius: 24,
                                                  backgroundColor: MySpecialColors.MainColor)
        button.addTarget(nil, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    @objc private func loginButtonTapped(_ sender: UIButton) {
        let loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }

   
    private let saveAutoLoginInfo = "userEmail"
    private func performLogout() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: saveAutoLoginInfo)
            let loginViewController = LoginViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            
            let errorAlert = UIAlertController(title: "Error", message: "로그아웃하는 중에 오류가 발생했습니다. 다시 시도해 주세요.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(errorAlert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViews()
        setupLayout()
        
        updateUIBasedOnAuthState()
    }
    
    private func updateUIBasedOnAuthState() {
        if let _ = Auth.auth().currentUser {
            // 사용자가 로그인되어 있는 경우
            logoutButton.isHidden = false
            loginButton.isHidden = true
        } else {
            // 사용자가 로그인되어 있지 않은 경우
            logoutButton.isHidden = true
            loginButton.isHidden = false
        }
    }
    
    private func setupUI() {
        self.title = "설정"
        view.backgroundColor = MySpecialColors.Gray1
        
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "chevron-left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "chevron-left")
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = MySpecialColors.Green4
    }
    
    private func setupViews() {
        view.addSubview(settingTableView)
        view.addSubview(logoutButton)
        view.addSubview(loginButton)
    }
    
    private func setupLayout() {
        settingTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.top.equalToSuperview().inset(14)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(26)
            make.height.greaterThanOrEqualTo(46)
        }
        
        loginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(26)
            make.height.greaterThanOrEqualTo(46)
        }
    }
}

extension SetupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingDescriptionString.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.cellId,
                                                 for: indexPath) as! SettingTableViewCell
        
        cell.titleLabel.text = settingDescriptionString[indexPath.row].0
        cell.descriptionLabel.text = settingDescriptionString[indexPath.row].1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let nextVC = EditMyPageViewController()
            self.navigationController?.pushViewController(nextVC, animated: false)
        case 1:
            let nextVC = AccountInfoViewController()
            self.navigationController?.pushViewController(nextVC, animated: false)
        case 2:
            let nextVC = FindPasswordViewController()
            self.navigationController?.pushViewController(nextVC, animated: false)
        default:
            debugPrint("invalid indexPath")
        }
    }
}
    //    private let saveAutoLoginInfo = "userEmail"
    //    private let options = ["프로필 수정", "계정 관리", "비밀번호 변경하기"]
    //    private let tableView = UITableView()
    //
    //    private let logoutButton: UIButton = {
    //        let button = UIButton()
    //        button.setTitle("LogOut", for: .normal)
    //        button.setTitleColor(.red, for: .normal)
    //        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    //        return button
    //    }()
    //
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        view.backgroundColor = .white
    //        title = "설정"
    //
    //        view.addSubview(tableView)
    //        view.addSubview(logoutButton)
    //
    //        tableView.translatesAutoresizingMaskIntoConstraints = false
    //        logoutButton.translatesAutoresizingMaskIntoConstraints = false
    //
    //        NSLayoutConstraint.activate([
    //            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
    //            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    //            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    //            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    //
    //            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    //            logoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
    //            logoutButton.heightAnchor.constraint(equalToConstant: 40),
    //            logoutButton.widthAnchor.constraint(equalToConstant: 80)
    //        ])
    //
    //        tableView.dataSource = self
    //        tableView.delegate = self
    //        tableView.rowHeight = 38
    //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    //    }
    //
    //    @objc private func logoutButtonTapped() {
    //        // 로그아웃 확인 알림 표시
    //        let alert = UIAlertController(title: "Log Out", message: "로그아웃", preferredStyle: .alert)
    //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    //        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
    //            self.performLogout()
    //        }))
    //        present(alert, animated: true, completion: nil)
    //    }
    //
    //    private func performLogout() {
    //        do {
    //            try Auth.auth().signOut()
    //            // 로그아웃 후 저장된 로그인 정보 삭제
    //            UserDefaults.standard.removeObject(forKey: saveAutoLoginInfo)
    //            // 로그아웃 후 처리 (예: 로그인 화면으로 이동)
    //            let loginViewController = LoginViewController()
    //            loginViewController.modalPresentationStyle = .fullScreen
    //            present(loginViewController, animated: true, completion: nil)
    //        } catch let signOutError as NSError {
    //            print("Error signing out: %@", signOutError)
    //
    //            // 오류 알림 표시
    //            let errorAlert = UIAlertController(title: "Error", message: "로그아웃하는 중에 오류가 발생했습니다. 다시 시도해 주세요.", preferredStyle: .alert)
    //            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //            present(errorAlert, animated: true, completion: nil)
    //        }
    //    }
    //
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return options.count
    //    }
    //
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    //        cell.textLabel?.text = options[indexPath.row]
    //        return cell
    //    }
    //
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        tableView.deselectRow(at: indexPath, animated: true)
    //
    //        var detailVC: UIViewController
    //
    //        switch indexPath.row {
    //        case 0:
    //            detailVC = EditMyPageViewController()
    //        case 1:
    //            detailVC = AccountInfoViewController()
    //        case 2:
    //            detailVC = FindPasswordViewController()
    //        default:
    //            return
    //        }
    //
    //        navigationController?.pushViewController(detailVC, animated: true)
    //    }
    //}
