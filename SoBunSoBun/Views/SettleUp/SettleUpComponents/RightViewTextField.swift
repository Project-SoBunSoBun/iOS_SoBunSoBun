//
//  RightViewTextField.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/31/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RightViewTextField: PaddedTextField {
    init(rightText: String, keyboardType: UIKeyboardType = .numberPad) {
        super.init(frame: .zero, fontStyle: body16)
        self.keyboardType = keyboardType
        configureUI(rightText: rightText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI(rightText: String) {
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.primary100.cgColor
        backgroundColor = .backgroundWhite
        textAlignment = .right
        self.placeholder = String("0")
        
        let label = UILabel(frame: .zero)
        label.text = rightText
        label.font = body16.font
        label.textColor = .neutral900
        
        let container = UIView()
        container.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
            )
        }
        
        configurePadding(width: Int(14))
        rightView = container
        rightViewMode = .always
    }
    
    func updateRightViewText(_ text: String) {
        guard let container = rightView else { return }
        
        if let label = container.subviews.first as? UILabel {
            label.text = text
            
            configurePadding(width: Int(14))
        }
    }
}

extension Reactive where Base: RightViewTextField {
    /// 천 단위 콤마가 포함된 숫자 텍스트
    var formattedNumericText: ControlProperty<String> {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        
        let source = base.rx.text.orEmpty
            .map { [weak base] text -> String in
                guard let base = base else { return "" }

                let numbers = text.filter { $0.isNumber }

                guard !numbers.isEmpty, let value = Int(numbers) else {
                    if base.text != "" {
                        base.text = ""
                    }
                    
                    return ""
                }

                let formatted = formatter.string(from: NSNumber(value: value)) ?? numbers
                
                if base.text != formatted {
                    base.text = formatted
                }
                
                return numbers
            }
        
        let observer = Binder<String>(base) { textField, text in
            let numbers = text.filter { $0.isNumber }
            guard !numbers.isEmpty, let value = Int(numbers) else {
                if textField.text != "" {
                    textField.text = ""
                }
                
                return
            }
            
            let formatted = formatter.string(from: NSNumber(value: value)) ?? numbers
            if textField.text != formatted {
                textField.text = formatted
            }
        }
        
        return ControlProperty(values: source, valueSink: observer)
    }
}
