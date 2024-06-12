//
//  CalenderDeatailViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CalenderDeatailViewController: UIViewController {
    var data: [String: Any]?
    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }
    private let calenderDeatailTitle: UILabel = {
        let text = UILabel()
        text.text = "CalenderDeatail"
        return text
    }()
    
    private lazy var memoLabel: UILabel = {
        let label = UILabel()
        label.text = "메모를 추가하려면 탭하세요."
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMemoLabelTap)))
        return label
    }()
    
    private lazy var memoTextField: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Memo", for: .normal)
        button.addTarget(self, action: #selector(saveMemo), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(calenderDeatailTitle)
        view.addSubview(memoLabel)
        view.addSubview(memoTextField)
        view.addSubview(saveButton)
        
        calenderDeatailTitle.translatesAutoresizingMaskIntoConstraints = false
        memoLabel.translatesAutoresizingMaskIntoConstraints = false
        memoTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            calenderDeatailTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            calenderDeatailTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            memoLabel.topAnchor.constraint(equalTo: calenderDeatailTitle.bottomAnchor, constant: 20),
            memoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            memoTextField.topAnchor.constraint(equalTo: calenderDeatailTitle.bottomAnchor, constant: 20),
            memoTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            memoTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            memoTextField.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.topAnchor.constraint(equalTo: memoTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        displayData()
    }
    
    private func displayData() {
        guard let data = data else { return }
        
        var topAnchor = memoLabel.bottomAnchor
        
        for (key, value) in data {
            let keyLabel = UILabel()
            keyLabel.text = key
            keyLabel.font = UIFont.boldSystemFont(ofSize: 16)
            keyLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(keyLabel)
            
            let valueLabel = UILabel()
            valueLabel.text = "\(value)"
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(valueLabel)
            
            NSLayoutConstraint.activate([
                keyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                keyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                
                valueLabel.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: 10),
                valueLabel.firstBaselineAnchor.constraint(equalTo: keyLabel.firstBaselineAnchor),
                valueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
            
            topAnchor = keyLabel.bottomAnchor
        }
    }
    
    @objc private func handleMemoLabelTap() {
        memoLabel.isHidden = true
        memoTextField.isHidden = false
        memoTextField.becomeFirstResponder()
    }
    
    @objc private func saveMemo() {
        guard let uid = uid, let day = data?["day"] as? String else {
            print("UID or day is nil")
            return
        }
        
        guard let memoText = memoTextField.text else {
            print("Memo text is nil")
            return
        }
        
        let memoData: [String: Any] = [
            "day-memo": memoText
        ]
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(day)
            .updateData(memoData) { error in
                if let error = error {
                    print("메모 업데이트 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("메모가 성공적으로 업데이트되었습니다.")
                }
            }
    }
}
