//
//  ToDoDetailViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ToDoDetailViewController: UIViewController {
    
    private let date: Date
    private var todoDocumentID: String?
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter your text"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveText), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(date: Date) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTextField()
        setupSaveButton()
        fetchToDoData()
    }
    
    private func setupTextField() {
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSaveButton() {
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func fetchToDoData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: date)
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("todo-list")
            .whereField("date", isEqualTo: day)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching todo data: \(error.localizedDescription)")
                    return
                }
                
                guard let document = querySnapshot?.documents.first else {
                    let newDocumentRef = Firestore.firestore()
                        .collection("user-info")
                        .document(uid)
                        .collection("todo-list")
                        .document()
                    
                    self.todoDocumentID = newDocumentRef.documentID
                    return
                }
                
                self.todoDocumentID = document.documentID
                if let text = document.data()["text"] as? String {
                    self.textField.text = text
                }
            }
    }
    
    @objc private func saveText() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let todoDocumentID = todoDocumentID else { return }
        guard let text = textField.text else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: date)
        
        let data: [String: Any] = [
            "date": day,
            "text": text
        ]
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("todo-list")
            .document(todoDocumentID)
            .setData(data) { error in
                if let error = error {
                    print("할 일 데이터를 저장하는 중에 오류가 발생했습니다. \(error.localizedDescription)")
                } else {
                    print("Todo 데이터가 성공적으로 저장되었습니다.")
                }
            }
    }
}
