//
//  BlueMeatballsRefreshController.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 12/5/25.
//

import UIKit
import ImageIO
import SnapKit
import RxSwift
import OSLog

class BlueMeatballsRefreshController: UIRefreshControl {
    private let disposeBag = DisposeBag()
    
    private lazy var gifImageView: GIFImageView = {
        let gif = GIFImageView(fileName: "BlueMeatballs")
        gif.contentMode = .scaleAspectFit
        gif.clipsToBounds = true
        
        return gif
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 80))
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.tintColor = .clear
        self.backgroundColor = .red
        
        addSubview(gifImageView)
        
        gifImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(80)
        }
        
        self.rx.controlEvent(.valueChanged)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.gifImageView.startAnimating()
            })
            .disposed(by: disposeBag)
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        gifImageView.stopAnimating()
    }
}
