//
//  HomeView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/24/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import RxGesture

class HomeView: UIViewController {
    typealias Reactor = HomeReactor
    private let reactor = HomeReactor()
    
    private let disposeBag = DisposeBag()
    
    // 외부 이벤트 전달
    let shouldShowLocationSettingAlert = PublishRelay<Void>()
    
    // MARK: - 디자인 요소
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .logo
        iv.contentMode = .scaleAspectFit
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(30)
        }
        
        return iv
    }()
    
    private let letterLogoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .sobunSobunText
        iv.contentMode = .scaleAspectFit
        
        iv.snp.makeConstraints { make in
            make.width.equalTo(65)
            make.height.equalTo(22)
        }
        
        return iv
    }()
    
    private let locationIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .glassLocation
        iv.contentMode = .scaleAspectFit
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        return iv
    }()
    
    private let myProfileButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .glassUser
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        
        let btn = UIButton(configuration: config)
        
        btn.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        
        return btn
    }()
    
    private let notificationButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .glassBell
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        
        let btn = UIButton(configuration: config)
        
        btn.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        
        return btn
    }()
    
    private let locationLabel: UILabel = {
        let lb = UILabel()
        lb.font = title16.font
        lb.textColor = .neutral900
        lb.textAlignment = .left
        lb.numberOfLines = 1
        
        return lb
    }()
    
    private let searchTextField: SearchTextField = {
        let tf = SearchTextField()
        tf.isEnabled = false
        
        return tf
    }()
    
    private let searchTextFieldCover: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let categoriesScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        
        return sv
    }()
    
    private let categoriesStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        
        return sv
    }()
    
    private let addCategoryButton: UIView = {
        let size: CGFloat = 35
        let view = UIView()
        view.backgroundColor = .primary100
        view.layer.cornerRadius = size / 2
        view.clipsToBounds = true
        
        let iv = UIImageView()
        iv.image = .lightbluePlus
        iv.contentMode = .scaleAspectFit
        
        view.addSubview(iv)
        
        view.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.center.equalToSuperview()
        }
        
        return view
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(PostListTableViewCell.self, forCellReuseIdentifier: PostListTableViewCell.identifier)
        tv.estimatedRowHeight = 142
        tv.rowHeight = UITableView.automaticDimension
        tv.contentInset = .init(
            top: 0,
            left: 0,
            bottom: 8 + BottomNavigationBar.SHADOW_HEIGHT + 8 + 8,
            right: 0)
        
        return tv
    }()
    
    private let refreshControl: BlueMeatballsRefreshController = {
        let rc = BlueMeatballsRefreshController()
        
        return rc
    }()
    
    private let registerPostButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = .primary500
        config.cornerStyle = .fixed
        config.background.cornerRadius = 100
        var imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        config.preferredSymbolConfigurationForImage = imageConfig
        config.image = .whitePost
        config.imagePadding = 8
        
        var attributes: [NSAttributedString.Key: Any] = title16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.backgroundWhite
        
        let attributedTitle = NSAttributedString(
            string: String(localized: "WritePost", table: "Home"),
            attributes: attributes
        )
        
        config.attributedTitle = AttributedString(attributedTitle)
        config.contentInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private lazy var gradientLayer = BackgroundGradientLayer(view)
    
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
        view.layer.addSublayer(gradientLayer)
        
        [logoImageView, letterLogoImageView, locationIconImageView, locationLabel, myProfileButton, notificationButton, locationLabel, searchTextField, searchTextFieldCover, categoriesScrollView, tableView, registerPostButton].forEach {
            view.addSubview($0)
        }
        
        // 상단 로고
        logoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
        }
        
        letterLogoImageView.snp.makeConstraints { make in
            make.leading.equalTo(logoImageView.snp.trailing).offset(8)
            make.centerY.equalTo(logoImageView)
        }
        
        // 지역 인증, 알림, 내 프로필
        locationIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
        }
        
        myProfileButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(4)
            make.centerY.equalTo(locationIconImageView)
        }
        
        notificationButton.snp.makeConstraints { make in
            make.trailing.equalTo(myProfileButton.snp.leading)
            make.centerY.equalTo(locationIconImageView)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationIconImageView.snp.trailing).offset(8)
            make.trailing.equalTo(notificationButton.snp.leading)
            make.centerY.equalTo(locationIconImageView)
        }
        
        // 검색창
        searchTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(myProfileButton.snp.bottom).offset(8)
        }
        
        searchTextFieldCover.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(searchTextField)
            make.top.equalTo(searchTextField)
            make.size.equalTo(searchTextField)
        }
        
        // 카테고리 목록
        categoriesScrollView.addSubview(categoriesStackView)
        
        categoriesScrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(searchTextField.snp.bottom).offset(8)
            make.height.equalTo(51)
        }
        
        categoriesStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
        }
        
        addCategoryAll()
        
        categoriesStackView.addArrangedSubview(addCategoryButton)
        
        // 게시글 목록
        tableView.refreshControl = refreshControl
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(categoriesScrollView.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 글쓰기 버튼
        registerPostButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(safeareaBottom + 8 + BottomNavigationBar.SHADOW_HEIGHT + 8 + 8)
        }
    }
}

