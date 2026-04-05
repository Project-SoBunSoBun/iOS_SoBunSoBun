//
//  SettleUpView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 11/14/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import OSLog

class SettleUpView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SettleUp.SettleUp.View"
    )
    
    typealias Reactor = SettleUpReactor
    private let reactor = SettleUpReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 타이틀
    private let titleLabel: UILabel = {
        let title = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpStart", table: "SettleUp"),
            attributes: title24.attributes(alignment: .left)
        )
        title.attributedText = attributedText
        title.textColor = .neutral900
        
        return title
    }()
    
    // 카테고리 스택뷰
    private let categoryStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        
        return sv
    }()
    
    // 카테고리들
    private let allCategories = CalculationCategorySelectable()
    private let incompleteCategories = CalculationCategorySelectable()
    private let completeCategories = CalculationCategorySelectable()
    
    // tableViewEmptyDescLabel
    private let tableViewEmptyDescLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpTableViewEmpty", table: "SettleUp"),
            attributes: body18.attributes(alignment: .center)
        )
        lb.attributedText = attributedText
        lb.textColor = .primary200
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 테이블 뷰
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.backgroundView = nil
        tv.isOpaque = false
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.register(SettleUpTableViewCell.self, forCellReuseIdentifier: "SettleUpTableViewCell")
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 185
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84, right: 0)
        
        return tv
    }()
    
    // 그라데이션 뷰
    private let gradientView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    // 그라데이션 뷰
    private let gradientLayer: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor.primary100.withAlphaComponent(0).cgColor,
            UIColor.primary100.withAlphaComponent(1).cgColor
        ]
        gl.locations = [0,1]
        gl.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        return gl
    }()
    
    // Empty Label이 들어가는 View
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    private let refreshControl: BlueMeatballsRefreshController = {
        let rc = BlueMeatballsRefreshController()
        
        return rc
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // viewWillAppear시 액션 전달
        reactor.action.onNext(.viewWillAppear)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [titleLabel, categoryStackView, gradientView, emptyView, tableView].forEach {
            view.addSubview($0)
        }
        
        gradientView.layer.addSublayer(gradientLayer)
        
        // 타이틀 Label
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 카테고리 스택 뷰
        [allCategories, incompleteCategories, completeCategories].forEach{
            categoryStackView.addArrangedSubview($0)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        // Calculation Category
        allCategories.text = String(localized: "SettleUpAll", table: "SettleUp")
        incompleteCategories.text = String(localized: "SettleUpIncomplete", table: "SettleUp")
        completeCategories.text = String(localized: "SettleUpComplete", table: "SettleUp")
        
        allCategories.isChecked = true
        
        // 그라데이션 뷰
        gradientView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * 0.62)
        }
        
        // 비어있는 뷰
        emptyView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(allCategories.snp.bottom).offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(84)
        }
        
        emptyView.addSubview(tableViewEmptyDescLabel)
        
        // 테이블 뷰 Empty Desc
        tableViewEmptyDescLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        // TableView
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(categoryStackView.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        
        tableView.refreshControl = refreshControl
    }
}

extension SettleUpView {
    // reactor와 view 연결
    func bind(reactor: SettleUpReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    func bindAction(reactor: SettleUpReactor) {
        // 전체 카테고리 선택
        allCategories.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.categorySelected(.all) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 미완료 카테고리 선택
        incompleteCategories.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.categorySelected(.incomplete) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 완료 카테고리 선택
        completeCategories.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.categorySelected(.complete) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 새로고침
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
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
            .map { _ in Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(reactor: SettleUpReactor) {
        // 선택된 카테고리에 따라 UI 업데이트
        reactor.state.map { $0.selectedCategory }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] category in
                self?.updateCategorySelection(category)
            })
            .disposed(by: disposeBag)
        
        // TableView 데이터 바인딩
        reactor.state.map { $0.items }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: SettleUpTableViewCell.identifier, cellType: SettleUpTableViewCell.self)) { [weak self] _, item, cell in
                guard let self = self else { return }
                
                cell.configure(with: item)
                
                cell.settleUpTrigger
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        
                        self.logger.debug("정산하기 버튼 탭: id=\(item.settlementId)")
                        
                        let vc = SettleUp1stStepView(settlementId: item.settlementId, authorId: item.authorId, participants: item.participants)
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.statementCheckTrigger
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        
                        self.logger.debug("정산서 확인 버튼 탭: id=\(item.settlementId)")
                        
                        let vc = SettlementConfirmView(settlementId: item.settlementId)
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.shareTrigger
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        
                        self.logger.debug("공유 버튼 탭: id=\(item.settlementId)")
                        
                        let alert = CustomAlertView(
                            title: String(localized: "SettleUpShareConfirmTitle", table: "SettleUp"),
                            primaryTitleKey: String(localized: "Share", table: "Common"),
                            cancelTitleKey: String(localized: "Cancel", table: "Common")
                        )
                        
                        alert.onPrimaryTapped = { [weak self] in
                            guard let self = self,
                                  let chatRoomId = item.chatRoomId else {
                                return
                            }
                            
                            self.reactor.action.onNext(.sendSettlementCard(settlementId: item.settlementId, chatRoomId: chatRoomId))
                        }
                        
                        alert.show(on: self)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 선택된 카테고리에 따른 EmptyLabel 분기
        Observable.combineLatest(
            reactor.state.map { $0.items.isEmpty }.distinctUntilChanged(),
            reactor.state.map { $0.selectedCategory }.distinctUntilChanged()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] isEmpty, category in
            guard let self = self else { return }
            
            self.tableViewEmptyDescLabel.isHidden = !isEmpty
            guard isEmpty else { return }
            
            switch category {
            case .all, .incomplete:
                self.tableViewEmptyDescLabel.attributedText = NSAttributedString(
                    string: String(localized: "SettleUpTableViewEmpty", table: "SettleUp"),
                    attributes: body18.attributes(alignment: .center)
                )
            case .complete:
                self.tableViewEmptyDescLabel.attributedText = NSAttributedString(
                    string: String(localized: "SettleUpTableViewCompleteEmpty", table: "SettleUp"),
                    attributes: body18.attributes(alignment: .center)
                )
            }
        })
        .disposed(by: disposeBag)
        
        // 정산서 공유 성공
        reactor.pulse(\.$showShareSucceedAlert)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let alert = CustomAlertView(
                    title: String(localized: "SettleUpShareSuccessMessage", table: "SettleUp"),
                    primaryTitleKey: String(localized: "Confirm", table: "Common")
                )
                
                alert.show(on: self)
            })
            .disposed(by: disposeBag)
        
        // 새로고침
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    }
    
    private func updateCategorySelection(_ category: SettleUpCategory) {
        allCategories.isChecked = (category == .all)
        incompleteCategories.isChecked = (category == .incomplete)
        completeCategories.isChecked = (category == .complete)
    }
}

// 미리보기
#if DEBUG
import SwiftUI

struct SettleUpViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            SettleUpView()
        }
    }
}
#endif
