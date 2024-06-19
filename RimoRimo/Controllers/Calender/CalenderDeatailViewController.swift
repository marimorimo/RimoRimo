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
        image.contentMode = .scaleAspectFill
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
        let label = UILabel()
        label.font = UIFont.pretendard(style: .semiBold, size: 14)
        label.textColor = MySpecialColors.Gray4
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "edit-pencil-01")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.MainColor
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        if !memoTextView.text.isEmpty {
            setAlertView(title: "메모 저장", subTitle: "메모가 성공적으로 저장되었습니다.")
        }
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: day) {
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            let formattedDay = dateFormatter.string(from: date)
            dateLabel.text = formattedDay
        } else {
            print("Failed to convert day string to date.")
            return
        }
        
        
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
                        if dayMemo == "" {
                            self.memoPlaceholderLabel.isHidden = false
                        } else {
                            self.memoTextView.text = dayMemo
                            self.memoPlaceholderLabel.isHidden = true
                        }
                    }
                    
                    // Update timeLabel with total-time
                        if let totalTime = memoData["total-time"] as? String {
                            if totalTime == "" {
                                self.timeLabel.text = "00:00:00"
                            } else {
                                self.timeLabel.text = totalTime
                            }
                        }
                    
                    // Update Marimo Image
                    let marimoState = memoData["marimo-state"] as? Int
                    let profileImageName = memoData["profile-image"] as? String
                    self.updateMarimoImage(with: marimoState, profileImageName: profileImageName)
                } else {
                    print("No document found for day: \(day)")
                    self.memoPlaceholderLabel.isHidden = false
                }
                
            }
    }
    
    private func updateMarimoImage(with state: Int?, profileImageName: String?) {
        var imageName: String
        switch state {
        case 0:
            imageName = "Group 1"
        case 1:
            imageName = "Group 2"
        case 2:
            imageName = "Group 3"
        case 3:
            imageName = "Group 4"
        case 4:
            imageName = profileImageName ?? "Group7"
        default:
            imageName = "Group 7"
        }
        self.marimoImage.image = UIImage(named: imageName)
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
    
    // MARK: - setAlertView
    let alertBack = AlertUIFactory.alertBackView()
    let alertView = AlertUIFactory.alertView()
    
    let alertTitle = AlertUIFactory.alertTitle(titleText: "차단 해제", textColor: MySpecialColors.Black, fontSize: 16)
    let alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: "차단을 해제하시겠습니까?", textColor: MySpecialColors.Gray4, fontSize: 14)
    
    let widthLine = AlertUIFactory.widthLine()
    let heightLine = AlertUIFactory.heightLine()

    let checkView = AlertUIFactory.checkView()
    let checkLabel = AlertUIFactory.checkLabel(cancleText: "확인", textColor: MySpecialColors.MainColor, fontSize: 14)
    
    @objc private func setAlertView(title: String, subTitle: String) {
        let alertTitle = AlertUIFactory.alertTitle(titleText: title, textColor: MySpecialColors.Black, fontSize: 16)
        let alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: subTitle, textColor: MySpecialColors.Gray4, fontSize: 14)
        
        checkView.isUserInteractionEnabled = true
        
        view.addSubview(alertBack)
        alertBack.addSubview(alertView)
        [alertTitle, alertSubTitle, widthLine, checkView].forEach {
            alertView.addSubview($0)
        }
        checkView.addSubview(checkLabel)
        
        alertBack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(46)
            make.trailing.equalToSuperview().inset(46)
            make.height.equalTo(140)
        }
        
        alertTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        alertSubTitle.snp.makeConstraints { make in
            make.top.equalTo(alertTitle.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        widthLine.snp.makeConstraints { make in
            make.top.equalTo(alertSubTitle.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        checkView.snp.makeConstraints { make in
            make.top.equalTo(widthLine.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        checkLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }
        
        alertBack.alpha = 0
        alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.3) {
            self.alertBack.alpha = 1
            self.alertView.transform = CGAffineTransform.identity
        }
        
        checkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeAlertView)))
    }
    
    @objc private func removeAlertView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alertBack.alpha = 0
            self.alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            self.alertBack.removeFromSuperview()
            self.alertView.removeFromSuperview()
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        memoPlaceholderLabel.isHidden = true
        editButton.tintColor = MySpecialColors.Gray3
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            memoPlaceholderLabel.isHidden = false
            editButton.tintColor = MySpecialColors.Gray3
        } else {
            memoTextView.textColor = MySpecialColors.Gray4
            editButton.tintColor = MySpecialColors.MainColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == memoTextView {
            checkMaxLength(textView)
            setupTextViewLineSpacing()
            
            memoTextView.textColor = MySpecialColors.Gray3
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
