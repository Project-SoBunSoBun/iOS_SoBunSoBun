//
//  SettleUp3rdStepView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 3/11/26.
//

import UIKit
import SnapKit
import OSLog
import RxSwift
import RxCocoa

class SettleUp3rdStepView: UIViewController {
    private let authorId: Int
    
    init(model: SettleUp3rdStepDataModel, authorId: Int) {
        reactor = SettleUp3rdStepReactor(model: model, authorId: authorId)
        
        self.authorId = authorId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias Reactor = SettleUp3rdStepReactor
    private let reactor: SettleUp3rdStepReactor
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SettleUp.SettleUp3rdStep.View"
    )
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 3/3
    private let stepLabel: UILabel = {
        var attributes = title14.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.primary400
        
        let attributedText = NSAttributedString(
            string: "3/3",
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // 제목 라벨
    private let titleLabel: UILabel = {
        var attributes = title24.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpComplete", table: "SettleUp"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // 총 정산 금액 라벨 배경
    private let subtitleBackground: UIView = {
        let v = UIView()
        v.backgroundColor = .primary50
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        
        return v
    }()
    
    // 총 정산 금액 라벨
    private let subtitleLabel = UILabel()

    // 테이블 뷰
    private let tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.backgroundColor = .clear
        tv.showsVerticalScrollIndicator = false 
        tv.register(UserSettlementTableViewCell.self, forCellReuseIdentifier: UserSettlementTableViewCell.identifier)
        tv.estimatedRowHeight = 113
        
        return tv
    }()
    
    // 저장하기 버튼
    private let saveButton = Button(title: String(localized: "SaveSettlement", table: "SettleUp"))
    
    // 로딩 화면
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        
        return view
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
        
        [topNavigationBar, stepLabel, titleLabel, subtitleBackground, tableView, saveButton, loadingView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        stepLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topNavigationBar.snp.bottom).offset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(stepLabel.snp.bottom).offset(8)
        }
        
        subtitleBackground.addSubview(subtitleLabel)
        
        subtitleBackground.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(subtitleBackground.snp.bottom).offset(16)
            make.bottom.equalTo(saveButton.snp.top).inset(16)
        }
        
        saveButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // model에서 받은 총 금액을 subtitleLabel에 표시
    private func setSubtitleLabel(totalAmount: Int) {
        let formattedAmount = numberFormatter.string(from: NSNumber(value: totalAmount)) ?? "0"
        
        let subtitleText = String.localizedStringWithFormat(
            String(localized: "TotalSettlementAmountFormat", table: "SettleUp"),
            formattedAmount
        )
        
        var attributes = title16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary400
        
        subtitleLabel.attributedText = NSAttributedString(
            string: subtitleText,
            attributes: attributes
        )
    }
}

extension SettleUp3rdStepView {
    private func bind(reactor: SettleUp3rdStepReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: SettleUp3rdStepReactor) {
        // 저장하기 버튼 클릭
        saveButton.rx.tap
            .map { Reactor.Action.saveButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SettleUp3rdStepReactor) {
        // subtitle 바인딩
        reactor.state.map { $0.model.totalAmount }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] totalAmount in
                guard let self = self else { return }
                
                self.setSubtitleLabel(totalAmount: totalAmount)
            })
            .disposed(by: disposeBag)
        
        // TableView 데이터 바인딩
        reactor.state.map { $0.sortedParticipants }
            .bind(to: tableView.rx.items(
                cellIdentifier: UserSettlementTableViewCell.identifier,
                cellType: UserSettlementTableViewCell.self
            )) { [weak self] _, item, cell in
                guard let self = self else { return }
                
                cell.selectionStyle = .none
                
                cell.configureUI(model: item, authorId: self.authorId)
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 성공 시 화면 이동
        reactor.pulse(\.$shouldNavigateToSettleUpView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                guard let navController = self.navigationController,
                      let navigationTabView = navController.viewControllers.first(where: { $0 is NavigationTabView }) as? NavigationTabView else {
                    return
                }
                
                navController.popToViewController(navigationTabView, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 실패 시 알러트
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.errorAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func errorAlert() {
        let alert = CustomAlertView(
            title: String(localized: "SettlementFailed", table: "SettleUp"),
            subTitle: String(localized: "ErrorMessage", table: "Common"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = { [weak self] in
            guard let self = self else { return }
            
            self.logger.debug("확인 버튼 클릭")
        }
        
        alert.show(on: self)
    }
}
