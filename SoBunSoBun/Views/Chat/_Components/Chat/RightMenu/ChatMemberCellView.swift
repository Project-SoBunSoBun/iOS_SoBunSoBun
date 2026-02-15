//
//  ChatMemberCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit
import OSLog

class ChatMemberCellView: UIStackView {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ChatMemberCellView"
    )
    
    init(frame: CGRect = .zero, profileImageUrl: String?, nickname: String) {
        super.init(frame: frame)
        
        configureUI(profileImageUrl: profileImageUrl, nickname: nickname)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50 / 2
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.primary50.cgColor
        
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private func configureUI(profileImageUrl: String?, nickname: String) {
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
        self.isLayoutMarginsRelativeArrangement = true
        self.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        [profileImageView, nicknameLabel].forEach {
            self.addArrangedSubview($0)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(50)
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
        
        var attributes: [NSAttributedString.Key: Any] = body16.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        nicknameLabel.attributedText = NSAttributedString(string: nickname, attributes: attributes)
    }
}
