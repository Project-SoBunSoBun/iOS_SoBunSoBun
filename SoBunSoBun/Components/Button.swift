//
//  Button.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/26/25.
//

import UIKit
import SnapKit

class Button: UIButton {
    enum ColorType {
        case primary, black
    }
    
    var colorType: ColorType = .primary {
        didSet {
            self.backgroundColor = colorType == .primary ? .primary300 : .black0
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ?
            (colorType == .primary ? .primary300 : .black0) : .neutral200
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.setTitleColor(.backgroundWhite, for: .normal)
        self.setTitleColor(.backgroundWhite, for: .disabled)
        self.setTitleColor(.backgroundWhite, for: .highlighted)
        self.titleLabel?.font = title16.font
        self.layer.cornerRadius = 14
        
        self.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}
