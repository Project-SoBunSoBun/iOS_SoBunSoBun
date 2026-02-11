//
//  ChatListCellTableViewCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/10/26.
//

import UIKit
import SnapKit

class ChatListCellTableViewCell: UITableViewCell {
    static let identifier = "ChatListTableViewCell"
    
    private let view = ChatListCellView()
    
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
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10).priority(.high)
        }
    }
    
    func configureUI(imageUrl: String?, title: String, lastSentAt: String?, lastMessage: String?, unreadCount: Int?) {
        view.configureUI(imageUrl: imageUrl, title: title, lastSentAt: lastSentAt, lastMessage: lastMessage, unreadCount: unreadCount)
        view.layoutIfNeeded()
    }
}
