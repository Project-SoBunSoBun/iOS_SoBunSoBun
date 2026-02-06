//
//  PostDetailView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/26/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class PostDetailView: UIViewController {
    private let postId: Int
    
    typealias Reactor = PostDetailReactor
    private lazy var reactor = PostDetailReactor(postId: postId)
    
    private let disposeBag = DisposeBag()
    
    init(postId: Int, nibName: String? = nil, bundle: Bundle? = nil) {
        self.postId = postId
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private func topNavigationButton(image: UIImage) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = image.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.background.backgroundColor = .clear
        
        let btn = UIButton(configuration: config)
        
        return btn
    }
    
    private lazy var topShareButton: UIButton = topNavigationButton(image: .blackShare)
    
    private lazy var topBookMarkButton: UIButton = topNavigationButton(image: .blackBookmark)
    
    private lazy var topMoreButton: UIButton = topNavigationButton(image: .blackHorizontalDot)
    
    private let topMoreDropDownView: DropDownView = DropDownView(selectionMode: .plain, tableName: "Home")
    
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.buttons = [topShareButton, topBookMarkButton, topMoreButton]
        
        return tnb
    }()
    
    private let refreshControl: BlueMeatballsRefreshController = {
        let rc = BlueMeatballsRefreshController()
        
        return rc
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        
        return tv
    }()
    
    private let commentDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        
        return view
    }()
    
    private let createCommentContaienrStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.backgroundColor = .backgroundWhite
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        return sv
    }()
    
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
        
        view.isHidden = true
        
        return view
    }()
    
    private let createCommentContainerStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        
        sv.backgroundColor = .neutral50
        sv.layer.cornerRadius = 16
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 4)
        sv.clipsToBounds = true
        
        return sv
    }()
    
    private let createCommmentTextView: AutoHeightTextView = AutoHeightTextView(minHeight: 56, maxHeight: 72, maxLength: 120, fontStyle: body16)
    
    private let sendButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .greySend.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private let editCommentContainerStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.backgroundColor = .backgroundWhite
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        sv.isHidden = true
        
        return sv
    }()
    
    private let editCommentTextView: AutoHeightTextView = AutoHeightTextView(minHeight: 56, maxHeight: 72, maxLength: 120, fontStyle: body16)
    
    private let editCommentCancelButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = .redFail.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.background.backgroundColor = .primary50
        
        let btn = UIButton(configuration: config)
        btn.layer.cornerRadius = 24
        btn.clipsToBounds = true
        
        return btn
    }()
    
    private let editCommentConfirmButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = .blueCheck.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.background.backgroundColor = .primary50
        
        let btn = UIButton(configuration: config)
        btn.layer.cornerRadius = 24
        btn.clipsToBounds = true
        
        return btn
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        
        return view
    }()
    
    private let horizontalWrappingView = HorizontalWrappingView(horizontalSpacing: 8, verticalSpacing: 8)
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let authorInfoView = AuthorInfoView()
    
    private let informationCard = InformationCard()
    
    private let plannedProductsTitleLabel: UILabel = {
        var attributes: [NSAttributedString.Key: Any] = title18.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.attributedText = NSAttributedString(string: String(localized: "PlannedProducts", table: "Home"), attributes: attributes)
        
        return lb
    }()
    
    private let plannedProductsLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let notesTitleLabel: UILabel = {
        var attributes: [NSAttributedString.Key: Any] = title18.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.attributedText = NSAttributedString(string: String(localized: "Notes", table: "Home"), attributes: attributes)
        
        return lb
    }()
    
    private let notesLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let ruleCard = RuleCard(title: String(localized: "SobunSobunRuleTitle", table: "Home"), desc: "\(String(localized: "SobunSobunRule01", table: "Home"))|\(String(localized: "SobunSobunRule02", table: "Home"))")
    
    private let contentDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        
        return view
    }()
    
    private let commentsCountLabel: UILabel = {
        var attributes: [NSAttributedString.Key: Any] = body16.attributes()
        attributes[.foregroundColor] = UIColor.neutral700
        
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.attributedText = NSAttributedString(string: "\(String(localized: "Comments", table: "Home")) 0", attributes: attributes)
        
        return lb
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
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
        [topNavigationBar, topMoreDropDownView, createCommentContainerStackView, editCommentContainerStackView, commentDividerView, tableView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        topMoreDropDownView.snp.makeConstraints { make in
            make.trailing.equalTo(topNavigationBar).inset(4)
            make.top.equalTo(topNavigationBar.snp.bottom)
        }
        
        [chatButton, createCommmentTextView].forEach {
            createCommentContainerStackView.addArrangedSubview($0)
        }
        
        createCommentContainerStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        [editCommentTextView, editCommentCancelButton, editCommentConfirmButton].forEach {
            editCommentContainerStackView.addArrangedSubview($0)
        }
        
        editCommentContainerStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        commentDividerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(createCommentContainerStackView.snp.top)
            make.height.equalTo(1)
        }
        
        tableView.tableHeaderView = contentView
        tableView.refreshControl = refreshControl
        
        configureContentView()
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom).offset(8)
            make.bottom.equalTo(commentDividerView.snp.top).inset(24)
        }
    }
    
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
            .map { Reactor.Action.menuButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        topMoreDropDownView
            .didCellTap
            .subscribe(onNext: { menu in
                switch menu {
                case "Report":
                    reactor.action.onNext(.reportButtonTapped)
                    
                case "Delete":
                    reactor.action.onNext(.deletePostButtonTapped)
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
        
        sendButton.rx.tap
            .withLatestFrom(createCommmentTextView.rx.text.orEmpty)
            .map { text in
                Reactor.Action.createComment(text)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때
        tableView.rx.modelSelected(CommentModel.self)
            .map { Reactor.Action.setSelectedCommentId($0.id) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editCommentConfirmButton.rx.tap
            .withLatestFrom(editCommentTextView.rx.text.orEmpty)
            .map { text in
                Reactor.Action.editCommentTapped(text)
            }
            .bind(to: reactor.action)
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
    }
    
    private func bindState(reactor: PostDetailReactor) {
        reactor.state.map { ($0.postInfo, $0.postCommentsCount) }
            .subscribe(onNext: { [weak self] (postInfo, postCommentsCount) in
                guard let self = self else { return }
                
                if let postInfo, let postCommentsCount {
                    updateUI(postInfo: postInfo, postCommentsCount: postCommentsCount)
                } else {
                    contentView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
            
        reactor.state.map { $0.comments }
            .bind(to: tableView.rx.items(
                cellIdentifier: CommentTableViewCell.identifier,
                cellType: CommentTableViewCell.self
            )) { [weak self] index, model, cell in
                guard let self = self else { return }
                let commentedUsers = reactor.currentState.commentedUsersToNickname ?? [:]
                
                cell.configureUI(model: model, commentedUsers: commentedUsers)
                
                cell.replyTap
                    .map { Reactor.Action.replyButtonTapped }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
                
                cell.reportTap
                    .map { Reactor.Action.reportButtonTapped }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
                
                cell.editTap
                    .map { Reactor.Action.editButtonTapped }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
                
                cell.editTap
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        
                        editCommentTextView.rx.text.onNext(model.content)
                    })
                    .disposed(by: disposeBag)
                
                cell.deleteTap
                    .map { Reactor.Action.deleteCommentButtonTapped }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isSaved }
            .subscribe(onNext: { [weak self] isSaved in
                guard let self = self else { return }
                
                let imageSize: CGSize = .init(width: 24, height: 24)
                
                topBookMarkButton.configuration?.image = isSaved ?
                    .blackBookmarkFill.resize(imageSize) :
                    .blackBookmark.resize(imageSize)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isMenuOpen }
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                topMoreDropDownView.setOpen(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        
        reactor.state.map { ($0.isEditMode, $0.selectedCommentId) }
        .skip(1)
        .subscribe(onNext: { [weak self] isEditMode, selectedCommentId in
            guard let self = self else { return }
            
            let visibleCells = self.tableView.visibleCells.compactMap { $0 as? CommentTableViewCell }
            
            for cell in visibleCells {
                guard let indexPath = self.tableView.indexPath(for: cell) else { continue }
                let model = reactor.currentState.comments[indexPath.row]
                let shouldBeInEditMode = isEditMode && selectedCommentId == model.id
                
                cell.toggleEditMode(shouldBeInEditMode)
            }
            
            updateEditUI(isEditMode: isEditMode)
        })
        .disposed(by: disposeBag)
        
        // 답장 기능
        reactor.state.map { $0.reply }
            .bind(to: createCommmentTextView.rx.text)
            .disposed(by: disposeBag)
        
        // TODO: 공유 기능 추가 필요
        reactor.pulse(\.$shouldShowShare)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                
            })
            .disposed(by: disposeBag)
        
        // 게시글 신고 알림
        reactor.pulse(\.$shouldShowReportPostAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "ReportPostTitle", table: "Home"),
                    primaryTitleKey: String(localized: "Report", table: "Home"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.isSubtitleEnabled = false
                
                alert.onPrimaryTapped = {
                    self.reactor.action.onNext(.reportPost)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 게시글 신고 완료 알림
        reactor.pulse(\.$shouldShowReportPostDoneAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                showAlert(title: String(localized: "ReportDoneTitle", table: "Home"), vc: self)
            })
            .disposed(by: disposeBag)
        
        // 게시글 삭제 알림
        reactor.pulse(\.$shouldShowDeletePostAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "DeletePostTitle", table: "Home"),
                    primaryTitleKey: String(localized: "Delete", table: "Home"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.isSubtitleEnabled = false
                
                alert.onPrimaryTapped = {
                    self.reactor.action.onNext(.deletePost)
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
                
                showAlert(
                    title: String(localized: "DeleteDoneTitle", table: "Home"),
                    confirmAction: {
                        self.navigationController?.popViewController(animated: true)
                    },
                    vc: self
                )
            })
            .disposed(by: disposeBag)
        
        // 댓글 신고 알림
        reactor.pulse(\.$shouldShowReportCommentAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "ReportCommentTitle", table: "Home"),
                    primaryTitleKey: String(localized: "Report", table: "Home"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.isSubtitleEnabled = false
                
                alert.onPrimaryTapped = {
                    self.reactor.action.onNext(.reportComment)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 댓글 신고 완료 알림
        reactor.pulse(\.$shouldShowReportCommentDoneAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                showAlert(title: String(localized: "ReportDoneTitle", table: "Home"), vc: self)
            })
            .disposed(by: disposeBag)
        
        // 댓글 삭제 알림
        reactor.pulse(\.$shouldShowDeleteCommentAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "DeleteCommentTitle", table: "Home"),
                    primaryTitleKey: String(localized: "Delete", table: "Home"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.isSubtitleEnabled = false
                
                alert.onPrimaryTapped = {
                    self.reactor.action.onNext(.deleteComment)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 댓글 삭제 완료 알림
        reactor.pulse(\.$shouldShowDeleteCommentDoneAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                showAlert(title: String(localized: "DeleteDoneTitle", table: "Home"), vc: self)
            })
            .disposed(by: disposeBag)
        
        // TODO: 채팅 연결 기능 구현 필요
        reactor.pulse(\.$shouldNavigateToChat)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                
            })
            .disposed(by: disposeBag)
        
        // 오류 메시지
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                showAlert(title: message, vc: self)
            })
            .disposed(by: disposeBag)
    }
    
    // contentView 업데이트
    private func updateUI(postInfo: PostModel, postCommentsCount: CommentCountModel) {
        // 카테고리
        let categories = postInfo.categoryCode.split(separator: ",").map {
            let view = CategoryMini()
            view.text = String($0)
            
            return view
        }
        
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
        
        commentsCountLabel.attributedText = NSAttributedString(string: "\(String(localized: "Comments", table: "Home")) \(postCommentsCount)", attributes: commentsCountAttributes)
        
        if let userId = KeyChain.shared.get(key: "USER_ID"),
           let myId = Int(userId) {
            chatButton.isHidden = myId == postInfo.owner.id
        } else {
            chatButton.isHidden = true
        }
        
        contentView.isHidden = false
    }
    
    // 수정 모드 UI 업데이트
    private func updateEditUI(isEditMode: Bool) {
        createCommentContainerStackView.isHidden = isEditMode
        editCommentContainerStackView.isHidden = !isEditMode
        
        commentDividerView.snp.remakeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(isEditMode ? editCommentContainerStackView.snp.top : createCommentContainerStackView.snp.top)
            make.height.equalTo(1)
        }
    }
}

#if DEBUG
// 미리보기
import SwiftUI

struct PostDetaillViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            PostDetailView(postId: 0)
        }
    }
}
#endif
