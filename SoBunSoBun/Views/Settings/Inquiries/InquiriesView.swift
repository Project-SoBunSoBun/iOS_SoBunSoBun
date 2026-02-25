//
//  InquiriesView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/7/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import OSLog

class InquiriesView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.Inquiries.View"
    )
    
    typealias Reactor = InquiriesReactor
    private let reactor = InquiriesReactor()
    
    private let disposeBag = DisposeBag()
    
    private var inquiriesImagePicker: CustomImagePicker?
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "Contact", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 전체 스크롤 뷰
    private let scrollView = UIScrollView()
    
    // 스크롤 뷰가 들어갈 View
    private let contentView = UIView()
    
    // 문의 내용 선택 메뉴 박스
    private let selectedInquiries = SelectMenuBox(placeholder: String(localized: "SelectInquiries", table: "Settings"))
    
    // 문의 내용 제목 dropdown
    private let inquiriesDropDownView: SettingDropDownView = {
        let ddv = SettingDropDownView(tableName: "Settings", isHeightLimited: false)
        ddv.textAlignment = .center
        ddv.items = ["InquiriesReason001", "InquiriesReason002", "InquiriesReason003"]
        ddv.animationAnchor = .topCenter
        
        return ddv
    }()
    
    // 내용을 입력해 주세요
    private let detailTextView: AutoHeightTextView = {
        let ahtv = AutoHeightTextView(minHeight: 240, maxLength: 240, fontStyle: body16)
        ahtv.placeholder = String(localized: "InsertContent", table: "Common")
        ahtv.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        ahtv.showCharactersCount = true
        ahtv.layer.cornerRadius = 16
        ahtv.layer.borderWidth = 1
        ahtv.layer.borderColor = UIColor.neutral200.cgColor
        ahtv.frame = CGRectInset(ahtv.frame, -ahtv.layer.borderWidth, -ahtv.layer.borderWidth)
        
        return ahtv
    }()
    
    // 사진 선택 스택뷰를 감싸는 스크롤뷰
    private let selectedImageScrollView = UIScrollView()
    
    // 선택된 사진들이 들어가는 스택뷰
    private let selectedImageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .leading
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        return sv
    }()
    
    // 사진 선택 컴포넌트
    private let selectedImageView = SelectImage()
    
    // 이미지 업로드 가이드 라벨
    private let imageUploadGuideLabel: UILabel = {
        var attributes = body14.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral700
        
        var attributedText = NSAttributedString(
            string: String(localized: "PhotoUploadLimitGuide", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 이미지 삭제 경고문
    private let imagePolicyNoticeLabel: UILabel = {
        var attributes = body14.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.errorRed
        
        var attributedText = NSAttributedString(
            string: String(localized: "imagePolicyNotice1", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 답변 받을 이메일 주소
    private let receivedEmailLabel: UILabel = {
        var attributes = title16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: String(localized: "ReceivedEmailAddress", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // 이메일 입력 텍스트 필드
    private let inputEmailTextField: TextFieldUnderline = {
        let tf = TextFieldUnderline(maxLength: 40)
        tf.underlineLayer.backgroundColor = UIColor.neutral300.cgColor
        tf.placeholder = String(localized: "InputEmail", table: "Settings")
        
        return tf
    }()
    
    // 이메일 수집 안내
    private let emailCollectionDisclaimerLabel: UILabel = {
        var attributes = body12.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral300
        
        let attributedText = NSAttributedString(
            string: String(localized: "EmailCollectionDisclaimer", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // 문의 제출 동의 체크박스
    private let agreeCheckBox = TermsCheckBoxView()
    
    // 문의하기 버튼
    private let inquiriesButton = Button(title: String(localized: "Inquiries", table: "Settings"))
    
    // 로딩 화면
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        
        return view
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setImagePicker()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, scrollView].forEach {
            view.addSubview($0)
        }
        
        // 탑 네비게이션 바
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        [selectedInquiries, detailTextView, inquiriesDropDownView, selectedImageScrollView, imageUploadGuideLabel, imagePolicyNoticeLabel, receivedEmailLabel, inputEmailTextField, emailCollectionDisclaimerLabel, agreeCheckBox, inquiriesButton, loadingView].forEach {
            contentView.addSubview($0)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 문의 내용 선택 메뉴 박스
        selectedInquiries.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 내용을 입력해 주세요
        detailTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(selectedInquiries.snp.bottom).offset(16)
        }
        
        // 문의 내용 제목 dropdown
        inquiriesDropDownView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(selectedInquiries.snp.bottom).offset(16)
        }
        
        selectedImageScrollView.addSubview(selectedImageStackView)
        
        selectedImageScrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(detailTextView.snp.bottom).offset(16)
            make.height.equalTo(80)
        }
        
        // 선택된 사진들이 들어가는 스택뷰
        selectedImageStackView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        
        selectedImageView.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
        
        selectedImageStackView.addArrangedSubview(selectedImageView)
        
        // 이미지 업로드 가이드 라벨
        imageUploadGuideLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(selectedImageScrollView.snp.bottom).offset(16)
        }
        
        // 이미지 삭제 경고문
        imagePolicyNoticeLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(imageUploadGuideLabel.snp.bottom)
        }
        
        // 답변 받을 이메일 주소
        receivedEmailLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(imagePolicyNoticeLabel.snp.bottom).offset(24)
        }
        
        // 이메일 입력 텍스트 필드
        inputEmailTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(receivedEmailLabel.snp.bottom).offset(8)
        }
        
        // 이메일 수집 안내
        emailCollectionDisclaimerLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(inputEmailTextField.snp.bottom).offset(8)
        }
        
        // 문의 제출 동의 체크박스
        agreeCheckBox.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(emailCollectionDisclaimerLabel.snp.bottom).offset(16)
        }
        
        // 체크박스 설정
        agreeCheckBox.configure(title: String(localized: "AgreeInquiries", table: "Settings"), hasDetail: false, font: body14.font, textColor: .neutral900)
        
        // 문의하기 버튼
        inquiriesButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(agreeCheckBox.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
        
        // 로딩 뷰
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // 이미지 피커 설정
    private func setImagePicker() {
        inquiriesImagePicker = CustomImagePicker(presentingViewController: self, selectionMode: .multi(limit: 2))
    }
}

extension InquiriesView {
    private func bind(reactor: InquiriesReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: InquiriesReactor) {
        // 문의 내용 드롭다운 열기
        selectedInquiries.didTap
            .observe(on: MainScheduler.instance)
            .map { _ in Reactor.Action.menuBoxTapped(!reactor.currentState.isMenuOpen)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 문의 내용 선택
        inquiriesDropDownView.didCellTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { menu in
                reactor.action.onNext(.menuBoxTapped(false))
                
                guard let menuNum = Int(menu.suffix(3)) else { return }
                
                reactor.action.onNext(.dropDownCellTapped(menuNum))
            })
            .disposed(by: disposeBag)
        
        // 문의 내용 Text 전달
        detailTextView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.detailChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 이미지 추가 클릭
        selectedImageView.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.selectImageTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 이미지 선택 완료
        inquiriesImagePicker?.imagesSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] images in
                guard let self = self else { return }
                
                self.logger.debug("\(images.count)장의 이미지 선택 완료")
                reactor.action.onNext(.inquiriesImageSelected(images))
            })
            .disposed(by: disposeBag)
        
        // 이미지 선택 취소
        inquiriesImagePicker?.cancelled
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("이미지 선택 취소됨")
            })
            .disposed(by: disposeBag)
        
        // 이메일 Text 전달
        inputEmailTextField.rx.text
            .distinctUntilChanged()
            .map { Reactor.Action.emailChanged($0 ?? "")}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 제출 동의
        agreeCheckBox.isChecked
            .map { Reactor.Action.agreeCheckBoxTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 문의하기 버튼 선택
        inquiriesButton.rx.tap
            .map { Reactor.Action.inquiriesButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: InquiriesReactor) {
        // 문의 사유 드롭다운 개폐
        reactor.state.map { $0.isMenuOpen }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                inquiriesDropDownView.setOpen(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        // 문의 내용 라벨에 반영
        reactor.state.map { $0.menuNumber }
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] menuNumber in
                guard let self = self else { return }
                
                let paddedNumber = String(format: "%03d", menuNumber)
                let key = "InquiriesReason\(paddedNumber)"
                let localizedString = String(localized: String.LocalizationValue(key), table: "Settings")
                
                selectedInquiries.updateSelectedText(text: localizedString)
            })
            .disposed(by: disposeBag)
        
        // 이미지 피커 표시
        reactor.pulse(\.$shouldShowImagePicker)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.inquiriesImagePicker?.checkPhotoLibraryPermission()
            })
            .disposed(by: disposeBag)
        
        // 선택된 이미지 배열을 스택뷰에 업데이트
        reactor.state.map { $0.selectedImages }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] images in
                guard let self = self else { return }
                
                self.updateImageStackView(images: images)
            })
            .disposed(by: disposeBag)
        
        // 버튼 활성화 상태
        reactor.state.map { $0.isButtonEnabled }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: inquiriesButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 문의 내용 전송 완료
        reactor.pulse(\.$inquiriesCompleted)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("문의 완료 알림 표시")
                inquiriesAlert()
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                
                self.logger.error("에러: \(errorMessage)")
                self.errorAlert(title: errorMessage)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func updateImageStackView(images: [UIImage]) {
        // 선택된 사진 갯수 업데이트
        selectedImageView.updateImageCountLabel(current: images.count, total: 2)
        
        // 최대 선택시 터치 X
        selectedImageView.isUserInteractionEnabled = images.count < 2
        
        selectedImageStackView.arrangedSubviews.forEach { view in
            if view != selectedImageView {
                view.removeFromSuperview()
            }
        }
        
        images.enumerated().forEach { index, image in
            let containerView = SelectedImageView()
            containerView.updateImage(image: image)
            
            containerView.snp.makeConstraints { make in
                make.size.equalTo(80)
            }
            
            containerView.deleteButton.rx.tapGesture()
                .when(.recognized)
                .map { _ in Reactor.Action.deleteImage(index) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            selectedImageStackView.addArrangedSubview(containerView)
        }
    }
    
    private func inquiriesAlert() {
        let alert = CustomAlertView(
            title: String(localized: "CompletedInquiries", table: "Settings"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.show(on: self)
    }
    
    private func errorAlert(title: String) {
        let alert = CustomAlertView(
            title: title,
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.logger.debug("확인 버튼 클릭")
        }
        
        alert.show(on: self)
    }
}
