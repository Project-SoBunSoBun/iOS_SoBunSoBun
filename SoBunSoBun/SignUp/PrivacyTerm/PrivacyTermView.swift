//
//  PrivacyTermView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/23/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class PrivacyTermView: CustomViewController {
    typealias Reactor = PrivacyTermReactor
    private let reactor = PrivacyTermReactor()
    
    private let disposeBag = DisposeBag()
    
    // 뒤로 가기 버튼
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "BlackLeft"), for: .normal)
        
        return button
    }()
    
    // 임시 타이틀
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Privacy 약관 화면"
        title.textColor = .appleBlack
        title.textAlignment = .center
        
        return title
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        bind(reactor: reactor)
    }
    
    private func configureUI() {
        view.backgroundColor = .appleWhite
        
        [backButton, titleLabel].forEach {
            view.addSubview($0)
        }
        
        backButton.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.leading.equalToSuperview().offset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}

extension PrivacyTermView {
    // reactor와 view 연결
    func bind(reactor: PrivacyTermReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    func bindAction(reactor: PrivacyTermReactor) {
        // Back 버튼 탭
        backButton.rx.tap
            .map { Reactor.Action.backButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(reactor: PrivacyTermReactor) {
        // 뒤로 가기 버튼
        reactor.pulse(\.$shouldPopViewController)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
