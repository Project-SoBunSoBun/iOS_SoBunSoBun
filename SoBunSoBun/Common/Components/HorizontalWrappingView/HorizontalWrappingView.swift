//
//  HorizontalWrappingView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/21/26.
//

import UIKit

class HorizontalWrappingView: UIView {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    
    init(frame: CGRect = .zero,
         horizontalSpacing: CGFloat,
         verticalSpacing: CGFloat) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var arrangedSubviews: [UIView] = []
    
    private var maxWidth: CGFloat = 0
    private var cachedHeight: CGFloat = 0
    
    // 뷰 추가
    func addArrangedSubview(_ view: UIView) {
        arrangedSubviews.append(view)
        addSubview(view)
        setNeedsLayout()
    }
    
    // 뷰 삽입
    func insertArrangedSubview(_ view: UIView, at index: Int) {
        arrangedSubviews.insert(view, at: index)
        addSubview(view)
        setNeedsLayout()
    }
    
    // 특정 뷰 제거
    func removeArrangedSubview(_ view: UIView) {
        if let index = arrangedSubviews.firstIndex(of: view) {
            arrangedSubviews.remove(at: index)
            view.removeFromSuperview()
            setNeedsLayout()
        }
    }
    
    // 모든 뷰 제거
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        arrangedSubviews.removeAll()
        setNeedsLayout()
    }
    
    // 뷰 사이즈 계산
    private func getViewSize(view: UIView) -> CGSize? {
        if view.intrinsicContentSize.width > 0 && view.intrinsicContentSize.height > 0  {
            return view.intrinsicContentSize
        } else if view.frame.width > 0 && view.frame.height > 0 {
            return view.frame.size
        } else {
            return nil
        }
    }
    
    // 뷰 배치
    private func layoutArrangedSubviews() {
        let fullWidth: CGFloat = bounds.width
        
        guard !arrangedSubviews.isEmpty, fullWidth > 0 else {
            return
        }
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeightInCurrentRow: CGFloat = 0 // 해당 줄에서 가장 높은 높이
        var views: [HorizontalWrappingModel] = []
        
        for view in arrangedSubviews {
            // isHidden과 뷰 크기 유효성 검사
            guard !view.isHidden, let size = getViewSize(view: view) else {
                continue
            }
            
            // 현재 줄이 포화 상태
            if currentX + size.width > fullWidth {
                layoutRowViews(y: currentY, maxHeight: maxHeightInCurrentRow, views: views)
                
                // 초기화
                currentX = 0
                currentY += maxHeightInCurrentRow + verticalSpacing
                maxHeightInCurrentRow = 0
                views.removeAll()
            }
            
            views.append(HorizontalWrappingModel(view: view, x: currentX))
            
            // 다음 뷰 위치 계산
            currentX += size.width + horizontalSpacing
            maxHeightInCurrentRow = max(maxHeightInCurrentRow, size.height)
        }
        
        // 마지막 줄
        if !views.isEmpty {
            layoutRowViews(y: currentY, maxHeight: maxHeightInCurrentRow, views: views)
        }
        
        // intrinsicContentSize 업데이트
        let totalHeight = currentY + maxHeightInCurrentRow
        
        if totalHeight != cachedHeight {
            cachedHeight = totalHeight
            invalidateIntrinsicContentSize()
        }
    }
    
    // 뷰 열 배치
    private func layoutRowViews(y: CGFloat, maxHeight: CGFloat, views: [HorizontalWrappingModel]) {
        guard let lastView = views.last,
              let lastViewSize = getViewSize(view: lastView.view) else {
            return
        }
        
        // 해당 줄 너비 계산
        maxWidth = max(maxWidth, lastView.x + lastViewSize.width)
        
        for model in views {
            let view = model.view
            
            // isHidden과 뷰 크기 유효성 검사
            guard !view.isHidden, let size = getViewSize(view: view) else {
                continue
            }
            
            // frame 설정
            view.frame = CGRect(
                x: model.x,
                y: y,
                width: size.width,
                height: size.height
            )
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutArrangedSubviews()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: maxWidth, height: cachedHeight)
    }
}

extension HorizontalWrappingView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
}
