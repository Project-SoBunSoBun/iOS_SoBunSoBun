//
//  SettleUp1stStepView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/11/25.
//

import UIKit
import SnapKit
import OSLog
import RxSwift
import RxCocoa
import ReactorKit

class SettleUp1stStepView: UIViewController {
    init(id: Int) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    typealias Reactor = SettleUp1stStepReactor
    private let reactor = SettleUp1stStepReactor()
    
    private let disposeBag = DisposeBag()
    private let id: Int
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SettleUp1stStep.View"
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
        config.image = .greyClose
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        
        button.configuration = config
        
        return button
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            make.size.equalTo(48)
            make.leading.equalToSuperview().offset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        self.logger.debug("선택된 정산 id: \(self.id)")
    }
}

extension SettleUp1stStepView {
    // reactor와 view 연결
    private func bind(reactor: SettleUp1stStepReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: SettleUp1stStepReactor) {
        // Back 버튼 탭
        backButton.rx.tap
            .map { Reactor.Action.backButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SettleUp1stStepReactor) {
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