extension HomeView {
    // reactor와 view 연결
    private func bind(reactor: HomeReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: HomeReactor) {
        addCategoryButton.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.addCategoryTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        notificationButton.rx.tap
            .map { Reactor.Action.notificationsTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        myProfileButton.rx.tap
            .map { Reactor.Action.myProfileTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchTextFieldCover.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.searchTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        registerPostButton.rx.tap
            .map { Reactor.Action.registerPostTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 새로고침
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
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
    
    private func bindState(reactor: HomeReactor) {
        reactor.state
            .map { $0.verifiedLocation }
            .bind(to: locationLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushNotificationsView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // TODO: 알림 뷰 이동 기능 추가
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushMyProfileView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // TODO: 내 프로필 뷰 이동 기능 추가
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushSearchView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(SearchView(), animated: false)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowBottomCategorySheet)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                showSelectCategoriesBottomSheet()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedCategories }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selectedCategories in
                guard let self = self else { return }
                
                updateCategoriesStackView(selectedCategories)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowLocationSettingAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                shouldShowLocationSettingAlert.accept(())
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushRegisterPostView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(RegisterPostView(), animated: false)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushPostDetailView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(PostDetailView(postId: model.id), animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.posts }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: PostListTableViewCell.identifier,
                cellType: PostListTableViewCell.self
            )) { index, model, cell in
                // let isLast = index == reactor.currentState.posts.count - 1
                
                cell.configureUI(model: model)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    }
    
    private func addCategoryAll() {
        let view = CategorySelected()
        view.text = String(localized: "All", table: "Category")
        
        categoriesStackView.addArrangedSubview(view)
    }
    
    private func updateCategoriesStackView(_ selectedCategories: [String]) {
        categoriesStackView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        if selectedCategories.isEmpty {
            addCategoryAll()
        } else {
            selectedCategories.forEach {
                let view = CategorySelected()
                view.text = NSLocalizedString("Category\($0)", tableName: "Category", comment: "")
                
                categoriesStackView.addArrangedSubview(view)
            }
        }
        
        categoriesStackView.addArrangedSubview(addCategoryButton)
    }
    
    private func showSelectCategoriesBottomSheet() {
        let sheetView = SelectCategoriesView(selectedCategories: reactor.currentState.selectedCategories)
        
        sheetView.selectedCategoriesRelay
            .map { Reactor.Action.getSelectedCategories($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // iOS 26이상 sheet detents 이슈로 인해 customize할 방법이 없어 직접 제작한 BottomSheetView를 사용하였습니다.
        let bottomSheet = BottomSheetView(
            contentViewController: sheetView,
            height: 0.88,
            cornerRadius: 24)
        
        present(bottomSheet, animated: true)
    }
}

#if DEBUG
// 미리보기
import SwiftUI

struct HomeViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            HomeView()
        }
    }
}
#endif
