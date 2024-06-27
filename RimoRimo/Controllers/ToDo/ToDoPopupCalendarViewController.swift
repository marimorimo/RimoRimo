//
//  ToDoPopupCalendarViewController.swift
//  RimoRimo
//
//  Created by 이유진 on 6/15/24.
//

import UIKit
import SnapKit
import FSCalendar
import Firebase

class ToDoPopupCalendarViewController: UIViewController, FSCalendarDelegate,FSCalendarDelegateAppearance, FSCalendarDataSource {
    
    
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
        selectTodayDateIfNecessary()
//        fetchLastSelectedDateFromFirebase()
        
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
        
        selectTodayDateIfNecessary()
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
    
    // Header
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateHeaderTitle(for: mainCalendar.currentPage)
    }
    private func updateHeaderTitle(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        customHeaderLabel.text = formatter.string(from: mainCalendar.currentPage)
    }
    
    var selectedDate: Date?
    var didSelectDate: ((Date, String) -> Void)?
    
    @objc private func confirmButtonTapped() {
        if let selectedDate = mainCalendar.selectedDate {
            self.selectedDate = selectedDate
           
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy.MM.dd.EEE"
            let formattedDate = formatter.string(from: selectedDate)
            
            self.didSelectDate?(selectedDate, formattedDate)
            saveSelectedDateToFirebase(selectedDate: selectedDate)

            dismiss(animated: true, completion: nil)
            print("선택한 날짜: \(formattedDate)")
        } else {
            print("날짜가 선택되지 않았습니다.")
        }
    }
    
    private func saveSelectedDateToFirebase(selectedDate: Date) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd.EEE"
        let day = formatter.string(from: selectedDate)
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .setData(["day": Timestamp(date: selectedDate)], merge: true) { error in
                if let error = error {
                    print("Error saving selected date: \(error.localizedDescription)")
                } else {
                    print("Selected date saved successfully.")
                }
            }
    }
    
    var todayDate: String? {
        didSet {
            selectTodayDateIfNecessary()
        }
    }
    
    private func selectTodayDateIfNecessary() {
        print("확인확인확인: \(String(describing: self.todayDate))")
        if let todayDateString = todayDate {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy.MM.dd.EEE"
            
            if let selectedDate = formatter.date(from: todayDateString) {
                mainCalendar.select(selectedDate)
                mainCalendar.setCurrentPage(selectedDate, animated: true)
                updateHeaderTitle(for: selectedDate)
            } else {
                print("Invalid date format for todayDate")
                // 선택되지 않은 경우 기본적으로 오늘 날짜를 선택하도록 설정
                let today = Date()
                mainCalendar.select(today)
                mainCalendar.setCurrentPage(today, animated: true)
                updateHeaderTitle(for: today)
            }
        } else {
            print("todayDate is nil or empty")
            // 선택되지 않은 경우 기본적으로 오늘 날짜를 선택하도록 설정
            let today = Date()
            mainCalendar.select(today)
            mainCalendar.setCurrentPage(today, animated: true)
            updateHeaderTitle(for: today)
        }
    }
    
}
