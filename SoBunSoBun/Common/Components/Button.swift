//
//  Button.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/26/25.
//

import UIKit
import SnapKit

class Button: UIButton {
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? .primary400 : .neutral200
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
        self.backgroundColor = self.isEnabled ? .primary400 : .neutral200
        self.setTitleColor(.backgroundWhite, for: .normal)
        self.setTitleColor(.backgroundWhite, for: .disabled)
        self.setTitleColor(.backgroundWhite, for: .highlighted)
        self.titleLabel?.font = title20.font
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        self.snp.makeConstraints { make in
            make.height.equalTo(64)
        }
    }
}
