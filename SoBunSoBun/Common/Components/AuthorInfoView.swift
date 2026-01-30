//
//  AuthorInfoView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/26/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import OSLog

class AuthorInfoView: UIStackView {
    var id: Int? {
        didSet {
            bind()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Author"
    )
    
    private let disposeBag = DisposeBag()
    
    static let PROFILE_IMAGE_SIZE: CGFloat = 48
    
    private let UNKNOWN_STRING = String(localized: "Unknown", table: "Common")
    
    // MARK: - 디자인 요소
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = PROFILE_IMAGE_SIZE / 2
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.primary50.cgColor
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(PROFILE_IMAGE_SIZE)
        }
        
        return iv
    }()
    
    private let verticalStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .leading
        
        return sv
    }()
    
    private let nicknameLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        
        return lb
    }()
    
    private let bottomInfoLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        
        return lb
    }()
    
    // MARK: - UI 설정
    private func configureUI() {
        self.axis = .horizontal
        self.spacing = 8
        self.alignment = .center
        
        addArrangedSubview(profileImageView)
        addArrangedSubview(verticalStackView)
        
        [nicknameLabel, bottomInfoLabel].forEach {
            verticalStackView.addArrangedSubview($0)
        }
        
        profileImageView.setContentHuggingPriority(.required, for: .horizontal)
        nicknameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        bottomInfoLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    func configureUI(
        profileImageUrl: String?,
        nickname: String?,
        createdAt: String?,
        verifyLocation: String?
    ) {
        setProfileImage(profileImageUrl)
        setNickname(nickname)
        setBottomInfo(createdAt, verifyLocation: verifyLocation)
    }
    
    private func setProfileImage(_ profileImageUrl: String?) {
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
                        self.logger.error("\(error.localizedDescription)")
                        profileImageView.image = .defaultProfile
                    }
                }
        } else {
            // profileImageUrl이 nil 인 경우 기본 이미지 설정
            profileImageView.image = .defaultProfile
        }
    }
    
    private func setNickname(_ nickname: String?) {
        var nicknameAttributes: [NSAttributedString.Key: Any] = title16.attributes()
        nicknameAttributes[.foregroundColor] = UIColor.neutral900
        
        nicknameLabel.attributedText = NSAttributedString(string: nickname ?? UNKNOWN_STRING, attributes: nicknameAttributes)
    }
    
    private func setBottomInfo(_ createdAt: String?, verifyLocation: String?) {
        var bottomInfoAttributes: [NSAttributedString.Key: Any] = body14.attributes()
        bottomInfoAttributes[.foregroundColor] = UIColor.neutral500
        
        let createdAtString: String
        
        if let createdAt {
            createdAtString = ISO8601ToRelativeString(createdAt)
        } else {
            createdAtString = UNKNOWN_STRING
        }
        
        let verifyLocationString: String = "\(verifyLocation ?? UNKNOWN_STRING) \(String(localized: "Verified", table: "Home"))"
        
        bottomInfoLabel.attributedText = NSAttributedString(string: "\(createdAtString) | \(verifyLocationString) ", attributes: bottomInfoAttributes)
    }
}

extension AuthorInfoView {
    private func bind() {
        Observable.combineLatest([
            profileImageView
                .rx
                .tapGesture()
                .when(.recognized),
            nicknameLabel
                .rx
                .tapGesture()
                .when(.recognized)
        ])
        .subscribe(onNext: { _ in
            // TODO: 프로필 이동 구현
        })
        .disposed(by: disposeBag)
    }
}
