//
//  ChatRoomListCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/10/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher
import OSLog

class ChatRoomListCellView: UIView {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Chat.ChatListCellView"
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.primary50.cgColor
        
        return iv
    }()
    
    private let topStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        sv.distribution = .fill
        
        return sv
    }()
    
    private let titleAttributes: [NSAttributedString.Key: Any] = {
        var attributes: [NSAttributedString.Key: Any] = title14.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        return attributes
    }()
    
    private let nameLabel: UILabel = UILabel()
    
    private let bottomStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .center
        sv.distribution = .fill
        
        return sv
    }()
    
    private let lastSentAtAttributes: [NSAttributedString.Key: Any] = {
        var attributes: [NSAttributedString.Key: Any] = body12.attributes()
        attributes[.foregroundColor] = UIColor.neutral500
        
        return attributes
    }()
    
    private let lastSentAtLabel: UILabel = UILabel()
    
    private let lastMeesageAttributes: [NSAttributedString.Key: Any] = {
        var attributes: [NSAttributedString.Key: Any] = body14.attributes()
        attributes[.foregroundColor] = UIColor.neutral500
        
        return attributes
    }()
    
    private let lastMessageLabel: UILabel = UILabel()
    
    private let unreadCountLabel: UnreadCountLabel = UnreadCountLabel()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        [imageView, topStackView, bottomStackView].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(50)
        }
        
        [nameLabel, lastSentAtLabel].forEach {
            topStackView.addArrangedSubview($0)
        }
        
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lastSentAtLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        topStackView.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(2)
        }
        
        [lastMessageLabel, unreadCountLabel].forEach {
            bottomStackView.addArrangedSubview($0)
        }
        
        lastMessageLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        unreadCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        bottomStackView.snp.makeConstraints { make in
            make.leading.equalTo(topStackView)
            make.trailing.equalToSuperview()
            make.top.equalTo(topStackView.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
    }
    
    func configureUI(model: ChatRoomListResponseDataModel) {
        if let profileImageUrl = model.profileImageUrl {
            let imageUrl = URL(string: API_URL + profileImageUrl)
            
            imageView.kf.setImage(
                with: imageUrl,
                placeholder: UIImage.defaultProfile) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let value):
                        let urlString = value.source.url?.absoluteString ?? "알 수 없음"
                        self.logger.debug("프로필 이미지 비동기 로드 성공: \(urlString)")
                        
                    case .failure(let error):
                        self.logger.error("\(error.localizedDescription)")
                        imageView.image = .defaultProfile
                    }
            }
        } else {
            // profileImageUrl이 nil 인 경우 기본 이미지 설정
            imageView.image = .defaultProfile
        }
        
        nameLabel.attributedText = NSAttributedString(string: model.roomName, attributes: titleAttributes)
        
        var lastMessageString: String = ""
        
        if let lastMessage = model.lastMessage {
            let nickname = lastMessage.nickname ?? String(localized: "Unknown", table: "Common")
            let content = lastMessage.content ?? ""
            
            switch lastMessage.type {
            case .TEXT:
                lastMessageString = "\(nickname): \(content)"
                
            case .IMAGE:
                lastMessageString = String(format: String(localized: "UserMessageImageSent", table: "Chat"), nickname)
                
            case .INVITE_CARD:
                lastMessageString = String(format: String(localized: "UserMessageInviteCard", table: "Chat"), nickname)
                
            case .SETTLEMENT_CARD:
                lastMessageString = String(format: String(localized: "UserMessageSettlementCard", table: "Chat"), nickname)
                
            case .SYSTEM:
                lastMessageString = content
                
            case .ENTER:
                lastMessageString = String(format: String(localized: "UserMessageJoined", table: "Chat"), nickname)
                
            case .LEAVE:
                lastMessageString = String(format: String(localized: "UserMessageLeft", table: "Chat"), nickname)
            }
        }
        
        var lastSentAtString: String = ""
        
        if let lastSentAt = model.lastMessage?.createdAt {
            lastSentAtString = ISO8601ToRelativeString(lastSentAt)
        }
        
        lastSentAtLabel.attributedText = NSAttributedString(string: lastSentAtString, attributes: lastSentAtAttributes)
        
        lastMessageLabel.attributedText = NSAttributedString(string: lastMessageString, attributes: lastMeesageAttributes)
        
        unreadCountLabel.text = "\(model.unreadCount)"
        unreadCountLabel.isHidden = model.unreadCount <= 0
    }
}
