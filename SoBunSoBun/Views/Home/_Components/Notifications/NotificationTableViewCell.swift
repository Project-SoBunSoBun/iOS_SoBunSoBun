//
//  NotificationTableViewCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/20/26.
//

import UIKit
import SnapKit
import RxSwift

class NotificationTableViewCell: UITableViewCell {
    static let identifier = "PostListTableViewCell"
    
    private let view = NotificationCellView()
    private var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(.high)
        }
    }
    
    func configureUI(message: String, createdAt: String, isRead: Bool, bottomEdgeInset: CGFloat = 0) {
        view.configureUI(message: message, createdAt: createdAt, isRead: isRead)
        
        if bottomEdgeInset != 0 {
            view.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview().inset(bottomEdgeInset).priority(.high)
            }
        }
        
        view.layoutIfNeeded()
    }
}
