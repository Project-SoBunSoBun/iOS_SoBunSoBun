//
//  CustomViewController.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/9/25.
//

import UIKit

class CustomViewController: UIViewController {

    // 네비게이션 바 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
