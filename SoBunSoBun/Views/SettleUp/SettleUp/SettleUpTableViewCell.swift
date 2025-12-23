//
//  SettleUpTableViewCell.swift
//  SoBunSoBun
//
//  Created by 허성필 on 11/19/25.
//

import UIKit
import SnapKit

class SettleUpTableViewCell: UITableViewCell {
    
    private var incompleteView: Incomplete?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        incompleteView?.removeFromSuperview()
        incompleteView = nil
    }
    
    func configure(with item: SettleUpItem,
                   onDeleteTapped: @escaping () -> Void = {},
                   onSettleUpButtonTapped: @escaping () -> Void = {},
                   onStatementCheckButtonTapped: @escaping () -> Void = {},
                   onShareButtonTapped: @escaping () -> Void = {}
    ) {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        incompleteView?.removeFromSuperview()
        
        let newIncompleteView = Incomplete(
            SettleUpStatus: item.settleUpStatus,
            title: item.title,
            location: item.location,
            meetingDate: item.meetingDate
        )
        
        incompleteView = newIncompleteView
        contentView.addSubview(newIncompleteView)
        
        newIncompleteView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
        }
        
        incompleteView?.onDeleteButtonTapped = onDeleteTapped
        incompleteView?.onSettleUpButtonTapped = onSettleUpButtonTapped
        incompleteView?.onStatementCheckButtonTapped = onStatementCheckButtonTapped
        incompleteView?.onShareButtonTapped = onShareButtonTapped
    }
}
