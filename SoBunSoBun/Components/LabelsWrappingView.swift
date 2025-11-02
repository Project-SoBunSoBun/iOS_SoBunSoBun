//
//  LabelsWrappingView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/27/25.
//

import UIKit

/// 데이터는 labels에 삽입하십시오
class LabelsWrappingView<T: UILabel>: UIView {
    private let customLabelType: T.Type
    private let spacingX: CGFloat
    private let spacingY: CGFloat
    
    init(frame: CGRect = .zero,
         customLabelType: T.Type,
         spacingX: CGFloat,
         spacingY: CGFloat) {
        self.customLabelType = customLabelType
        self.spacingX = spacingX
        self.spacingY = spacingY
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labels: [String] = [] {
        didSet {
            addTagLabels()
        }
    }
    
    private var intrinsicHeight: CGFloat = 0
    
    private func addTagLabels(){
        // subview 초기화
        while self.subviews.count > labels.count {
            self.subviews[0].removeFromSuperview()
        }
        
        // tagLabels 수 맞추기
        while self.subviews.count < labels.count {
            let tagView = customLabelType.init()
            addSubview(tagView)
            
        }
        
        // now loop through labels and set text and size
        for (str, v) in zip(labels, self.subviews) {
            guard let label = v as? T else {
                fatalError("non-UILabel subview found!")
            }
            
            label.text = str
            label.frame.size = label.intrinsicContentSize
        }
    }
    
    private func displayTagLabels() {
        var currentOriginX: CGFloat = 0
        var currentOriginY: CGFloat = 0
        
        self.subviews.forEach { v in
            guard let label = v as? T else {
                fatalError("non-UILabel subview found!")
            }
            
            // 해당 행이 부모 뷰의 너비를 넘어갈 때
            if currentOriginX + label.frame.width > bounds.width {
                currentOriginX = 0
                currentOriginY += label.intrinsicContentSize.height + spacingY
            }
            
            // 라벨 위치 설정
            label.frame.origin.x = currentOriginX
            label.frame.origin.y = currentOriginY
            
            // X 위치를 라벨 너비 + 가로 간격만큼 이동
            currentOriginX += label.frame.width + spacingX
        }
        
        // 전체 높이 계산 및 intrinsicContentSize 업데이트
        intrinsicHeight = currentOriginY + ((self.subviews.first as? T)?.frame.height ?? 0)
        invalidateIntrinsicContentSize()
        
    }
    
    override var intrinsicContentSize: CGSize {
        var sz = super.intrinsicContentSize
        sz.height = intrinsicHeight
        
        return sz
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        displayTagLabels()
    }
}
