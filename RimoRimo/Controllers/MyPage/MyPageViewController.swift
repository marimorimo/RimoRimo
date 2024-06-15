
import UIKit
import FirebaseFirestore
import FirebaseAuth
import WidgetKit

class MyPageViewController: UIViewController {

//    private let myPageTitle: UILabel = {
//        let text = UILabel()
//        text.text = "MyPage"
//        text.font = UIFont.boldSystemFont(ofSize: 24)
//        return text
//    }()
//    
//    private let setupButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("", for: .normal)
//        button.setImage(UIImage(systemName: "gear"), for: .normal)
//        button.addTarget(self, action: #selector(setupButtonTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    private let emailLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .black
//        return label
//    }()
//    
//    private let nicknameLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .black
//        return label
//    }()
//    
//    private let dDayTitleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .black
//        return label
//    }()
//    
//    private let dDayLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .black
//        return label
//    }()
//    
//    private let targetTimeLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .black
//        return label
//    }()
//    
//    private let profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 50
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//    
    private var listener: ListenerRegistration?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        view.addSubview(myPageTitle)
//        view.addSubview(setupButton)
//        view.addSubview(emailLabel)
//        view.addSubview(nicknameLabel)
//        view.addSubview(dDayTitleLabel)
//        view.addSubview(dDayLabel)
//        view.addSubview(targetTimeLabel)
//        view.addSubview(profileImageView)
//        
//        myPageTitle.translatesAutoresizingMaskIntoConstraints = false
//        setupButton.translatesAutoresizingMaskIntoConstraints = false
//        emailLabel.translatesAutoresizingMaskIntoConstraints = false
//        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
//        dDayTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        dDayLabel.translatesAutoresizingMaskIntoConstraints = false
//        targetTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            myPageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            myPageTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            
//            setupButton.topAnchor.constraint(equalTo: myPageTitle.bottomAnchor, constant: 20),
//            setupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            setupButton.widthAnchor.constraint(equalToConstant: 40),
//            setupButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            emailLabel.topAnchor.constraint(equalTo: setupButton.bottomAnchor, constant: 20),
//            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            nicknameLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
//            nicknameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            dDayTitleLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 10),
//            dDayTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            dDayLabel.topAnchor.constraint(equalTo: dDayTitleLabel.bottomAnchor, constant: 10),
//            dDayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            targetTimeLabel.topAnchor.constraint(equalTo: dDayLabel.bottomAnchor, constant: 10),
//            targetTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            profileImageView.topAnchor.constraint(equalTo: targetTimeLabel.bottomAnchor, constant: 10),
//            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            profileImageView.widthAnchor.constraint(equalToConstant: 100),
//            profileImageView.heightAnchor.constraint(equalToConstant: 100)
//        ])
//        
//        setupUserDataListener()
//    }
//
    let marimoNameList = ["Group 1", "Group 2", "Group 3", "Group 4", "Group 5"]

    // MARK: - UI Elements
    private lazy var settingButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        button.tintColor = MySpecialColors.GearGray
        button.addTarget(self, action: #selector(moveToSetting), for: .touchUpInside)

        return button
    }()

    private let profileMarimoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Group 3"))
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .pretendard(style: .medium, size: 16)

        label.text = "리모리모리모"

        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .pretendard(style: .regular, size: 10)

        label.textColor = MySpecialColors.Gray3
        label.text = "RimoRimo@naver.com"

