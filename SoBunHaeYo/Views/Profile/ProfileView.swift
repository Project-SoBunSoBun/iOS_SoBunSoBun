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

class ProfileView: UIViewController {
    private let userId: Int
    
    init(userId: Int, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.userId = userId
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Profile.View"
    )
    
    typealias Reactor = ProfileReactor
    private lazy var reactor = ProfileReactor(userId: userId)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.title = String(localized: "Profile", table: "Common")
        
        return tnb
    }()
    
    private let refreshControl: BlueMeatballsRefreshController = {
        let rc = BlueMeatballsRefreshController()
        
        return rc
    }()
    
    private let tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.register(UserPagePostListTableViewCell.self, forCellReuseIdentifier: UserPagePostListTableViewCell.identifier)
        tv.estimatedRowHeight = 142
        tv.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        return tv
    }()
    
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
    
    // 작성한 글 라벨
    private lazy var myPostsLabel = makeLabel(string: String(localized: "MyPosts", table: "Common"))
    
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
        
        [topNavigationBar, tableView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        tableView.tableHeaderView = contentView
        tableView.refreshControl = refreshControl
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(tableView)
        }
    }
}

extension ProfileView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        // 새로고침
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때
        tableView.rx.modelSelected(PostModel.self)
            .map { Reactor.Action.postTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 페이지네이션
        tableView.rx.willDisplayCell
            .filter { [weak self] cell, indexPath -> Bool in
                guard let self = self else { return false }
                
                let totalCount = self.tableView.numberOfRows(inSection: 0)
                let triggerCount = 3
                
                return totalCount > triggerCount && indexPath.row >= totalCount - triggerCount
            }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.loadMorePosts }
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
        
        reactor.state.map { $0.posts }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: UserPagePostListTableViewCell.identifier,
                cellType: UserPagePostListTableViewCell.self
            )) { index, model, cell in
                cell.configureUI(model: model, bottomEdgeInset: 8)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushPostDetailView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(PostDetailView(postId: model.id, showBackButton: true, showChatButton: false), animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureContentView(model: ProfileUserInfoResponseDataModel) {
        [profileImageView, nicknameLabel, userInfoView, receivedMannerLabel, emptyMannerView, myPostsLabel].forEach {
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
        
        // 나의 공동 구매 라벨
        myPostsLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(emptyMannerView.snp.bottom).offset(24)
            make.bottom.equalToSuperview().inset(16).priority(.high)
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
        
        contentView.layoutIfNeeded()
        tableView.tableHeaderView = contentView
        tableView.layoutIfNeeded()
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
        }
        
        // 작성한 글 구매 라벨
        myPostsLabel.snp.remakeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(mannerWrappingViews.snp.bottom).offset(24)
            make.bottom.equalToSuperview().inset(16).priority(.high)
        }
    }
}
