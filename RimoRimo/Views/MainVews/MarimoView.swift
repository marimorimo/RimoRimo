//
//  MarimoView.swift
//  RimoRimo-Refactoring
//
//  Created by wxxd-fxrest on 6/28/24.
//

import UIKit
import SnapKit

class MarimoView: UIView {
    
    // MARK: - Properties
    var marimoImage: UIImageView
    
    override init(frame: CGRect) {
        marimoImage = UIFactory_.makeImageView(image: UIImage(named: "Group 1"), contentMode: .scaleAspectFit)
        
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        marimoImage = UIFactory_.makeImageView(image: UIImage(named: "Group 1"), contentMode: .scaleAspectFit)
        
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(marimoImage)
    }
    
    func setupConstraints() {
        if let imageSize = marimoImage.image?.size {
            let aspectRatio = imageSize.width / imageSize.height
            marimoImage.contentMode = .scaleAspectFit 

            marimoImage.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.height.equalTo(84)
                $0.width.equalTo(marimoImage.snp.height).multipliedBy(aspectRatio)
            }
        } else {
            marimoImage.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.height.equalTo(84)
                $0.width.equalTo(marimoImage.snp.height)
            }
        }
    }
}
