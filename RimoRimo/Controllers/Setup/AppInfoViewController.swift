//
//  LicenseViewController.swift
//  RimoRimo
//
//  Created by 이유진 on 6/21/24.
//

import UIKit

class AppInfoViewController: UIViewController {
    
    let settingDescriptionString = [("라이선스", "사용된 리소스의 출처 및 정보를 확인할 수 있습니다."),
                                    ("개인정보 처리방침", "개인정보 수집 및 이용 방침을 확인할 수 있습니다.")]
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViews()
        setupLayout()
    }
    
    private func setupUI() {
        self.title = "정보"
        view.backgroundColor = MySpecialColors.Gray1
        
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "chevron-left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "chevron-left")
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = MySpecialColors.Green4
    }
    
    private func setupViews() {
        view.addSubview(settingTableView)
    }
    
    private func setupLayout() {
        settingTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.top.equalToSuperview().inset(14)
        }
    }
}

extension AppInfoViewController: UITableViewDelegate, UITableViewDataSource {
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
            let nextVC = LicenseViewController()
            self.navigationController?.pushViewController(nextVC, animated: true)
        case 1:
            let nextVC = InfoPrivacyPolicyViewController()
            self.navigationController?.pushViewController(nextVC, animated: true)
        default:
            debugPrint("invalid indexPath")
        }
    }
}
