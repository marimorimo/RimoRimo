
import UIKit
import SnapKit

class MyAccountTableViewCell: UITableViewCell {

    static let cellId = "MyAccountCellId"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .pretendard(style: .medium, size: 12)
        label.textColor = MySpecialColors.Black

        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .pretendard(style: .medium, size: 12)
        label.textAlignment = .right
        label.textColor = MySpecialColors.Gray4

        return label
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
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
            make.leading.equalToSuperview().inset(28)
            make.width.equalTo(40)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
            make.trailing.equalToSuperview().inset(28)
            make.width.equalTo(200)
        }
    }

}
