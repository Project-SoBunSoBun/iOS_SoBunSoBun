//
//  ChatMemberKickCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit
import OSLog

class ChatMemberKickCellView: UIStackView {
    let userId: Int
    
    init(frame: CGRect = .zero, model: ChatRoomDetailMemberModel) {
        self.userId = model.userId
        
        super.init(frame: frame)
        
        configureUI(model: model)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ChatMemberCancelCellView"
    )
    
    private let PROFILE_IMAGE_SIZE: CGFloat = 50
    
    // MARK: - 디자인 요소
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = PROFILE_IMAGE_SIZE / 2
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.primary50.cgColor
        
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    let cancelButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .primary50
        config.background.cornerRadius = 17
        config.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        var attributes = body12.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary300
        
        config.attributedTitle = AttributedString(NSAttributedString(string: String(localized: "Cancel", table: "Chat"), attributes: attributes))
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // MARK: - 레이아웃 설정
    private func configureUI(model: ChatRoomDetailMemberModel) {
        self.backgroundColor = .backgroundWhite
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 그림자
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary300.withAlphaComponent(0.16).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 24
        self.clipsToBounds = false
        
        self.axis = .horizontal
        self.spacing = 8
        self.alignment = .center
        self.distribution = .fill
        self.isLayoutMarginsRelativeArrangement = true
        self.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        [profileImageView, nicknameLabel, cancelButton].forEach {
            self.addArrangedSubview($0)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(PROFILE_IMAGE_SIZE)
        }
        
        if let profileImageUrl = model.profileImage {
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
        
        profileImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        var attributes: [NSAttributedString.Key: Any] = body16.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        nicknameLabel.attributedText = NSAttributedString(string: model.nickname ?? String(localized: "Unknown", table: "Common") , attributes: attributes)
        
        nicknameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
