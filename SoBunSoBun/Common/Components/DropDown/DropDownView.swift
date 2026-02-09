//
//  DropDownView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/17/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DropDownView: UIStackView {
    enum SelectionMode { case plain, check }
    enum AnimationAnchor { case topLeft, topCenter, topRight, left, center, right, bottomLeft, bottomCenter, bottomRight }
    
    private let selectionMode: SelectionMode
    private let tableName: String
    
    var items: [String] = [] {
        didSet {
            setCells()
            
            if !items.isEmpty {
                bindCells(reactor: reactor)
            }
        }
    }
    
    var cellHeight: CGFloat = 40 {
        didSet {
            setCells()
        }
    }
    
    var textAlignment: NSTextAlignment = .left {
        didSet {
            setCells()
        }
    }
    
    var horizontalInset: CGFloat = 8 {
        didSet {
            setCells()
        }
    }
    
    var animationAnchor: AnimationAnchor = .topRight
    
    typealias Reactor = DropDownReactor
    private let reactor: DropDownReactor = DropDownReactor()
    
    private let disposeBag = DisposeBag()
    
    let didCellTap = PublishSubject<String>()
    
    init(frame: CGRect = .zero, selectionMode: SelectionMode, tableName: String) {
        self.selectionMode = selectionMode
        self.tableName = tableName
        super.init(frame: frame)
        
        configureUI()
        bindState(reactor: reactor)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.backgroundColor = .backgroundWhite
        
        // 그림자
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary400.withAlphaComponent(0.24).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 16
        self.clipsToBounds = false
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // stackview 설정
        self.axis = .vertical
        self.spacing = 0
        self.alignment = .fill
        self.distribution = .fill
        
        self.backgroundColor = .backgroundWhite
        
        // 초기 설정
        self.isHidden = true
        self.alpha = 0
    }
    
    // 셀 추가
    private func setCells() {
        // 기존 셀 제거
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        guard !items.isEmpty else {
            return
        }
        
        items.enumerated().forEach { index, item in
            let cell = DropDownCell(localizableKey: item, tableName: tableName, selectionMode: selectionMode)
            
            cell.label.textAlignment = textAlignment
            
            if selectionMode == .check && index == 0 {
                cell.toggleSelect(isSelected: true)
            }
            
            self.addArrangedSubview(cell)
            
            cell.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(cellHeight)
            }
        }
    }
    
    private func animateToggle(isOpen: Bool) {
        let anchor: CGPoint
        let scale: CGFloat = 0.3
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 16).cgPath
    }
}

extension DropDownView {
    func setOpen(isOpen: Bool) {
        reactor.action.onNext(.buttonTapped(isOpen))
    }
    
    private func bindCells(reactor: Reactor) {
        // 처음에만 실행되도록
        if selectionMode == .check {
            reactor.action.onNext(.selectCell(items[0]))
        }
        
        self.arrangedSubviews.forEach {
            guard let cell = $0 as? DropDownCell else { return }
            
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
            .do(onNext: { [weak self] localizableKey in
                guard let self = self else { return }
                
                if selectionMode == .check {
                    cellCheckAndMoveToTop(localizableKey: localizableKey)
                }
            })
            .bind(to: didCellTap)
            .disposed(by: disposeBag)
    }
    
    private func cellCheckAndMoveToTop(localizableKey: String) {
        var selectedCell: DropDownCell?
        
        self.arrangedSubviews.forEach {
            guard let cell = $0 as? DropDownCell else { return }
            
            let isSelected = localizableKey == cell.localizableKey
            
            cell.toggleSelect(isSelected: isSelected)
            
            if isSelected {
                selectedCell = cell
            }
        }
        
        // 선택된 셀 최상단으로 위치
        if let selectedCell = selectedCell,
           selectedCell != self.arrangedSubviews.first {
            self.removeArrangedSubview(selectedCell)
            self.insertArrangedSubview(selectedCell, at: 0)
        }
    }
}
