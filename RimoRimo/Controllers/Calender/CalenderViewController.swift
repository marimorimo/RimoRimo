import UIKit
import FSCalendar
import FirebaseFirestore
import FirebaseAuth
import SnapKit

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    var profileImageName: String = ""
    private var currentYear: Int = 0
    private var currentMonth: Int = 0
    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }
    
    private let mainCalendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scope = .month
        calendar.headerHeight = 0
        calendar.tintColor = MySpecialColors.MainColor
        calendar.appearance.todayColor = UIColor.clear // 오늘 날짜의 배경을 투명하게 설정
        calendar.appearance.selectionColor = UIColor.clear
        calendar.appearance.eventDefaultColor = UIColor.clear
        calendar.appearance.eventSelectionColor = UIColor.clear // 이벤트 점의 색상 설정
        calendar.scrollEnabled = false
        return calendar
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = MySpecialColors.Black
        label.textAlignment = .left
        return label
    }()
    
    let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 20
        return stack
    }()
    
    let prevButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "chevron-left")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.Gray3
        button.addTarget(self, action: #selector(didTapPrevButton), for: .touchUpInside)
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "chevron-right")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = MySpecialColors.Gray3
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()
    
    private var collectionRef: CollectionReference!
    private var listener: ListenerRegistration?
    private var sessionData: [String: [String: Any]] = [:]
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MySpecialColors.Gray1
        
        let currentDate = Date()
        let calendar = Calendar.current
        currentYear = calendar.component(.year, from: currentDate)
        currentMonth = calendar.component(.month, from: currentDate)
        
        if let uid = uid {
            collectionRef = Firestore.firestore().collection("user-info").document(uid).collection("study-sessions")
        }
        
        setupMonthLabel()
        setupCalendar()
        setupSessionDataListener()
        fetchUserDataAndBindUI()
    }
    
    private func fetchUserDataAndBindUI() {
           guard let uid = uid else {
               print("유저 정보를 찾을 수 없음")
               return
           }
           
           // Fetch marimo-name data from study-sessions collection
           let studySessionRef = Firestore.firestore()
               .collection("user-info")
               .document(uid)
               .collection("study-sessions")
           
           studySessionRef.addSnapshotListener { [weak self] (querySnapshot, error) in
               guard let self = self else { return }
               
               if let error = error {
                   print("문서를 가져오는 중 오류 발생: \(error.localizedDescription)")
                   return
               }
               
               guard let documents = querySnapshot?.documents else {
                   print("문서가 존재하지 않음")
                   return
               }
               
               if documents.isEmpty {
                   print("문서 데이터가 비어 있습니다.")
                   return
               }
               
               // Process each document in the query snapshot
               for document in documents {
                   let data = document.data()
                   print("Study Session Data: \(data)")
                   
                   let documentID = document.documentID // 문서 ID를 사용하여 sessionData에 저장
                   self.sessionData[documentID] = data
                   
                   DispatchQueue.main.async {
                       self.mainCalendar.reloadData() // 캘린더 리로드
                   }
               }
           }
       }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Setup
    private func setupMonthLabel() {
        view.addSubview(monthLabel)
        view.addSubview(buttonStack)
        
        monthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)//90
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.height.equalTo(30)
        }
        
        [prevButton, nextButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70) //90
            make.leading.equalTo(monthLabel.snp.trailing).offset(10)
            make.trailing.equalTo(view).offset(-20)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        updateMonthLabel() // 초기 설정 시 월 라벨 업데이트
    }
    
    private func setupCalendar() {
        view.addSubview(mainCalendar)
        mainCalendar.delegate = self
        mainCalendar.dataSource = self
        mainCalendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "CustomCalendarCell")
        
        mainCalendar.snp.makeConstraints { make in
            make.top.equalTo(monthLabel.snp.bottom).offset(10)//10
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalToSuperview().inset(150) // 캘린더 높이 조절 150
        }
        mainCalendar.appearance.weekdayTextColor = MySpecialColors.MainColor
        mainCalendar.appearance.weekdayFont = UIFont(name: "Pretendard-SemiBold", size: 14)
        mainCalendar.locale = Locale(identifier: "ko_KR")
    }
    
    private func updateMonthLabel() {
        let dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        if let date = Calendar.current.date(from: dateComponents) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월"
            monthLabel.text = formatter.string(from: date)
        }
    }
    
    private func setupSessionDataListener() {
        guard let collectionRef = collectionRef else { return }
        
        listener = collectionRef.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.sessionData.removeAll()
                for document in querySnapshot!.documents {
                    self.sessionData[document.documentID] = document.data()
                    print("Loaded data for document \(document.documentID): \(document.data())")
                }
                self.mainCalendar.reloadData() // 캘린더 리로드
            }
        }
    }
    
    
    deinit {
        listener?.remove()
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
        currentYear = Calendar.current.component(.year, from: nextPage)
        currentMonth = Calendar.current.component(.month, from: nextPage)
        updateMonthLabel() // 월 변경 시 월 라벨 업데이트
    }
    
    // MARK: - FSCalendarDataSource
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = formatDate(date: date)
        return sessionData[dateString] != nil ? 1 : 0
    }
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        let dateString = formatDate(date: date)
        let day = Calendar.current.component(.day, from: date)
        return sessionData[dateString] != nil ? "\(day)" : nil
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at monthPosition: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCalendarCell", for: date, at: monthPosition) as! CustomCalendarCell
        let isToday = Calendar.current.isDateInToday(date)
        let dateString = formatDate(date: date)
        
        if let session = sessionData[dateString] {
            let marimoState = session["marimo-state"] as? Int
            let marimoName = session["marimo-name"] as? String
            cell.profileImageName = marimoName // marimoName을 CustomCalendarCell에 전달
            cell.configure(with: date, marimoState: marimoState, isToday: isToday, isCurrentMonth: monthPosition == .current)
        } else {
            cell.configure(with: date, marimoState: nil, isToday: isToday, isCurrentMonth: monthPosition == .current)
        }
        return cell
    }
    
    // MARK: - FSCalendarDelegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateString = formatDate(date: date)
        if let data = sessionData[dateString] as? [String: Any] {
            let detailVC = CalendarDetailViewController()
            detailVC.data = data
            detailVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let dateString = formatDate(date: date)
        return sessionData[dateString] != nil
    }
    
    // MARK: - FSCalendarDelegateAppearance
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return nil // 기본 색상 설정을 여기서 하지 않음
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) {
            return UIColor.clear // 오늘 날짜의 배경을 투명하게 설정
        }
        return nil
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // CustomCalendarCell 클래스 정의
    class CustomCalendarCell: FSCalendarCell {
        var profileImageName: String?
        private let customLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont(name: "Pretendard-Medium", size: 14)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let marimoImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .clear // 이미지가 없을 때 투명 배경으로 설정
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(marimoImageView)
            contentView.addSubview(customLabel)
            
            marimoImageView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.height.equalTo(45)
                make.bottom.equalTo(customLabel).offset(-12)
            }
            
            customLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(12)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configure(with date: Date, marimoState: Int?, isToday: Bool, isCurrentMonth: Bool) {
            customLabel.text = Calendar.current.component(.day, from: date).description
            if let marimoState = marimoState {
                var imageName: String?
                
                print(marimoState)
                switch marimoState {
                case 1:
                    imageName = "Group 1"
                case 2:
                    imageName = "Group 2"
                case 3:
                    imageName = "Group 3"
                case 4:
                    imageName = "Group 4"
                case 5:
                    imageName = profileImageName ?? "Group 7"
                default:
                    imageName = nil
                }
                
                if let imageName = imageName {
                    if let image = UIImage(named: imageName) {
                        marimoImageView.image = image
                        print("Image \(imageName) loaded successfully.")
                    } else {
                        marimoImageView.image = nil
                        print("Failed to load image \(imageName).")
                    }
                } else {
                    marimoImageView.image = nil
                    print("Image name is nil.")
                }
                marimoImageView.backgroundColor = .clear
            } else {
                marimoImageView.image = nil
                marimoImageView.backgroundColor = .clear
                print("marimoState is nil.")
            }
            
            if isToday {
                customLabel.textColor = MySpecialColors.MainColor
                customLabel.font = UIFont(name: "Pretendard-Bold", size: 14)
            } else if !isCurrentMonth {
                customLabel.textColor = MySpecialColors.Gray2
                customLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
            } else {
                customLabel.textColor = .black
                customLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            titleLabel.isHidden = true
        }
    }
}
