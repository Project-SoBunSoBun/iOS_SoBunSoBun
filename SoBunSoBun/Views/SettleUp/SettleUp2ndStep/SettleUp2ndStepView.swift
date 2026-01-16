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
    
    // 전체 스크롤 뷰
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        
        return sv
    }()
    
    // 스크롤 뷰가 들어갈 View
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    // 2/3
    private let stepLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: "2/3",
            attributes: title14.attributes(alignment: .left)
        )
        lb.attributedText = attributedText
        lb.textColor = .primary400
        
        return lb
    }()
    
    // 제목 라벨
    private let titleLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SettleUpStart"),
            attributes: title24.attributes(alignment: .left)
        )
        lb.attributedText = attributedText
        lb.textColor = .neutral900
        
        return lb
    }()
    
    // 등록된 상품 수량 라벨 배경 뷰
    private let subtitleBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .primary50
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        
        return view
    }()
    
    // 등록된 상품 수량 라벨
    private let subtitleLabel: UILabel = {
        let lb = UILabel()
        let format = String(localized: "SettleUpParticipant")
        let attributedText = NSAttributedString(
            string: String(format: format, 0),
            attributes: body14.attributes(alignment: .center)
        )
        
        lb.attributedText = attributedText
        lb.textColor = .neutral800
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 참여자별 정산 컴포넌트가 들어갈 스택뷰
    private let calculationStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        
        return sv
    }()
    
    // 등록하기 버튼
    private let registerButton = Button(title: String(localized: "Register"))
    
    private let test: CalculationGuest = {
        let testProduct = ListedProductModel(name: "두쫀쿠", count: 1000, price: 5000000, unitIndex: 1)
        let test = CalculationGuest(product: testProduct)
        
        return test
    }()
    
    private let test2: CalculationGuest = {
        let testProduct = ListedProductModel(name: "두쫀쿠", count: 500, price: 1500000, unitIndex: 2)
        let test = CalculationGuest(product: testProduct)
        
        return test
    }()
    
    private let test3: CalculationGuest = {
        let testProduct = ListedProductModel(name: "배추", count: 5, price: 25000, unitIndex: 1)
        let test = CalculationGuest(product: testProduct)
        
        return test
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
        
        [backButton, scrollView].forEach {
            view.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [stepLabel, titleLabel, subtitleBackground, calculationStackView, registerButton].forEach {
            contentView.addSubview($0)
        }
        
        // CalculationGuest 컴포넌트가 들어갈 StackView
        [test, test2, test3].forEach {
            calculationStackView.addArrangedSubview($0)
        }
        
        subtitleBackground.addSubview(subtitleLabel)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.size.equalTo(48)
        }
        
        stepLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(stepLabel.snp.bottom).offset(8)
        }
        
        subtitleBackground.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(53)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        calculationStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(subtitleBackground.snp.bottom).offset(8)
        }
        
        registerButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(calculationStackView.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
        
        let mockParticipants = ["닉네임(나)", "닉네임 A", "닉네임 B", "닉네임 C", "닉네임 D"]
        
        test.setParticipants(mockParticipants)
        test2.setParticipants(mockParticipants)
        test3.setParticipants(mockParticipants)
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
