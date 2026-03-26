//
//  ProfileView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/14/26.
//

import UIKit
import SnapKit
import RxSwift
import OSLog

class ProfileManagableView: UIViewController {
    private let userId: Int
    private let groupPostId: Int
    
    init(userId: Int, groupPostId: Int, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.userId = userId
        self.groupPostId = groupPostId
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "ProfileManagable.View"
    )
    
    typealias Reactor = ProfileManagableReactor
    private lazy var reactor = ProfileManagableReactor(userId: userId)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.title = String(localized: "Profile", table: "Common")
        
        return tnb
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let contentView: UIView = UIView()
    
    // 프로필 이미지 뷰
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.primary50.cgColor
        
        return iv
    }()
    
    // 닉네임 라벨
    private let nicknameLabel = UILabel()
    
    // 매너 점수, 참여 횟수, 방장 횟수 뷰
    private let userInfoView = UserInfo()
    
    private func makeLabel(string: String) -> UILabel {
        var attributes = title16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: string,
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }
    
    // 받은 매너 평가 라벨
    private lazy var receivedMannerLabel = makeLabel(string: String(localized: "ReceivedReview", table: "Settings"))
    
    // ReviewBox
    private var mannerWrappingViews = HorizontalWrappingView(
        horizontalSpacing: 8,
        verticalSpacing: 8
    )
    
    // 받은 매너 평가가 없을 때
    private let emptyMannerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        
        return v
    }()
    
    // 받은 매너 평가가 없습니다
    private let emptyMannerLabel: UILabel = {
        var attributes = body18.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary200
        
        let attributedText = NSAttributedString(
            string: String(localized: "EmptyMannerTag", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    private let buttonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isHidden = true
        
        return sv
    }()
    
    // 신고하기
    private let reportButton = Button(title: String(localized: "Report", table: "Common"))
    
    // 차단하기
    private let blockButton = Button(title: String(localized: "Block", table: "Common"))
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reactor.action.onNext(.viewWillAppear)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, buttonsStackView, scrollView, contentView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

extension ProfileManagableView {
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        reportButton.rx.tap
            .map { Reactor.Action.reportButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        blockButton.rx.tap
            .map { Reactor.Action.blockButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        reactor.state.map { $0.userInfo }
            .distinctUntilChanged()
            .compactMap { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                configureContentView(model: model)
                updateUI(model)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.userInfo }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                setBlockButtonTitle(isBlocked: model.isBlocked)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushReportUserView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(ReportView(target: .user(userId: userId, groupPostId: groupPostId)), animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowBlockAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "BlockAlertTitle", table: "Common"),
                    subTitle: String(localized: "BlockAlertSubTitle", table: "Common"),
                    primaryTitleKey: String(localized: "Block", table: "Common"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    reactor.action.onNext(.blockUser)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowBlockDoneAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "Notice", table: "Common"),
                    subTitle: String(localized: "BlockDoneAlertSubTitle", table: "Common"),
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowUnBlockAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "UnBlockAlertTitle", table: "Common"),
                    subTitle: String(localized: "UnBlockAlertSubTitle", table: "Common"),
                    primaryTitleKey: String(localized: "UnBlock", table: "Common"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    reactor.action.onNext(.unBlockUser)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowUnBlockDoneAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "Notice", table: "Common"),
                    subTitle: String(localized: "UnBlockDoneAlertSubTitle", table: "Common"),
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "Error", table: "Common"),
                    subTitle: message,
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureContentView(model: ProfileUserInfoResponseDataModel) {
        guard let myIdString = KeyChain.shared.get(key: "USER_ID"),
              let myId = Int(myIdString) else {
            return
        }
        
        [profileImageView, nicknameLabel, userInfoView, receivedMannerLabel, emptyMannerView].forEach {
            contentView.addSubview($0)
        }
        
        // 프로필 이미지 뷰
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.size.equalTo(100)
        }
        
        // 닉네임 라벨
        nicknameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
        }
        
        // 유저 정보 뷰 컴포넌트
        userInfoView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(24)
        }
        
        // 받은 매너 평가 라벨
        receivedMannerLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(userInfoView.snp.bottom).offset(24)
        }
        
        emptyMannerView.addSubview(emptyMannerLabel)
        
        // 받은 매너 평가가 없을 때 표시하는 뷰
        emptyMannerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(receivedMannerLabel.snp.bottom).offset(16)
            make.height.equalTo(148)
        }
        
        // 받은 매너 평가가 없습니다
        emptyMannerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        if model.userId != myId {
            buttonsStackView.isHidden = false
            
            [reportButton, blockButton].forEach {
                buttonsStackView.addArrangedSubview($0)
                $0.snp.makeConstraints { make in
                    make.horizontalEdges.equalToSuperview()
                }
            }
            
            scrollView.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview()
                make.top.equalTo(topNavigationBar.snp.bottom)
                make.bottom.equalTo(buttonsStackView.snp.top).inset(-8)
            }
        }
    }
    
    private func updateUI(_ model: ProfileUserInfoResponseDataModel) {
        let nickname = model.nickname ?? String(localized: "UnknownNickname", table: "Settings")
        let profileImageUrl = model.profileImageUrl
        let receivedManner = model.mannerTags
        
        // 프로필 이미지 설정
        setProfileImage(profileImageUrl)
        
        // 닉네임 라벨 Text 설정
        setNickname(nickname)
        
        // 매너 점수, 참여 횟수, 방장 횟수 설정
        userInfoView.updateUI(
            activityScore: model.activityScore,
            participationCount: model.participationCount,
            hostCount: model.hostCount
        )
        
        // 받은 매너 평가 설정
        setReviewBox(receivedManner)
    }
    
    private func setProfileImage(_ profileImageUrl: String?) {
        if let profileImageUrl = profileImageUrl {
            let imageUrl = URL(string: API_URL + profileImageUrl)
            
            profileImageView.kf.setImage(
                with: imageUrl,
                placeholder: UIImage.defaultProfile) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success:
                        break
                        
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
    
    private func setNickname(_ nickname: String) {
        var nicknameAttributes = title20.attributes(alignment: .center)
        nicknameAttributes[.foregroundColor] = UIColor.neutral900
        
        let nicknameAttributedText = NSAttributedString(
            string: nickname,
            attributes: nicknameAttributes
        )
        
        nicknameLabel.attributedText = nicknameAttributedText
    }
    
    private func setReviewBox(_ receivedManner: [MannerTagModel]?) {
        guard let mannerTags = receivedManner, !mannerTags.isEmpty else { return }
        
        emptyMannerView.removeFromSuperview()
        
        mannerWrappingViews.removeAllArrangedSubviews()
        
        let sortedTags = mannerTags.sorted { $0.tagId < $1.tagId }
        
        let reviewViews = sortedTags.compactMap { tag -> UIView? in
            Review(number: String(format: "%03d", tag.tagId))
        }
        
        mannerWrappingViews.addArrangedSubviews(reviewViews)
        
        contentView.addSubview(mannerWrappingViews)
        
        // ReviewBox 컴포넌트
        mannerWrappingViews.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(receivedMannerLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func setBlockButtonTitle(isBlocked: Bool) {
        blockButton.changeTitle(title: NSLocalizedString(isBlocked ? "UnBlock" : "Block", tableName: "Common" , comment: ""))
    }
}
