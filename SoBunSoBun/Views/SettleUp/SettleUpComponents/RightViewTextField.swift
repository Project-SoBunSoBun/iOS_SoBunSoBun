//
//  RightViewTextField.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/31/25.
//

import UIKit
import SnapKit

final class RightViewTextField: PaddedTextField {
    init(rightText: String) {
        super.init(frame: .zero, fontStyle: body16)
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
