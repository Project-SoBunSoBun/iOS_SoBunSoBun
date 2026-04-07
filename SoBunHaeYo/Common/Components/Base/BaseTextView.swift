//
//  BaseTextView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 12/23/25.
//

import UIKit
import SnapKit
import RxSwift

class BaseTextView: UITextView {
    let fontStyle: FontStyle
    
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect, textContainer: NSTextContainer?, fontStyle: FontStyle) {
        self.fontStyle = fontStyle
        super.init(frame: frame, textContainer: textContainer)
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var placeholder: String? {
        didSet {
            guard let placeholder = placeholder else {
                placeholderLabel.isHidden = true
                
                return
            }
            
            var attributes = body16.attributes(alignment: .left)
            attributes[.foregroundColor] = UIColor.neutral400
            
            placeholderLabel.attributedText = NSAttributedString(string: placeholder, attributes: attributes)
            placeholderLabel.isHidden = placeholder.isEmpty
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            updatePlaceholderConstraints()
        }
    }
    
    private let placeholderLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.isUserInteractionEnabled = false
        
        return lb
    }()
    
    private func configureUI() {
        // 폰트 설정
        self.font = fontStyle.font
        
        // 행간 설정
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        self.typingAttributes = attributes
        
        // placeholder
        addSubview(placeholderLabel)

        updatePlaceholderConstraints()
    }

    private func updatePlaceholderConstraints() {
        let padding = textContainer.lineFragmentPadding

        placeholderLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(textContainerInset.left + padding)
            make.trailing.equalToSuperview().inset(textContainerInset.right + padding)
            make.top.equalToSuperview().offset(textContainerInset.top)
        }
    }
    
    private func bind() {
        self.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                placeholderLabel.isHidden = !text.isEmpty
            })
            .disposed(by: disposeBag)
    }
    
    // 시스템 커서 숨김 (tintColor를 clear로 하면 스페이스바 트랙패드 모드가 비활성화되므로 caretRect로 처리)
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    // 커서 설정
    private var cursorLayer: CAShapeLayer?
    private let cursorLineWidth: CGFloat = 1.5
    
    func updateCursorLayer() {
        // 기존 레이어 제거
        cursorLayer?.removeFromSuperlayer()
        cursorLayer = nil
        
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
    
    override var selectedTextRange: UITextRange? {
        didSet {
            updateCursorLayer()
        }
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
        updateCursorLayer()
    }
}
