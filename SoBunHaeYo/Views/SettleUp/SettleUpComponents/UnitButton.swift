//
//  UnitButton.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 12/30/25.
//

import UIKit

class UnitButton: UIButton {
    
    private let titleKey: String.LocalizationValue
    
    init(titleKey: String.LocalizationValue, isSelected: Bool) {
        self.titleKey = titleKey
        super.init(frame: .zero)
        
        configureBase()
        configure(isSelected: isSelected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBase() {
        var config = UIButton.Configuration.filled()
        
        var attributedString = AttributedString(String(localized: titleKey, table: "SettleUp"))
        attributedString.font = title16.font
        
        config.attributedTitle = attributedString
        config.contentInsets = .init(top: 16, leading: 12, bottom: 16, trailing: 12)
        
        self.configuration = config
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
    }
    
    private func configure(isSelected: Bool) {
        var config = self.configuration ?? UIButton.Configuration.filled()
        
        if isSelected {
            config.baseBackgroundColor = .primary100
            config.baseForegroundColor = .primary400
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.primary400.cgColor
        } else {
            config.baseBackgroundColor = .backgroundWhite
            config.baseForegroundColor = .primary300
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.primary100.cgColor
        }
        
        self.configuration = config
    }
}
