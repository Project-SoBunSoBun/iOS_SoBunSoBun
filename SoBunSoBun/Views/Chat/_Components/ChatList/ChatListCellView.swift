//
//  ChatListCellView.swift
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

class ChatListCellView: UIView {
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
    
    private let titleLabel: UILabel = UILabel()
    
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
    
    private let unreadCouneLabel: UnreadCountLabel = UnreadCountLabel()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        [imageView, topStackView, bottomStackView].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(50)
        }
        
        [titleLabel, lastSentAtLabel].forEach {
            topStackView.addArrangedSubview($0)
        }
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lastSentAtLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        topStackView.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(2)
        }
        
        [lastMessageLabel, unreadCouneLabel].forEach {
            bottomStackView.addArrangedSubview($0)
        }
        
        lastMessageLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        unreadCouneLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        bottomStackView.snp.makeConstraints { make in
            make.leading.equalTo(topStackView)
            make.trailing.equalToSuperview()
            make.top.equalTo(topStackView.snp.bottom).offset(4)
        }
    }
    
    // 임시
    func configureUI(imageUrl: String?, title: String, lastSentAt: String?, lastMessage: String?, unreadCount: Int?) {
        if let imageUrl = imageUrl {
            let imageUrl = URL(string: API_URL + imageUrl)
            
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
        
        titleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
        
        let lastSentAtString: String
        
        if let lastSentAt {
            lastSentAtString = ISO8601ToRelativeString(lastSentAt)
        } else {
            lastSentAtString = ""
        }
        
        lastSentAtLabel.attributedText = NSAttributedString(string: lastSentAtString, attributes: lastSentAtAttributes)
        
        lastMessageLabel.attributedText = NSAttributedString(string: lastMessage ?? "", attributes: lastMeesageAttributes)
        
        unreadCouneLabel.text = "\(unreadCount ?? 0)"
    }
}
