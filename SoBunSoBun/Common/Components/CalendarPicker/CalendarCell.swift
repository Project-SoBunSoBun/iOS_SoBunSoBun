//
//  CalendarCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/12/25.
//

import UIKit
import SnapKit

class CalendarCell: UICollectionViewCell {
    private let dayLabel: UILabel = {
        let lb = UILabel()
        lb.font = body14.font
        lb.textColor = .neutral900
        lb.textAlignment = .center
        
        return lb
    }()
    
    private let selectedCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = .primary400
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        dayLabel.text = "\(model.day)"
        dayLabel.textColor = model.isDisabled ? .neutral500 : .neutral900
        
        contentView.alpha = 1.0
        
        if model.isSelected {
            selectedCircle.isHidden = false
            dayLabel.textColor = .backgroundWhite
        } else {
            selectedCircle.isHidden = true
            dayLabel.textColor = !model.isCurrentMonth || model.isDisabled ? .neutral500 : .neutral900
        }
    }
}
