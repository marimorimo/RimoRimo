import UIKit
import FirebaseFirestore
import FirebaseAuth
import SnapKit

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
        
        view.backgroundColor = MySpecialColors.Gray1
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
        textField.borderStyle = .none
        textField.delegate = self
        
        let underline = UIView()
        underline.backgroundColor = MySpecialColors.Gray2
        view.addSubview(underline)
        
        saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(named: "add-plus-circle"), for: .normal)
        saveButton.addTarget(self, action: #selector(saveToDo), for: .touchUpInside)
        saveButton.tintColor = MySpecialColors.MainColor
        
        let imageView = UIImageView(image: UIImage(named: "Group 591"))
        imageView.contentMode = .scaleAspectFit
        let textFieldStack = UIStackView(arrangedSubviews: [imageView, textField, saveButton])
        textFieldStack.axis = .horizontal
        textFieldStack.spacing = 10
        view.addSubview(textFieldStack)
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = MySpecialColors.Gray1
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .none  // 기존의 테이블 뷰 밑줄 제거
        view.addSubview(tableView)
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(view).offset(100)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }
        
        textFieldStack.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.height.equalTo(40)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(30) // 이미지 뷰 크기 설정
        }
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(30)
        }

        underline.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.equalTo(saveButton.snp.leading).offset(-10)
            make.bottom.equalTo(textField.snp.bottom).offset(1)
            make.height.equalTo(1)
        }
        
        saveButton.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(textFieldStack.snp.top).offset(-20)
        }
        
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
        
        // Clear existing subviews to avoid duplication
        cell.contentView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        let textLabel = UILabel()
        textLabel.text = todoText
        
        let toggleButton = UIButton()
        toggleButton.setImage(UIImage(named: isCompleted ? "Group 583" : "Group 582"), for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped(_:)), for: .touchUpInside)
        toggleButton.tag = indexPath.row
        
        cell.contentView.addSubview(toggleButton)
        cell.contentView.addSubview(textLabel)
        cell.backgroundColor = MySpecialColors.Gray1
        
        toggleButton.snp.makeConstraints { make in
            make.leading.equalTo(cell.contentView).offset(10)
            make.centerY.equalTo(cell.contentView)
            make.width.height.equalTo(30)
        }
        
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(toggleButton.snp.trailing).offset(10)
            make.trailing.equalTo(cell.contentView).offset(-10)
            make.centerY.equalTo(cell.contentView)
        }
        
        // Add underline to the cell
        let cellUnderline = UIView()
        cellUnderline.backgroundColor = MySpecialColors.Gray2
        cell.contentView.addSubview(cellUnderline)
        
        cellUnderline.snp.makeConstraints { make in
            make.leading.equalTo(toggleButton.snp.trailing).offset(10)
            make.trailing.equalTo(cell.contentView).offset(-10)
            make.bottom.equalTo(cell.contentView.snp.bottom).offset(-1)
            make.height.equalTo(1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let todo = todos[indexPath.row]
        guard let todoText = todo["todo"] as? String else { return }
        cell.textLabel?.isHidden = true
        
        // Remove all existing subviews from the cell's content view to avoid duplicates
        cell.contentView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
         // 셀의 배경색을 변경
        
        let textField = UITextField(frame: CGRect(x: 40, y: 0, width: cell.contentView.bounds.width - 80, height: cell.contentView.bounds.height))
        textField.text = todoText
        textField.borderStyle = .none
        textField.delegate = self
        textField.tag = indexPath.row
        cell.contentView.addSubview(textField)
        
        let saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(named: "edit-pencil-01"), for: .normal)
        saveButton.tintColor = MySpecialColors.MainColor
        saveButton.addTarget(self, action: #selector(saveEditedText(_:)), for: .touchUpInside)
        saveButton.tag = indexPath.row
        
        cell.contentView.addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.leading.equalTo(cell.contentView).offset(10)
            make.centerY.equalTo(cell.contentView)
            make.width.height.equalTo(30)
        }
        
        let cellUnderline = UIView()
        cellUnderline.backgroundColor = MySpecialColors.Gray2
        cell.contentView.addSubview(cellUnderline)
        
        cellUnderline.snp.makeConstraints { make in
            make.leading.equalTo(saveButton.snp.trailing).offset(10)
            make.trailing.equalTo(cell.contentView).offset(-10)
            make.bottom.equalTo(cell.contentView.snp.bottom).offset(-1)
            make.height.equalTo(1)
        }
        
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
            cell.backgroundColor = .white // 셀의 배경색을 원래 색으로 되돌림
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
               .order(by: "date", descending: false) // 이 줄을 추가하여 정렬
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
    
    // 스와이프하여 삭제 기능 추가
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todo = todos[indexPath.row]
            guard let documentId = todo["id"] as? String else { return }
            guard let uid = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let day = formatter.string(from: datePicker.date)
            
            // 먼저 UI 업데이트를 수행합니다.
            tableView.beginUpdates()
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            // Firestore에서 데이터를 삭제합니다.
            Firestore.firestore()
                .collection("user-info")
                .document(uid)
                .collection("todo-list")
                .document(day)
                .collection("sub-collection")
                .document(documentId)
                .delete { error in
                    if let error = error {
                        print("Error deleting todo: \(error.localizedDescription)")
                    } else {
                        print("ToDo가 성공적으로 삭제되었습니다.")
                    }
                }
        }
    }
}
