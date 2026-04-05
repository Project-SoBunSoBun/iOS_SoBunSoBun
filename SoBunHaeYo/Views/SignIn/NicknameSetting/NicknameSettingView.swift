//
//  NicknameSettingView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 10/23/25.
//

import UIKit
import ReactorKit
import SnapKit
import RxSwift
import RxCocoa
import Photos
import OSLog
import RxGesture

class NicknameSettingView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "NicknameSetting.View"
    )
    
    typealias Reactor = NicknameSettingReactor
    private let reactor = NicknameSettingReactor()
    
    private lazy var profileImagePicker = CustomImagePicker(presentingViewController: self)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 뒤로 가기 버튼
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "BlackLeft"), for: .normal)
        
        return button
    }()
    
    private let profileImage: UIImageView = {
        let image = UIImageView()
        image.image = .defaultProfile
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.cornerRadius = 50
        
        return image
    }()
    
    private let cameraImage: UIImageView = {
        let image = UIImageView()
        image.image = .camera
        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = true
        
        return image
    }()
    
    private let nickname = Nickname()
    
    private let nextButton = Button(title: String(localized: "Next", table: "Common"))
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [backButton, profileImage, cameraImage, nickname, nextButton].forEach {
            view.addSubview($0)
        }
        
        nextButton.isEnabled = false
        
        backButton.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.leading.equalToSuperview().offset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        profileImage.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(16)
        }
        
        cameraImage.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.bottom.equalTo(profileImage.snp.bottom)
            make.trailing.equalTo(profileImage.snp.trailing)
        }
        
        nickname.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(profileImage.snp.bottom).offset(24)
        }
        
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(64)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // 닉네임 유효성 검사 결과를 버튼 활성화 상태에 바인딩
        nickname.isNicknameValid
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

extension NicknameSettingView {
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
        
        // 닉네임 텍스트 변경
        nickname.textField.rx.text.orEmpty
            .map { Reactor.Action.nicknameChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭
        nextButton.rx.tap
            .map { Reactor.Action.nextButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 카메라 이미지 탭
        cameraImage.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.cameraImageTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 이미지 선택 완료
        profileImagePicker.imageSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                
                self.profileImage.image = image
                
                self.logger.debug("이미지 선택 완료")
                reactor.action.onNext(.profileImageSelected(image))
            })
            .disposed(by: disposeBag)
        
        // 이미지 선택 취소
        profileImagePicker.cancelled
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("이미지 선택 취소됨")
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        // 뒤로 가기 버튼
        reactor.pulse(\.$shouldPopViewController)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.logger.debug("로딩 중: \(isLoading)")
                }
            })
            .disposed(by: disposeBag)
        
        // 프로필 저장 성공
        reactor.pulse(\.$profileSaved)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("프로필 저장 성공")
                self.navigationController?.pushViewController(SignUpCompletedView(), animated: true)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        // 이미지 피커 표시
        reactor.pulse(\.$shouldShowImagePicker)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                
                self.profileImagePicker.checkPhotoLibraryPermission()
            })
            .disposed(by: disposeBag)
    }
}
