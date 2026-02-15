//
//  ChatRightMenuView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/16/26.
//

import UIKit

class ChatRightMenuView: UIViewController {
    // MARK: - 디자인 요소
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        
        return tnb
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    // 모임글 확인하기
    private let goToPostDetailCell = SettingCardCell(title: String(localized: "GoToPost", table: "Chat"), type: .button)
    private lazy var goToPostDetailCard = SettingCard(cells: [goToPostDetailCell])
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        
    }
}
