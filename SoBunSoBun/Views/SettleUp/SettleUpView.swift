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

class SettleUpView: UIViewController {
    typealias Reactor = SettleUpReactor
    private let reactor = SettleUpReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 타이틀
    private let titleLabel: UILabel = {
        let title = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpStart"),
            attributes: title24.attributes(alignment: .left)
        )
        title.attributedText = attributedText
        title.textColor = .neutral900
        title.textAlignment = .left
        
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
            string: String(localized: "SettleUpTableViewEmpty"),
            attributes: body18.attributes()
        )
        lb.attributedText = attributedText
        lb.textColor = .primary200
        lb.textAlignment = .center
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
        tv.estimatedRowHeight = 200
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
        
        // ViewDidLoad 액션 전달
        reactor.action.onNext(.viewDidLoad)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //        gradientLayer.frame = CGRect(
        //            x: 0,
        //            y: view.bounds.height * 0.38, // 높이 기준 38%
        //            width: view.bounds.width,
        //            height: view.bounds.height * (1 - 0.38)
        //        )
        
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [titleLabel, categoryStackView, tableView, gradientView, emptyView].forEach {
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
        allCategories.text = String(localized: "SettleUpAll")
        incompleteCategories.text = String(localized: "SettleUpIncomplete")
        completeCategories.text = String(localized: "SettleUpComplete")
        
        allCategories.isChecked = true
        
        // TableView
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(categoryStackView.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        
        // 그라데이션 뷰 - TableView 뒤에 배치
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * 0.62)
        }
        
        // gradientView를 TableView 뒤로 이동
        view.sendSubviewToBack(gradientView)
        
        emptyView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(allCategories.snp.bottom).offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(84)
        }
        
        emptyView.addSubview(tableViewEmptyDescLabel)
        view.sendSubviewToBack(emptyView)
        
        // 테이블 뷰 Empty Desc
        tableViewEmptyDescLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(85)
            make.centerY.equalToSuperview()
        }
    }
}

extension SettleUpView {
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
            .bind(to: tableView.rx.items(cellIdentifier: "SettleUpTableViewCell", cellType: SettleUpTableViewCell.self)) { index, item, cell in
                cell.configure(with: item)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        // Empty 상태 표시
        reactor.state.map { $0.items.isEmpty }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEmpty in
                self?.tableViewEmptyDescLabel.isHidden = !isEmpty
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isLoading in
                print("로딩 중: \(isLoading)")
            })
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
