//
//  MainViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import UserNotifications
import FirebaseFirestore
import FirebaseAuth
import SnapKit
import Then

class MainViewController: UIViewController, UNUserNotificationCenterDelegate {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    private var activityIndicator: UIActivityIndicatorView!
    
    private let defaults = UserDefaults.standard

    // MARK: - Firebase Properties
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private var uid: String? {
        return auth.currentUser?.uid
    }
    
    // MARK: - Properties
    private var timerIsCounting = false
    private var startTime: Date?
    private var stopTime: Date?
    private var scheduledTimer: Timer?
    
    private let START_TIME_KEY = "startTime"
    private let STOP_TIME_KEY = "stopTime"
    private let COUNTING_KEY = "countingKey"
    private let NOTIFICATION_KEY = "ScheduledNotification"
    
    private var currentGroup = 1
    private var interval: Double = 0
    private var isAnimationRunning = false
    private var profileImageName = ""
    private var targetTimeData: Double?
    
    private let formatter = DateFormatter()
    private var isStudy = false
    private var currentSessionID: String?
    private var totalTimeElapsed: TimeInterval = 0
    
    private let alertOnly = AlertOnly()
    private let alertPaths = AlertPaths()
    private let alertOnboarding = AlertOnboarding()
    
    // MARK: - Outlets
    private lazy var timeLabel = UILabel().then {
        $0.text = makeTimeString(hour: 0, min: 0, sec: 0)
        if #available(iOS 13.0, *) {
            let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 72, weight: .semibold)
            $0.font = UIFontMetrics.default.scaledFont(for: monospacedFont)
        } else {
            $0.font = UIFont(name: "Courier", size: 72)
        }
        $0.textColor = MySpecialColors.MainColor
        $0.textAlignment = .center
    }
    
    private lazy var startStopButton = UIButton(type: .system).then {
        $0.setTitle("집중 모드 시작하기", for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(style: .semiBold, size: 16, isScaled: true)
        $0.setTitleColor(MySpecialColors.Gray1, for: .normal)
        $0.backgroundColor = MySpecialColors.MainColor
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(startStopAction(_:)), for: .touchUpInside)
    }
    
    private lazy var resetButton = UIButton(type: .system).then {
        $0.setTitle("RESET", for: .normal)
        $0.setTitleColor(MySpecialColors.Gray3, for: .normal)
        $0.addTarget(self, action: #selector(resetAction(_:)), for: .touchUpInside)
    }
    
    private lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.image = UIImage(named: "Group \(self.currentGroup)")
    }
    
    private let dayView = UIView().then {
        $0.backgroundColor = MySpecialColors.DayBlue
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let dayStackView = UIStackView().then {
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 10
    }
    
    private lazy var dayTitleLabel = UILabel().then {
        $0.text = "토익 시험"
        $0.textColor = MySpecialColors.Black
        $0.font = UIFont.pretendard(style: .medium, size: 16, isScaled: true)
    }
    
    private lazy var dayLabel = UILabel().then {
        $0.text = "D-30"
        if #available(iOS 13.0, *) {
            let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
            $0.font = UIFontMetrics.default.scaledFont(for: monospacedFont)
        } else {
            $0.font = UIFont(name: "Courier-Bold", size: 16)
        }
        $0.textColor = MySpecialColors.MainColor
    }
    
    private let cheeringLabel = UILabel().then {
        $0.text = "마리모가 응원해줄 거예요!"
        $0.textColor = MySpecialColors.Gray4
        $0.font = UIFont.pretendard(style: .regular, size: 14, isScaled: true)
    }
    
    // MARK: - SuccessView
    private let successView = UIView().then {
        $0.backgroundColor = MySpecialColors.Blue.withAlphaComponent(0.6)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let successStackView = UIStackView().then {
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 10
    }
    
    private let successTitleLabel = UILabel().then {
        $0.text = "마리모의 성장이 완료되었어요!"
        $0.textColor = MySpecialColors.Black
        $0.font = UIFont.pretendard(style: .bold, size: 18)
    }
    
    private let goDetailButton = UIButton().then {
        $0.addTarget(self, action: #selector(goDetailButtonTapped), for: .touchUpInside)
    }
    
    private let goDetailImage = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = MySpecialColors.Black
    }
    
    private let successTextLabel = UILabel().then {
        $0.text = """
        마리모가 생성되었습니다!
        성장이 완료된 마리모를 확인해 보세요.
        """
        $0.textColor = MySpecialColors.Black
        $0.font = UIFont.pretendard(style: .regular, size: 14, isScaled: true)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MySpecialColors.Gray1
        
        checkUserDefaults()
      
        formatter.dateFormat = "yyyy-MM-dd"
        
        notificationCenter.delegate = self
        
        setupBackground()
        setupBubbleEmitter()
        
        setupUI()
        
        addBouncingAnimation(targetView: imageView)
        hideSuccessView()
        cheeringLabel.isHidden = false
        
        requestNotificationAuthorization()
        
        setupActivityIndicator()
        
        fetchUserDataAndBindUI()
        
        showLoadingIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkAndResetTimerIfNeeded()
            self.updateImageView()
            self.hideLoadingIndicator()
        }
    }
    
    private func checkUserDefaults() {
        let userDefaultsDictionary = defaults.dictionaryRepresentation()

        for (key, value) in userDefaultsDictionary {
            print("userDefaultsDictionary \(key): \(value)")
        }
    }
    
    // MARK: - setupActivityIndicator
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.color = MySpecialColors.MainColor
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
         ])
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false // 사용자 상호작용 비활성화
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true // 사용자 상호작용 활성화
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubviews(
            timeLabel, startStopButton, resetButton, imageView, cheeringLabel,
            dayView, dayStackView,
            successView, goDetailButton, successStackView, successTitleLabel, goDetailImage, successTextLabel
        )
        
        dayStackView.addArrangedSubviews(dayTitleLabel, dayLabel)
        
        setupConstraints()
        setupDayUI()
        setSuccessView()
    }
    
    // MARK: - setSuccessView
    private func setSuccessView() {
        successView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.top.equalTo(timeLabel.snp.bottom).offset(14)
            $0.leading.equalTo(view.snp.leading).offset(24)
            $0.trailing.equalTo(view.snp.trailing).offset(-24)
            $0.height.equalTo(100)
        }
        
        goDetailButton.snp.makeConstraints {
            $0.top.equalTo(successView.snp.top).offset(20)
            $0.leading.equalTo(successView.snp.leading).offset(24)
            $0.trailing.equalTo(successView.snp.trailing).offset(-24)
            $0.bottom.equalTo(successView.snp.bottom).offset(-20)
        }
        
        successStackView.snp.makeConstraints {
            $0.top.equalTo(goDetailButton.snp.top)
            $0.leading.equalTo(goDetailButton.snp.leading)
            $0.trailing.equalTo(goDetailButton.snp.trailing)
            $0.height.equalTo(18)
        }
        
        successTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(successStackView.snp.centerY)
            $0.leading.equalTo(successStackView.snp.leading)
        }
        
        goDetailImage.snp.makeConstraints {
            $0.centerY.equalTo(successStackView.snp.centerY)
            $0.trailing.equalTo(successStackView.snp.trailing)
            $0.width.equalTo(14)
            $0.height.equalTo(18)
        }
        
        successTextLabel.snp.makeConstraints {
            $0.top.equalTo(successStackView.snp.bottom).offset(8)
            $0.leading.equalTo(successView.snp.leading).offset(24)
            $0.trailing.equalTo(successView.snp.trailing).offset(-24)
            $0.bottom.equalTo(successView.snp.bottom).offset(-20)
        }
    }
    
    // MARK: - hideSuccessView
    private func hideSuccessView() {
        UIView.animate(withDuration: 0.2) {
            self.successView.alpha = 0.0
            self.successView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.successView.isHidden = true
            self.goDetailButton.isHidden = true
            self.successStackView.isHidden = true
            self.successTitleLabel.isHidden = true
            self.goDetailImage.isHidden = true
            self.successTextLabel.isHidden = true
        }
    }
    
    // MARK: - showSuccessView
    private func showSuccessView() {
        successView.isHidden = false
        goDetailButton.isHidden = false
        successStackView.isHidden = false
        successTitleLabel.isHidden = false
        goDetailImage.isHidden = false
        successTextLabel.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.successView.alpha = 1.0
            self.successView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func setupDayUI() {
        dayView.setContentHuggingPriority(.required, for: .horizontal)
        dayView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        dayTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        dayLabel.setContentHuggingPriority(.required, for: .horizontal)
        dayTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dayLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        dayView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.top).offset(-24)
            $0.centerX.equalTo(view.snp.centerX)
            $0.height.equalTo(26)
        }
        
        dayStackView.snp.makeConstraints {
            $0.top.equalTo(dayView.snp.top)
            $0.leading.equalTo(dayView.snp.leading).offset(8)
            $0.trailing.equalTo(dayView.snp.trailing).offset(-8)
            $0.bottom.equalTo(dayView.snp.bottom)
            $0.width.greaterThanOrEqualTo(dayTitleLabel.snp.width).offset(12)
            $0.width.greaterThanOrEqualTo(dayLabel.snp.width).offset(12)
        }
        
        dayTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(dayStackView.snp.centerY)
        }
        
        dayLabel.snp.makeConstraints {
            $0.centerY.equalTo(dayStackView.snp.centerY)
        }
    }
    
    private func setupConstraints() {
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(140)
            $0.centerX.equalToSuperview()
        }
        
        startStopButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-150)
            $0.leading.trailing.equalToSuperview().inset(74)
            $0.height.equalTo(46)
        }
        
        resetButton.snp.makeConstraints {
            $0.top.equalTo(startStopButton.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        cheeringLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(40)
            $0.centerX.equalTo(view.snp.centerX)
        }
    }
    
    // MARK: - Setup Background
    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        let gray1Color = MySpecialColors.Gray1.cgColor
        let blueColor = MySpecialColors.Blue.cgColor
        
        gradientLayer.colors = [
            gray1Color,
            blueColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 2.0)
        view.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Bubble
    private func setupBubbleEmitter() {
        let bubbleEmitter = CAEmitterLayer()
        bubbleEmitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: view.bounds.height * 0.85)
        bubbleEmitter.emitterShape = .line
        bubbleEmitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        let bubbleCell = CAEmitterCell()
        bubbleCell.contents = UIImage(named: "bubble")?.cgImage ?? createBubbleImage().cgImage
        bubbleCell.birthRate = 10
        bubbleCell.lifetime = 5.0
        bubbleCell.velocity = -50
        bubbleCell.velocityRange = -20
        bubbleCell.yAcceleration = -30
        bubbleCell.scale = 0.1
        bubbleCell.scaleRange = 0.2
        bubbleCell.alphaRange = 0.5
        bubbleCell.alphaSpeed = -0.1
        
        bubbleEmitter.emitterCells = [bubbleCell]
        view.layer.addSublayer(bubbleEmitter)
    }
    
    private func createBubbleImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    @objc private func goDetailButtonTapped(_ sender: UIButton) {
        guard let uid = uid else {
            print("Detail Page 이동 / 사용자 정보를 확인할 수 없음")
            return
        }
        
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: currentDate)
        
        let docRef = db.collection("user-info").document(uid).collection("study-sessions").document(day)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                let calendarDetailVC = CalendarDetailViewController()
                calendarDetailVC.data = data
                
                calendarDetailVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(calendarDetailVC, animated: true)
            } else {
                print("도큐먼트 데이터 없음")
            }
        }
    }
    
    // MARK: - Methods
    // 시작 시간 설정
    private func setStartTime(date: Date?) {
        startTime = date
        userDefaults.set(startTime, forKey: START_TIME_KEY) // UserDefaults에 시작 시간 저장
    }
    
    // 정지 시간 설정
    private func setStopTime(date: Date?) {
        stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY) // UserDefaults에 정지 시간 저장
    }
    
    // 타이머 작동 여부 설정
    private func setTimerCounting(_ value: Bool) {
        timerIsCounting = value
        userDefaults.set(timerIsCounting, forKey: COUNTING_KEY) // UserDefaults에 타이머 작동 여부 저장
    }
    
    @objc private func refreshValue() {
        if let start = startTime {
            let difference = Date().timeIntervalSince(start)
            setTimeLabel(Int(difference))
            
            let (currentGroup, totalGroups) = calculateCurrentGroup(difference: difference)
            
            if currentGroup != self.currentGroup {
                self.currentGroup = currentGroup
                updateImageView()
            }
        } else {
            stopTimer()
            setTimeLabel(0)
        }
    }
    
    private func calculateCurrentGroup(difference: TimeInterval) -> (currentGroup: Int, totalGroups: Int) {
        interval = (targetTimeData ?? 7.0) * 3600
        let totalGroups = 5
        let intervalBetweenImages = interval / Double(totalGroups - 1)
        let currentGroupNumber = Int(difference / intervalBetweenImages) + 1
        let newCurrentGroup = min(currentGroupNumber, totalGroups)
        return (newCurrentGroup, totalGroups)
    }
    
    private func updateImageView() {
        if currentGroup < 5 {
            imageView.image = UIImage(named: "Group \(currentGroup)")
        } else {
            imageView.image = UIImage(named: profileImageName)
        }
        
        NSLayoutConstraint.deactivate(imageView.constraints)
        
        imageView.snp.remakeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.bottom.equalTo(view.snp.bottom).offset(bottomConstraintConstant(for: currentGroup) + 20)
            $0.width.height.equalTo(84)
        }
        
        addBouncingAnimation(targetView: imageView)
    }
    
    private func addBouncingAnimation(targetView: UIView) {
        let moveDistance: CGFloat = 30 // 이동 거리
        let duration: TimeInterval = 1.6
        let damping: CGFloat = 1
        let velocity: CGFloat = 0
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.autoreverse, .repeat],
            animations: {
                targetView.transform = CGAffineTransform(translationX: 0, y: -moveDistance)
            },
            completion: nil
        )
    }
    
    private func bottomConstraintConstant(for index: Int) -> CGFloat {
        var constant: CGFloat = 0
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if UIScreen.main.nativeBounds.height == 2436 {
                constant = -244 - CGFloat(index * 20) // iPhone X, XS, 11 Pro, 12 Mini
            } else if UIScreen.main.nativeBounds.height == 2796 || UIScreen.main.nativeBounds.height == 1792 {
                constant = -244 - CGFloat(index * 50) // iPhone XS Max, 11 Pro Max, 12, 12 Pro
            } else if UIScreen.main.nativeBounds.height == 2556 { // iPhone 15Pro
                constant = -244 - CGFloat(index * 34)
            } else {
                constant = -244 - CGFloat(index * 20) // Other iPhones
            }
        default:
            constant = -244 - CGFloat(index * 30)
        }
        return constant
    }
    
    private func setTimeLabel(_ value: Int) {
        let time = secToHoursMinSec(value)
        let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
        timeLabel.text = timeString
        
        interval = (targetTimeData ?? 7.0) * 3600
        
        if value >= Int(interval) {
            showSuccessView()
            self.cheeringLabel.isHidden = true
        } else {
            self.cheeringLabel.isHidden = false
        }
    }
    
    private func secToHoursMinSec(_ seconds: Int) -> (Int, Int, Int) {
        let hour = seconds / 3600
        let min = (seconds % 3600) / 60
        let sec = (seconds % 3600) % 60
        return (hour, min, sec)
    }
    
    private func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    
    private func stopTimer() {
        scheduledTimer?.invalidate()
        setTimerCounting(false)
        UIView.transition(with: startStopButton, duration: 0.3, options: .transitionCrossDissolve) {
            self.startStopButton.setTitle("집중 모드 시작하기", for: .normal)
            self.startStopButton.setTitleColor(MySpecialColors.Gray1, for: .normal)
            self.startStopButton.backgroundColor = MySpecialColors.MainColor
        }
    }
    
    private func calcRestartTime(start: Date, stop: Date) -> Date {
        let difference = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(difference)
    }
    
    private func startTimer() {
        scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
        setTimerCounting(true)
        UIView.transition(with: startStopButton, duration: 0.3, options: .transitionCrossDissolve) {
            self.startStopButton.setTitle("집중 모드 중단하기", for: .normal)
            self.startStopButton.setTitleColor(MySpecialColors.Gray1, for: .normal)
            self.startStopButton.backgroundColor = MySpecialColors.Gray3
        }
        
        alertOnboarding.setAlertView(in: self)
    }
    
    // MARK: - Start Stop Actions
    @objc private func startStopAction(_ sender: Any) {
        if timerIsCounting {
            setStopTime(date: Date())
            stopTimer()
            pauseTimerData()
        } else {
            if let stop = stopTime {
                let restartTime = calcRestartTime(start: startTime!, stop: stop)
                setStopTime(date: nil)
                setStartTime(date: restartTime)
            } else {
                setStartTime(date: Date())
            }
            startTimer()
            startTimerButtonTapped()
        }
        
        checkAndResetTimerIfNeeded()
    }
    
    // MARK: - Reset Actions
    @objc private func resetAction(_ sender: Any) {
        alertPaths.cancelHandler = {
            print("리셋 취소")
        }
        
        alertPaths.confirmHandler = {
            print("리셋 확인")
            self.deleteTodayStudySessionData()
        }
        
        alertPaths.setAlertView(title: "타이머 초기화", subTitle: "초기화 시 마리모도 함께 초기화됩니다.", in: self)
    }
    
    // MARK: - Load Timer State
    private func loadTimerState() {
        startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerIsCounting = userDefaults.bool(forKey: COUNTING_KEY)
        
        if timerIsCounting { // 타이머가 작동 중이면?
            startTimer() // 타이머 시작
            scheduleNotification() // 알람
        } else { // 타이머가 정지 중이면?
            stopTimer() // 타이머 정지
            if let start = startTime, let stop = stopTime { // 시작 시간과 정지 시간이 모두 존재하면?
                let time = calcRestartTime(start: start, stop: stop) // 재시작 시간 계산
                let difference = Date().timeIntervalSince(time) // 현재 시간과의 차이 계산
                setTimeLabel(Int(difference)) // 시간 라벨 업데이트
                
                interval = (targetTimeData ?? 7.0) * 3600
                print("loadTimerState\(interval)")
                
                let (currentGroup, totalGroups) = calculateCurrentGroup(difference: difference)
                self.currentGroup = currentGroup
                
                updateImageView()
            } else { // 시작 시간 또는 정지 시간이 없으면?
                setTimeLabel(0) // 시간 라벨 초기화
                currentGroup = 1 // currentGroup 변수를 1로 설정
                updateImageView() // 이미지뷰 업데이트
            }
        }
        hideLoadingIndicator() // 로딩 인디케이터 중지
    }
    
    // MARK: - Helper Methods >> "00:00:00" formatTime
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
    
    // MARK: - Helper Methods >> "yyyy-MM-dd" formattedDate
    private func getCurrentFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - Firebase - User Data Fetch
    private func fetchUserDataAndBindUI() {
        guard let uid = uid else {
            print("사용자 정보를 확인할 수 없음")
            return
        }
        
        db.collection("user-info").document(uid).addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("문서를 가져오는 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = documentSnapshot else {
                print("문서가 존재하지 않음")
                return
            }
            
            if !snapshot.exists {
                print("문서가 비어 있습니다.")
                return
            }
            
            let documentData = snapshot.data() ?? [:]
            self.bindUIData(with: documentData)
            print("Data: \(documentData)")
            
            if let imageName = documentData["profile-image"] as? String {
                self.profileImageName = imageName
                print("profileImageNameprofileImageNameprofileImageName \(profileImageName)")
            } else {
                print("No profile-image")
                self.profileImageName = "Group 9"
            }
            
            if let targetTimeString = documentData["target-time"] as? String,
               let hours = Int(targetTimeString) {
                
                targetTimeData = Double(hours)
                updateImageView()
                
                loadTimerState()
            } else {
                print("No target-time")
            }
        }
    }
    
    // MARK: - D-Day 변환
    private func convertDateToDDay(targetDate: Date, isTodayIncluded: Bool) -> String {
        let currentDate = Date()
        let calendar = Calendar.current

        let currentDateStripped = calendar.startOfDay(for: currentDate)
        let targetDateStripped = calendar.startOfDay(for: targetDate)

        var components = calendar.dateComponents([.day], from: currentDateStripped, to: targetDateStripped)

        guard let days = components.day else {
            return "No days"
        }

        if days > 0 {
            return "D-\(days)"
        } else if days == 0 {
            return "D-day"
        } else {
            return "D+\(-days)"
        }
    }

    // MARK: - bindUIData
    private func bindUIData(with data: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let title = data["d-day-title"] as? String, !title.isEmpty {
                self.dayTitleLabel.text = title
                dayView.backgroundColor = MySpecialColors.DayBlue
            } else {
                print("No d-day-title")
                self.dayTitleLabel.text = "D-day는"
                dayView.backgroundColor = .clear
            }
            
            if let dDayTimestamp = data["d-day-date"] as? Timestamp {
                let targetDate = dDayTimestamp.dateValue()
                let isTodayIncluded = data["isTodayIncluded"] as? Bool ?? false
                let dDayText = self.convertDateToDDay(targetDate: targetDate, isTodayIncluded: isTodayIncluded)
                
                self.dayLabel.text = dDayText
                self.dayView.backgroundColor = MySpecialColors.DayBlue
                print("D-day: \(dDayText)")
            } else {
                print("No d-day")
                self.dayLabel.text = "프로필에서 설정할 수 있어요."
                self.dayView.backgroundColor = .clear
            }
        }
    }
    
    // MARK: - study-sessions 데이터 경로
    private var studySessionDocumentPath: String? {
        guard let uid = uid else {
            print("사용자 정보를 확인할 수 없음")
            return nil
        }
        return "user-info/\(uid)/study-sessions"
    }
    
    // MARK: - study-sessions 가져오기
    func checkAndResetTimerIfNeeded() {
        guard let path = studySessionDocumentPath else {
            print("집중 모드 데이터 저장 실패: pauseTimerData / 사용자 정보를 확인할 수 없음")
            return
        }
        
        let day = getCurrentFormattedDate()
        
        db.collection(path).document(day).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }
            
            if let document = documentSnapshot, document.exists {
                print("오늘 날짜인 문서가 이미 존재합니다.")
            } else {
                print("오늘 날짜인 문서가 존재하지 않습니다. 타이머를 초기화합니다.")

                self.resetTimer()
                self.startTimer()
                self.startTimerButtonTapped()
            }
        }
    }
    
    private func resetTimer() {
        print("문서 존재 X: 집중 모드 데이터 삭제")
        self.setStopTime(date: nil)
        self.setStartTime(date: nil)
        self.timeLabel.text = self.makeTimeString(hour: 0, min: 0, sec: 0)
        self.stopTimer()
        self.hideSuccessView()
        self.cheeringLabel.isHidden = false
        
        self.currentGroup = 1
        self.updateImageView()
    }
    
    // MARK: - Firebase Save - 시작 데이터
    private func startTimerButtonTapped() {
        guard let path = studySessionDocumentPath else {
            print("집중 모드 데이터 저장 실패: startTimerButtonTapped / 사용자 정보를 확인할 수 없음")
            return
        }
        
        isStudy = true
        
        let currentDate = Date()
        let day = getCurrentFormattedDate()
        currentSessionID = day
        
        db.collection(path).document(day).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                self?.updateIsStudy(true, day: day, path: path)
            } else {
                self?.saveNewData(day: day, startTime: currentDate, path: path)
            }
        }
    }
    
    private func saveNewData(day: String, startTime: Date, path: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let startTimeString = formatter.string(from: startTime)
        
        let data: [String: Any] = [
            "day": day,
            "start-time": startTimeString,
            "isStudy": isStudy,
            "marimo-state": "",
            "marimo-name": "",
            "last-time": "",
            "total-time": "",
            "day-memo": "",
        ]
        
        db.collection(path).document(day).setData(data) { error in
            if let error = error {
                print("시작 시간을 저장하는 동안 오류 발생 \(error.localizedDescription)")
            } else {
                print("시작 시간 저장 성공")
            }
        }
    }
    
    private func updateIsStudy(_ isCurrentlyStudying: Bool, day: String, path: String) {
        isStudy = isCurrentlyStudying
        
        db.collection(path).document(day).updateData([
            "isStudy": isStudy
        ]) { error in
            if let error = error {
                print("isStudy 상태를 업데이트하는 중에 오류 발생 \(error.localizedDescription)")
            } else {
                print("isStudy 상태 업데이트 성공")
            }
        }
    }
    
    // MARK: - Firebase Save - 중단 데이터
    private func pauseTimerData() {
        guard let path = studySessionDocumentPath else {
            print("집중 모드 데이터 저장 실패: pauseTimerData / 사용자 정보를 확인할 수 없음")
            return
        }
        
        guard let startTime = startTime else {
            print("집중 모드 데이터 업데이트 실패: startTime를 확인할 수 없음")
            return
        }
        
        let currentDate = Date()
        let elapsedTime = currentDate.timeIntervalSince(startTime) + totalTimeElapsed
        
        totalTimeElapsed = elapsedTime
        
        let day = getCurrentFormattedDate()
        
        formatter.dateFormat = "HH:mm:ss"
        let lastTime = formatter.string(from: currentDate)
        let formattedTotalTime = formatTime(elapsedTime)
        
        db.collection(path).document(day).updateData([
            "isStudy": false,
            "marimo-state": currentGroup,
            "marimo-name": profileImageName,
            "last-time": lastTime,
            "total-time": formattedTotalTime
        ]) { error in
            if let error = error {
                print("상태를 업데이트하는 중에 오류 발생: \(error.localizedDescription)")
            } else {
                print("상태 업데이트 성공")
                self.totalTimeElapsed = 0.0
            }
        }
    }
    
    // MARK: - Firebase Delete - 집중 모드 리셋
    @objc private func deleteTodayStudySessionData() {
        guard let path = studySessionDocumentPath else {
            print("집중 모드 데이터 저장 실패: deleteTodayStudySessionData / 사용자 정보를 확인할 수 없음")
            return
        }
        
        let day = getCurrentFormattedDate()
        
        db.collection(path).document(day).delete { error in
            if let error = error {
                print("집중 모드 데이터 삭제 오류: \(error.localizedDescription)")
            } else {
                print("집중 모드 데이터 삭제")
                self.setStopTime(date: nil)
                self.setStartTime(date: nil)
                self.timeLabel.text = self.makeTimeString(hour: 0, min: 0, sec: 0)
                self.stopTimer()
                self.hideSuccessView()
                self.cheeringLabel.isHidden = false
                
                self.currentGroup = 1
                self.updateImageView()
            }
        }
    }
    
    // MARK: - NotificationCenter
    private func requestNotificationAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("알림 승인 승인")
            } else {
                print("알림 승인 거부")
            }
        }
    }
    
    private func scheduleNotification() {
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 00
        
        let content = UNMutableNotificationContent()
        content.title = "리모리모: 하루를 마무리해 볼까요?"
        content.body = "집중 시간과 ToDo 확인하러 가기"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: NOTIFICATION_KEY, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("알람 오류 \(error.localizedDescription)")
            } else {
                print("알람 성공")
            }
        }
    }
}
