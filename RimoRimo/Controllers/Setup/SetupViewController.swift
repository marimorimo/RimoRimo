//
//  SetupViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseAuth
import WidgetKit

class SetupViewController: UIViewController {
    let settingDescriptionString = [("프로필 수정", "내 프로필을 수정합니다."),
                                    ("계정 관리", "내 계정 정보를 관리합니다."),
                                    ("정보", "앱과 관련된 정보를 확인합니다.")]
    
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
        button.addTarget(self, action: #selector(logoutButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    @objc private func logoutButtonTapped(_ sender: UIButton) {
        showLogOutAlert(title: "로그아웃", subTitle: "로그아웃 하시겠습니까?")
    }
    
    private lazy var loginButton: UIButton = {
        let button = TabButtonUIFactory.tapButton(buttonTitle: "로그아웃",
                                                  textColor: .white,
                                                  cornerRadius: 24,
                                                  backgroundColor: MySpecialColors.Gray3)
        button.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    @objc private func loginButtonTapped(_ sender: UIButton) {
        let loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    // Log Out Alert
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
                         
    private func showLogOutAlert(title: String, subTitle: String) {
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
        
        checkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performLogout)))
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

    private let START_TIME_KEY = "startTime"
    private let STOP_TIME_KEY = "stopTime"
    private let COUNTING_KEY = "countingKey"
    private let saveAutoLoginInfo = "userEmail"
    @objc private func performLogout() {
        do {
            try Auth.auth().signOut()
            // 로그아웃 후 저장된 로그인 정보 삭제
            UserDefaults.standard.removeObject(forKey: self.saveAutoLoginInfo)
            UserDefaults.standard.removeObject(forKey: self.START_TIME_KEY)
            UserDefaults.standard.removeObject(forKey: self.STOP_TIME_KEY)
            UserDefaults.standard.removeObject(forKey: self.COUNTING_KEY)

            let defaults = UserDefaults.standard
            for key in defaults.dictionaryRepresentation().keys {
                defaults.removeObject(forKey: key)
            }

            defaults.synchronize()

            print("UserDefaults deleted successfully")
            
            WidgetCenter.shared.reloadAllTimelines()

            // 로그인 화면으로 이동
            let loginViewController = LoginViewController()
            let navController = UINavigationController(rootViewController: loginViewController)
            
            // 화면 전환
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.changeRootViewController(navController)
                navController.navigationBar.topItem?.title = ""  // 타이틀을 빈 문자열로 설정
                navController.navigationItem.hidesBackButton = true
            }
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
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem = backBarButtonItem
        
        switch indexPath.row {
        case 0:
            let nextVC = EditMyPageViewController()
            self.navigationController?.pushViewController(nextVC, animated: true)
        case 1:
            let nextVC = AccountInfoViewController()
            self.navigationController?.pushViewController(nextVC, animated: true)
        case 2:
            let nextVC = AppInfoViewController()
            self.navigationController?.pushViewController(nextVC, animated: true)
        default:
            debugPrint("invalid indexPath")
        }
    }
}
