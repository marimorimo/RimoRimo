//
//  EditMyPageViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class EditMyPageViewController: UIViewController {
    
    private let editMypageTitle: UILabel = {
        let text = UILabel()
        text.text = "editMypage"
        text.font = UIFont.boldSystemFont(ofSize: 24)
        return text
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your nickname"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let duplicateCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Check", for: .normal)
        button.addTarget(self, action: #selector(duplicateCheckButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView = UIImageView()
    private let dDayTitleTextField = UITextField()
    private let dDayTextField = UITextField()
    private let targetTimeTextField = UITextField()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ko_KR")
        return picker
    }()
    
    private let todayCheckbox: UISwitch = {
        let checkbox = UISwitch()
        checkbox.isOn = true
        checkbox.addTarget(self, action: #selector(todayCheckboxChanged), for: .valueChanged)
        return checkbox
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(saveButton)
        view.addSubview(editMypageTitle)
        view.addSubview(nicknameTextField)
        view.addSubview(duplicateCheckButton)
        view.addSubview(profileImageView)
        view.addSubview(dDayTitleTextField)
        view.addSubview(dDayTextField)
        view.addSubview(targetTimeTextField)
        
        setupConstraints()
        setupProfileImageView()
        fetchUserData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dDayTextFieldTapped))
        dDayTextField.addGestureRecognizer(tapGesture)
        dDayTextField.isUserInteractionEnabled = true
        
        dDayTextField.inputView = datePicker
        
        view.addSubview(todayCheckbox)
        todayCheckbox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            todayCheckbox.topAnchor.constraint(equalTo: dDayTextField.bottomAnchor, constant: 8),
            todayCheckbox.leadingAnchor.constraint(equalTo: dDayTextField.leadingAnchor),
        ])
    }
    
    private func setupConstraints() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        editMypageTitle.translatesAutoresizingMaskIntoConstraints = false
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        duplicateCheckButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        dDayTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        dDayTextField.translatesAutoresizingMaskIntoConstraints = false
        targetTimeTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 40),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            
            editMypageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editMypageTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            nicknameTextField.topAnchor.constraint(equalTo: editMypageTitle.bottomAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: duplicateCheckButton.leadingAnchor, constant: -10),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            duplicateCheckButton.centerYAnchor.constraint(equalTo: nicknameTextField.centerYAnchor),
            duplicateCheckButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            duplicateCheckButton.widthAnchor.constraint(equalToConstant: 80),
            duplicateCheckButton.heightAnchor.constraint(equalToConstant: 40),
            
            profileImageView.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            dDayTitleTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            dDayTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dDayTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dDayTitleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            dDayTextField.topAnchor.constraint(equalTo: dDayTitleTextField.bottomAnchor, constant: 20),
            dDayTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dDayTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dDayTextField.heightAnchor.constraint(equalToConstant: 40),
            
            targetTimeTextField.topAnchor.constraint(equalTo: dDayTextField.bottomAnchor, constant: 20),
            targetTimeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            targetTimeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            targetTimeTextField.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        nicknameTextField.borderStyle = .roundedRect
        dDayTitleTextField.borderStyle = .roundedRect
        dDayTextField.borderStyle = .roundedRect
        targetTimeTextField.borderStyle = .roundedRect
    }
    
    private func setupProfileImageView() {
        profileImageView.image = UIImage(named: "profileImage")
        profileImageView.isUserInteractionEnabled = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func profileImageTapped() {
        let imagePickerVC = ImagePickerViewController()
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true, completion: nil)
    }
    
    @objc private func duplicateCheckButtonTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "닉네임을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Firestore.firestore().collection("user-info").whereField("nickname", isEqualTo: nickname).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("닉네임 확인 중 오류 발생: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let documents = querySnapshot?.documents, documents.isEmpty {
                let alert = UIAlertController(title: "Available", message: "이 닉네임을 사용할 수 있습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Unavailable", message: "이 닉네임은 이미 사용 중입니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    private func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("user-info").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.nicknameTextField.text = data?["nickname"] as? String ?? ""
                self.dDayTitleTextField.text = data?["d-day-title"] as? String ?? ""
                self.dDayTextField.text = data?["d-day"] as? String ?? ""
                self.targetTimeTextField.text = data?["target-time"] as? String ?? ""
                
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
                
                if self.nicknameTextField.text == "" {
                    self.nicknameTextField.placeholder = "Enter your nickname"
                }
                if self.dDayTitleTextField.text == "" {
                    self.dDayTitleTextField.placeholder = "Enter D-day title"
                }
                if self.dDayTextField.text == "" {
                    self.dDayTextField.placeholder = "Enter D-day"
                }
                if self.targetTimeTextField.text == "" {
                    self.targetTimeTextField.placeholder = "Enter target time"
                }
            } else {
                self.nicknameTextField.placeholder = "Enter your nickname"
                self.dDayTitleTextField.placeholder = "Enter D-day title"
                self.dDayTextField.placeholder = "Enter D-day"
                self.targetTimeTextField.placeholder = "Enter target time"
            }
        }
    }
    
    @objc private func saveButtonTapped() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var userDataToUpdate: [String: Any] = [:]
        
        if let nickname = nicknameTextField.text, !nickname.isEmpty {
            userDataToUpdate["nickname"] = nickname
        }
        
        if let dDayTitle = dDayTitleTextField.text, !dDayTitle.isEmpty {
            userDataToUpdate["d-day-title"] = dDayTitle
        }
        
        if let dDay = dDayTextField.text, !dDay.isEmpty {
            userDataToUpdate["d-day"] = dDay
        }
        
        if let targetTime = targetTimeTextField.text, !targetTime.isEmpty {
            userDataToUpdate["target-time"] = targetTime
        }
        
        if let profileImage = profileImageView.image, let imageData = profileImage.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading profile image: \(error.localizedDescription)")
                    return
                }

                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error fetching download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    userDataToUpdate["profile-image"] = downloadURL.absoluteString
                    
                    if !userDataToUpdate.isEmpty {
                        Firestore.firestore().collection("user-info").document(uid).updateData(userDataToUpdate) { error in
                            if let error = error {
                                print("사용자 데이터 업데이트 오류: \(error.localizedDescription)")
                            } else {
                                print("사용자 데이터가 성공적으로 업데이트되었습니다.")
                            }
                        }
                    }
                }
            }
        } else {
            if !userDataToUpdate.isEmpty {
                Firestore.firestore().collection("user-info").document(uid).updateData(userDataToUpdate) { error in
                    if let error = error {
                        print("사용자 데이터 업데이트 오류: \(error.localizedDescription)")
                    } else {
                        print("사용자 데이터가 성공적으로 업데이트되었습니다.")
                    }
                }
            } else {
                print("No data to update.")
            }
        }
    }
    
    @objc private func todayCheckboxChanged() {
        if todayCheckbox.isOn {
            dDayTextField.text = getCurrentDateString()
        } else {
            dDayTextField.text = ""
        }
    }
    
    private func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    @objc private func dDayTextFieldTapped() {
        dDayTextField.becomeFirstResponder()
    }
}

extension EditMyPageViewController: ImagePickerDelegate {
    func didSelectImage(named imageName: String) {
        profileImageView.image = UIImage(named: imageName)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("user-info").document(uid)
        userRef.updateData(["profile-image": imageName]) { error in
            if let error = error {
                print("프로필 이미지 업데이트 중 오류 발생: \(error.localizedDescription)")
            } else {
                print("프로필 이미지가 업데이트되었습니다.")
            }
        }
    }
}

protocol ImagePickerDelegate: AnyObject {
    func didSelectImage(named imageName: String)
}

class ImagePickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    weak var delegate: ImagePickerDelegate?
    
    private let imageNames = ["Group 2", "Group 3", "Group 4"]
    private let collectionView: UICollectionView
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = UIImageView(image: UIImage(named: imageNames[indexPath.item]))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        cell.contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
        ])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImageName = imageNames[indexPath.item]
        delegate?.didSelectImage(named: selectedImageName)
        dismiss(animated: true, completion: nil)
    }
}
