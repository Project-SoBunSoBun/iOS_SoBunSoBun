//
//  UserSettlementTableViewCell.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 3/12/26.
//

import UIKit
import SnapKit

class UserSettlementTableViewCell: UITableViewCell {
    static let identifier = "UserSettlementTableViewCell"
    
    private let view = UserSettlementCellView()
    
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(8).priority(.high)
        }
    }
    
    func configureUI(model: SettleUp3rdStepParticipantModel, authorId: Int) {
        view.configureUI(model: model, authorId: authorId)
    }
    
    func configureUI(model: SettlementParticipantModel, currentUserId: Int) {
        view.configureUI(model: model, currentUserId: currentUserId)
    }
}
