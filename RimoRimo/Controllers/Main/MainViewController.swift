//
//  MainViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MainViewController: UIViewController {
    private var currentMarimoIndex = -1
    private var marimoImages: [UIImageView] = []
    private var profileImageName: String = ""
    private var marimoTimer: Timer?
    private var timerInterval: TimeInterval?
    
    private var timerIsCounting: Bool = false
    private var startTime: Date?
    private var stopTime: Date?
    private let userDefaults = UserDefaults.standard
    private let START_TIME_KEY = "startTime"
    private let STOP_TIME_KEY = "stopTime"
    private let COUNTING_KEY = "countingKey"
    
    private var scheduledTimer: Timer!
    private var timerStartDate: Date?
    private var totalTimeElapsed: TimeInterval = 0
    private var isStudy = false
    private var currentSessionID: String?
    
    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }
    
    private var checkAction: (() -> Void)?
    private var cancelAction: (() -> Void)?
    
    // MARK: - HeaderView
    private let HeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let dayView: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.DayBlue
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    private let dayStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private let dayTitleLabel: UILabel = {
        let text = UILabel()
        text.text = "토익 시험"
        text.textColor = MySpecialColors.Black
        text.font = UIFont.pretendard(style: .medium, size: 16, isScaled: true)
        return text
    }()
    
    private let dayLabel: UILabel = {
        let text = UILabel()
        text.text = "D-30"
        text.textColor = MySpecialColors.MainColor
        if #available(iOS 13.0, *) {
            let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
            text.font = UIFontMetrics.default.scaledFont(for: monospacedFont)
        } else {
            text.font = UIFont(name: "Courier-Bold", size: 16)
        }
        return text
    }()
    
    private let timeLabel: UILabel = {
        let text = UILabel()
        text.text = "00:00:00"
        text.textColor = MySpecialColors.Black
        if #available(iOS 13.0, *) {
            let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 72, weight: .semibold)
            text.font = UIFontMetrics.default.scaledFont(for: monospacedFont)
        } else {
            text.font = UIFont(name: "Courier", size: 72)
        }
        return text
    }()
    
    private let cheeringLabel: UILabel = {
        let text = UILabel()
        text.text = "마리모가 응원해줄 거예요!" // 데이터
        text.textColor = MySpecialColors.Gray4
        text.font = UIFont.pretendard(style: .regular, size: 14, isScaled: true)
        return text
    }()
    
    private let startTimerButton = TabButtonUIFactory.doubleCheckButton(buttonTitle: "집중 모드 시작하기", textColor: MySpecialColors.MainColor, cornerRadius: 24, backgroundColor: MySpecialColors.Gray1)
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("RESET", for: .normal)
        button.titleLabel?.font = UIFont.pretendard(style: .medium, size: 14, isScaled: true)
        button.setTitleColor(MySpecialColors.Gray3, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - SuccessView
    private let successView: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Blue.withAlphaComponent(0.6)
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let successStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private let successTitleLabel: UILabel = {
        let text = UILabel()
        text.text = "마리모의 성장이 완료되었어요!"
        text.textColor = MySpecialColors.Black
        text.font = UIFont.pretendard(style: .bold, size: 18, isScaled: true)
        return text
    }()
    
    private let goDetailButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(goDetailButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let goDetailImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.right")
        image.tintColor = MySpecialColors.Black
        return image
    }()
    
    private let successTextLabel: UILabel = {
        let text = UILabel()
        text.text = """
        마리모가 생성되었습니다!
        성장이 완료된 마리모를 확인해 보세요.
        """
        text.textColor = MySpecialColors.Black
        text.font = UIFont.pretendard(style: .regular, size: 14, isScaled: true)
        text.numberOfLines = 0
        text.lineBreakMode = .byWordWrapping
        return text
    }()
    
    // MARK: - AlertUIFactory
    private let alertBack = AlertUIFactory.alertBackView()
    private let alertView = AlertUIFactory.alertView()
    
    private let alertTitle = AlertUIFactory.alertTitle(titleText: "차단 해제", textColor: MySpecialColors.Black, fontSize: 16)
    private let alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: "차단을 해제하시겠습니까?", textColor: MySpecialColors.Gray4, fontSize: 14)
    
    private let widthLine = AlertUIFactory.widthLine()
    private let heightLine = AlertUIFactory.heightLine()
    
    private let cancleView = AlertUIFactory.checkView()
    private let cancleLabel = AlertUIFactory.checkLabel(cancleText: "취소", textColor: MySpecialColors.Red, fontSize: 14)

    private let checkView = AlertUIFactory.checkView()
    private let checkLabel = AlertUIFactory.checkLabel(cancleText: "확인", textColor: MySpecialColors.MainColor, fontSize: 14)
    
    // MARK: - Onboarding Alert
    private let onboardingBackView = AlertUIFactory.alertBackView()
    private let onboardingView = AlertUIFactory.alertView()
    private let onboardingText = AlertUIFactory.alertSubTitle(subTitleText: "자정(12시) 전에 꼭 집중 모드를 중단해 주세요!", textColor: MySpecialColors.Black, fontSize: 14)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MySpecialColors.Gray1
        // Load saved data
        startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerIsCounting = userDefaults.bool(forKey: COUNTING_KEY)
                
        hideSuccessView()
        cheeringLabel.isHidden = false
        
        setupBackground()
        setupBubbleEmitter()
        setupHeaderView()
        setupTapButton()
        setupResetButton()
        setSuccessView()
        
        fetchUserDataAndBindUI()
        
        if timerIsCounting {
            // Timer start
            startTimer()
            updateMarimoImage()

            if let startTime = startTime, let timerInterval = timerInterval {
                let elapsedTime = Date().timeIntervalSince(startTime)
                let delay = timerInterval - (elapsedTime.truncatingRemainder(dividingBy: timerInterval))
                startMarimoTimer(withDelay: delay)
            } else {
                print("Error: startTime or timerInterval is nil")
            }
        } else {
            // Timer stop
            stopTimer()
            stopMarimoTimer()
            
            if let start = startTime, let stop = stopTime {
                let time = calcRestartTime(start: start, stop: stop)
                let difference = Date().timeIntervalSince(time)
                setTimeLabel(Int(difference))
                updateMarimoImage()
            } else {
                setTimeLabel(0)
            }
        }
        
        if let processedTime = timerInterval {
            print("마리모 변환 시간 간격: \(processedTime)")
        } else {
            print("마리모 변환 시간 간격 없음")
        }
        
        checkAndResetTimerIfNeeded()
    }
    
    // MARK: - Setup HeaderView
    private func setupHeaderView() {
        view.addSubview(HeaderView)
        HeaderView.addSubview(dayView)
        dayView.addSubview(dayStackView)
        dayStackView.addArrangedSubview(dayTitleLabel)
        dayStackView.addArrangedSubview(dayLabel)
        
        HeaderView.addSubview(timeLabel)
        HeaderView.addSubview(cheeringLabel)
        
        HeaderView.translatesAutoresizingMaskIntoConstraints = false
        dayView.translatesAutoresizingMaskIntoConstraints = false
        dayStackView.translatesAutoresizingMaskIntoConstraints = false
        dayTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        cheeringLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            HeaderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 106),
            HeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            HeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            HeaderView.heightAnchor.constraint(equalToConstant: 200),
            
            dayView.topAnchor.constraint(equalTo: HeaderView.topAnchor),
            dayView.centerXAnchor.constraint(equalTo: HeaderView.centerXAnchor),
            dayView.heightAnchor.constraint(equalToConstant: 26),
            
            dayStackView.topAnchor.constraint(equalTo: dayView.topAnchor),
            dayStackView.leadingAnchor.constraint(equalTo: dayView.leadingAnchor, constant: 8),
            dayStackView.trailingAnchor.constraint(equalTo: dayView.trailingAnchor, constant: -8),
            dayStackView.bottomAnchor.constraint(equalTo: dayView.bottomAnchor),
            dayStackView.widthAnchor.constraint(greaterThanOrEqualTo: dayTitleLabel.widthAnchor, constant: 12),
            dayStackView.widthAnchor.constraint(greaterThanOrEqualTo: dayLabel.widthAnchor, constant: 12),
            
            dayTitleLabel.centerYAnchor.constraint(equalTo: dayStackView.centerYAnchor),
            
            dayLabel.centerYAnchor.constraint(equalTo: dayStackView.centerYAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: dayView.bottomAnchor, constant: 18),
            timeLabel.centerXAnchor.constraint(equalTo: HeaderView.centerXAnchor),
            
            cheeringLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 40),
            cheeringLabel.centerXAnchor.constraint(equalTo: HeaderView.centerXAnchor),
        ])
    }
    
    // MARK: - Setup TapButton
    private func setupTapButton() {
        view.addSubview(startTimerButton)
        
        startTimerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startTimerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -142),
            startTimerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 84),
            startTimerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -84),
            startTimerButton.heightAnchor.constraint(equalToConstant: 46),
        ])
        
        startTimerButton.addTarget(self, action: #selector(startStopAction), for: .touchUpInside)
    }
    
    private func setupResetButton() {
        view.addSubview(resetButton)
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: startTimerButton.bottomAnchor, constant: 6),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 84),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -84),
        ])
        
        resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
    }
    
    // MARK: - setSuccessView
    private func setSuccessView() {
        view.addSubview(successView)
        view.addSubview(goDetailButton)
        goDetailButton.addSubview(successStackView)
        successStackView.addArrangedSubview(successTitleLabel)
        successStackView.addArrangedSubview(goDetailImage)
        goDetailButton.addSubview(successTextLabel)
        
        successView.translatesAutoresizingMaskIntoConstraints = false
        successStackView.translatesAutoresizingMaskIntoConstraints = false
        successTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        goDetailButton.translatesAutoresizingMaskIntoConstraints = false
        goDetailImage.translatesAutoresizingMaskIntoConstraints = false
        successTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            successView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 14),
            successView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            successView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            successView.heightAnchor.constraint(equalToConstant: 100),
            
            goDetailButton.topAnchor.constraint(equalTo: successView.topAnchor, constant: 20),
            goDetailButton.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 24),
            goDetailButton.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -24),
            goDetailButton.bottomAnchor.constraint(equalTo: successView.bottomAnchor, constant: -20),
            
            successStackView.topAnchor.constraint(equalTo: goDetailButton.topAnchor),
            successStackView.leadingAnchor.constraint(equalTo: goDetailButton.leadingAnchor),
            successStackView.trailingAnchor.constraint(equalTo: goDetailButton.trailingAnchor),
            successStackView.heightAnchor.constraint(equalToConstant: 18),
            
            successTitleLabel.centerYAnchor.constraint(equalTo: successStackView.centerYAnchor),
            successTitleLabel.leadingAnchor.constraint(equalTo: successStackView.leadingAnchor),
            
            goDetailImage.centerYAnchor.constraint(equalTo: successStackView.centerYAnchor),
            goDetailImage.trailingAnchor.constraint(equalTo: successStackView.trailingAnchor),
            goDetailImage.widthAnchor.constraint(equalToConstant: 14),
            goDetailImage.heightAnchor.constraint(equalToConstant: 18),
            
            successTextLabel.topAnchor.constraint(equalTo: successStackView.bottomAnchor, constant: 8),
            successTextLabel.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 24),
            successTextLabel.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -24),
            successTextLabel.bottomAnchor.constraint(equalTo: successView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - hideSuccessView
    private func hideSuccessView() {
        successView.isHidden = true
        goDetailButton.isHidden = true
        successStackView.isHidden = true
        successTitleLabel.isHidden = true
        goDetailImage.isHidden = true
        successTextLabel.isHidden = true
    }
    
    // MARK: - showSuccessView
    private func showSuccessView() {
        successView.isHidden = false
        goDetailButton.isHidden = false
        successStackView.isHidden = false
        successTitleLabel.isHidden = false
        goDetailImage.isHidden = false
        successTextLabel.isHidden = false
    }
    
    // MARK: - setAlertView
    @objc private func setAlertView(title: String, subTitle: String, checkTitle: String = "확인", cancelTitle: String = "취소", checkAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) {
        let alertTitle = AlertUIFactory.alertTitle(titleText: title, textColor: MySpecialColors.Black, fontSize: 16)
        let alertSubTitle = AlertUIFactory.alertSubTitle(subTitleText: subTitle, textColor: MySpecialColors.Gray4, fontSize: 14)
        
        checkView.isUserInteractionEnabled = true
        
        view.addSubview(alertBack)
        alertBack.addSubview(alertView)
        alertView.addSubview(alertTitle)
        alertView.addSubview(alertSubTitle)
        alertView.addSubview(widthLine)
        alertView.addSubview(heightLine)
        alertView.addSubview(cancleView)
        alertView.addSubview(cancleLabel)
        alertView.addSubview(checkView)
        checkView.addSubview(checkLabel)
        
        alertBack.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false
        alertTitle.translatesAutoresizingMaskIntoConstraints = false
        alertSubTitle.translatesAutoresizingMaskIntoConstraints = false
        widthLine.translatesAutoresizingMaskIntoConstraints = false
        heightLine.translatesAutoresizingMaskIntoConstraints = false
        cancleView.translatesAutoresizingMaskIntoConstraints = false
        cancleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkView.translatesAutoresizingMaskIntoConstraints = false
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            alertBack.topAnchor.constraint(equalTo: view.topAnchor),
            alertBack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alertBack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alertBack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 46),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -46),
            alertView.heightAnchor.constraint(equalToConstant: 140),
            
            alertTitle.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 24),
            alertTitle.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            
            alertSubTitle.topAnchor.constraint(equalTo: alertTitle.bottomAnchor, constant: 10),
            alertSubTitle.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            
            widthLine.topAnchor.constraint(equalTo: alertSubTitle.bottomAnchor, constant: 20),
            widthLine.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            widthLine.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            widthLine.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            widthLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            heightLine.topAnchor.constraint(equalTo: widthLine.bottomAnchor),
            heightLine.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            heightLine.widthAnchor.constraint(equalToConstant: 0.5),
            heightLine.heightAnchor.constraint(equalToConstant: 80),
            
            cancleView.topAnchor.constraint(equalTo: widthLine.bottomAnchor),
            cancleView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            cancleView.trailingAnchor.constraint(equalTo: heightLine.leadingAnchor, constant: -4),
            cancleView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor),
            
            cancleLabel.topAnchor.constraint(equalTo: cancleView.topAnchor, constant: 14),
            cancleLabel.centerXAnchor.constraint(equalTo: cancleView.centerXAnchor),
            
            checkView.topAnchor.constraint(equalTo: widthLine.bottomAnchor),
            checkView.leadingAnchor.constraint(equalTo: heightLine.trailingAnchor, constant: 4),
            checkView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            checkView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor),
            
            checkLabel.topAnchor.constraint(equalTo: checkView.topAnchor, constant: 14),
            checkLabel.centerXAnchor.constraint(equalTo: checkView.centerXAnchor),
        ])
        
        cancleLabel.text = cancelTitle
        checkLabel.text = checkTitle
        
        alertBack.alpha = 0
        alertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.3) {
            self.alertBack.alpha = 1
            self.alertView.transform = CGAffineTransform.identity
        }
        
        checkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkButtonTapped)))
        cancleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelButtonTapped)))
        
        self.checkAction = checkAction
        self.cancelAction = cancelAction
    }

    // MARK: - setOnboardingUI
    private func setOnboardingUI() {
        view.addSubview(onboardingBackView)
        onboardingBackView.addSubview(onboardingView)
        onboardingView.addSubview(onboardingText)
        
        onboardingBackView.translatesAutoresizingMaskIntoConstraints = false
        onboardingView.translatesAutoresizingMaskIntoConstraints = false
        onboardingText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            onboardingBackView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingBackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingBackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onboardingBackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            onboardingView.centerYAnchor.constraint(equalTo: onboardingBackView.centerYAnchor),
            onboardingView.leadingAnchor.constraint(equalTo: onboardingBackView.leadingAnchor, constant: 46),
            onboardingView.trailingAnchor.constraint(equalTo: onboardingBackView.trailingAnchor, constant: -46),
            
            onboardingText.topAnchor.constraint(equalTo: onboardingView.topAnchor, constant: 16),
            onboardingText.bottomAnchor.constraint(equalTo: onboardingView.bottomAnchor, constant: -16),
            onboardingText.centerXAnchor.constraint(equalTo: onboardingView.centerXAnchor)
        ])
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if timerIsCounting {
            // Timer start
            startTimer()
            updateMarimoImage()
            
            if let startTime = startTime, let timerInterval = timerInterval {
                let elapsedTime = Date().timeIntervalSince(startTime)
                let delay = timerInterval - (elapsedTime.truncatingRemainder(dividingBy: timerInterval))
                startMarimoTimer(withDelay: delay)
            } else {
                print("Error: startTime or timerInterval is nil")
            }
        } else {
            // Timer stop
            stopTimer()
            stopMarimoTimer()
            
            if let start = startTime, let stop = stopTime {
                let time = calcRestartTime(start: start, stop: stop)
                let difference = Date().timeIntervalSince(time)
                setTimeLabel(Int(difference))
                updateMarimoImage()
            } else {
                setTimeLabel(0)
            }
        }
        
        if let processedTime = timerInterval {
            print("마리모 변환 시간 간격: \(processedTime)")
        } else {
            print("마리모 변환 시간 간격 없음")
        }
        
        checkAndResetTimerIfNeeded()
    }
    
    // MARK: - checkAndResetTimerIfNeeded
    func checkAndResetTimerIfNeeded() {
        guard let uid = uid else {
            print("유저 정보를 찾을 수 없음")
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let day = formatter.string(from: currentDate)
        
        let documentRef = Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(day)
        
        documentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }
            
            if let document = documentSnapshot, document.exists {
                // 문서가 존재할 때의 처리
                print("오늘 날짜인 문서가 이미 존재합니다.")
            } else {
                // 문서가 존재하지 않을 때의 처리
                print("오늘 날짜인 문서가 존재하지 않습니다. 타이머를 초기화합니다.")
                
                // 타이머 초기화하는 로직 추가
                self.resetTimer()
            }
        }
    }
    
    func resetTimer() {
        // 타이머 정지
        stopTimer()
        
        // 다른 초기화 작업 수행 (UI 초기화 등)
        setTimeLabel(0)
        updateMarimoImage()
    }
    
    // MARK: - fetchUserDataAndBindUI
    private func fetchUserDataAndBindUI() {
        guard let uid = uid else {
            print("유저 정보를 찾을 수 없음")
            return
        }
        
        let documentRef = Firestore.firestore().collection("user-info").document(uid)
        
        documentRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("문서를 가져오는 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot else {
                print("문서가 존재하지 않음")
                return
            }
            
            if document.exists {
                if let data = document.data() {
                    self.bindUIData(with: data)
                    print("Data: \(data)")
                    
                    if let imageName = data["profile-image"] as? String {
                        self.profileImageName = imageName
                    } else {
                        print("No profile-image")
                        self.profileImageName = "Group 9"
                    }
                    
                    if let targetTimeString = data["target-time"] as? String,
                       let hours = Int(targetTimeString) {
                        let processedTimeInSeconds = (Double(hours) * 3600) / 5
                        print("Processed time seconds: \(processedTimeInSeconds)")
                        
//                        self.timerInterval = processedTimeInSeconds
                        self.timerInterval = 3
                    } else {
                        print("No target-time")
                    }
                    
                    self.setupMarimoImages()
                } else {
                    print("문서 데이터가 비어 있습니다.")
                }
            } else {
                print("문서가 존재하지 않습니다")
            }
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
            
            if let dDayText = data["d-day"] as? String, !dDayText.isEmpty {
                self.dayLabel.text = dDayText
            } else {
                print("No d-day")
                self.dayLabel.text = "프로필에서 설정할 수 있어요."
                dayView.backgroundColor = .clear
                dayView.backgroundColor = MySpecialColors.DayBlue
            }
            
            if let profileImageName = data["profile-image"] as? String {
                self.profileImageName = profileImageName
            } else {
                print("No profile-image")
                self.profileImageName = "Group 9"
            }
        }
    }
    
    private func calculateRemainingDays(until date: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: currentDate, to: targetDate)
        return components.day ?? 0
    }

    // MARK: - Setup Marimo Images
    private func setupMarimoImages() {
        var imageNames = ["Group 1", "Group 2", "Group 3", "Group 4"]
        
        if !profileImageName.isEmpty {
            let insertIndex = min(4, imageNames.count)
            imageNames.insert(profileImageName, at: insertIndex)
        }
        
        for (index, name) in imageNames.enumerated() {
            let imageView = marimoImageView(name: name, alpha: index == 0 ? 1 : 0)
            view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            guard let image = imageView.image, image.size.width != 0 else {
                continue
            }
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomConstraintConstant(for: index)),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: image.size.height / image.size.width),
            ])
            
            if index == imageNames.count - 1 {
                imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            } else {
                imageView.widthAnchor.constraint(equalToConstant: 46 + CGFloat(index * 14)).isActive = true
            }
            
            marimoImages.append(imageView)
            
            animateImageAppearance(imageView)
        }
        
        updateMarimoImage()
    }
    
    // MARK: - bottomConstraintConstant
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
    
    // MARK: - MARIMO Timer
    private func startMarimoTimer(withDelay delay: TimeInterval = 0) {
        marimoTimer?.invalidate()
        
        guard let timerInterval = timerInterval else {
            print("Error: timerInterval nil")
            return
        }
        
        marimoTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateMarimoImage), userInfo: nil, repeats: true)
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.marimoTimer?.fire()
            }
        }
    }
    
    private func stopMarimoTimer() {
        marimoTimer?.invalidate()
        marimoTimer = nil
    }
    
    // MARK: - MARIMO
    @objc private func updateMarimoImage() {
        guard let startTime = startTime else { return }

        let elapsedTime = Date().timeIntervalSince(startTime)

        guard let timerInterval = timerInterval else {
            print("Error: timerInterval nil")
            return
        }

        let currentIndex = min(Int(elapsedTime / timerInterval), marimoImages.count - 1)

        currentMarimoIndex = currentIndex

        showMarimoImage(at: currentIndex)
    }
        
    private func showMarimoImage(at index: Int) {
        let group = DispatchGroup()

        for (i, imageView) in marimoImages.enumerated() {
            group.enter()
            UIView.animate(withDuration: 0.5, animations: {
                imageView.alpha = i == index ? 1 : 0
            }) { _ in
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if index == self.marimoImages.count - 1 {
                self.showSuccessView()
                self.cheeringLabel.isHidden = true
            }
        }
    }


    private func updateMarimoImagesPosition() {
        for (index, imageView) in marimoImages.enumerated() {
            let newBottomConstraint = -244 - CGFloat(index * 40)
            imageView.constraints.filter { $0.firstAttribute == .bottom && $0.secondAttribute == .bottom }.first?.constant = newBottomConstraint
        }
        view.layoutIfNeeded()
    }
    
    private func marimoImageView(name: String, alpha: Int) -> UIImageView {
        let marimo = UIImageView()
        marimo.image = UIImage(named: name)
        marimo.alpha = CGFloat(alpha)
        return marimo
    }
    
    private func animateImageAppearance(_ imageView: UIImageView) {
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
                imageView.transform = CGAffineTransform(translationX: 0, y: -moveDistance)
            },
            completion: nil
        )
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
        bubbleEmitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: view.bounds.height)
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
    
    // MARK: - Timer
    private func setStartTime(date: Date?) {
        startTime = date
        userDefaults.set(startTime, forKey: START_TIME_KEY)
    }
    
    private func setStopTime(date: Date?) {
        stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
    }
    
    private func setTimerCounting(_ value: Bool) {
        timerIsCounting = value
        userDefaults.set(timerIsCounting, forKey: COUNTING_KEY)
    }
    
    @objc func refreshValue() {
        if let start = startTime {
            let difference = Date().timeIntervalSince(start)
            setTimeLabel(Int(difference))
        } else {
            stopTimer()
            setTimeLabel(0)
        }
    }
    
    private func setTimeLabel(_ value: Int) {
        let time = secToHoursMinSec(value)
        let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
        timeLabel.text = timeString
    }
    
    private func secToHoursMinSec(_ ms: Int) -> (Int, Int, Int) {
        let hour = ms / 3600
        let min = (ms % 3600) / 60
        let sec = (ms % 3600) % 60
        return (hour, min, sec)
    }
    
    private func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hour)
        timeString += ":"
        timeString += String(format: "%02d", min)
        timeString += ":"
        timeString += String(format: "%02d", sec)
        return timeString
    }
    
    private func stopTimer() {
        if scheduledTimer != nil { scheduledTimer.invalidate() }
        setTimerCounting(false)
        
        UIView.transition(with: startTimerButton, duration: 0.3, options: .transitionCrossDissolve) {
            self.startTimerButton.setTitle("집중 모드 시작하기", for: .normal)
            self.startTimerButton.layer.borderColor = MySpecialColors.MainColor.cgColor
            self.startTimerButton.layer.borderWidth = 1
            self.startTimerButton.backgroundColor = MySpecialColors.Gray1
            self.startTimerButton.setTitleColor(MySpecialColors.MainColor, for: .normal)
        }
    }
    
    private func calcRestartTime(start: Date, stop: Date) -> Date {
        let difference = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(difference)
    }
    
    private func startTimer() -> TimeInterval {
        guard let startTime = startTime else {
            print("startTime 없음")
            return 0.1
        }
        
        // Start main timer
        scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
        setTimerCounting(true)
        showOnboardingView()

        // Update marimo image
        updateMarimoImage()
        
        // Start marimoTimer
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        UIView.transition(with: startTimerButton, duration: 0.3, options: .transitionCrossDissolve) {
            self.startTimerButton.setTitle("집중 모드 중단하기", for: .normal)
            self.startTimerButton.layer.borderColor = MySpecialColors.MainColor.cgColor
            self.startTimerButton.layer.borderWidth = 1
            self.startTimerButton.backgroundColor = MySpecialColors.MainColor
            self.startTimerButton.setTitleColor(MySpecialColors.Gray1, for: .normal)
        }
        
        guard let timerInterval = timerInterval else {
            print("timerInterval 없음")
            return 0.1
        }
        
        let delay = timerInterval - (elapsedTime.truncatingRemainder(dividingBy: timerInterval))
        startMarimoTimer(withDelay: delay)
        
        return 0.1
    }
    
    //MARK: - Alert Action
    @objc private func checkButtonTapped() {
        removeAlertView()
        checkAction?()
    }

    @objc private func cancelButtonTapped() {
        removeAlertView()
        cancelAction?()
    }

    @objc private func removeAlertView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alertBack.alpha = 0
        }) { _ in
            self.alertBack.removeFromSuperview()
        }
    }
    
    //MARK: - startStopAction
    @objc private func startStopAction(_ sender: Any) {
        if timerIsCounting {
            setStopTime(date: Date())
            stopTimer()
            stopMarimoTimer()
            updateIsStudy(false)
            pauseTimerData()
        } else {
            if let stop = stopTime {
                let restartTime = calcRestartTime(start: startTime!, stop: stop)
                setStopTime(date: nil)
                setStartTime(date: restartTime)
                updateIsStudy(true)
            } else {
                setStartTime(date: Date())
            }
            let interval = startTimer()
            startMarimoTimer(withDelay: interval)
            startTimerButtonTapped()
        }
    }

    // MARK: - resetAction
    @objc private func resetAction(_ sender: Any) {
        setAlertView(
            title: "Reset Timer",
            subTitle: "공부 시간을 초기화하시겠습니까?",
            checkTitle: "확인",
            cancelTitle: "취소",
            checkAction: { [weak self] in
                self?.deleteTodayStudySessionData()
            },
            cancelAction: {
                print("Cancel button tapped")
                self.removeAlertView()
            }
        )
    }
    
    // MARK: - startFocusModeButtonTapped
    @objc private func startFocusModeButtonTapped() {
        showOnboardingView()
    }
    
    // MARK: - goDetailButtonTapped
    @objc private func goDetailButtonTapped(_ sender: UIButton) {
        guard let uid = uid else {
            print("Detail Page 이동 / 사용자 정보를 확인할 수 없음")
            return
        }
        
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: currentDate)
        
        let db = Firestore.firestore()
        let docRef = db.collection("user-info").document(uid).collection("study-sessions").document(day)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                let calendarDetailVC = CalendarDetailViewController()
                calendarDetailVC.data = data
                CalendarDetailViewController()
                
                self.navigationController?.pushViewController(calendarDetailVC, animated: true)
            } else {
                print("도큐먼트 데이터 없음")
            }
        }
    }
    
    // MARK: - deleteTodayStudySessionData
    @objc private func deleteTodayStudySessionData() {
        guard let uid = uid else {
            print("집중 모드 데이터 삭제 실패: deleteTodayStudySessionData / 사용자 정보를 확인할 수 없음")
            return
        }
        
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: currentDate)
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(day)
            .delete { error in
                if let error = error {
                    print("집중 모드 데이터 삭제 오류: \(error.localizedDescription)")
                } else {
                    print("집중 모드 데이터 삭제")
                    self.setStopTime(date: nil)
                    self.setStartTime(date: nil)
                    self.timeLabel.text = self.makeTimeString(hour: 0, min: 0, sec: 0)
                    self.stopTimer()
                    self.stopMarimoTimer()
                    
                    self.marimoImages.forEach { $0.removeFromSuperview() }
                    self.marimoImages.removeAll()
                    self.setupMarimoImages()
                    
                    self.currentSessionID = nil
                    self.hideSuccessView()
                    self.cheeringLabel.isHidden = false 
                    self.removeAlertView()
                }
            }
    }
    
    // MARK: - formatter > "yyyy-MM-dd"
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: - formatTime > "00:00:00"
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
    
    // MARK: - Firebase Data
    private func startTimerButtonTapped() {
        guard let uid = uid else {
            print("집중 모드 데이터 저장 실패: startTimerButtonTapped / 사용자 정보를 확인할 수 없음")
            return
        }
        
        let currentDate = Date()
        isStudy = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: currentDate)
        currentSessionID = day
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(day)
            .getDocument { [weak self] (document, error) in
                if let document = document, document.exists {
                    self?.updateIsStudy(true)
                } else {
                    self?.saveNewData(day: day, startTime: currentDate)
                }
            }
    }
    
    private func saveNewData(day: String, startTime: Date) {
        guard let uid = uid else {
            print("집중 모드 데이터 업데이트 실패: saveNewData / 사용자 정보를 확인할 수 없음")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let startTimeString = formatter.string(from: startTime)
        
        let data: [String: Any] = [
            "day": day,
            "start-time": startTime,
            "isStudy": isStudy,
            "marimo-state": currentMarimoIndex,
            "last-time": "",
            "total-time": "",
            "day-memo": "",
        ]
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(day)
            .setData(data) { error in
                if let error = error {
                    print("시작 시간을 저장하는 동안 오류 발생 \(error.localizedDescription)")
                } else {
                    print("시작 시간 저장 성공")
                }
            }
    }
    
    private func pauseTimerData() {
        guard let uid = uid else {
            print("집중 모드 데이터 업데이트 실패: pauseTimerData / 사용자 정보를 확인할 수 없음")
            return
        }
        guard let startTime = startTime else {
            print("집중 모드 데이터 업데이트 실패: startTime를 확인할 수 없음")
            return
        }
        
        let currentDate = Date()
        let elapsedTime = currentDate.timeIntervalSince(startTime) + totalTimeElapsed
        
        totalTimeElapsed = elapsedTime
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let day = formatter.string(from: currentDate)
        
        formatter.dateFormat = "HH:mm:ss"
        let lastTime = formatter.string(from: currentDate)
        let formattedTotalTime = formatTime(elapsedTime)
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(day)
            .updateData([
                "isStudy": false,
                "marimo-state": currentMarimoIndex,
                "last-time": lastTime,
                "total-time": formattedTotalTime
            ]) { error in
                if let error = error {
                    print("상태를 업데이트하는 중에 오류 발생: \(error.localizedDescription)")
                } else {
                    print("상태 업데이트 성공", self.currentMarimoIndex)
                }
            }
    }
    
    private func updateIsStudy(_ isCurrentlyStudying: Bool) {
        guard let uid = uid else {
            print("집중 모드 데이터 업데이트 실패: updateIsStudy / 사용자 정보를 확인할 수 없음")
            return
        }
        guard let sessionID = currentSessionID else {
            print("집중 모드 데이터 업데이트 실패: currentSessionID를 확인할 수 없음")
            return
        }
        
        isStudy = isCurrentlyStudying
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(sessionID)
            .updateData([
                "isStudy": isStudy
            ]) { error in
                if let error = error {
                    print("isStudy 상태를 업데이트하는 중에 오류 발생 \(error.localizedDescription)")
                } else {
                    print("isStudy 상태 업데이트 성공")
                }
            }
    }
    
    private func showOnboardingView() {
        setOnboardingUI()
        
        onboardingBackView.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.onboardingBackView.alpha = 1.0
        }) { _ in
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.onboardingBackView.alpha = 0.0
                }) { _ in
                    self.onboardingBackView.removeFromSuperview()
                }
            }
        }
    }
}
