//
//  CalendarCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/12/25.
//

import UIKit
import SnapKit

class CalendarCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dayLabel: UILabel = UILabel()
    
    private let selectedCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = .primary400
        
        return view
    }()
    
    private func configureUI() {
        selectedCircle.isHidden = true
        contentView.addSubview(selectedCircle)
        
        selectedCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(30)
        }
        
        contentView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(_ model: CalendarCellDataModel) {
        var dayAttributes: [NSAttributedString.Key: Any] = body14.attributes(alignment: .center)
        dayAttributes[.foregroundColor] = model.isDisabled ? UIColor.neutral500 : UIColor.neutral900
        
        dayLabel.attributedText = NSAttributedString(string: String(model.day), attributes: dayAttributes)
        
        selectedCircle.isHidden = !model.isSelected
        
        if model.isSelected {
            dayLabel.textColor = .backgroundWhite
        } else {
            dayLabel.textColor = !model.isCurrentMonth || model.isDisabled ? .neutral500 : .neutral900
        }
    }
}
