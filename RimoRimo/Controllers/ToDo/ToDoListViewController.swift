import UIKit
import FirebaseFirestore
import FirebaseAuth
import SnapKit

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // UI Components
    var datePicker: UIDatePicker!
    var textField: UITextField!
    var saveButton: UIButton!
    var tableView: UITableView!
    var textFieldStack: UIStackView!
    var imageView: UIImageView!
    var underline: UIView!
    
    // Data
    var todos: [[String: Any]] = []
    var editingIndexPath: IndexPath?
    var selectedDate: Date = Date()
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupActions()
        
        addSnapshotListener(for: selectedDate)
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        view.backgroundColor = MySpecialColors.Gray1
        
        // DatePicker Setup
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.setDate(Date(), animated: false)
        datePicker.minimumDate = Date()
        let calendar = Calendar.current
        let nextYear = calendar.date(byAdding: .year, value: 1, to: Date())
        datePicker.maximumDate = nextYear
        view.addSubview(datePicker)
        
        // TextField Setup
        textField = UITextField()
        textField.placeholder = "할 일을 입력하세요"
        textField.borderStyle = .none
        textField.delegate = self
        
        // Underline Setup
        underline = UIView()
        underline.backgroundColor = MySpecialColors.Gray2
        view.addSubview(underline)
        
        // Save Button Setup
        saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(named: "add-plus-circle"), for: .normal)
        saveButton.tintColor = MySpecialColors.MainColor
        
        // ImageView Setup
        imageView = UIImageView(image: UIImage(named: "Group 591"))
        imageView.contentMode = .scaleAspectFit
        
        // TextField Stack Setup
        textFieldStack = UIStackView(arrangedSubviews: [imageView, textField, saveButton])
        textFieldStack.axis = .horizontal
        textFieldStack.spacing = 10
        view.addSubview(textFieldStack)
        
        // TableView Setup
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = MySpecialColors.Gray1
        tableView.register(ToDoTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
    
    // MARK: - Constraints Setup
    
    func setupConstraints() {
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(view).offset(100)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }
        
        textFieldStack.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.equalTo(view).offset(26)
            make.trailing.equalTo(view).offset(-26)
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
    }
    
    // MARK: - Actions Setup
    
    func setupActions() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveToDo), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func datePickerValueChanged() {
        selectedDate = datePicker.date
        addSnapshotListener(for: selectedDate)
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
    
    @objc func saveEditedText(_ sender: UIButton) {
        guard let indexPath = editingIndexPath else { return }
        let todo = todos[indexPath.row]
        guard let documentId = todo["id"] as? String else { return }
        let updatedText = (tableView.cellForRow(at: indexPath) as? ToDoTableViewCell)?.textField.text ?? ""
        
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
        
        if let cell = tableView.cellForRow(at: indexPath) as? ToDoTableViewCell {
            cell.resetContent()
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
    
    // MARK: - Firebase Functions
    
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
            .order(by: "date", descending: false)
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
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        let todo = todos[indexPath.row]
        let todoText = todo["todo"] as? String ?? ""
        let isCompleted = todo["completed"] as? Bool ?? false
        cell.configure(with: todoText, isCompleted: isCompleted, index: indexPath.row, target: self)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let previousIndexPath = editingIndexPath {
            guard let previousCell = tableView.cellForRow(at: previousIndexPath) as? ToDoTableViewCell else { return }
            previousCell.resetContent()
            tableView.reloadRows(at: [previousIndexPath], with: .automatic)
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ToDoTableViewCell else { return }
        let todo = todos[indexPath.row]
        guard let todoText = todo["todo"] as? String else { return }
        cell.setEditMode(todoText: todoText, target: self)
        
        editingIndexPath = indexPath
    }
    
    // MARK: - Swipe to Delete
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let todo = self.todos[indexPath.row]
            guard let documentId = todo["id"] as? String else { return }
            guard let uid = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let day = formatter.string(from: self.datePicker.date)
            
            // Firestore에서 데이터를 삭제합니다.
            Firestore.firestore()
                .collection("user-info")
                .document(uid)
                .collection("todo-list")
                .document(day)
                .collection("sub-collection")
                .document(documentId)
                .delete { [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        print("Error deleting todo: \(error.localizedDescription)")
                        completionHandler(false) // 삭제 실패 시
                    } else {
                        print("ToDo가 성공적으로 삭제되었습니다.")
                        completionHandler(true) // 삭제 성공 시
                    }
                }
        }
        
        deleteAction.backgroundColor = MySpecialColors.MainColor
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.remove()
    }
}

class ToDoTableViewCell: UITableViewCell {
    
    var toggleButton: UIButton!
    var todoTextLabel: UILabel!
    var underline: UIView!
    var textField: UITextField!
    var saveButton: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
        setupCellConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellUI() {
        toggleButton = UIButton()
        todoTextLabel = UILabel()
        underline = UIView()
        underline.backgroundColor = MySpecialColors.Gray2
        
        contentView.addSubview(toggleButton)
        contentView.addSubview(todoTextLabel)
        contentView.addSubview(underline)
    }
    
    func setupCellConstraints() {
        toggleButton.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(30)
        }
        
        todoTextLabel.snp.makeConstraints { make in
            make.leading.equalTo(toggleButton.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).offset(-10)
            make.centerY.equalTo(contentView)
        }
        
        underline.snp.makeConstraints { make in
            make.leading.equalTo(toggleButton.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).offset(-10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-1)
            make.height.equalTo(1)
        }
    }
    
    func configure(with todoText: String, isCompleted: Bool, index: Int, target: Any) {
        todoTextLabel.text = todoText
        toggleButton.setImage(UIImage(named: isCompleted ? "Group 583" : "Group 582"), for: .normal)
        toggleButton.tag = index
        toggleButton.addTarget(target, action: #selector(ToDoListViewController.toggleButtonTapped(_:)), for: .touchUpInside)
    }
    
    func setEditMode(todoText: String, target: Any) {
        todoTextLabel.isHidden = true
        
        textField = UITextField()
        textField.text = todoText
        textField.borderStyle = .none
        textField.tag = toggleButton.tag
        contentView.addSubview(textField)
        
        saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(named: "edit-pencil-01"), for: .normal)
        saveButton.tintColor = MySpecialColors.MainColor
        saveButton.addTarget(target, action: #selector(ToDoListViewController.saveEditedText(_:)), for: .touchUpInside)
        saveButton.tag = toggleButton.tag
        contentView.addSubview(saveButton)
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(toggleButton.snp.trailing).offset(10)
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(saveButton.snp.leading).offset(-10)
            make.height.equalTo(30)
        }
        
        saveButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-10)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(30)
        }
    }
    
    func resetContent() {
        textField?.removeFromSuperview()
        saveButton?.removeFromSuperview()
        todoTextLabel.isHidden = false
    }
}
