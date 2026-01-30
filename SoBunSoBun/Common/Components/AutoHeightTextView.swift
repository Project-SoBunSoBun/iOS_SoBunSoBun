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
    private let maxHeight: CGFloat
    private let maxLength: Int
    private var heightConstraint: Constraint?
    
    var showCharactersCount: Bool = true {
        didSet {
            setShowCharactersCount(showCharactersCount)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    init(
        minHeight: CGFloat,
        maxHeight: CGFloat = 240,
        maxLength: Int,
        showBorder: Bool = true
    ) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.maxLength = maxLength
        
        super.init(frame: .zero, textContainer: nil, fontStyle: body16)
        
        configureUI(showBorder: showBorder)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let charactersContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    private let charactersLabel: UILabel = {
        let lb = UILabel()
        lb.isUserInteractionEnabled = false
        
        return lb
    }()
    
    // MARK: - UI 설정
    private func configureUI(showBorder: Bool) {
        self.backgroundColor = .clear
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 테두리
        if showBorder {
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.primary100.cgColor
            self.frame = CGRectInset(self.frame, -self.layer.borderWidth, -self.layer.borderWidth)
        }
        
        // 여백 설정
        self.textContainerInset = .init(top: 16, left: 16, bottom: 16 + body12.font.lineHeight + 8 + 8, right: 16)
        self.textContainer.lineFragmentPadding = 0
        
        // 스크롤 설정
        self.isScrollEnabled = true
        self.showsVerticalScrollIndicator = true
        self.showsHorizontalScrollIndicator = false
        
        // 초기 높이 설정
        self.snp.makeConstraints { make in
            heightConstraint = make.height.greaterThanOrEqualTo(minHeight).constraint
        }
        
        // 글자 수
        var charactersAttributes: [NSAttributedString.Key: Any] = body12.attributes(alignment: .right)
        charactersAttributes[.foregroundColor] = UIColor.neutral600
        
        charactersLabel.attributedText = NSAttributedString(string: "\(self.text.count)/\(maxLength)\(String(localized: "Characters", table: "Common"))", attributes: charactersAttributes)
        addSubview(charactersLabel)
    }
    
    private func updateHeight() {
        // 현재 텍스트에 필요한 높이 계산
        let size = CGSize(width: bounds.width, height: .infinity)
        let estimatedSize = sizeThatFits(size)
        
        var newHeight = estimatedSize.height
        
        newHeight = max(newHeight, minHeight)
        newHeight = min(newHeight, maxHeight)
        
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
    
    private func setShowCharactersCount(_ show: Bool) {
        charactersLabel.isHidden = !show
        
        self.textContainerInset = .init(
            top: 16,
            left: 16,
            bottom: 16 + (show ?
                          body12.font.lineHeight + 8 + 8 :
                            0),
            right: 16
        )
    }
    
    private func updateCharactersLabel(count: Int) {
        var charactersAttributes: [NSAttributedString.Key: Any] = body12.attributes(alignment: .right)
        charactersAttributes[.foregroundColor] = UIColor.neutral600
        
        charactersLabel.attributedText = NSAttributedString(
            string: "\(count)/\(maxLength)\(String(localized: "Characters", table: "Common"))",
            attributes: charactersAttributes
        )
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
    private func bind() {
        self.rx.text.orEmpty
            .map { [weak self] text in
                guard let self = self else { return "" }
                
                return String(text.prefix(maxLength))
            }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                // 글자 수 제한
                if self.text != text {
                    self.text = text
                }
                
                // 글자 수 표시
                updateCharactersLabel(count: text.count)
                
                updateHeight()
                applyLineHeight()
            })
            .disposed(by: disposeBag)
    }
}
