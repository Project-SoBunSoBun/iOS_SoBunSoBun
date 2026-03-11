//
//  SettleUpView.swift
//  SoBunSoBun
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
        subsystem: "SoBunSoBun",
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
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
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
    }
}

extension SettleUpView {
    func bind(reactor: SettleUpReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    func bindAction(reactor: SettleUpReactor) {
        // viewDidLoad시 액션 전달
        reactor.action.onNext(.viewDidLoad)
        
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
            .bind(to: tableView.rx.items(cellIdentifier: "SettleUpTableViewCell", cellType: SettleUpTableViewCell.self)) { [weak self] index, item, cell in
                guard let self = self else { return }
                
                cell.selectionStyle = .none
                
                cell.configure(with: item)
                
                cell.deleteTrigger
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        
                        self.logger.debug("삭제 버튼 탭: id=\(item.settlementId)")
                        self.showDeleteAlert(id: item.settlementId)
                    })
                    .disposed(by: cell.disposeBag)
                
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
                        // TODO: 정산서 이동 로직
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.shareTrigger
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        
                        self.logger.debug("공유 버튼 탭: id=\(item.settlementId)")
                        // TODO: 공유 기능 로직
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                
                self.logger.debug("로딩 중: \(isLoading)")
            })
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
    }
    
    private func updateCategorySelection(_ category: SettleUpCategory) {
        allCategories.isChecked = (category == .all)
        incompleteCategories.isChecked = (category == .incomplete)
        completeCategories.isChecked = (category == .complete)
    }
    
    // 삭제 알림창
    private func showDeleteAlert(id: Int) {
        let alert = CustomAlertView(
            title: String(localized: "SettleUpDeleteMessage1st", table: "SettleUp"),
            subTitle: String(localized: "SettleUpDeleteMessage2nd", table: "SettleUp"),
            primaryTitleKey: String(localized: "Delete", table: "Common"),
            cancelTitleKey: String(localized: "Cancel", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.reactor.action.onNext(.deleteSettleUpTapped(id: id))
        }
        
        alert.onCancelTapped = {
            self.logger.debug("취소됨")
        }
        
        alert.show(on: self)
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
