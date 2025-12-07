//
//  GIFImageView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/7/25.
//

import UIKit
import OSLog

class GIFImageView: UIImageView {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "GIFImageView"
    )
    
    /// fileName은 확장자 없이 입력하십시오, speed는 배속입니다.
    init(frame: CGRect = .zero, fileName: String, speed: CGFloat = 1.0) {
        super.init(frame: frame)
        
        configure(fileName: fileName, speed: speed)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(fileName: String, speed: CGFloat) {
        guard let gifURL = Bundle.main.url(forResource: fileName, withExtension: "gif"),
              let gifData = try? Data(contentsOf: gifURL),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            logger.critical("GIF 파일을 찾지 못함: \(fileName)")
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
        
        self.animationImages = images
        self.animationDuration = totalDuration * (1 / speed) // 기존 gif 속도 배율 조절
        self.animationRepeatCount = 0
        self.startAnimating()
    }
}
