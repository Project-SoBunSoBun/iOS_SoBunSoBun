//
//  GIFImageView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/7/25.
//

import UIKit
import Gifu
import OSLog

final class GIFImageView: UIImageView, GIFAnimatable {
    public lazy var animator: Animator? = {
        return Animator(withDelegate: self)
    }()
    
    override public func display(_ layer: CALayer) {
        updateImageIfNeeded()
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "GIFImageView"
    )
    
    /// fileName은 확장자 없이 입력하십시오,
    init(frame: CGRect = .zero, fileName: String) {
        super.init(frame: frame)
        
        configure(fileName: fileName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(fileName: String) {
        self.animate(withGIFNamed: fileName)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        self.prepareForReuse()
    }
}
