//
//  OtherUserChatCellView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/15/26.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa
import RxGesture
import OSLog

class OtherUserChatCellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Chat.Chat.OtherChatCellView"
    )
    
    let didImageLoad = PublishRelay<Void>()
    let didInviteCardButtonTapped = PublishRelay<Int>()
    let didSettlementCardButtonTapped = PublishRelay<Int>()
    
    static let PROFILE_IMAGE_SIZE: CGFloat = 32
    private let UNKNOWN_STRING = String(localized: "Unknown", table: "Common")
    private let BUBBLE_VIEW_MAX_WIDTH = UIScreen.main.bounds.width * 0.56
    private let IMAGE_VIEW_MAX_WIDTH = UIScreen.main.bounds.width * 0.5 - (10 * 2)
    
    // MARK: - 디자인 요소
    let profileImageView: UIImageView = {
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
    
    let chatLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    let chatImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    private func chatButton(title: String) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = .primary400
        config.background.cornerRadius = 16
        config.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        var attributes: [NSAttributedString.Key: Any] = title16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.backgroundWhite
        
        config.attributedTitle = AttributedString(NSAttributedString(string: title, attributes: attributes))
        
        let btn = UIButton(configuration: config)
        
        return btn
    }
    
    private let invitationCardView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .center
        
        let iv = UIImageView()
        iv.image = .mail.resize(.init(width: 80, height: 64))
        iv.contentMode = .scaleAspectFit
        
        iv.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(64)
        }
        
        sv.addArrangedSubview(iv)
        
        let title = UILabel()
        title.numberOfLines = 0
        
        var titleAttributes: [NSAttributedString.Key: Any] = title20.attributes(alignment: .center)
        titleAttributes[.foregroundColor] = UIColor.primary400
        title.attributedText = NSAttributedString(string: String(localized: "InvitationCardReceivedTitle", table: "Chat"), attributes: titleAttributes)
        
        sv.addArrangedSubview(title)
        
        let subTitle = UILabel()
        subTitle.numberOfLines = 0
        
        var subTitleAttributes: [NSAttributedString.Key: Any] = body14.attributes(alignment: .center)
        subTitleAttributes[.foregroundColor] = UIColor.neutral600
        subTitle.attributedText = NSAttributedString(string: String(localized: "InvitationCardReceivedSubTitle", table: "Chat"), attributes: subTitleAttributes)
        
        sv.addArrangedSubview(subTitle)
        
        return sv
    }()
    
    private lazy var invitationAcceptButton = chatButton(title: String(localized: "Accept", table: "Chat"))
    
    private let settlementCardView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .center
        
        let iv = UIImageView()
        iv.image = .receipt.resize(.init(width: 72, height: 74))
        iv.contentMode = .scaleAspectFit
        
        iv.snp.makeConstraints { make in
            make.width.equalTo(72)
            make.height.equalTo(74)
        }
        
        sv.addArrangedSubview(iv)
        
        let title = UILabel()
        title.numberOfLines = 0
        
        var titleAttributes: [NSAttributedString.Key: Any] = title20.attributes(alignment: .center)
        titleAttributes[.foregroundColor] = UIColor.primary400
        title.attributedText = NSAttributedString(string: String(localized: "SettlementReceivedTitle", table: "Chat"), attributes: titleAttributes)
        
        sv.addArrangedSubview(title)
        
        let subTitle = UILabel()
        subTitle.numberOfLines = 0
        
        var subTitleAttributes: [NSAttributedString.Key: Any] = body14.attributes(alignment: .center)
        subTitleAttributes[.foregroundColor] = UIColor.neutral600
        subTitle.attributedText = NSAttributedString(string: String(localized: "SettlementReceivedSubTitle", table: "Chat"), attributes: subTitleAttributes)
        
        sv.addArrangedSubview(subTitle)
        
        return sv
    }()
    
    private lazy var settlementConfirmButton = chatButton(title: String(localized: "Confirm", table: "Chat"))
    
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
            make.size.equalTo(OtherUserChatCellView.PROFILE_IMAGE_SIZE)
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
            make.width.lessThanOrEqualTo(BUBBLE_VIEW_MAX_WIDTH)
        }
        
        chatBubbleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        invitationCardView.addArrangedSubview(invitationAcceptButton)
        
        invitationAcceptButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        
        settlementCardView.addArrangedSubview(settlementConfirmButton)
        
        settlementConfirmButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        
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
            configureInvitation(model: model)
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
            make.size.equalTo(IMAGE_VIEW_MAX_WIDTH)
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
    
    private func configureInvitation(model: ChatMessageModel) {
        chatBubbleView.backgroundColor = .backgroundWhite
        chatBubbleView.layer.borderWidth = 2
        chatBubbleView.layer.borderColor = UIColor.primary100.cgColor
        chatBubbleView.frame = CGRectInset(chatBubbleView.frame, -chatBubbleView.layer.borderWidth, -chatBubbleView.layer.borderWidth)
        
        chatBubbleView.addSubview(invitationCardView)
        
        invitationCardView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(20)
            make.width.equalTo(BUBBLE_VIEW_MAX_WIDTH - (16 * 2))
        }
    }
    
    private func configureSettleUp(model: ChatMessageModel) {
        chatBubbleView.backgroundColor = .backgroundWhite
        chatBubbleView.layer.borderWidth = 2
        chatBubbleView.layer.borderColor = UIColor.primary100.cgColor
        chatBubbleView.frame = CGRectInset(chatBubbleView.frame, -chatBubbleView.layer.borderWidth, -chatBubbleView.layer.borderWidth)
        
        chatBubbleView.addSubview(settlementCardView)
        
        settlementCardView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(20)
            make.width.equalTo(BUBBLE_VIEW_MAX_WIDTH - (16 * 2))
        }
    }
    
    private func calculateImageSize(image: UIImage) -> CGSize {
        let maxHeight: CGFloat = 300
        
        let ratio = image.size.width / image.size.height
        
        var targetWidth = IMAGE_VIEW_MAX_WIDTH
        var targetHeight = IMAGE_VIEW_MAX_WIDTH / ratio
        
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

extension OtherUserChatCellView {
    func bind(model: ChatMessageModel) {
        profileImageView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                if let userId = model.userId, let url = URL(string: "sobunhaeyo://profile/\(userId)") {
                    UIApplication.shared.open(url)
                }
            })
            .disposed(by: disposeBag)
        
        invitationAcceptButton.rx.tap
            .compactMap { model.inviteId }
            .bind(to: didInviteCardButtonTapped)
            .disposed(by: disposeBag)
        
        settlementConfirmButton.rx.tap
            .compactMap { model.settlementId }
            .bind(to: didSettlementCardButtonTapped)
            .disposed(by: disposeBag)
    }
}
