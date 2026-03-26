//
//  ChatRoomKickView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatRoomKickView: UIViewController {
    private let chatRoomId: Int
    
    var changeMembers: PublishRelay<[ChatRoomDetailMemberModel]>?
    
    typealias Reactor = ChatRoomKickReactor
    private lazy var reactor = ChatRoomKickReactor(chatRoomId: chatRoomId)
    
    private let disposeBag = DisposeBag()
    
    init(
        chatRoomId: Int,
        members: [ChatRoomDetailMemberModel],
        nibName nibNameOrNil: String? = nil,
        bundle nibBundleOrNil: Bundle? = nil
    ) {
        self.chatRoomId = chatRoomId
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        reactor.action.onNext(.setMembers(members))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.title = String(localized: "KickMembers", table: "Chat")
        
        return tnb
    }()
    
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
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        
        return sv
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        changeMembers?.accept(reactor.currentState.members)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        view.addSubview(topNavigationBar)
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    private func changeMemberCells(members: [ChatRoomDetailMemberModel]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        guard let myIdString = KeyChain.shared.get(key: "USER_ID"),
              let myId = Int(myIdString) else {
            return
        }
        
        members
            .filter { $0.userId != myId }
            .forEach { model in
                // TODO: 프로필 연결 기능 추가
                let cellView = ChatMemberKickCellView(model: model)
                let card = SettingCard(cells: [cellView])
                
                cellView.cancelButton.rx.tap
                    .map { Reactor.Action.kickButtonTapped(model.userId) }
                    .bind(to: reactor.action)
                    .disposed(by: disposeBag)
                
                stackView.addArrangedSubview(card)
            }
    }
}

extension ChatRoomKickView {
    private func bind(reactor: ChatRoomKickReactor) {
        bindState(reactor: reactor)
    }
    
    private func bindState(reactor: ChatRoomKickReactor) {
        reactor.state.map { $0.members }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] members in
                guard let self = self else { return }
                
                changeMemberCells(members: members)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowKickAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alertView = CustomAlertView(
                    title: String(localized: "Warning", table: "Common"),
                    subTitle: String(localized: "KickMemberAlertTitle", table: "Chat"),
                    primaryTitleKey: String(localized: "Kick", table: "Chat"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alertView.onPrimaryTapped = {
                    reactor.action.onNext(.kickAccepted)
                }
                
                alertView.onCancelTapped = {
                    
                }
                
                alertView.show(on: self)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowKickDoneAlert)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alertView = CustomAlertView(
                    title: String(localized: "KickMemberDoneAlertTitle", table: "Chat"),
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alertView.onPrimaryTapped = {
                    
                }
                
                alertView.show(on: self)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
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
}
