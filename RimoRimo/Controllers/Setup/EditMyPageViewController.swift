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
import WidgetKit

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
        includeButtonTapped()
        
        tapView()
        
        fetchUserData()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: editNickName)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Contents
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    // Profile Image
    private let rimoMessage: UILabel = {
        let label = UILabel()
        label.text = "나를 대표할 리모를 선택해 주세요"
        label.font = UIFont.pretendard(style: .regular, size: 12)
        label.textColor = MySpecialColors.Black
        return label
    }()
    lazy var changeProfile: UIButton = {
        let button = UIButton()
            button.setImage(UIImage(named: "Group 5"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(changeProfileButtonTapped(_:)), for: .touchUpInside)
            return button
    }()
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "add-plus-circle")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.MainColor
        button.layer.cornerRadius = 20
        button.backgroundColor = MySpecialColors.Gray1
        button.addTarget(self, action: #selector(changeProfileButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    // NickName
    private let outerNickNameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    private let innerNickNameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    private let editNickName: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.pretendard(style: .regular, size: 14)
        textField.textColor = MySpecialColors.Gray3
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
    private func alertTextLabel(alertText: String, textColor: UIColor) -> UILabel {
        let text = UILabel()
        text.text = alertText
        text.textColor = textColor
        text.textAlignment = .left
        text.font = UIFont.pretendard(style: .regular, size: 10, isScaled: true)
        return text
    }
    private var nicknameCheck: Bool = true
    lazy var nameAlertTextLabel: UILabel = alertTextLabel(alertText: "", textColor: MySpecialColors.Red)
    
    private lazy var nameDoubleCheckButton: UIButton = {
        let button = TabButtonUIFactory.doubleCheckButton(buttonTitle: "중복 확인", textColor: MySpecialColors.Gray3, cornerRadius: 12, backgroundColor: MySpecialColors.Gray1)
        button.titleLabel?.font = UIFont.pretendard(style: .bold, size: 12)
        button.layer.borderColor = MySpecialColors.Gray3.cgColor
        button.addTarget(self, action: #selector(duplicateCheckButtonTapped), for: .touchUpInside)
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
        label.text = "D-Day 제목"
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
        label.text = "D-Day 날짜"
        label.font = UIFont.pretendard(style: .semiBold, size: 12)
        label.textColor = MySpecialColors.Black
        return label
    }()
    private let includeTodayView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let includeTodayLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 포함"
        label.font = UIFont.pretendard(style: .regular, size: 12)
        label.textColor = MySpecialColors.Black
        return label
    }()
    private lazy var includeTodayButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "square")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.Gray3
        button.addTarget(self, action: #selector(includeTodayButtonTapped), for: .touchUpInside)
        return button
    }()
    private let dateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
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
        
        return textField
    }()
    private let dateLine: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray3
        return view
    }()
    // Confirm
    private lazy var confirmButton: UIButton = {
        let button = TabButtonUIFactory.tapButton(buttonTitle: "확인", textColor: .white , cornerRadius: 22, backgroundColor: MySpecialColors.MainColor)
        button.titleLabel?.font = UIFont.pretendard(style: .semiBold, size: 16)
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = MySpecialColors.Gray1
        self.title = "프로필 수정"
    }
    
    private func setupContent() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [rimoMessage, changeProfile, plusButton, outerNickNameStackView, nameAlertTextLabel, nickNameErrorMessage, focusTimeMessage, focusTimeBox, focusTimeStack, scheduleLabel, editScheduleName, scheduleLine, dateLabel, includeTodayView, includeTodayLabel, includeTodayButton, dateStack, dateLine, confirmButton].forEach {
            contentView.addSubview($0)
        }
        // NickName
        [innerNickNameStackView, nameDoubleCheckButton].forEach {
            outerNickNameStackView.addArrangedSubview($0)
        }
        [editNickName, nickNameLine].forEach {
            innerNickNameStackView.addArrangedSubview($0)
        }
        [calendarButton, editDate].forEach {
            dateStack.addArrangedSubview($0)
        }
        
        [editFocusTime, timeLabel].forEach {
            focusTimeStack.addArrangedSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.width.equalTo(scrollView.snp.width)
            make.edges.equalToSuperview()
            make.height.equalTo(800)
        }
        
        rimoMessage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
        }
        
        changeProfile.snp.makeConstraints { make in
            make.top.equalTo(rimoMessage.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints { make in
            make.bottom.equalTo(changeProfile.snp.bottom)
            make.trailing.equalTo(changeProfile.snp.trailing)
        }
        
        // NickName
        outerNickNameStackView.snp.makeConstraints { make in
            make.top.equalTo(changeProfile.snp.bottom).offset(46)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
        }
        innerNickNameStackView.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        editNickName.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
        }
        nickNameLine.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(0.8)
            make.width.equalToSuperview()
        }
        nameDoubleCheckButton.snp.makeConstraints { make in
            make.width.equalTo(74)
            make.height.equalTo(44)
        }
        nickNameErrorMessage.snp.makeConstraints { make in
            make.top.equalTo(outerNickNameStackView.snp.bottom).offset(9)
            make.leading.equalTo(outerNickNameStackView.snp.leading)
        }
        nameAlertTextLabel.snp.makeConstraints { make in
            make.top.equalTo(outerNickNameStackView.snp.bottom).offset(9)
            make.leading.equalTo(outerNickNameStackView.snp.leading)
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
            make.leading.equalToSuperview().offset(24)
        }
        editScheduleName.snp.makeConstraints { make in
            make.top.equalTo(scheduleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(35)
            make.trailing.equalToSuperview().inset(35)
        }
        scheduleLine.snp.makeConstraints { make in
            make.top.equalTo(editScheduleName.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(0.75)
        }
        
        // Date
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(scheduleLine.snp.bottom).offset(46)
            make.leading.equalTo(scheduleLine)
        }
        includeTodayView.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.trailing.equalToSuperview().inset(24)
            make.width.equalTo(82)
            make.height.equalTo(24)
        }
        includeTodayLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.trailing.equalTo(includeTodayButton.snp.trailing).inset(30)
        }
        includeTodayButton.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.trailing.equalToSuperview().inset(30)
        }
        dateStack.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(35)
            make.trailing.equalToSuperview().inset(35)
            make.height.equalTo(22)
        }
        calendarButton.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        editDate.snp.makeConstraints { make in
            make.centerY.equalTo(calendarButton)
            make.top.bottom.trailing.equalToSuperview()
        }
        dateLine.snp.makeConstraints { make in
            make.top.equalTo(editDate.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(0.75)
        }
        
        // Confirm
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(dateLine.snp.bottom).offset(46)
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
                        var date = timestamp.dateValue() // Convert Timestamp to Date
                        if let isTodayIncluded = data?["isTodayIncluded"] as? Bool, isTodayIncluded == true {
                            date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date // Subtract one day
                        }
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
                            print("프로필 설정: \(profileImageName)")
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
    private var isNicknameAvailable: Bool = false
    
    private func setupNickName() {
        editNickName.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: UITextField.textDidChangeNotification, object: editNickName)
        nameDoubleCheckButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let nickname = editNickName.text, !nickname.isEmpty {
            isNickNameEdited = true
        }
    }
    
    @objc private func duplicateCheckButtonTapped() {
        nickNameErrorMessage.isHidden = true
        nameDoubleCheckButton.layer.borderColor = MySpecialColors.Gray3.cgColor
        guard let nickname = editNickName.text, !nickname.isEmpty else {
            nameAlertTextLabel.isHidden = false
            updateConfirmButtonState()
            return
        }
        
        guard nickname.count >= 2 else {
            nameAlertTextLabel.isHidden = false
            nameAlertTextLabel.text = "닉네임은 2자 이상 입력해야 합니다."
            nameAlertTextLabel.textColor = MySpecialColors.Red
            self.isNicknameAvailable = false
            updateConfirmButtonState()
            return
        }
        
        guard isValidNicknameFormat(nickname) else {
            nameAlertTextLabel.isHidden = false
            nameAlertTextLabel.text = "닉네임은 한글/영어/숫자 2~8자로 입력해 주세요."
            nameAlertTextLabel.textColor = MySpecialColors.Red
            self.isNicknameAvailable = false
            updateConfirmButtonState()
            return
        }
        
        nameAlertTextLabel.isHidden = true
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("user-info").document(uid).getDocument { (document, error) in
            if let error = error {
                print("닉네임 확인 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists, let currentNickname = document.data()?["nickname"] as? String, currentNickname == nickname {
                // 사용자 닉네임과 파이어베이스에 저장된 닉네임이 동일할 경우
                self.isNicknameAvailable = true
                self.nameAlertTextLabel.text = "현재 사용 중인 닉네임입니다."
                self.nameAlertTextLabel.textColor = MySpecialColors.MainColor
                self.nameAlertTextLabel.isHidden = false
                self.updateConfirmButtonState()
            } else {
                // 닉네임 중복 확인
                Firestore.firestore().collection("user-info").whereField("nickname", isEqualTo: nickname).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("닉네임 확인 중 오류 발생: \(error.localizedDescription)")
                        return
                    }
                    
                    if let documents = querySnapshot?.documents, documents.isEmpty {
                        self.isNicknameAvailable = true
                        self.nameAlertTextLabel.text = "사용할 수 있는 닉네임입니다."
                        self.nameAlertTextLabel.textColor = MySpecialColors.MainColor
                    } else {
                        self.isNicknameAvailable = false
                        self.nameAlertTextLabel.text = "이미 사용 중인 닉네임입니다."
                        self.nameAlertTextLabel.textColor = MySpecialColors.Red
                    }
                    self.nameAlertTextLabel.isHidden = false
                    self.updateConfirmButtonState()
                }
            }
        }
    }
    
    private func updateConfirmButtonState() {
        confirmButton.isEnabled = self.isNicknameAvailable
        confirmButton.backgroundColor = self.isNicknameAvailable ? MySpecialColors.MainColor : MySpecialColors.Gray2
    }
    private func isValidNicknameFormat(_ nickname: String) -> Bool {
        let nicknameRegex = "^[a-zA-Z0-9가-힣]{2,}$"
        let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknameRegex)
        return nicknamePredicate.evaluate(with: nickname)
    }
    
    // Edit Schedule
    private func setupSchedule() {
        editScheduleName.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Edit focusTime
    private func setupFocusTime() {
        editFocusTime.delegate = self
        editFocusTime.inputView = focusTimePicker
        focusTimePicker.delegate = self
        focusTimePicker.dataSource = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusTimeBoxTapped))
            focusTimeBox.addGestureRecognizer(tapGesture)
            focusTimeBox.isUserInteractionEnabled = true
        let tapGestureLabel = UITapGestureRecognizer(target: self, action: #selector(focusTimeBoxTapped))
           timeLabel.addGestureRecognizer(tapGestureLabel)
           timeLabel.isUserInteractionEnabled = true
    }
    @objc private func focusTimeBoxTapped() {
        editFocusTime.becomeFirstResponder()
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
    private func includeButtonTapped() {
        let includeViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(includeTodayButtonTapped))
        includeTodayView.addGestureRecognizer(includeViewTapGesture)
        
        let includeLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(includeTodayButtonTapped))
        includeTodayLabel.addGestureRecognizer(includeLabelTapGesture)
        
        let includeButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(includeTodayButtonTapped))
        includeTodayButton.addGestureRecognizer(includeButtonTapGesture)
    }
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
        
        // 버튼 색상 변경
        let originalColor = confirmButton.backgroundColor
        confirmButton.backgroundColor = MySpecialColors.Gray2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.confirmButton.backgroundColor = originalColor
            
            // Firestore 업데이트
            let userDocRef = Firestore.firestore().collection("user-info").document(uid)
            var updateData: [String: Any] = [:]
            
            if let imageName = self?.selectedProfileImageName {
                updateData["profile-image"] = imageName
            }
            
            if let nickname = self?.editNickName.text, !nickname.isEmpty {
                updateData["nickname"] = nickname
                
                if self?.isNickNameEdited == true {
                    Firestore.firestore().collection("user-info").whereField("nickname", isEqualTo: nickname).getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("닉네임 확인 중 오류 발생: \(error.localizedDescription)")
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                            return
                        }
                        
                        if let documents = querySnapshot?.documents, documents.isEmpty {
                            self?.saveDataToFirestore(userDocRef: userDocRef, updateData: updateData)
                        } else {
                            let alert = UIAlertController(title: "Unavailable", message: "이 닉네임은 이미 사용 중입니다.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }
                } else {
                    self?.saveDataToFirestore(userDocRef: userDocRef, updateData: updateData)
                }
            }
            
            if let selectedFocusTime = self?.selectedFocusTime {
                updateData["target-time"] = "\(selectedFocusTime)"
            }
            
            if let scheduleName = self?.editScheduleName.text, !scheduleName.isEmpty {
                updateData["d-day-title"] = scheduleName
                UserDefaults.shared.set(scheduleName, forKey: "goal")
            }
            
            if let dateString = self?.editDate.text, let selectedDate = self?.dateFormatter.date(from: dateString) {
                var targetDate = selectedDate
                if self?.isTodayIncluded == true {
                    targetDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }

                //Data for widget
                UserDefaults.shared.set(Date(), forKey: "startDate")
                UserDefaults.shared.set(targetDate, forKey: "endDate")
                WidgetCenter.shared.reloadAllTimelines()

                let daysRemaining = self?.calculateDaysRemaining(to: targetDate) ?? 0
                let dDayMessage = "D-\(daysRemaining)"
                updateData["d-day-date"] = targetDate
                updateData["d-day"] = dDayMessage
                updateData["isTodayIncluded"] = self?.isTodayIncluded ?? false
                
                userDocRef.updateData(updateData) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated")
                        self?.navigateToMyPage()
                    }
                }
            } else {
                self?.navigateToMyPage()
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func navigateToMyPage() {
        if let myPageVC = self.navigationController?.viewControllers.first(where: { $0 is MyPageViewController }) {
            self.navigationController?.popToViewController(myPageVC, animated: true)
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
    
    // 키보드
    private var keyboardHeight: CGFloat = 0.0
    @objc func keyboardWillShow(_ noti: NSNotification){
        guard let userInfo = noti.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let screenHeight = UIScreen.main.bounds.height
        
        // 현재 활성화된 텍스트 필드나 뷰 가져오기
        guard let activeField = findFirstResponder(view: scrollView) else {
            return
        }
        
        // editScheduleName 텍스트 필드인 경우에만 처리
        if activeField == editScheduleName {
            let textFieldFrame = editScheduleName.frame
            let textFieldBottomY = textFieldFrame.origin.y + textFieldFrame.height
            
            // 텍스트 필드가 키보드보다 위에 있을 때만 뷰를 올림
            if textFieldBottomY > (screenHeight - keyboardHeight - 100) {
                let offsetY = textFieldBottomY - (screenHeight - keyboardHeight - 120)
                self.view.frame.origin.y = CGFloat(-offsetY)
            }
        }
        
        // contentInset 설정 및 스크롤
        var contentInset = scrollView.contentInset
        contentInset.bottom = keyboardHeight
        scrollView.contentInset = contentInset
        
        let scrollRect = activeField.convert(activeField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(scrollRect, animated: true)
    }

    @objc func keyboardWillHide(_ noti: NSNotification){
        UIView.animate(withDuration: 0.3) {
               self.view.frame.origin.y = 0
           }
        var contentInset = scrollView.contentInset
                contentInset.bottom = 0
                scrollView.contentInset = contentInset
    }
    
    private func findFirstResponder(view: UIView) -> UIView? {
           if view.isFirstResponder {
               return view
           }
           
           for subview in view.subviews {
               if let firstResponder = findFirstResponder(view: subview) {
                   return firstResponder
               }
           }
           
           return nil
       }
    
    private func tapView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
           // view에 gesture 추가
           view.addGestureRecognizer(tapGesture)
    }
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // 터치된 지점이 키보드를 닫을 필요가 있는 경우
        view.endEditing(true)
        UIView.animate(withDuration: 0.3) {
               self.view.frame.origin.y = 0
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

        if textField == editNickName {
            nameDoubleCheckButton.layer.borderColor = MySpecialColors.MainColor.cgColor
            nameDoubleCheckButton.titleLabel?.textColor = MySpecialColors.MainColor
            
            nameAlertTextLabel.isHidden = false
            nameAlertTextLabel.text = "중복확인을 진행해주세요."
            nameAlertTextLabel.textColor = MySpecialColors.Red
            
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = MySpecialColors.Gray2
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == editNickName {
            if let nickname = textField.text, !nickname.isEmpty {
                if isNicknameAvailable {
                    // 중복 확인 완료된 경우
                    nameAlertTextLabel.isHidden = true
                    confirmButton.isEnabled = true
                    confirmButton.backgroundColor = MySpecialColors.MainColor
                } else {
                    // 중복 확인이 아직 안 된 경우
                    nameAlertTextLabel.isHidden = false
                    nameAlertTextLabel.text = "중복확인을 진행해주세요."
                    nameAlertTextLabel.textColor = MySpecialColors.Red
                    confirmButton.isEnabled = false
                    confirmButton.backgroundColor = MySpecialColors.Gray2
                }
            } else {
                nameAlertTextLabel.isHidden = true
                textField.placeholder = "닉네임을 입력해 주세요"
                confirmButton.isEnabled = true
                confirmButton.backgroundColor = MySpecialColors.Gray2
            }
            nameDoubleCheckButton.layer.borderColor = MySpecialColors.Gray3.cgColor
            nameDoubleCheckButton.titleLabel?.textColor = MySpecialColors.Gray3
        } else if textField == editScheduleName {
            if textField.text?.isEmpty ?? true {
                textField.placeholder = "일정 이름을 입력해 주세요"
            }
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
    }
    @objc private func textFieldDidChange(_ notification: Notification) {
        guard let textField = notification.object as? UITextField else {
            return
        }
        // Edit NickName
        if textField == editNickName {
            nameDoubleCheckButton.layer.borderColor = MySpecialColors.MainColor.cgColor
            nameDoubleCheckButton.titleLabel?.textColor = MySpecialColors.MainColor
            if let text = textField.text, text.count > 8 {
                textField.text = String(text.prefix(8))
                nickNameErrorMessage.isHidden = false
                nameAlertTextLabel.isHidden = true
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
