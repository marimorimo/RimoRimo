//
//  MainViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import UserNotifications
import FirebaseFirestore

class MainViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    // MARK: - Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    private let firebaseMainManager = FirebaseMainManager.shared
    
    private let START_TIME_KEY = "startTime"
    private let STOP_TIME_KEY = "stopTime"
    private let COUNTING_KEY = "countingKey"
    private let NOTIFICATION_KEY = "RimoRimoDayNotification"
    
    // MARK: - Timer Properties
    private var timerIsCounting: Bool = false
    private var startTime: Date?
    private var stopTime: Date?
    private var scheduledTimer: Timer!
    
    // MARK: - Firebase Properties
    private var profileImageName: String = ""
    private var interval: Double = 0
    private var targetTimeData: Double = 0
    private var currentGroup = 1
    private var isStudy: Bool = false
    private var totalTimeElapsed: TimeInterval = 0
    private let formatter = DateFormatter()
    private var currentSessionID: String?
    private var currentUid: String?
    private var studySessionDocumentPath: String? {
        guard let uid = currentUid else {
            print("사용자 정보를 확인할 수 없음")
            return nil
        }
        return "user-info/\(uid)/study-sessions"
    }

    // MARK: - View
    private let stopwatchView = StopwatchView()
    private let marimoView = MarimoView()
    private let activityIndicatorHelper = ActivityIndicatorHelper()
    
    // MARK: - Alert UI
    private let alertPaths = AlertPaths()
    private let alertOnboarding = AlertOnboarding()
    
    // MARK: - Marimo Image Properties
    private lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.image = UIImage(named: "Group \(self.currentGroup)")
    }
    
    // MARK: - View lifecycle
    override func loadView() {
        view = stopwatchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(imageView)
        notificationCenter.delegate = self
        requestNotificationAuthorization()
        
        currentUid = FirebaseMainManager.shared.currentUid

        fetchUserDataAndBindUI()
        getTimerUserDefaults()
        setupButtons()
        
        activityIndicatorHelper.activityIndicator.startAnimating()
        firebaseMainManager.checkAndResetTimerIfNeeded(currentUid: currentUid) {
            // 오늘 날짜 데이터가 없다면 타이머 초기화
            self.resetSessionData()
            self.activityIndicatorHelper.activityIndicator.stopAnimating()
            print("resetSessionData 초기화")
        }
    }
    
    private func loadTimer() {
        if timerIsCounting {
            startTimer()
            scheduleNotification() // 알람
        } else {
            stopTimer()
            if let start = startTime {
                if let stop = stopTime {
                    let time = calcRestartTime(start: start, stop: stop)
                    let difference = Date().timeIntervalSince(time)
                    setTimeLabel(Int(difference))
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stopwatchView.successView.isHidden = true
        stopwatchView.cheeringLabel.isHidden = false
        AnimationHelper.addBouncingAnimation(to: imageView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnimationHelper.removeBouncingAnimation(from: imageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - setup Buttons
    private func setupButtons() {
        stopwatchView.startStopButton.addTarget(self, action: #selector(startStopAction), for: .touchUpInside)
        stopwatchView.resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        stopwatchView.successView.goDetailButton.addTarget(self, action: #selector(goDetailButtonTapped), for: .touchUpInside)
    }
  
    // MARK: - get Timer UserDefaults
    private func getTimerUserDefaults() {
        startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerIsCounting = userDefaults.bool(forKey: COUNTING_KEY)
    }
    
    // MARK: - save Timer UserDeaults
    func setStartTime(date: Date?) {
        startTime = date
        userDefaults.set(startTime, forKey: START_TIME_KEY)
    }
    
    func setStopTime(date: Date?) {
        stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
        pauseTimerData()
    }
    
    func setTimerCounting(_ value: Bool) {
        timerIsCounting = value
        userDefaults.set(timerIsCounting, forKey: COUNTING_KEY)
    }
    
    // MARK: - Timer Methods
    @objc func refreshValue() {
        if let start = startTime {
            let difference = Date().timeIntervalSince(start)
            setTimeLabel(Int(difference))
            
            let (currentGroup, totalGroups) = calculateCurrentGroup(difference: difference)
            
            if currentGroup != self.currentGroup {
                self.currentGroup = currentGroup
                // print("currentGroupcurrentGroup\(currentGroup)")
                updateImageView()
            }
        } else {
            stopTimer()
            setTimeLabel(0)
        }
    }
    
    // MARK: - set TimerLabel
    func setTimeLabel(_ value: Int) {
        let time = secToHoursMinSec(value)
        let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
        stopwatchView.timeLabel.text = timeString
        
        interval = (targetTimeData ?? 7.0) * 60 // 테스트 시 60 | 배포 시 3600
        
        if value >= Int(interval) {
            stopwatchView.successView.isHidden = false
            stopwatchView.cheeringLabel.isHidden = true
        } else {
            stopwatchView.successView.isHidden = true
            stopwatchView.cheeringLabel.isHidden = false
        }
    }
    
    func secToHoursMinSec(_ ms: Int) -> (Int, Int, Int) {
        let hour = ms / 3600
        let min = (ms % 3600) / 60
        let sec = (ms % 3600) % 60
        return (hour, min, sec)
    }
    
    func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    
    func calcRestartTime(start: Date, stop: Date) -> Date {
        let difference = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(difference)
    }
    
    // MARK: - stop Timer & Button Change
    func stopTimer() {
        if scheduledTimer != nil { scheduledTimer.invalidate() }
        setTimerCounting(false)
        
        UIView.transition(with: stopwatchView.startStopButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.stopwatchView.startStopButton.setTitle("집중 모드 시작하기", for: .normal)
            self.stopwatchView.startStopButton.setTitleColor(MySpecialColors.Gray1, for: .normal)
            self.stopwatchView.startStopButton.backgroundColor = MySpecialColors.MainColor
        }, completion: nil)
    }
    
    // MARK: - start Timer & Button Change
    func startTimer() {
        scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
        setTimerCounting(true)
        
        UIView.transition(with: stopwatchView.startStopButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.stopwatchView.startStopButton.setTitle("집중 모드 중단하기", for: .normal)
            self.stopwatchView.startStopButton.setTitleColor(MySpecialColors.Gray1, for: .normal)
            self.stopwatchView.startStopButton.backgroundColor = MySpecialColors.Gray3
        }, completion: nil)
    }
    
    // MARK: - Timer Actions
    @objc func startStopAction(_ sender: Any) {
        if timerIsCounting {
            setStopTime(date: Date())
            stopTimer()
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
            alertOnboarding.setAlertView(in: self)
        }
    }
    
    // MARK: - Reset Timer
    @objc func resetAction(_ sender: Any) {
        alertPaths.cancelHandler = {
            print("리셋 취소")
        }
        
        alertPaths.confirmHandler = {
            print("리셋 확인")
            self.deleteTodayStudySessionData()
        }
        
        alertPaths.setAlertView(title: "타이머 초기화", subTitle: "초기화 시 마리모도 함께 초기화됩니다.", in: self)
    }
    
    // MARK: - goDetailButtonTapped
    @objc private func goDetailButtonTapped(_ sender: UIButton) {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: currentDate)
        
        FirebaseMainManager.shared.getStudySession(date: day) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let calendarDetailVC = CalendarDetailViewController()
                    calendarDetailVC.data = data
                    calendarDetailVC.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(calendarDetailVC, animated: true)
                }
            case .failure(let error):
                print("도큐먼트 데이터 없음: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Image Timer Connection
    private func calculateCurrentGroup(difference: TimeInterval) -> (currentGroup: Int, totalGroups: Int) {
        interval = (targetTimeData ?? 7.0) * 60 // 테스트 시 60 | 배포 시 3600
        // print("intervalinterval \(interval)")
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
        AnimationHelper.addBouncingAnimation(to: imageView)
    }

    private func bottomConstraintConstant(for index: Int) -> CGFloat {
        var constant: CGFloat = 0
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            let screenHeight = UIScreen.main.nativeBounds.height
            if screenHeight == 2436 {
                constant = -244 - CGFloat(index * 24) // iPhone X, XS, 11 Pro, 12 Mini
            } else if screenHeight == 2796 || screenHeight == 1792 {
                constant = -244 - CGFloat(index * 44) // iPhone XS Max, 11 Pro Max, 11, 12, 12 Pro, iPhone XR
            } else if screenHeight == 2556 { // iPhone 15Pro
                constant = -244 - CGFloat(index * 34)
            } else {
                constant = -244 - CGFloat(index * 24) // Other iPhones
            }
        default:
            constant = -244 - CGFloat(index * 24)
        }
        return constant
    }

    // MARK: - Date & Time Formatter
    private func getCurrentFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
    
    // MARK: - Firebase - User Data Fetch
    private func fetchUserDataAndBindUI() {
        activityIndicatorHelper.activityIndicator.startAnimating()
        firebaseMainManager.fetchUserData { [weak self] data, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Document does not exist")
                return
            }
            
            self.bindUIData(with: data)
            print("Data: \(data)")
            
            if let imageName = data["profile-image"] as? String {
                self.profileImageName = imageName
                // print("profileImageName \(self.profileImageName)")
            } else {
                print("No profile-image")
                self.profileImageName = "Group 9"
            }
            
            if let targetTimeString = data["target-time"] as? String,
               let hours = Int(targetTimeString) {
                
                targetTimeData = Double(hours)
                if let start = startTime, let stop = stopTime { // 시작 시간과 정지 시간이 모두 존재하면?
                    let time = calcRestartTime(start: start, stop: stop) // 재시작 시간 계산
                    let difference = Date().timeIntervalSince(time) // 현재 시간과의 차이 계산
                    
                    interval = (targetTimeData ?? 7.0) * 3600
                    // print("loadTimerState\(interval)")
                    
                    let (currentGroup, totalGroups) = calculateCurrentGroup(difference: difference)
                    self.currentGroup = currentGroup
                }
                updateImageView()
                loadTimer()
                // print("targetTimeString: \(targetTimeData)")
            } else {
                print("No target-time")
            }
        }
        activityIndicatorHelper.activityIndicator.stopAnimating()
    }
    
    // MARK: - D-Day 변환
    private func convertDateToDDay(targetDate: Date, isTodayIncluded: Bool) -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let currentDateStripped = calendar.startOfDay(for: currentDate)
        let targetDateStripped = calendar.startOfDay(for: targetDate)
        
        let components = calendar.dateComponents([.day], from: currentDateStripped, to: targetDateStripped)
        
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
                stopwatchView.dayTitleLabel.text = title
                stopwatchView.dayView.backgroundColor = MySpecialColors.DayBlue
            } else {
                print("No d-day-title")
                stopwatchView.dayTitleLabel.text = "D-day는"
                stopwatchView.dayView.backgroundColor = .clear
            }
            
            if let dDayTimestamp = data["d-day-date"] as? Timestamp {
                let targetDate = dDayTimestamp.dateValue()
                let isTodayIncluded = data["isTodayIncluded"] as? Bool ?? false
                let dDayText = self.convertDateToDDay(targetDate: targetDate, isTodayIncluded: isTodayIncluded)
                
                stopwatchView.dayLabel.text = dDayText
                stopwatchView.dayView.backgroundColor = MySpecialColors.DayBlue
                // print("D-day: \(dDayText)")
            } else {
                print("No d-day")
                stopwatchView.dayLabel.text = "프로필에서 설정할 수 있어요."
                stopwatchView.dayView.backgroundColor = .clear
            }
        }
    }
    
    // MARK: - Save Firebase Data
    private func startTimerButtonTapped() {
        guard let path = studySessionDocumentPath else {
            print("집중 모드 데이터 저장 실패: startTimerButtonTapped / 사용자 정보를 확인할 수 없음")
            return
        }
        
        isStudy = true
        
        let currentDate = Date()
        let day = getCurrentFormattedDate()
        currentSessionID = day
        
        firebaseMainManager.getDocument(path: path, day: day) { [weak self] result in
            switch result {
            case .success:
                self?.updateIsStudy(true, day: day, path: path)
            case .failure:
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
        
        firebaseMainManager.saveData(path: path, day: day, data: data) { result in
            switch result {
            case .success:
                print("시작 시간 저장 성공")
            case .failure(let error):
                print("시작 시간을 저장하는 동안 오류 발생 \(error.localizedDescription)")
            }
        }
    }
    
    private func updateIsStudy(_ isStudy: Bool, day: String, path: String) {
        let data: [String: Any] = ["isStudy": isStudy]
        
        firebaseMainManager.updateData(path: path, day: day, data: data) { result in
            switch result {
            case .success:
                print("isStudy 업데이트 성공")
            case .failure(let error):
                print("isStudy 업데이트 중 오류 발생 \(error.localizedDescription)")
            }
        }
    }
    
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
        
        let data: [String: Any] = [
            "isStudy": false,
            "marimo-state": currentGroup,
            "marimo-name": profileImageName,
            "last-time": lastTime,
            "total-time": formattedTotalTime
        ]
        
        firebaseMainManager.updateData(path: path, day: day, data: data) { result in
            switch result {
            case .success:
                print("상태 업데이트 성공")
                self.totalTimeElapsed = 0.0
            case .failure(let error):
                print("상태를 업데이트하는 중에 오류 발생: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Reset Firebase Data
    @objc private func deleteTodayStudySessionData() {
        guard let path = studySessionDocumentPath else {
            print("집중 모드 데이터 저장 실패: deleteTodayStudySessionData / 사용자 정보를 확인할 수 없음")
            return
        }
        
        let day = getCurrentFormattedDate()
        
        firebaseMainManager.deleteData(path: path, day: day) { result in
            switch result {
            case .success:
                print("집중 모드 데이터 삭제 성공")
                self.resetSessionData()
            case .failure(let error):
                print("집중 모드 데이터 삭제 오류: \(error.localizedDescription)")
            }
        }
    }
    
    private func resetSessionData() {
        setStopTime(date: nil)
        setStartTime(date: nil)
        stopwatchView.timeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
        stopTimer()
        stopwatchView.successView.isHidden = true
        stopwatchView.cheeringLabel.isHidden = false
        clearUserDefaults()
        
        currentGroup = 1
        updateImageView()
    }
    
    // MARK: - Reset userDefaults Data
    func clearUserDefaults() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: START_TIME_KEY)
        userDefaults.removeObject(forKey: STOP_TIME_KEY)
        userDefaults.removeObject(forKey: COUNTING_KEY)
        userDefaults.synchronize()
    }
    
    // MARK: - NotificationCenter
    private func requestNotificationAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("알림 승인")
                self.scheduleNotification() // 권한 승인 후 알림 스케줄링
            } else {
                print("알림 승인 거부")
            }
            if let error = error {
                print("알림 권한 요청 에러: \(error.localizedDescription)")
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
