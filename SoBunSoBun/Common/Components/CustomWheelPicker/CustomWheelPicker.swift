//
//  CustomWheelPicker.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/15/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CustomWheelPicker: UIView {
    private var items: [String]
    private let itemHeight: CGFloat
    private let isInfiniteScroll: Bool
    private let multiplier = 1000 // 무한은 아니지만 무한처럼 보이게 만듦
    
    let selectedValueRelay = BehaviorRelay<String?>(value: nil)
    private let disposeBag = DisposeBag()
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    init(
        frame: CGRect = .zero,
        visibleItemCount: Int = 3,
        items: [String],
        itemHeight: CGFloat,
        selectedValue: String?,
        isInfiniteScroll: Bool,
        initialIndex: Int = 0
    ) {
        self.items = items
        self.itemHeight = itemHeight
        self.isInfiniteScroll = isInfiniteScroll
        
        super.init(frame: frame)
        
        configureUI(visibleItemCount: visibleItemCount)
        bind()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let selectedValue = selectedValue,
               let index = items.firstIndex(of: selectedValue) {
                selectedValueRelay.accept(selectedValue)
                initialScrollToRow(index: index + initialIndex)
            } else {
                initialScrollToRow(index: initialIndex)
            }
        }
        
        hapticGenerator.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(WheelPickerCell.self, forCellReuseIdentifier: WheelPickerCell.identifier)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.decelerationRate = .fast
        
        return tv
    }()
    
    private func divider() -> UIView {
        let view = UIView()
        view.backgroundColor = .neutral200
        
        view.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        return view
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI(visibleItemCount: Int) {
        backgroundColor = .clear
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let verticalPadding = itemHeight * CGFloat(visibleItemCount / 2)
        tableView.contentInset = UIEdgeInsets(top: verticalPadding, left: 0, bottom: verticalPadding, right: 0)
        
        let topLine = divider()
        addSubview(topLine)
        
        let bottomLine = divider()
        addSubview(bottomLine)
        
        topLine.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview().offset(-itemHeight / 2)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview().offset(itemHeight / 2)
        }
    }
}

extension CustomWheelPicker {
    private func bind() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        let totalItemsCount = isInfiniteScroll ? items.count * multiplier : items.count
        
        Observable.just(0..<totalItemsCount)
            .map{ $0 }
            .bind(to: tableView.rx.items(
                cellIdentifier: WheelPickerCell.identifier,
                cellType: WheelPickerCell.self
            )) { [weak self] row, _, cell in
                guard let self = self else { return }
                
                let actualIndex = row % items.count
                let isSelected = items[actualIndex] == selectedValueRelay.value
                
                cell.configure(text: self.items[actualIndex], isSelected: isSelected)
            }
            .disposed(by: disposeBag)
        
        // 스크롤 중
        tableView.rx.didScroll
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                updateCells()
                updateSelectedValue()
            })
            .disposed(by: disposeBag)
        
        // 스크롤을 멈췄을 때
        tableView.rx.didEndDragging
            .observe(on: MainScheduler.asyncInstance)
            .filter { !$0 } // willDecelerate가 false일 때
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                snapToMiddleItem()
            })
            .disposed(by: disposeBag)
        
        // 스크롤이 감속될 때
        tableView.rx.didEndDecelerating
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                snapToMiddleItem()
            })
            .disposed(by: disposeBag)
        
        // 햅틱 피드백
        selectedValueRelay
            .observe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                triggerHaptic()
            })
            .disposed(by: disposeBag)
    }
    
    private func getMiddleRowIndex() -> IndexPath? {
        let centerPoint: CGPoint = .init(x: tableView.bounds.midX, y: tableView.bounds.midY)
        
        return tableView.indexPathForRow(at: centerPoint)
    }
    
    private func updateCells() {
        tableView.visibleCells.forEach { cell in
            guard let pickerCell = cell as? WheelPickerCell,
                  let indexPath = tableView.indexPath(for: cell) else { return }
            
            let centerIndexPath = getMiddleRowIndex()
            let isSelected = indexPath.row == centerIndexPath?.row
            
            let actualIndex = indexPath.row % items.count
            let text = items[actualIndex]
            
            pickerCell.configure(text: text, isSelected: isSelected)
        }
    }
    
    private func updateSelectedValue() {
        guard let indexPath = getMiddleRowIndex() else { return }
        
        let actualIndex = indexPath.row % items.count
        let newValue = items[actualIndex]
        
        if newValue != selectedValueRelay.value {
            selectedValueRelay.accept(newValue)
        }
    }
    
    private func snapToMiddleItem() {
        if let indexPath = getMiddleRowIndex() {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                updateCells()
                updateSelectedValue()
            }
        }
    }
    
    private func triggerHaptic() {
        hapticGenerator.impactOccurred()
        hapticGenerator.prepare()
    }
    
    private func initialScrollToRow(index: Int) {
        guard index >= 0 && index < (isInfiniteScroll ? items.count * multiplier : items.count) else { return }
        
        if isInfiniteScroll {
            let middleSection = multiplier / 2
            let target = middleSection * items.count + index
            
            tableView.scrollToRow(
                at: IndexPath(row: target, section: 0),
                at: .middle,
                animated: false
            )
        } else {
            tableView.scrollToRow(
                at: IndexPath(row: index, section: 0),
                at: .middle,
                animated: false
            )
        }
    }
}

extension CustomWheelPicker: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }
}