        return label
    }()

    private lazy var profileInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nicknameLabel, emailLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 6

        return stackView
    }()

    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileMarimoImageView, profileInfoStackView])

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 36

        return stackView
    }()

    private let profileBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Mint

        return view
    }()

    private let concentrationGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "목표 집중 시간"
        label.font = .pretendard(style: .regular, size: 16)
        label.textColor = MySpecialColors.Green4

        return label
    }()

    private let concentrationTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "07hr"
        label.font = .pretendard(style: .semiBold, size: 40)
        label.textColor = MySpecialColors.Gray4

        return label
    }()

    private lazy var concentrationContainerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [concentrationGuideLabel, concentrationTimeLabel])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill

        return stackView
    }()

    private let goalLabel: UILabel = {
        let label = UILabel()
        label.text = "토익 시험"
        label.font = .pretendard(style: .regular, size: 16)
        label.textColor = MySpecialColors.Green4

        return label
    }()

    private let goalDdayLabel: UILabel = {
        let label = UILabel()
        label.text = "D-37"
        label.font = .pretendard(style: .semiBold, size: 40)
        label.textColor = MySpecialColors.Gray4

        return label
    }()

    private lazy var goalContainerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [goalLabel, goalDdayLabel])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill

        return stackView
    }()

    private let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = MySpecialColors.Gray3

        return view
    }()

    private lazy var statusStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [concentrationContainerStackView, dividerLineView, goalContainerStackView])
        stackView.backgroundColor = .white
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.distribution = .fillProportionally

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 20, trailing: 16)

        stackView.layer.cornerRadius = 12
        stackView.clipsToBounds = true

        return stackView
    }()

    private lazy var showCollectionButton: UIButton = {
        let button = UIButton()

        button.setTitle("컬렉션만 보기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(named: "mypageIcon2"), for: .normal)
        button.tintColor = MySpecialColors.Gray2
        button.semanticContentAttribute = .forceRightToLeft
        button.contentMode = .scaleToFill
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 80, bottom: 2, right: 56)
        button.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
        button.addTarget(self, action: #selector(showCollectionButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var showMarimoButton: UIButton = {
        let button = UIButton()
        button.setTitle("마리모만 보기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(named: "mypageIcon1"), for: .normal)
        button.tintColor = MySpecialColors.Gray2
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)

        button.addTarget(self, action: #selector(showMarimoButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [showCollectionButton, showMarimoButton])
        stackView.distribution = .fillEqually
        stackView.spacing = 20

        return stackView
    }()

    private let marimoCollectionStackView1: UIStackView = {
        let stackView = UIStackView()

        stackView.distribution = .fillEqually

        stackView.alignment = .center

        return stackView
    }()

    private let marimoCollectionStackView2: UIStackView = {
        let stackView = UIStackView()

        stackView.distribution = .equalSpacing
        stackView.alignment = .center

        return stackView
    }()

    private let marimoCollectionStackView3: UIStackView = {
        let stackView = UIStackView()

        stackView.distribution = .fillEqually
        stackView.alignment = .center

        return stackView
    }()

    private lazy var collectionContainerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [marimoCollectionStackView1, marimoCollectionStackView2, marimoCollectionStackView3])

        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center

        return stackView
    }()

    var animatingMarimoImageViews = [UIImageView]()

    var animator: UIDynamicAnimator!
    var gravityBehavior: UIGravityBehavior!
    var collisionBehavior: UICollisionBehavior!
    var itemBehavior: UIDynamicItemBehavior!
    var attachmentBehavior: UIAttachmentBehavior!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Setup Views
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureCollection()
        setupConstraints()
        setupUserDataListener()
    }

    //navibar 나오면서 애니메이션이 부자연스러움 -> 설정의 viewWillAppear에서 적용하거나 네비바 그림자 삭제
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupViews() {
        view.backgroundColor = MySpecialColors.Gray1

        view.addSubview(profileBackgroundView)
        profileBackgroundView.addSubview(settingButton)
        profileBackgroundView.addSubview(profileStackView)
        profileBackgroundView.addSubview(statusStackView)

        view.addSubview(buttonStackView)
        view.addSubview(collectionContainerStackView)
    }

    private func configureCollection() {
        let marimoCollectionButtonTitles = ["그룹 내 1등", "첫 투두 완료", "첫 목표시간 달성", "2시간 이상 집중", "그룹 만들기", "모든 목표 달성", "100 마리모 획득", "일주일 달려", "첫 채팅하기", "투두 5개 이상 완료", "리뷰 작성 완료"]

        for i in 0...3 {
            marimoCollectionStackView1.addArrangedSubview(MarimoCollectionButton(title: marimoCollectionButtonTitles[i], image: UIImage(named: "CollectionMarimo-\(i+1)") ?? UIImage()))
        }

        for i in 4...6 {
            marimoCollectionStackView2.addArrangedSubview(MarimoCollectionButton(title: marimoCollectionButtonTitles[i], image: UIImage(named: "CollectionMarimo-\(i+1)") ?? UIImage()))
        }

        for i in 7...10 {
            marimoCollectionStackView3.addArrangedSubview(MarimoCollectionButton(title: marimoCollectionButtonTitles[i], image: UIImage(named: "CollectionMarimo-\(i+1)") ?? UIImage()))
        }
    }

    func safeAreaTopInset() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene

        return windowScene?.windows.first?.safeAreaInsets.top ?? 0
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        profileBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(safeAreaTopInset())
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(300)
        }

        settingButton.snp.makeConstraints { make in
            make.top.equalTo(profileBackgroundView.snp.top).inset(12)
            make.trailing.equalToSuperview().inset(24)
            make.height.width.equalTo(32)
        }

        profileMarimoImageView.snp.makeConstraints { make in
            make.height.width.equalTo(100)
        }

        profileStackView.snp.makeConstraints { make in
            make.top.equalTo(profileBackgroundView.snp.top).inset(56)
            make.leading.trailing.equalToSuperview().inset(28)
            make.height.greaterThanOrEqualTo(100)
        }

        dividerLineView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(40)
        }

        statusStackView.snp.makeConstraints { make in
            make.top.equalTo(profileStackView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(28)
            make.height.greaterThanOrEqualTo(104)
        }

        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.top.equalTo(profileBackgroundView.snp.bottom).offset(20)
            make.height.greaterThanOrEqualTo(24)
        }

        collectionContainerStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.top.equalTo(buttonStackView.snp.bottom).offset(4)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }

        showCollectionButton.snp.makeConstraints { make in
            make.width.equalTo(100)
        }
    }
    // MARK: - move to Setting page
    @objc private func moveToSetting() {
        let settingsVC = SetupViewController()

        //Test for widget Data setting
        UserDefaults.shared.set(Calendar.current.date(byAdding: .day, value: -20, to: Date()), forKey: "startDate")
        UserDefaults.shared.set(Calendar.current.date(byAdding: .day, value: 10, to: Date()), forKey: "endDate")
        UserDefaults.shared.set(["아침", "점심"], forKey: "todo")
        UserDefaults.shared.set("토익 시험", forKey: "goal")
        WidgetCenter.shared.reloadAllTimelines()

        navigationController?.pushViewController(settingsVC, animated: true)
    }

    @objc
    private func showCollectionButtonTapped() {
        collectionContainerStackView.isHidden = false

        for _ in 0..<animatingMarimoImageViews.count {
            let imageView = animatingMarimoImageViews.removeLast()
            imageView.removeFromSuperview()
        }
    }

    @objc
    private func showMarimoButtonTapped() {
        collectionContainerStackView.isHidden = true

        for _ in 0..<animatingMarimoImageViews.count {
            let imageView = animatingMarimoImageViews.removeLast()
            imageView.removeFromSuperview()
        }

        configureAnimatingMarimoImageViews()
        setupDynamics()
        setupTapGesture()
    }

    deinit {
        listener?.remove()
    }
}

