//
//  SystemChatCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/26/26.
//

import UIKit
import SnapKit

class SystemChatCellView: UIView {
    init(frame: CGRect = .zero, model: ChatMessageModel) {
        super.init(frame: frame)
        
        configureUI(model: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary400.withAlphaComponent(0.2)
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        
        return view
    }()
    
    private let announcementAttributes: [NSAttributedString.Key: Any] = {
        var attributes = body12.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral700
        
        return attributes
    }()
    
    private let announcementLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    private func configureUI(model: ChatMessageModel) {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(8)
        }
        
        containerView.addSubview(announcementLabel)
        
        let announcementString: String
        let nickname: String = model.nickname ?? String(localized: "Unknown", table: "Common")
        
        switch model.type {
        case .SYSTEM:
            announcementString = model.content ?? ""
            
        case .ENTER:
            announcementString = String(
                format: NSLocalizedString(
                    "UserMessageJoined",
                    tableName: "Chat",
                    comment: ""
                ),
                nickname
            )
            
        case .LEAVE:
            announcementString = String(
                format: NSLocalizedString(
                    "UserMessageLeft",
                    tableName: "Chat",
                    comment: ""
                ),
                nickname
            )
            
        default:
            announcementString = ""
        }
        
        announcementLabel.attributedText = NSAttributedString(string: announcementString, attributes: announcementAttributes)
        
        announcementLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }
}
