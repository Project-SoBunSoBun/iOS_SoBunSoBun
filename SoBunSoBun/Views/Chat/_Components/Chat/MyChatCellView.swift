//
//  MyChatCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/15/26.
//

import UIKit
import SnapKit

class MyChatCellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let UNKNOWN_STRING = String(localized: "Unknown", table: "Common")
    
    // MARK: - 디자인 요소
    private let chatBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary400
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
        
        return view
    }()
    
    private let chatAttributes: [NSAttributedString.Key: Any] = {
        var attributes = body14.attributes()
        attributes[.foregroundColor] = UIColor.backgroundWhite
        
        return attributes
    }()
    
    private let chatLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let timeAttributes: [NSAttributedString.Key: Any] = {
        var attributes = body14.attributes()
        attributes[.foregroundColor] = UIColor.neutral500
        
        return attributes
    }()
    
    private let timeLabel: UILabel = {
        let lb = UILabel()
        
        return lb
    }()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        [chatBubbleView, timeLabel].forEach {
            addSubview($0)
        }
        
        chatBubbleView.snp.makeConstraints { make in
            make.trailing.verticalEdges.equalToSuperview()
        }
        
        chatBubbleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        chatBubbleView.addSubview(chatLabel)
        
        chatLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chatBubbleView.snp.leading).inset(4)
            make.bottom.equalTo(chatBubbleView)
        }
        
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    // 임시
    func configureUI(message: String, date: String, isFirstChatOfDay: Bool) {
        if isFirstChatOfDay {
            let dateView = ChatDateCellView(date: date)
            insertSubview(dateView, at: 0)
            
            dateView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            chatBubbleView.snp.remakeConstraints { make in
                make.top.equalTo(dateView.snp.bottom).offset(16)
                make.trailing.bottom.equalToSuperview()
            }
        }
        
        chatLabel.attributedText = NSAttributedString(string: message, attributes: chatAttributes)
        
        let timeString: String
        
        if let date = ISO8601ToDate(date),
           let convertedTimeString = dateToString(date: date, format: "hh:mm") {
            timeString = convertedTimeString
        } else {
            timeString = UNKNOWN_STRING
        }
        
        timeLabel.attributedText = NSAttributedString(string: timeString, attributes: timeAttributes)
    }
}