extension MyPageViewController {
    private func setupUserDataListener() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        listener = Firestore.firestore().collection("user-info").document(uid).addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            if let document = documentSnapshot, document.exists {
                let data = document.data()

                self.nicknameLabel.text = "Nickname: \(data?["nickname"] as? String ?? "N/A")"
                self.emailLabel.text = "Email: \(data?["email"] as? String ?? "N/A")"
                self.goalLabel.text = "\(data?["d-day-title"] as? String ?? "N/A")"
                self.goalDdayLabel.text = "D-\(data?["d-day"] as? String ?? "N/A")"
                self.concentrationTimeLabel.text = "Target Time: \(data?["target-time"] as? String ?? "N/A")"

//                if let profileImageURLString = data?["profile-image"] as? String, !profileImageURLString.isEmpty {
//                    if let profileImageURL = URL(string: profileImageURLString) {
//                        URLSession.shared.dataTask(with: profileImageURL) { (data, response, error) in
//                            if let data = data {
//                                DispatchQueue.main.async {
//                                    self.profileImageView.image = UIImage(data: data)
//                                }
//                            }
//                        }.resume()
//                    }
//                } else {
//                    self.profileImageView.image = UIImage(named: "Group 1")
//                }
            } else {
                self.nicknameLabel.text = "Nickname: N/A"
                self.emailLabel.text = "Email: N/A"
                self.goalLabel.text = "N/A"
                self.goalDdayLabel.text = "N/A"
                self.concentrationTimeLabel.text = "N/A"
//                self.profileImageView.image = UIImage(named: "Group 1")
            }
        }
    }
}


