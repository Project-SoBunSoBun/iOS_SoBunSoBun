//
//  ChatRateMannerView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatRateMannerView: UIViewController {
    private let groupPostId: Int
    
    init(
        groupPostId: Int,
        members: [ChatRoomDetailMemberModel],
        nibName nibNameOrNil: String? = nil,
        bundle nibBundleOrNil: Bundle? = nil
    ) {
        self.groupPostId = groupPostId
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        reactor.action.onNext(.setMembers(members))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()
    
    typealias Reactor = ChatRateMannerReactor
    private lazy var reactor = ChatRateMannerReactor(groupPostId: groupPostId)
    
    // MARK: - 디자인 요소
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.onBackButtonTapped = {
            let alert = CustomAlertView(
                title: String(localized: "SkipRateMannersAlertTitle", table: "Chat"),
                subTitle: String(localized: "SkipRateMannersAlertSubTitle", table: "Chat"),
                primaryTitleKey: String(localized: "SkipRateMannersAlertPrimary", table: "Chat"),
                cancelTitleKey: String(localized: "SkipRateMannersAlertCancel", table: "Chat")
            )
            
            alert.onPrimaryTapped = {
                
            }
            
            alert.onCancelTapped = {
                self.reactor.action.onNext(.skipTapped)
            }
            
            alert.show(on: self)
        }
        
        tnb.title = String(localized: "RateManners", table: "Chat")
        
        return tnb
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let contentView: UIView = UIView()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .top
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 0, bottom: 16, right: 0)
        
        return sv
    }()
    
    private let button: Button = Button(title: String(localized: "RateDone", table: "Chat"))
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, button, scrollView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        button.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(button.snp.top)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview()
        }
    }
}

extension ChatRateMannerView {
    private func bind(reactor: ChatRateMannerReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: ChatRateMannerReactor) {
        button.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "ConfirmRateMannerTitle", table: "Chat"),
                    subTitle: String(localized: "ConfirmRateMannerSubTitle", table: "Chat"),
                    primaryTitleKey: String(localized: "Rate", table: "Chat"),
                    cancelTitleKey: String(localized: "Cancel", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    let manners = self.getRatedManners()
                    reactor.action.onNext(.rateMannersButtonTapped(manners))
                }
                
                alert.onCancelTapped = {
                    
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: ChatRateMannerReactor) {
        reactor.state.map { $0.members }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] members in
                guard let self = self else { return }
                
                guard let url = Bundle.main.url(forResource: "Chat", withExtension: "xcstrings"),
                         let data = try? Data(contentsOf: url),
                         let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                         let reviews = json["strings"] as? [String: Any] else {
                       return
                   }
                
                members.forEach {
                    let view = ChatMannerExpandableView(model: $0)
                    
                    let reviewViews = reviews.keys.map {
                        let reviewView = Review(number: String($0.suffix(3)))
                        reviewView.isUserInteractionEnabled = true
                        
                        return reviewView
                    }
                    
                    view.reviewsView.addArrangedSubviews(reviewViews)
                    
                    self.stackView.addArrangedSubview(view)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isDone)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "RateMannersDone", table: "Chat"),
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.onPrimaryTapped = {
                    self.navigationController?.popViewController(animated: true)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPop)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.popViewController(animated: true)
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
                    self.navigationController?.popViewController(animated: true)
                }
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
    }
    
    private func getRatedManners() -> [[String]] {
        let extendableViews: [ChatMannerExpandableView] = stackView.arrangedSubviews.compactMap { $0 as? ChatMannerExpandableView }
        let reviewsView: [[Review]] = extendableViews.map { view in
            view.reviewsView.subviews.compactMap { $0 as? Review }
        }
        let manners: [[String]] = reviewsView.map { view in
            view
                .filter { $0.isSelected }
                .map { $0.number }
        }
        
        return manners
    }
}
