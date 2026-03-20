//
//  NotificationCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/20/26.
//

import UIKit
import SnapKit

class NotificationCellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let messageLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 3
        
        return lb
    }()
    
    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        
        return lb
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral100
        
        return view
    }()
    
    private func configureUI() {
        [messageLabel, dateLabel, divider].forEach {
            addSubview($0)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(messageLabel.snp.bottom).offset(8)
        }
        
        divider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom).offset(15)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    func configureUI(message: String, createdAt: String, isRead: Bool) {
        self.backgroundColor = isRead ? .clear : .primary50
        
        var messageAttributes: [NSAttributedString.Key: Any] = body16.attributes()
        messageAttributes[.foregroundColor] = UIColor.neutral900
        
        messageLabel.attributedText = NSAttributedString(string: message, attributes: messageAttributes)
        
        var dateAttributes: [NSAttributedString.Key: Any] = body14.attributes()
        dateAttributes[.foregroundColor] = UIColor.neutral400
        
        guard let date = ISO8601ToDate(createdAt) else {
            dateLabel.attributedText = NSAttributedString(string: String(localized: "Unknown", table: "Common"), attributes: dateAttributes)
            
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let dateString = formatter.string(from: date)
        
        dateLabel.attributedText = NSAttributedString(string: dateString, attributes: dateAttributes)
    }
}
