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
import SnapKit

class EditMyPageViewController: UIViewController {
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupContent()
        setupNickName()
        setupSchedule()
        setupFocusTime()
        setupEditDateTapGesture()
        
        fetchUserData()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: editNickName)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Contents
    
    // Profile Image
    private let rimoMessage: UILabel = {
        let label = UILabel()
        label.text = "나를 대표할 리모를 선택해 주세요"
        label.font = UIFont.pretendard(style: .regular, size: 12)
        label.textColor = MySpecialColors.Black
        return label
    }()
    private let changeProfile: UIButton = {
        let button = UIButton()
            button.setImage(UIImage(named: "Group 5"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(nil, action: #selector(changeProfileButtonTapped(_:)), for: .touchUpInside)
            return button
    }()
    private let plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "add-plus-circle")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.MainColor
        button.layer.cornerRadius = 20
        button.backgroundColor = MySpecialColors.Gray1
        button.addTarget(nil, action: #selector(changeProfileButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    // NickName
    private let editNickName: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.pretendard(style: .regular, size: 14)
        textField.textColor = MySpecialColors.Gray4
        textField.tintColor = MySpecialColors.MainColor
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.clearButtonMode = .whileEditing
        
        let placeholderText = "닉네임을 입력해 주세요"
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: MySpecialColors.Gray3
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        return textField
    }()
    private let tapGesture = UITapGestureRecognizer(target: EditMyPageViewController.self, action: #selector(dismissKeyboard))
    
    private let nickNameLine: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray3
        return view
    }()
    private let nameDoubleCheckButton: UIButton = {
        let button = TabButtonUIFactory.doubleCheckButton(buttonTitle: "중복 확인", textColor: MySpecialColors.MainColor, cornerRadius: 12, backgroundColor: MySpecialColors.Gray1)
        button.titleLabel?.font = UIFont.pretendard(style: .bold, size: 12)
        button.addTarget(nil, action: #selector(duplicateCheckButtonTapped), for: .touchUpInside)
        return button
    }()
    private let nickNameErrorMessage: UILabel = {
        let label = UILabel()
        label.text = "닉네임은 8자까지만 입력 가능합니다."
        label.font = UIFont.pretendard(style: .regular, size: 10)
        label.textColor = MySpecialColors.Red
        label.isHidden = true
        return label
    }()
    
    // FocusTime
    private let focusTimeMessage: UILabel = {
        let label = UILabel()
        label.text = "목표 집중 시간"
        label.font = UIFont.pretendard(style: .semiBold, size: 12)
        label.textColor = MySpecialColors.Black
        return label
    }()
    private let focusTimeBox: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray1
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = MySpecialColors.Gray2.cgColor
        return view
    }()
    private let focusTimeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    private let editFocusTime: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.pretendard(style: .bold, size: 30)
        textField.textColor = MySpecialColors.Black
        textField.tintColor = .clear
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.clearButtonMode = .never
        textField.textAlignment = .right
        
        let placeholderText = "24"
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: MySpecialColors.Gray4
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        return textField
    }()
    private let hours: [Int] = Array(1...24)
    private let focusTimePicker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        return pickerView
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        label.font = UIFont.pretendard(style: .semiBold, size: 20)
        label.textColor = MySpecialColors.Gray3
        return label
    }()
    
    // Schedule
    private let scheduleLabel: UILabel = {
        let label = UILabel()
        label.text = "일정"
        label.font = UIFont.pretendard(style: .semiBold, size: 12)
        label.textColor = MySpecialColors.Black
        return label
    }()
    private let editScheduleName: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.pretendard(style: .regular, size: 14)
        textField.textColor = MySpecialColors.Gray4
        textField.tintColor = MySpecialColors.MainColor
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.clearButtonMode = .whileEditing
        
        let placeholderText = "일정 이름을 입력해 주세요"
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: MySpecialColors.Gray3
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        return textField
    }()
    private let scheduleLine: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray3
        return view
    }()
    
    // Date
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜"
        label.font = UIFont.pretendard(style: .semiBold, size: 12)
        label.textColor = MySpecialColors.Black
        return label
    }()
    private let includeTodayLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 포함"
        label.font = UIFont.pretendard(style: .regular, size: 12)
        label.textColor = MySpecialColors.Black
        return label
    }()
    private let includeTodayButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "square")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.Gray3
        button.addTarget(nil, action: #selector(includeTodayButtonTapped), for: .touchUpInside)
        return button
    }()
    private let calendarButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendar"), for: .normal)
        
        return button
    }()
    private let editDate:  UITextField = {
        let textField = UITextField()
        textField.font = UIFont.pretendard(style: .regular, size: 14)
        textField.textColor = MySpecialColors.Gray4
        textField.tintColor = .clear
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.clearButtonMode = .never
        textField.textAlignment = .left
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
//        let currentDate = Date()
//        textField.text = dateFormatter.string(from: currentDate)
        
        return textField
    }()
    private let dateLine: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray3
        return view
    }()
    // Confirm
    private let confirmButton: UIButton = {
        let button = TabButtonUIFactory.tapButton(buttonTitle: "확인", textColor: .white , cornerRadius: 22, backgroundColor: MySpecialColors.MainColor)
        button.titleLabel?.font = UIFont.pretendard(style: .semiBold, size: 16)
        button.addTarget(nil, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = MySpecialColors.Gray1
        self.title = "프로필 수정"
    }
    
    private func setupContent() {
        
        [rimoMessage, changeProfile, plusButton, editNickName, nameDoubleCheckButton, nickNameLine, nickNameErrorMessage, focusTimeMessage, focusTimeBox, focusTimeStack, scheduleLabel, editScheduleName, scheduleLine, dateLabel, includeTodayLabel, includeTodayButton, calendarButton, editDate, dateLine, confirmButton].forEach {
            view.addSubview($0)
        }
        
        [editFocusTime, timeLabel].forEach {
            focusTimeStack.addArrangedSubview($0)
        }
        
        rimoMessage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(118)
            make.leading.equalToSuperview().offset(110.5)
            make.trailing.equalToSuperview().inset(110.5)
        }
        
        changeProfile.snp.makeConstraints { make in
            make.top.equalTo(rimoMessage.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(146.5)
            make.trailing.equalToSuperview().inset(146.5)
        }
        
        plusButton.snp.makeConstraints { make in
            make.bottom.equalTo(changeProfile.snp.bottom)
            make.trailing.equalTo(changeProfile.snp.trailing)
        }
        
        // NickName
        editNickName.snp.makeConstraints { make in
            make.top.equalTo(changeProfile.snp.bottom).offset(46)
            make.leading.equalToSuperview().offset(35)
        }
        nickNameLine.snp.makeConstraints { make in
            make.top.equalTo(editNickName.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(258)
            make.height.equalTo(0.8)
        }
        nameDoubleCheckButton.snp.makeConstraints { make in
            make.centerY.equalTo(editNickName)
            make.leading.equalTo(nickNameLine.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }
        nickNameErrorMessage.snp.makeConstraints { make in
            make.top.equalTo(nickNameLine.snp.bottom).offset(9)
            make.leading.equalTo(nickNameLine.snp.leading)
        }
        
        // FocusTime
        focusTimeMessage.snp.makeConstraints { make in
            make.top.equalTo(editNickName.snp.bottom).offset(56)
            make.leading.equalToSuperview().offset(30)
        }
        focusTimeBox.snp.makeConstraints { make in
            make.top.equalTo(focusTimeMessage.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(345)
            make.height.equalTo(54)
        }
        focusTimeStack.snp.makeConstraints { make in
            make.centerX.equalTo(focusTimeBox)
            make.centerY.equalTo(focusTimeBox)
        }
        editFocusTime.snp.makeConstraints { make in
            make.width.equalTo(38)
        }
        
        // Schedule
        scheduleLabel.snp.makeConstraints { make in
            make.top.equalTo(editFocusTime.snp.bottom).offset(56)
            make.leading.equalToSuperview().offset(35)
        }
        editScheduleName.snp.makeConstraints { make in
            make.top.equalTo(scheduleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(35)
        }
        scheduleLine.snp.makeConstraints { make in
            make.top.equalTo(editScheduleName.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(323)
            make.height.equalTo(0.8)
        }
        
        // Date
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(scheduleLine.snp.bottom).offset(46)
            make.leading.equalTo(scheduleLine)
        }
        includeTodayLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.trailing.equalTo(includeTodayButton.snp.trailing).inset(30)
        }
        includeTodayButton.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.trailing.equalToSuperview().inset(30)
        }
        calendarButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(35)
        }
        editDate.snp.makeConstraints { make in
            make.centerY.equalTo(calendarButton)
            make.leading.equalTo(calendarButton.snp.trailing).offset(8)
        }
        dateLine.snp.makeConstraints { make in
            make.top.equalTo(editDate.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(323)
            make.height.equalTo(0.8)
        }
        
        // Confirm
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(345)
            make.height.equalTo(46)
        }
    }
    
    // MARK: - Func Firbase
    private func fetchUserData() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
    
            Firestore.firestore().collection("user-info").document(uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    // Update TextField
                    self.editNickName.text = data?["nickname"] as? String ?? ""
                    self.editScheduleName.text = data?["d-day-title"] as? String ?? ""
                    
                    // Update Date
                    if let timestamp = data?["d-day-date"] as? Timestamp {
                        let date = timestamp.dateValue() // Convert Timestamp to Date
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                        self.editDate.text = dateFormatter.string(from: date)
                    } else {
                        let currentDate = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                        self.editDate.text = dateFormatter.string(from: currentDate)
                    }
                    
                    // Update FocusTime
                    self.editFocusTime.text = data?["target-time"] as? String ?? ""
    
                    // Update ProfileImage
                    if let profileImageName = data?["profile-image"] as? String, !profileImageName.isEmpty {
                        DispatchQueue.main.async {
                            self.changeProfile.setImage(UIImage(named: profileImageName) ?? UIImage(named: "Group 5"), for: .normal)
                            self.changeProfile.imageView?.contentMode = .scaleAspectFit
                        }
                    } else {
                        self.changeProfile.setImage(UIImage(named: "Group 1"), for: .normal)
                        self.changeProfile.imageView?.contentMode = .scaleAspectFit
                    }
                    // Update includeTodayButton state
                    if let isTodayIncluded = data?["isTodayIncluded"] as? Bool {
                        DispatchQueue.main.async {
                            self.isTodayIncluded = isTodayIncluded
                            if isTodayIncluded {
                                if let image = UIImage(named: "square-check")?.withRenderingMode(.alwaysTemplate) {
                                    self.includeTodayButton.setImage(image, for: .normal)
                                    self.includeTodayButton.tintColor = MySpecialColors.MainColor
                                }
                            } else {
                                if let image = UIImage(named: "square")?.withRenderingMode(.alwaysTemplate) {
                                    self.includeTodayButton.setImage(image, for: .normal)
                                    self.includeTodayButton.tintColor = MySpecialColors.Gray3
                                }
                            }
                        }
                    }
                } else {
                    // Handle case where document doesn't exist or data is empty
                    self.editScheduleName.placeholder = "일정 이름을 입력해 주세요"
                }
            }
    }
    
    // MARK: - Func
    
    // Edit Profile
    private var isNicknameAvailable: Bool = false
    @objc private func changeProfileButtonTapped(_ sender: UIButton) {
        let selectMarimoVC = SelectMarimoViewController()
        selectMarimoVC.didSelectImage = { [weak self] imageName in
            guard let self = self else { return }
            let image = UIImage(named: imageName)
            self.changeProfile.setImage(image, for: .normal)
            self.selectedProfileImageName = imageName
        }
        selectMarimoVC.modalPresentationStyle = .overCurrentContext
        present(selectMarimoVC, animated: true, completion: nil)
    }
    
    // Edit NickName
    private var isNickNameEdited = false
    
    private func setupNickName() {
        editNickName.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: UITextField.textDidChangeNotification, object: editNickName)
        nameDoubleCheckButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let nickname = editNickName.text, !nickname.isEmpty {
            isNickNameEdited = true
        }
    }
    @objc private func duplicateCheckButtonTapped() {
        guard let nickname = editNickName.text, !nickname.isEmpty else {
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
                self.isNicknameAvailable = true
            } else {
                let alert = UIAlertController(title: "Unavailable", message: "이 닉네임은 이미 사용 중입니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.isNicknameAvailable = false
            }
        }
    }
    
    // Edit Schedule
    private func setupSchedule() {
        editScheduleName.delegate = self
    }
    
    // Edit focusTime
    private func setupFocusTime() {
        editFocusTime.delegate = self
        editFocusTime.inputView = focusTimePicker
        focusTimePicker.delegate = self
        focusTimePicker.dataSource = self
    }
    
    // Edit Date
    private func setupEditDateTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editDateTapped))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(editDateTapped))
        editDate.addGestureRecognizer(tapGesture)
        calendarButton.addGestureRecognizer(tapGesture2)
    }
    @objc private func editDateTapped() {
        print("taptap")
        showCalendarPopup()
    }
    private func showCalendarPopup() {
        let popupCalendarVC = PopupCalendarViewController()
        popupCalendarVC.didSelectDate = { [weak self] selectedDate in
            DispatchQueue.main.async {
                self?.editDate.text = selectedDate
            }
        }
        popupCalendarVC.modalPresentationStyle = .overCurrentContext
        present(popupCalendarVC, animated: true, completion: nil)
    }
    // Toggle IncludeToday
    var isTodayIncluded = false
    @objc private func includeTodayButtonTapped() {
        if isTodayIncluded {
            if let image = UIImage(named: "square")?.withRenderingMode(.alwaysTemplate) {
                includeTodayButton.setImage(image, for: .normal)
                includeTodayButton.tintColor = MySpecialColors.Gray3
            }
        } else {
            if let image = UIImage(named: "square-check")?.withRenderingMode(.alwaysTemplate) {
                includeTodayButton.setImage(image, for: .normal)
                includeTodayButton.tintColor = MySpecialColors.MainColor
            }
        }
        isTodayIncluded.toggle()
    }
    
    // Confirm
    var selectedFocusTime: Int?
    var selectedProfileImageName: String?
    
    @objc private func confirmButtonTapped() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let userDocRef = Firestore.firestore().collection("user-info").document(uid)
        var updateData: [String: Any] = [:]
        
        if let imageName = selectedProfileImageName {
            updateData["profile-image"] = imageName
        }
        if let nickname = editNickName.text, !nickname.isEmpty {
            updateData["nickname"] = nickname
            
            // 닉네임이 수정된 경우에만 중복 체크
            if isNickNameEdited {
                Firestore.firestore().collection("user-info").whereField("nickname", isEqualTo: nickname).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("닉네임 확인 중 오류 발생: \(error.localizedDescription)")
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    if let documents = querySnapshot?.documents, documents.isEmpty {
                        // 중복된 닉네임이 없으면 Firestore에 저장
                        self.saveDataToFirestore(userDocRef: userDocRef, updateData: updateData)
                    } else {
                        // 중복된 닉네임이 있으면 알림 표시
                        let alert = UIAlertController(title: "Unavailable", message: "이 닉네임은 이미 사용 중입니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                // 닉네임이 수정되지 않은 경우에도 Firestore에 저장
                self.saveDataToFirestore(userDocRef: userDocRef, updateData: updateData)
            }
        }

        if let selectedFocusTime = selectedFocusTime {
            updateData["target-time"] = "\(selectedFocusTime)"
        }
        if let scheduleName = editScheduleName.text, !scheduleName.isEmpty {
               updateData["d-day-title"] = scheduleName
        }
        if let dateString = editDate.text, let selectedDate = dateFormatter.date(from: dateString) {
            var targetDate = selectedDate
            if isTodayIncluded {
                targetDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            }
            // Calculate D-day
            let daysRemaining = calculateDaysRemaining(to: targetDate)
            let dDayMessage = "D-\(daysRemaining)"
            // Update D-Day
            updateData["d-day-date"] = selectedDate
            updateData["d-day"] = dDayMessage
            
            // TodayIncluded
            let isTodayIncluded = self.isTodayIncluded
            updateData["isTodayIncluded"] = isTodayIncluded
            
            userDocRef.updateData(updateData) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()
    private func calculateDaysRemaining(to date: Date) -> Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: now, to: targetDate)
        return components.day ?? 0
    }
    
    private func saveDataToFirestore(userDocRef: DocumentReference, updateData: [String: Any]) {
        // Update Firestore
        userDocRef.updateData(updateData) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}

// MARK: - TextField
extension EditMyPageViewController: UITextFieldDelegate {
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
        textField.textColor = MySpecialColors.Gray4
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == editNickName {
            if textField.text?.isEmpty ?? true {
                textField.placeholder = "닉네임을 입력해 주세요"
            }
        } else if textField == editScheduleName {
            if textField.text?.isEmpty ?? true {
                textField.placeholder = "일정 이름을 입력해 주세요"
            }
        }
    }
    @objc private func textFieldDidChange(_ notification: Notification) {
        guard let textField = notification.object as? UITextField else {
            return
        }
        // Edit NickName
        if textField == editNickName {
            if let text = textField.text, text.count > 8 {
                textField.text = String(text.prefix(8))
                nickNameErrorMessage.isHidden = false
            } else {
                nickNameErrorMessage.isHidden = true
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == editFocusTime {
            return false
        }
        return true
    }
}

// MARK: - PickerView
extension EditMyPageViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Edit FocusTime
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hours.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(hours[row])"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedHour = hours[row]
        editFocusTime.text = "\(selectedHour)"
        selectedFocusTime = selectedHour
    }
}

    
//    private let editMypageTitle: UILabel = {
//        let text = UILabel()
//        text.text = "editMypage"
//        text.font = UIFont.boldSystemFont(ofSize: 24)
//        return text
//    }()
//    
//    private let saveButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("", for: .normal)
//        button.setImage(UIImage(systemName: "gear"), for: .normal)
//        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    private let nicknameTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Enter your nickname"
//        textField.borderStyle = .roundedRect
//        return textField
//    }()
//    
//    private let duplicateCheckButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Check", for: .normal)
//        button.addTarget(self, action: #selector(duplicateCheckButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    private let profileImageView = UIImageView()
//    private let dDayTitleTextField = UITextField()
//    private let dDayTextField = UITextField()
//    private let targetTimeTextField = UITextField()
//    
//    private let datePicker: UIDatePicker = {
//        let picker = UIDatePicker()
//        picker.datePickerMode = .date
//        picker.locale = Locale(identifier: "ko_KR")
//        return picker
//    }()
//    
//    private let todayCheckbox: UISwitch = {
//        let checkbox = UISwitch()
//        checkbox.isOn = true
//        checkbox.addTarget(self, action: #selector(todayCheckboxChanged), for: .valueChanged)
//        return checkbox
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        view.addSubview(saveButton)
//        view.addSubview(editMypageTitle)
//        view.addSubview(nicknameTextField)
//        view.addSubview(duplicateCheckButton)
//        view.addSubview(profileImageView)
//        view.addSubview(dDayTitleTextField)
//        view.addSubview(dDayTextField)
//        view.addSubview(targetTimeTextField)
//        
//        setupConstraints()
//        setupProfileImageView()
//        fetchUserData()
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dDayTextFieldTapped))
//        dDayTextField.addGestureRecognizer(tapGesture)
//        dDayTextField.isUserInteractionEnabled = true
//        
//        dDayTextField.inputView = datePicker
//        
//        view.addSubview(todayCheckbox)
//        todayCheckbox.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            todayCheckbox.topAnchor.constraint(equalTo: dDayTextField.bottomAnchor, constant: 8),
//            todayCheckbox.leadingAnchor.constraint(equalTo: dDayTextField.leadingAnchor),
//        ])
//    }
//    
//    private func setupConstraints() {
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        editMypageTitle.translatesAutoresizingMaskIntoConstraints = false
//        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
//        duplicateCheckButton.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        dDayTitleTextField.translatesAutoresizingMaskIntoConstraints = false
//        dDayTextField.translatesAutoresizingMaskIntoConstraints = false
//        targetTimeTextField.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            saveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
//            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            saveButton.widthAnchor.constraint(equalToConstant: 40),
//            saveButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            editMypageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            editMypageTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            
//            nicknameTextField.topAnchor.constraint(equalTo: editMypageTitle.bottomAnchor, constant: 20),
//            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            nicknameTextField.trailingAnchor.constraint(equalTo: duplicateCheckButton.leadingAnchor, constant: -10),
//            nicknameTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            duplicateCheckButton.centerYAnchor.constraint(equalTo: nicknameTextField.centerYAnchor),
//            duplicateCheckButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            duplicateCheckButton.widthAnchor.constraint(equalToConstant: 80),
//            duplicateCheckButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            profileImageView.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 20),
//            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            profileImageView.widthAnchor.constraint(equalToConstant: 100),
//            profileImageView.heightAnchor.constraint(equalToConstant: 100),
//            
//            dDayTitleTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
//            dDayTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            dDayTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            dDayTitleTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            dDayTextField.topAnchor.constraint(equalTo: dDayTitleTextField.bottomAnchor, constant: 20),
//            dDayTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            dDayTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            dDayTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            targetTimeTextField.topAnchor.constraint(equalTo: dDayTextField.bottomAnchor, constant: 20),
//            targetTimeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            targetTimeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            targetTimeTextField.heightAnchor.constraint(equalToConstant: 40),
//        ])
//        
//        nicknameTextField.borderStyle = .roundedRect
//        dDayTitleTextField.borderStyle = .roundedRect
//        dDayTextField.borderStyle = .roundedRect
//        targetTimeTextField.borderStyle = .roundedRect
//    }
//    
//    private func setupProfileImageView() {
//        profileImageView.image = UIImage(named: "profileImage")
//        profileImageView.isUserInteractionEnabled = true
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.layer.cornerRadius = 50
//        profileImageView.clipsToBounds = true
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
//        profileImageView.addGestureRecognizer(tapGesture)
//    }
//    
//    @objc private func profileImageTapped() {
//        let imagePickerVC = ImagePickerViewController()
//        imagePickerVC.delegate = self
//        present(imagePickerVC, animated: true, completion: nil)
//    }
//    
//    @objc private func duplicateCheckButtonTapped() {
//        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
//            let alert = UIAlertController(title: "Error", message: "닉네임을 입력해주세요.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
//        
//        Firestore.firestore().collection("user-info").whereField("nickname", isEqualTo: nickname).getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("닉네임 확인 중 오류 발생: \(error.localizedDescription)")
//                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                return
//            }
//            
//            if let documents = querySnapshot?.documents, documents.isEmpty {
//                let alert = UIAlertController(title: "Available", message: "이 닉네임을 사용할 수 있습니다.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            } else {
//                let alert = UIAlertController(title: "Unavailable", message: "이 닉네임은 이미 사용 중입니다.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
//    
//    
//    private func fetchUserData() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        Firestore.firestore().collection("user-info").document(uid).getDocument { (document, error) in
//            if let document = document, document.exists {
//                let data = document.data()
//                self.nicknameTextField.text = data?["nickname"] as? String ?? ""
//                self.dDayTitleTextField.text = data?["d-day-title"] as? String ?? ""
//                self.dDayTextField.text = data?["d-day"] as? String ?? ""
//                self.targetTimeTextField.text = data?["target-time"] as? String ?? ""
//                
//                if let profileImageURLString = data?["profile-image"] as? String, !profileImageURLString.isEmpty {
//                    if let profileImageURL = URL(string: profileImageURLString) {
//                        URLSession.shared.dataTask(with: profileImageURL) { (data, response, error) in
//                            if let data = data {
//                                DispatchQueue.main.async {
//                                    self.profileImageView.image = UIImage(data: data)
//                                }
//                            }
//                        }.resume()
//                    }
//                } else {
//                    self.profileImageView.image = UIImage(named: "Group 1")
//                }
//                
//                if self.nicknameTextField.text == "" {
//                    self.nicknameTextField.placeholder = "Enter your nickname"
//                }
//                if self.dDayTitleTextField.text == "" {
//                    self.dDayTitleTextField.placeholder = "Enter D-day title"
//                }
//                if self.dDayTextField.text == "" {
//                    self.dDayTextField.placeholder = "Enter D-day"
//                }
//                if self.targetTimeTextField.text == "" {
//                    self.targetTimeTextField.placeholder = "Enter target time"
//                }
//            } else {
//                self.nicknameTextField.placeholder = "Enter your nickname"
//                self.dDayTitleTextField.placeholder = "Enter D-day title"
//                self.dDayTextField.placeholder = "Enter D-day"
//                self.targetTimeTextField.placeholder = "Enter target time"
//            }
//        }
//    }
//    
//    @objc private func saveButtonTapped() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        var userDataToUpdate: [String: Any] = [:]
//        
//        if let nickname = nicknameTextField.text, !nickname.isEmpty {
//            userDataToUpdate["nickname"] = nickname
//        }
//        
//        if let dDayTitle = dDayTitleTextField.text, !dDayTitle.isEmpty {
//            userDataToUpdate["d-day-title"] = dDayTitle
//        }
//        
//        if let dDay = dDayTextField.text, !dDay.isEmpty {
//            userDataToUpdate["d-day"] = dDay
//        }
//        
//        if let targetTime = targetTimeTextField.text, !targetTime.isEmpty {
//            userDataToUpdate["target-time"] = targetTime
//        }
//        
//        if let profileImage = profileImageView.image, let imageData = profileImage.jpegData(compressionQuality: 0.5) {
//            let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
//            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
//                if let error = error {
//                    print("Error uploading profile image: \(error.localizedDescription)")
//                    return
//                }
//
//                storageRef.downloadURL { (url, error) in
//                    guard let downloadURL = url else {
//                        print("Error fetching download URL: \(error?.localizedDescription ?? "Unknown error")")
//                        return
//                    }
//
//                    userDataToUpdate["profile-image"] = downloadURL.absoluteString
//                    
//                    if !userDataToUpdate.isEmpty {
//                        Firestore.firestore().collection("user-info").document(uid).updateData(userDataToUpdate) { error in
//                            if let error = error {
//                                print("사용자 데이터 업데이트 오류: \(error.localizedDescription)")
//                            } else {
//                                print("사용자 데이터가 성공적으로 업데이트되었습니다.")
//                            }
//                        }
//                    }
//                }
//            }
//        } else {
//            if !userDataToUpdate.isEmpty {
//                Firestore.firestore().collection("user-info").document(uid).updateData(userDataToUpdate) { error in
//                    if let error = error {
//                        print("사용자 데이터 업데이트 오류: \(error.localizedDescription)")
//                    } else {
//                        print("사용자 데이터가 성공적으로 업데이트되었습니다.")
//                    }
//                }
//            } else {
//                print("No data to update.")
//            }
//        }
//    }
//    
//    @objc private func todayCheckboxChanged() {
//        if todayCheckbox.isOn {
//            dDayTextField.text = getCurrentDateString()
//        } else {
//            dDayTextField.text = ""
//        }
//    }
//    
//    private func getCurrentDateString() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.string(from: Date())
//    }
//    
//    @objc private func dDayTextFieldTapped() {
//        dDayTextField.becomeFirstResponder()
//    }
//}
//
//extension EditMyPageViewController: ImagePickerDelegate {
//    func didSelectImage(named imageName: String) {
//        profileImageView.image = UIImage(named: imageName)
//        
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let userRef = Firestore.firestore().collection("user-info").document(uid)
//        userRef.updateData(["profile-image": imageName]) { error in
//            if let error = error {
//                print("프로필 이미지 업데이트 중 오류 발생: \(error.localizedDescription)")
//            } else {
//                print("프로필 이미지가 업데이트되었습니다.")
//            }
//        }
//    }
//}
//
//protocol ImagePickerDelegate: AnyObject {
//    func didSelectImage(named imageName: String)
//}
//
//class ImagePickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    weak var delegate: ImagePickerDelegate?
//    
//    private let imageNames = ["Group 2", "Group 3", "Group 4"]
//    private let collectionView: UICollectionView
//    
//    init() {
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 100, height: 100)
//        layout.minimumInteritemSpacing = 20
//        layout.minimumLineSpacing = 20
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        
//        super.init(nibName: nil, bundle: nil)
//        
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        view.addSubview(collectionView)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return imageNames.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        let imageView = UIImageView(image: UIImage(named: imageNames[indexPath.item]))
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 50
//        cell.contentView.addSubview(imageView)
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
//            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
//            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
//        ])
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedImageName = imageNames[indexPath.item]
//        delegate?.didSelectImage(named: selectedImageName)
//        dismiss(animated: true, completion: nil)
//    }
//}
