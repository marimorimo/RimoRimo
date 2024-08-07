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
    
    let tapGestureView: UIView = {
        let tapGestureView = UIView()
        return tapGestureView
    }()
    
    // PickDate Setup
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
    
    let emptyTodoView: UIView = {
        let emptyTodoView = UIView()
        emptyTodoView.backgroundColor = .blue
        return emptyTodoView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupActions()
        setupEditDateTapGesture()
        setUpKeyboardHideTapGesture()
        
        addSnapshotListener(for: selectedDate)
        fetchDateData()
        
        // Keyboard event observers
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
        view.addSubview(tapGestureView)
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
        saveButton.contentHorizontalAlignment = .fill
        saveButton.contentVerticalAlignment = .fill
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
        tapGestureView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.bottom.equalTo(tableView.snp.top)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
        }
        
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
            make.height.equalTo(30)
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
            make.width.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(editDate.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(14)
            make.trailing.equalTo(view).offset(-16)
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
    
    //tapGesture keyboard
    private func setUpKeyboardHideTapGesture() {
        let keyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(keyboardHideTapped))
        tapGestureView.addGestureRecognizer(keyboardTapGesture)
    }
    
    // MARK: - Actions
    @objc private func editDateTapped() {
        print("taptap")
        showCalendarPopup()
    }
    
    @objc private func keyboardHideTapped() {
        print("뷰 쳤더니 키보드 내려감")
        self.view.endEditing(true)
    }
    
    private func showCalendarPopup() {
        let popupCalendarVC = ToDoPopupCalendarViewController()
        popupCalendarVC.didSelectDate = { [weak self] selectedDate, formattedDate in
            DispatchQueue.main.async {
                self?.editDate.text = formattedDate
                self?.selectedDate = selectedDate
                self?.addSnapshotListener(for: selectedDate)
            }
        }
        
        addSnapshotListener(for: selectedDate)
        popupCalendarVC.todayDate = editDate.text
        popupCalendarVC.modalPresentationStyle = .overCurrentContext
        present(popupCalendarVC, animated: true, completion: nil)
    }
    
    @objc func saveToDo() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자가 인증되지 않았습니다.")
            return
        }
        
        let todoText = textField.text ?? ""
        
        guard !todoText.isEmpty else {
            print("할 일 텍스트가 비어있습니다.") // 텍스트 필드 비어있으면 셀에 추가 안 됨 그냥 취소 됨
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: selectedDate)

        let todoData = [
            "todoText": todoText,
            "success": false
        ] as [String : Any]
        
        let docRef = Firestore.firestore()
                    .collection("user-info")
                    .document(uid)
                    .collection("todo-list")
                    .document(day)

                docRef.updateData(["todos": FieldValue.arrayUnion([todoData])]) { [weak self] error in
                        if let error = error {
                            print("Error saving ToDo: \(error.localizedDescription)")
                            docRef.setData(["todos": [todoData]]) { error2 in
                                if let error2 = error2 {
                                    print("Error saving ToDo: \(error2.localizedDescription)")
                                } else {
                                    print("ToDo가 성공적으로 저장되었습니다.")
                                    self?.textField.text = ""
                                    self?.loadTodos(for: self?.selectedDate ?? Date())
                                }
                            }
                        } else {
                            print("ToDo가 성공적으로 저장되었습니다.")
                            self?.textField.text = ""
                            self?.loadTodos(for: self?.selectedDate ?? Date())
                        }
                    }
    }
    
    @objc func saveEditedText(_ sender: UIButton) {
        guard let indexPath = editingIndexPath else { return }
        saveEditedText(at: indexPath)
    }
    
    func saveEditedText(at indexPath: IndexPath) {
        let updatedText = (tableView.cellForRow(at: indexPath) as? ToDoTableViewCell)?.textField.text ?? ""
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ToDoTableViewCell else { return }
        
        if updatedText.isEmpty {
            cell.textField.text = cell.previousText
            cell.resetContent()
            editingIndexPath = nil
            tableView.reloadRows(at: [indexPath], with: .none)
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("사용자가 인증되지 않았습니다.")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: selectedDate)

        todos[indexPath.row]["todoText"] = updatedText
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("todo-list")
            .document(day)
            .updateData(["todos": todos]) { [weak self] error in
                if let error = error {
                    print("Error updating todo text: \(error.localizedDescription)")
                } else {
                    print("Todo 텍스트가 성공적으로 업데이트되었습니다.")
                    self?.loadTodos(for: self?.selectedDate ?? Date())
                }
            }
        
        cell.resetContent()
        editingIndexPath = nil
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc func toggleButtonTapped(_ sender: UIButton) {
        guard editingIndexPath == nil else {
            return
        }
        
        let rowIndex = sender.tag
        let todo = todos[rowIndex]
        let success = todo["success"] as? Bool ?? false
        let updatedStatus = !success
        
        todos[rowIndex]["success"] = updatedStatus
        
        updateCompletionStatus(todoIndex: rowIndex, success: updatedStatus)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: rowIndex, section: 0)) as? ToDoTableViewCell {
            cell.configure(with: todos[rowIndex]["todoText"] as? String ?? "", success: updatedStatus, index: rowIndex, target: self)
        }
    }
    
    // MARK: - Keyboard Handlers
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
            
            if let editingIndexPath = editingIndexPath {
                if tableView.numberOfRows(inSection: editingIndexPath.section) > editingIndexPath.row {
                    tableView.scrollToRow(at: editingIndexPath, at: .middle, animated: true)
                }
            } else {
                textFieldStack.snp.updateConstraints { make in
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(80-keyboardHeight)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        
        textFieldStack.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
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
        
        let collectionRef = Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("todo-list")
            .document(day)
        
        self.listener = collectionRef.addSnapshotListener { [weak self] (querySnapshot, error) in
                    guard let self = self else { return }
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        self.todos.removeAll()
                        if let document = querySnapshot, document.exists {
                            var todoData = document.data()
                            self.todos.append(contentsOf: todoData?["todos"] as? [[String: Any]] ?? [])
                        }
                        self.tableView.reloadData()
                    }
                }
    }
    
    func loadTodos(for date: Date) {
        todolistArr = []
        addSnapshotListener(for: selectedDate)
    }
    
    func updateCompletionStatus(todoIndex: Int, success: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: selectedDate)
        
        var todo = todos[todoIndex]
        todo["success"] = success
        todos[todoIndex] = todo
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("todo-list")
            .document(day)
            .updateData(["todos": todos]) { [weak self] error in
                if let error = error {
                    print("Error updating completion status: \(error.localizedDescription)")
                } else {
                    print("완료 상태가 성공적으로 업데이트되었습니다.")
                    self?.loadTodos(for: self?.selectedDate ?? Date())
                }
            }
    }
    
    private func fetchDateData() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd.EEE"
        self.editDate.text = dateFormatter.string(from: currentDate)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        print("키보드 내려감")
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let indexPath = editingIndexPath {
            saveEditedText(at: indexPath)
        } else {
            saveToDo()
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("텍스트 필드 편집 시작")
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
        let todoText = todo["todoText"] as? String ?? ""
        
        let success = todo["success"] as? Bool ?? false
        cell.configure(with: todoText, success: success, index: indexPath.row, target: self)
        
        if success == false {
            todolistArr.append(todoText)
        }
        UserDefaults.shared.set(todolistArr, forKey: "\(self.selectedDate.onlyDate)")
        WidgetCenter.shared.reloadAllTimelines()

        // Cell Background color gray
        cell.backgroundColor = MySpecialColors.Gray1
        
        // Cell Selection color gray
        let bgColorView = UIView()
        bgColorView.backgroundColor = MySpecialColors.Gray1
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard editingIndexPath == nil else {
            return
        }
        
        if let previousIndexPath = editingIndexPath {
            guard let previousCell = tableView.cellForRow(at: previousIndexPath) as? ToDoTableViewCell else { return }
            previousCell.resetContent()
            tableView.reloadRows(at: [previousIndexPath], with: .none)
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ToDoTableViewCell else { return }
        let todo = todos[indexPath.row]
        guard let todoText = todo["todoText"] as? String else { return }
        cell.setEditMode(todoText: todoText, target: self)
        
        editingIndexPath = indexPath
        
        textFieldStack.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    // MARK: - Swipe to Delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 수정 모드일 때 삭제 스와이프 비활성화
        if editingIndexPath != nil {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            guard let uid = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let day = formatter.string(from: self.selectedDate)

            guard indexPath.row < todos.count else {
                print("Index out of range")
                return
            }

            self.todos.remove(at: indexPath.row)
            
            // Firestore에서 데이터를 삭제합니다.
            Firestore.firestore()
                .collection("user-info")
                .document(uid)
                .collection("todo-list")
                .document(day)
                .updateData(["todos": self.todos]) { [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        print("Error deleting todo: \(error.localizedDescription)")
                        completionHandler(false) // 삭제 실패 시
                    } else {
                        print("ToDo가 성공적으로 삭제되었습니다.")
                        completionHandler(true) // 삭제 성공 시
                        self.loadTodos(for: self.selectedDate)
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
        NotificationCenter.default.removeObserver(self)
    }
}

class ToDoTableViewCell: UITableViewCell {
    
    var toggleButton: UIButton!
    var todoTextLabel: UILabel!
    var underline: UIView!
    var textField: UITextField!
    var saveButton: UIButton!
    var previousText: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
        setupCellConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        toggleButton.setImage(nil, for: .normal)
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
    
    func configure(with todoText: String, success: Bool, index: Int, target: Any) {
        todoTextLabel.text = todoText
        toggleButton.setImage(UIImage(named: success ? "Group 583" : "Group 582"), for: .normal)
        toggleButton.tag = index
        toggleButton.addTarget(target, action: #selector(ToDoListViewController.toggleButtonTapped(_:)), for: .touchUpInside)
    }
    
    func setEditMode(todoText: String, target: Any) {
        todoTextLabel.isHidden = true
        
        textField?.removeFromSuperview()
        saveButton?.removeFromSuperview()
        
        textField = UITextField()
        textField.text = todoText
        previousText = todoText
        textField.borderStyle = .none
        textField.tag = toggleButton.tag
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = target as? UITextFieldDelegate
        contentView.addSubview(textField)
        
        saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(named: "edit-pencil-01"), for: .normal)
        
        saveButton.tintColor = MySpecialColors.MainColor
        saveButton.addTarget(target, action: #selector(ToDoListViewController.saveEditedText(_:)), for: .touchUpInside)
        saveButton.tag = toggleButton.tag
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-10)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(30)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(toggleButton.snp.trailing).offset(10)
            make.trailing.equalTo(saveButton.snp.leading).offset(-10)
            make.centerY.equalTo(contentView)
            make.height.equalTo(30)
        }
        
        textField.isUserInteractionEnabled = true
        textField.becomeFirstResponder()
        if let newPosition = textField.position(from: textField.endOfDocument, offset: 0) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition) // 텍스트 필드 활성화 시 텍스트 끝으로 커서 이동
        }
    }
    
    func resetContent() {
        textField?.removeFromSuperview()
        saveButton?.removeFromSuperview()
        todoTextLabel.isHidden = false
    }
}
