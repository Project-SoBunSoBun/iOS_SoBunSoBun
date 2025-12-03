//
//  NavigationBar.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/18/25.
//

import UIKit
import SnapKit
import SwiftUI
import RxSwift
import RxCocoa

class NavigationBar: UIView {
    private let disposeBag = DisposeBag()
    
    static let SHADOW_WIDTH: CGFloat = 344
    static let SHADOW_HEIGHT: CGFloat = 68
    
    private let buttons: [TabBarButton]
    
    /// 외부 뷰에 이벤트 전달
    let didChangeIndex = PublishSubject<Int>()
    
    /// updateSelectedIndex 함수로 상태를 변경하십시오.
    init(frame: CGRect = .zero, buttons: [TabBarButton]) {
        self.buttons = buttons
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 뒷배경
    private let tabBarView: UIView = {
        let view = UIView()
        // 모서리
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // 테두리
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.backgroundWhite.withAlphaComponent(0.5).cgColor
        view.frame = CGRectInset(view.frame, -view.layer.borderWidth, -view.layer.borderWidth)
        
        return view
    }()
    
    // UIKit에는 blur radius를 적용할 수 있는 방법이 없어 흐림배경은 SwiftUI 사용
    struct BlurredBackground: View {
        var body: some View {
            Rectangle()
                .fill(.clear)
                .blur(radius: 8)
        }
    }
    
    // 흐림배경
    private let blurredBackground: UIHostingController = {
        let hostingController = UIHostingController(rootView: BlurredBackground())
        // hostingController는 기본적으로 흰색 배경을 가지고 있음
        hostingController.view.backgroundColor = .backgroundWhite.withAlphaComponent(0.2)
        
        return hostingController
    }()
    
    // 탭바 내부 컨테이너
    private let tabBarContentsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    // 인디케이터
    private let tabBarIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        return view
    }()
    
    // 버튼 모음 컨테이너
    private let buttonsContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        
        return sv
    }()
    
    private var indicatorLeadingConstraint: Constraint? = nil
    
    // MARK: - 레이아웃 설정
    private func configure() {
        // 그림자
        self.clipsToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: Self.SHADOW_WIDTH, height: Self.SHADOW_HEIGHT), cornerRadius: 16).cgPath
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary400.cgColor
        self.layer.shadowOpacity = 0.16
        self.layer.shadowRadius = 24
        
        self.snp.makeConstraints { make in
            make.width.equalTo(self.layer.shadowPath!.boundingBoxOfPath.size.width)
            make.height.equalTo(self.layer.shadowPath!.boundingBoxOfPath.size.height)
        }
        
        // 뒷배경
        self.addSubview(tabBarView)
        
        tabBarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 흐림배경
        tabBarView.addSubview(blurredBackground.view)
        
        blurredBackground.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        // 탭바 내부 컨테이너
        tabBarView.addSubview(tabBarContentsContainer)
        
        tabBarContentsContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        // 인디케이터
        tabBarContentsContainer.addSubview(tabBarIndicator)
        
        tabBarIndicator.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            indicatorLeadingConstraint = make.leading.equalToSuperview().constraint
            make.width.equalToSuperview().dividedBy(buttons.count).offset(-(2 * (buttons.count - 1)))
        }
        
        // 버튼 모음 컨테이너
        tabBarContentsContainer.addSubview(buttonsContainer)
        
        buttonsContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 버튼 설정
        buttons.enumerated().forEach { index, button in
            buttonsContainer.addArrangedSubview(button)
            
            button.snp.makeConstraints { make in
                make.verticalEdges.equalToSuperview()
            }
            
            button.rx.tap
                .map { index }
                .bind(to: didChangeIndex)
                .disposed(by: disposeBag)
        }
    }
    
    // 인디케이터 애니메이션 설정
    private func updateIndicator(index: Int) {
        let indicatorWidth = tabBarIndicator.bounds.width
        guard indicatorWidth > 0 else { return }
        
        let leadingOffset = (CGFloat(index) * indicatorWidth) + (CGFloat(index) * 8)
        
        indicatorLeadingConstraint?.update(offset: leadingOffset)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut]) {
                self.tabBarContentsContainer.layoutIfNeeded()
            }
    }
    
    // NavigationBar 상태 변경
    func updateSelectedIndex(index: Int) {
        updateIndicator(index: index)
        
        buttons.enumerated().forEach { i, btn in
            btn.isSelected = (i == index)
        }
    }
}

class TabBarButton: UIButton {
    // 시작 첫 애니메이션 삭제
    private var isFirst: Bool = true
    
    // 비활성화, 활성화 순서
    private let icons: [UIImage]
    
    override var isSelected: Bool {
        didSet {
            if isFirst {
                firstToggle()
            } else {
                toggleAnimation()
            }
        }
    }
    
    init(frame: CGRect = .zero, icons: [UIImage], title: String) {
        self.icons = icons
        super.init(frame: frame)
        configureUI(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let stackview: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .center
        sv.isUserInteractionEnabled = false
        
        return sv
    }()
    
    private let icon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private let label: UILabel = {
        let lb = UILabel()
        lb.font = title12.font
        lb.textAlignment = .center
        lb.textColor = .neutral500
        
        return lb
    }()
    
    private func configureUI(title: String) {
        icon.image = icons[0]
        label.text = title
        
        self.addSubview(stackview)
        stackview.addArrangedSubview(icon)
        stackview.addArrangedSubview(label)
        
        stackview.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(4)
        }
        
        icon.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
    
    // 버튼 변환 애니메이션
    private func toggleAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + (self.isSelected ? 0.3 : 0)) {
            // icon 애니메이션
            UIView.transition(with: self.icon,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                self.icon.image = self.isSelected ? self.icons[1] : self.icons[0]
            }, completion: nil)
            
            // label 애니메이션
            UIView.animate(withDuration: 0.2) {
                self.label.textColor = self.isSelected ? .primary400 : .neutral500
            }
        }
    }
    
    // 첫 버튼 변환
    private func firstToggle() {
        self.icon.image = self.isSelected ? self.icons[1] : self.icons[0]
        self.label.textColor = self.isSelected ? .primary400 : .neutral500
        
        isFirst = false
    }
}
