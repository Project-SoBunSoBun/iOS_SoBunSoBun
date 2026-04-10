//
//  BaseTextView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 12/23/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

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
        
        // 새로 입력되는 텍스트에 적용될 속성 설정
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
    
    // 이미지 붙여넣기 이벤트 저장소
    // Relay는 에러 없이 이벤트만 전달하므로 UI 이벤트를 다루기에 적합
    private let imagePasteRelay = PublishRelay<UIImage>()
    
    // 외부에는 Signal로 노출
    // Signal은 메인 스레드에서 동작하고 에러를 방출하지 않아, 화면 이벤트를 안전하게 바인딩할 때 사용
    // 따라서 구독 시 일반 subscribe 대신 UI 바인딩 전용 메서드인 emit을 사용
    var imagePasted: Signal<UIImage> {
        imagePasteRelay.asSignal()
    }
    
    // 클립보드에 이미지가 있으면 Rx 이벤트로 전달하고, 텍스트면 기본 붙여넣기 수행
    override func paste(_ sender: Any?) {
        if let image = UIPasteboard.general.image {
            imagePasteRelay.accept(image)
        } else {
            super.paste(sender)
        }
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
        
        // typingAttributes 기반으로 실제 라인 높이와 폰트 높이 계산
        let paraStyle = typingAttributes[.paragraphStyle] as? NSParagraphStyle
        let lineHeight = paraStyle?.minimumLineHeight ?? (fontStyle.fontSize * fontStyle.lineHeightMultiple)
        let font = (typingAttributes[.font] as? UIFont) ?? self.font
        let naturalFontHeight = font?.lineHeight ?? lineHeight
        
        // baselineOffset만큼 y를 내려 글리프 위치와 커서를 정렬
        let yOffset = max(0, (lineHeight - naturalFontHeight) / 2)
        
        let layer = CAShapeLayer()
        let path = UIBezierPath(
            roundedRect: CGRect(
                x: caretRect.origin.x + 1,
                y: caretRect.origin.y + yOffset,
                width: cursorLineWidth,
                height: naturalFontHeight
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
