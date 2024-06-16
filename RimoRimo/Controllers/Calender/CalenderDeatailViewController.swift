//
//  CalenderDeatailViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class CalendarDetailViewController: UIViewController, UITextViewDelegate {
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.font = UIFont.pretendard(style: .regular, size: 66)
        label.textColor = MySpecialColors.Gray4
        return label
    }()
    
    let marimoImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "Group 3"))
        return image
    }()
    
    let marimoMessage: UILabel = {
        let label = UILabel()
        label.text = "오늘은 마리모가 이만큼 성장했어요!"
        label.font = UIFont.pretendard(style: .medium, size: 14)
        label.textColor = MySpecialColors.Gray4
        return label
    }()
    
    let memoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        return view
    }()
    
    let dateLabel: UILabel = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let currentDate = dateFormatter.string(from: Date())
        
        let label = UILabel()
        label.text = currentDate
        label.font = UIFont.pretendard(style: .semiBold, size: 14)
        label.textColor = MySpecialColors.Gray4
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "edit-pencil-01"), for: .normal)
        button.addTarget(nil, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let memoTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.tintColor = MySpecialColors.MainColor
        return textView
    }()
    let memoPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 하루의 기분을 남겨 보세요 :>"
        label.font = UIFont.pretendard(style: .regular, size: 14)
        label.textColor = MySpecialColors.Gray3
        label.isHidden = false
        return label
    }()
    let characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(style: .regular, size: 12)
        label.textColor = MySpecialColors.Gray3
        return label
    }()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupContent()
        setupGestureRecognizer()
        
        memoTextView.delegate = self
        
        loadMemoData()
           
    }
    
    
    // MARK: - Setup func
    private func setupUI() {
        view.backgroundColor = UIColor(patternImage: UIImage(named: "GradientBackground")!)
        self.title = "오늘의 집중 시간"

        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "chevron-left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "chevron-left")
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = MySpecialColors.Green4
    }
    
    private func setupContent() {
        
        [timeLabel, marimoImage, marimoMessage, memoView, dateLabel, editButton, memoTextView, memoPlaceholderLabel, characterCountLabel].forEach {
            view.addSubview($0)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(140)
            make.centerX.equalToSuperview()
        }
        
        marimoImage.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(52)
            make.centerX.equalToSuperview()
            make.height.equalTo(159)
            make.width.equalTo(165)
        }
        
        marimoMessage.snp.makeConstraints { make in
            make.top.equalTo(marimoImage.snp.bottom).offset(43)
            make.centerX.equalToSuperview()
        }
        
        memoView.snp.makeConstraints { make in
            make.top.equalTo(marimoMessage.snp.bottom).offset(37)
            make.centerX.equalToSuperview()
            make.width.equalTo(345)
            make.height.equalTo(127)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(memoView.snp.top).offset(20)
            make.leading.equalTo(memoView.snp.leading).offset(24)
        }
        
        editButton.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.trailing.equalTo(memoView.snp.trailing).inset(24)
        }
        
        memoTextView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.equalTo(memoView.snp.leading).offset(18)
            make.trailing.equalTo(editButton)
            make.bottom.equalTo(memoView.snp.bottom).inset(30)
        }
        
        memoPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.leading.equalTo(dateLabel)
            make.trailing.equalTo(editButton)
        }
        
        characterCountLabel.snp.makeConstraints { make in
            make.bottom.equalTo(memoView.snp.bottom).inset(20)
            make.trailing.equalTo(memoView.snp.trailing).inset(30)
        }
    }
    
    // MARK: - Actions
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func editButtonTapped() {
        memoPlaceholderLabel.isHidden = true
        memoTextView.isEditable = true
        memoTextView.becomeFirstResponder()
    }
    
    @objc private func viewTapped() {
        if memoTextView.isFirstResponder {
            memoTextView.resignFirstResponder()
        }
        memoTextView.isEditable = false
        memoTextView.isScrollEnabled = true
        
        saveMemoToFirebase()
    }
    
    
    // MARK: - Firebase Data Handling
    var data: [String: Any]?
    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }
    
    private func loadMemoData() {
        guard let uid = uid, let day = data?["day"] as? String else {
                   print("UID or day is nil")
                   return
               }
        print("UID: \(uid), Day: \(day)")
        
        guard let memoText = memoTextView.text else {
            print("Memo text is nil")
            return
        }
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(day)
            .getDocument { (document, error) in
                if let error = error {
                    print("Error fetching document: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists {
                    let memoData = document.data() ?? [:]
                    print("Document data: \(memoData)")
                    
                    // Update memoTextView with day-memo
                    if let dayMemo = memoData["day-memo"] as? String {
                        self.memoTextView.text = dayMemo
                    }
                    self.memoPlaceholderLabel.isHidden = true
                    
                    // Update timeLabel with total-time
                    if let totalTime = memoData["total-time"] as? String {
                        self.timeLabel.text = totalTime
                    }
                } else {
                    print("No document found for day: \(day)")
                    self.memoPlaceholderLabel.isHidden = false
                }
            }
    }
    
    private func saveMemoToFirebase() {
        guard let uid = uid, let day = data?["day"] as? String else {
            print("UID or day is nil")
            return
        }
        
        guard let memoText = memoTextView.text else {
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
            .setData(memoData, merge: true) { error in
                if let error = error {
                    print("메모 저장 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("메모가 성공적으로 저장되었습니다.")
                }
            }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        memoPlaceholderLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            memoPlaceholderLabel.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == memoTextView {
            checkMaxLength(textView)
            setupTextViewLineSpacing()
            
            memoTextView.textColor = MySpecialColors.Gray4
            memoTextView.font = UIFont.pretendard(style: .regular, size: 14)
            
            if textView.text.isEmpty {
                memoPlaceholderLabel.isHidden = false
            } else {
                memoPlaceholderLabel.isHidden = true
            }
            
            let count  = textView.text.count
            characterCountLabel.text = "\(count)/50"
        }
    }
    
    func checkMaxLength(_ textView: UITextView) {
        let maxLength = 50
        if let text = textView.text, text.count > maxLength {
            let excessLength = text.count - maxLength
            let endIndex = text.index(text.endIndex, offsetBy: -excessLength) // 초과된 글자의 끝 인덱스 계산
            textView.text = String(text.prefix(upTo: endIndex)) // 초과된 글자 삭제
        }
    }
    
    func setupTextViewLineSpacing() {
        let attributedString = NSMutableAttributedString(string: memoTextView.text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        memoTextView.attributedText = attributedString
    }
}

//import UIKit
//import FirebaseFirestore
//import FirebaseAuth
//
//class CalenderDeatailViewController: UIViewController {
//    var data: [String: Any]?
//    private var uid: String? {
//        return Auth.auth().currentUser?.uid
//    }
//    private let calenderDeatailTitle: UILabel = {
//        let text = UILabel()
//        text.text = "CalenderDeatail"
//        return text
//    }()
//    
//    private lazy var memoLabel: UILabel = {
//        let label = UILabel()
//        label.text = "메모를 추가하려면 탭하세요."
//        label.isUserInteractionEnabled = true
//        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMemoLabelTap)))
//        return label
//    }()
//    
//    private lazy var memoTextField: UITextField = {
//        let textField = UITextField()
//        textField.isHidden = true
//        textField.borderStyle = .roundedRect
//        return textField
//    }()
//    
//    private lazy var saveButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Save Memo", for: .normal)
//        button.addTarget(self, action: #selector(saveMemo), for: .touchUpInside)
//        return button
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        view.addSubview(calenderDeatailTitle)
//        view.addSubview(memoLabel)
//        view.addSubview(memoTextField)
//        view.addSubview(saveButton)
//        
//        calenderDeatailTitle.translatesAutoresizingMaskIntoConstraints = false
//        memoLabel.translatesAutoresizingMaskIntoConstraints = false
//        memoTextField.translatesAutoresizingMaskIntoConstraints = false
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            calenderDeatailTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            calenderDeatailTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            
//            memoLabel.topAnchor.constraint(equalTo: calenderDeatailTitle.bottomAnchor, constant: 20),
//            memoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            memoTextField.topAnchor.constraint(equalTo: calenderDeatailTitle.bottomAnchor, constant: 20),
//            memoTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            memoTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            memoTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            saveButton.topAnchor.constraint(equalTo: memoTextField.bottomAnchor, constant: 20),
//            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//        
//        displayData()
//    }
//    
//    private func displayData() {
//        guard let data = data else { return }
//        
//        var topAnchor = memoLabel.bottomAnchor
//        
//        for (key, value) in data {
//            let keyLabel = UILabel()
//            keyLabel.text = key
//            keyLabel.font = UIFont.boldSystemFont(ofSize: 16)
//            keyLabel.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(keyLabel)
//            
//            let valueLabel = UILabel()
//            valueLabel.text = "\(value)"
//            valueLabel.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(valueLabel)
//            
//            NSLayoutConstraint.activate([
//                keyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//                keyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
//                
//                valueLabel.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: 10),
//                valueLabel.firstBaselineAnchor.constraint(equalTo: keyLabel.firstBaselineAnchor),
//                valueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//            ])
//            
//            topAnchor = keyLabel.bottomAnchor
//        }
//    }
//    
//    @objc private func handleMemoLabelTap() {
//        memoLabel.isHidden = true
//        memoTextField.isHidden = false
//        memoTextField.becomeFirstResponder()
//    }
//    
//    @objc private func saveMemo() {
//        guard let uid = uid, let day = data?["day"] as? String else {
//            print("UID or day is nil")
//            return
//        }
//        
//        guard let memoText = memoTextField.text else {
//            print("Memo text is nil")
//            return
//        }
//        
//        let memoData: [String: Any] = [
//            "day-memo": memoText
//        ]
//        
//        Firestore.firestore()
//            .collection("user-info")
//            .document(uid)
//            .collection("study-sessions")
//            .document(day)
//            .updateData(memoData) { error in
//                if let error = error {
//                    print("메모 업데이트 중 오류 발생: \(error.localizedDescription)")
//                } else {
//                    print("메모가 성공적으로 업데이트되었습니다.")
//                }
//            }
//    }
//}
