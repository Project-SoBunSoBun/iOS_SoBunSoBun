//
//  SettingDropDownView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/11/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SettingDropDownView: UIScrollView {
    enum AnimationAnchor { case topLeft, topCenter, topRight, left, center, right, bottomLeft, bottomCenter, bottomRight }
    
    private let tableName: String
    private let isHeightLimited: Bool
    
    var items: [String] = [] {
        didSet {
            setCells()
            
            if !items.isEmpty {
                bindCells(reactor: reactor)
            }
        }
    }
    
    typealias Reactor = SettingDropDownReactor
    private let reactor = SettingDropDownReactor()
    
    private let disposeBag = DisposeBag()
    
    let didCellTap = PublishSubject<String>()
    
    init(
        frame: CGRect = .zero,
        tableName: String,
        isHeightLimited: Bool = false // 높이 제한 유무
    ) {
        self.tableName = tableName
        self.isHeightLimited = isHeightLimited
        
        super.init(frame: frame)
        
        configureUI()
        bindState(reactor: reactor)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cellHeight: CGFloat = 52 {
        didSet {
            setCells()
        }
    }
    
    var textAlignment: NSTextAlignment = .center {
        didSet {
            setCells()
        }
    }
    
    var horizontalInset: CGFloat = 8 {
        didSet {
            stackView.layoutMargins = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        }
    }
    
    var animationAnchor: AnimationAnchor = .topRight
    
    // MARK: - 디자인 요소
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = .backgroundWhite
        sv.layer.cornerRadius = 16
        sv.clipsToBounds = true
        
        return sv
    }()
    
    // 구분선을 만들어주는 함수
    private func createDivider() -> UIView {
        let dv = UIView()
        dv.backgroundColor = .neutral200
        
        return dv
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        self.backgroundColor = .backgroundWhite
        
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        
        // 그림자
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary300.withAlphaComponent(0.16).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 24
        self.clipsToBounds = false
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 초기 설정
        self.isHidden = true
        self.alpha = 0
        
        addSubview(stackView)
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    // 셀 추가
    private func setCells() {
        // 기존 셀 제거
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        guard !items.isEmpty else {
            return
        }
        
        items.enumerated().forEach { index, item in
            let cell = SettingDropDownCell(
                localizableKey: item,
                tableName: tableName,
                textAlignment: textAlignment
            )
            
            stackView.addArrangedSubview(cell)
            
            cell.snp.remakeConstraints { make in
                make.height.equalTo(cellHeight)
            }
            
            if index < items.count - 1 {
                let divider = createDivider()
                
                stackView.addArrangedSubview(divider)
                
                divider.snp.makeConstraints { make in
                    make.height.equalTo(1)
                }
            }
        }
        
        if !isHeightLimited {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 16).cgPath
    }
    
    override var intrinsicContentSize: CGSize {
        let height = CGFloat(items.count) * cellHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}

extension SettingDropDownView {
    func setOpen(isOpen: Bool) {
        reactor.action.onNext(.buttonTapped(isOpen))
    }
    
    private func bindCells(reactor: Reactor) {
        stackView.arrangedSubviews.forEach {
            guard let cell = $0 as? SettingDropDownCell else { return }
            
            cell.didTap
                .map { Reactor.Action.selectCell($0) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
    }
    
    private func bindState(reactor: Reactor) {
        reactor.state.map { $0.isOpen }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isOpen in
                guard let self = self else { return }
                
                animateToggle(isOpen: isOpen)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedCell)
            .compactMap { $0 }
            .bind(to: didCellTap)
            .disposed(by: disposeBag)
    }
    
    private func animateToggle(isOpen: Bool) {
        let anchor: CGPoint
        let scale: CGFloat = 0.7
        
        switch animationAnchor {
        case .topLeft:
            anchor = CGPoint(x: 0, y: 0)
            
        case .topCenter:
            anchor = CGPoint(x: 0.5, y: 0)
            
        case .topRight:
            anchor = CGPoint(x: 1, y: 0)
            
        case .left:
            anchor = CGPoint(x: 0, y: 0.5)
            
        case .center:
            anchor = CGPoint(x: 0.5, y: 0.5)
            
        case .right:
            anchor = CGPoint(x: 1, y: 0.5)
            
        case .bottomLeft:
            anchor = CGPoint(x: 0, y: 1)
            
        case .bottomCenter:
            anchor = CGPoint(x: 0.5, y: 1)
            
        case .bottomRight:
            anchor = CGPoint(x: 1, y: 1)
        }
        
        let xOffset = self.bounds.width * (anchor.x - 0.5) * (1.0 - scale)
        let yOffset = self.bounds.height * (anchor.y - 0.5) * (1.0 - scale)
        
        // 애니메이션 위치 선적용을 위한 transform
        let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
            .scaledBy(x: scale, y: scale)
        
        if isOpen { // 열기
            self.isHidden = false
            self.transform = transform
            self.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                self.transform = .identity
                self.alpha = 1
            }
        } else { // 닫기
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn]) {
                self.transform = transform
                self.alpha = 0
            } completion: { _ in
                self.isHidden = true
                self.transform = .identity
            }
        }
    }
}
