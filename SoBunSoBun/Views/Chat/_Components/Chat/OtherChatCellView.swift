//
//  OtherChatCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/15/26.
//

import UIKit
import SnapKit
import OSLog

class OtherChatCellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Chat.Chat.OtherChatCellView"
    )
    
    static let PROFILE_IMAGE_SIZE: CGFloat = 32
    private let UNKNOWN_STRING = String(localized: "Unknown", table: "Common")
    
    // MARK: - 디자인 요소
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = PROFILE_IMAGE_SIZE / 2
        
        return iv
    }()
    
    private let nicknameAttributes: [NSAttributedString.Key: Any] = {
        var attributes = body14.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        return attributes
    }()
    
    private let nicknameLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let chatBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
        
        return view
    }()
    
    private let chatAttributes: [NSAttributedString.Key: Any] = {
        var attributes = body14.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
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
        [profileImageView, nicknameLabel, chatBubbleView, timeLabel].forEach {
            addSubview($0)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.size.equalTo(OtherChatCellView.PROFILE_IMAGE_SIZE)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        chatBubbleView.snp.makeConstraints { make in
            make.leading.equalTo(nicknameLabel)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
        }
        
        chatBubbleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        chatBubbleView.addSubview(chatLabel)
        
        chatLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(chatBubbleView.snp.trailing).offset(4)
            make.bottom.equalTo(chatBubbleView)
        }
        
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    // 임시
    func configureUI(profileImageUrl: String?, nickname: String?, message: String, date: String, isFirstChatOfDay: Bool) {
        if isFirstChatOfDay {
            let dateView = ChatDateCellView(date: date)
            insertSubview(dateView, at: 0)
            
            dateView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            profileImageView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.top.equalTo(dateView.snp.bottom).offset(16)
                make.size.equalTo(OtherChatCellView.PROFILE_IMAGE_SIZE)
            }
            
            nicknameLabel.snp.remakeConstraints { make in
                make.leading.equalTo(profileImageView.snp.trailing).offset(8)
                make.trailing.equalToSuperview()
                make.top.equalTo(dateView.snp.bottom).offset(16)
            }
        }
        
        if let profileImageUrl {
            let imageUrl = URL(string: API_URL + profileImageUrl)
            
            profileImageView.kf.setImage(
                with: imageUrl,
                placeholder: UIImage.defaultProfile) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let value):
                        let urlString = value.source.url?.absoluteString ?? "알 수 없음"
                        self.logger.debug("프로필 이미지 비동기 로드 성공: \(urlString)")
                        
                    case .failure(let error):
                        self.logger.fault("\(error.localizedDescription)")
                        profileImageView.image = .defaultProfile
                    }
                }
        } else {
            // profileImageUrl이 nil 인 경우 기본 이미지 설정
            profileImageView.image = .defaultProfile
        }
        
        nicknameLabel.attributedText = NSAttributedString(string: nickname ?? UNKNOWN_STRING, attributes: nicknameAttributes)
        
        chatLabel.attributedText = NSAttributedString(string: message, attributes: chatAttributes)
        
        let timeString: String
        
        if let date = ISO8601ToDate(date),
           let convertedTimeString = dateToString(date: date, format: "hh:mm") {
            timeString = convertedTimeString
        } else {
            timeString = String(localized: "Unknown", table: "Common")
        }
        
        timeLabel.attributedText = NSAttributedString(string: timeString, attributes: timeAttributes)
    }
}
