//
//  SignUpCompletedView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 11/6/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import OSLog

class SignUpCompletedView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SignUpCompleted.View"
    )
    
    typealias Reactor = SignUpCompletedReactor
    private let reactor = SignUpCompletedReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private let greyClose: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "GreyClose"), for: .normal)
        
        return button
    }()
    
    private let unionLeft: UIImageView = {
        let image = UIImageView()
        image.image = .union
        
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "CongratulationsOnJoining", table: "SignIn"),
            attributes: title24.attributes(alignment: .center)
        )
        label.attributedText = attributedText
        label.textColor = .neutral900
        label.textAlignment = .center
        
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    private let unionRight: UIImageView = {
        let image = UIImageView()
        image.image = .union
        image.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        return image
    }()
    
    private let startButton = Button(title: String(localized: "Start", table: "SignIn"))
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
        
        reactor.action.onNext(.viewDidLoad)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [greyClose, unionLeft, titleLabel, subLabel, unionRight, startButton].forEach {
            view.addSubview($0)
        }
        
        greyClose.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.trailing.equalToSuperview().inset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        unionLeft.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.leading.equalToSuperview().offset(62)
            make.top.equalToSuperview().offset(197)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(82)
            make.top.equalTo(unionLeft.snp.bottom).offset(44)
        }
        
        subLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(82)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        unionRight.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.trailing.equalToSuperview().inset(62)
            make.top.equalTo(subLabel.snp.bottom).offset(44)
        }
        
        startButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(64)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension SignUpCompletedView {
    private func bind(reactor: SignUpCompletedReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: SignUpCompletedReactor) {
        // 닫기 버튼 탭
        greyClose.rx.tap
            .map { Reactor.Action.closeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 시작 버튼 탭
        startButton.rx.tap
            .map {Reactor.Action.startButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SignUpCompletedReactor) {
        // 닉네임 업데이트
        reactor.state.map { $0.nickname }
            .distinctUntilChanged()
            .filter{ !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] nickname in
                guard let self = self else { return }
                
                self.updateSubLabel(with: nickname)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.logger.debug("사용자 정보 로딩 중")
                }
            })
            .disposed(by: disposeBag)
        
        // 홈 화면으로 이동
        reactor.pulse(\.$shouldNavigateToHome)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigateToHome()
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.logger.debug("에러 발생: \(message)")
                let alert = UIAlertController(title: String(localized: "Error", table: "Error"), message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: String(localized: "Confirm", table: "Common"), style: .default))
                self.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateSubLabel(with nickname: String) {
        let message = String(format: String(localized: "SignUpCompletedMessage", table: "SignIn"), nickname)
        
        let attributedText = NSMutableAttributedString(string: message)
        attributedText.setAttributes([
            .foregroundColor: UIColor.neutral900,
            .font: body18.font,
            .paragraphStyle: title18.paragraphStyle(alignment: .center),
            .baselineOffset: title18.attributes()[.baselineOffset]!
        ], range: NSRange(location: 0, length: message.count))
        
        // 닉네임 부분의 범위 찾기
        if let range = message.range(of: nickname) {
            let nsRange = NSRange(range, in: message)
            var nicknameAttributes = title18.attributes(alignment: .center)
            nicknameAttributes[.foregroundColor] = UIColor.primary400
            attributedText.addAttributes(nicknameAttributes, range: nsRange)
        }
        
        subLabel.attributedText = attributedText
    }
    
    private func navigateToHome() {
        let vc = NavigationTabView()
        navigationController?.setViewControllers([vc], animated: false)
    }
}

// 미리보기
#if DEBUG
import SwiftUI

struct SignUpCompletedViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            SignUpCompletedView()
        }
    }
}
#endif
