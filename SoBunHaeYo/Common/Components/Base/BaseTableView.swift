//
//  BaseTableView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/14/26.
//

import UIKit

class BaseTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.backgroundColor = .backgroundWhite
        self.isOpaque = true
        self.separatorStyle = .none
        self.rowHeight = UITableView.automaticDimension
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 1.0
        self.pinchGestureRecognizer?.isEnabled = false
    }
}
