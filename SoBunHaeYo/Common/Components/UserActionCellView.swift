//
//  UserActionCellView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit
import OSLog

class UserActionCellView: UIStackView {
    let userId: Int
    
    init(frame: CGRect = .zero, userId: Int, nickname: String?, profileImageUrl: String?, actionTitle: String) {
        self.userId = userId
        
        super.init(frame: frame)
        
        configureUI(nickname: nickname, profileImageUrl: profileImageUrl, actionTitle: actionTitle)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "UserActionCellView"
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
    
    let actionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .primary50
        config.background.cornerRadius = 17
        config.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // MARK: - 레이아웃 설정
    private func configureUI(nickname: String?, profileImageUrl: String?, actionTitle: String) {
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
        
        [profileImageView, nicknameLabel, actionButton].forEach {
            self.addArrangedSubview($0)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(PROFILE_IMAGE_SIZE)
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
            profileImageView.image = .defaultProfile
        }
        
        profileImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        var nicknameAttributes: [NSAttributedString.Key: Any] = body16.attributes()
        nicknameAttributes[.foregroundColor] = UIColor.neutral900
        
        nicknameLabel.attributedText = NSAttributedString(
            string: nickname ?? String(localized: "Unknown", table: "Common"),
            attributes: nicknameAttributes
        )
        
        nicknameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        var buttonAttributes = body12.attributes(alignment: .center)
        buttonAttributes[.foregroundColor] = UIColor.primary300
        
        actionButton.configuration?.attributedTitle = AttributedString(
            NSAttributedString(string: actionTitle, attributes: buttonAttributes)
        )
        
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
