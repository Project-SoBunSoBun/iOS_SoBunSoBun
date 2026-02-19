//
//  TextFieldUnderline.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/11/25.
//

import UIKit
import RxSwift
import RxCocoa

class TextFieldUnderline: BaseTextField {
    private let maxLength: Int
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect = .zero, maxLength: Int) {
        self.maxLength = maxLength
        
        super.init(frame: frame, fontStyle: body16)
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let underlineLayer = CALayer()
    
    private func configureUI() {
        self.borderStyle = .none
        self.textColor = .neutral900
        
        // underline
        underlineLayer.backgroundColor = UIColor.primary100.cgColor
        self.layer.addSublayer(underlineLayer)
    }
    
    private func bind() {
        self.rx.text.orEmpty
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                // 글자 수 제한
                if self.text?.count ?? 0 > maxLength {
                    let index = text.index(text.startIndex, offsetBy: maxLength)
                    self.text = String(text[..<index])
                }
            })
            .disposed(by: disposeBag)
        
        self.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(
            top: 16,
            left: 0,
            bottom: 16,
            right: 0
        ))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let underlineHeight: CGFloat = 1
        underlineLayer.frame = CGRect(x: 0, y: bounds.height - underlineHeight, width: bounds.width, height: underlineHeight)
    }
}
