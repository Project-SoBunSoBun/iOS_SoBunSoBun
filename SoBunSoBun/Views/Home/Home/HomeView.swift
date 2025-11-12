//
//  HomeView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/24/25.
//

import UIKit

class HomeView: UIViewController {
    // MARK: - 디자인 요소
    private let scrollView: UIScrollView = UIScrollView()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .logo
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private let letterLogoImageView: UIImageView = {
        let iv = UIImageView()
//        iv.image = .
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private let locationIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .glassLocation
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private let locationLabel: UILabel = {
        let lb = UILabel()
        lb.font = title16.font
        lb.textColor = .neutral900
        lb.textAlignment = .left
        
        return lb
    }()
    
    private let notificationButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .glassBell
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private let mypageButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .glassUser
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()

    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .backgroundWhite
    }
    
    
}

#if DEBUG
// 미리보기
import SwiftUI

struct HomeViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            HomeView()
        }
    }
}
#endif
