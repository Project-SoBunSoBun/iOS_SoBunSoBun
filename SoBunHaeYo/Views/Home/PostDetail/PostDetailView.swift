//
//  PostDetailView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 1/26/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import OSLog

class PostDetailView: UIViewController {
    private let postId: Int
    private let isNew: Bool
    private let showBackButton: Bool
    private let showChatButton: Bool
    private let notificationId: Int?
    
    typealias Reactor = PostDetailReactor
    private lazy var reactor = PostDetailReactor(postId: postId)
    
    private let disposeBag = DisposeBag()
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Home.PostDetail.View"
    )
    
    init(
        postId: Int,
        isNew: Bool = false,
        showBackButton: Bool = true,
        showChatButton: Bool = true,
        notificationId: Int? = nil,
        nibName: String? = nil,
        bundle: Bundle? = nil
    ) {
        self.postId = postId
        self.isNew = isNew
        self.showBackButton = showBackButton
        self.showChatButton = showChatButton
        self.notificationId = notificationId
        
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        
        if showBackButton {
            tnb.parentViewController = self
        }
        
        return tnb
    }()
    
    // 상단 네비게이션 바 버튼 컴포넌트
    private func topNavigationButton(image: UIImage) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = image.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.background.backgroundColor = .clear
        
        let btn = UIButton(configuration: config)
        
        return btn
    }
    
    // (상단 네비게이션)공유 버튼
    private lazy var topShareButton: UIButton = topNavigationButton(image: .blackShare)
    
    // (상단 네비게이션)저장 버튼
    private lazy var topBookMarkButton: UIButton = topNavigationButton(image: .blackBookmark)
    
    // (상단 네비게이션)메뉴 버튼
    private lazy var topMoreButton: UIButton = topNavigationButton(image: .blackHorizontalDot)
    
    // (상단 네비게이션)메뉴 dropdown
    private let topMoreDropDownView: DropDownView = {
        let ddv = DropDownView(selectionMode: .plain, tableName: "Home")
        ddv.textAlignment = .center
        
        return ddv
    }()
    
    // tableView refresh
    private let refreshControl: BlueMeatballsRefreshController = {
        let rc = BlueMeatballsRefreshController()
        
        return rc
    }()
    
    // tableView
    private let tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tv.estimatedRowHeight = 124
        tv.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tv.isHidden = true
        
        return tv
    }()
    
    // 댓글 입력칸 위 구분선
    private let commentDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        view.isHidden = true
        
        return view
    }()
    
    // 댓글 생성 컨테이너
    private let createCommentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.backgroundColor = .backgroundWhite
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 0, bottom: 16, right: 0)
        sv.isHidden = true
        
        return sv
    }()
    
    // 채팅하기 버튼(타인 기준)
    private let chatButton: UIView = {
        let view = UIView()
        view.backgroundColor = .primary400
        view.layer.cornerRadius = 34
        view.clipsToBounds = true
        
        let icon = UIImageView()
        icon.image = .whiteMessage
        icon.contentMode = .scaleAspectFit
        icon.isUserInteractionEnabled = false
        
        view.addSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(24)
        }
        
        var attributes: [NSAttributedString.Key: Any] = title12.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.backgroundWhite
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "Chat", table: "Home"), attributes: attributes)
        
        view.addSubview(lb)
        
        lb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
        
        view.snp.makeConstraints { make in
            make.size.equalTo(68)
        }
        
        return view
    }()
    
    // 댓글 생성 입력칸
    private let createCommentContainerStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        sv.backgroundColor = .neutral50
        sv.layer.cornerRadius = 16
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 4, left: 16, bottom: 4, right: 4)
        sv.clipsToBounds = true
        
        return sv
    }()
    
    // 댓글 생성 textView
    private let createCommentTextView: MentionTextView = {
        let mtv = MentionTextView(minHeight: 24, maxHeight: 72, maxLength: 50, fontStyle: body16)
        mtv.textContainerInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        mtv.placeholder = String(localized: "InsertComment", table: "Home")
        mtv.showCharactersCount = false
        
        return mtv
    }()
    
    // 댓글 생성 버튼
    private let sendButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .greySend.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // 댓글 수정 컨테이너
    private let editCommentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.backgroundColor = .backgroundWhite
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 0, bottom: 16, right: 0)
        sv.isHidden = true
        
        return sv
    }()
    
    // 댓글 수정 textView
    private let editCommentTextView: MentionTextView = {
        let mtv = MentionTextView(minHeight: 32, maxHeight: 80, maxLength: 50, fontStyle: body16)
        mtv.textContainerInset = .init(top: 4, left: 16, bottom: 4, right: 16)
        mtv.placeholder = String(localized: "InsertComment", table: "Home")
        mtv.showCharactersCount = false
        mtv.backgroundColor = .neutral50
        mtv.layer.cornerRadius = 16
        mtv.clipsToBounds = true
        
        return mtv
    }()
    
    // 댓글 수정 취소
    private let editCommentCancelButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = .redFail.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.background.backgroundColor = .primary50
        
        // 캡슐 형태(원형)
        config.cornerStyle = .capsule
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // 댓글 수정 확인
    private let editCommentConfirmButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = .blueCheck.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.background.backgroundColor = .primary50
        
        // 캡슐 형태(원형)
        config.cornerStyle = .capsule
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // tableView 상단 컨텐츠 뷰
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        
        return view
    }()
    
    // 카테고리
    private let horizontalWrappingView = HorizontalWrappingView(horizontalSpacing: 8, verticalSpacing: 8)
    
    // 제목
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 작성자 정보
    private let authorInfoView = AuthorInfoView()
    
    // 소분소분 만남 정보
    private let informationCard = InformationCard()
    
    // 구매 예정 상품 제목
    private let plannedProductsTitleLabel: UILabel = {
        var attributes: [NSAttributedString.Key: Any] = title18.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.attributedText = NSAttributedString(string: String(localized: "PlannedProducts", table: "Home"), attributes: attributes)
        
        return lb
    }()
    
    // 구매 예정 상품
    private let plannedProductsLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 전달 사항 제목
    private let notesTitleLabel: UILabel = {
        var attributes: [NSAttributedString.Key: Any] = title18.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.attributedText = NSAttributedString(string: String(localized: "Notes", table: "Home"), attributes: attributes)
        
        return lb
    }()
    
    // 전달 사항
    private let notesLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 이용 규칙 카드
    private let ruleCard = RuleCard(title: String(localized: "SobunHaeyoRuleTitle", table: "Home"), desc: "\(String(localized: "SobunHaeyoRule01", table: "Home"))|\(String(localized: "SobunHaeyoRule02", table: "Home"))")
    
    // 컨텐트 뷰 구분선
    private let contentDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        
        return view
    }()
    
    // 댓글 갯수 라벨
    private let commentsCountLabel: UILabel = {
        var attributes: [NSAttributedString.Key: Any] = body16.attributes()
        attributes[.foregroundColor] = UIColor.neutral700
        
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.attributedText = NSAttributedString(string: "\(String(localized: "Comments", table: "Home")) 0", attributes: attributes)
        
        return lb
    }()
    
    // 댓글 메뉴 dropDown
    private let commentMenuDropDownView: DropDownView = {
        let ddv = DropDownView(selectionMode: .plain, tableName: "Home")
        ddv.textAlignment = .center
        
        return ddv
    }()
    
    // 게시글 작성 성공 뷰
    private let successView: RegisterPostSuccessView = {
        let view = RegisterPostSuccessView()
        view.isHidden = true
        
        return view
    }()
    
    // MARK: - 생명주기
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateTableHeaderViewHeight()
    }
    
    private func updateTableHeaderViewHeight() {
        guard let headerView = tableView.tableHeaderView else { return }
        
        let height = headerView.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        var frame = headerView.frame
        
        if abs(frame.size.height - height) > 1 {
            frame.size.height = height
            headerView.frame = frame
            tableView.tableHeaderView = headerView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .pageSheet
        
        configureUI()
        bind(reactor: reactor)
        
        // 현재의 navigation 스택에서 RegisterPostView 삭제(뒤로가기 시 게시글 작성 뷰 이동 방지)
        if let navigationController = navigationController {
            var viewControllers = navigationController.viewControllers
            
            viewControllers.removeAll {
                $0 is RegisterPostView
            }
            
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, createCommentStackView, commentDividerView, tableView, topMoreDropDownView, commentMenuDropDownView, successView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        createCommentStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        createCommentStackView.addArrangedSubview(createCommentContainerStackView)
        
        [createCommentTextView, sendButton].forEach {
            createCommentContainerStackView.addArrangedSubview($0)
        }
        
        [editCommentTextView, editCommentCancelButton, editCommentConfirmButton].forEach {
            editCommentStackView.addArrangedSubview($0)
        }
        
        commentDividerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(createCommentStackView.snp.top)
            make.height.equalTo(1)
        }
        
        // tableView 상단에 contentView 추가
        tableView.tableHeaderView = contentView
        tableView.refreshControl = refreshControl
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom).offset(8)
            make.bottom.equalTo(commentDividerView.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(tableView)
        }
        
        topMoreDropDownView.snp.makeConstraints { make in
            make.trailing.equalTo(topNavigationBar).inset(4)
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.width.equalTo(70)
        }
        
        configureContentView()
        
        successView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // contentView configure
    private func configureContentView() {
        [horizontalWrappingView, titleLabel, authorInfoView, informationCard, plannedProductsTitleLabel, plannedProductsLabel, notesTitleLabel, notesLabel, ruleCard, contentDividerView, commentsCountLabel].forEach {
            contentView.addSubview($0)
        }
        
        horizontalWrappingView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(horizontalWrappingView.snp.bottom).offset(8)
        }
        
        authorInfoView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        informationCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(authorInfoView.snp.bottom).offset(16)
        }
        
        plannedProductsTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(informationCard.snp.bottom).offset(24)
        }
        
        plannedProductsLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(plannedProductsTitleLabel.snp.bottom).offset(8)
        }
        
        notesTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(plannedProductsLabel.snp.bottom).offset(24)
        }
        
        notesLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(notesTitleLabel.snp.bottom).offset(8)
        }
        
        ruleCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(notesLabel.snp.bottom).offset(48)
        }
        
        contentDividerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(ruleCard.snp.bottom).offset(16)
            make.height.equalTo(1)
        }
        
        commentsCountLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(contentDividerView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}

