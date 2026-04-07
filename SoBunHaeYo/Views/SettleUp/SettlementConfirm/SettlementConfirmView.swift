//
//  SettlementConfirmView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 3/17/26.
//

import UIKit
import SnapKit
import RxSwift
import OSLog

class SettlementConfirmView: UIViewController {
    typealias Reactor = SettlementConfirmReactor
    private let reactor: SettlementConfirmReactor
    private let notificationId: Int?
    
    init(settlementId: Int, notificationId: Int? = nil) {
        reactor = SettlementConfirmReactor(settlementId: settlementId)
        self.notificationId = notificationId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SettleUp.SettlementConfirm.View"
    )
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.title = String(localized: "SettleUpCheck", table: "SettleUp")
        
        return tnb
    }()
    
    // 총 정산 금액 라벨 배경
    private let titleBackground: UIView = {
        let v = UIView()
        v.backgroundColor = .primary50
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        
        return v
    }()
    
    // 총 정산 금액 라벨
    private let titleLabel = UILabel()
    
    // 테이블 뷰
    private let tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.backgroundColor = .clear
        tv.showsVerticalScrollIndicator = false
        tv.register(UserSettlementTableViewCell.self, forCellReuseIdentifier: UserSettlementTableViewCell.identifier)
        tv.estimatedRowHeight = 113
        
        return tv
    }()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, titleBackground, tableView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        titleBackground.addSubview(titleLabel)
        
        titleBackground.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleBackground.snp.bottom).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }
    
    // 정산 상세 조회 후 받은 총 금액을 subtitleLabel에 표시
    private func setSubtitleLabel(totalAmount: Int) {
        let formattedAmount = numberFormatter.string(from: NSNumber(value: totalAmount)) ?? "0"
        
        let titleText = String.localizedStringWithFormat(
            String(localized: "TotalSettlementAmountFormat", table: "SettleUp"),
            formattedAmount
        )
        
        var attributes = title16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary400
        
        titleLabel.attributedText = NSAttributedString(
            string: titleText,
            attributes: attributes
        )
    }
}

extension SettlementConfirmView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        reactor.action.onNext(.viewDidLoad)
        
        if let notificationId {
            reactor.action.onNext(.readNotification(notificationId))
        }
    }
    
    private func bindState(reactor: Reactor) {
        // totalAmount 바인딩
        reactor.state.compactMap { $0.item?.totalAmount }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] totalAmount in
                guard let self = self else { return }
                
                self.setSubtitleLabel(totalAmount: totalAmount)
            })
            .disposed(by: disposeBag)
        
        // tableView 데이터 바인딩
        reactor.state.map { $0.sortedParticipants }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: UserSettlementTableViewCell.identifier,
                cellType: UserSettlementTableViewCell.self
            )) { _, item, cell in
                guard let userIdString = KeyChain.shared.get(key: "USER_ID"),
                      let currentUserId = Int(userIdString) else { return }
                
                cell.configureUI(model: item, currentUserId: currentUserId)
            }
            .disposed(by: disposeBag)
        
        // 에러 알림
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
}
