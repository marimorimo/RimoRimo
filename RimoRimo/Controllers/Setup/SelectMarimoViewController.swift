//
//  SelectMarimoViewController.swift
//  Marimo
//
//  Created by 이유진 on 6/12/24.
//

import UIKit
import Firebase

class SelectMarimoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let marimoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.9
        view.layer.cornerRadius = 24
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 선택"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    let marimoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 24
        layout.minimumLineSpacing = 24
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let cellReuseIdentifier = "MarimoCell"
    let cellImages = ["Group 2", "Group 3", "Group 4", "Group 5", "Group 13", "Group 12", "Group 11", "Group 10", "Group 9", "Group 8", "Group 7", "Group 6"]
    var selectedIndexPath: IndexPath?
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = MySpecialColors.MainColor
        button.layer.cornerRadius = 22
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(nil, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var didSelectImage: ((String) -> Void)?
    var selectedProfileImageName: String?
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContent()
        
        marimoCollectionView.delegate = self
        marimoCollectionView.dataSource = self
        marimoCollectionView.register(MarimoCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        if let lastIndex = UserDefaults.standard.value(forKey: "lastSelectedIndex") as? Int {
            selectedIndexPath = IndexPath(row: lastIndex, section: 0)
        }
        
        tapBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfileImageNameFromFirebase()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selectedIndexPath = selectedIndexPath {
            UserDefaults.standard.set(selectedIndexPath.row, forKey: "lastSelectedIndex")
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
    }
    
    private func setupContent() {
        [backgroundView, marimoView, titleLabel, marimoCollectionView, confirmButton].forEach {
            view.addSubview($0)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        marimoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(146)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(384)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(marimoView.snp.top).offset(20)
            make.centerX.equalTo(marimoView)
        }
        
        marimoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.centerX.equalTo(marimoView)
            make.width.equalTo(288)
            make.height.equalTo(210)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(marimoCollectionView.snp.bottom).offset(34)
            make.centerX.equalTo(marimoView)
            make.width.equalTo(285)
            make.height.equalTo(46)
        }
    }
    
    private func tapBackground() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
               backgroundView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func backgroundViewTapped() {
            dismiss(animated: true, completion: nil)
        }
    
    @objc private func confirmButtonTapped() {
        guard let selectedIndexPath = selectedIndexPath else {
            print("No cell selected")
            return
        }
        
        let selectedImageName = cellImages[selectedIndexPath.row]
        print("Selected image name: \(selectedImageName)")
        didSelectImage?(selectedImageName)
        dismiss(animated: true, completion: nil)
    }
    
    func fetchProfileImageNameFromFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let userDocRef = db.collection("user-info").document(uid)
        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                if let profileImageName = document.data()?["profile-image"] as? String {
                    if let index = self.cellImages.firstIndex(of: profileImageName) {
                        let selectedIndexPath = IndexPath(row: index, section: 0)
                        self.selectCell(at: selectedIndexPath)
                    } else {
                        self.deselectAllCells()
                    }
                } else {
                    self.deselectAllCells()
                }
            } else {
                print("Document does not exist")
                self.deselectAllCells()
            }
        }
    }
    
    func selectCell(at indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        marimoCollectionView.reloadData()
    }
    
    func deselectAllCells() {
        self.selectedIndexPath = nil
        marimoCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? MarimoCell else {
            fatalError("Unable to dequeue MarimoCell")
        }
        
        cell.imageView.image = UIImage(named: cellImages[indexPath.item])
        
        // 마지막으로 선택된 셀에만 인디케이터 표시
        if let selectedIndexPath = self.selectedIndexPath, selectedIndexPath == indexPath {
            cell.showSelectionIndicator()
        } else {
            cell.hideSelectionIndicator()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 72) / 4 // 4 columns with 24 spacing between them
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
            // 이미 선택된 셀을 다시 탭할 경우 선택 해제
            deselectAllCells()
        } else {
            // 새로운 셀 선택
            selectCell(at: indexPath)
        }
    }
}

// MARK: - Custom UICollectionViewCell class
class MarimoCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let selectionIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.RedOrange
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContent() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectionIndicator)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectionIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.trailing.equalToSuperview().offset(-2)
            make.width.height.equalTo(10)
        }
    }
    
    func showSelectionIndicator() {
        selectionIndicator.isHidden = false
    }
    
    func hideSelectionIndicator() {
        selectionIndicator.isHidden = true
    }
}

