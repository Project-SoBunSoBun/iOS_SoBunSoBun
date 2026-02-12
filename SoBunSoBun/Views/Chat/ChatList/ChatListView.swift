//
//  ChatListView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/24/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatListView: UIViewController {
    typealias Reactor = ChatListReactor
    private let reactor = ChatListReactor()
    
    private let disposeBag = DisposeBag()
    
    // 외부 이벤트 전달
    let shouldShowUnread = PublishRelay<Void>()
    
    // MARK: - 디자인 요소
    private let titleLabel: UILabel = {
        let lb = UILabel()
        var attributes: [NSAttributedString.Key: Any] = title20.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        lb.attributedText = NSAttributedString(string: String(localized: "Chat", table: "Common"), attributes: attributes)
        
        return lb
    }()
    
    private let buttonScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        
        return sv
    }()
    
    private let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
        
        return sv
    }()
    
    private let privateChatString: String = String(localized: "PrivateChat", table: "Chat")
    private lazy var privateChatButton: ChatCategoryButton = {
        let btn = ChatCategoryButton()
        btn.title = privateChatString
        btn.isSelected = true
        
        return btn
    }()
    
    private let groupChatString: String = String(localized: "GroupChat", table: "Chat")
    private lazy var groupChatButton: ChatCategoryButton = {
        let btn = ChatCategoryButton()
        btn.title = groupChatString
        
        return btn
    }()
    
    private let privateChatTableView: UITableView = {
        let tv = UITableView()
        tv.register(ChatListCellTableViewCell.self, forCellReuseIdentifier: ChatListCellTableViewCell.identifier)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.estimatedRowHeight = 70
        tv.rowHeight = UITableView.automaticDimension
        tv.contentInset = .init(
            top: 0,
            left: 0,
            bottom: 8 + BottomNavigationBar.SHADOW_HEIGHT + 8 + 8,
            right: 0
        )
        tv.minimumZoomScale = 1.0
        tv.maximumZoomScale = 1.0
        tv.pinchGestureRecognizer?.isEnabled = false
        tv.isHidden = false
        
        return tv
    }()
    
    private let groupChatTableView: UITableView = {
        let tv = UITableView()
        tv.register(ChatListCellTableViewCell.self, forCellReuseIdentifier: ChatListCellTableViewCell.identifier)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.estimatedRowHeight = 70
        tv.rowHeight = UITableView.automaticDimension
        tv.contentInset = .init(
            top: 0,
            left: 0,
            bottom: 8 + BottomNavigationBar.SHADOW_HEIGHT + 8 + 8,
            right: 0
        )
        tv.minimumZoomScale = 1.0
        tv.maximumZoomScale = 1.0
        tv.pinchGestureRecognizer?.isEnabled = false
        tv.isHidden = true
        
        return tv
    }()
    
    private lazy var gradientLayer = BackgroundGradientLayer(view)
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        view.layer.addSublayer(gradientLayer)
        
        [titleLabel, buttonScrollView, privateChatTableView, groupChatTableView].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
        }
        
        buttonScrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.greaterThanOrEqualTo(44)
        }
        
        [privateChatButton, groupChatButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        buttonScrollView.addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        
        privateChatTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(buttonScrollView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalToSuperview()
        }
        
        groupChatTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(buttonScrollView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalToSuperview()
        }
    }
}

extension ChatListView {
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        reactor.action.onNext(.viewDidLoad)
        
        [privateChatButton, groupChatButton].enumerated().forEach { index, button in
            button.rx.tap
                .map { Reactor.Action.tabButtonTapped(index) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
    }
    
    private func bindState(reactor: Reactor) {
        reactor.state.map { $0.tabIndex }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                
                privateChatTableView.isHidden = index != 0
                groupChatTableView.isHidden = index != 1
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(index: Int) {
        privateChatTableView.isHidden = index != 0
        groupChatTableView.isHidden = index != 1
    }
}

#if DEBUG
// 미리보기
import SwiftUI

struct ChatListViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            ChatListView()
        }
    }
}
#endif
