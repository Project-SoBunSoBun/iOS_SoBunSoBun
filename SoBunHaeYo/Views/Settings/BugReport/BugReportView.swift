//
//  BugReportView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/7/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import OSLog

class BugReportView: BaseViewController {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.BugReport.View"
    )
    
    typealias Reactor = BugReportReactor
    private let reactor = BugReportReactor()
    
    private let disposeBag = DisposeBag()
    
    private lazy var bugImagePicker = CustomImagePicker(presentingViewController: self, selectionMode: .multi(limit: 2))
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.title = String(localized: "BugReport", table: "Settings")
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 전체 스크롤 뷰
    private let scrollView = UIScrollView()
    
    // 스크롤 뷰가 들어갈 View
    private let contentView = UIView()
    
    // 버그 발생 위치 선택 메뉴 박스
    private let bugLocation = SelectMenuBox(placeholder: String(localized: "SelectBugLocation", table: "Settings"))
    
    // 버그 발생 위치 dropdown
    private let bugLocationDropDownView: SettingDropDownView = {
        let ddv = SettingDropDownView(tableName: "Settings", isHeightLimited: false)
        ddv.textAlignment = .center
        ddv.items = ["BugLocation001", "BugLocation002", "BugLocation003", "BugLocation004", "BugLocation005", "BugLocation006"]
        ddv.animationAnchor = .topCenter
        
        return ddv
    }()
    
    // 버그에 대해 설명해 주세요
    private let detailTextView: AutoHeightTextView = {
        let ahtv = AutoHeightTextView(minHeight: 240, maxLength: 240, fontStyle: body16)
        ahtv.placeholder = String(localized: "DescribeYourBug", table: "Settings")
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
        
        let attributedText = NSAttributedString(
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
        
        let attributedText = NSAttributedString(
            string: String(localized: "imagePolicyNotice2", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 신고 제출 동의 체크박스
    private let agreeCheckBox = TermsCheckBoxView()
    
    // 신고하기 버튼
    private let reportButton = Button(title: String(localized: "Report", table: "Settings"))
    
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
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
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
        
        [bugLocation, detailTextView, selectedImageScrollView, bugLocationDropDownView, imageUploadGuideLabel, imagePolicyNoticeLabel, agreeCheckBox, reportButton, loadingView].forEach {
            contentView.addSubview($0)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 버그 발생 위치 선택 메뉴 박스
        bugLocation.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 버그에 대해 설명해 주세요
        detailTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(bugLocation.snp.bottom).offset(16)
        }
        
        // 버그 발생 위치 dropdown
        bugLocationDropDownView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(bugLocation.snp.bottom).offset(16)
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
        
        // 신고 제출 동의 체크박스
        agreeCheckBox.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(imagePolicyNoticeLabel.snp.bottom).offset(16)
        }
        
        // 체크박스 설정
        agreeCheckBox.configure(title: String(localized: "AgreeReport", table: "Settings"), hasDetail: false, font: body16.font, textColor: .neutral900)
        
        // 신고하기 버튼
        reportButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(agreeCheckBox.snp.bottom).offset(36)
            make.bottom.equalToSuperview()
        }
        
        // 로딩 뷰
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension BugReportView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        // 버그 발생 위치 드롭다운 열기
        bugLocation.didTap
            .observe(on: MainScheduler.instance)
            .map { _ in Reactor.Action.menuBoxTapped(!reactor.currentState.isMenuOpen)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 버그 발생 위치 선택
        bugLocationDropDownView.didCellTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { menu in
                reactor.action.onNext(.menuBoxTapped(false))
                
                guard let menuNum = Int(menu.suffix(3)) else { return }
                
                reactor.action.onNext(.dropDownCellTapped(menuNum))
            })
            .disposed(by: disposeBag)
        
        // 버그 내용 Text 전달
        detailTextView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.detailChanged($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 이미지 추가 클릭
        selectedImageView.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.selectedImageTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 이미지 선택 완료
        bugImagePicker.imagesSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] images in
                guard let self = self else { return }
                
                self.logger.debug("\(images.count)장의 이미지 선택 완료")
                reactor.action.onNext(.bugImageSelected(images))
            })
            .disposed(by: disposeBag)
        
        // 이미지 선택 취소
        bugImagePicker.cancelled
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("이미지 선택 취소됨")
            })
            .disposed(by: disposeBag)
        
        // 제출 동의
        agreeCheckBox.isChecked
            .map { Reactor.Action.agreeCheckBoxTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 신고하기 버튼 선택
        reportButton.rx.tap
            .map { Reactor.Action.bugReportButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        // 버그 발생 위치 드롭다운 개폐
        reactor.state.map { $0.isMenuOpen }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                bugLocationDropDownView.setOpen(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        // 버그 발생 위치 라벨에 반영
        reactor.state.map { $0.menuNumber }
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] menuNumber in
                guard let self = self else { return }
                
                let paddedNumber = String(format: "%03d", menuNumber)
                let key = "BugLocation\(paddedNumber)"
                let localizedString = String(localized: String.LocalizationValue(key), table: "Settings")
                
                bugLocation.updateSelectedText(text: localizedString)
            })
            .disposed(by: disposeBag)
        
        // 이미지 피커 표시
        reactor.pulse(\.$shouldShowIamgePicker)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.bugImagePicker.checkPhotoLibraryPermission()
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
            .bind(to: reportButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 버그 신고 전송 완료
        reactor.pulse(\.$bugReportCompleted)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.logger.debug("버그 신고 완료 알림 표시")
                bugReportAlert()
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
    
    private func bugReportAlert() {
        let alert = CustomAlertView(
            title: String(localized: "CompletedBugReport", table: "Settings"),
            primaryTitleKey: String(localized: "Confirm", table: "Common")
        )
        
        alert.onPrimaryTapped = {
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.show(on: self)
    }
}
