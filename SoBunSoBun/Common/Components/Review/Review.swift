//
//  Review.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/21/26.
//

import UIKit
import SnapKit
import RxSwift

class Review: UIButton {
    let number: Int
    
    private let disposeBag = DisposeBag()
    
    /// 숫자는 세자리까지만
    init(frame: CGRect = .zero, number: Int) {
        self.number = number
        
        super.init(frame: frame)
        
        configureUI()
        setEmoji()
        setTitleColor()
        bind()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 12
        ).cgPath
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        config.titleAlignment = .center
        
        self.backgroundColor = .backgroundWhite
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // 모서리
        self.layer.cornerRadius = 12
        
        // 테두리
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.primary50.cgColor
        
        // 그림자
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary300.withAlphaComponent(0.16).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 16
        self.clipsToBounds = false
        
        self.configuration = config
    }
    
    private func setEmoji() {
        guard number < 1000 && number > 0 else { return }
        
        switch number {
        case 1:
            configuration?.image = .emojiEightOclock.resize(.init(width: 16, height: 16))
            
        case 2:
            configuration?.image = .emojiGreenHeart.resize(.init(width: 16, height: 16))
            
        case 3:
            configuration?.image = .emojiThumbsUp.resize(.init(width: 16, height: 16))
            
        case 4:
            configuration?.image = .emojiGlowingStar.resize(.init(width: 16, height: 16))
            
        case 5:
            configuration?.image = .emojiGrinningFace.resize(.init(width: 16, height: 16))
            
        default:
            configuration?.image = .logo.resize(.init(width: 16, height: 16))
        }
    }
    
    private func setTitleColor() {
        guard number < 1000 && number > 0 else { return }
        
        var attributes = body16.attributes(alignment: .center)
        
        switch number {
        case 1:
            attributes[.foregroundColor] = UIColor.review1
            
        case 2:
            attributes[.foregroundColor] = UIColor.review2
            
        case 3:
            attributes[.foregroundColor] = UIColor.review3
            
        case 4:
            attributes[.foregroundColor] = UIColor.review4
            
        case 5:
            attributes[.foregroundColor] = UIColor.review5
            
        default:
            attributes[.foregroundColor] = UIColor.neutral900
        }
        
        let localizedString = NSLocalizedString(String(format: "Review%03d", number), tableName: "Review", comment: "")
        let attributedText = NSAttributedString(
            string: localizedString,
            attributes: attributes
        )
        
        self.configuration?.attributedTitle = AttributedString(attributedText)
    }
    
    private func updateUI(isSelected: Bool) {
        if isSelected {
            self.backgroundColor = .primary300
            self.layer.borderColor = UIColor.primary300.cgColor
            var attributes = body16.attributes(alignment: .center)
            attributes[.foregroundColor] = UIColor.backgroundWhite
            
            let localizedString = NSLocalizedString(String(format: "Review%03d", number), tableName: "Review", comment: "")
            let attributedText = NSAttributedString(
                string: localizedString,
                attributes: attributes
            )
            
            self.configuration?.attributedTitle = AttributedString(attributedText)
        } else {
            self.backgroundColor = .backgroundWhite
            self.layer.borderColor = UIColor.primary50.cgColor
            setTitleColor()
        }
    }
}

extension Review {
    private func bind() {
        self.configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            
            updateUI(isSelected: button.isSelected)
        }
        
        self.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.isSelected.toggle()
            })
            .disposed(by: disposeBag)
    }
}
