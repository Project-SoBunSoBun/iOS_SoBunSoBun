//
//  BugReportView.swift
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

class BugReportView: UIViewController {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.BugReport.View"
    )
    
    typealias Reactor = BugReportReactor
    private let reactor = BugReportReactor()
    
    private let disposeBag = DisposeBag()
    
    private var profileImagePicker: ProfileImagePicker?
    
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
            string: String(localized: "imagePolicyNotice", table: "Settings"),
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
        
        [bugLocation, detailTextView, bugLocationDropDownView, selectedImageScrollView, imageUploadGuideLabel, imagePolicyNoticeLabel, agreeCheckBox, reportButton].forEach {
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
            make.top.equalTo(agreeCheckBox.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    // 이미지 피커 설정
    private func setImagePicker() {
        profileImagePicker = ProfileImagePicker(presentingViewController: self)
    }
}

extension BugReportView {
    private func bind(reactor: BugReportReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: BugReportReactor) {
        
    }
    
    private func bindState(reactor: BugReportReactor) {
        
    }
}
