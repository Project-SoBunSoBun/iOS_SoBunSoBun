//
//  CustomWheelPickerCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/15/25.
//

import UIKit
import SnapKit

class WheelPickerCell: UITableViewCell {
    static let identifier = "CustomWheelPickerCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label: UILabel = UILabel()
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(text: String, isSelected: Bool) {
        var attributes: [NSAttributedString.Key: Any] = isSelected ? title20.attributes(alignment: .center) : body18.attributes(alignment: .center)
        attributes[.foregroundColor] = isSelected ? UIColor.primary400 : UIColor.neutral400
        
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
