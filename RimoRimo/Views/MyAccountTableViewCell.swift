
import UIKit
import SnapKit

protocol MyAccountTableViewCellDelegate: AnyObject {
    func didTapResetPasswordButton(withEmail email: String)
}

class MyAccountTableViewCell: UITableViewCell {

    static let cellId = "MyAccountCellId"
    weak var delegate: MyAccountTableViewCellDelegate?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .pretendard(style: .medium, size: 14)
        label.textColor = MySpecialColors.Black

        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .pretendard(style: .medium, size: 12)
        label.textAlignment = .left
        label.textColor = MySpecialColors.Gray4

        return label
    }()
    
    lazy var resetPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(MySpecialColors.MainColor, for: .normal)
        button.titleLabel?.font = UIFont.pretendard(style: .regular, size: 12)
        button.addTarget(self, action: #selector(resetPasswordButtonTapped), for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been impl")
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(resetPasswordButton)
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
            make.leading.equalToSuperview().inset(28)
            make.width.equalTo(40)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.width.equalTo(200)
        }
        
        resetPasswordButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(28)
        }
    }

    @objc private func resetPasswordButtonTapped() {
        guard let email = descriptionLabel.text, !email.isEmpty else {
            delegate?.didTapResetPasswordButton(withEmail: "")
            return
        }
        delegate?.didTapResetPasswordButton(withEmail: email)
        print("taptap")
    }
}
