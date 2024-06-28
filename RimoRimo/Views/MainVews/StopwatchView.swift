//
//  MainView.swift
//  RimoRimo-Refactoring
//
//  Created by 밀가루 on 6/27/24.
//

import UIKit

class StopwatchView: UIView {
    
    lazy var successView = SuccessView()
    
    // MARK: - Properties
    private var backgroundLayer: CAGradientLayer!
    private var bubbleEmitter: CAEmitterLayer!
    
    private var timerView = UIFactory_.makeView(backgroundColor: .clear)
    private var buttonView = UIFactory_.makeView(backgroundColor: .clear)
        
    lazy var dayView = UIView().then {
        $0.backgroundColor = MySpecialColors.DayBlue
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    lazy var dayTitleLabel = UIFactory_.makeLabel(
        text: "Title", // data
        textColor: MySpecialColors.Black,
        font: UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium),
        textAlignment: .center
    )
    
    lazy var dayLabel = UIFactory_.makeLabel(
        text: "D-Day", // data
        textColor: MySpecialColors.MainColor,
        font: UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .semibold),
        textAlignment: .center
    )
    
    private lazy var dayStackView: UIStackView = UIFactory_.makeStackView(
        arrangedSubviews: [dayTitleLabel, dayLabel],
        axis: .horizontal,
        spacing: 10
    )
    
    lazy var timeLabel = UIFactory_.makeLabel(
        text: "00:00:00",
        textColor: MySpecialColors.MainColor,
        font: UIFont.monospacedDigitSystemFont(ofSize: 68, weight: .semibold),
        textAlignment: .center
    )
    
    lazy var startStopButton: UIButton = createDoubleCheckButton(title: "집중 모드 시작하기", textColor: MySpecialColors.Gray1, cornerRadius: 24, backgroundColor: MySpecialColors.MainColor, font: UIFont.pretendard(style: .semiBold, size: 16, isScaled: true))
    lazy var resetButton: UIButton = createDoubleCheckButton(title: "RESET", textColor: MySpecialColors.Gray3, cornerRadius: 0, backgroundColor: .clear, font: UIFont.pretendard(style: .regular, size: 14, isScaled: true))
    
    private func createDoubleCheckButton(title: String, textColor: UIColor, cornerRadius: Int, backgroundColor: UIColor, font: UIFont) -> UIButton {
        let button = TabButtonUIFactory.tapButton(
            buttonTitle: title,
            textColor: textColor,
            cornerRadius: cornerRadius,
            backgroundColor: backgroundColor
        )
        button.titleLabel?.font = font
        return button
    }
    
    lazy var cheeringLabel = UIFactory_.makeLabel(
        text: "마리모가 응원해줄 거예요!",
        textColor: MySpecialColors.Gray4,
        font: UIFont.pretendard(style: .regular, size: 14, isScaled: true),
        textAlignment: .center
    )
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBackground()
        setupBubbleEmitter()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupBackground()
        setupBubbleEmitter()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
        bubbleEmitter.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height * 0.85)
        bubbleEmitter.emitterSize = CGSize(width: bounds.width, height: 1)
    }

    // MARK: - Setup View
    private func setupView() {
        addSubviews(timerView, buttonView, successView)
    
        timerView.addSubviews(dayView, timeLabel, cheeringLabel)
        dayView.addSubviews(dayStackView)
        buttonView.addSubviews(startStopButton, resetButton)

        setupTimerConstraints()        
    }
    
    private func setupTimerConstraints() {
        timerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(52)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(200)
        }
        
        dayView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(26)
        }
        
        dayStackView.snp.makeConstraints {
            $0.top.equalTo(dayView.snp.top)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalTo(dayView.snp.bottom)
            $0.width.greaterThanOrEqualTo(dayTitleLabel.snp.width).offset(12)
            $0.width.greaterThanOrEqualTo(dayLabel.snp.width).offset(12)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(dayView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        cheeringLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        successView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(100)
        }
        
        buttonView.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        startStopButton.snp.makeConstraints {
            $0.bottom.equalTo(resetButton.snp.top).offset(-6)
            $0.leading.trailing.equalToSuperview().inset(74)
            $0.height.equalTo(46)
        }
        
        resetButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(36)
        }
    }

    // MARK: - Setup Background
    private func setupBackground() {
        backgroundLayer = CAGradientLayer()
        backgroundLayer.frame = bounds
        
        let gray1Color = MySpecialColors.Gray1.cgColor
        let blueColor = MySpecialColors.Blue.cgColor
        
        backgroundLayer.colors = [
            gray1Color,
            blueColor
        ]
        
        backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundLayer.endPoint = CGPoint(x: 0.5, y: 2.0)
        layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    // MARK: - Bubble
     func setupBubbleEmitter() {
        bubbleEmitter = CAEmitterLayer()
        bubbleEmitter.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height * 0.85)
        bubbleEmitter.emitterShape = .line
        bubbleEmitter.emitterSize = CGSize(width: bounds.width, height: 1)
        
        let bubbleCell = CAEmitterCell()
        bubbleCell.contents = UIImage(named: "bubble")?.cgImage ?? createBubbleImage().cgImage
        bubbleCell.birthRate = 10
        bubbleCell.lifetime = 5.0
        bubbleCell.velocity = -50
        bubbleCell.velocityRange = -20
        bubbleCell.yAcceleration = -30
        bubbleCell.scale = 0.1
        bubbleCell.scaleRange = 0.2
        bubbleCell.alphaRange = 0.5
        bubbleCell.alphaSpeed = -0.1
        
        bubbleEmitter.emitterCells = [bubbleCell]
        layer.addSublayer(bubbleEmitter)
    }
    
    private func createBubbleImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
