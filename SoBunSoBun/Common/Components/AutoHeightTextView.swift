//
//  AutoHeightTextView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/16/25.
//

import UIKit
import SnapKit
import RxSwift

class AutoHeightTextView: BaseTextView {
    private let minHeight: CGFloat
    private let maxLength: Int
    private var heightConstraint: Constraint?
    
    private let disposeBag = DisposeBag()
    
    init(
        minHeight: CGFloat,
        maxLength: Int
    ) {
        self.minHeight = minHeight
        self.maxLength = maxLength
        
        super.init(frame: .zero, textContainer: nil, fontStyle: body16)
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let charactersContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    private let charactersLabel: UILabel = {
        let lb = UILabel()
        lb.font = body12.font
        lb.textColor = .neutral600
        lb.textAlignment = .right
        lb.isUserInteractionEnabled = false
        
        return lb
    }()
    
    private func configureUI() {
        self.delegate = self
        
        self.backgroundColor = .clear
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 테두리
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.primary100.cgColor
        self.frame = CGRectInset(self.frame, -self.layer.borderWidth, -self.layer.borderWidth)
        
        // 여백 설정
        self.textContainerInset = .init(top: 16, left: 16, bottom: 16 + body12.font.lineHeight + 8 + 8, right: 16)
        self.textContainer.lineFragmentPadding = 0
        
        // 스크롤 설정
        self.isScrollEnabled = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        // 초기 높이 설정
        self.snp.makeConstraints { make in
            heightConstraint = make.height.greaterThanOrEqualTo(minHeight).constraint
        }
        
        // 글자 수
        charactersLabel.text = "\(self.text.count)/\(maxLength)\(String(localized: "Characters"))"
        addSubview(charactersLabel)
    }
    
    private func bind() {
        self.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                charactersLabel.text = "\(text.count)/\(maxLength)\(String(localized: "Characters"))"
                
                updateHeight()
                applyLineHeight()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateHeight() {
        // 현재 텍스트에 필요한 높이 계산
        let size = CGSize(width: bounds.width, height: .infinity)
        let estimatedSize = sizeThatFits(size)
        
        var newHeight = estimatedSize.height
        
        newHeight = max(newHeight, minHeight)
        
        heightConstraint?.update(offset: newHeight)
        
        setNeedsLayout()
        layoutIfNeeded()
        
        DispatchQueue.main.async { [weak self] in
            self?.updateCursorLayer()
        }
    }
    
    private func applyLineHeight() {
        guard !text.isEmpty else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attributedString.length)
        
        attributedString.addAttributes(body16.attributes(), range: range)
        
        self.attributedText = attributedString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // SnapKit으로 위치 지정이 되지 않아 frame으로 설정
        let labelWidth = charactersLabel.intrinsicContentSize.width
        let labelHeight = charactersLabel.font.lineHeight
        
        charactersLabel.frame = CGRect(
            x: bounds.width - 16 - labelWidth,
            y: bounds.height - 16 - labelHeight,
            width: labelWidth,
            height: labelHeight
        )
    }
}

extension AutoHeightTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= maxLength
    }
}
