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
    
    var showCharactersCount: Bool = false {
        didSet {
            setShowCharactersCount(showCharactersCount)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    init(
        minHeight: CGFloat,
        maxHeight: CGFloat = 240,
        maxLength: Int,
        fontStyle: FontStyle
    ) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.maxLength = maxLength
        
        super.init(frame: .zero, textContainer: nil, fontStyle: fontStyle)
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let charactersLabel: UILabel = {
        let lb = UILabel()
        lb.isUserInteractionEnabled = false
        lb.isHidden = true
        
        return lb
    }()
    
    // MARK: - UI 설정
    private func configureUI() {
        self.backgroundColor = .clear
        
        // 여백 설정
        self.textContainer.lineFragmentPadding = 0
        
        // 초기 높이 설정
        self.snp.makeConstraints { make in
            heightConstraint = make.height.greaterThanOrEqualTo(minHeight).constraint
        }
        
        // 초기 글자 수
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
        
        attributedString.addAttributes(fontStyle.attributes(), range: range)
        
        self.attributedText = attributedString
    }
    
    private func setShowCharactersCount(_ show: Bool) {
        charactersLabel.isHidden = !show
        
        let charactersLabelHeight: CGFloat = body12.font.lineHeight + 8 + 8
        
        self.textContainerInset = .init(
            top: self.textContainerInset.top,
            left: self.textContainerInset.left,
            bottom: self.textContainerInset.bottom + (show ? charactersLabelHeight : -charactersLabelHeight),
            right: self.textContainerInset.right
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
