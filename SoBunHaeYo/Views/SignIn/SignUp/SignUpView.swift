//
//  SignUpView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 9/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import OSLog

class SignUpView: BaseViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SignUp.View"
    )
    
    typealias Reactor = SignUpReactor
    private let reactor = SignUpReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 뒤로 가기 버튼
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "BlackLeft"), for: .normal)
        
        return button
    }()
    
    // 제목 Text
    private let titleLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "SignUpTitle", table: "SignIn"),
            attributes: title24.attributes()
        )
        label.attributedText = attributedText
        label.textColor = .neutral900
        label.numberOfLines = 0
        
        return label
    }()
    
    // 전체 동의 체크박스
    private let allAgreeCheckBox = TermsCheckBoxView()
    
    // 약관 동의 컨테이너
    private let termsContainerView: UIStackView = {
        let view = UIStackView()
        view.spacing = 8
        view.axis = .vertical
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    // 개별 약관 체크박스들
    private let serviceTermsCheckBox = TermsCheckBoxView()
    private let privacyTermsCheckBox = TermsCheckBoxView()
    private let locationTermsCheckBox = TermsCheckBoxView()
    
    private let nextButton: Button = {
        let button = Button(title: String(localized: "Next", table: "Common"))
        button.isEnabled = false
        
        return button
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    func configureUI() {
        [backButton, titleLabel, termsContainerView, nextButton, allAgreeCheckBox ].forEach {
            view.addSubview($0)
        }
        
        [serviceTermsCheckBox, privacyTermsCheckBox, locationTermsCheckBox].forEach {
            termsContainerView.addArrangedSubview($0)
        }
        
        // 체크박스 설정
        allAgreeCheckBox.configure(title: String(localized: "AllAgree", table: "SignIn"),
                                   hasDetail: false,
                                   font: title16.font,
                                   textColor: .neutral900)
        serviceTermsCheckBox.configure(title: String(localized: "ServiceAgree", table: "SignIn"),
                                       hasDetail: true,
                                       font: body16.font,
                                       textColor: .neutral600)
        privacyTermsCheckBox.configure(title: String(localized: "PersonalInfomationAgree", table: "SignIn"),
                                       hasDetail: true,
                                       font: body16.font,
                                       textColor: .neutral600)
        locationTermsCheckBox.configure(title: String(localized: "LocationInfomationAgree", table: "SignIn"),
                                        hasDetail: true,
                                        font: body16.font,
                                        textColor: .neutral600)
        
        backButton.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.leading.equalToSuperview().offset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(130)
        }
        
        allAgreeCheckBox.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.height.equalTo(24)
        }
        
        termsContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(32)
            make.top.equalTo(allAgreeCheckBox.snp.bottom).offset(16)
        }
        
        [serviceTermsCheckBox, privacyTermsCheckBox, locationTermsCheckBox].forEach {
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(24)
            }
        }
        
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(64)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension SignUpView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        // Back 버튼 탭
        backButton.rx.tap
            .map { Reactor.Action.backButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 전체 동의 체크박스
        allAgreeCheckBox.isChecked
            .skip(1)
            .map { _ in Reactor.Action.allAgreeToggled }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 개별 약관 체크박스
        serviceTermsCheckBox.isChecked
            .skip(1)
            .map { _ in Reactor.Action.termsToggled("service")}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        privacyTermsCheckBox.isChecked
            .skip(1)
            .map { _ in Reactor.Action.termsToggled("privacy") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        locationTermsCheckBox.isChecked
            .skip(1)
            .map { _ in Reactor.Action.termsToggled("location") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 상세보기 버튼
        serviceTermsCheckBox.detailButtonTapped
            .map { Reactor.Action.detailButtonTapped("service") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        privacyTermsCheckBox.detailButtonTapped
            .map { Reactor.Action.detailButtonTapped("privacy") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        locationTermsCheckBox.detailButtonTapped
            .map { Reactor.Action.detailButtonTapped("location") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 다음 버튼 클릭
        nextButton.rx.tap
            .map { Reactor.Action.nextButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 위치 권한 상태 모니터링
        LocationManager.shared.currentAuthorizationStatus
            .skip(1)
            .subscribe(onNext: { [weak self] status in
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    self?.reactor.action.onNext(.locationPermisstionGranted)
                case .denied, .restricted:
                    self?.reactor.action.onNext(.locationPermisstionDenied)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        // 뒤로 가기 버튼
        reactor.pulse(\.$shouldPopViewController)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 전체 동의 체크박스 상태 변경
        reactor.state.map { $0.allAgreed }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] allAgreed in
                self?.allAgreeCheckBox.setChecked(allAgreed, animated: true)
                let textColor: UIColor = allAgreed ? .primary400 : .neutral600
                self?.allAgreeCheckBox.updateTextColor(textColor, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 개별 약관 체크박스 상태 반영
        reactor.state.map { $0.termsChecked["service"] ?? false }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] checked in
                self?.serviceTermsCheckBox.setChecked(checked, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.termsChecked["privacy"] ?? false }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] checked in
                self?.privacyTermsCheckBox.setChecked(checked, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.termsChecked["location"] ?? false }
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] checked in
                self?.locationTermsCheckBox.setChecked(checked, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 약관 상세보기 화면 전환
        reactor.pulse(\.$shouldTermsDetail)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] termsId in
                guard let self = self else { return }
                
                let view = TermsDetailView(termsType: termsId)
                
                self.navigationController?.pushViewController(view, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 활성화 상태
        reactor.state.map { $0.allAgreed }
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 위치 권한 요청
        reactor.pulse(\.$shouldRequestLocationPermission)
            .filter { $0 }
            .subscribe(onNext: { _ in
                LocationManager.shared.requestLocationPermission()
            })
            .disposed(by: disposeBag)
        
        // 설정으로 이동 알림창
        reactor.pulse(\.$shouldShowLocationSettingAlert)
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.showLocationSettingAlert()
            })
            .disposed(by: disposeBag)
        
        // 회원가입 완료 시 화면 전환
        reactor.pulse(\.$signUpCompleted)
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                // 닉네임 설정 화면으로 이동
                let nickNameVC = NicknameSettingView()
                self.navigationController?.pushViewController(nickNameVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    // 위치 권한 설정 알림창
    private func showLocationSettingAlert() {
        let alert = CustomAlert(
            title: String(localized: "LocationSettingTitle", table: "Common"),
            primaryTitleKey: String(localized: "GoToSetting", table: "Common"),
            cancelTitleKey: String(localized: "Cancel", table: "Common")
        )
        
        alert.primaryTap.emit(onNext: {
            // 설정 앱으로 이동
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        .disposed(by: alert.disposeBag)
        
        alert.show(on: self)
    }
    
}

// 미리보기
#if DEBUG
import SwiftUI

struct SignUpViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            SignUpView()
        }
    }
}
#endif
