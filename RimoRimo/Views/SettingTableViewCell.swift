
import UIKit
import SnapKit

class SettingTableViewCell: UITableViewCell {

    static let cellId = "SettingCellId"

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
        self.accessoryType = .disclosureIndicator
        self.accessoryView = UIImageView(image: UIImage(named: "chevron-right"))

        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
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
    }
}
