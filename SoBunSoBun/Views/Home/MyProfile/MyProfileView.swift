//
//  MyProfileView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/18/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import OSLog

class MyProfileView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Home.MyProfile.View"
    )
    
    typealias Reactor = MyProfileReactor
    private let reactor = MyProfileReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private let settingButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .settings
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let bt = UIButton(configuration: config)
        
        return bt
    }()
    
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.title = String(localized: "Profile", table: "Common")
        tnb.buttons = [settingButton]
        
        return tnb
    }()
    
    private let refreshControl: BlueMeatballsRefreshController = {
        let rc = BlueMeatballsRefreshController()
        
        return rc
    }()
    
    private let tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.register(PostListTableViewCell.self, forCellReuseIdentifier: PostListTableViewCell.identifier)
        tv.register(PostListWithCommentTableViewCell.self, forCellReuseIdentifier: PostListWithCommentTableViewCell.identifier)
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
    
    // 프로필 수정
    private let editProfileButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = 12
        config.background.backgroundColor = .neutral50
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        var attributes = body14.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral400
        
        config.attributedTitle = AttributedString(NSAttributedString(
            string: String(localized: "EditProfile", table: "Settings"),
            attributes: attributes
        ))
        
        let bt = UIButton()
        bt.configuration = config
        
        return bt
    }()
    
    // 매너 점수, 참여 횟수, 방장 횟수 뷰
    private let userInfoView = UserInfo()
    
    // 작성한 글 버튼
    private let tabPostsButton = MyProfileTabButton(title: String(localized: "TabPosts", table: "Home"))
    
    // 댓글단 글 버튼
    private let tabCommentedButton = MyProfileTabButton(title: String(localized: "TabCommented", table: "Home"))
    
    // 저장한 글
    private let tabSavedButton = MyProfileTabButton(title: String(localized: "TabSaved", table: "Home"))
    
    // 탭 버튼 stack view
    private let tabButtonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fillEqually
        
        return sv
    }()
    
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
        
        tableView.dataSource = self
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

extension MyProfileView {
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        // 프로필 수정 버튼 클릭
        editProfileButton.rx.tap
            .map { Reactor.Action.editProfileButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 앱 설정 아이콘 버튼 클릭
        settingButton.rx.tap
            .map { Reactor.Action.settingButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 작성한 글
        tabPostsButton.rx.tap
            .map { Reactor.Action.tabSelected(0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 댓글단 글
        tabCommentedButton.rx.tap
            .map { Reactor.Action.tabSelected(1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 저장한 글
        tabSavedButton.rx.tap
            .map { Reactor.Action.tabSelected(2) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 새로고침
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때
        tableView.rx.itemSelected
            .compactMap { [weak self] indexPath -> Reactor.Action? in
                guard let self = self else { return nil }
                
                let model = self.reactor.currentState.posts[indexPath.row]
                
                return Reactor.Action.postTapped(model)
            }
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
        
        reactor.state.map { $0.tabIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                
                tabPostsButton.isSelected = index == 0
                tabCommentedButton.isSelected = index == 1
                tabSavedButton.isSelected = index == 2
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            reactor.state.map { $0.posts }.distinctUntilChanged(),
            reactor.state.map { $0.tabIndex }.distinctUntilChanged()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] posts, tabIndex in
            guard let self = self else { return }
            
            tableView.reloadData()
        })
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushSettingView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(ManagingAccountInfoView(), animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushEditProfileView)
            .withLatestFrom(
                reactor.state.map { $0.userInfo }
                    .distinctUntilChanged()
            )
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] userInfo in
                guard let self = self else { return }
                
                if let profileImageUrl = userInfo.profileImageUrl {
                    self.navigationController?.pushViewController(EditProfileView(profileImageUrl: URL(string: API_URL + profileImageUrl)), animated: true)
                } else {
                    self.navigationController?.pushViewController(EditProfileView(profileImageUrl: nil), animated: true)
                }
            })
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
                
                let alert = CustomAlertView(
                    title: String(localized: "Error", table: "Common"),
                    subTitle: message,
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureContentView(model: MyProfileResponseDataModel) {
        [profileImageView, nicknameLabel, editProfileButton, userInfoView, tabButtonsStackView].forEach {
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
        
        // 프로필 수정 버튼
        editProfileButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
        }
        
        // 유저 정보 뷰 컴포넌트
        userInfoView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(editProfileButton.snp.bottom).offset(24)
        }
        
        [tabPostsButton, tabCommentedButton, tabSavedButton].forEach {
            tabButtonsStackView.addArrangedSubview($0)
        }
        
        tabButtonsStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(userInfoView.snp.bottom).offset(24)
            make.bottom.equalToSuperview()
        }
    }
    
    private func updateUI(_ model: MyProfileResponseDataModel) {
        let nickname = model.nickname ?? String(localized: "UnknownNickname", table: "Settings")
        let profileImageUrl = model.profileImageUrl
        
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
}

extension MyProfileView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reactor.currentState.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = reactor.currentState.posts[indexPath.row]
        
        if reactor.currentState.tabIndex == 1 { // 댓글단 글
            let cell = tableView.dequeueReusableCell(withIdentifier: PostListWithCommentTableViewCell.identifier, for: indexPath) as! PostListWithCommentTableViewCell
            cell.configureUI(model: model, horizontalEdgesInset: 16)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostListTableViewCell.identifier, for: indexPath) as! PostListTableViewCell
            cell.configureUI(model: model, horizontalEdgesInset: 16)
            
            return cell
        }
    }
}
