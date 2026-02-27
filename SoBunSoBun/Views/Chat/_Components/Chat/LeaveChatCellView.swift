//
//  LeaveChatCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/26/26.
//

import UIKit
import SnapKit

class LeaveChatCellView: UIView {
    init(frame: CGRect = .zero, nickname: String?) {
        super.init(frame: frame)
        
        configureUI(nickname: nickname)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let leaveContainerView: UIView = {
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
    
    private func configureUI(nickname: String?) {
        addSubview(leaveContainerView)
        
        leaveContainerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(8)
        }
        
        leaveContainerView.addSubview(announcementLabel)
        
        let announcementString: String = String(format: NSLocalizedString("LeftUserMessage", tableName: "Chat", comment: ""),
                                                nickname ?? String(localized: "Unknown", table: "Common"))
        
        announcementLabel.attributedText = NSAttributedString(string: announcementString, attributes: announcementAttributes)
        
        announcementLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }
}
