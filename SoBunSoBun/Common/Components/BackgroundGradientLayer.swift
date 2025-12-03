//
//  BackgroundGradientLayer.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/2/25.
//

import UIKit

class BackgroundGradientLayer: CAGradientLayer {
    /// lazy var로 초기화 후 뷰 컨트롤러의 view를 매개변수에 넣으십시오.
    init(_ parentView: UIView) {
        super.init()
        
        configureUI(parentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI(_ parentView: UIView) {
        colors = [
            UIColor.primary100.withAlphaComponent(0).cgColor,
            UIColor.primary100.withAlphaComponent(1).cgColor
        ]
        locations = [0,1]
        startPoint = CGPoint(x: 0.5, y: 0.0)
        endPoint = CGPoint(x: 0.5, y: 1.0)
        
        frame = CGRect(
            x: 0,
            y: parentView.bounds.height * 0.38, // 높이 기준 38%
            width: parentView.bounds.width,
            height: parentView.bounds.height * (1 - 0.38)
        )
    }
}
