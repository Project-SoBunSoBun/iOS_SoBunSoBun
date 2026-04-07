//
//  Review.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 1/21/26.
//

import UIKit
import SnapKit
import RxSwift

class Review: UIButton {
    let number: String
    
    private let EDGES_INSET: CGFloat = 10
    
    private let disposeBag = DisposeBag()
    
    /// 숫자는 세자리까지만
    init(frame: CGRect = .zero, number: String) {
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
    private let emojiView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        
        return iv
    }()
    
    private let label: UILabel = {
        let lb = UILabel()
        lb.isUserInteractionEnabled = false
        
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
    private func configureUI() {
        self.isUserInteractionEnabled = false
        
        self.backgroundColor = .backgroundWhite
        
        // 테두리
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.primary50.cgColor
        
        // 모서리
        self.layer.cornerRadius = 12
        
        // 그림자
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary300.withAlphaComponent(0.16).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 16
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = false
        
        [emojiView, label].forEach {
            addSubview($0)
        }
        
        emojiView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(EDGES_INSET)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(emojiView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(EDGES_INSET)
            make.verticalEdges.equalToSuperview().inset(EDGES_INSET)
        }
    }
    
    private func setEmoji() {
        guard number.count == 3 else { return }
        
        switch number {
        case "001":
            emojiView.image = .emojiEightOclock
            
        case "002":
            emojiView.image = .emojiGreenHeart
            
        case "003":
            emojiView.image = .emojiThumbsUp
            
        case "004":
            emojiView.image = .emojiGlowingStar
            
        case "005":
            emojiView.image = .emojiGrinningFace
            
        default:
            emojiView.image = .appLogo
        }
    }
    
    private func setTitleColor() {
        guard number.count == 3 else { return }
        
        var attributes = body16.attributes(alignment: .center)
        
        switch number {
        case "001":
            attributes[.foregroundColor] = UIColor.review1
            
        case "002":
            attributes[.foregroundColor] = UIColor.review2
            
        case "003":
            attributes[.foregroundColor] = UIColor.review3
            
        case "004":
            attributes[.foregroundColor] = UIColor.review4
            
        case "005":
            attributes[.foregroundColor] = UIColor.review5
            
        default:
            attributes[.foregroundColor] = UIColor.neutral900
        }
        
        let localizedString = NSLocalizedString(String(format: "Review\(number)"), tableName: "Review", comment: "")
        let attributedText = NSAttributedString(
            string: localizedString,
            attributes: attributes
        )
        
        label.attributedText = attributedText
    }
    
    private func updateUI(isSelected: Bool) {
        if isSelected {
            self.backgroundColor = .primary300
            self.layer.borderColor = UIColor.primary300.cgColor
            
            var attributes = body16.attributes(alignment: .center)
            attributes[.foregroundColor] = UIColor.backgroundWhite
            let localizedString = NSLocalizedString(String(format: "Review\(number)"), tableName: "Review", comment: "")
            
            label.attributedText = NSAttributedString(string: localizedString, attributes: attributes)
        } else {
            self.backgroundColor = .backgroundWhite
            self.layer.borderColor = UIColor.primary50.cgColor
            
            setTitleColor()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        let width = EDGES_INSET + 16 + 8 + labelSize.width + EDGES_INSET
        let height = EDGES_INSET + labelSize.height + EDGES_INSET
        
        return CGSize(width: width, height: height)
    }
}

extension Review {
    private func bind() {
        self.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.isSelected.toggle()
                self.updateUI(isSelected: self.isSelected)
            })
            .disposed(by: disposeBag)
    }
}
