//
//  TextFieldMember.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TextFieldMember: BaseTextField {
    private let minValue: Int
    private let maxValue: Int
    private let maxLength: Int
    
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect = .zero, minValue: Int, maxValue: Int, maxLength: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.maxLength = maxLength
        
        super.init(frame: frame, fontStyle: body16)
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let edgesPadding: CGFloat = 16
    
    private let rightDecoView: UILabel = {
        let lb = UILabel()
        var attributes: [NSAttributedString.Key: Any] = body16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral400
        
        lb.attributedText = NSAttributedString(string: String(localized: "PeopleCount", table: "Home"), attributes: attributes)
        lb.sizeToFit()
        
        return lb
    }()
    
    private lazy var rightPadding: CGFloat = edgesPadding + rightDecoView.frame.width + 8
    
    private lazy var leftContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: edgesPadding, height: rightDecoView.frame.height))
    private lazy var rightContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: edgesPadding + rightDecoView.frame.width, height: rightDecoView.frame.height))
    
    private func configureUI() {
        self.backgroundColor = .backgroundWhite
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 테두리
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.primary100.cgColor
        self.frame = CGRectInset(self.frame, -self.layer.borderWidth, -self.layer.borderWidth)
        
        // 오른쪽 정렬
        self.textAlignment = .right
        
        // 키보드 타입
        self.keyboardType = .numberPad
        
        // 아이콘 설정
        rightContainer.addSubview(rightDecoView)
        
        self.leftView = leftContainer
        self.leftViewMode = .always
        self.rightView = rightContainer
        self.rightViewMode = .always
    }
    
    private func bind() {
        self.rx.text.orEmpty
            .map { $0.filter { $0.isNumber } }
            .map { [weak self] text in
                guard let self = self else { return "" }
                
                return String(text.prefix(maxLength))
            }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                if self.text != text {
                    self.text = text
                }
            })
            .disposed(by: disposeBag)
        
        self.rx.controlEvent(.editingDidEnd)
            .withLatestFrom(self.rx.text.orEmpty)
            .compactMap { Int($0) }
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                
                self.text = "\(min(max(value, minValue), maxValue))"
                self.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: edgesPadding, left: edgesPadding, bottom: edgesPadding, right: rightPadding))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
