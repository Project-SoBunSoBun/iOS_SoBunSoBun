//
//  AutoHeightTextView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/16/25.
//

import UIKit
import SnapKit
import RxSwift

class AutoHeightTextView: UITextView {
    private let minHeight: CGFloat
    private let maxLength: Int
    private var heightConstraint: Constraint?
    
    private let disposeBag = DisposeBag()
    
    init(
        minHeight: CGFloat,
        maxLength: Int,
        placeholder: String? = nil
    ) {
        self.minHeight = minHeight
        self.maxLength = maxLength
        
        super.init(frame: .zero, textContainer: nil)
        
        configureUI(placeholder: placeholder)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let placeholderLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.isUserInteractionEnabled = false
        
        return lb
    }()
    
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
    
    private func configureUI(placeholder: String?) {
        self.delegate = self
        
        self.backgroundColor = .clear
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 테두리
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.primary100.cgColor
        self.frame = CGRectInset(self.frame, -self.layer.borderWidth, -self.layer.borderWidth)
        
        // 폰트 설정
        self.font = body16.font
        
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        self.typingAttributes = attributes
        
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
        
        // placeholder
        if let placeholder = placeholder {
            var attributes = body16.attributes(alignment: .left)
            attributes[.foregroundColor] = UIColor.neutral300
            
            placeholderLabel.attributedText = NSAttributedString(string: placeholder, attributes: attributes)
            
            addSubview(placeholderLabel)
            
            placeholderLabel.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalToSuperview().offset(16)
            }
        }
        
        // 글자 수
        charactersLabel.text = "\(self.text.count)/\(maxLength)\(String(localized: "Characters"))"
        addSubview(charactersLabel)
    }
    
    private func bind() {
        self.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                placeholderLabel.isHidden = !text.isEmpty
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
    
    // 커서 설정
    private var cursorLayer: CAShapeLayer?
    private let cursorLineWidth: CGFloat = 1.5
    
    private func updateCursorLayer() {
        // 기존 레이어 제거
        cursorLayer?.removeFromSuperlayer()
        cursorLayer = nil
        
        // 실제 커서는 투명하게
        self.tintColor = .clear
        
        // 커스텀 레이어 추가
        guard isFirstResponder else { return }
        
        guard let selectedRange = selectedTextRange else { return }
        
        var caretRect = self.firstRect(for: selectedRange)
        caretRect = self.convert(caretRect, from: self.textInputView)
        
        let fontHeight = self.font?.lineHeight ?? 20
        
        let layer = CAShapeLayer()
        let path = UIBezierPath(
            roundedRect: CGRect(
                x: caretRect.origin.x + 1,
                y: caretRect.origin.y,
                width: cursorLineWidth,
                height: fontHeight
            ), cornerRadius: cursorLineWidth / 2
        )
        
        layer.path = path.cgPath
        layer.strokeColor = UIColor.primary400.cgColor
        layer.fillColor = UIColor.primary400.cgColor
        layer.lineWidth = cursorLineWidth
        
        // 깜빡이는 애니메이션
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "blink")
        
        self.layer.addSublayer(layer)
        cursorLayer = layer
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        updateCursorLayer()
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        cursorLayer?.removeFromSuperlayer()
        cursorLayer = nil
        return result
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
        
        updateCursorLayer()
    }
}

extension AutoHeightTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= maxLength
    }
    
    // 커서 위치가 변경될 때마다 업데이트
    func textViewDidChangeSelection(_ textView: UITextView) {
        updateCursorLayer()
    }
}
