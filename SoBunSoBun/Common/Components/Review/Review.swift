//
//  Review.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/21/26.
//

import UIKit
import SnapKit

class Review: UIStackView {
    init(frame: CGRect = .zero, title: String) {
        super.init(frame: frame)
        
        configure()
        setEmojiAndColor(reviewNumber: title)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 이모지 뷰
    private let emojiView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        
        return v
    }()
    
    // 텍스트 라벨
    private let titleLabel: UILabel = {
        let lb = UILabel()
        
        return lb
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 12
        ).cgPath
    }
    
    // MARK: - 레이아웃 설정
    private func configure() {
        self.backgroundColor = .backgroundWhite
        
        self.axis = .horizontal
        self.spacing = 8
        self.alignment = .center
        self.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        self.isLayoutMarginsRelativeArrangement = true
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
        
        [emojiView, titleLabel].forEach {
            self.addArrangedSubview($0)
        }
        
        emojiView.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
                
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        emojiView.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func setEmojiAndColor(reviewNumber: String) {
        var attributes = body16.attributes(alignment: .center)
        
        let suffix = String(reviewNumber.suffix(3))
        guard let number = Int(suffix) else { return }
        
        switch number {
        case 1:
            emojiView.image = .emojiEightOclock
            attributes[.foregroundColor] = UIColor.review1
            
        case 2:
            emojiView.image = .emojiGreenHeart
            attributes[.foregroundColor] = UIColor.review2
            
        case 3:
            emojiView.image = .emojiThumbsUp
            attributes[.foregroundColor] = UIColor.review3
            
        case 4:
            emojiView.image = .emojiGlowingStar
            attributes[.foregroundColor] = UIColor.review4
            
        case 5:
            emojiView.image = .emojiGrinningFace
            attributes[.foregroundColor] = UIColor.review5
            
        default:
            emojiView.image = .logo
            attributes[.foregroundColor] = UIColor.neutral900
        }
        
        let localizedString = NSLocalizedString(reviewNumber, tableName: "Review", comment: "")
        let attributedText = NSAttributedString(
            string: localizedString,
            attributes: attributes
        )
        
        titleLabel.attributedText = attributedText
    }
}
