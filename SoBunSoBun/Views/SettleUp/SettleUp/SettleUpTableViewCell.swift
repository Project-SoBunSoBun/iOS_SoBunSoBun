//
//  SettleUpTableViewCell.swift
//  SoBunSoBun
//
//  Created by 허성필 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

class SettleUpTableViewCell: UITableViewCell {
    static let identifier = "SettleUpTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var incompleteView: Incomplete?
    
    var disposeBag = DisposeBag()
    
    let deleteTrigger = PublishRelay<Void>()
    let settleUpTrigger = PublishRelay<Void>()
    let statementCheckTrigger = PublishRelay<Void>()
    let shareTrigger = PublishRelay<Void>()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        
        incompleteView?.removeFromSuperview()
        incompleteView = nil
    }
    
    func configure(with item: SettleUpItemModel) {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        incompleteView?.removeFromSuperview()
        
        let newIncompleteView = Incomplete(
            SettleUpStatus: item.settlementStatus,
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
        
        newIncompleteView.deleteTrigger
            .bind(to: deleteTrigger)
            .disposed(by: disposeBag)
        
        newIncompleteView.settleUpTrigger
            .bind(to: settleUpTrigger)
            .disposed(by: disposeBag)
        
        newIncompleteView.statementTrigger
            .bind(to: statementCheckTrigger)
            .disposed(by: disposeBag)
        
        newIncompleteView.shareTrigger
            .bind(to: shareTrigger)
            .disposed(by: disposeBag)
    }
}
