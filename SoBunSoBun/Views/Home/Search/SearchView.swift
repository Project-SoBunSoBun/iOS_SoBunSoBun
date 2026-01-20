//
//  SearchView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/13/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class SearchView: UIViewController {
    typealias Reactor = SearchReactor
    private let reactor = SearchReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private let topContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .blackLeft
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private let searchTextField: SearchTextField = SearchTextField()
    
    // 검색 전
    private let beforeSearchScrollView: UIScrollView = UIScrollView()
    
    private let beforeSearchView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let historyTitleLabel: UILabel = {
        let lb = UILabel()
        
        var attributes: [NSAttributedString.Key: Any] = title16.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        lb.attributedText = NSAttributedString(string: String(localized: "SearchKeywordsHistory"), attributes: attributes)
        
        return lb
    }()
    
    private let clearAllHistoryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        var attributes: [NSAttributedString.Key: Any] = body14.attributes()
        attributes[.foregroundColor] = UIColor.neutral400
        config.attributedTitle = AttributedString(
            NSAttributedString(string: String(localized: "ClearAll"), attributes: attributes)
        )
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private let historyListView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .leading
        
        return sv
    }()
    
    // 검색 후
    private let afterSearchView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        
        return view
    }()
    
    private static let sortLocalizableKeys: [String] = ["SortByLatest", "SortByDeadline"]
    
    private let sortSelectView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        
        return sv
    }()
    
    private let sortLabel: UILabel = {
        let lb = UILabel()
        var attributes: [NSAttributedString.Key: Any] = title14.attributes(alignment: .right)
        attributes[.foregroundColor] = UIColor.neutral900
        
        lb.attributedText = NSAttributedString(
            string: NSLocalizedString(sortLocalizableKeys[0], comment: ""),
            attributes: attributes
        )
        
        return lb
    }()
    
    private let sortArrowIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = .blackDown
        iv.contentMode = .scaleAspectFit
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        return iv
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary50
        
        return view
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(PostListTableViewCell.self, forCellReuseIdentifier: PostListTableViewCell.identifier)
        tv.estimatedRowHeight = 142
        tv.rowHeight = UITableView.automaticDimension
        
        return tv
    }()
    
    private let dropDownView = DropDownView(items: sortLocalizableKeys)
    
    // 검색 후 결과 없음
    private let emptySearchResultLabel: UILabel = {
        let lb = UILabel()
        var attributes: [NSAttributedString.Key: Any] = body18.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary200
        
        lb.attributedText = NSAttributedString(string: String(localized: "EmptySearchResult"), attributes: attributes)
        lb.isHidden = true
        
        return lb
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
        
        DispatchQueue.main.async {
            if self.tableView.numberOfRows(inSection: 0) > 0 {
                self.tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        view.addSubview(topContainer)
        
        topContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().inset(16)
        }
        
        [backButton, searchTextField].forEach {
            topContainer.addSubview($0)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        configureBeforeSearchView()
        configureAfterSearchView()
        configureEmptyResultLabel()
    }
    
    private func configureBeforeSearchView() {
        view.addSubview(beforeSearchScrollView)
        
        beforeSearchScrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(topContainer.snp.bottom).offset(16)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        beforeSearchScrollView.addSubview(beforeSearchView)
        
        beforeSearchView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [historyTitleLabel, clearAllHistoryButton, historyListView].forEach {
            beforeSearchView.addSubview($0)
        }
        
        historyTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        clearAllHistoryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(historyTitleLabel)
        }
        
        historyListView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(historyTitleLabel.snp.bottom).offset(12)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    private func configureAfterSearchView() {
        view.addSubview(afterSearchView)
        
        afterSearchView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topContainer.snp.bottom).offset(16)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        [sortLabel, sortArrowIcon].forEach {
            sortSelectView.addArrangedSubview($0)
        }
        
        [sortSelectView, dividerView, tableView, dropDownView].forEach {
            afterSearchView.addSubview($0)
        }
        
        sortSelectView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(sortSelectView.snp.bottom).offset(16)
            make.height.equalTo(1)
        }
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(dividerView.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        dropDownView.snp.makeConstraints { make in
            make.trailing.equalTo(sortSelectView)
            make.top.equalTo(sortSelectView.snp.bottom)
        }
    }
    
    private func configureEmptyResultLabel() {
        view.addSubview(emptySearchResultLabel)
        
        emptySearchResultLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.center.equalToSuperview()
        }
    }
}

extension SearchView {
    private func bind(reactor: SearchReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: SearchReactor) {
        backButton.rx.tap
            .map { Reactor.Action.backButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .map { Reactor.Action.search($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        clearAllHistoryButton.rx.tap
            .map { Reactor.Action.clearAllTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 정렬을 열고 닫을 때
        sortSelectView.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.sortButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 정렬을 눌렀을 때
        dropDownView.itemTapped
            .map { Reactor.Action.sortTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 셀을 눌렀을 때
        tableView.rx.modelSelected(PostModel.self)
            .map { Reactor.Action.postTapped($0) }
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
            .map { _ in Reactor.Action.loadMorePosts }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SearchReactor) {
        reactor.pulse(\.$shouldGoBack)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
       
        reactor.state.map { $0.history.reversed() }
            .subscribe(onNext: { [weak self] history in
                guard let self = self else { return }
                
                clearHistoryListView()
                addHistoryListView(history: history)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.keyword }
            .subscribe(onNext: { [weak self] keyword in
                guard let self = self else { return }
                
                searchTextField.rx.text
                    .onNext(keyword)
                
                searchTextField.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isSortButtonOpen }
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                dropDownView.setOpen(isOpen: isOpen)
                
                sortArrowIcon.image = isOpen ? .blackUp : .blackDown
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.sortBy }
            .subscribe(onNext: { [weak self] sortBy in
                guard let self = self else { return }
                
                var attributes: [NSAttributedString.Key: Any] = title14.attributes(alignment: .right)
                attributes[.foregroundColor] = UIColor.neutral900
                sortLabel.attributedText = NSAttributedString(string: NSLocalizedString(sortBy, comment: ""), attributes: attributes)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushPostDetailView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                // TODO: 게시글 상세 뷰 이동 기능 추가
                
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.posts }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                guard let self = self else { return }
                
                beforeSearchScrollView.isHidden = true
                afterSearchView.isHidden = true
                emptySearchResultLabel.isHidden = true
                
                if posts == nil { // 검색 전
                    beforeSearchScrollView.isHidden = false
                } else if posts!.isEmpty { // 검색 후 결과 없음
                    emptySearchResultLabel.isHidden = false
                } else { // 검색 후 결과
                    afterSearchView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.posts ?? [] }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: PostListTableViewCell.identifier,
                cellType: PostListTableViewCell.self
            )) { index, model, cell in
                let isLast = index == (reactor.currentState.posts?.count ?? 0) - 1
                
                cell.configureUI(model: model, isLast: isLast)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                showAlert(
                    title: String(localized: "Error"),
                    message: message,
                    confirmTitle: String(localized: "Confirm"),
                    confirmAction: {},
                    vc: self
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func clearHistoryListView() {
        historyListView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    private func addHistoryListView(history: [String]) {
        history.forEach {
            let cell = SearchHistoryListCell(history: $0)
            
            cell.labelTapped
                .map { Reactor.Action.quickSearch($0) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            cell.removeTapped
                .map { Reactor.Action.clearOneSearchHistoryTapped($0) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            historyListView.addArrangedSubview(cell)
            
            cell.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
    }
}

#if DEBUG
// 미리보기
import SwiftUI

struct SearchViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            SearchView()
        }
    }
}
#endif
