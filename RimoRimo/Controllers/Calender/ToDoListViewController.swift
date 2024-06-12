//
//  ToDoListViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var datePicker: UIDatePicker!
    var textField: UITextField!
    var saveButton: UIButton!
    var tableView: UITableView!
    var todos: [[String: Any]] = []
    var editingIndexPath: IndexPath?
    var selectedDate: Date = Date()
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        
        datePicker.setDate(Date(), animated: false)
        
        datePicker.minimumDate = Date()
        
        let calendar = Calendar.current
        let nextYear = calendar.date(byAdding: .year, value: 1, to: Date())
        datePicker.maximumDate = nextYear
        
        view.addSubview(datePicker)
        
        textField = UITextField()
        textField.placeholder = "할 일을 입력하세요"
        textField.borderStyle = .roundedRect
        textField.delegate = self
        view.addSubview(textField)
        
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveToDo), for: .touchUpInside)
        view.addSubview(saveButton)
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            textField.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        addSnapshotListener(for: selectedDate)
    }
    
    @objc func datePickerValueChanged() {
        selectedDate = datePicker.date
        addSnapshotListener(for: selectedDate)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let todo = todos[indexPath.row]
        let todoText = todo["todo"] as? String ?? ""
        let isCompleted = todo["completed"] as? Bool ?? false
        cell.textLabel?.text = todoText
        
        let toggleButton = UIButton(type: .system)
        toggleButton.setImage(UIImage(systemName: isCompleted ? "checkmark.square" : "square"), for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped(_:)), for: .touchUpInside)
        toggleButton.tag = indexPath.row
        
        toggleButton.frame = CGRect(x: cell.contentView.bounds.width - 40, y: 0, width: 40, height: cell.contentView.bounds.height)
        
        cell.contentView.addSubview(toggleButton)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let todo = todos[indexPath.row]
        guard let todoText = todo["todo"] as? String else { return }
        cell.textLabel?.isHidden = true
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: cell.contentView.bounds.width - 40, height: cell.contentView.bounds.height))
        textField.text = todoText
        textField.borderStyle = .none
        textField.delegate = self
        textField.tag = indexPath.row
        cell.contentView.addSubview(textField)
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveEditedText(_:)), for: .touchUpInside)
        saveButton.tag = indexPath.row
        
        saveButton.frame = CGRect(x: cell.contentView.bounds.width - 140, y: 0, width: 40, height: cell.contentView.bounds.height)
        
        cell.contentView.addSubview(saveButton)
        
        editingIndexPath = indexPath
    }
    
    @objc func saveEditedText(_ sender: UIButton) {
        guard let indexPath = editingIndexPath else { return }
        let todo = todos[indexPath.row]
        guard let documentId = todo["id"] as? String else { return }
        let updatedText = (tableView.cellForRow(at: indexPath)?.contentView.subviews.first { $0 is UITextField } as? UITextField)?.text ?? ""
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자가 인증되지 않았습니다.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: datePicker.date)
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("todo-list")
            .document(day)
            .collection("sub-collection")
            .document(documentId)
            .updateData(["todo": updatedText]) { [weak self] error in
                if let error = error {
                    print("Error updating todo text: \(error.localizedDescription)")
                } else {
                    print("Todo 텍스트가 성공적으로 업데이트되었습니다.")
                    self?.loadTodos(for: self?.selectedDate ?? Date())
                    
                }
            }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            for subview in cell.contentView.subviews {
                if subview is UITextField || subview is UIButton {
                    subview.removeFromSuperview()
                }
            }
        }
        
        editingIndexPath = nil
    }
    
    @objc func toggleButtonTapped(_ sender: UIButton) {
        let rowIndex = sender.tag
        let todo = todos[rowIndex]
        let isCompleted = todo["completed"] as? Bool ?? false
        let updatedStatus = !isCompleted
        updateCompletionStatus(todoIndex: rowIndex, isCompleted: updatedStatus)
    }
    
    func updateCompletionStatus(todoIndex: Int, isCompleted: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: datePicker.date)
        
        let todo = todos[todoIndex]
        guard let documentId = todo["id"] as? String else {
            print("Document ID not found")
            return
        }
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("todo-list")
            .document(day)
            .collection("sub-collection")
            .document(documentId)
            .updateData(["completed": isCompleted]) { [weak self] error in
                if let error = error {
                    print("Error updating completion status: \(error.localizedDescription)")
                } else {
                    print("완료 상태가 성공적으로 업데이트되었습니다.")
                    self?.loadTodos(for: self?.selectedDate ?? Date())
                }
            }
    }
    
    @objc func saveToDo() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자가 인증되지 않았습니다.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: datePicker.date)
        
        let todoText = textField.text ?? ""
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("todo-list")
            .document(day)
            .collection("sub-collection")
            .addDocument(data: ["todo": todoText, "date": Timestamp(date: Date()), "completed": false]) { [weak self] error in
                if let error = error {
                    print("Error saving ToDo: \(error.localizedDescription)")
                } else {
                    print("ToDo가 성공적으로 저장되었습니다.")
                    self?.textField.text = ""
                    self?.loadTodos(for: self?.selectedDate ?? Date())
                }
            }
    }
    
    func addSnapshotListener(for date: Date) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: date)
        
        listener?.remove()
        
        listener = Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("todo-list")
            .document(day)
            .collection("sub-collection")
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    
                    self.todos.removeAll()
                    for document in querySnapshot!.documents {
                        var todoData = document.data()
                        todoData["id"] = document.documentID
                        self.todos.append(todoData)
                    }
                    self.tableView.reloadData()
                }
            }
    }
    
    func loadTodos(for date: Date) {
        addSnapshotListener(for: date)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
    }
}
