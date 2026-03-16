//
//  ChatRoomListCellTableViewCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/10/26.
//

import UIKit
import SnapKit

class ChatRoomListCellTableViewCell: UITableViewCell {
    static let identifier = "ChatRoomListCellTableViewCell"
    
    private let view = ChatRoomListCellView()
    
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
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10).priority(.high)
        }
    }
    
    func configureUI(model: ChatRoomListResponseDataModel) {
        view.configureUI(model: model)
        view.layoutIfNeeded()
    }
}
