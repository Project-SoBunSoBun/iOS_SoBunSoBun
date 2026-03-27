//
//  HomeView.swift
//  SoBunHaeYo
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
    
    // 외부 이벤트에서 전달
    let unreadNotificationCount = PublishSubject<Int>()
    
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
        iv.image = .logo.resize(.init(width: 30, height: 30))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private let letterLogoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .soBunHaeYoText.resize(.init(width: 65, height: 22))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private let locationIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .glassLocation.resize(.init(width: 24, height: 24))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private let myProfileButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .glassUser.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private let notificationButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .glassBell.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        
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
    
    private let sortLocalizableKeys: [String] = ["SortByLatest", "SortByDeadline"]
    
    private let sortSelectView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 5.5, left: 10, bottom: 5.5, right: 10)
        sv.layer.cornerRadius = 12
        sv.clipsToBounds = true
        sv.backgroundColor = .neutral800
        
        return sv
    }()
    
    private let filtersScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        
        return sv
    }()
    
    private let filtersStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        
        return sv
    }()
    
    private let sortLabelAttributes: [NSAttributedString.Key: Any] = {
        var attributes: [NSAttributedString.Key: Any] = title14.attributes(alignment: .right)
        attributes[.foregroundColor] = UIColor.backgroundWhite
        
        return attributes
    }()
    
    private lazy var sortLabel: UILabel = {
        let lb = UILabel()
        
        lb.attributedText = NSAttributedString(
            string: NSLocalizedString(sortLocalizableKeys[0], tableName: "Home", comment: ""),
            attributes: sortLabelAttributes
        )
        
        return lb
    }()
    
    private let sortArrowIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = .whiteChevronDown.resize(.init(width: 24, height: 24))
        iv.contentMode = .scaleAspectFit
        
        return iv
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
    
    private let tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.register(PostListTableViewCell.self, forCellReuseIdentifier: PostListTableViewCell.identifier)
        tv.estimatedRowHeight = 142
        tv.contentInset = .init(
            top: 0,
            left: 0,
            bottom: 8 + BottomNavigationBar.SHADOW_HEIGHT + 8 + 8,
            right: 0)
        tv.minimumZoomScale = 1.0
        tv.maximumZoomScale = 1.0
        tv.pinchGestureRecognizer?.isEnabled = false
        
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
        config.image = .whitePost.resize(.init(width: 20, height: 20))
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
    
    private lazy var dropDownView: DropDownView = {
        let ddv = DropDownView(selectionMode: .check, tableName: "Home")
        ddv.items = sortLocalizableKeys
        ddv.animationAnchor = .topLeft
        
        return ddv
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
        
        [logoImageView, letterLogoImageView, locationIconImageView, locationLabel, myProfileButton, notificationButton, locationLabel, searchTextField, searchTextFieldCover, filtersScrollView, tableView, registerPostButton, dropDownView].forEach {
            view.addSubview($0)
        }
        
        // 상단 로고
        logoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.size.equalTo(30)
        }
        
        letterLogoImageView.snp.makeConstraints { make in
            make.leading.equalTo(logoImageView.snp.trailing).offset(8)
            make.centerY.equalTo(logoImageView)
            make.width.equalTo(65)
            make.height.equalTo(22)
        }
        
        // 지역 인증, 알림, 내 프로필
        locationIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.size.equalTo(24)
        }
        
        myProfileButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(4)
            make.centerY.equalTo(locationIconImageView)
            make.size.equalTo(48)
        }
        
        notificationButton.snp.makeConstraints { make in
            make.trailing.equalTo(myProfileButton.snp.leading)
            make.centerY.equalTo(locationIconImageView)
            make.size.equalTo(48)
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
        filtersScrollView.addSubview(filtersStackView)
        
        filtersScrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(searchTextField.snp.bottom).offset(8)
            make.height.equalTo(51)
        }
        
        filtersStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
        }
        
        filtersStackView.addArrangedSubview(sortSelectView)
        addCategoryAll()
        filtersStackView.addArrangedSubview(addCategoryButton)
        
        // 게시글 목록
        tableView.refreshControl = refreshControl
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(filtersScrollView.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 글쓰기 버튼
        registerPostButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8 + BottomNavigationBar.SHADOW_HEIGHT + 8 + 8)
        }
        
        [sortLabel, sortArrowIcon].forEach {
            sortSelectView.addArrangedSubview($0)
        }
        
        updateDropDownViewConstraints()
    }
    
    private func updateDropDownViewConstraints() {
        dropDownView.snp.remakeConstraints { make in
            make.leading.equalTo(sortSelectView)
            make.top.equalTo(sortSelectView.snp.bottom).offset(4)
            make.width.equalTo(128)
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
        
        // 정렬을 열고 닫을 때
        sortSelectView.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.sortButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 정렬을 눌렀을 때
        dropDownView.didCellTap
            .map { Reactor.Action.sortTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: HomeReactor) {
        reactor.pulse(\.$shouldShowLocationSettingAlert)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                shouldShowLocationSettingAlert.accept(())
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.verifiedLocation }
            .bind(to: locationLabel.rx.text)
            .disposed(by: disposeBag)
        
        unreadNotificationCount
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                
                notificationButton.configuration?.image = count > 0 ? .newGlassBell.resize(.init(width: 24, height: 24)) : .glassBell.resize(.init(width: 24, height: 24))
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushNotificationsView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(NotificationsView(), animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushMyProfileView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(MyProfileView(), animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldPushSearchView)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.pushViewController(SearchView(), animated: false)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isSortButtonOpen }
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                dropDownView.setOpen(isOpen: isOpen)
                
                sortArrowIcon.image = isOpen ? .whiteChevronUp.resize(.init(width: 24, height: 24)) : .whiteChevronDown.resize(.init(width: 24, height: 24))
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.sortBy }
            .subscribe(onNext: { [weak self] sortBy in
                guard let self = self else { return }
                
                sortLabel.attributedText = NSAttributedString(string: NSLocalizedString(sortBy, tableName: "Home", comment: ""), attributes: sortLabelAttributes)
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
        
        reactor.state.map { $0.posts }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: PostListTableViewCell.identifier,
                cellType: PostListTableViewCell.self
            )) { index, model, cell in
                cell.configureUI(model: model)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
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
    }
    
    private func addCategoryAll() {
        let view = CategorySelected()
        view.text = String(localized: "All", table: "Category")
        
        filtersStackView.addArrangedSubview(view)
    }
    
    private func updateCategoriesStackView(_ selectedCategories: [String]) {
        filtersStackView.subviews.forEach {
            filtersStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        filtersStackView.addArrangedSubview(sortSelectView)
        
        // sortSelectView가 제거/재추가되면 dropDownView의 제약도 같이 사라지므로 재적용
        updateDropDownViewConstraints()
        
        if selectedCategories.isEmpty {
            addCategoryAll()
        } else {
            selectedCategories.forEach {
                let view = CategorySelected()
                view.text = NSLocalizedString("Category\($0)", tableName: "Category", comment: "")
                
                filtersStackView.addArrangedSubview(view)
            }
        }
        
        filtersStackView.addArrangedSubview(addCategoryButton)
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
