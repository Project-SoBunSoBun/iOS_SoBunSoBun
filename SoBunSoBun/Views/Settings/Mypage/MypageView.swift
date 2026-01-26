//
//  MypageView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/24/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import OSLog
import Kingfisher

class MypageView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Mypage.View"
    )
    
    typealias Reactor = MyPageReactor
    private let reactor = MyPageReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 설정 버튼
    private let settingButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        config.image = .settings
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let bt = UIButton(configuration: config)
        
        return bt
    }()
    
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "MyProfile", table: "Settings")
        tnb.buttons = [settingButton]
        
        return tnb
    }()
    
    // 전체 스크롤 뷰
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        
        return sv
    }()
    
    // 스크롤 뷰가 들어갈 View
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
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
    
    // 프로필 수정 버튼
    private let editProfileButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = 12
        config.background.backgroundColor = .neutral50
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        var attributes = AttributeContainer()
        attributes.font = body14.font
        attributes.foregroundColor = UIColor.neutral400.withAlphaComponent(1.0)
        
        config.attributedTitle = AttributedString(
            String(localized: "EditProfile", table: "Settings"),
            attributes: attributes
        )
        
        let bt = UIButton()
        bt.configuration = config
            
        return bt
    }()
    
    // 매너 점수, 참여 횟수, 방장 횟수 뷰
    private let userInfoView = UserInfo()
    
    // 받은 매너 평가 라벨
    private let receivedMannerLabel: UILabel = {
        var attributes = title16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: String(localized: "ReceivedReview", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // ReviewBox
    private var mannerWrappingViews = HorizontalWrappingView(
        horizontalSpacing: 8,
        verticalSpacing: 8
    )
    
    // 그라데이션 뷰
    private let gradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    // 그라데이션 뷰
    private let gradientLayer: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor.primary100.withAlphaComponent(0).cgColor,
            UIColor.primary100.withAlphaComponent(1).cgColor
        ]
        gl.locations = [0,1]
        gl.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        return gl
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        bind(reactor: reactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reactor.action.onNext(.viewDidLoad)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - 레이아웃 구성
    private func configure() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, gradientView, scrollView].forEach {
            view.addSubview($0)
        }
        
        gradientView.layer.addSublayer(gradientLayer)
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 그라데이션 뷰
        gradientView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * 0.62)
        }
        
        scrollView.addSubview(contentView)
        
        // 스크롤 뷰
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(84)
        }
        
        // 스크롤 뷰 안에 들어가는 컨텐츠 뷰
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [profileImageView, nicknameLabel, editProfileButton, userInfoView, receivedMannerLabel, mannerWrappingViews].forEach {
            contentView.addSubview($0)
        }
        
        // 프로필 이미지 뷰
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(scrollView.snp.bottom).offset(16)
            make.size.equalTo(100)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
        }
        
        editProfileButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
        }
        
        userInfoView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(editProfileButton.snp.bottom).offset(24)
        }
        
        receivedMannerLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(userInfoView.snp.bottom).offset(24)
        }
        
        mannerWrappingViews.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(receivedMannerLabel.snp.bottom).offset(16)
        }
    }
}

extension MypageView {
    private func bind(reactor: MyPageReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: MyPageReactor) {
        // viewDidLoad 시 동작
        reactor.action.onNext(.viewDidLoad)
    }
    
    private func bindState(reactor: MyPageReactor) {
        // 프로필 정보 받아오기
        reactor.state.map { $0.profile }
            .compactMap { $0 }
            .distinctUntilChanged { $0.data == $1.data }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] profile in
                guard let self = self else { return }
                
                self.updateUI(profile)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(_ profile: MyProfileModel) {
        let nickname = profile.data.nickname ?? String(localized: "UnknownNickname")
        let profileImageUrl = profile.data.profileImageUrl
        let receivedManner = profile.data.mannerTags
        
        // 프로필 이미지 설정
        setProfileImage(profileImageUrl)
        
        // 닉네임 라벨 Text 설정
        setNickname(nickname)
        
        // 매너 점수, 참여 횟수, 방장 횟수 설정
        userInfoView.updateUI(profile)
        
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
        mannerWrappingViews.removeAllArrangedSubviews()
        
        guard let mannerTags = receivedManner, !mannerTags.isEmpty else { return }
        
        let sortedTags = mannerTags.sorted { $0.tagId < $1.tagId }
        
        let reviewViews = sortedTags.compactMap { tag -> UIView? in
            // tagId에 따라 title 생성: "Review001", "Review003"...
            let title = String(format: "Review%03d", tag.tagId)
            let review = Review(title: title)
            
            return review
        }
        
        mannerWrappingViews.addArrangedSubviews(reviewViews)
    }
}
