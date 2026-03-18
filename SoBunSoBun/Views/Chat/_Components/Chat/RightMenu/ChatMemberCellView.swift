//
//  ChatMemberCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit
import RxSwift
import RxGesture
import OSLog

class ChatMemberCellView: UIStackView {
    init(frame: CGRect = .zero, isMe: String, model: ChatRoomDetailMemberModel) {
        super.init(frame: frame)
        
        configureUI(isMe: isMe, model: model)
        bind(model: model)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ChatMemberCellView"
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
    
    // MARK: - 레이아웃 설정
    private func configureUI(isMe: String, model: ChatRoomDetailMemberModel) {
        self.backgroundColor = .backgroundWhite
        
        // 모서리
        self.layer.cornerRadius = 16
        
        self.axis = .horizontal
        self.spacing = 8
        self.alignment = .center
        
        [profileImageView, nicknameLabel].forEach {
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
        
        var attributes: [NSAttributedString.Key: Any] = body16.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        nicknameLabel.attributedText = NSAttributedString(string: model.nickname ?? String(localized: "Unknown", table: "Common"), attributes: attributes)
    }
}

extension ChatMemberCellView {
    private func bind(model: ChatRoomDetailMemberModel) {
        self.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                DeepLinkManager.shared.handle(url: URL(string: "sobunsobun://profile_managable/\(model.userId)")!)
            })
            .disposed(by: disposeBag)
    }
}
