//
//  ChatView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/15/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import OSLog

class ChatView: BaseViewController {
    private let chatRoomId: Int
    
    private let willLeave = PublishRelay<Void?>()
    
    init(chatRoomId: Int, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.chatRoomId = chatRoomId
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Chat.Chat.View"
    )
    
    typealias Reactor = ChatReactor
    private lazy var reactor = ChatReactor(chatRoomId: chatRoomId)
    
    private let disposeBag = DisposeBag()
    
    private var rightMenuView: ChatRightMenuView?
    
    // MARK: - 디자인 요소
    private lazy var gradientLayer = BackgroundGradientLayer(view)
    
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.onBackButtonTapped = {
            guard let navController = self.navigationController,
                  let navigationTabView = navController.viewControllers.first(where: { $0 is NavigationTabView }) as? NavigationTabView else {
                return
            }
            
            navController.popToViewController(navigationTabView, animated: true)
        }
        tnb.backgroundColor = .backgroundWhite.withAlphaComponent(0.95)
        
        return tnb
    }()
    
    private let rightMenuButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .blackHorizontalDot.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.background.backgroundColor = .clear
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // safearea 그라데이션 미적용
    private let safeareaBottomBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    private let chatStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.backgroundColor = .backgroundWhite
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        return sv
    }()
    
    // 커스텀 메뉴 버튼
    private let plusButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = .lightbluePlus.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 5.5, leading: 5.5, bottom: 5.5, trailing: 5.5)
        config.background.backgroundColor = .primary100
        config.background.cornerRadius = 35 / 2
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // 채팅 textView
    private let chatTextView: AutoHeightTextView = {
        let ahtv = AutoHeightTextView(minHeight: 41, maxHeight: 83, maxLength: 140, fontStyle: body14)
        ahtv.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        ahtv.placeholder = String(localized: "SendMessage", table: "Chat")
        ahtv.showCharactersCount = false
        ahtv.backgroundColor = .neutral100
        ahtv.layer.cornerRadius = 16
        ahtv.clipsToBounds = true
        
        return ahtv
    }()
    
    // 전송 버튼
    private let sendButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .lightBluePointer.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // 채팅 tableview
    private lazy var tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return tv
    }()
    
    // 커스텀 하단 메뉴
    private let bottomMenuView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        view.frame = .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
        
        return view
    }()
    
    private let bottomMenuStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .center
        sv.backgroundColor = .backgroundWhite
        sv.isLayoutMarginsRelativeArrangement = true
        
        return sv
    }()
    
    private let sendImageButton = ChatBottomMenuButton(image: .blueImageIcon, text: String(localized: "SendPicture", table: "Chat"))
    private let sendInvitationButton = ChatBottomMenuButton(image: .blueMail, text: String(localized: "SendInvitation", table: "Chat"))
    private let checkPostButton = ChatBottomMenuButton(image: .blueDocument, text: String(localized: "CheckPost", table: "Chat"))
    private let sendSettlementButton = ChatBottomMenuButton(image: .blueReceipt, text: String(localized: "SendSettlement", table: "Chat"))
    private let confirmSettlementButton = ChatBottomMenuButton(image: .blueReceipt, text: String(localized: "ConfirmSettlement", table: "Chat"))
    
    private lazy var imagePicker = {
        let picker = CustomImagePicker(presentingViewController: self, selectionMode: .single)
        picker.allowEditing = false
        
        return picker
    }()
    
    // chat longtap dropDown
    private let chatCellMenuDropDownView: DropDownView = {
        let ddv = DropDownView(selectionMode: .plain, tableName: "Chat")
        ddv.textAlignment = .center
        
        return ddv
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset = .init(top: 0, left: 0, bottom: topNavigationBar.frame.height, right: 0)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        bottomMenuView.frame.size.height = 258 + view.safeAreaInsets.bottom
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        chatTextView.textView.inputView = nil
        reactor.action.onNext(.readLastChat)
        reactor.action.onNext(.disconnectChatRoom)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.layer.addSublayer(gradientLayer)
        
        [chatStackView, safeareaBottomBackgroundView, tableView, topNavigationBar, chatCellMenuDropDownView].forEach {
            view.addSubview($0)
        }
        
        [plusButton, chatTextView, sendButton].forEach {
            chatStackView.addArrangedSubview($0)
        }
        
        chatStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        sendButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        plusButton.setContentHuggingPriority(.required, for: .horizontal)
        plusButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        chatTextView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        chatTextView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        sendButton.setContentHuggingPriority(.required, for: .vertical)
        sendButton.setContentCompressionResistancePriority(.required, for: .vertical)
        
        safeareaBottomBackgroundView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(chatStackView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(chatStackView.snp.top)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 하단 메뉴
        bottomMenuView.addSubview(bottomMenuStackView)
        
        bottomMenuStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
}

extension ChatView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        // 오른쪽 메뉴 버튼
        rightMenuButton.rx.tap
            .map { Reactor.Action.rightMenuButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 채팅방 나가기
        willLeave
            .compactMap { $0 }
            .map { Reactor.Action.leaveChatRoom }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 메시지 전송
        sendButton.rx.tap
            .withLatestFrom(chatTextView.rx.text.orEmpty)
            .map { Reactor.Action.sendMessage($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 하단 메뉴 버튼
        plusButton.rx.tap
            .map { Reactor.Action.bottomMenuTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 이미지 전송 버튼
        sendImageButton.rx.tap
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                
                _ = self.chatTextView.textView.resignFirstResponder()
            })
            .map { Reactor.Action.showImagePicker }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 초대장 전송 버튼
        sendInvitationButton.rx.tap
            .withLatestFrom(
                reactor.state.map { $0.detailInfoModel }
                    .compactMap { $0 }
            )
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                _ = self.chatTextView.textView.resignFirstResponder()
                
                let alert = CustomAlertView(
                    title: String(localized: "SendInvitationAlertTitle", table: "Chat"),
                    subTitle: String(localized: "SendInvitationAlertSubTitle", table: "Chat"),
                    primaryTitleKey: String(localized: "SendInvitation", table: "Chat"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    reactor.action.onNext(.sendInviteCard)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 정산서 전송 버튼
        sendSettlementButton.rx.tap
            .withLatestFrom(
                reactor.state.map { $0.detailInfoModel }
                    .compactMap { $0 }
            )
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                _ = self.chatTextView.textView.resignFirstResponder()
                
                let alert = CustomAlertView(
                    title: String(localized: "SendSettlementConfirmAlertTitle", table: "Chat"),
                    subTitle: String(localized: "SendSettlementConfirmAlertSubTitle", table: "Chat"),
                    primaryTitleKey: String(localized: "SendSettlement", table: "Chat"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    if let settlementId = model.data?.settlementId {
                        reactor.action.onNext(.sendSettlementCard(settlementId))
                    } else {
                        self.showNotSettledYetForOwnerAlert()
                    }
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 게시글 확인 버튼
        checkPostButton.rx.tap
            .withLatestFrom(
                reactor.state.map { $0.detailInfoModel }
                    .compactMap { $0 }
            )
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                guard let data = model.data else { return }
                
                _ = self.chatTextView.textView.resignFirstResponder()
                
                let sheetView = PostDetailView(
                    postId: data.groupPostId,
                    showBackButton: false,
                    showChatButton: false
                )
                let bottomSheet = BottomSheetView(
                    contentViewController: sheetView,
                    height: 0.88,
                    cornerRadius: 24
                )
                
                self.present(bottomSheet, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 정산서 확인 버튼
        confirmSettlementButton.rx.tap
            .withLatestFrom(
                reactor.state.map { $0.detailInfoModel }
                    .compactMap { $0 }
            )
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                guard let data = model.data else { return }
                
                _ = self.chatTextView.textView.resignFirstResponder()
                
                if let settlementId = data.settlementId {
                    self.navigationController?.pushViewController(SettlementConfirmView(settlementId: settlementId), animated: true)
                } else {
                    let alert = CustomAlertView(
                        title: String(localized: "NotSettledYetForMemberAlertTitle", table: "Chat"),
                        subTitle: String(localized: "NotSettledYetForMemberAlertSubTitle", table: "Chat"),
                        primaryTitleKey: String(localized: "Confirm", table: "Common")
                    )
                    
                    alert.show(on: self)
                }
            })
            .disposed(by: disposeBag)
        
        // 클립보드 이미지 붙여넣기
        chatTextView.textView.imagePasted
            .emit(onNext: { [weak self] image in
                guard let self = self else { return }
                
                let confirmVC = ImagePickerConfirmView(image: image)
                
                confirmVC.onConfirm
                    .take(1)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        self?.reactor.action.onNext(.sendImage(image))
                    })
                    .disposed(by: confirmVC.disposeBag)
                
                self.present(confirmVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 채팅 페이지네이션
        tableView.rx.willDisplayCell
            .filter { [weak self] _, indexPath -> Bool in
                guard let self = self else { return false }
                
                let lastRow = self.tableView.numberOfRows(inSection: 0) - 1
                
                return self.tableView.isDragging && indexPath.row >= lastRow - 10
            }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.getMoreMessages }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 채팅 상호작용 메뉴
        chatCellMenuDropDownView
            .didCellTap
            .subscribe(onNext: { [weak self] menu in
                guard let self = self else { return }
                
                let currentState = reactor.currentState
                let selectedMessageModel = currentState.selectedChatMessageModel
                
                switch menu {
                case "Copy":
                    guard let content = selectedMessageModel?.content else {
                        return
                    }
                    
                    UIPasteboard.general.string = content
                    
                default:
                    logger.fault("chatCellLongTappedMenuDropDownView의 didCellTap의 case에서 등록되지 않은 메뉴가 있음: \(menu)")
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ChatMessageModel.self)
            .map { Reactor.Action.setSelectedChatMessageModel($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.merge([
            tableView.rx.didZoom.map { _ in },
            tableView.rx.didScroll.map { _ in }
        ])
        .subscribe(onNext: { _ in
            reactor.action.onNext(.chatLongPressed(false))
        })
        .disposed(by: disposeBag)
        
        view.rx
            .tapGesture(configuration: { gesture, delegate in
                gesture.cancelsTouchesInView = false
                
                delegate.otherFailureRequirementPolicy = .custom { _, otherGesture in
                    // longPress가 활성화 중이면 tap 제스처 실패 처리
                    return otherGesture is UILongPressGestureRecognizer
                }
            })
            .when(.recognized)
            .subscribe(onNext: { _ in
                if reactor.currentState.isChatCellMenuOpen {
                    reactor.action.onNext(.chatLongPressed(false))
                } else {
                    reactor.action.onNext(.backToKeyboard)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        reactor.state.map { $0.detailInfoModel }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                guard let data = model.data else { return }
                
                // 제목, 메뉴 설정
                topNavigationBar.title = data.roomName
                topNavigationBar.buttons = [rightMenuButton]
                
                rightMenuView = ChatRightMenuView(
                    chatRoomId: chatRoomId,
                    groupPostId: data.groupPostId,
                    type: data.roomType,
                    members: data.members
                )
                rightMenuView?.willLeave = willLeave
                
                bottomMenuStackView.arrangedSubviews.forEach {
                    self.bottomMenuStackView.removeArrangedSubview($0)
                    $0.removeFromSuperview()
                }
                
                guard let myIdString = KeyChain.shared.get(key: "USER_ID"),
                      let myId = Int(myIdString) else {
                    return
                }
                
                bottomMenuStackView.addArrangedSubview(sendImageButton)
                
                sendImageButton.snp.makeConstraints { make in
                    make.horizontalEdges.equalToSuperview()
                    make.height.equalTo(88)
                }
                
                if data.ownerId == myId {
                    if data.roomType == .ONE_TO_ONE {
                        bottomMenuStackView.addArrangedSubview(sendInvitationButton)
                        sendInvitationButton.snp.makeConstraints { make in
                            make.horizontalEdges.equalToSuperview()
                            make.height.equalTo(88)
                        }
                    } else if data.roomType == .GROUP {
                        bottomMenuStackView.addArrangedSubview(sendSettlementButton)
                        sendSettlementButton.snp.makeConstraints { make in
                            make.horizontalEdges.equalToSuperview()
                            make.height.equalTo(88)
                        }
                    }
                } else {
                    if data.roomType == .ONE_TO_ONE {
                        bottomMenuStackView.addArrangedSubview(checkPostButton)
                        checkPostButton.snp.makeConstraints { make in
                            make.horizontalEdges.equalToSuperview()
                            make.height.equalTo(88)
                        }
                    } else if data.roomType == .GROUP {
                        bottomMenuStackView.addArrangedSubview(confirmSettlementButton)
                        confirmSettlementButton.snp.makeConstraints { make in
                            make.horizontalEdges.equalToSuperview()
                            make.height.equalTo(88)
                        }
                    }
                }
                
                // 방장만 정산 후 자동 매너 평가 뷰 이동
                if data.ownerId == myId && data.isSettled && data.isReviewed == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.navigationController?.pushViewController(
                            ChatRateMannerView(
                                groupPostId: data.groupPostId,
                                members: data.members
                            ), animated: true
                        )
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 메시지
        reactor.state.map { $0.messages }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: ChatTableViewCell.identifier, cellType: ChatTableViewCell.self)) { index, model, cell in
                // 하루 중 첫 채팅 표시 여부
                let messages = reactor.currentState.messages
                let previousMessage = index + 1 < messages.count ? messages[index + 1] : nil
                
                let isFirstChatOfDay: Bool
                
                if index == messages.count - 1 { // 첫 메시지일 때
                    isFirstChatOfDay = true
                } else if let previousMessage = previousMessage,
                          let prevDate = ISO8601ToDate(previousMessage.createdAt),
                          let currentDate = ISO8601ToDate(model.createdAt) {
                    isFirstChatOfDay = !Calendar.current.isDate(prevDate, inSameDayAs: currentDate)
                } else { // nil 처리
                    isFirstChatOfDay = false
                }
                
                guard let myIdString = KeyChain.shared.get(key: "USER_ID"),
                      let myId = Int(myIdString) else {
                    return
                }
                
                let isMine: Bool = myId == model.userId
                
                cell.configureUI(model: model, isMine: isMine, isFirstChatOfDay: isFirstChatOfDay)
                
                // 이미지 비동기 로드 시 스크롤 아래로
                cell.didImageLoad
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: {
                        if self.isScrollNearBottom() {
                            self.scrollToBottom()
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.didTextLongPressed
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] chatCellView in
                        guard let self = self,
                              model.type == .TEXT else {
                            return
                        }
                        
                        chatCellMenuDropDownView.items = ["Copy"]
                        
                        // 버튼 좌표 변환
                        let chatCellViewFrame = chatCellView.convert(chatCellView.bounds, to: view)
                        
                        // 드롭다운 높이: 항목 수 × 셀 높이
                        let dropdownHeight = CGFloat(chatCellMenuDropDownView.items.count) * chatCellMenuDropDownView.cellHeight
                        
                        // 입력 영역 위까지 남은 공간
                        let availableSpaceBelow = chatStackView.frame.minY - chatCellViewFrame.maxY
                        let shouldOpenUpward = dropdownHeight > availableSpaceBelow
                        
                        if isMine {
                            chatCellMenuDropDownView.animationAnchor = shouldOpenUpward ? .bottomRight : .topRight
                        } else {
                            chatCellMenuDropDownView.animationAnchor = shouldOpenUpward ? .bottomLeft : .topLeft
                        }
                        
                        chatCellMenuDropDownView.snp.remakeConstraints { make in
                            if isMine {
                                make.trailing.equalTo(self.view.snp.leading).offset(chatCellViewFrame.maxX)
                            } else {
                                make.leading.equalTo(self.view.snp.leading).offset(chatCellViewFrame.minX)
                            }
                            
                            if shouldOpenUpward {
                                make.bottom.equalTo(self.view.snp.top).offset(chatCellViewFrame.minY)
                            } else {
                                make.top.equalToSuperview().offset(chatCellViewFrame.maxY + 4)
                            }
                            
                            make.width.equalTo(70)
                        }
                        
                        // z-order 재설정
                        view.bringSubviewToFront(chatCellMenuDropDownView)
                        
                        let currentState = reactor.currentState
                        let isSameChatId = currentState.selectedChatMessageModel?.id == model.id
                        let shouldChatCellMenuOpen = !(currentState.isChatCellMenuOpen && isSameChatId)
                        
                        reactor.action.onNext(.setSelectedChatMessageModel(model))
                        reactor.action.onNext(.chatLongPressed(shouldChatCellMenuOpen))
                    })
                    .disposed(by: cell.disposeBag)
                
                // 이미지 미리보기
                cell.didImageTapped
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] image in
                        guard let self = self,
                              let image = image,
                              model.type == .IMAGE else {
                            return
                        }
                        
                        let vc = ImageDetailView(image: image)
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                    .disposed(by: cell.disposeBag)
                
                // 단체 채팅방 초대 수락
                cell.didInviteCardButtonTapped
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] inviteId in
                        guard let self = self else { return }
                        
                        let alert = CustomAlertView(
                            title: String(localized: "ConfirmAcceptGroupChatRoomAlertTitle", table: "Chat"),
                            subTitle: String(localized: "ConfirmAcceptGroupChatRoomAlertTitle", table: "Chat"),
                            primaryTitleKey: String(localized: "Confirm", table: "Chat"),
                            cancelTitleKey: String(localized: "Cancel", table: "Common")
                        )
                        
                        alert.onPrimaryTapped = {
                            reactor.action.onNext(.acceptGroupChatRoom(inviteId))
                        }
                        
                        alert.show(on: self)
                    })
                    .disposed(by: cell.disposeBag)
                
                // 정산서 확인 버튼 누름
                cell.didSettlementCardButtonTapped
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] settlementId in
                        guard let self = self else { return }
                        
                        self.navigationController?.pushViewController(SettlementConfirmView(settlementId: settlementId), animated: true)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 메시지 첫 표시할 때 스크롤 아래로
        reactor.state.map { $0.messages }
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.scrollToBottom()
                }
            })
            .disposed(by: disposeBag)
        
        // 메시지 표시될 때마다 스크롤이 맨하단 근처에 있다면 아래로
        reactor.state.map { $0.messages }
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if self.isScrollNearBottom() {
                        self.scrollToBottom()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 메뉴 뷰로 이동
        reactor.pulse(\.$shouldNavigateToRightMenu)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let rightMenuView = rightMenuView else {
                    return
                }
                
                self.navigationController?.pushViewController(rightMenuView, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 텍스트 전송 성공
        reactor.pulse(\.$sendSucceed)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                chatTextView.text = ""
            })
            .disposed(by: disposeBag)
        
        // 하단 메뉴 표시
        reactor.state.map { $0.isOpenBottomMenu }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isBottomMenu in
                guard let self = self else { return }
                
                chatTextView.textView.inputView = isBottomMenu ? bottomMenuView : nil
                
                if chatTextView.textView.isFirstResponder {
                    chatTextView.textView.reloadInputViews()
                } else if isBottomMenu { // 키보드가 닫혀있으면 메뉴를 열음
                    _ = chatTextView.textView.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        // 이미지 선택 완료
        imagePicker.imageSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                
                logger.debug("이미지 선택")
                reactor.action.onNext(.sendImage(image))
            })
            .disposed(by: disposeBag)
        
        // 이미지 선택 취소
        imagePicker.cancelled
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("이미지 선택 취소됨")
            })
            .disposed(by: disposeBag)
        
        // 이미지 피커 표시
        reactor.pulse(\.$shouldShowImagePicker)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.imagePicker.checkPhotoLibraryPermission()
            })
            .disposed(by: disposeBag)
        
        // 채팅 메뉴 표시 여부
        reactor.state.map { $0.isChatCellMenuOpen }
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                tableView.isScrollEnabled = !isOpen
                chatCellMenuDropDownView.setOpen(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        // 그룹 채팅방 이동
        reactor.pulse(\.$shouldNavigateToGroupChatRoom)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] groupChatRoomId in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(ChatView(chatRoomId: groupChatRoomId), animated: true)
            })
            .disposed(by: disposeBag)
        
        // 채팅방 나가기
        reactor.pulse(\.$shouldNavigateToBack)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 오류 메시지
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        // 심각한 오류 발생 시 채팅 이용 불가
        reactor.pulse(\.$criticalErrorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.showCriticalErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func isScrollNearBottom() -> Bool {
        return tableView.contentOffset.y < 300
    }
    
    private func scrollToBottom() {
        tableView.layoutIfNeeded()
        
        guard tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    // 정산이 완료되지 않을 상태로 정산서 보내기를 시도할 때
    private func showNotSettledYetForOwnerAlert() {
        let alert = CustomAlertView(
            title: String(localized: "NotSettledYetForOwnerAlertTitle", table: "Chat"),
            subTitle: String(localized: "NotSettledYetForOwnerAlertSubTitle", table: "Chat"),
            primaryTitleKey: String(localized: "GoToSettlementTab", table: "Chat"),
            cancelTitleKey: String(localized: "Cancel", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            guard let navController = self.navigationController,
                  let navigationTabView = navController.viewControllers.first(where: { $0 is NavigationTabView }) as? NavigationTabView else {
                return
            }
            
            navController.popToViewController(navigationTabView, animated: true)
        }
        
        alert.show(on: self)
    }
}
