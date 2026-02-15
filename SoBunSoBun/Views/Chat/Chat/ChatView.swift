//
//  ChatView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/15/26.
//

import UIKit
import SnapKit

class ChatView: UIViewController {

    // MARK: - 디자인 요소
    private lazy var gradientLayer = BackgroundGradientLayer(view)
    
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.backgroundColor = .backgroundWhite.withAlphaComponent(0.95)
        
        return tnb
    }()
    
    private let topNavigationButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .blackHorizontalDot.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.background.backgroundColor = .clear
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // safearea 그라데이션 미적용
    private let safeareaBottomBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    private let chatStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.backgroundColor = .backgroundWhite
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        return sv
    }()
    
    // 커스텀 메뉴 버튼
    private let plusButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = .lightbluePlus.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 5.5, leading: 5.5, bottom: 5.5, trailing: 5.5)
        config.background.backgroundColor = .primary100
        config.background.cornerRadius = 35 / 2
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // 채팅 textView
    private let chatTextView: AutoHeightTextView = {
        let ahtv = AutoHeightTextView(minHeight: 41, maxHeight: 83, maxLength: 140, fontStyle: body14)
        ahtv.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        ahtv.placeholder = String(localized: "SendMessage", table: "Chat")
        ahtv.showCharactersCount = false
        ahtv.backgroundColor = .neutral100
        ahtv.layer.cornerRadius = 16
        ahtv.clipsToBounds = true
        
        return ahtv
    }()
    
    // 전송 버튼
    private let sendButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .lightBluePointer.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    // 채팅 tableview
    private lazy var tableView: BaseTableView = {
        let tv = BaseTableView()
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.contentInset = .init(top: topNavigationButton.frame.height, left: 0, bottom: 0, right: 0)
        
        return tv
    }()
    
    // 커스텀 바텀 메뉴
    private let bottomMenuStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .center
        sv.backgroundColor = .backgroundWhite
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 32, left: 16, bottom: 32, right: 16)
        
        return sv
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        view.layer.addSublayer(gradientLayer)
        
        [topNavigationBar, chatStackView, safeareaBottomBackgroundView, tableView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        [plusButton, chatTextView, sendButton].forEach {
            chatStackView.addArrangedSubview($0)
        }
        
        chatStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        safeareaBottomBackgroundView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(chatStackView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(chatStackView.snp.top)
        }
    }
}

#if DEBUG
// 미리보기
import SwiftUI

struct ChatViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            ChatView()
        }
    }
}
#endif
