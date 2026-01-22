//
//  LabelsWrappingView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/27/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 데이터는 labels에 삽입하십시오
class LabelsWrappingView<T: UILabel>: UIView {
    private let customLabelType: T.Type
    private let spacingX: CGFloat
    private let spacingY: CGFloat
    
    private let disposeBag = DisposeBag()
    
    // 외부 이벤트 전달
    let selectedCategory = PublishRelay<String>()
    
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
            addchipLabels()
        }
    }
    
    /// labels와 같은 개수를 맞추십시오
    var tags: [Int] = [] {
        didSet {
            addTags()
        }
    }
    
    func bindSelectedCategories(_ selectedCategories: Observable<[String]>) {
        selectedCategories
            .subscribe(onNext: { [weak self] categories in
                self?.updateSelectedCategories(categories)
            })
            .disposed(by: disposeBag)
    }
    
    func updateSelectedCategories(_ selectedCategories: [String]) {
        self.subviews.forEach { v in
            guard let label = v as? CategorySelectable else { return }
            
            label.isChecked = selectedCategories.contains(String(format: "%04d", label.tag))
        }
    }
    
    private var intrinsicHeight: CGFloat = 0
    
    private func addchipLabels(){
        // subview 초기화
        while self.subviews.count > labels.count {
            self.subviews[0].removeFromSuperview()
        }
        
        // chipLabels 수 맞추기
        while self.subviews.count < labels.count {
            let chipView = customLabelType.init()
            addSubview(chipView)
            
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
    
    private func displayChipLabels() {
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
    
    private func addTags() {
        if self.subviews.count == tags.count {
            self.subviews.enumerated().forEach { index, view in
                view.tag = tags[index]
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var sz = super.intrinsicContentSize
        sz.height = intrinsicHeight
        
        return sz
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        displayChipLabels()
    }
}
