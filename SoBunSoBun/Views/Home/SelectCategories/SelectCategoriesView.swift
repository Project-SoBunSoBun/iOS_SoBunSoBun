//
//  SelectCategoriesView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/14/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import OSLog

class SelectCategoriesView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SelectCategories.View"
    )
    
    typealias Reactor = SelectCategoriesReactor
    private let reactor: SelectCategoriesReactor
    
    let selectedCategoriesRelay = PublishRelay<[String]>()
    
    private let disposeBag = DisposeBag()
    
    init(selectedCategories: [String]) {
        self.reactor = SelectCategoriesReactor(selectedCategories: selectedCategories)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let scrollView: UIScrollView = UIScrollView()
    
    private func groupTitleLabel() -> UILabel {
        let lb = UILabel()
        lb.font = title18.font
        lb.textColor = .neutral900
        
        return lb
    }
    
    private var wrappingViews: [LabelsWrappingView<CategorySelectable>] = []
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        selectedCategoriesRelay.accept(reactor.currentState.selectedCategories)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.addSubview(scrollView)
        
        view.backgroundColor = .backgroundWhite
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SelectCategoriesView {
    private func bind(reactor: SelectCategoriesReactor) {
        bindState(reactor: reactor)
    }
    
    private func bindState(reactor: SelectCategoriesReactor) {
        // groups state를 먼저 호출한 다음 Action 실행
        reactor.state.map { $0.groups }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] groups in
                guard let self = self else { return }
                
                setupCategoryGroups(groups)
                bindAction(reactor: reactor)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedCategories }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] categories in
                guard let self = self else { return }
                
                updateSelectedCategories(categories)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: SelectCategoriesReactor) {
        // 모든 wrappingView의 선택 이벤트를 구독
        Observable.merge(wrappingViews.map { $0.selectedCategory.asObservable() })
            .map { Reactor.Action.toggleCategory($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setupCategoryGroups(_ groups: [String]) {
        var previousView: UIView? = nil
        
        groups.enumerated().forEach { index, groupNumber in
            // 그룹 레이블 생성
            let groupLabel = UILabel()
            groupLabel.font = title18.font
            groupLabel.textColor = .neutral900
            groupLabel.text = NSLocalizedString("CategoryGroup\(groupNumber)", comment: "")
            
            scrollView.addSubview(groupLabel)
            
            groupLabel.snp.makeConstraints { make in
                if let previous = previousView {
                    make.top.equalTo(previous.snp.bottom).offset(48)
                } else {
                    make.top.equalToSuperview().offset(32)
                }
                make.horizontalEdges.equalToSuperview().inset(16)
            }
            
            // 카테고리 가져오기
            let bundle = Bundle.main
            guard let path = bundle.path(forResource: "Localizable", ofType: "strings"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: String] else {
                logger.critical("Localizable.strings not found")
                return
            }
            
            let matchedKeys = dict.filter { $0.key.contains("Category\(groupNumber)") }
                .sorted { $0.key < $1.key }
            
            let categories = matchedKeys.map { $0.value }
            let tags = matchedKeys.compactMap { Int($0.key.suffix(4)) }
            
            let wrappingView = LabelsWrappingView(
                customLabelType: CategorySelectable.self,
                spacingX: 8,
                spacingY: 8
            )
            
            wrappingView.labels = categories
            wrappingView.tags = tags
            
            wrappingViews.append(wrappingView)
            
            scrollView.addSubview(wrappingView)
            
            wrappingView.snp.makeConstraints { make in
                make.top.equalTo(groupLabel.snp.bottom).offset(16)
                make.horizontalEdges.equalToSuperview().inset(16)
                make.width.equalToSuperview().inset(16 * 2)
                
                if index == groups.count - 1 {
                    make.bottom.equalToSuperview().inset(32)
                }
            }
            
            previousView = wrappingView
        }
    }
    
    private func updateSelectedCategories(_ selectedCategories: [String]) {
        wrappingViews.forEach { view in
            view.updateSelectedCategories(selectedCategories)
        }
    }
}


#if DEBUG
// 미리보기
import SwiftUI
import RxRelay

struct SelectCategoriesViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            SelectCategoriesView(selectedCategories: [])
        }
    }
}
#endif
