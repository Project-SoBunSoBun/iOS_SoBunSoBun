//
//  ChatRightMenuView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class ChatRightMenuView: UIViewController {
    private let chatRoomId: Int
    private let groupPostId: Int
    private let type: ChatRoomType
    
    init(
        chatRoomId: Int,
        groupPostId: Int,
        type: ChatRoomType,
        members: [ChatRoomDetailMemberModel],
        nibName nibNameOrNil: String? = nil,
        bundle nibBundleOrNil: Bundle? = nil
    ) {
        self.chatRoomId = chatRoomId
        self.groupPostId = groupPostId
        self.type = type
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        reactor.action.onNext(.setMembers(members))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias Reactor = ChatRightMenuReactor
    private lazy var reactor = ChatRightMenuReactor(chatRoomId: chatRoomId)
    
    private let disposeBag = DisposeBag()
    
    var willLeave: PublishRelay<Void?>?
    
    let changedMembers = PublishRelay<[ChatRoomDetailMemberModel]>()
    
    private var kickView: ChatRoomKickView?
    
    // MARK: - 디자인 요소
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 채팅방 나가기
    private let leaveButton = Button(title: String(localized: "LeaveChatRoom", table: "Chat"))
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    // 모임글 확인하기
    private let goToPostDetailCell = SettingCardCell(title: String(localized: "GoToPost", table: "Chat"), type: .button)
    private lazy var postDetailCard = SettingCard(cells: [goToPostDetailCell])
    
    // 내보내기
    private let kickCell = SettingCardCell(title: String(localized: "GoToPost", table: "Chat"), type: .button)
    private lazy var kickCard = SettingCard(cells: [kickCell])
    
    // 대화 상대
    private let memberCountLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        
        return lb
    }()
    
    private let memberCountAttributes: [NSAttributedString.Key: Any] = {
        var attributes = body16.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        return attributes
    }()
    
    private var memberCountCard: SettingCard = SettingCard(cells: [])
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        view.addSubview(topNavigationBar)
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        view.addSubview(leaveButton)
        
        leaveButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(leaveButton.snp.top)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentView.addSubview(postDetailCard)
        
        postDetailCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        goToPostDetailCell.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
    }
    
    private func configureMembersUI(members: [ChatRoomDetailMemberModel]) {
        guard let myIdString = KeyChain.shared.get(key: "USER_ID"),
              let myId = Int(myIdString) else {
            return
        }
        
        kickCard.removeFromSuperview()
        memberCountCard.removeFromSuperview()
        
        let isOwner: Bool = type == .GROUP && members.contains(where: { $0.userId == myId && $0.isOwner })
        
        if isOwner {
            contentView.addSubview(kickCard)
            
            kickCard.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalTo(postDetailCard.snp.bottom).offset(16)
            }
            
            kickCell.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
        
        contentView.addSubview(memberCountCard)
        
        memberCountCard.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(isOwner ? kickCard.snp.bottom : postDetailCard.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    private func changeMemberCells(members: [ChatRoomDetailMemberModel]) {
        guard let myIdString = KeyChain.shared.get(key: "USER_ID"),
              let myId = Int(myIdString) else {
            return
        }
        
        let localizedString: String = String(format: NSLocalizedString("MemberCount", tableName: "Chat", comment: ""), members.count)
        memberCountLabel.attributedText = NSAttributedString(string: localizedString, attributes: memberCountAttributes)
        
        let memberCells: [ChatMemberCellView] = members
            .sorted { $0.userId == myId && $1.userId != myId }
            .enumerated()
            .map { index, model in
                let isMe: String = index == 0 ? "(\(String(localized: "Me", table: "Chat"))) " : ""
                
                // TODO: 프로필 연결 기능 추가
                return ChatMemberCellView(isMe: isMe, model: model)
            }
        
        memberCountCard.update(cells: [memberCountLabel] + memberCells)
        memberCells.forEach {
            $0.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
    }
}

extension ChatRightMenuView {
    private func bind(reactor: ChatRightMenuReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: ChatRightMenuReactor) {
        goToPostDetailCell.didTap
            .map { _ in Reactor.Action.postDetailCardTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        kickCell.didTap
            .map { _ in Reactor.Action.kickCardTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        leaveButton.rx.tap
            .map { Reactor.Action.leaveChatRoomTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: ChatRightMenuReactor) {
        Observable.merge([
            reactor.state.map { $0.members },
            changedMembers.asObservable()
        ])
        .distinctUntilChanged()
        .subscribe(onNext: { [weak self] members in
            guard let self = self else { return }
            
            kickView = ChatRoomKickView(chatRoomId: chatRoomId, members: members)
            kickView?.changeMembers = changedMembers
            
            configureMembersUI(members: members)
            changeMemberCells(members: members)
        })
        .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToPostDetailId)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(
                    PostDetailView(
                        postId: groupPostId,
                        showBackButton: true,
                        showChatButton: false
                    ), animated: true
                )
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToKick)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let kickView = kickView else {
                    return
                }
                
                self.navigationController?.pushViewController(kickView, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowLeaveChatRoomAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alertView = CustomAlertView(
                    title: String(localized: "Warning", table: "Common"),
                    subTitle: String(localized: "LeaveChatRoomAlertTitle", table: "Chat"),
                    primaryTitleKey: String(localized: "LeaveChatRoom", table: "Chat"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alertView.onPrimaryTapped = {
                    self.willLeave?.accept(())
                    self.navigationController?.popViewController(animated: true)
                }
                
                alertView.onCancelTapped = {
                    
                }
                
                alertView.show(on: self)
            })
            .disposed(by: disposeBag)
    }
}
