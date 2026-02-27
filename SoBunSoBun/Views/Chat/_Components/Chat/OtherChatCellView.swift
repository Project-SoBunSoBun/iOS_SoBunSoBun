//
//  OtherChatCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/15/26.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa
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
    
    let didImageLoad = PublishRelay<Void>()
    let didInviteCardButtonTapped = PublishRelay<Int>()
    let didSettlementCardButtonTapped = PublishRelay<Int>()
    
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
    
    let chatBubbleView: UIView = {
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
    
    private let chatImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private var imageWidthConstraint: Constraint?
    private var imageHeightConstraint: Constraint?
    
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
            make.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 0.56)
        }
        
        chatBubbleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(chatBubbleView.snp.trailing).offset(4)
            make.bottom.equalTo(chatBubbleView)
        }
        
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func configureUI(model: ChatMessageModel) {
        if let profileImageUrl = model.profileImage {
            let imageUrl = URL(string: API_URL + profileImageUrl)
            
            profileImageView.kf.setImage(
                with: imageUrl,
                placeholder: UIImage.defaultProfile) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(_):
                        break
                        
                    case .failure(let error):
                        self.logger.fault("\(error.localizedDescription)")
                        profileImageView.image = .defaultProfile
                    }
                }
        } else {
            // profileImageUrl이 nil 인 경우 기본 이미지 설정
            profileImageView.image = .defaultProfile
        }
        
        nicknameLabel.attributedText = NSAttributedString(string: model.nickname ?? UNKNOWN_STRING, attributes: nicknameAttributes)
        
        switch model.type {
        case .TEXT:
            configureText(model: model)
        case .IMAGE:
            configureImage(model: model)
        case .INVITE_CARD:
            configureInvite(model: model)
        case .SETTLEMENT_CARD:
            configureSettleUp(model: model)
        default:
            break
        }
        
        let timeString: String
        
        if let date = ISO8601ToDate(model.createdAt),
           let convertedTimeString = dateToString(date: date, format: "hh:mm") {
            timeString = convertedTimeString
        } else {
            timeString = String(localized: "Unknown", table: "Common")
        }
        
        timeLabel.attributedText = NSAttributedString(string: timeString, attributes: timeAttributes)
    }
    
    private func configureText(model: ChatMessageModel) {
        initializeChatBubbleView()
        
        chatBubbleView.addSubview(chatLabel)
        
        chatLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        chatLabel.attributedText = NSAttributedString(string: model.content ?? "", attributes: chatAttributes)
    }
    
    private func configureImage(model: ChatMessageModel) {
        initializeChatBubbleView()
        
        chatBubbleView.addSubview(chatImageView)
        
        chatImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.size.equalTo(UIScreen.main.bounds.width * 0.5)
        }
        
        if let imageUrl = model.imageUrl {
            chatImageView.kf.cancelDownloadTask()
            
            chatImageView.kf.setImage(
                with: URL(string: API_URL + imageUrl),
                placeholder: UIImage.defaultProfile) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let value):
                        let size = self.calculateImageSize(image: value.image)
                        
                        self.chatImageView.snp.remakeConstraints { make in
                            make.leading.top.equalToSuperview().inset(10)
                            make.size.equalTo(size)
                            make.trailing.bottom.equalToSuperview().inset(10)
                        }
                        
                        didImageLoad.accept(())
                        
                    case .failure(let error):
                        self.logger.fault("\(error.localizedDescription)")
                        chatImageView.image = .defaultProfile
                    }
                }
        } else {
            // profileImageUrl이 nil 인 경우 기본 이미지 설정
            chatImageView.image = .defaultProfile
        }
    }
    
    private func configureInvite(model: ChatMessageModel) {
        
    }
    
    private func configureSettleUp(model: ChatMessageModel) {
        
    }
    
    private func calculateImageSize(image: UIImage) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width * 0.5
        let maxHeight: CGFloat = 300
        
        let ratio = image.size.width / image.size.height
        
        var targetWidth = maxWidth
        var targetHeight = maxWidth / ratio
        
        if targetHeight > maxHeight {
            targetHeight = maxHeight
            targetWidth = maxHeight * ratio
        }
        
        return CGSize(width: targetWidth, height: targetHeight)
    }
    
    private func initializeChatBubbleView() {
        chatBubbleView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
