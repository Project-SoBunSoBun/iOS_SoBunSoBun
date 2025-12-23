//
//  TextFieldMember.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/11/25.
//

import UIKit
import SnapKit

class TextFieldMember: BaseTextField {
    let minValue: Int
    let maxValue: Int
    
    init(frame: CGRect = .zero, minValue: Int, maxValue: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        
        super.init(frame: frame, fontStyle: body16)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let edgesPadding: CGFloat = 16
    
    private let rightDecoView: UILabel = {
        let lb = UILabel()
        lb.text = String(localized: "PeopleCount")
        lb.font = body16.font
        lb.textColor = .neutral300
        lb.textAlignment = .center
        lb.sizeToFit()
        
        return lb
    }()
    
    private lazy var rightPadding: CGFloat = edgesPadding + rightDecoView.frame.width + 8
    
    private lazy var leftContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: edgesPadding, height: rightDecoView.frame.height))
    private lazy var rightContainer: UIView = UIView(frame: CGRect(x: 0, y: 0, width: edgesPadding + rightDecoView.frame.width, height: rightDecoView.frame.height))
    
    private func configureUI() {
        self.delegate = self
        
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

extension TextFieldMember: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isEmpty {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
        }
        
        // 현재 텍스트 계산
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 빈 문자열 허용
        if updatedText.isEmpty {
            return true
        }
        
        // Int 변환 체크
        guard Int(updatedText) != nil else { return false }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text,
              !text.isEmpty,
              let value = Int(text) else { return }
        
        // value의 범위가 벗어났을 때 강제 value 조정
        if value < minValue {
            textField.text = "\(minValue)"
        } else if value > maxValue {
            textField.text = "\(maxValue)"
        }
        
        textField.sendActions(for: .editingChanged)
    }
}
