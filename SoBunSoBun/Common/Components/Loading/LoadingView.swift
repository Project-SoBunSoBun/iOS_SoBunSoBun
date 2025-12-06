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
    
    private let gifImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        
        return iv
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
        
        // gif 적용
        guard let gifURL = Bundle.main.url(forResource: "Loading", withExtension: "gif"),
              let gifData = try? Data(contentsOf: gifURL),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            logger.critical("Loading GIF 파일을 찾지 못함")
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
        gifImageView.animationDuration = totalDuration * (1 / 1) // 기존 gif 속도의 1배
        gifImageView.animationRepeatCount = 0
        gifImageView.startAnimating()
        
        addSubview(gifImageView)
        
        gifImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(200)
        }
    }
}
