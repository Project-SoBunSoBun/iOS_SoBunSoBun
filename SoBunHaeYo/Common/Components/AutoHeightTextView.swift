//
//  AutoHeightTextView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 12/16/25.
//

import UIKit
import SnapKit
import RxSwift

class AutoHeightTextView: UIView {
    private let minHeight: CGFloat
    private let maxHeight: CGFloat
    private let maxLength: Int
    private let fontStyle: FontStyle
    private var heightConstraint: Constraint?
    
    var showCharactersCount: Bool = false {
        didSet {
            setShowCharactersCount(showCharactersCount)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    var text: String? {
        get {
            textView.text
        }
        set {
            textView.text = newValue
        }
    }
    
    var placeholder: String? {
        didSet {
            textView.placeholder = placeholder
        }
    }
    
    var textContainerInset: UIEdgeInsets = .zero {
        didSet {
            updateTextViewInsets()
        }
    }
    
    var isScrollEnabled: Bool = true {
        didSet {
            textView.isScrollEnabled = isScrollEnabled
        }
    }
    
    init(
        frame: CGRect = .zero,
        minHeight: CGFloat,
        maxHeight: CGFloat = 240,
        maxLength: Int,
        fontStyle: FontStyle
    ) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.maxLength = maxLength
        self.fontStyle = fontStyle
        
        super.init(frame: frame)
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    lazy var textView: BaseTextView = {
        let tv = BaseTextView(frame: .zero, textContainer: nil, fontStyle: fontStyle)
        tv.backgroundColor = .clear
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()
    
    private let charactersLabel: UILabel = {
        let lb = UILabel()
        lb.isUserInteractionEnabled = false
        lb.isHidden = true
        
        return lb
    }()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        self.backgroundColor = .clear
        
        addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            // 초기 높이 설정
            heightConstraint = make.height.greaterThanOrEqualTo(minHeight).priority(.high).constraint
        }
        
        addSubview(charactersLabel)
        
        // 초기 글자 수
        updateCharactersLabel(count: 0)
        
        charactersLabel.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(16)
        }
    }
    
    func updateHeight() {
        // 현재 텍스트에 필요한 높이 계산
        let size = CGSize(width: bounds.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        var newHeight = estimatedSize.height
        
        newHeight = max(newHeight, minHeight)
        newHeight = min(newHeight, maxHeight)
        
        heightConstraint?.update(offset: newHeight)
        
        layoutIfNeeded()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            textView.updateCursorLayer()
        }
    }
    
    func applyLineHeight() {
        guard !textView.text.isEmpty else { return }
        
        let attributedString = NSMutableAttributedString(string: textView.text)
        let range = NSRange(location: 0, length: attributedString.length)
        
        attributedString.addAttributes(fontStyle.attributes(), range: range)
        
        textView.attributedText = attributedString
    }
    
    private func updateTextViewInsets() {
        var inset = textContainerInset
        
        if showCharactersCount {
            let charactersLabelHeight: CGFloat = body12.font.lineHeight + 8 + 8
            inset.bottom += charactersLabelHeight
        }
        
        textView.textContainerInset = inset
        
        updateHeight()
    }
    
    private func setShowCharactersCount(_ show: Bool) {
        charactersLabel.isHidden = !show
        
        updateTextViewInsets()
    }
    
    private func updateCharactersLabel(count: Int) {
        var charactersAttributes: [NSAttributedString.Key: Any] = body12.attributes(alignment: .right)
        charactersAttributes[.foregroundColor] = UIColor.neutral600
        
        charactersLabel.attributedText = NSAttributedString(
            string: "\(count)/\(maxLength)\(String(localized: "Characters", table: "Common"))",
            attributes: charactersAttributes
        )
    }
}

extension AutoHeightTextView {
    var rx: Reactive<BaseTextView> {
        return textView.rx
    }
    
    private func bind() {
        textView.rx.text.orEmpty
            .skip(1)
            .subscribe(onNext: { [weak self] isEditable in
                guard let self = self else { return }
                
                // 글자 수 제한
                if textView.text.count > maxLength {
                    let index = textView.text.index(textView.text.startIndex, offsetBy: maxLength)
                    textView.text = String(textView.text[..<index])
                }
                
                // 글자 수 표시
                updateCharactersLabel(count: textView.text.count)
                
                updateHeight()
                applyLineHeight()
            })
            .disposed(by: disposeBag)
    }
}
