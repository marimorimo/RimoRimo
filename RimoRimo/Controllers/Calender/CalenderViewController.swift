//
//  CalenderViewController.swift
//  RimoRimo
//
//  Created by wxxd-fxrest on 6/11/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CalendarViewController: UIViewController {
    private var currentYear: Int = 0
    private var currentMonth: Int = 0
    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        return collectionView
    }()
    
    private var collectionRef: CollectionReference!
    
    private var listener: ListenerRegistration?
    
    private var sessionData: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let currentDate = Date()
        let calendar = Calendar.current
        currentYear = calendar.component(.year, from: currentDate)
        currentMonth = calendar.component(.month, from: currentDate)
        
        if let uid = uid {
            collectionRef = Firestore.firestore().collection("user-info").document(uid).collection("study-sessions")
        }
        
        setupMonthLabel()
        setupCollectionView()
        
        setupSessionDataListener()
    }
    
    private func setupMonthLabel() {
        view.addSubview(monthLabel)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            monthLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            monthLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        updateMonthLabel()
    }
    
    private func setupCollectionView() {
        view.addSubview(calendarCollectionView)
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarCollectionView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10),
            calendarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendarCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    private func updateMonthLabel() {
        let dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        if let date = Calendar.current.date(from: dateComponents) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
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
                }
                self.calendarCollectionView.reloadData()
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let range = Calendar.current.range(of: .day, in: .month, for: Date()) {
            return range.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        var dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        dateComponents.day = indexPath.item + 1
        if let date = Calendar.current.date(from: dateComponents) {
            let dateString = formatDate(date: date)
            if sessionData[dateString] != nil {
                cell.configure(with: date, textColor: .red)
            } else {
                cell.configure(with: date, textColor: .black)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 40) / 7, height: 40)
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        dateComponents.day = indexPath.item + 1
        if let date = Calendar.current.date(from: dateComponents) {
            let dateString = formatDate(date: date)
            if let data = sessionData[dateString] as? [String: Any] {
                let detailVC = CalenderDeatailViewController()
                detailVC.data = data
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}

// MARK: - CalendarCell
class CalendarCell: UICollectionViewCell {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with date: Date, textColor: UIColor) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        dateLabel.text = formatter.string(from: date)
        dateLabel.textColor = textColor
    }
}
