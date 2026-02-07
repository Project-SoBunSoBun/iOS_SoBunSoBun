//
//  EditProfileView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/28/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import OSLog
import RxGesture

class EditProfileView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "EditProfile.View"
    )
    
    typealias Reactor = EditProfileReactor
    private let reactor = EditProfileReactor()
    
    private let profileImageUrl: URL?
    private var profileImagePicker: ProfileImagePicker?
    
    private let disposeBag = DisposeBag()
    
    init(profileImageUrl: URL?) {
        self.profileImageUrl = profileImageUrl
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 완료 버튼
    private let completeButton = UIButton()
    
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "EditProfile", table: "Settings")
        tnb.parentViewController = self
        tnb.buttons = [completeButton]
        
        return tnb
    }()
    
    // 프로필 이미지 뷰
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.primary50.cgColor
        
        return iv
    }()
    
    // 카메라 아이콘 뷰
    private let cameraImage: UIImageView = {
        let image = UIImageView()
        image.image = .camera
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    // 닉네임 컴포넌트
    private let nickname = Nickname()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setImagePicker()
        setProfileImage(self.profileImageUrl)
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, profileImageView, cameraImage, nickname].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        // 프로필 이미지 뷰
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom).offset(16)
            make.size.equalTo(100)
        }
        
        // 카메라 이미지 뷰
        cameraImage.snp.makeConstraints { make in
            make.trailing.equalTo(profileImageView.snp.trailing)
            make.bottom.equalTo(profileImageView.snp.bottom)
            make.size.equalTo(48)
        }
        
        // 닉네임 컴포넌트
        nickname.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(profileImageView.snp.bottom).offset(24)
        }
    }
    
    // 초기 프로필 이미지 설정
    private func setProfileImage(_ profileImageUrl: URL?) {
        if let imageUrl = profileImageUrl {
            profileImageView.kf.setImage(
                with: imageUrl,
                placeholder: UIImage.defaultProfile) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let value):
                        let urlString = value.source.url?.absoluteString ?? "알 수 없음"
                        self.logger.debug("프로필 이미지 비동기 로드 성공: \(urlString)")
                        
                    case .failure(let error):
                        self.logger.error("\(error.localizedDescription)")
                        profileImageView.image = .defaultProfile
                    }
                }
        } else {
            // profileImageUrl이 nil 인 경우 기본 이미지 설정
            profileImageView.image = .defaultProfile
        }
    }
    
    // 이미지 피커 설정
    private func setImagePicker() {
        profileImagePicker = ProfileImagePicker(presentingViewController: self)
    }
}

extension EditProfileView {
    private func bind(reactor: EditProfileReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: EditProfileReactor) {
        // 카메라 이미지 탭
        cameraImage.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.cameraImageTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 이미지 선택 완료
        profileImagePicker?.imageSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                
                self.profileImageView.image = image
                self.logger.debug("이미지 선택 완료")
                reactor.action.onNext(.profileImageSelected(image))
            })
            .disposed(by: disposeBag)
        
        // 이미지 선택 취소
        profileImagePicker?.cancelled
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("이미지 선택 취소됨")
            })
            .disposed(by: disposeBag)
        
        // 닉네임 중복 확인 후 값 넘기기
        nickname.isNicknameValid
            .filter { $0 }
            .withLatestFrom(nickname.textField.rx.text.orEmpty) { _, nicknameText in
                Reactor.Action.nicknameChanged(nicknameText)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 닉네임 텍스트 필드가 비었을 때 완료 버튼 비활성화
        nickname.textField.rx.text.orEmpty
            .filter { $0.isEmpty }
            .map { _ in Reactor.Action.isNicknameEmpty }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 완료 버튼 클릭
        completeButton.rx.tap
            .map { Reactor.Action.completeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: EditProfileReactor) {
        // completeButton 활성화 / 비활성화
        reactor.state.map { $0.isCompleteButtonEnabled }
            .observe(on: MainScheduler.instance)
            .bind(to: completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // completeButton 텍스트 색상 변경
        reactor.state.map { $0.isCompleteButtonEnabled }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                
                self.updateCompleteButton(isEnabled)
            })
            .disposed(by: disposeBag)
        
        // 이미지 피커 표시
        reactor.pulse(\.$shouldShowImagePicker)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.profileImagePicker?.checkPhotoLibraryPermission()
            })
            .disposed(by: disposeBag)
        
        // 프로필 저장 성공
        reactor.pulse(\.$profileSaved)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("프로필 저장 성공")
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // 완료 버튼 활성화 / 비활성화
    private func updateCompleteButton(_ isEnabled: Bool) {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 13.5, leading: 12, bottom: 13.5, trailing: 12)
        
        let text = String(localized: "Complete", table: "Settings")
        
        var attributes = body14.attributes(alignment: .center)
        attributes[.foregroundColor] = isEnabled ? UIColor.neutral900 : UIColor.neutral300
        config.attributedTitle = AttributedString(NSAttributedString(string: text, attributes: attributes))
        
        completeButton.configuration = config
    }
}


