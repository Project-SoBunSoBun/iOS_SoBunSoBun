//
//  SettleUp2ndStepView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/12/26.
//

import UIKit
import SnapKit
import OSLog
import RxSwift
import RxCocoa
import ReactorKit

class SettleUp2ndStepView: UIViewController {
    init(id: Int, products: [ListedProductModel]) {
        self.id = id
        self.products = products
        super.init(nibName: nil, bundle: nil)
    }
    
    typealias Reactor = SettleUp2ndStepReactor
    private let reactor = SettleUp2ndStepReactor()
    
    private let disposeBag = DisposeBag()
    private let id: Int
    private let products: [ListedProductModel]
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SettleUp2ndStep.View"
    )
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 뒤로 가기 버튼
    private let backButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0)
        config.image = .blackLeft
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        
        button.configuration = config
        
        return button
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // products 정보 로깅
        logger.debug("받은 ID: \(self.id)")
        logger.debug("받은 상품 수: \(self.products.count)")
        
        products.forEach { product in
            logger.debug("상품명: \(product.name), 수량: \(product.count), 가격: \(product.price), 단위: \(product.unitIndex)")
        }
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [backButton].forEach {
            view.addSubview($0)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.size.equalTo(48)
        }
    }
}

extension SettleUp2ndStepView {
    // reactor와 view 연결
    private func bind(reactor: SettleUp2ndStepReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
        
    private func bindAction(reactor: SettleUp2ndStepReactor) {
        // Back 버튼 탭
        backButton.rx.tap
            .map { Reactor.Action.backButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SettleUp2ndStepReactor) {
        // Back  버튼 탭
        reactor.pulse(\.$shouldPopViewController)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
