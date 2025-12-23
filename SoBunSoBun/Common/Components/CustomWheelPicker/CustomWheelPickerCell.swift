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
    
    private let label: UILabel = {
        let lb = UILabel()
        lb.font = body18.font
        lb.textColor = .neutral400
        lb.textAlignment = .center
        
        return lb
    }()
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(text: String, isSelected: Bool) {
        label.text = text
        
        if isSelected {
            label.font = title20.font
            label.textColor = .primary400
        } else {
            label.font = body18.font
            label.textColor = .neutral400
        }
    }
}