extension PostDetailView {
    private func bind(reactor: PostDetailReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: PostDetailReactor) {
        reactor.action.onNext(.viewDidLoad)
        
        if let notificationId {
            reactor.action.onNext(.readNotification(notificationId))
        }
        
        if isNew {
            logger.debug("RegisterPostSuccessView 보이기")
            reactor.action.onNext(.showRegisterSuccessView)
        }
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        topShareButton.rx.tap
            .map { Reactor.Action.shareButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        topBookMarkButton.rx.tap
            .map { Reactor.Action.saveButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        topMoreButton.rx.tap
            .map { Reactor.Action.menuButtonTapped(!reactor.currentState.isMenuOpen) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        topMoreDropDownView.didCellTap
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { menu in
                reactor.action.onNext(.menuButtonTapped(false))
                
                switch menu {
                case "Report":
                    reactor.action.onNext(.reportPostButtonTapped)
                    
                case "Delete":
                    reactor.action.onNext(.deletePostButtonTapped)
                    
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
        
        sendButton.rx.tap
            .withLatestFrom(createCommentTextView.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                reactor.action.onNext(.createComment(text))
                createCommentTextView.text = ""
            })
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때
        tableView.rx.modelSelected(CommentModel.self)
            .map { Reactor.Action.setSelectedCommentModel($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editCommentConfirmButton.rx.tap
            .withLatestFrom(editCommentTextView.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                
                reactor.action.onNext(.editCommentTapped(text))
                editCommentTextView.text = ""
            })
            .disposed(by: disposeBag)
        
        editCommentCancelButton.rx.tap
            .map { Reactor.Action.editCancelTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        chatButton.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.chatButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        commentMenuDropDownView
            .didCellTap
            .subscribe(onNext: { [weak self] menu in
                guard let self = self else { return }
                
                let currentState = reactor.currentState
                let selectedCommentModel = currentState.selectedCommentModel
                let commentedUsersToNickname = currentState.commentedUsersToNickname
                
                switch menu {
                case "Reply":
                    guard let nickname = selectedCommentModel?.userNickname else {
                        return
                    }
                    
                    reactor.action.onNext(.replyButtonTapped("@\(nickname) "))
                
                case "Report":
                    reactor.action.onNext(.reportCommentButtonTapped)
                    
                case "Edit":
                    editCommentTextView.text = CommentView.convertComment(
                        comment: selectedCommentModel?.content ?? "",
                        commentedUsers: commentedUsersToNickname,
                        isEdited: false
                    )
                    .string
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    reactor.action.onNext(.editButtonTapped)
                    
                case "Delete":
                    reactor.action.onNext(.deleteCommentButtonTapped)
                    
                default:
                    logger.fault("commentMenuDropDownView의 didCellTap의 case에서 등록되지 않은 메뉴가 있음: \(menu)")
                }
            })
            .disposed(by: disposeBag)
        
        Observable.merge([
            view.rx.tapGesture().when(.recognized).map { _ in },
            tableView.rx.didZoom.map { _ in },
            tableView.rx.didScroll.map { _ in }
        ])
        .subscribe(onNext: { _ in
            reactor.action.onNext(.menuButtonTapped(false))
            reactor.action.onNext(.commentMenuButtonTapped(false))
        })
        .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: PostDetailReactor) {
        // 게시글 정보, 댓글 개수
        reactor.state.map { ($0.postInfo, $0.postCommentsCount) }
            .distinctUntilChanged{ $0.1 == $1.1 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (postInfo, postCommentsCount) in
                guard let self = self else { return }
                
                logger.debug("state의 postInfo 혹은 postCommentsCount 업데이트")
                
                if let postInfo, let postCommentsCount {
                    authorInfoView.bind(userId: postInfo.owner.id)
                    updateUI(postInfo: postInfo, postCommentsCount: postCommentsCount)
                } else {
                    contentView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        // 댓글 목록
        reactor.state.map { $0.comments }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: CommentTableViewCell.identifier,
                cellType: CommentTableViewCell.self
            )) { [weak self] index, model, cell in
                guard let self = self else { return }
                
                logger.debug("state의 comments 업데이트")
                
                let commentedUsers = reactor.currentState.commentedUsersToNickname
                
                cell.configureUI(model: model, commentedUsers: commentedUsers)
                
                cell.menuTap
                    .subscribe(onNext: { [weak self] button in
                        guard let self = self else { return }
                        
                        if let myIdString = KeyChain.shared.get(key: "USER_ID"),
                           let myId = Int(myIdString) {
                            if model.userId == myId {
                                commentMenuDropDownView.items = ["Reply", "Edit", "Delete"]
                            } else {
                                commentMenuDropDownView.items = ["Reply", "Report"]
                            }
                        } else {
                            commentMenuDropDownView.items = []
                        }
                        
                        // 버튼 좌표 변환
                        let buttonFrame = button.convert(button.bounds, to: view)
                        
                        // 드롭다운 높이: 항목 수 × 셀 높이
                        let dropdownHeight = CGFloat(commentMenuDropDownView.items.count) * commentMenuDropDownView.cellHeight
                        
                        // commentDividerView 위까지 남은 공간
                        let availableSpaceBelow = commentDividerView.frame.minY - buttonFrame.maxY
                        let shouldOpenUpward = dropdownHeight > availableSpaceBelow
                        
                        commentMenuDropDownView.animationAnchor = shouldOpenUpward ? .bottomRight : .topRight
                        
                        commentMenuDropDownView.snp.remakeConstraints { make in
                            make.trailing.equalTo(self.view.snp.leading).offset(buttonFrame.maxX)
                            
                            if shouldOpenUpward {
                                make.bottom.equalTo(self.view.snp.top).offset(buttonFrame.minY)
                            } else {
                                make.top.equalToSuperview().offset(buttonFrame.maxY)
                            }
                            
                            make.width.equalTo(70)
                        }
                        
                        // z-order 재설정
                        view.bringSubviewToFront(commentMenuDropDownView)
                        
                        let currentState = reactor.currentState
                        let isSameComment = currentState.selectedCommentModel?.id == model.id
                        let shouldCommentMenuOpen = !(currentState.isCommentMenuOpen && isSameComment)

                        reactor.action.onNext(.commentMenuButtonTapped(shouldCommentMenuOpen))
                        reactor.action.onNext(.setSelectedCommentModel(model))
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // MentionTextView의 멘션 기능을 위한 닉네임으로 유저의 id 찾는 용도
        reactor.state.map { $0.commentedUsersToId }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] users in
                guard let self = self else { return }
                
                createCommentTextView.commentedUsersToId.accept(users)
                editCommentTextView.commentedUsersToId.accept(users)
            })
            .disposed(by: disposeBag)
        
        // 저장 유무
        reactor.state.map { $0.isSaved }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isSaved in
                guard let self = self else { return }
                
                logger.debug("state의 isSaved 업데이트")
                
                let imageSize: CGSize = .init(width: 24, height: 24)
                
                topBookMarkButton.configuration?.image = isSaved ?
                    .blackBookmarkFill.resize(imageSize) :
                    .blackBookmark.resize(imageSize)
            })
            .disposed(by: disposeBag)
        
        // 상단 네비게이션의 dropDown 개폐
        reactor.state.map { $0.isMenuOpen }
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                topMoreDropDownView.setOpen(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        // 수정 모드와 선택한 댓글 API 모델
        reactor.state.map { ($0.isEditMode, $0.selectedCommentModel) }
            .distinctUntilChanged { $0 == $1 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEditMode, selectedCommentModel in
                guard let self = self else { return }
                
                logger.debug("state의 isEditMode 혹은 selectedCommentModel 업데이트")
                
                let visibleCells = tableView.visibleCells.compactMap { $0 as? CommentTableViewCell }
                
                for cell in visibleCells {
                    guard let indexPath = tableView.indexPath(for: cell),
                          let selectedCommentModel else { continue }
                    
                    let model = reactor.currentState.comments[indexPath.row]
                    cell.toggleEditMode(isEditMode && selectedCommentModel.id == model.id)
                }
                
                updateEditUI(isEditMode: isEditMode)
            })
            .disposed(by: disposeBag)
        
        // 답장 기능
        reactor.pulse(\.$textViewText)
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // 키보드 올리기
                _ = createCommentTextView.becomeFirstResponder()
            })
            .bind(to: createCommentTextView.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowShare)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let postTitle = reactor.currentState.postInfo?.title ?? String(localized: "Unknown", table: "Common")
                let shareContent = String(
                    format: String(localized: "SharePostText", table: "Common"),
                    postTitle,
                    "sobunhaeyo://post/\(self.postId)"
                )
                
                let activityVC = UIActivityViewController(
                    activityItems: [shareContent],
                    applicationActivities: nil
                )
                
                self.present(activityVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 게시글 삭제 알림
        reactor.pulse(\.$shouldShowDeletePostAlert)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "DeletePostTitle", table: "Home"),
                    primaryTitleKey: String(localized: "Delete", table: "Home"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    reactor.action.onNext(.deletePost)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 게시글 삭제 완료 알림
        reactor.pulse(\.$shouldShowDeletePostDoneAlert)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "DeleteDoneTitle", table: "Home"),
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true)
                    }
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 댓글 메뉴
        reactor.state.map { $0.isCommentMenuOpen }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                tableView.isScrollEnabled = !isOpen
                commentMenuDropDownView.setOpen(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        // 댓글 삭제 알림
        reactor.pulse(\.$shouldShowDeleteCommentAlert)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "DeleteCommentTitle", table: "Home"),
                    primaryTitleKey: String(localized: "Delete", table: "Home"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    self.reactor.action.onNext(.deleteComment)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 댓글 삭제 완료 알림
        reactor.pulse(\.$shouldShowDeleteCommentDoneAlert)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "DeleteDoneTitle", table: "Home"),
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToChat)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] roomId in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(ChatView(chatRoomId: roomId), animated: true)
            })
            .disposed(by: disposeBag)
        
        // 새로고침
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        // 작성 성공 알림 뷰
        reactor.pulse(\.$shouldShowRegisterSuccessView)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                view.bringSubviewToFront(successView)
                successView.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.successView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushReportPostView)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(ReportView(target: .post(postId: postId)), animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushReportPostCommentView)
            .withLatestFrom(reactor.state.map { $0.selectedCommentModel })
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] commentModel in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(ReportView(target: .comment(commentId: commentModel.id)), animated: true)
            })
            .disposed(by: disposeBag)
        
        // 오류 메시지
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "Error", table: "Error"),
                    subTitle: message,
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
    }
    
    // contentView 업데이트
    private func updateUI(postInfo: PostModel, postCommentsCount: CommentCountModel) {
        guard let userIdString = KeyChain.shared.get(key: "USER_ID"),
              let myId = Int(userIdString) else {
            return
        }
        
        let isOwner = (myId == postInfo.owner.id)
        
        var buttons: [UIButton] = [topShareButton]
        
        if !isOwner {
            buttons.append(topBookMarkButton)
        }
        
        if showChatButton {
            buttons.append(topMoreButton)
        }
        
        topNavigationBar.buttons = buttons
        
        topMoreDropDownView.items = isOwner ? ["Delete"] : ["Report"]
        
        // 카테고리
        let categories = postInfo.categoryCode.split(separator: ",").map {
            let category = NSLocalizedString("Category\($0)", tableName: "Category", comment: "")
            let view = CategoryMini()
            
            view.text = category
            
            return view
        }
        
        horizontalWrappingView.removeAllArrangedSubviews()
        horizontalWrappingView.addArrangedSubviews(categories)
        
        // 제목
        var titleAttributes: [NSAttributedString.Key: Any] = title24.attributes()
        titleAttributes[.foregroundColor] = UIColor.neutral900
        
        titleLabel.attributedText = NSAttributedString(string: postInfo.title, attributes: titleAttributes)
        
        // 유저 정보
        authorInfoView.configureUI(
            profileImageUrl: postInfo.owner.profileImageUrl,
            nickname: postInfo.owner.nickname,
            createdAt: postInfo.createdAt,
            verifyLocation: postInfo.owner.address
        )
        
        // 정보 카드
        informationCard.configureUI(
            minMembers: postInfo.minMembers,
            maxMembers: postInfo.maxMembers,
            locationName: postInfo.locationName,
            meetAt: postInfo.meetAt,
            deadline: postInfo.deadlineAt
        )
        
        // 구매 예정 상품
        var plannedProductsAttributes: [NSAttributedString.Key: Any] = body16.attributes()
        plannedProductsAttributes[.foregroundColor] = UIColor.neutral700
        
        plannedProductsLabel.attributedText = NSAttributedString(string: postInfo.itemsText, attributes: plannedProductsAttributes)
        
        // 전달 사항
        var notesAttributes: [NSAttributedString.Key: Any] = body16.attributes()
        notesAttributes[.foregroundColor] = UIColor.neutral700
        
        notesLabel.attributedText = NSAttributedString(string: postInfo.notesText, attributes: notesAttributes)
        
        var commentsCountAttributes: [NSAttributedString.Key: Any] = body18.attributes()
        commentsCountAttributes[.foregroundColor] = UIColor.neutral700
        
        commentsCountLabel.attributedText = NSAttributedString(string: "\(String(localized: "Comments", table: "Home")) \(postCommentsCount.commentCount)", attributes: commentsCountAttributes)
        
        contentView.isHidden = false
        tableView.isHidden = false
        commentDividerView.isHidden = false
        createCommentStackView.isHidden = false
        editCommentStackView.isHidden = false
        
        if !isOwner && showChatButton {
            createCommentStackView.insertArrangedSubview(chatButton, at: 0)
        }
        
        contentView.layoutIfNeeded()
        updateTableHeaderViewHeight()
    }
    
    // 수정 모드 UI 업데이트
    private func updateEditUI(isEditMode: Bool) {
        if isEditMode {
            createCommentStackView.removeFromSuperview()
            view.addSubview(editCommentStackView)
            
            editCommentStackView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            }
        } else {
            editCommentStackView.removeFromSuperview()
            view.addSubview(createCommentStackView)
            
            createCommentStackView.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            }
        }
        
        commentDividerView.snp.remakeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(isEditMode ? editCommentStackView.snp.top : createCommentStackView.snp.top)
            make.height.equalTo(1)
        }
    }
}

