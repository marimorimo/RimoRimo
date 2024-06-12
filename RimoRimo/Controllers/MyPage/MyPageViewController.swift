//
//  MyPageViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MyPageViewController: UIViewController {

    private let myPageTitle: UILabel = {
        let text = UILabel()
        text.text = "MyPage"
        text.font = UIFont.boldSystemFont(ofSize: 24)
        return text
    }()
    
    private let setupButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.addTarget(self, action: #selector(setupButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let dDayTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let dDayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let targetTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(myPageTitle)
        view.addSubview(setupButton)
        view.addSubview(emailLabel)
        view.addSubview(nicknameLabel)
        view.addSubview(dDayTitleLabel)
        view.addSubview(dDayLabel)
        view.addSubview(targetTimeLabel)
        view.addSubview(profileImageView)
        
        myPageTitle.translatesAutoresizingMaskIntoConstraints = false
        setupButton.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        dDayTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dDayLabel.translatesAutoresizingMaskIntoConstraints = false
        targetTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            myPageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            myPageTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            setupButton.topAnchor.constraint(equalTo: myPageTitle.bottomAnchor, constant: 20),
            setupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            setupButton.widthAnchor.constraint(equalToConstant: 40),
            setupButton.heightAnchor.constraint(equalToConstant: 40),
            
            emailLabel.topAnchor.constraint(equalTo: setupButton.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            nicknameLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            nicknameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            dDayTitleLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 10),
            dDayTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            dDayLabel.topAnchor.constraint(equalTo: dDayTitleLabel.bottomAnchor, constant: 10),
            dDayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            targetTimeLabel.topAnchor.constraint(equalTo: dDayLabel.bottomAnchor, constant: 10),
            targetTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            profileImageView.topAnchor.constraint(equalTo: targetTimeLabel.bottomAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        setupUserDataListener()
    }
    
    private func setupUserDataListener() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        listener = Firestore.firestore().collection("user-info").document(uid).addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            if let document = documentSnapshot, document.exists {
                let data = document.data()
                self.emailLabel.text = "Email: \(data?["email"] as? String ?? "N/A")"
                self.nicknameLabel.text = "Nickname: \(data?["nickname"] as? String ?? "N/A")"
                self.dDayTitleLabel.text = "D-day Title: \(data?["d-day-title"] as? String ?? "N/A")"
                self.dDayLabel.text = "D-day: \(data?["d-day"] as? String ?? "N/A")"
                self.targetTimeLabel.text = "Target Time: \(data?["target-time"] as? String ?? "N/A")"
                
                if let profileImageURLString = data?["profile-image"] as? String, !profileImageURLString.isEmpty {
                    if let profileImageURL = URL(string: profileImageURLString) {
                        URLSession.shared.dataTask(with: profileImageURL) { (data, response, error) in
                            if let data = data {
                                DispatchQueue.main.async {
                                    self.profileImageView.image = UIImage(data: data)
                                }
                            }
                        }.resume()
                    }
                } else {
                    self.profileImageView.image = UIImage(named: "Group 1")
                }
            } else {
                self.emailLabel.text = "Email: N/A"
                self.nicknameLabel.text = "Nickname: N/A"
                self.dDayTitleLabel.text = "D-day Title: N/A"
                self.dDayLabel.text = "D-day: N/A"
                self.targetTimeLabel.text = "Target Time: N/A"
                self.profileImageView.image = UIImage(named: "Group 1")
            }
        }
    }
    
    @objc private func setupButtonTapped() {
        let settingsVC = SetupViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    deinit {
        listener?.remove()
    }
}
