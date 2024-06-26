import UIKit
import WidgetKit
import FirebaseFirestore
import FirebaseAuth
import SnapKit

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var todolistArr: [String] = []
    
    //MARK: - UI Components
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
    
    let dateView: UIView = {
        let view = UIView()
        return view
    }()
    let dateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    
    let calendarButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "calendar")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.MainColor
        return button
    }()
    
    let editDate: UITextField = {
        let date = UITextField()
        date.font = UIFont.pretendard(style: .regular, size: 14)
        date.textColor = MySpecialColors.Gray4
        date.tintColor = .clear
        date.borderStyle = .none
        date.backgroundColor = .clear
        date.clearButtonMode = .never
        date.textAlignment = .right
        return date
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupActions()
        setupEditDateTapGesture()
        
        fetchTodoData(for: selectedDate) { todoData, error in
            if let error = error {
                print("Error fetching todo data: \(error.localizedDescription)")
            } else {
                if let todoData = todoData {
                    print("Fetched todo data: \(todoData)")
                    self.todos = todoData["todos"] as? [[String: Any]] ?? []
                    self.tableView.reloadData()
                } else {
                    print("Todo data nil")
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = MySpecialColors.Gray1
        view.addSubview(dateStack)
        view.addSubview(dateView)
        [calendarButton, editDate].forEach {
            dateStack.addArrangedSubview($0)
        }
        
        // TextField Setup
        textField = UITextField()
        textField.placeholder = "할 일을 입력하세요"
        textField.borderStyle = .none
        textField.delegate = self
        view.addSubview(textField)
        
        // Underline Setup
        underline = UIView()
        underline.backgroundColor = MySpecialColors.Gray2
        view.addSubview(underline)
        
        // Save Button Setup
        saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(named: "add-plus-circle"), for: .normal)
        saveButton.tintColor = MySpecialColors.MainColor
        view.addSubview(saveButton)
        
        // ImageView Setup
        imageView = UIImageView(image: UIImage(named: "Group 591"))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
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
        
        dateView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(95)
            make.width.equalTo(104)
            make.height.equalTo(30)
            make.trailing.equalToSuperview().inset(24)
        }
        dateStack.snp.makeConstraints { make in
            make.top.equalTo(view).offset(100)
            make.trailing.equalTo(saveButton)
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
            make.top.equalTo(editDate.snp.bottom).offset(20)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(textFieldStack.snp.top).offset(-20)
        }
    }
    
    // MARK: - Actions Setup
    func setupActions() {
        saveButton.addTarget(self, action: #selector(saveToDo), for: .touchUpInside)
    }
    
    // Edit Date
    private func setupEditDateTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editDateTapped))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(editDateTapped))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(editDateTapped))
        editDate.addGestureRecognizer(tapGesture)
        calendarButton.addGestureRecognizer(tapGesture2)
        dateView.addGestureRecognizer(tapGesture3)
    }
    
    // MARK: - Actions
    @objc private func editDateTapped() {
        print("taptap")
        showCalendarPopup()
    }
    
    private func showCalendarPopup() {
        let popupCalendarVC = ToDoPopupCalendarViewController()
        popupCalendarVC.didSelectDate = { [weak self] selectedDate, formattedDate in
            DispatchQueue.main.async {
                self?.editDate.text = formattedDate
                self?.selectedDate = selectedDate
                self?.fetchTodoData(for: selectedDate) { todoData, error in
                    if let error = error {
                        print("Error fetching todo data: \(error.localizedDescription)")
                    } else {
                        if let todoData = todoData {
                            print("Fetched todo data: \(todoData)")
                            self?.todos = todoData["todos"] as? [[String: Any]] ?? []
                            self?.tableView.reloadData()
                        } else {
                            print("Todo data nil")
                        }
                    }
                }
            }
        }
        
        popupCalendarVC.modalPresentationStyle = .overCurrentContext
        present(popupCalendarVC, animated: true, completion: nil)
    }
    
    // MARK: - 저장
    @objc func saveToDo() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자가 인증되지 않았습니다.")
            return
        }
        
        let todoText = textField.text ?? ""
        
        guard !todoText.isEmpty else {
            print("할 일 텍스트가 비어있습니다.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: selectedDate)
        
        let todoData = [
            "todoText": todoText,
            "success": false
        ] as [String : Any]
        
        addTodoToFirestore(uid: uid, day: day, todoData: todoData) { error in
            if let error = error {
                print("Error add todo \(error.localizedDescription)")
            } else {
                print("Todo add successfully")
                self.fetchTodoData(for: self.selectedDate) { todoData, error in
                    if let error = error {
                        print("Error fetching todo data: \(error.localizedDescription)")
                    } else {
                        if let todoData = todoData {
                            print("Fetched todo data: \(todoData)")
                            self.todos = todoData["todos"] as? [[String: Any]] ?? []
                            self.tableView.reloadData()
                        } else {
                            print("Todo data nil")
                        }
                    }
                }
                self.textField.text = ""
            }
        }
    }
    
    // MARK: - Firebase Firestore Data Fetch
    func fetchTodoData(for date: Date, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자가 인증되지 않았습니다.")
            completion(nil, nil)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: date)
        
        let db = Firestore.firestore()
        let docRef = db.collection("user-info").document(uid).collection("todo-list").document(day)
        
        docRef.getDocument { document, error in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                completion(document.data(), nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func addTodoToFirestore(uid: String, day: String, todoData: [String: Any], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("user-info").document(uid).collection("todo-list").document(day)
        
        docRef.updateData([
            "todos": FieldValue.arrayUnion([todoData])
        ]) { error in
            if let error = error {
                if (error as NSError).code == FirestoreErrorCode.notFound.rawValue {
                    docRef.setData([
                        "todos": [todoData]
                    ]) { error in
                        completion(error)
                    }
                } else {
                    completion(error)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - TableView DataSource and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        
        let todo = todos[indexPath.row]
        let todoText = todo["todoText"] as? String ?? ""
        let success = todo["success"] as? Bool ?? false
        
        cell.todoLabel.text = todoText
        cell.successButton.isSelected = success
        
        // deleteButtonAction 설정
        cell.deleteButtonAction = { [weak self] in
            self?.deleteButtonAction(at: indexPath)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = todos[indexPath.row]
        let todoText = todo["todoText"] as? String ?? ""
        let alertController = UIAlertController(title: "할 일 편집", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = todoText
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            if let updatedText = alertController.textFields?.first?.text, !updatedText.isEmpty {
                self?.updateTodoText(at: indexPath, with: updatedText)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func toggleTodoSuccess(at indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자가 인증되지 않았습니다.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: selectedDate)
        
        var todo = todos[indexPath.row]
        let success = todo["success"] as? Bool ?? false
        todo["success"] = !success
        todos[indexPath.row] = todo
        
        let db = Firestore.firestore()
        let docRef = db.collection("user-info").document(uid).collection("todo-list").document(day)
        
        docRef.updateData([
            "todos": todos
        ]) { error in
            if let error = error {
                print("Error update: \(error.localizedDescription)")
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func updateTodoText(at indexPath: IndexPath, with newText: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자가 인증되지 않았습니다.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: selectedDate)
        
        todos[indexPath.row]["todoText"] = newText
        
        let db = Firestore.firestore()
        let docRef = db.collection("user-info").document(uid).collection("todo-list").document(day)
        
        docRef.updateData([
            "todos": todos
        ]) { error in
            if let error = error {
                print("Error update: \(error.localizedDescription)")
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    // MARK: - Delete Todo Item
    func deleteButtonAction(at indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자가 인증되지 않았습니다.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: selectedDate)
        
        guard indexPath.row < todos.count else {
            print("Index out of range")
            return
        }
        
        tableView.beginUpdates()
        todos.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        let db = Firestore.firestore()
        let docRef = db.collection("user-info").document(uid).collection("todo-list").document(day)
        
        docRef.updateData([
            "todos": todos
        ]) { error in
            if let error = error {
                print("Error delete todo item: \(error.localizedDescription)")
                self.fetchTodoData(for: self.selectedDate) { todoData, error in
                    if let error = error {
                        print("Error fetching todo data: \(error.localizedDescription)")
                    } else {
                        if let todoData = todoData {
                            print("Fetched todo data: \(todoData)")
                            self.todos = todoData["todos"] as? [[String: Any]] ?? []
                            self.tableView.reloadData()
                        } else {
                            print("Todo data nil")
                        }
                    }
                }
            } else {
                print("item delete successfully")
            }
        }
    }
    
    // MARK: - Keyboard Handling
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.textFieldStack.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-keyboardHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.textFieldStack.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            }
            self.view.layoutIfNeeded()
        }
    }
}

class ToDoTableViewCell: UITableViewCell {
    
    var todoLabel: UILabel!
    var successButton: UIButton!
    var deleteButton: UIButton!
    var successButtonAction: (() -> Void)?
    var deleteButtonAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = MySpecialColors.Gray1
        
        todoLabel = UILabel()
        todoLabel.font = UIFont.pretendard(style: .regular, size: 14)
        todoLabel.textColor = MySpecialColors.Gray4
        contentView.addSubview(todoLabel)
        
        successButton = UIButton(type: .system)
        successButton.setImage(UIImage(systemName: "check-circle"), for: .normal)
        successButton.tintColor = MySpecialColors.MainColor
        contentView.addSubview(successButton)
        
        deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = MySpecialColors.Gray4
        contentView.addSubview(deleteButton)
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        todoLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(20)
            make.centerY.equalTo(contentView)
        }
        
        successButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-60)
            make.centerY.equalTo(contentView)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-100)
            make.centerY.equalTo(contentView)
        }
    }
    
    // MARK: - Actions Setup
    private func setupActions() {
        successButton.addTarget(self, action: #selector(successButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func successButtonTapped() {
        successButtonAction?()
    }
    
    @objc private func deleteButtonTapped() {
        deleteButtonAction?()
    }
}
