//
//  LoadingView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/6/25.
//

import UIKit
import SnapKit
import OSLog

class LoadingView: UIView {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "LoadingView"
    )
    
    private let gifImageView: GIFImageView = {
        let gif = GIFImageView(fileName: "Loading")
        gif.contentMode = .scaleAspectFit
        gif.clipsToBounds = true
        
        return gif
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.backgroundColor = .alertBackgroundBlack
        
        addSubview(gifImageView)
        
        gifImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(200)
        }
    }
}
