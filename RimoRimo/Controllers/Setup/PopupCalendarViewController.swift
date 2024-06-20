//
//  PopupCalendarViewController.swift
//  Marimo
//
//  Created by 이유진 on 6/12/24.
//

import UIKit
import SnapKit
import FSCalendar
import Firebase

class PopupCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance, FSCalendarDataSource {

    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let boxView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.alpha = 0.97
        return view
    }()
    
    let mainCalendar: FSCalendar = {
        let calendar = FSCalendar()
        return calendar
    }()
    
    let customHeaderLabel: UILabel = {
         let label = UILabel()
         label.font = UIFont.pretendard(style: .medium, size: 16)
         label.textColor = MySpecialColors.Gray4
         label.textAlignment = .left
         return label
     }()
    
    let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        return stack
    }()
    
    lazy var prevButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "chevron-left-md")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.MainColor
        button.addTarget(self, action: #selector(didTapPrevButton), for: .touchUpInside)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "chevron-right-md")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.MainColor
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()
    
    lazy var confirmButton: UIButton = {
        let button = TabButtonUIFactory.tapButton(buttonTitle: "확인", textColor: .white , cornerRadius: 22, backgroundColor: MySpecialColors.MainColor)
        button.titleLabel?.font = UIFont.pretendard(style: .semiBold, size: 16)
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        self.setCalendar(myCalendar: mainCalendar)
        
        setupContent()
        updateHeaderTitle(for: mainCalendar.currentPage)
        
        fetchLastSelectedDateFromFirebase()
        
        tapBackground()

    }
    
    // MARK: - Setup
    
    private func setupContent() {
        
        [backgroundView, boxView, mainCalendar, customHeaderLabel, buttonStack, confirmButton].forEach {
            view.addSubview($0)
        }
        [prevButton, nextButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        boxView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(345)
            make.height.equalTo(414)
        }
        
        customHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(boxView.snp.top).offset(30)
            make.leading.equalTo(boxView.snp.leading).offset(30)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.centerY.equalTo(customHeaderLabel)
            make.trailing.equalTo(boxView.snp.trailing).inset(24)
        }
        
        mainCalendar.snp.makeConstraints { make in
            make.top.equalTo(boxView.snp.top).offset(70)
            make.leading.equalTo(boxView.snp.leading).offset(24)
            make.trailing.equalTo(boxView.snp.trailing).inset(24)
            make.width.equalTo(297)
            make.height.equalTo(263)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(mainCalendar.snp.bottom).offset(16)
            make.centerX.equalTo(boxView)
            make.width.equalTo(297)
            make.height.equalTo(46)
        }
        
    }
    
    private func setCalendar(myCalendar: FSCalendar) {
        
        myCalendar.delegate = self
        myCalendar.dataSource = self
        
        myCalendar.locale = Locale(identifier: "ko_KR")
        
        myCalendar.scrollEnabled = false
        myCalendar.backgroundColor = .clear
        
        // 년도,월
        myCalendar.appearance.headerMinimumDissolvedAlpha = 0
        myCalendar.headerHeight = 0
        
        // 요일
        myCalendar.appearance.weekdayFont = UIFont.pretendard(style: .regular, size: 12)
        myCalendar.appearance.weekdayTextColor = MySpecialColors.Gray3
        myCalendar.firstWeekday = 1
        
        // 날짜
        myCalendar.appearance.titleFont = UIFont.pretendard(style: .regular, size: 12)
        myCalendar.appearance.todayColor = MySpecialColors.Gray2
        myCalendar.appearance.titleTodayColor = .white
        myCalendar.appearance.todaySelectionColor = MySpecialColors.MainColor
        myCalendar.appearance.selectionColor = MySpecialColors.MainColor
        myCalendar.appearance.titleSelectionColor = .white
        myCalendar.appearance.titlePlaceholderColor = MySpecialColors.Gray2
        myCalendar.appearance.titleDefaultColor = MySpecialColors.Black
        myCalendar.appearance.titleWeekendColor = MySpecialColors.Black
        
        if let lastSelectedDate = lastSelectedDate {
            myCalendar.select(lastSelectedDate)
            myCalendar.setCurrentPage(lastSelectedDate, animated: true)
            updateHeaderTitle(for: lastSelectedDate)
        }
    }
    
    
    // MARK: - Func
    private func tapBackground() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func backgroundViewTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapPrevButton() {
        moveCurrentPage(by: -1)
    }
    
    @objc private func didTapNextButton() {
        moveCurrentPage(by: 1)
    }
    
    private func moveCurrentPage(by months: Int) {
        let currentPage = mainCalendar.currentPage
        let nextPage = Calendar.current.date(byAdding: .month, value: months, to: currentPage)!
        mainCalendar.setCurrentPage(nextPage, animated: true)
        updateHeaderTitle(for: nextPage)
    }
    
    // MARK: - FSCalendarDelegate
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let canSelect = !isDateInPast(date)
        
        if !canSelect {
            setAlertView(title: "선택 불가", subTitle: "지난 날짜는 선택할 수 없습니다.")
        }
        return canSelect
    }
    private func isDateInPast(_ date: Date) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: date)
        return selectedDay < today
    }
    
    // Header
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateHeaderTitle(for: mainCalendar.currentPage)
    }
    private func updateHeaderTitle(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        customHeaderLabel.text = formatter.string(from: mainCalendar.currentPage)
    }
    
    var selectedDate: String?
    var didSelectDate: ((String) -> Void)?
    
    @objc private func confirmButtonTapped() {
        if let selectedDate = mainCalendar.selectedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일"
            let formattedDate = formatter.string(from: selectedDate)
            self.didSelectDate?(formattedDate)
            dismiss(animated: true, completion: nil)
            print("Selected Date: \(formattedDate)")
        } else {
            print("No date selected")
        }
    }
    
    var lastSelectedDate: Date?
    private let db = Firestore.firestore()
    // Firebase Fetch
    private func fetchLastSelectedDateFromFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let userDocRef = db.collection("user-info").document(uid)
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let selectedTimestamp = document.data()?["d-day-date"] as? Timestamp {
                    let selectedDate = selectedTimestamp.dateValue()
                    self.lastSelectedDate = selectedDate
                    self.mainCalendar.select(selectedDate)
                    self.mainCalendar.setCurrentPage(selectedDate, animated: true)
                    self.updateHeaderTitle(for: selectedDate)
                }
            } else {
                print("Document does not exist")
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
    
}
