
import UIKit
import SnapKit

//protocol MyAccountTableViewCellDelegate: AnyObject {
//    func didTapResetPasswordButton(withEmail email: String)
//}

class MyAccountTableViewCell: UITableViewCell {

    static let cellId = "MyAccountCellId"
//    weak var delegate: MyAccountTableViewCellDelegate?

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
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .pretendard(style: .medium, size: 12)
        label.textAlignment = .left
        label.textColor = MySpecialColors.Gray4

        return label
    }()
    
    let enterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chevron-right")
        return imageView
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
        contentView.addSubview(emailLabel)
        contentView.addSubview(enterImageView)
    }

    private func setupLayout() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(28)
            make.height.greaterThanOrEqualTo(18)
            make.width.greaterThanOrEqualTo(280)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(28)
            make.height.greaterThanOrEqualTo(12)
            make.width.greaterThanOrEqualTo(280)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(28)
        }
        
        enterImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(24)
        }
        
    }
}