// MARK: - configure Animating Marimo

extension MyPageViewController {
    func configureAnimatingMarimoImageViews() {
        let ballSize: CGFloat = 50.0
        for i in 0..<40 {
            let imageView = UIImageView(frame: CGRect(x: CGFloat.random(in: 0...view.bounds.width - ballSize),
                                                      y: ballSize,
                                                      width: ballSize,
                                                      height: ballSize))
            imageView.backgroundColor = .white
            imageView.layer.cornerRadius = ballSize / 2
            imageView.clipsToBounds = true
            imageView.image = UIImage(named: marimoNameList[i%5])
            imageView.isUserInteractionEnabled = true
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            imageView.addGestureRecognizer(panGesture)
            view.addSubview(imageView)
            animatingMarimoImageViews.append(imageView)
        }
    }

    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    func setupDynamics() {
        animator = UIDynamicAnimator(referenceView: view)

        gravityBehavior = UIGravityBehavior(items: animatingMarimoImageViews)
        gravityBehavior.magnitude = 0.2
        animator.addBehavior(gravityBehavior)

        collisionBehavior = UICollisionBehavior(items: animatingMarimoImageViews)
        collisionBehavior.addBoundary(withIdentifier: "borders" as NSCopying, for: UIBezierPath(rect: self.view.frame))
        collisionBehavior.addBoundary(withIdentifier: "borders" as NSCopying, for: UIBezierPath(rect: self.tabBarController!.tabBar.frame))
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collisionBehavior)

        itemBehavior = UIDynamicItemBehavior(items: animatingMarimoImageViews)
        itemBehavior.elasticity = 0.6
        animator.addBehavior(itemBehavior)
    }

    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let location = gesture.location(in: self.view)
        let touchLocation = gesture.location(in: view)

        switch gesture.state {
        case .began:
            gravityBehavior.removeItem(view)
            attachmentBehavior = UIAttachmentBehavior(item: view, offsetFromCenter: UIOffset(horizontal: touchLocation.x - view.bounds.midX, vertical: touchLocation.y - view.bounds.midY), attachedToAnchor: location)
            if let attachmentBehavior = attachmentBehavior {
                animator.addBehavior(attachmentBehavior)
            }
        case .changed:
            attachmentBehavior?.anchorPoint = location
        case .ended, .cancelled, .failed:
            if let attachmentBehavior = attachmentBehavior {
                animator.removeBehavior(attachmentBehavior)
                self.attachmentBehavior = nil
            }
            gravityBehavior.addItem(view)
        default:
            break
        }
    }

    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self.view)

        for imageView in animatingMarimoImageViews {
            let distance = hypot(imageView.center.x - tapLocation.x, imageView.center.y - tapLocation.y)
            let maxDistance: CGFloat = 500.0
            if distance < maxDistance {
                let angle = atan2(imageView.center.y - tapLocation.y, imageView.center.x - tapLocation.x)
                let pushBehavior = UIPushBehavior(items: [imageView], mode: .instantaneous)
                pushBehavior.magnitude = (maxDistance - distance) / maxDistance * 1.0
                pushBehavior.angle = angle
                animator.addBehavior(pushBehavior)
            }
        }
    }
}

