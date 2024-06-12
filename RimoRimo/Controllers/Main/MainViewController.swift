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

    private let mainTitle: UILabel = {
        let text = UILabel()
        text.text = "Main"
        text.textAlignment = .center
        text.font = UIFont.pretendard(style: .bold, size: 24, isScaled: true)
        text.textColor = MySpecialColors.Green2
        return text
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 48)
        return label
    }()
    
    private let startTimerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Timer", for: .normal)
        button.addTarget(self, action: #selector(startTimerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let pauseTimerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pause Timer", for: .normal)
        button.addTarget(self, action: #selector(pauseTimerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var timer: Timer?
    private var timerStartDate: Date?
    private var totalTimeElapsed: TimeInterval = 0
    private var isStudy = false
    private var currentSessionID: String?
    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(mainTitle)
        view.addSubview(timerLabel)
        view.addSubview(startTimerButton)
        view.addSubview(pauseTimerButton)
        view.addSubview(resetButton)
        
        mainTitle.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimerButton.translatesAutoresizingMaskIntoConstraints = false
        pauseTimerButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 20),
            
            startTimerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startTimerButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 20),
            
            pauseTimerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pauseTimerButton.topAnchor.constraint(equalTo: startTimerButton.bottomAnchor, constant: 20),
            
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: pauseTimerButton.bottomAnchor, constant: 20),
        ])
    }
    
    @objc private func startTimerButtonTapped() {
        guard let uid = uid else {
            print("User is not logged in.")
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
            .collection("calendar")
            .document(day)
            .getDocument { [weak self] (document, error) in
                if let document = document, document.exists {
                    self?.updateIsStudy(uid: uid, day: day)
                } else {
                    self?.saveNewData(uid: uid, day: day, currentDate: currentDate)
                }
            }
    }

    private func saveNewData(uid: String, day: String, currentDate: Date) {
        timerStartDate = currentDate
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let startTime = formatter.string(from: currentDate)
        
        let data: [String: Any] = [
            "day": day,
            "start-time": startTime,
            "isStudy": isStudy,
            "marimo-state": "",
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
                    print("시작 시간을 저장하는 중에 오류가 발생했습니다.: \(error.localizedDescription)")
                } else {
                    print("시작 시간이 성공적으로 저장되었습니다.")
                    self.startTimer()
                }
            }
    }

    private func updateIsStudy(uid: String, day: String) {
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(day)
            .updateData([
                "isStudy": isStudy
            ]) { error in
                if let error = error {
                    print("isStudy 업데이트 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("isStudy가 성공적으로 업데이트되었습니다.")
                    self.startTimer()
                }
            }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let startDate = self?.timerStartDate else { return }
            let elapsedTime = Date().timeIntervalSince(startDate) + (self?.totalTimeElapsed ?? 0)
            self?.updateTimerLabel(with: elapsedTime)
        }
    }

    private func updateTimerLabel(with elapsedTime: TimeInterval) {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    @objc private func pauseTimerButtonTapped() {
        guard let startDate = timerStartDate, let sessionID = currentSessionID, let uid = uid else {
            print("타이머가 시작되지 않았거나 사용자가 로그인하지 않았습니다.")
            return
        }
        
        timer?.invalidate()
        
        let currentDate = Date()
        let lastTimeElapsed = currentDate.timeIntervalSince(startDate) + totalTimeElapsed
        isStudy = false
        totalTimeElapsed = lastTimeElapsed
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let lastTime = formatter.string(from: currentDate)
        let formattedTotalTime = formatTime(lastTimeElapsed)
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(sessionID)
            .updateData([
                "isStudy": isStudy,
                "last-time": lastTime,
                "total-time": formattedTotalTime
            ]) { error in
                if let error = error {
                    print("상태를 업데이트하는 중에 오류가 발생했습니다. \(error.localizedDescription)")
                } else {
                    print("성공적으로 업데이트되었습니다.")
                }
            }
    }

    @objc private func resetButtonTapped() {
        let alertController = UIAlertController(title: "Reset Timer", message: "하루 동안 공부한 시간이 삭제됩니다. 정말 진행하시겠습니까?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.deleteTodayStudySessionData()
        }))
        present(alertController, animated: true, completion: nil)
    }

    private func deleteTodayStudySessionData() {
        guard let uid = uid, let sessionID = currentSessionID else {
            print("집중 모드 데이터 삭제 실패: 사용자가 로그인하지 않았거나 세션 ID를 찾을 수 없습니다.")
            return
        }
        
        Firestore.firestore()
            .collection("user-info")
            .document(uid)
            .collection("study-sessions")
            .document(sessionID)
            .delete { error in
                if let error = error {
                    print("집중 모드 데이터 삭제 오류: \(error.localizedDescription)")
                } else {
                    print("집중 모드 데이터가 삭제되었습니다.")
                    self.resetUI()
                }
            }
    }
    
    private func resetUI() {
        timer?.invalidate()
        timer = nil
        totalTimeElapsed = 0
        timerLabel.text = "00:00:00"
    }
}
