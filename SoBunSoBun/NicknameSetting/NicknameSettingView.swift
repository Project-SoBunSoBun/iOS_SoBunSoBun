//
//  NicknameSettingView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/23/25.
//

import UIKit
import ReactorKit
import SnapKit
import RxSwift
import RxCocoa
import Photos

class NicknameSettingView: CustomViewController {
    typealias Reactor = NicknameSettingReactor
    private let reactor = NicknameSettingReactor()
    
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
    
    private let nextButton = Button(title: String(localized: "Next"))
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
        setupImagePickerGesture()
    }
    
    // MARK: - 레이아웃 구성
    private func configureUI() {
        view.backgroundColor = .appleWhite
        
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
    
    private func setupImagePickerGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cameraImageTapped))
        cameraImage.addGestureRecognizer(tapGesture)
    }
    
    // cameraImage가 Tapped 됐을 때 실행되는 함수
    @objc private func cameraImageTapped() {
        checkPhotoLibraryPermission()
    }
    
    // 사진 권한을 확인하는 함수
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            presentImagePicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.presentImagePicker()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        default:
            break
        }
    }
    
    // 사용자가 사진을 선택할 수 있도록 하는 함수
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary // 이미지를 가져올 위치
        picker.allowsEditing = true // 사용자가 사진을 선택한 후 편집 화면을 표시할지 여부
        picker.delegate = self
        present(picker, animated: true) // UIImagePickerController를 모달 방식으로 화면에 표시
    }
    
    // 권한 요청이 없을 때 실행 될 설정으로 이동시키는 알러트
    private func showPermissionAlert() {
        let alertView = CustomAlertView(title: String(localized: "GalleryPermissionMessage")
        )
        
        alertView.onSettingsTapped = {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        alertView.onCancelTapped = {
            print("취소됨")
        }
        alertView.show(on: self)
    }
}

extension NicknameSettingView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        guard let image = selectedImage else { return }
        
        // 이미지 크기 체크 (5MB 제한)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let imageSizeInMB = Double(imageData.count) / (1024.0 * 1024.0)
            print("이미지 사이즈: \(imageSizeInMB)")
            if imageSizeInMB > 5.0 {
                showImageSizeAlert()
                return
            }
        }
        
        profileImage.image = image
        reactor.action.onNext(.profileImageSelected(image))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func showImageSizeAlert() {
        let alert = UIAlertController(
            title: String(localized: "ImageSizeExceeded"),
            message: String(localized: "SelectOnlyFilesUnder5MB"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localized: "Confirm"), style: .default))
        present(alert, animated: true)
    }
}

extension NicknameSettingView {
    // reactor와 view 연결
    func bind(reactor: NicknameSettingReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    func bindAction(reactor: NicknameSettingReactor) {
        // Back 버튼 탭
        backButton.rx.tap
            .map { Reactor.Action.backButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 닉네임 텍스트 변경
        nickname.nicknameText
            .map { Reactor.Action.nicknameChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭
        nextButton.rx.tap
            .map { Reactor.Action.nextButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(reactor: NicknameSettingReactor) {
        // 뒤로 가기 버튼
        reactor.pulse(\.$shouldPopViewController)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isLoading in
                if isLoading {
                    print("로딩 중...")
                }
            })
            .disposed(by: disposeBag)
        
        // 프로필 저장 성공
        reactor.pulse(\.$profileSaved)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                print("프로필 저장 성공")
                // TODO: 다음 화면으로 이동
                self?.navigationController?.pushViewController(SignUpCompletedView(), animated: true)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                print("에러 발생: \(message)")
                let alert = UIAlertController(title: String(localized: "Error"), message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: String(localized: "Confirm"), style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
