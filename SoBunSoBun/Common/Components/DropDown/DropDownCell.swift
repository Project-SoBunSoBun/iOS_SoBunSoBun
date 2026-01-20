//
//  DropDownCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/17/26.
//

import UIKit

class DropDownCell: UIStackView {
    let title: String
    
    init(frame: CGRect = .zero, title: String) {
        self.title = title
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label = UILabel()
    
    private let icon: UIImageView = {
        let iv = UIImageView()
        iv.image = .greyCheck
        iv.contentMode = .scaleAspectFit
        iv.preferredSymbolConfiguration = .init(pointSize: 24)
        iv.isHidden = true
        
        return iv
    }()
    
    private func configureUI() {
        self.axis = .horizontal
        self.spacing = 8
        self.alignment = .center
        self.isLayoutMarginsRelativeArrangement = true
        self.directionalLayoutMargins = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        var attributes: [NSAttributedString.Key: Any] = title14.attributes()
        attributes[.foregroundColor] = UIColor.neutral600
        
        label.attributedText = NSAttributedString(string: NSLocalizedString(title, comment: ""), attributes: attributes)
        
        [label, icon].forEach {
            self.addArrangedSubview($0)
        }
        
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    func toggleSelect(isSelected: Bool) {
        icon.isHidden = !isSelected
        
        var attributes: [NSAttributedString.Key: Any] = title14.attributes()
        attributes[.foregroundColor] = isSelected ? UIColor.neutral900 : UIColor.neutral600
        
        label.attributedText = NSAttributedString(string: NSLocalizedString(title, comment: ""), attributes: attributes)
    }
}
