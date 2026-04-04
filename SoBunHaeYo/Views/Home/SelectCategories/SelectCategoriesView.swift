//
//  SelectCategoriesView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 11/14/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import OSLog

class SelectCategoriesView: UIViewController {
    private let initialSelectedCategories: [String]
    private let safeAreaBottom: CGFloat
    private let allowsEmpty: Bool
    
    init(selectedCategories: [String], safeAreaBottom: CGFloat, allowsEmpty: Bool) {
        self.initialSelectedCategories = selectedCategories
        self.safeAreaBottom = safeAreaBottom
        self.allowsEmpty = allowsEmpty
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SelectCategories.View"
    )
    
    typealias Reactor = SelectCategoriesReactor
    private let reactor: SelectCategoriesReactor = SelectCategoriesReactor()
    
    let selectedCategoriesRelay = PublishRelay<[String]>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private let scrollView: UIScrollView = UIScrollView()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    private var wrappingViews: [HorizontalWrappingView] = []
    
    private lazy var confirmButton: Button = {
        let btn = Button(title: String(localized: "SelectComplete", table: "Home"))
        btn.isEnabled = allowsEmpty
        
        return btn
    }()
    
    private func groupLabel(number: String) -> UILabel {
        let label = UILabel()
        var attributes = title18.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        label.attributedText = NSAttributedString(
            string: NSLocalizedString("Group\(number)", tableName: "Category", comment: ""),
            attributes: attributes
        )
        
        return label
    }
    
    private func categoryWrappingView(categories: [String]) -> HorizontalWrappingView {
        let wrappingView = HorizontalWrappingView(horizontalSpacing: 8, verticalSpacing: 8)
        
        let categorySelectables = categories.map { category in
            let view = CategorySelectable(number: category)
            
            // bind action
            view.didTap
                .map { Reactor.Action.selectCategory($0) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            return view
        }
        
        wrappingView.addArrangedSubviews(categorySelectables)
        
        return wrappingView
    }
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [confirmButton, scrollView].forEach {
            view.addSubview($0)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(safeAreaBottom)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(confirmButton.snp.top)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

extension SelectCategoriesView {
    private func bind(reactor: SelectCategoriesReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: SelectCategoriesReactor) {
        reactor.action.onNext(.viewDidLoad(initialSelectedCategories))
        
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                selectedCategoriesRelay.accept(reactor.currentState.selectedCategories)
                
                if let bottomSheet = parent as? BottomSheetView {
                    bottomSheet.handleDismiss()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SelectCategoriesReactor) {
        reactor.state.map { $0.categories }
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] categories in
                guard let self = self else { return }
                
                setupCategories(categories: categories)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedCategories }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] categories in
                guard let self = self else { return }
                
                confirmButton.isEnabled = allowsEmpty || !categories.isEmpty
                updateSelectedCategories(selectedCategories: categories)
            })
            .disposed(by: disposeBag)
    }
    
    // 카테고리 뷰 설정
    private func setupCategories(categories: [String]) {
        var previousView: UIView? = nil
        
        // [그룹: [카테고리]] dictionary 형태
        let groupedCategories = Dictionary(grouping: categories, by: { String($0.prefix(2)) })
        
        // 그룹 key만 포함 예) ["00", "01"]
        let sortedGroups = groupedCategories.keys.sorted()
        
        for (index, groupNumber) in sortedGroups.enumerated() {
            guard let categoriesInGroup = groupedCategories[groupNumber] else { continue }
            
            // 그룹 제목
            let groupLabel = groupLabel(number: groupNumber)
            contentView.addSubview(groupLabel)
            
            groupLabel.snp.makeConstraints { make in
                if let previous = previousView {
                    make.top.equalTo(previous.snp.bottom).offset(48)
                } else {
                    make.top.equalToSuperview().offset(32)
                }
                make.horizontalEdges.equalToSuperview().inset(16)
            }
            
            // 카테고리 목록
            let wrappingView = categoryWrappingView(categories: categoriesInGroup)
            wrappingViews.append(wrappingView)
            contentView.addSubview(wrappingView)
            
            wrappingView.snp.makeConstraints { make in
                make.top.equalTo(groupLabel.snp.bottom).offset(16)
                make.horizontalEdges.equalToSuperview().inset(16)
                
                if index == sortedGroups.count - 1 {
                    make.bottom.equalToSuperview().inset(32)
                }
            }
            
            previousView = wrappingView
        }
    }
    
    // CategorySelectable 상태 업데이트
    private func updateSelectedCategories(selectedCategories: [String]) {
        // Array는 순차로 검색하지만, Set은 해시 함수를 통해 더 빨리 검색함
        let setSelectedCategories = Set(selectedCategories)
        
        wrappingViews
            .flatMap { $0.subviews }
            .compactMap { $0 as? CategorySelectable }
            .forEach {
                $0.isChecked = setSelectedCategories.contains($0.number)
            }
    }
}
