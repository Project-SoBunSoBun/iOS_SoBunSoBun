//
//  BlueMeatballsRefreshController.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/5/25.
//

import UIKit
import ImageIO
import SnapKit
import RxSwift

class BlueMeatballsRefreshController: UIRefreshControl {
    private let disposeBag = DisposeBag()
    
    private let gifImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        
        return iv
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        tintColor = .clear
        
        // gif 적용
        guard let gifURL = Bundle.main.url(forResource: "BlueMeatballs", withExtension: "gif"),
              let gifData = try? Data(contentsOf: gifURL),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            print("BlueMeatballs GIF 파일을 찾지 못함")
            return
        }
        
        let frameCount = CGImageSourceGetCount(source)
        var images = [UIImage]()
        var totalDuration: TimeInterval = 0
        
        for i in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
                
                // frame duration 가져오기
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                   let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                   let duration = gifInfo[kCGImagePropertyGIFDelayTime as String] as? TimeInterval {
                    totalDuration += duration
                } else {
                    totalDuration += 0.1 // 기본값
                }
            }
        }
        
        gifImageView.animationImages = images
        gifImageView.animationDuration = totalDuration * (1 / 5) // 기존 gif 속도의 5배
        gifImageView.animationRepeatCount = 0
        
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
