//
//  WithdrawView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/5/26.
//

import UIKit
import SnapKit

class WithdrawView: UIViewController {
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        
        return tnb
    }()
    
    // 전체 스크롤 뷰
    private let scrollView = UIScrollView()
    
    // 스크롤 뷰가 들어갈 View
    private let contentView = UIView()
    
    // 화면 상단 타이틀 라벨
    private let titleLabel: UILabel = {
        var attributes = title24.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: String(localized: "WithdrawTitle", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 회원 탈퇴 안내 메세지를 만드는 함수
    private func makeWithdrawMessage(string: String) -> UILabel {
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral700
        
        let attributedText = NSAttributedString(
            string: string,
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.numberOfLines = 0
        
        return lb
    }
    
    // 회원 탈퇴 안내 메세지 1
    private lazy var withdrawMessage1 = makeWithdrawMessage(string: String(localized: "WithdrawMessage1", table: "Settings"))
    
    // 회원 탈퇴 안내 메세지 2
    private lazy var withdrawMessage2 = makeWithdrawMessage(string: String(localized: "WithdrawMessage2", table: "Settings"))
    
    // 회원 탈퇴 안내 메세지 3
    private lazy var withdrawMessage3 = makeWithdrawMessage(string: String(localized: "WithdrawMessage3", table: "Settings"))
    
    // 1. 2. 3. 라벨을 만들어 주는 함수
    private func makeNumberLabel(string: String) -> UILabel {
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral700
        
        let attributedText = NSAttributedString(
            string: string,
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        lb.snp.makeConstraints { make in
            make.width.equalTo(16)
        }
        
        return lb
    }
    
    private lazy var firstLabel = makeNumberLabel(string: "1.")
    
    private lazy var secondLabel = makeNumberLabel(string: "2.")
    
    private lazy var thirdLabel = makeNumberLabel(string: "3.")

    private let verticalStackView: UIStackView = {
        let vs = UIStackView()
        vs.axis = .vertical
        vs.spacing = 0
        
        return vs
    }()
    
    private func makeHorizontalStackView() -> UIStackView {
        let hs = UIStackView()
        hs.spacing = 8
        hs.axis = .horizontal
        hs.alignment = .top
        
        return hs
    }
    
    private lazy var firstStackView = makeHorizontalStackView()
    
    private lazy var secondStackView = makeHorizontalStackView()
    
    private lazy var thirdStackView = makeHorizontalStackView()
    
    // 탈퇴 사유 라벨
    private let reasonLabel: UILabel = {
        var attributes = title16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: String(localized: "WithdrawReason", table: "Settings"),
            attributes: attributes
        )
        
        let lb = UILabel()
        lb.attributedText = attributedText
        
        return lb
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, scrollView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // 스크롤 뷰 안에 들어가는 요소들
        [titleLabel, verticalStackView, reasonLabel].forEach {
            contentView.addSubview($0)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        [firstStackView, secondStackView, thirdStackView].forEach {
            verticalStackView.addArrangedSubview($0)
        }
        
        [firstLabel, withdrawMessage1].forEach {
            firstStackView.addArrangedSubview($0)
        }
        
        [secondLabel, withdrawMessage2].forEach {
            secondStackView.addArrangedSubview($0)
        }
        
        [thirdLabel, withdrawMessage3].forEach {
            thirdStackView.addArrangedSubview($0)
        }
        
        verticalStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        reasonLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(verticalStackView.snp.bottom).offset(34)
        }
    }
}
