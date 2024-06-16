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
    
    let prevButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "chevron-left-md")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.MainColor
        button.addTarget(nil, action: #selector(didTapPrevButton), for: .touchUpInside)
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "chevron-right-md")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.MainColor
        button.addTarget(nil, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = TabButtonUIFactory.tapButton(buttonTitle: "확인", textColor: .white , cornerRadius: 22, backgroundColor: MySpecialColors.MainColor)
        button.titleLabel?.font = UIFont.pretendard(style: .semiBold, size: 16)
        button.addTarget(nil, action: #selector(confirmButtonTapped), for: .touchUpInside)
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

    }
    
    // MARK: - Setup
    
    private func setupContent() {
        
        [backgroundView, mainCalendar, customHeaderLabel, buttonStack, confirmButton].forEach {
            view.addSubview($0)
        }
        [prevButton, nextButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(180)
            make.centerX.equalToSuperview()
            make.width.equalTo(345)
            make.height.equalTo(414)
        }
        
        customHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp.top).offset(30)
            make.leading.equalTo(backgroundView.snp.leading).offset(30)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.centerY.equalTo(customHeaderLabel)
            make.trailing.equalTo(backgroundView.snp.trailing).inset(24)
        }
        
        mainCalendar.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp.top).offset(70)
            make.leading.equalTo(backgroundView.snp.leading).offset(24)
            make.trailing.equalTo(backgroundView.snp.trailing).inset(24)
            make.width.equalTo(297)
            make.height.equalTo(263)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(mainCalendar.snp.bottom).offset(16)
            make.centerX.equalTo(backgroundView)
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
    
}
