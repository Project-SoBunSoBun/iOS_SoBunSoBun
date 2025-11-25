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
    private let scrollView: UIScrollView = UIScrollView()
    
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
    
    private let mypageButton: UIButton = {
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
    
    private let searchTextField: SearchTextField = SearchTextField()
    
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
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [logoImageView, letterLogoImageView, locationIconImageView, locationLabel, mypageButton, notificationButton, locationLabel, searchTextField, categoriesScrollView].forEach {
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
        
        mypageButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(4)
            make.centerY.equalTo(locationIconImageView)
        }
        
        notificationButton.snp.makeConstraints { make in
            make.trailing.equalTo(mypageButton.snp.leading)
            make.centerY.equalTo(locationIconImageView)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationIconImageView.snp.trailing).offset(8)
            make.trailing.equalTo(notificationButton.snp.leading)
            make.centerY.equalTo(locationIconImageView)
        }
        
        // 검색창
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(mypageButton.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        // 카테고리 목록
        categoriesScrollView.addSubview(categoriesStackView)
        
        categoriesScrollView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(51)
        }
        
        categoriesStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
        }
        
        addCategoryAll()
        
        categoriesStackView.addArrangedSubview(addCategoryButton)
    }
}

extension HomeView {
    // reactor와 view 연결
    private func bind(reactor: HomeReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: HomeReactor) {
        // bind 호출 시 바로 실행
        Observable.just(())
            .map { Reactor.Action.initialized }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addCategoryButton.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.addCategoryTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: HomeReactor) {
        reactor.state
            .map { $0.verifiedLocation }
            .bind(to: locationLabel.rx.text)
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
    }
    
    private func addCategoryAll() {
        let categoryAll = CategorySelected()
        categoryAll.text = String(localized: "CategoryAll")
        categoriesStackView.addArrangedSubview(categoryAll)
    }
    
    private func updateCategoriesStackView(_ selectedCategories: [String]) {
        categoriesStackView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        if selectedCategories.isEmpty {
            addCategoryAll()
        } else {
            selectedCategories.forEach {
                let categoryString = NSLocalizedString("Category\($0)", comment: "Category \($0)")
                let category = CategorySelected()
                category.text = categoryString
                
                categoriesStackView.addArrangedSubview(category)
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
            heightRatio: 0.88,
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
