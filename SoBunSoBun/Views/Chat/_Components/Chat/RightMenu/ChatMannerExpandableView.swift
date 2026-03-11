//
//  ChatMannerExpandableView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import OSLog

class ChatMannerExpandableView: UIView {
    init(frame: CGRect = .zero, model: ChatRoomDetailMemberModel) {
        super.init(frame: frame)
        
        configureUI(model: model)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Chat.Component.MemberCancelCellView"
    )
    
    private let disposeBag = DisposeBag()
    
    private let PROFILE_IMAGE_SIZE: CGFloat = 50
    
    private var isExpanded = false
    private var contentHeightConstraint: Constraint?
    
    // MARK: - 디자인 요소
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        return sv
    }()
    
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
    
    private let arrowButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .blackDown.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        btn.isUserInteractionEnabled = false
        
        return btn
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        
        return view
    }()
    
    let reviewsView: HorizontalWrappingView = HorizontalWrappingView(horizontalSpacing: 8, verticalSpacing: 8)
    
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
        
        [stackView, contentView].forEach {
            addSubview($0)
        }
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
        }
        
        [profileImageView, nicknameLabel, arrowButton].forEach {
            stackView.addArrangedSubview($0)
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
        
        profileImageView.setContentHuggingPriority(.required, for: .horizontal)
        profileImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        nicknameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        arrowButton.setContentHuggingPriority(.required, for: .horizontal)
        arrowButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(stackView.snp.bottom)
            make.bottom.equalToSuperview()
            contentHeightConstraint = make.height.equalTo(0).constraint
        }
        
        contentView.addSubview(reviewsView)
        
        reviewsView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
        }
    }
}

extension ChatMannerExpandableView {
    private func bind() {
        stackView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                toggleExpand()
            })
            .disposed(by: disposeBag)
    }
    
    private func toggleExpand() {
        isExpanded.toggle()
        
        arrowButton.configuration?.image = isExpanded ?
            .blackUp.resize(.init(width: 24, height: 24)) :
            .blackDown.resize(.init(width: 24, height: 24))
        
        contentHeightConstraint?.update(offset: isExpanded ? reviewsView.intrinsicContentSize.height + 16 : 0)
        
        // 높이 애니메이션은 상위 뷰의 layoutIfNeeded에 따라 달라짐
        // 확실하게 하려면 window.layoutIfNeeded를 사용한다.
        // 또는 self.superview?.superview?.layoutIfNeeded()를 써도 해결이 된다.
        UIView.animate(withDuration: 0.3) {
            self.superview?.superview?.layoutIfNeeded()
        }
    }
}
