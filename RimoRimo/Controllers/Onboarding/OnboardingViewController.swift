
import UIKit
import SnapKit
import Then

class OnboardingViewController: UIViewController {
    
    var isLast = false

    let imageView = UIImageView().then { imgView in
        imgView.contentMode = .scaleAspectFit
    }

    lazy var startButton: UIButton = {
        let btn = TabButtonUIFactory.tapButton(buttonTitle: "시작하기 🙌",
                                           textColor: .white ,
                                           cornerRadius: 26,
                                           backgroundColor: MySpecialColors.MainColor)
        btn.titleLabel?.font = UIFont.pretendard(style: .semiBold, size: 18)
        btn.addTarget(self, action: #selector(moveToLogin), for: .touchUpInside)

        return btn
    }()


    init(imageName: String, isLast: Bool) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(named: imageName)
        self.isLast = isLast
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        configurelayout()
    }
}

extension OnboardingViewController {

    private func configureHierarchy() {
        view.addSubview(imageView)

        if isLast {
            view.addSubview(startButton)
        }
    }

    private func configurelayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if isLast {
            startButton.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(40)
                make.height.equalTo(52)
                make.bottom.equalToSuperview().inset(128)
            }
        }
    }

    @objc 
    private func moveToLogin() {
        let vc = LoginViewController()
        let navController = UINavigationController(rootViewController: vc)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(navController)
    }
}
