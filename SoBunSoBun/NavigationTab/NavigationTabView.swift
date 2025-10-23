//
//  NavigationView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/15/25.
//

import UIKit
import SnapKit
import SwiftUI

class NavigationView: UIViewController {
    private let viewControllers: [UIViewController] = [
        
    ]
    private let buttons: [TabBarButton] = [
        TabBarButton(icons: [.greyFilledHome, .blueFilledHome], title: "홈"),
        TabBarButton(icons: [.greyFilledMessage, .blueFilledMessage], title: "채팅"),
        TabBarButton(icons: [.greyFilledReceipt, .blueFilledReceipt], title: "정산"),
        TabBarButton(icons: [.greyFilledUser, .blueFilledUser], title: "마이페이지")
    ]
    
    var selectedIndex = 0 {
        willSet {
            previousIndex = selectedIndex
        }
        didSet {
            updateIndicator()
        }
    }
    private var previousIndex = 0
    
    // UIKit에는 blur radius를 적용할 수 있는 방법이 없어 뒷배경은 SwiftUI 사용
    struct BlurredBackground: View {
        var body: some View {
            Rectangle()
                .fill(.backgroundWhite.opacity(0.2))
                .blur(radius: 8)
        }
    }
    
    private let blurredBackground: UIHostingController = {
        let hostingController = UIHostingController(rootView: BlurredBackground())
        // hostingController는 기본적으로 흰색 배경을 가지고 있음
        hostingController.view.backgroundColor = .clear
        
        return hostingController
    }()
    
    private lazy var tabBarShadow: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 344, height: 68), cornerRadius: 16).cgPath
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.primary400.cgColor
        view.layer.shadowOpacity = 0.16
        view.layer.shadowRadius = 24
        
        return view
    }()
    
    private let tabBarView: UIView = {
        let view = UIView()
        // 모서리
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // 테두리
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.backgroundWhite.withAlphaComponent(0.5).cgColor
        view.frame = CGRectInset(view.frame, -2, -2)
        
        return view
    }()
    
    private let tabBarContentsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let buttonsContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        
        return sv
    }()
    
    private let tabBarIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        view.addSubview(tabBarShadow)
        
        tabBarShadow.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
            make.width.equalTo(tabBarShadow.layer.shadowPath!.boundingBoxOfPath.size.width)
            make.height.equalTo(tabBarShadow.layer.shadowPath!.boundingBoxOfPath.size.height)
        }
        
        tabBarShadow.addSubview(tabBarView)
        
        tabBarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }
        
        tabBarView.addSubview(blurredBackground.view)
        
        blurredBackground.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        tabBarView.addSubview(tabBarContentsContainer)
        
        tabBarContentsContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        tabBarContentsContainer.addSubview(tabBarIndicator)
        
        tabBarIndicator.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalToSuperview().dividedBy(buttons.count).offset(-(2 * (buttons.count - 1)))
        }
        
        tabBarContentsContainer.addSubview(buttonsContainer)
        
        buttonsContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buttons.forEach { btn in
            buttonsContainer.addArrangedSubview(btn)
        }
    }
    
    private func updateIndicator() {
        
    }
}

class TabBarButton: UIButton {
    // 비활성화, 활성화 순서
    private let icons: [UIImage]
    
    override var isSelected: Bool {
        didSet {
            toggleAnimation()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
}

// 미리보기
#if DEBUG
import SwiftUI

struct HomeViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            HomeView()
        }
    }
}
#endif
