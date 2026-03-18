//
//  MyProfileTabButton.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/18/26.
//

import UIKit

class MyProfileTabButton: UIButton {
    private let title: String
    
    override var isSelected: Bool {
        didSet {
            changeSelectedStyle(isSelected: isSelected)
        }
    }
    
    private var attributes = title14.attributes(alignment: .center)
    
    init(title: String, frame: CGRect = .zero) {
        self.title = title
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = 12
        config.background.backgroundColor = .clear
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        attributes[.foregroundColor] = UIColor.neutral600
        
        config.attributedTitle = AttributedString(NSAttributedString(
            string: title,
            attributes: attributes
        ))
        
        self.configuration = config
    }
    
    private func changeSelectedStyle(isSelected: Bool) {
        self.configuration?.background.backgroundColor = isSelected ? .primary300 : .clear
        
        attributes[.foregroundColor] = isSelected ? UIColor.backgroundWhite : UIColor.neutral600
        
        self.configuration?.attributedTitle = AttributedString(NSAttributedString(
            string: title,
            attributes: attributes
        ))
    }
}
