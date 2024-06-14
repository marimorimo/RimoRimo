

import UIKit

class BlockedUITableViewCell: UITableViewCell {

    static let cellId = "BlockedCellId"

    @objc
    var unblockAccount: (() -> ())?

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
        label.font = .pretendard(style: .medium, size: 10)
        label.textColor = MySpecialColors.Gray4

        return label
    }()

    lazy var unblockButton: UIButton = {
        let button = UIButton()

        button.setTitle("해제", for: .normal)
        button.setTitleColor(MySpecialColors.Green4, for: .normal)
        button.titleLabel?.font = .pretendard(style: .medium, size: 12)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.backgroundColor = .white

        button.addTarget(self, action: #selector(unblockButtonTapped), for: .touchUpInside)

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

    @objc private func unblockButtonTapped() {
        unblockAccount?()
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(unblockButton)
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

        unblockButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
            make.height.equalTo(34)
            make.width.equalTo(42)
        }
    }
}
