
import UIKit

class MarimoCollectionButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(title: String, image: UIImage) {
        super.init(frame: .zero)
        configureUI(title: title, image: image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI(title: String, image: UIImage) {
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .black
        configuration.buttonSize = .small

        var container = AttributeContainer()
        container.font = .pretendard(style: .regular, size: 10)
        configuration.attributedTitle = AttributedString(title, attributes: container)

        configuration.image = image
        configuration.imagePlacement = .top

        configuration.imagePadding = 10
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 30)


        self.configuration = configuration
    }
}
